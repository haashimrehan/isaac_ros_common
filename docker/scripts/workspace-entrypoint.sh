#!/bin/bash
#
# Copyright (c) 2021, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

# Build ROS dependency
echo "alias build_workspace='cd /workspaces/isaac_ros-dev && colcon build --symlink-install && source install/setup.bash'" >> ~/.bashrc
echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
source /opt/ros/${ROS_DISTRO}/setup.bash

sudo apt-get update
rosdep update

# Install ROS2 deps
source ${ROS_ROOT}/install/setup.bash \
    && export ROS_PACKAGE_PATH=${AMENT_PREFIX_PATH} \
    && mkdir -p src/external_packages \
    && rosinstall_generator --deps --exclude RPP --rosdistro ${ROS_DISTRO} \
    `rosdep keys --ignore-src --rosdistro=humble --from-paths src | egrep -v "PKG_2_SKIP1|PKG_2_SKIP2"` \
    > ros.${ROS_DISTRO}.external_packages.rosinstall \
    && cat ros.${ROS_DISTRO}.external_packages.rosinstall \
    && vcs import src/external_packages < ros.${ROS_DISTRO}.external_packages.rosinstall 

source ${ROS_ROOT}/install/setup.bash && apt-get update || true && rosdep update && rosdep install -y --skip-keys="PUT_DEPS_TO_SKIP_HERE" \
    --from-paths src --ignore-src -y --rosdistro=${ROS_DISTRO}


# Restart udev daemon
sudo service udev restart

$@
