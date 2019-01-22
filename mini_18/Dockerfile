FROM ubuntu:bionic
# FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# switch to non interactive https://github.com/phusion/baseimage-docker/issues/319
ENV DEBIAN_FRONTEND noninteractive

#copy the cleanup script so that its accesible in docker https://stackoverflow.com/a/53167819
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh
RUN sh "./cleanup.sh"

# Basic Utilities
RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh tmux git meld cmake cmake-curses-gui htop vim iputils-ping apt-utils apt-transport-https software-properties-common wget build-essential gdb curl && sh "./cleanup.sh"

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config


#-------------------------------------------------------------------------------
# NVIDIA driver
RUN sudo add-apt-repository -y ppa:graphics-drivers/ppa
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nvidia-driver-410=410.78-0ubuntu1~gpu18.04.1  && sh "./cleanup.sh"


#cuda from https://gitlab.com/nvidia/cuda/tree/ubuntu18.04/10.0/devel/cudnn7 and all the directories the it ha above the hierachy
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*
ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
ENV CUDNN_VERSION 7.4.1.5
RUN apt-get update && apt-get install -y --no-install-recommends \
            #base
            cuda-cudart-$CUDA_PKG_VERSION \
            cuda-compat-10-0=410.48-1 \
            #runtime 
            cuda-libraries-$CUDA_PKG_VERSION \
            cuda-nvtx-$CUDA_PKG_VERSION \
            # libnccl2=$NCCL_VERSION-1+cuda10.0 \
            #devel
            cuda-libraries-dev-$CUDA_PKG_VERSION \
            cuda-nvml-dev-$CUDA_PKG_VERSION \
            cuda-minimal-build-$CUDA_PKG_VERSION \
            cuda-command-line-tools-$CUDA_PKG_VERSION \
            # libnccl-dev=$NCCL_VERSION-1+cuda10.0 \
            #devel/cudnn
            libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
            libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0 && \
    ln -s cuda-10.0 /usr/local/cuda && \
    apt-mark hold libcudnn7 && \
    # apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*
ENV PATH /usr/local/cuda/bin:${PATH}



#conda
RUN apt-get -y update && apt-get install -y --no-install-recommends curl && sh "./cleanup.sh"
RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && "./cleanup.sh"
ENV PATH /opt/conda/bin:$PATH


#pytorch (it comes by default with cuda90 but it's fine since it automatically pulls the dependency and installs it)
ARG PYTHON_VERSION=3.6
RUN conda create -n pt python=${PYTHON_VERSION} numpy mkl mkl-include jupyter pytorch torchvision && conda clean -ya
# RUN echo "source activate pt" > ~/.bashrc 
# ENV PATH /opt/conda/envs/pt/bin:$PATH
# RUN /bin/bash -c "source activate pt"

#ROS
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ros-melodic-desktop-full && "./cleanup.sh"
RUN sudo rosdep init
RUN rosdep update
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python-catkin-tools && sh "./cleanup.sh"

#GRAPHICS STUFF
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libglfw3-dev && sh "./cleanup.sh"

#Latex
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends texlive-base texlive-latex-extra texlive-latex-recommended texlive-science texlive-pictures texlive-fonts-recommended texlive-luatex imagemagick texstudio && sh "./cleanup.sh"

#nativefiledialog reuires it https://github.com/mlabbe/nativefiledialog
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libgtk-3-dev && sh "./cleanup.sh"

#clang and llvm as a depenency of halide
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends llvm-6.0-dev && sh "./cleanup.sh"

#Halide requires a newer version of Eigen 
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libeigen3-dev && sh "./cleanup.sh"



#ranger 
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends ranger caca-utils highlight atool w3m poppler-utils mediainfo && "./cleanup.sh"

#Things that are nice to have in order to run some applications
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libtbb-dev libglm-dev libkqueue-dev libpcap-dev network-manager net-tools && "./cleanup.sh"

#python libs
# sudo apt-get install python3-tk
RUN conda install -n pt  matplotlib  && conda clean -ya
# RUN echo "source activate pt" > ~/.bashrc 
# ENV PATH /opt/conda/envs/pt/bin:$PATH
# RUN /bin/bash -c "source activate pt"


#default command to run when running the container (activate the conda environment so if we run jupyter it all works and runs off the correct python version)
# CMD [".", "activate pt"] 
# CMD ["source", "activate", "pt"] 
# RUN echo "source activate pt" > ~/.bashrc 
# CMD source activate pt && /bin/bash && source activate pt
# CMD /bin/bash -c "source ~/.bashrc" && /bin/bash
# ENTRYPOINT source activate pt && /bin/bash "use && to separate your code"
ENTRYPOINT echo "source activate pt" >> ~/.bashrc && /bin/bash






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
RUN usermod -a -G plugdev ${user}



# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# Switch to the workspace
WORKDIR ${workspace}

# switch to interactive
ENV DEBIAN_FRONTEND teletype
