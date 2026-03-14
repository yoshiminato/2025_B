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

"""Pure-Python kinematics helpers for a differential drive robot.

All functions here are free of ROS2 dependencies so they can be tested
without a running ROS2 installation.
"""

import math


def normalize_angle(angle: float) -> float:
    """Wrap *angle* (rad) to the range (-π, π]."""
    return math.atan2(math.sin(angle), math.cos(angle))


def yaw_to_quaternion_components(yaw: float) -> tuple[float, float, float, float]:
    """Convert a yaw angle [rad] to quaternion components (x, y, z, w)."""
    return (0.0, 0.0, math.sin(yaw / 2.0), math.cos(yaw / 2.0))


def differential_drive_odometry(
    dl_ticks: int,
    dr_ticks: int,
    wheel_radius: float,
    wheel_base: float,
    encoder_resolution: int,
    x: float,
    y: float,
    theta: float,
) -> tuple[float, float, float, float, float]:
    """Integrate encoder ticks into an updated robot pose.

    Parameters
    ----------
    dl_ticks, dr_ticks:
        Change in encoder ticks since the last call (left / right wheel).
    wheel_radius:
        Wheel radius [m].
    wheel_base:
        Distance between the two wheel contact points [m].
    encoder_resolution:
        Ticks per full wheel revolution.
    x, y, theta:
        Current robot pose.

    Returns
    -------
    (new_x, new_y, new_theta, dc, dtheta)
        Updated pose, centre displacement [m], and heading change [rad].
    """
    meters_per_tick = 2.0 * math.pi * wheel_radius / encoder_resolution
    dl = dl_ticks * meters_per_tick
    dr = dr_ticks * meters_per_tick

    dc = (dl + dr) / 2.0
    dtheta = (dr - dl) / wheel_base

    mid_theta = theta + dtheta / 2.0
    new_x = x + dc * math.cos(mid_theta)
    new_y = y + dc * math.sin(mid_theta)
    new_theta = normalize_angle(theta + dtheta)

    return new_x, new_y, new_theta, dc, dtheta


def cmd_vel_to_wheel_velocities(
    vx: float,
    vth: float,
    wheel_radius: float,
    wheel_base: float,
) -> tuple[float, float]:
    """Compute per-wheel angular velocities from a Twist command.

    Parameters
    ----------
    vx:
        Linear velocity [m/s].
    vth:
        Angular velocity [rad/s].
    wheel_radius:
        Wheel radius [m].
    wheel_base:
        Distance between wheel contact points [m].

    Returns
    -------
    (left_omega, right_omega) in [rad/s].
    """
    left_omega = (vx - vth * wheel_base / 2.0) / wheel_radius
    right_omega = (vx + vth * wheel_base / 2.0) / wheel_radius
    return left_omega, right_omega
