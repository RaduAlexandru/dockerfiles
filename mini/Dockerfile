FROM ubuntu:xenial

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
RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh tmux git meld cmake vim iputils-ping apt-utils apt-transport-https software-properties-common python-software-properties python-pip wget && sh "./cleanup.sh"


# HACK around https://github.com/dotcloud/docker/issues/5490
# RUN apt-get -y update && apt-get install -y tcpdump --fix-missing && sh "./cleanup.sh"
# RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump
# RUN mv /sbin/dhclient  /usr/sbin/dhclient

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config


#-------------------------------------------------------------------------------

#ROS
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN apt-get -y update && sudo apt-get install -y --no-install-recommends ros-kinetic-ros-base ros-kinetic-geometry ros-kinetic-image-common ros-kinetic-image-pipeline  ros-kinetic-image-transport-plugins ros-kinetic-perception-pcl ros-kinetic-vision-opencv ros-kinetic-rviz && sh "./cleanup.sh"
#packages are here  http://www.ros.org/reps/rep-0142.html
RUN sudo rosdep init
RUN rosdep update
# RUN sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
RUN sudo pip install catkin_tools && sh "./cleanup.sh"

#GRAPHICS STUFF
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libglfw3-dev && sh "./cleanup.sh"

#GDB
RUN sudo apt-get update && sudo apt-get install -y gdb && sh "./cleanup.sh"

#Latex
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends texlive-base latex-beamer texlive-science imagemagick && sh "./cleanup.sh"

#nativefiledialog reuires it https://github.com/mlabbe/nativefiledialog
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libgtk-3-dev && sh "./cleanup.sh"


#clang and llvm as a depenency of halide https://blog.kowalczyk.info/article/k/how-to-install-latest-clang-5.0-on-ubuntu-16.04-xenial-wsl.html
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
RUN sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main"
RUN sudo apt-get update && sudo apt-get install -y clang-5.0 && sh "./cleanup.sh"
RUN ln -sf /usr/bin/clang-5.0 /usr/bin/clang
RUN ln -sf /usr/bin/llvm-config-5.0 /usr/bin/llvm-config
RUN ln -sf /usr/lib/x86_64-linux-gnu/libclang-5.0.so.1 /usr/lib/libclang.so # for https://github.com/arakashic/chromatica.nvim

#Halide requires a newer version of Eigen than the one present in Ubuntu 16.04 so we grab the one from Bionic Beaver
RUN wget http://mirrors.kernel.org/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.3.4-4_all.deb
RUN sudo dpkg -i libeigen3-dev_3.3.4-4_all.deb

# NVIDIA driver
RUN sudo add-apt-repository -y ppa:graphics-drivers/ppa
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nvidia-390=390.87-0ubuntu0~gpu16.04.1 && sh "./cleanup.sh"

#visual_studio_code
RUN wget https://vscode-update.azurewebsites.net/1.28.2/linux-deb-x64/stable
RUN mv stable code
RUN sudo apt-get update && sudo apt-get install -y libgconf-2-4 libsecret-1-0 libnss3 && sh "./cleanup.sh"
RUN sudo dpkg -i code

#NVIDIA CUDA stuff copied from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/9.0/base/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates apt-transport-https gnupg-curl && \
    rm -rf /var/lib/apt/lists/* && \
    NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list
ENV CUDA_VERSION 9.0.176
ENV CUDA_PKG_VERSION 9-0=$CUDA_VERSION-1
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-core-$CUDA_PKG_VERSION \
        cuda-misc-headers-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
        cuda-nvrtc-dev-$CUDA_PKG_VERSION \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-nvgraph-dev-$CUDA_PKG_VERSION \
        cuda-cusolver-dev-$CUDA_PKG_VERSION \
        cuda-cublas-dev-9-0=9.0.176.4-1 \
        cuda-cufft-dev-$CUDA_PKG_VERSION \
        cuda-curand-dev-$CUDA_PKG_VERSION \
        cuda-cusparse-dev-$CUDA_PKG_VERSION \
        cuda-npp-dev-$CUDA_PKG_VERSION \
        cuda-cudart-dev-$CUDA_PKG_VERSION \
        cuda-driver-dev-$CUDA_PKG_VERSION && \
    ln -s cuda-9.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* && \
    sh "./cleanup.sh"
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH "/usr/local/nvidia/lib:/usr/local/nvidia/lib64:$LD_LIBRARY_PATH"
#in order for tensorflow to find libcuda.so.1 https://github.com/tensorflow/tensorflow/issues/10776
# RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
# ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH"
# RUN LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH python3 setup.py install
# RUN rm /usr/local/cuda/lib64/stubs/libcuda.so.1
RUN sudo apt-get update&& sudo apt-get install -y libcuda1-390=390.87-0ubuntu0~gpu16.04.1 && sh "./cleanup.sh"
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH"


#CUDANN copied from https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/cudnn7/Dockerfile
RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list
ENV CUDNN_VERSION 7.3.1.20
RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda9.0 && \
    rm -rf /var/lib/apt/lists/* && \
    sh "./cleanup.sh"
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

#Tensorflow
RUN sudo apt-get update && sudo apt-get install -y \
        python3-dev python3-pip \
        && sh "./cleanup.sh"
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade tensorflow-gpu && sh "./cleanup.sh"

#python stuff
RUN sudo apt-get update && sudo apt-get -y install python3-pip python3-tk && sh "./cleanup.sh"
RUN sudo apt-get update && sudo python3 -m pip install h5py scipy ipython pillow matplotlib opencv-python keras && sh "./cleanup.sh"

# #Bunch of python things
# RUN pip --no-cache-dir install \
#         Pillow \
#         h5py \
#         ipykernel \
#         jupyter \
#         keras_applications \
#         keras_preprocessing \
#         matplotlib \
#         numpy \
#         pandas \
#         scipy \
#         sklearn \
#         && \
#         python -m ipykernel.kernelspec

# #cuda agin
# wget https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb
# sudo dpkg -i cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb
# sudo apt-key add /var/cuda-repo-9-0-local/7fa2af80.pub
# https://gist.github.com/zhanwenchen/e520767a409325d9961072f666815bb8
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#runfile-advanced
#
#
# ########
# Again with nvidia docker2 https://github.com/nvidia/nvidia-docker/wiki/Installation-(version-2.0)
# ON HOST
#     curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
#     sudo apt-key add -
#
#     distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
#
#     curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
#     sudo tee /etc/apt/sources.list.d/nvidia-docker.list
#
#     sudo apt-get update










#·-------------------------------------------------------------------------------

#Cleanup
RUN sudo rm -rf /var/lib/apt/lists/*
RUN sudo apt-get update

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
