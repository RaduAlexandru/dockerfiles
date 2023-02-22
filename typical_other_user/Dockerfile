# FROM ubuntu:bionic

# FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu18.04

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

#solves an issue with some weird nvidia repo error https://github.com/NVIDIA/nvidia-docker/issues/1632
#RUN rm /etc/apt/sources.list.d/cuda.list
#RUN rm /etc/apt/sources.list.d/nvidia-ml.list
#solve another issue with cuda repos https://forums.developer.nvidia.com/t/invalid-public-key-for-cuda-apt-repository/212901/13
#RUN sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
#RUN sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

# Basic Utilities (dirmngr and gpg-agent is needed so that apt-get adv works)
RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh tmux git meld cmake cmake-curses-gui htop vim iputils-ping apt-utils apt-transport-https software-properties-common wget build-essential gdb valgrind silversearcher-ag curl dirmngr gpg-agent checkinstall locate baobab ninja-build libncurses5-dev gimp pkg-config && sh "./cleanup.sh"

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


#CONDA FUCKS UP WITH SO MANY SYSTEM LIBRARIESSS
# #conda
# RUN apt-get -y update && apt-get install -y --no-install-recommends curl && sh "./cleanup.sh"
# RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
#      chmod +x ~/miniconda.sh && \
#      ~/miniconda.sh -b -p /opt/conda && \
#      rm ~/miniconda.sh && "./cleanup.sh"
# ENV PATH /opt/conda/bin:$PATH

# #python
# ARG PYTHON_VERSION=3.6
# RUN conda create -n pt python=${PYTHON_VERSION} numpy jupyter && conda clean -ya
# #They cause conflicts with the library installed in the system
# RUN rm /opt/conda/envs/pt/lib/libfontconfig.so.1 /opt/conda/envs/pt/lib/libfontconfig.so /opt/conda/envs/pt/lib/libfontconfig.so.1.11.1


#things like spconv require cmake >3.13 https://github.com/traveller59/spconv
# RUN sudo dpkg -r --force-depends cmake cmake-curses-gui
# WORKDIR /
# RUN wget http://www.cmake.org/files/v3.14/cmake-3.14.0.tar.gz
# RUN tar -xvzf cmake-3.14.0.tar.gz
# WORKDIR cmake-3.14.0/
# RUN ./configure
# RUN make -j4
# RUN sudo checkinstall -D -y --pkgname=cmake --pkgversion=3.14
# WORKDIR /
# RUN rm cmake-3.14.0.tar.gz && rm -rf cmake-3.14.0


#copy the cleanup script
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh

#things for Instant Neural Primitives https://github.com/NVlabs/instant-ngp----------------------------------------------------------------
#also needed cmake 3.13 and above for pytorch
#CMAKE above 3.19  https://askubuntu.com/a/8652941
# https://gitlab.kitware.com/cmake/cmake/-/issues/22245
# RUN sudo apt-get update
# RUN sudo apt-get install software-properties-common wget
# RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
# RUN sudo apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
# RUN sudo apt update
# RUN sudo apt install -y cmake


#python at least 3.7 is needed to compile pytorch 
RUN sudo add-apt-repository ppa:deadsnakes/ppa
RUN sudo apt install -y python3.8
#switch to python3  https://linuxconfig.org/how-to-change-from-default-to-alternative-python-version-on-debian-linux
#this is needed so that catkin uses python3 and therefore pybind uses python3 which is the only one that can use spconv..
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python3.8-dev && sh "./cleanup.sh"
#install pip 
# https://stackoverflow.com/a/56140616
RUN sudo apt-get update && sudo apt install -y python3-pip
RUN python3.8 -m pip install pip
RUN sudo python3.8 -m pip install -U pip
#install packages
RUN sudo python3.8 -m pip install setuptools
# CANNOT DO THIS HERE because that will change python3 to be python3.8 and python3.8 cannot run add-apt-repository because it's missing apt-kg
# RUN sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2 





