# FROM ubuntu:bionic
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,display,video

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# switch to non interactive https://github.com/phusion/baseimage-docker/issues/319
ENV DEBIAN_FRONTEND noninteractive

# #copy the cleanup script so that its accesible in docker https://stackoverflow.com/a/53167819
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh

# Basic Utilities (dirmngr and gpg-agent is needed so that apt-get adv works)
RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh tmux git meld cmake cmake-curses-gui htop vim iputils-ping apt-utils apt-transport-https software-properties-common wget build-essential gdb valgrind silversearcher-ag curl dirmngr gpg-agent checkinstall locate baobab ninja-build libncurses5-dev && sh "./cleanup.sh"

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

#-------------------------------------------------------------------------------

#python3
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python3-dev python3-pip python3-setuptools && sh "./cleanup.sh"

#switch to python3  https://linuxconfig.org/how-to-change-from-default-to-alternative-python-version-on-debian-linux
#this is needed so that catkin uses python3 and therefore pybind uses python3 which is the only one that can use spconv..
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2






#ROS and install also catkin for python3
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh
RUN sudo add-apt-repository main
RUN sudo add-apt-repository universe
RUN sudo add-apt-repository multiverse
RUN sudo add-apt-repository restricted
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
# RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 
RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ros-melodic-desktop-full && sh "./cleanup.sh"
RUN sudo python3 -m pip install catkin-tools rosdep
RUN sudo rosdep init
RUN rosdep update
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python-catkin-tools && sh "./cleanup.sh"

#GRAPHICS STUFF
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libglfw3-dev && sh "./cleanup.sh"


#nativefiledialog reuires it https://github.com/mlabbe/nativefiledialog
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libgtk-3-dev && sh "./cleanup.sh"

#Halide requires also Eigen but there is an issue when compiling cuda10 and eigen, solution is to upgrade eigen https://github.com/tensorflow/tensorflow/issues/15389
RUN wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.3.7-1_all.deb
RUN sudo dpkg -i libeigen3-dev_3.3.7-1_all.deb


#nvvp crashes under the default java11 so we need java8 as explained here https://bugs.launchpad.net/ubuntu/+source/nvidia-cuda-toolkit/+bug/1766948
RUN sudo apt-get update && sudo apt-get install  -y --no-install-recommends  openjdk-8-jre && sh "./cleanup.sh"
RUN sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
RUN sudo apt-get update && apt-get install -y --no-install-recommends cuda-command-line-tools-$CUDA_PKG_VERSION cuda-visual-tools-$CUDA_PKG_VERSION && sh "./cleanup.sh"

#pytorch
# RUN conda config --env --add channels pytorch
# RUN conda install -n pt numpy pyyaml mkl mkl-include setuptools cmake cffi typing magma-cuda100 && conda clean -ya 
# ENV PATH /opt/conda/envs/pt/bin:$PATH
WORKDIR /
# RUN GIT_TRACE=1 GIT_CURL_VERBOSE=1 git clone --verbose --recursive https://github.com/pytorch/pytorch /opt/pytorch
# RUN git clone --verbose --recursive git@github.com:pytorch/pytorch.git /opt/pytorch
#RUN git clone --verbose --recursive https://github.com/pytorch/pytorch  /opt/pytorch
RUN git clone --verbose https://github.com/pytorch/pytorch  /opt/pytorch
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python3-pip python3-setuptools && sh "./cleanup.sh"
RUN pip3 install numpy pyyaml mkl mkl-include typing 
WORKDIR /opt/pytorch
RUN git checkout tags/v1.4.0
RUN git submodule sync
RUN git submodule update --init --recursive
# RUN mkdir /opt/pytorch_installed
# ENV CMAKE_PREFIX_PATH /opt/pytorch_installed
ENV BUILD_TORCH ON 
# ENV FULL_CAFFE2 1
ENV BUILD_CAFFE2_OPS OFF
ENV BUILD_CAFFE2_MOBILE OFF
ENV MAX_JOBS 4
RUN python3 setup.py install 
WORKDIR /
# #need to make it own by myself and not by root because otherwise when we run python it will not access it
WORKDIR /
RUN git clone --recursive https://github.com/pytorch/vision /opt/vision
WORKDIR /opt/vision
# ENV CMAKE_PREFIX_PATH /opt/conda/envs/pt
RUN python3 setup.py install
WORKDIR /
# #torch c++ from https://github.com/pytorch/pytorch/blob/master/docs/libtorch.rst
# # WORKDIR /opt/pytorch
# # ENV BUILD_TORCH ON 
# # RUN tools/build_pytorch_libs.sh

#spconv for sparse convolutions in pytorch
# WORKDIR /
# RUN git clone --recursive https://github.com/traveller59/spconv.git /opt/spconv
# WORKDIR /opt/spconv
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends  libboost-all-dev
# RUN sudo apt-get update && sudo python3 -m pip install wheel
# RUN python3 setup.py bdist_wheel
# WORKDIR /opt/spconv/dist
# RUN sudo python3 -m pip install spconv-1.0-cp36-cp36m-linux_x86_64.whl
# WORKDIR /

#torch scatter in order to have scatter_max which is useful for a pointnet architecture
# RUN sudo python3 -m pip install torch-scatter


#python3 libs 
RUN sudo apt-get update && sudo apt-get -y install python3-pip python3-tk python3-pyqt5 python3-crypto python3-gnupg python3-dbg && sh "./cleanup.sh"
RUN sudo python3 -m pip install --upgrade pip
RUN sudo apt-get update && sudo python3 -m pip install ipdb numpy jupyter h5py scipy ipython pillow matplotlib opencv-python wheel trollius rospkg asyncio netifaces visdom torchnet sympy tqdm dlutils sklearn scikit-image twine natsort && sh "./cleanup.sh"
#Tensorflow and other stuff that I don't need at the moment
# RUN sudo apt-get update && sudo python3 -m pip install tensorflow==1.15 cython pycocotools && sh "./cleanup.sh"
#needed for tensorboard which required a higher version of setuptools
RUN sudo python3 -m pip install --upgrade setuptools setuptools-git  && sh "./cleanup.sh" 

#python2.7 libs
RUN sudo apt-get update && sudo apt-get install -y python-tk && sh "./cleanup.sh"
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends dvipng  python-tk && sh "./cleanup.sh"
RUN sudo apt-get update && sudo apt-get -y install python-pip && sh "./cleanup.sh"
RUN sudo apt-get update && python2 -m pip install pyyaml pathlib && sh "./cleanup.sh"

#to mount the bagserver 
RUN sudo apt-get update && sudo apt-get -y install cifs-utils && sh "./cleanup.sh"


#Things that are nice to have in order to run some applications
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libtbb-dev libglm-dev libkqueue-dev libpcap-dev network-manager net-tools meshlab ffmpeg libceres-dev && "./cleanup.sh"

#default python to 3.6
# RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2






# #default command to run when running the container 
ENTRYPOINT ./setup.sh &&  /bin/bash






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
RUN usermod -a -G audio ${user}
RUN usermod -a -G plugdev ${user}

#own some stuff because they were created by the root user in the docker container
# RUN chown -R ${user} /opt
# USER ${user}
# USER root

# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# Switch to the workspace
WORKDIR ${workspace}

# switch to interactive
ENV DEBIAN_FRONTEND teletype
