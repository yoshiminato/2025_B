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

"""ROS2 node for differential drive robot control.

This node bridges between a micro-ROS ESP32 and the ROS2 navigation stack.
It handles three responsibilities:
  1. Odometry calculation from rotary encoder ticks → publishes ``/odom``
  2. TF broadcast of the ``odom → base_link`` transform
  3. ``/cmd_vel`` → per-wheel motor velocity commands for the ESP32
"""

from geometry_msgs.msg import Quaternion, TransformStamped, Twist
from nav_msgs.msg import Odometry
import rclpy
from rclpy.node import Node
from std_msgs.msg import Float32, Int32
import tf2_ros

from diff_drive_controller.kinematics import (
    cmd_vel_to_wheel_velocities,
    differential_drive_odometry,
    yaw_to_quaternion_components,
)


class DiffDriveController(Node):
    """Differential drive controller node.

    Subscribes
    ----------
    /wheel/left_encoder  (std_msgs/Int32)
        Cumulative encoder tick count for the left wheel published by the ESP32.
    /wheel/right_encoder (std_msgs/Int32)
        Cumulative encoder tick count for the right wheel published by the ESP32.
    /cmd_vel             (geometry_msgs/Twist)
        Linear and angular velocity command from the navigation stack.

    Publishes
    ---------
    /odom                (nav_msgs/Odometry)
        Estimated robot pose and velocity in the odom frame.
    /wheel/left_cmd      (std_msgs/Float32)
        Target angular velocity [rad/s] for the left wheel motor (→ ESP32).
    /wheel/right_cmd     (std_msgs/Float32)
        Target angular velocity [rad/s] for the right wheel motor (→ ESP32).

    TF broadcast
    ------------
    odom → base_link     (geometry_msgs/TransformStamped)
        Transform kept in sync with the published odometry.

    Parameters
    ----------
    wheel_radius         float  (default 0.033 m)
    wheel_base           float  (default 0.160 m)
    encoder_resolution   int    (default 4096 ticks/revolution)
    odom_frame           str    (default "odom")
    base_frame           str    (default "base_link")
    publish_tf           bool   (default True)
    """

    def __init__(self):
        super().__init__('diff_drive_controller')

        # ------------------------------------------------------------------ #
        # Parameters
        # ------------------------------------------------------------------ #
        self.declare_parameter('wheel_radius', 0.033)
        self.declare_parameter('wheel_base', 0.160)
        self.declare_parameter('encoder_resolution', 4096)
        self.declare_parameter('odom_frame', 'odom')
        self.declare_parameter('base_frame', 'base_link')
        self.declare_parameter('publish_tf', True)

        self._wheel_radius = float(
            self.get_parameter('wheel_radius').value)
        self._wheel_base = float(
            self.get_parameter('wheel_base').value)
        self._encoder_resolution = int(
            self.get_parameter('encoder_resolution').value)
        self._odom_frame = str(
            self.get_parameter('odom_frame').value)
        self._base_frame = str(
            self.get_parameter('base_frame').value)
        self._publish_tf = bool(
            self.get_parameter('publish_tf').value)

        # ------------------------------------------------------------------ #
        # State variables
        # ------------------------------------------------------------------ #
        self._x = 0.0
        self._y = 0.0
        self._theta = 0.0

        self._left_ticks: int | None = None
        self._right_ticks: int | None = None
        self._last_left_ticks: int | None = None
        self._last_right_ticks: int | None = None

        self._last_time = self.get_clock().now()

        # ------------------------------------------------------------------ #
        # TF broadcaster
        # ------------------------------------------------------------------ #
        if self._publish_tf:
            self._tf_broadcaster = tf2_ros.TransformBroadcaster(self)

        # ------------------------------------------------------------------ #
        # Publishers
        # ------------------------------------------------------------------ #
        self._odom_pub = self.create_publisher(Odometry, '/odom', 10)
        self._left_cmd_pub = self.create_publisher(
            Float32, '/wheel/left_cmd', 10)
        self._right_cmd_pub = self.create_publisher(
            Float32, '/wheel/right_cmd', 10)

        # ------------------------------------------------------------------ #
        # Subscribers
        # ------------------------------------------------------------------ #
        self.create_subscription(
            Int32, '/wheel/left_encoder',
            self._left_encoder_callback, 10)
        self.create_subscription(
            Int32, '/wheel/right_encoder',
            self._right_encoder_callback, 10)
        self.create_subscription(
            Twist, '/cmd_vel',
            self._cmd_vel_callback, 10)

        self.get_logger().info(
            f'DiffDriveController started: '
            f'wheel_radius={self._wheel_radius} m, '
            f'wheel_base={self._wheel_base} m, '
            f'encoder_resolution={self._encoder_resolution} ticks/rev'
        )

    # ---------------------------------------------------------------------- #
    # Encoder callbacks
    # ---------------------------------------------------------------------- #

    def _left_encoder_callback(self, msg: Int32) -> None:
        """Store the latest left wheel tick count and update odometry."""
        self._left_ticks = msg.data
        self._update_odometry()

    def _right_encoder_callback(self, msg: Int32) -> None:
        """Store the latest right wheel tick count and update odometry."""
        self._right_ticks = msg.data
        self._update_odometry()

    # ---------------------------------------------------------------------- #
    # Odometry computation
    # ---------------------------------------------------------------------- #

    def _update_odometry(self) -> None:
        """Recompute pose from encoder deltas and publish odom + TF."""
        if self._left_ticks is None or self._right_ticks is None:
            return

        # First message: initialise reference and skip
        if self._last_left_ticks is None:
            self._last_left_ticks = self._left_ticks
            self._last_right_ticks = self._right_ticks
            self._last_time = self.get_clock().now()
            return

        dl_ticks = self._left_ticks - self._last_left_ticks
        dr_ticks = self._right_ticks - self._last_right_ticks

        self._last_left_ticks = self._left_ticks
        self._last_right_ticks = self._right_ticks

        # Integrate pose using differential drive kinematics
        self._x, self._y, self._theta, dc, dtheta = differential_drive_odometry(
            dl_ticks, dr_ticks,
            self._wheel_radius, self._wheel_base, self._encoder_resolution,
            self._x, self._y, self._theta,
        )

        # Velocity estimate
        now = self.get_clock().now()
        dt = (now - self._last_time).nanoseconds * 1e-9
        self._last_time = now

        if dt > 0.0:
            vx = dc / dt
            vth = dtheta / dt
        else:
            vx = 0.0
            vth = 0.0

        qx, qy, qz, qw = yaw_to_quaternion_components(self._theta)
        q = Quaternion()
        q.x, q.y, q.z, q.w = qx, qy, qz, qw

        # ---- Publish odometry -------------------------------------------- #
        odom = Odometry()
        odom.header.stamp = now.to_msg()
        odom.header.frame_id = self._odom_frame
        odom.child_frame_id = self._base_frame
        odom.pose.pose.position.x = self._x
        odom.pose.pose.position.y = self._y
        odom.pose.pose.position.z = 0.0
        odom.pose.pose.orientation = q
        odom.twist.twist.linear.x = vx
        odom.twist.twist.angular.z = vth
        self._odom_pub.publish(odom)

        # ---- Broadcast TF ------------------------------------------------ #
        if self._publish_tf:
            t = TransformStamped()
            t.header.stamp = now.to_msg()
            t.header.frame_id = self._odom_frame
            t.child_frame_id = self._base_frame
            t.transform.translation.x = self._x
            t.transform.translation.y = self._y
            t.transform.translation.z = 0.0
            t.transform.rotation = q
            self._tf_broadcaster.sendTransform(t)

    # ---------------------------------------------------------------------- #
    # cmd_vel callback
    # ---------------------------------------------------------------------- #

    def _cmd_vel_callback(self, msg: Twist) -> None:
        """Convert a Twist command to individual wheel velocity commands.

        Uses the standard differential drive inverse kinematics::

            v_left  = (vx - vth * wheel_base / 2) / wheel_radius  [rad/s]
            v_right = (vx + vth * wheel_base / 2) / wheel_radius  [rad/s]
        """
        vx = msg.linear.x
        vth = msg.angular.z

        left_vel, right_vel = cmd_vel_to_wheel_velocities(
            vx, vth, self._wheel_radius, self._wheel_base)

        left_msg = Float32()
        left_msg.data = float(left_vel)
        right_msg = Float32()
        right_msg.data = float(right_vel)

        self._left_cmd_pub.publish(left_msg)
        self._right_cmd_pub.publish(right_msg)


# -------------------------------------------------------------------------- #
# Entry point
# -------------------------------------------------------------------------- #

def main(args=None):
    """Spin the DiffDriveController node."""
    rclpy.init(args=args)
    node = DiffDriveController()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
