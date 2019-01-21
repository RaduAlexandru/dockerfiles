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


#python 3.6
ARG PYTHON_VERSION=3.6
RUN conda install -y python=$PYTHON_VERSION numpy && conda clean -ya

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



# #NVIDIA AND CUDNN  https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/devel-gpu.Dockerfile
# RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
#     curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
#     echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
#     echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
#     rm -rf /var/lib/apt/lists/*
# ENV CUDA_VERSION 10.0.130
# ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
# # For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         cuda-cudart-$CUDA_PKG_VERSION \
#         cuda-compat-10-0=410.48-1 && \
#     ln -s cuda-10.0 /usr/local/cuda && \
#     rm -rf /var/lib/apt/lists/*
# ENV PATH /usr/local/cuda/bin:${PATH}
# # nvidia-container-runtime
# ENV NVIDIA_VISIBLE_DEVICES all
# ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
# ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385"
# #more cuda stuff
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         build-essential \
#         cuda-command-line-tools-10-0 \
#         cuda-cublas-dev-10-0 \
#         cuda-cudart-dev-10-0 \
#         cuda-cufft-dev-10-0 \
#         cuda-curand-dev-10-0 \
#         cuda-cusolver-dev-10-0 \
#         cuda-cusparse-dev-10-0 \
#         libcudnn7=7.4.1.5-1+cuda10.0 \
#         libcudnn7-dev=7.4.1.5-1+cuda10.0 \
#         libcurl3-dev \
#         libfreetype6-dev \
#         libhdf5-serial-dev \
#         libzmq3-dev \
#         pkg-config \
#         # rsync \
#         software-properties-common \
#         # unzip \
#         # zip \
#         # zlib1g-dev \
#         # wget \
#         # git \
#         && \
#     find /usr/local/cuda-10.0/lib64/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete && \
#     rm /usr/lib/x86_64-linux-gnu/libcudnn_static_v7.a
# ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH



# #pytorch from https://github.com/anibali/docker-pytorch/blob/master/cuda-10.0/Dockerfile
# ARG PYTHON_VERSION=3.6
# RUN apt-get update && apt-get install -y --no-install-recommends build-essential cmake git curl vim ca-certificates libjpeg-dev libpng-dev && "./cleanup.sh"
# RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
#      chmod +x ~/miniconda.sh && \
#      ~/miniconda.sh -b -p /opt/conda && \
#      rm ~/miniconda.sh && \
#      /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include cython typing && \
#      /opt/conda/bin/conda install -y -c pytorch magma-cuda100 && \
#      /opt/conda/bin/conda install pytorch torchvision cuda100 -c pytorch && \
#      /opt/conda/bin/conda clean -ya
# ENV PATH /opt/conda/bin:$PATH

# #setup jupyter and everything you might ever need
# RUN conda  install -y numpy \
#     conda \
#     anaconda-client \
#     conda-build \
#     curl \
#     # greenlet \
#     # cython \
#     # fastcache \
#     # flask \
#     # graphviz \
#     h5py \
#     hdf5 \
#     # jinja2 \
#     # jpeg \
#     # jsonschema \
#     jupyter \
#     jupyter_client \
#     jupyter_console \
#     jupyter_core \
#     # libffi \
#     # libsodium \
#     # libpng \
#     # libtiff \
#     # libxml2 \
#     # libxslt \
#     # llvmlite \
#     # lxml \
#     matplotlib \
#     # mistune \
#     notebook \
#     # nltk \
#     # nose \
#     numba \
#     openblas \
#     pandas \
#     pep8 \
#     # pyqt \
#     # pycurl \
#     # pycosat \
#     # psutil \
#     # ptyprocess \
#     # redis \
#     # redis-py \
#     scikit-image \
#     scikit-learn \
#     scipy 
#     # simplegeneric \
#     # sip \
#     # sockjs-tornado \
#     # sqlite \
#     # sqlalchemy \
#     # tensorflow \
#     # werkzeug \
#     # unicodecsv \
#     # zeromq \
#     # zlib 
# # RUN conda update conda & conda update --all 
# RUN jupyter notebook --generate-config --allow-root
# RUN echo "c.NotebookApp.ip = '*'" >> ~/.jupyter/jupyter_notebook_config.py && \
#     echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py







# #python stuff
# RUN sudo apt-get update && sudo apt-get -y install python-pip python-tk python-numpy python-matplotlib python-yaml && sh "./cleanup.sh"
# RUN sudo apt-get update && sudo apt-get -y install python3-pip python3-tk && sh "./cleanup.sh"
# RUN sudo apt-get update && sudo python3 -m pip install h5py scipy ipython pillow matplotlib opencv-python keras && sh "./cleanup.sh"

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














#attempt 2 at installing pytorch and jupyter  
#conda install pytorch and jupyter








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