#Halide requires also Eigen but there is an issue when compiling cuda10 and eigen, solution is to upgrade eigen https://github.com/tensorflow/tensorflow/issues/15389
# COPY data/libeigen3-dev_3.3.7-3_all.deb ./
# RUN wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.3.7-1_all.deb
# RUN sudo dpkg -i libeigen3-dev_3.3.7-3_all.deb
#update to eigen 3.4 https://ubuntu.pkgs.org/22.04/ubuntu-universe-amd64/libeigen3-dev_3.4.0-2ubuntu2_all.deb.html
COPY data/libeigen3-dev_3.4.0-2ubuntu2_all.deb ./
RUN sudo dpkg -i libeigen3-dev_3.4.0-2ubuntu2_all.deb





#GRAPHICS STUFF
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libglfw3-dev && sh "./cleanup.sh"
RUN sudo apt-get update && sudo apt-get install -y cmake && sh "./cleanup.sh"


# Install Miniconda and Python 3.8
# ENV CONDA_AUTO_UPDATE_CONDA=false
# ENV PATH=/home/user/miniconda/bin:$PATH
# RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py38_4.8.2-Linux-x86_64.sh \
#  && chmod +x ~/miniconda.sh \
#  && ~/miniconda.sh -b -p ~/miniconda \
#  && rm ~/miniconda.sh \
#  && conda install -y python==3.8.1 \
#  && conda clean -ya

# install conda https://stackoverflow.com/a/73575335
# COPY --from=continuumio/miniconda3:4.12.0 /opt/conda /opt/conda
# ENV PATH=/opt/conda/bin:$PATH
# RUN set -ex && \
#     conda config --set always_yes yes --set changeps1 no && \
#     conda info -a && \
#     conda config --add channels conda-forge && \
#     conda install --quiet --freeze-installed -c main conda-pack

# # pytorch this has to be after we update the  pythion
# # RUN conda install --quiet pytorch torchvision torchaudio pytorch-cuda=11.7 -c pytorch -c nvidia

# RUN python --version

# # https://github.com/anibali/docker-pytorch/blob/master/dockerfiles/1.5.0-cuda10.2-ubuntu18.04/Dockerfile
# RUN conda install -y -c pytorch \
#     cudatoolkit=11.7 \
#     "pytorch=1.13.0=py3.9_cuda11.7_cudnn8.5.0_0" \
#     "torchvision=0.14.0=py39_cu117" \
#  && conda clean -ya



#####PYTORCH WITH PIP
RUN sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2 
RUN python --version
RUN python3 -m pip install torch torchvision torchaudio






#python3 libs
# RUN sudo apt-get update && sudo apt-get -y install python3.8-pip python3.8-tk python3.8-pyqt5 python3.8-crypto python3.8-gnupg python3.8-dbg && sh "./cleanup.sh"
# RUN sudo apt-get update && sudo python3.8 -m pip install numpy  && sh "./cleanup.sh"
#Tensorflow and other stuff that I don't need at the moment
# RUN sudo apt-get update && sudo python3 -m pip install tensorflow==1.15 cython pycocotools && sh "./cleanup.sh"
#needed for tensorboard which required a higher version of setuptools
# RUN sudo python3.8 -m pip install --upgrade setuptools setuptools-git  && sh "./cleanup.sh"
#we need to downgrade it because tensorboard has an issue with newer versions https://exerror.com/attributeerror-module-setuptools-_distutils-has-no-attribute-version/





#THIS HAS TO BE THE LAST thing after we instal things 
#if you ever need to do add-reposityo you need you change alternative back to python3.6
RUN sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2 



# #default command to run when running the container
# ENTRYPOINT ./setup.sh &&  /bin/bash






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
# VOLUME "/opt/intel"

WORKDIR ${workspace}

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

RUN pwd
# RUN ls ${user} 
RUN ls ${workspace} 
RUN chown -R ${user} ${workspace}
# RUN echo ${workspace}
USER "${user}"



# # Switch to user
# USER "${user}"
# # This is required for sharing Xauthority
# ENV QT_X11_NO_MITSHM=1
# # ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# # Switch to the workspace
# WORKDIR ${workspace}


# switch to interactive
ENV DEBIAN_FRONTEND teletype
