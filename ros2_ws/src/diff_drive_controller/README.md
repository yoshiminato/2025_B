# diff_drive_controller

A ROS2 Python package for a **differential drive robot** connected to an **ESP32 via micro-ROS**.

## Features

| Feature | Description |
|---------|-------------|
| **Odometry** | Computes robot pose from rotary encoder ticks and publishes `nav_msgs/Odometry` on `/odom` |
| **TF broadcast** | Continuously broadcasts the `odom → base_link` transform |
| **Motor commands** | Converts `geometry_msgs/Twist` on `/cmd_vel` to per-wheel angular-velocity commands for the ESP32 |

---

## Topic interface

### Subscribed topics

| Topic | Type | Description |
|-------|------|-------------|
| `/wheel/left_encoder` | `std_msgs/Int32` | Cumulative encoder tick count from the left wheel (published by ESP32 via micro-ROS) |
| `/wheel/right_encoder` | `std_msgs/Int32` | Cumulative encoder tick count from the right wheel (published by ESP32 via micro-ROS) |
| `/cmd_vel` | `geometry_msgs/Twist` | Velocity command from the navigation stack |

### Published topics

| Topic | Type | Description |
|-------|------|-------------|
| `/odom` | `nav_msgs/Odometry` | Estimated pose and velocity of the robot |
| `/wheel/left_cmd` | `std_msgs/Float32` | Left wheel target angular velocity [rad/s] → ESP32 |
| `/wheel/right_cmd` | `std_msgs/Float32` | Right wheel target angular velocity [rad/s] → ESP32 |

### TF frames

```
odom ──► base_link
```

---

## Parameters

Configure the node in `config/params.yaml`:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `wheel_radius` | double | `0.033` | Wheel radius [m] |
| `wheel_base` | double | `0.160` | Distance between wheel contact points [m] |
| `encoder_resolution` | int | `4096` | Encoder ticks per wheel revolution |
| `odom_frame` | string | `"odom"` | Name of the odometry frame |
| `base_frame` | string | `"base_link"` | Name of the robot base frame |
| `publish_tf` | bool | `true` | Whether to broadcast the `odom → base_link` TF |

---

## ESP32 / micro-ROS integration

The node expects the ESP32 firmware to:

1. **Publish** cumulative encoder tick counts on `/wheel/left_encoder` and `/wheel/right_encoder` using `std_msgs/Int32`.
2. **Subscribe** to `/wheel/left_cmd` and `/wheel/right_cmd` (`std_msgs/Float32`) and use the values as target angular velocities [rad/s] for the motor driver.

A minimal micro-ROS sketch skeleton:

```c
#include <micro_ros_arduino.h>
#include <std_msgs/msg/int32.h>
#include <std_msgs/msg/float32.h>

// Publishers (encoder → ROS2)
rcl_publisher_t left_enc_pub, right_enc_pub;
std_msgs__msg__Int32 left_enc_msg, right_enc_msg;

// Subscribers (ROS2 → motor)
rcl_subscription_t left_cmd_sub, right_cmd_sub;
std_msgs__msg__Float32 left_cmd_msg, right_cmd_msg;

void left_cmd_callback(const void *msg) {
    float omega = ((std_msgs__msg__Float32 *)msg)->data;
    // TODO: convert omega [rad/s] to PWM and drive left motor
}

void right_cmd_callback(const void *msg) {
    float omega = ((std_msgs__msg__Float32 *)msg)->data;
    // TODO: convert omega [rad/s] to PWM and drive right motor
}
```

---

## Build & run

```bash
# Inside your ROS2 workspace
cd ros2_ws
colcon build --packages-select diff_drive_controller
source install/setup.bash

# Launch with default parameters
ros2 launch diff_drive_controller diff_drive.launch.py

# Override the parameter file
ros2 launch diff_drive_controller diff_drive.launch.py \
    params_file:=/path/to/my_robot_params.yaml
```

---

## Kinematics

### Forward kinematics (encoder → odometry)

```
d_left  = Δticks_left  × (2π × r) / N
d_right = Δticks_right × (2π × r) / N

d_center = (d_left + d_right) / 2
dθ       = (d_right − d_left) / L

x     += d_center × cos(θ + dθ/2)
y     += d_center × sin(θ + dθ/2)
θ     += dθ
```

where `r` = wheel radius, `N` = encoder resolution, `L` = wheel base.

### Inverse kinematics (cmd_vel → wheel commands)

```
ω_left  = (vx − ωz × L/2) / r   [rad/s]
ω_right = (vx + ωz × L/2) / r   [rad/s]
```
