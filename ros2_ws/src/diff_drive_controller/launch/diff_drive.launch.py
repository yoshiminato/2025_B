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

"""Launch file for the differential drive controller node."""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    """Return a LaunchDescription for diff_drive_controller."""
    pkg_share = FindPackageShare('diff_drive_controller')

    params_file_arg = DeclareLaunchArgument(
        'params_file',
        default_value=PathJoinSubstitution(
            [pkg_share, 'config', 'params.yaml']),
        description='Full path to the ROS2 parameters file for the node',
    )

    diff_drive_node = Node(
        package='diff_drive_controller',
        executable='diff_drive_node',
        name='diff_drive_controller',
        parameters=[LaunchConfiguration('params_file')],
        output='screen',
    )

    return LaunchDescription([
        params_file_arg,
        diff_drive_node,
    ])
