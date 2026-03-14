# Copyright 2024 diff_drive_controller contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Unit tests for diff_drive_controller.

The kinematics tests are pure-Python (no ROS2 dependency).
The node-integration tests are marked ``ros`` and require a live rclpy
installation; they are skipped automatically when rclpy is not available.
"""

import math
import sys

import pytest

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_HAS_RCLPY = False
try:
    import rclpy  # noqa: F401
    _HAS_RCLPY = True
except ImportError:
    pass

ros_only = pytest.mark.skipif(
    not _HAS_RCLPY, reason='rclpy not available')


# ---------------------------------------------------------------------------
# Pure-Python kinematics tests  (no ROS2 required)
# ---------------------------------------------------------------------------

from diff_drive_controller.kinematics import (  # noqa: E402
    cmd_vel_to_wheel_velocities,
    differential_drive_odometry,
    normalize_angle,
    yaw_to_quaternion_components,
)


class TestNormalizeAngle:
    """normalize_angle must wrap angles to (-π, π]."""

    def test_zero(self):
        assert normalize_angle(0.0) == pytest.approx(0.0)

    def test_pi(self):
        assert abs(normalize_angle(math.pi)) == pytest.approx(math.pi)

    def test_minus_pi(self):
        assert abs(normalize_angle(-math.pi)) == pytest.approx(math.pi)

    def test_over_pi(self):
        result = normalize_angle(math.pi + 0.1)
        assert result == pytest.approx(-math.pi + 0.1, abs=1e-9)

    def test_under_minus_pi(self):
        result = normalize_angle(-math.pi - 0.1)
        assert result == pytest.approx(math.pi - 0.1, abs=1e-9)

    def test_two_pi(self):
        assert normalize_angle(2 * math.pi) == pytest.approx(0.0, abs=1e-9)


class TestYawToQuaternionComponents:
    """yaw_to_quaternion_components must produce a valid unit quaternion."""

    def test_zero_yaw(self):
        x, y, z, w = yaw_to_quaternion_components(0.0)
        assert x == pytest.approx(0.0)
        assert y == pytest.approx(0.0)
        assert z == pytest.approx(0.0)
        assert w == pytest.approx(1.0)

    def test_pi_yaw(self):
        x, y, z, w = yaw_to_quaternion_components(math.pi)
        assert x == pytest.approx(0.0)
        assert y == pytest.approx(0.0)
        assert z == pytest.approx(1.0, abs=1e-9)
        assert w == pytest.approx(0.0, abs=1e-9)

    def test_unit_norm(self):
        for yaw in [0.0, math.pi / 4, math.pi / 2, math.pi, -math.pi / 3]:
            x, y, z, w = yaw_to_quaternion_components(yaw)
            norm = math.sqrt(x**2 + y**2 + z**2 + w**2)
            assert norm == pytest.approx(1.0), (
                f'Non-unit quaternion for yaw={yaw}')

    def test_half_pi_yaw(self):
        x, y, z, w = yaw_to_quaternion_components(math.pi / 2)
        assert z == pytest.approx(math.sin(math.pi / 4))
        assert w == pytest.approx(math.cos(math.pi / 4))


class TestCmdVelToWheelVelocities:
    """cmd_vel_to_wheel_velocities must implement inverse kinematics."""

    R = 0.05
    L = 0.20

    def test_pure_linear(self):
        left, right = cmd_vel_to_wheel_velocities(1.0, 0.0, self.R, self.L)
        expected = 1.0 / self.R
        assert left == pytest.approx(expected)
        assert right == pytest.approx(expected)

    def test_pure_rotation_ccw(self):
        left, right = cmd_vel_to_wheel_velocities(0.0, 1.0, self.R, self.L)
        assert left == pytest.approx(-right, abs=1e-9)
        assert left < 0
        assert right > 0

    def test_combined(self):
        left, right = cmd_vel_to_wheel_velocities(0.5, 1.0, self.R, self.L)
        assert right > left  # CCW → right wheel faster

    def test_zero_command(self):
        left, right = cmd_vel_to_wheel_velocities(0.0, 0.0, self.R, self.L)
        assert left == pytest.approx(0.0)
        assert right == pytest.approx(0.0)


class TestDifferentialDriveOdometry:
    """differential_drive_odometry must integrate pose correctly."""

    R = 0.05
    L = 0.20
    N = 100  # ticks / rev  (simple numbers)

    def _odom(self, dl_ticks, dr_ticks, x=0.0, y=0.0, theta=0.0):
        return differential_drive_odometry(
            dl_ticks, dr_ticks, self.R, self.L, self.N, x, y, theta)

    def test_straight_line_one_revolution(self):
        """Equal ticks → straight motion along current heading."""
        circumference = 2 * math.pi * self.R
        new_x, new_y, new_theta, dc, dtheta = self._odom(self.N, self.N)
        assert new_x == pytest.approx(circumference, rel=1e-6)
        assert new_y == pytest.approx(0.0, abs=1e-9)
        assert new_theta == pytest.approx(0.0, abs=1e-9)
        assert dc == pytest.approx(circumference, rel=1e-6)
        assert dtheta == pytest.approx(0.0, abs=1e-9)

    def test_pure_rotation_quarter_turn(self):
        """Right wheel advances by arc = L·π/2 → heading = π/2."""
        target_angle = math.pi / 2
        arc_length = self.L * target_angle
        right_ticks = int(
            arc_length / (2 * math.pi * self.R) * self.N)
        _, _, new_theta, _, _ = self._odom(0, right_ticks)
        assert new_theta == pytest.approx(target_angle, rel=1e-3)

    def test_zero_ticks_no_movement(self):
        x0, y0, th0 = 1.0, 2.0, 0.5
        new_x, new_y, new_theta, dc, dtheta = self._odom(0, 0, x0, y0, th0)
        assert new_x == pytest.approx(x0)
        assert new_y == pytest.approx(y0)
        assert new_theta == pytest.approx(th0)
        assert dc == pytest.approx(0.0)
        assert dtheta == pytest.approx(0.0)

    def test_heading_accumulation(self):
        """Two successive quarter-turns should yield heading = π/2."""
        arc_length = self.L * (math.pi / 4)
        right_ticks = int(arc_length / (2 * math.pi * self.R) * self.N)
        x, y, theta = 0.0, 0.0, 0.0
        for _ in range(2):
            x, y, theta, _, _ = self._odom(0, right_ticks, x, y, theta)
        assert theta == pytest.approx(math.pi / 2, rel=1e-3)

