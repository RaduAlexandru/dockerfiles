FROM ubuntu:xenial

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell


# Basic Utilities
RUN apt-get -y update && apt-get install -y zsh tree sudo ssh synaptic tmux git checkinstall cmake vim
RUN sudo apt-get install -y apt-transport-https

#Needed for the command add-apt-repository
RUN apt-get -y install software-properties-common python-software-properties

# Additional development tools
RUN apt-get install -y x11-apps python-pip build-essential


#GCC-6.0 CUDA AND TORCH don't work with a version higher than 5 https://github.com/torch/cutorch/issues/631
#RUN sudo add-apt-repository -y  ppa:ubuntu-toolchain-r/test
#RUN sudo apt -y  update
#RUN sudo apt install -y gcc-6 g++-6
#RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6


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

RUN sudo apt-get install -y meshlab
RUN sudo apt-get install -y htop

#Latex
RUN sudo apt-get update
RUN sudo apt-get install -y texlive-base
RUN sudo apt-get install -y latex-beamer
RUN sudo apt-get install -y texlive-latex-extra
RUN sudo apt-get install -y texlive-bibtex-extra biber
RUN sudo apt-get install -y texlive-xetex
RUN sudo apt-get install -y latexmk
RUN sudo apt-get install -y zathura
RUN sudo apt-get install -y imagemagick
RUN sudo apt-get install -y pdf-presenter-console
    # to solve this issue for pdf-presenter-console: https://github.com/davvil/pdfpc/issues/86 (seems that only the verision 1.0 is needed). Part of the solution is also here in the comment of robotrono: https://github.com/mopidy/mopidy-youtube/issues/47
    # sudo apt-get install gstreamer0.10  gstreamer0.10-plugins-base gstreamer0.10-plugins-good  gstreamer1.0
RUN sudo apt-get install -y gstreamer1.0


#Atom
RUN sudo apt-get install -y apt-transport-https
RUN curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
RUN sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
RUN sudo apt-get update
RUN sudo apt-get install -y atom

#nativefiledialog reuires it https://github.com/mlabbe/nativefiledialog
RUN sudo apt-get install -y libgtk-3-dev




#-------------------------------------------------------------------------------
#NVIDIA stuff copied from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/devel/Dockerfile

# RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
#     NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
#     apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
#     apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
#     echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
#     echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list
#
# ENV CUDA_VERSION 8.0.61
#
# ENV CUDA_PKG_VERSION 8-0=$CUDA_VERSION-1
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         cuda-core-$CUDA_PKG_VERSION \
#         cuda-misc-headers-$CUDA_PKG_VERSION \
#         cuda-command-line-tools-$CUDA_PKG_VERSION \
#         cuda-nvrtc-dev-$CUDA_PKG_VERSION \
#         cuda-nvml-dev-$CUDA_PKG_VERSION \
#         cuda-nvgraph-dev-$CUDA_PKG_VERSION \
#         cuda-cusolver-dev-$CUDA_PKG_VERSION \
#         cuda-cublas-dev-8-0=8.0.61.2-1 \
#         cuda-cufft-dev-$CUDA_PKG_VERSION \
#         cuda-curand-dev-$CUDA_PKG_VERSION \
#         cuda-cusparse-dev-$CUDA_PKG_VERSION \
#         cuda-npp-dev-$CUDA_PKG_VERSION \
#         cuda-cudart-dev-$CUDA_PKG_VERSION \
#         cuda-driver-dev-$CUDA_PKG_VERSION && \
#     ln -s cuda-8.0 /usr/local/cuda && \
#     rm -rf /var/lib/apt/lists/*
#
#
# RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
#     echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
#
# ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
# ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
#
#
# #CUDANN copied from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/cudnn7/Dockerfile
# RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list
# RUN sudo apt-get update
# ENV CUDNN_VERSION 7.0.5.15
# RUN apt-get update && apt-get install -y --no-install-recommends \
#             libcudnn7=$CUDNN_VERSION-1+cuda8.0 && \
#     rm -rf /var/lib/apt/lists/*
#
# # nvidia-container-runtime
# ENV NVIDIA_VISIBLE_DEVICES all
# ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
# ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"
#
#
#
# #TORCH
# #If you use CUDA 9.1 we need to avoid https://github.com/torch/cutorch/issues/797 so uncomment the following line
# #ENV TORCH_NVCC_FLAGS="-D__CUDA_NO_HALF_OPERATORS__"
# RUN git clone https://github.com/torch/distro.git /torch --recursive
# RUN bash /torch/install-deps
# RUN cd torch && ./install.sh
# RUN /torch/install/bin/luarocks install torch
# RUN /torch/install/bin/luarocks install cutorch
# RUN /torch/install/bin/luarocks install nn
# RUN /torch/install/bin/luarocks install cunn
# RUN /torch/install/bin/luarocks install cudnn
# RUN /torch/install/bin/luarocks install visdom
# RUN /torch/install/bin/luarocks install luaposix
#
# # Export environment variables manually
# ENV LUA_PATH='/.luarocks/share/lua/5.1/?.lua;/.luarocks/share/lua/5.1/?/init.lua;/torch/install/share/lua/5.1/?.lua;/torch/install/share/lua/5.1/?/init.lua;./?.lua;/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
# ENV LUA_CPATH='/.luarocks/lib/lua/5.1/?.so;/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
# ENV PATH=/torch/install/bin:$PATH
# ENV LD_LIBRARY_PATH=/torch/install/lib:$LD_LIBRARY_PATH
# ENV DYLD_LIBRARY_PATH=/torch/install/lib:$DYLD_LIBRARY_PATH
# ENV LUA_CPATH='/torch/install/lib/?.so;'$LUA_CPATH

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
