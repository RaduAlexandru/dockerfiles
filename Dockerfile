FROM ubuntu:xenial

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell


# Basic Utilities
RUN apt-get -y update && apt-get install -y zsh tree sudo ssh synaptic tmux git checkinstall cmake vim

#Needed for the command add-apt-repository
RUN apt-get -y install software-properties-common python-software-properties

# Additional development tools
RUN apt-get install -y x11-apps python-pip build-essential


#GCC-6.0
RUN sudo add-apt-repository -y  ppa:ubuntu-toolchain-r/test
RUN sudo apt -y  update
RUN sudo apt install -y gcc-6 g++-6
RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6


RUN apt-get update
RUN apt-get install -y tcpdump --fix-missing
# HACK around https://github.com/dotcloud/docker/issues/5490
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump
RUN mv /sbin/dhclient  /usr/sbin/dhclient

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config


#-------------------------------------------------------------------------------

#ROS
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN sudo apt-get update
RUN sudo apt-get install -y ros-kinetic-desktop-full
RUN sudo rosdep init
RUN rosdep update
RUN sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN sudo pip install catkin_tools

#GRAPHICS STUFF
RUN sudo apt-get install -y libglfw3-dev
RUN sudo apt-get install -y libglm-dev


#Velodyne driver dependency
RUN sudo apt-get install -y libpcap-dev

#Dependencies for Ceres and Orb-Slam 
RUN sudo apt-get install -y libgoogle-glog-dev
RUN sudo apt-get install -y libatlas-base-dev
RUN sudo apt-get install -y libblas-dev
RUN sudo apt-get install -y libsuitesparse-dev
RUN sudo apt-get install -y astyle

#GDB
RUN sudo apt-get install -y gdb

#TMUXINATOR
RUN gem install tmuxinator

#F.lux
RUN sudo add-apt-repository -y ppa:nathan-renniewaldock/flux
RUN sudo apt-get update
RUN sudo apt-get install -y fluxgui


#·-------------------------------------------------------------------------------

# Make SSH available
EXPOSE 22

# Mount the user's home directory
VOLUME "${home}"

#Intel vtune and  MKL
VOLUME "/opt/intel"

# Clone user into docker image and set up X11 sharing
RUN \
  echo "${user}:x:${uid}:${uid}:${user},,,:${home}:${shell}" >> /etc/passwd && \
  echo "${user}:x:${uid}:" >> /etc/group && \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
  chmod 0440 "/etc/sudoers.d/${user}"


#Set the user in the dialaout group so that the gps works
RUN usermod -a -G dialout ${user}
RUN usermod -a -G video ${user}
RUN usermod -a -G plugdev ${user}



# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# Switch to the workspace
WORKDIR ${workspace}
