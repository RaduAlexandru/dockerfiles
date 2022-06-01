FROM ubuntu:bionic

# FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
# FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu18.04

# ENV NVIDIA_VISIBLE_DEVICES \
#     ${NVIDIA_VISIBLE_DEVICES:-all}
# ENV NVIDIA_DRIVER_CAPABILITIES \
#     ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,display,video

# Arguments
ARG user
ARG uid
# ARG home
# ARG workspace
ARG shell

# switch to non interactive https://github.com/phusion/baseimage-docker/issues/319
ENV DEBIAN_FRONTEND noninteractive

# #copy the cleanup script so that its accesible in docker https://stackoverflow.com/a/53167819
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh



#to get opengl working inside docker according to https://medium.com/@benjamin.botto/opengl-and-cuda-applications-in-docker-af0eece000f1
# Dependencies for glvnd and X11.
RUN apt-get update \
  && apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
  && rm -rf /var/lib/apt/lists/*# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute


# Basic Utilities (dirmngr and gpg-agent is needed so that apt-get adv works)
RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh tmux git meld cmake cmake-curses-gui htop vim iputils-ping apt-utils apt-transport-https software-properties-common wget build-essential gdb valgrind silversearcher-ag curl dirmngr gpg-agent checkinstall locate baobab ninja-build libncurses5-dev gimp && sh "./cleanup.sh"

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config
RUN  echo "    IdentityFile ~/.ssh/id_ed25519" >> /etc/ssh/ssh_config

#fixing locales in docker https://daten-und-bass.io/blog/fixing-missing-locale-setting-in-ubuntu-docker-image/
RUN sudo apt-get update \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y locales locales-all \
    && sudo sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sudo dpkg-reconfigure --frontend=noninteractive locales \
    && sudo update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN sudo locale-gen

#-------------------------------------------------------------------------------




#python3
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python3-dev python3-pip python3-setuptools && sh "./cleanup.sh"

#switch to python3  https://linuxconfig.org/how-to-change-from-default-to-alternative-python-version-on-debian-linux
#this is needed so that catkin uses python3 and therefore pybind uses python3 which is the only one that can use spconv..
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2




COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh


#ROS and install also catkin for python3
# COPY cleanup.sh ./
# RUN chmod +x ./cleanup.sh
# RUN sudo add-apt-repository main
# RUN sudo add-apt-repository universe
# RUN sudo add-apt-repository multiverse
# RUN sudo add-apt-repository restricted
# RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
# # RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
# # RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
# RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
# RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ros-melodic-desktop-full && sh "./cleanup.sh"
# RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ros-melodic-nmea-msgs && sh "./cleanup.sh"
# RUN sudo python3 -m pip install catkin-tools rosdep
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python3-wstool && sh "./cleanup.sh"
# RUN sudo rosdep init
# RUN rosdep update
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python-catkin-tools && sh "./cleanup.sh"

#GRAPHICS STUFF
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libglfw3-dev && sh "./cleanup.sh"

#DEPDENCIES for easypbr
RUN sudo apt-get update &&  sudo DEBIAN_FRONTEND="noninteractive" apt-get install -y python3-pip python3-setuptools libglfw3-dev libboost-dev libeigen3-dev libpcl-dev libopencv-dev





# #default command to run when running the container
# ENTRYPOINT ./setup.sh &&  /bin/bash
ENTRYPOINT /bin/bash






#·-------------------------------------------------------------------------------

#Cleanup
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update

# Make SSH available
EXPOSE 22
EXPOSE 42421
# TensorBoard https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/docker/Dockerfile.gpu
EXPOSE 6006
# IPython https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/docker/Dockerfile.gpu
EXPOSE 8888

# Mount the user's home directory
# VOLUME "${home}"

#Intel vtune and  MKL
VOLUME "/opt/intel"

# Clone user into docker image and set up X11 sharing
RUN \
  echo "${user}:x:${uid}:${uid}:${user},,,:${home}:${shell}" >> /etc/passwd && \
  echo "${user}:x:${uid}:" >> /etc/group && \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
  chmod 0440 "/etc/sudoers.d/${user}"


#Set the user in the dialaout group so that the gps works
RUN usermod -a -G dialout ${user} && usermod -a -G video ${user} && usermod -a -G audio ${user} && usermod -a -G audio ${user}


#own some stuff because they were created by the root user in the docker container
# RUN chown -R ${user} /opt
# USER ${user}
# USER root


#make a new home directory 
RUN mkdir -p /home/${user}
RUN sudo chown ${user} /home/${user}
ENV HOME=/home/${user}

# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
# ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# Switch to the workspace
# WORKDIR ${workspace}
WORKDIR /home/${user}



# switch to interactive
ENV DEBIAN_FRONTEND teletype
