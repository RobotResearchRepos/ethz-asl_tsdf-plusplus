FROM osrf/ros:noetic-desktop-full

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y git \
 && rm -rf /var/lib/apt/lists/*

# Clone code repository
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
 && mkdir -p /catkin_ws/src && cd /catkin_ws \
 && catkin init \
 && catkin config --extend /opt/ros/$ROS_VERSION --merge-devel \
 && catkin config --cmake-args -DCMAKE_CXX_STANDARD=14 -DCMAKE_BUILD_TYPE=Release \
 && wstool init src
 
RUN git clone --recurse-submodules \
      https://github.com/RobotResearchRepos/ethz-asl_tsdf-plusplus \
      /catkin_ws/src/tsdf-plusplus

# Install dependencies
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
 && cd /catkin_ws/src \
 && wstool merge -t . tsdf-plusplus/tsdf_plusplus_https.rosinstall \
 && wstool update

# Build package
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
 && cd /catkin_ws \
 && catkin build tsdf_plusplus_ros rgbd_segmentation mask_rcnn_ros cloud_segmentation

# Source workspace
RUN sed --in-place --expression \
      '$isource "/catkin_ws/devel/setup.bash"' \
      /ros_entrypoint.sh
