FROM ubuntu:jammy

RUN apt update

ENV ROS_DISTRO=humble
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Fix locale
RUN apt-get update && \
    echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get install -y \
        sudo \
        locales \
        tzdata
RUN locale-gen en_US.UTF-8; dpkg-reconfigure -f noninteractive locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get install -y \
        software-properties-common \
        curl \
        gnupg2 && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update && \
    apt-get install -y  \
        bash-completion \
        build-essential \
        cmake \
        git \
        iproute2 \
        ros-${ROS_DISTRO}-ros-core \
        ros-${ROS_DISTRO}-rmw-cyclonedds-cos-humble-moveitpp \
        ros-dev-tools && \
        ros-${ROS_DISTRO}-moveit && \
        ros-${ROS_DISTRO}-gazebo-ros2-control && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user \
    && echo "user:user" | chpasswd \
    && usermod -aG sudo user \
    && echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/user \
    && usermod --uid 1000 user 
    && usermod --gid 1000 user   

USER user
WORKDIR /

RUN echo 'alias cb="colcon build --symlink-install"'  >> ~/.bashrc && \
    echo 'alias ros_source="source install/setup.bash"' >> ~/.bashrc 

