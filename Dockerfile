FROM dorowu/ubuntu-desktop-lxde-vnc:bionic-lxqt
LABEL maintainer "jbnunn@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Setup your sources list and keys
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
#RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN sudo apt install curl 
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -


# Install ROS Melodic
RUN apt update
RUN apt-get install -y ros-melodic-desktop-full
run sudo apt-get install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN rosdep init && rosdep update

# Install some essentials
RUN apt-get install -y git wget curl nano mercurial python-pip
RUN apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

# Setup the shell
RUN /bin/bash -c "echo 'export HOME=/home/ubuntu' >> /root/.bashrc"
RUN /bin/bash -c "echo 'source /opt/ros/melodic/setup.bash' >> /root/.bashrc"
RUN cp /root/.bashrc /home/ubuntu/.bashrc
RUN /bin/bash -c "source /home/ubuntu/.bashrc"

# Install VS Code and Python extensions
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
RUN install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
RUN apt-get install -y apt-transport-https
RUN apt-get update
RUN apt-get install -y code
#RUN pip install pylint

# Install Catkin
RUN apt-get install -y ros-melodic-catkin python-catkin-tools

# Copy some starter models
RUN mkdir -p /home/ubuntu/.gazebo/
COPY models /home/ubuntu/.gazebo/models

# Turtlebot3
RUN apt-get install -y ros-melodic-turtlebot3-msgs
RUN apt-get install -y ros-melodic-turtlebot3

# prepare catkin workspace
RUN mkdir -p /home/ubuntu/catkin_ws/src/turtlebot3_simulations 
COPY modules /home/ubuntu/catkin_ws/src/turtlebot3_simulations 

WORKDIR /home/ubuntu/catkin_ws

RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd /home/ubuntu/catkin_ws; catkin_make'

# Move_base
RUN apt-get install -y ros-melodic-move-base-flex ros-melodic-dwa-local-planner ros-melodic-global-planner ros-melodic-teb-local-planner

# sourcing
RUN echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo "source /home/ubuntu/catkin_ws/devel/setup.bash" >> ~/.bashrc

