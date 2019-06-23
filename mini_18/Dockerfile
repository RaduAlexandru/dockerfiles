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

# #copy the cleanup script so that its accesible in docker https://stackoverflow.com/a/53167819
COPY cleanup.sh ./
RUN chmod +x ./cleanup.sh

# Basic Utilities (dirmngr and gpg-agent is needed so that apt-get adv works)
RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh tmux git meld cmake cmake-curses-gui htop vim iputils-ping apt-utils apt-transport-https software-properties-common wget build-essential gdb valgrind silversearcher-ag curl dirmngr gpg-agent checkinstall && sh "./cleanup.sh"

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config


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
# RUN sudo apt-get purge cmake
RUN sudo dpkg -r --force-depends cmake cmake-curses-gui  
WORKDIR /
RUN wget http://www.cmake.org/files/v3.14/cmake-3.14.0.tar.gz 
RUN tar -xvzf cmake-3.14.0.tar.gz 
WORKDIR cmake-3.14.0/ 
RUN ./configure
RUN make -j4
RUN sudo checkinstall -D -y --pkgname=cmake --pkgversion=3.14
WORKDIR /
RUN rm cmake-3.14.0.tar.gz && rm -rf cmake-3.14.0


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

#Latex
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends texlive-base texlive-latex-extra texlive-latex-recommended texlive-science texlive-pictures texlive-fonts-recommended texlive-luatex imagemagick texstudio && sh "./cleanup.sh"
#for solving https://ubuntuforums.org/showthread.php?t=945365
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends lmodern && sh "./cleanup.sh" 
#Fuck it, just install everything related to latex
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends texlive-full  && sh "./cleanup.sh" 
#pdfpc
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends pdf-presenter-console  && sh "./cleanup.sh" 
#in order to make pdfpc and libreoffice play videos 
RUN sudo apt-get update && sudo apt-get install -y gstreamer1.0-plugins-*  && sh "./cleanup.sh" 
# RUN sudo apt-get update && sudo apt-get install -y gstreamer1.0-python3-plugin-loader   gstreamer0.10 gstreamer1.0 && sh "./cleanup.sh"
# RUN sudo apt-get update && sudo apt-get install -y gstreamer1.0-* && sh "./cleanup.sh"
RUN sudo apt-get update && sudo apt-get install -y cmake valac libgee-0.8-dev libpoppler-glib-dev libgtk-3-dev libgstreamer1.0-dev libgstreamer-plugins-bad1.0-dev && sh "./cleanup.sh" 
# RUN sudo apt-get update && sudo apt-get install -y gstreamer-1.0 && sh "./cleanup.sh" 
# RUN sudo apt-get update && sudo apt-get install -y gstreamer1.0-* && sh "./cleanup.sh" 
RUN sudo apt-get update && sudo  DEBIAN_FRONTEND=noninteractive  apt install -y ubuntu-restricted-extras && sh "./cleanup.sh" 
RUN sudo apt-get update && sudo apt-get install -y cmake valac libgee-0.8-dev libpoppler-glib-dev libgtk-3-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-gtk3 && sh "./cleanup.sh" 
# INSTALL NOW PDFPC FROM THE GITHUB REPO AND DO ALSO A MAKE INSTALL!!

#pdfpc
WORKDIR /
RUN wget https://github.com/pdfpc/pdfpc/archive/v4.3.2.tar.gz
RUN tar -xvzf v4.3.2.tar.gz 
WORKDIR pdfpc-4.3.2/ 
RUN mkdir build 
WORKDIR build
RUN cmake ..
RUN make
RUN sudo checkinstall -D -y --pkgname=pdfpc --pkgversion=4.3.2
WORKDIR /
RUN rm v4.3.2.tar.gz && rm -rf pdfpc-4.3.2/


#nativefiledialog reuires it https://github.com/mlabbe/nativefiledialog
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libgtk-3-dev && sh "./cleanup.sh"

#clang and llvm as a depenency of halide
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends llvm-6.0-dev && sh "./cleanup.sh"

#Halide requires also Eigen but there is an issue when compiling cuda10 and eigen, solution is to upgrade eigen https://github.com/tensorflow/tensorflow/issues/15389
RUN wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.3.7-1_all.deb
RUN sudo dpkg -i libeigen3-dev_3.3.7-1_all.deb

#ranger 
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends ranger caca-utils highlight atool w3m poppler-utils mediainfo && "./cleanup.sh"



# NVIDIA driver
RUN sudo add-apt-repository -y ppa:graphics-drivers/ppa
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends  nvidia-driver-410=410.104-0ubuntu0~18.04.1    && sh "./cleanup.sh"


#cuda from https://gitlab.com/nvidia/cuda/tree/ubuntu18.04/10.0/devel/cudnn7 and all the directories the it ha above the hierachy
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
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
            # cuda-nvprof-$CUDA_PKG_VERSION \
            # cuda-nvvp-$CUDA_PKG_VERSION \
            cuda-visual-tools-$CUDA_PKG_VERSION \
            # libnccl-dev=$NCCL_VERSION-1+cuda10.0 \
            #devel/cudnn
            libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
            libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0 && \
    ln -s cuda-10.0 /usr/local/cuda && \
    apt-mark hold libcudnn7 && \
    # apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*
ENV PATH /usr/local/cuda/bin:${PATH}
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/cuda-10.0/compat:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}


#nvvp crashes under the default java11 so we need java8 as explained here https://bugs.launchpad.net/ubuntu/+source/nvidia-cuda-toolkit/+bug/1766948
RUN sudo apt-get install  -y --no-install-recommends  openjdk-8-jre && sh "./cleanup.sh"
RUN sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

#pytorch
# RUN conda config --env --add channels pytorch
# RUN conda install -n pt numpy pyyaml mkl mkl-include setuptools cmake cffi typing magma-cuda100 && conda clean -ya 
# ENV PATH /opt/conda/envs/pt/bin:$PATH
WORKDIR /
RUN git clone --recursive https://github.com/pytorch/pytorch /opt/pytorch
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends python3-pip python3-setuptools && sh "./cleanup.sh"
RUN pip3 install numpy pyyaml mkl mkl-include typing 
WORKDIR /opt/pytorch
# RUN mkdir /opt/pytorch_installed
# ENV CMAKE_PREFIX_PATH /opt/pytorch_installed
ENV BUILD_TORCH ON 
ENV FULL_CAFFE2 1
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
WORKDIR /
RUN git clone --recursive https://github.com/traveller59/spconv.git /opt/spconv
WORKDIR /opt/spconv
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends  libboost-all-dev
RUN sudo apt-get update && sudo python3 -m pip install wheel
RUN python3 setup.py bdist_wheel
WORKDIR /opt/spconv/dist
RUN sudo python3 -m pip install spconv-1.0-cp36-cp36m-linux_x86_64.whl
WORKDIR /

#torch scatter in order to have scatter_max which is useful for a pointnet architecture
RUN sudo python3 -m pip install torch-scatter


#blender
RUN sudo add-apt-repository -y ppa:thomas-schiex/blender
RUN sudo apt-get update
RUN sudo apt-get install -y blender

#lightworks for video editing (FOR SOME REASON IT DOESNT WORK IN DOCKER)
# RUN wget https://downloads.lwks.com/v14-5/lightworks-14.5.0-amd64.deb && sudo apt -f -y install && sudo dpkg -i lightworks-14.5.0-amd64.deb && rm lightworks-14.5.0-amd64.deb "./cleanup.sh"

#kdenlive for video edition 
RUN sudo add-apt-repository -y ppa:kdenlive/kdenlive-stable
RUN sudo apt-get update
RUN sudo apt-get install -y kdenlive dbus-x11

#python3 libs 
RUN sudo apt-get update && sudo apt-get -y install python3-pip python3-tk && sh "./cleanup.sh"
RUN sudo apt-get update && sudo python3 -m pip install ipdb numpy jupyter h5py scipy ipython pillow matplotlib opencv-python wheel trollius rospkg asyncio netifaces visdom torchnet sympy && sh "./cleanup.sh"

#python2.7 libs
RUN sudo apt-get update && sudo apt-get install -y python-tk && sh "./cleanup.sh"
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends dvipng  python-tk && sh "./cleanup.sh"
RUN sudo apt-get update && sudo apt-get -y install python-pip && sh "./cleanup.sh"
RUN pip2 install pyyaml pathlib

#to mount the bagserver 
RUN sudo apt-get update && sudo apt-get -y install cifs-utils && sh "./cleanup.sh"


#Things that are nice to have in order to run some applications
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libtbb-dev libglm-dev libkqueue-dev libpcap-dev network-manager net-tools meshlab ffmpeg libceres-dev && "./cleanup.sh"

#default python to 3.6
# RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2









# #python libs
# RUN conda install -n pt  matplotlib pyyaml scikit-image && conda clean -ya

# #python libs for python 2.7 because there are some sripts out there that only work with 2.7
# RUN conda create -n py27 python=2.7 numpy tk matplotlib pyyaml qt pyqt && conda clean -ya
# #dvipng is sometimes needed by matplotlib but somehow it is not mentioned as dependency and some plotting may fail because of that
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends dvipng && sh "./cleanup.sh" 



# ###   BUG FIXES   ################################3
# # need to downgrade fontconfig from 2.13 to 2.12 because with 2.13 I get a linking error of /opt/conda/envs/pt/lib/libfontconfig.so.1: undefined reference to `FT_Done_MM_Var'
# RUN conda install -n pt fontconfig=2.12 && conda clean -ya 



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
