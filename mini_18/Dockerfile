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
RUN sudo apt-get update
RUN sudo apt-get install software-properties-common wget
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN sudo apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
RUN sudo apt update
RUN sudo apt install -y cmake


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
#CANNOT DO THIS HERE because that will change python3 to be python3.8 and python3.8 cannot run add-apt-repository because it's missing apt-kg
# RUN sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2 

#now that python3 is actually python3.8 we need to also instal somehow python3-apt. We link to the ine from python3 the default version
#https://stackoverflow.com/a/36232975
# WORKDIR /usr/lib/python3/dist-packages
# RUN cp apt_pkg.cpython-36m-x86_64-linux-gnu.so apt_pkg.so
#more things that are missing from python3.8 https://stackoverflow.com/a/60352723
# RUN sudo python3.8 -m pip install pgi
# RUN sudo python3.8 -m pip install --ignore-installed PyGObject






#Halide requires also Eigen but there is an issue when compiling cuda10 and eigen, solution is to upgrade eigen https://github.com/tensorflow/tensorflow/issues/15389
# COPY data/libeigen3-dev_3.3.7-3_all.deb ./
# RUN wget http://mirrors.edge.kernel.org/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.3.7-1_all.deb
# RUN sudo dpkg -i libeigen3-dev_3.3.7-3_all.deb
#update to eigen 3.4 https://ubuntu.pkgs.org/22.04/ubuntu-universe-amd64/libeigen3-dev_3.4.0-2ubuntu2_all.deb.html
COPY data/libeigen3-dev_3.4.0-2ubuntu2_all.deb ./
RUN sudo dpkg -i libeigen3-dev_3.4.0-2ubuntu2_all.deb




#ROS and install also catkin for python3
RUN sudo add-apt-repository main
RUN sudo add-apt-repository universe
RUN sudo add-apt-repository multiverse
RUN sudo add-apt-repository restricted
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
# RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
# RUN sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ros-melodic-desktop-full && sh "./cleanup.sh"
RUN sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ros-melodic-nmea-msgs && sh "./cleanup.sh"
RUN sudo python3.8 -m pip install catkin-tools rosdep
RUN sudo python3.8 -m pip install wstool
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
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends texlive-full imagemagick texstudio  && sh "./cleanup.sh"
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
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends clang-8 llvm-8-dev libclang-8-dev && sh "./cleanup.sh"



#ranger
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends ranger caca-utils highlight atool w3m poppler-utils mediainfo && "./cleanup.sh"


#nvvp crashes under the default java11 so we need java8 as explained here https://bugs.launchpad.net/ubuntu/+source/nvidia-cuda-toolkit/+bug/1766948
RUN sudo apt-get update && sudo apt-get install  -y --no-install-recommends  openjdk-8-jre && sh "./cleanup.sh"
RUN sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
# RUN sudo apt-get update && apt-get install -y --no-install-recommends cuda-command-line-tools-$CUDA_PKG_VERSION cuda-visual-tools-$CUDA_PKG_VERSION && sh "./cleanup.sh"
# RUN sudo apt-cache search cuda-command-line-tool
# RUN sudo apt-cache search cuda-visual-tools
#RUN sudo apt-get update && apt-get install -y --no-install-recommends cuda-command-line-tools-11-1 cuda-visual-tools-11-1 && sh "./cleanup.sh"

#pytorch
# RUN conda config --env --add channels pytorch
# RUN conda install -n pt numpy pyyaml mkl mkl-include setuptools cmake cffi typing magma-cuda100 && conda clean -ya
# ENV PATH /opt/conda/envs/pt/bin:$PATH
WORKDIR /
# RUN GIT_TRACE=1 GIT_CURL_VERBOSE=1 git clone --verbose --recursive https://github.com/pytorch/pytorch /opt/pytorch
# RUN git clone --verbose --recursive git@github.com:pytorch/pytorch.git /opt/pytorch
#RUN git clone --verbose --recursive https://github.com/pytorch/pytorch  /opt/pytorch
RUN git clone --verbose https://github.com/pytorch/pytorch  /opt/pytorch
RUN sudo python3.8 -m pip install numpy pyyaml mkl mkl-include typing dataclasses typing-extensions
WORKDIR /opt/pytorch
RUN git checkout tags/v1.12.1
RUN git submodule sync
RUN git submodule update --init --recursive
# RUN mkdir /opt/pytorch_installed
# ENV CMAKE_PREFIX_PATH /opt/pytorch_installed
ENV BUILD_TORCH ON
# ENV FULL_CAFFE2 1
ENV BUILD_CAFFE2_OPS OFF
ENV BUILD_CAFFE2_MOBILE OFF
ENV MAX_JOBS 4
######The 8.0 is for ampere but we leave up until 7.5 because I am using the 2060
RUN MAX_JOBS=8 USE_NINJA=1 BUILD_TEST=0 BUILD_JNI=0 USE_CUDNN=1 TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX" python3.8 setup.py install
#RUN MAX_JOBS=8 USE_NINJA=1 BUILD_TEST=0 BUILD_JNI=0 USE_CUDNN=1 TORCH_CUDA_ARCH_LIST="7.5" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" python3 setup.py install
WORKDIR /
# #need to make it own by myself and not by root because otherwise when we run python it will not access it
WORKDIR /
RUN git clone --recursive https://github.com/pytorch/vision /opt/vision
# RUN pip3 install typing-extensions
WORKDIR /opt/vision
RUN git checkout tags/v0.13.1 && \
git submodule sync && \
git submodule update --init --recursive
# python3 setup.py install
######The 8.0 is for ampere but we leave up until 7.5 because I am using the 2060
RUN MAX_JOBS=8 USE_NINJA=1 BUILD_TEST=0 BUILD_JNI=0 TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX" python3.8 setup.py install
# RUN MAX_JOBS=8 USE_NINJA=1 BUILD_TEST=0 BUILD_JNI=0 USE_CUDNN=1 TORCH_CUDA_ARCH_LIST="7.5" TORCH_NVCC_FLAGS="-Xfatbin -compress-all" python3 setup.py install
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

#torch scatter in order to have scatter_max which is useful for a pointnet architecture. It needs the cuda_arch list in order to find nvidia drivers and build the gpu part of the torch-scatter https://github.com/rusty1s/pytorch_scatter/pull/79
#FORCE_CUDA may be needed for cases like this when the cuda runtime is not exposed during docker build but is actually needed https://github.com/facebookresearch/maskrcnn-benchmark/issues/167
ARG CUDA_HOME="/usr/local/cuda"
ARG TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX"
ARG TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ARG CPATH="/usr/local/cuda/include"
RUN git clone --recursive https://github.com/rusty1s/pytorch_scatter /opt/torch_scatter
WORKDIR /opt/torch_scatter
RUN git checkout tags/2.0.4 && \
git submodule sync && \
git submodule update --init --recursive && \
FORCE_CUDA=1 python3.8 setup.py install
WORKDIR /





#blender
RUN sudo add-apt-repository -y ppa:thomas-schiex/blender && sudo apt-get update && sudo apt-get install -y llvm-6.0-dev blender

#lightworks for video editing (FOR SOME REASON IT DOESNT WORK IN DOCKER)
# RUN wget https://downloads.lwks.com/v14-5/lightworks-14.5.0-amd64.deb && sudo apt -f -y install && sudo dpkg -i lightworks-14.5.0-amd64.deb && rm lightworks-14.5.0-amd64.deb "./cleanup.sh"

#kdenlive for video edition
RUN sudo add-apt-repository -y ppa:kdenlive/kdenlive-stable && sudo apt-get update &&  sudo apt-get install -y kdenlive dbus-x11

#python3 libs
# RUN sudo apt-get update && sudo apt-get -y install python3.8-pip python3.8-tk python3.8-pyqt5 python3.8-crypto python3.8-gnupg python3.8-dbg && sh "./cleanup.sh"
RUN sudo apt-get update && sudo python3.8 -m pip install tk pyqt5 crypto gnupg dbg ipdb numpy jupyter h5py scipy ipython pillow matplotlib opencv-python wheel trollius rospkg asyncio netifaces visdom torchnet sympy tqdm dlutils sklearn scikit-image twine natsort termcolor piq tensorboard torchdiffeq && sh "./cleanup.sh"
#Tensorflow and other stuff that I don't need at the moment
# RUN sudo apt-get update && sudo python3 -m pip install tensorflow==1.15 cython pycocotools && sh "./cleanup.sh"
#needed for tensorboard which required a higher version of setuptools
RUN sudo python3.8 -m pip install --upgrade setuptools setuptools-git  && sh "./cleanup.sh"
#we need to downgrade it because tensorboard has an issue with newer versions https://exerror.com/attributeerror-module-setuptools-_distutils-has-no-attribute-version/
RUN python3.8 -m pip install setuptools==59.5.0 

#python2.7 libs
RUN sudo apt-get update && sudo apt-get install -y python-pip python-tk dvipng  python-tk   && sh "./cleanup.sh"
RUN sudo apt-get update && python2 -m pip install pyyaml pathlib && sh "./cleanup.sh"

#to mount the bagserver
RUN sudo apt-get update && sudo apt-get -y install cifs-utils && sh "./cleanup.sh"


#Things that are nice to have in order to run some applications
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends libtbb-dev libglm-dev libkqueue-dev libpcap-dev network-manager net-tools meshlab ffmpeg libceres-dev unzip && "./cleanup.sh"


#realsense drivers  https://github.com/IntelRealSense/realsense-ros/issues/386#issuecomment-422979706
# RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C8B3A55A6F3EFCDE && sudo add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main" -u
RUN sudo apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo bionic main" -u
RUN sudo apt-get update && sudo apt-get install -y librealsense2-dkms librealsense2-utils librealsense2-dev ros-melodic-ddynamic-reconfigure

#edge tpu compilerlibeigen3-dev_3.3.7-1_all.deb
#RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
#RUN sudo apt-get update
#RUN sudo apt-get install -y edgetpu

#labelimg https://github.com/tzutalin/labelImg
# RUN sudo apt-get install -y pyqt5-dev-tools
# RUN sudo python3 -m pip  install -r requirements/requirements-linux-python3.txt
# RUN make qt5py3
# RUN python3 labelImg.py

#phoxi controller for phoxi scanner
RUN sudo apt install -y avahi-daemon && \
wget https://photoneo.com/files/installer/PhoXi/1.2.14/PhotoneoPhoXiControlInstaller-1.2.14-Ubuntu18-STABLE.run.zip && \
unzip PhotoneoPhoXiControlInstaller-1.2.14-Ubuntu18-STABLE.run.zip && \
chmod +x ./PhotoneoPhoXiControlInstaller-1.2.14-Ubuntu18-STABLE.run && \
sudo ./PhotoneoPhoXiControlInstaller-1.2.14-Ubuntu18-STABLE.run && \
rm PhotoneoPhoXiControlInstaller-1.2.14-Ubuntu18-STABLE.run PhotoneoPhoXiControlInstaller-1.2.14-Ubuntu18-STABLE.run.zip
ENV PHOXI_CONTROL_PATH=/opt/PhotoneoPhoXiControl-1.2.14


#for libgphoto for interfacing with digital cameras
# RUN sudo apt-get install -y usbutils libusb-dev libgphoto2-dev
RUN sudo apt-get install -y usbutils libusb-dev
#get newer version of libgphoto from ubuntu disco https://www.ubuntuupdates.org/package/core/disco/main/base/libgphoto2-dev
#RUN wget http://security.ubuntu.com/ubuntu/pool/main/libg/libgphoto2/libgphoto2-6_2.5.22-3_amd64.deb
#RUN wget http://security.ubuntu.com/ubuntu/pool/main/libg/libgphoto2/libgphoto2-dev_2.5.22-3_amd64.deb
#RUN wget http://security.ubuntu.com/ubuntu/pool/main/libg/libgphoto2/libgphoto2-port12_2.5.22-3_amd64.deb

# RUN wget http://ftp.debian.org/debian/pool/main/libg/libgphoto2/libgphoto2-6_2.5.22-3_amd64.deb
# RUN wget http://ftp.debian.org/debian/pool/main/libg/libgphoto2/libgphoto2-dev_2.5.22-3_amd64.deb
# RUN wget http://ftp.debian.org/debian/pool/main/libg/libgphoto2/libgphoto2-port12_2.5.22-3_amd64.deb

# newer one
# RUN wget https://ftp.fau.de/ubuntu/ubuntu/pool/main/libg/libgphoto2/libgphoto2-6_2.5.23-2_amd64.deb
# RUN wget https://ftp.fau.de/ubuntu/ubuntu/pool/main/libg/libgphoto2/libgphoto2-dev_2.5.23-2_amd64.deb
# RUN wget https://ftp.fau.de/ubuntu/ubuntu/pool/main/libg/libgphoto2/libgphoto2-port12_2.5.23-2_amd64.deb

# RUN sudo apt-get install -y libjpeg62-dev
# RUN sudo dpkg -i libgphoto2-6_2.5.22-3_amd64.deb libgphoto2-dev_2.5.22-3_amd64.deb libgphoto2-port12_2.5.22-3_amd64.deb
#RUN rm libgphoto2-6_2.5.22-3_amd64.deb libgphoto2-dev_2.5.22-3_amd64.deb libgphoto2-port12_2.5.22-3_amd64.deb
# RUN ls
# RUN wtff
# RUN sudo apt-get install -y gphoto2

# #install libgphoto2 from source
# RUN sudo apt-get install -y libpopt-dev
# RUN git clone --recursive https://github.com/gphoto/libgphoto2.git /opt/libgphoto2
# WORKDIR /opt/libgphoto2
# RUN git tag
# RUN git checkout tags/libgphoto2-2_5_23-release
# RUN autoreconf -is
# RUN ./configure
# RUN make
# RUN make install
# WORKDIR /
# #install gphoto2 (the command line interface for libgphoto2) from source
# RUN git clone --recursive https://github.com/gphoto/gphoto2.git /opt/gphoto2
# WORKDIR /opt/gphoto2
# RUN git tag
# RUN git checkout tags/gphoto2-2_5_23-release
# RUN autoreconf -is
# RUN ./configure
# RUN make
# RUN make install
# WORKDIR /


#gphoto with the version that works with nikon and with ubuntu 18
RUN sudo apt-get install -y usbutils libusb-dev libgphoto2-dev
COPY data/libgphoto2-6_2.5.22-3_amd64.deb ./
COPY data/libgphoto2-dev_2.5.22-3_amd64.deb ./
COPY data/libgphoto2-port12_2.5.22-3_amd64.deb ./
# RUN ls
RUN sudo dpkg -i libgphoto2-6_2.5.22-3_amd64.deb libgphoto2-dev_2.5.22-3_amd64.deb libgphoto2-port12_2.5.22-3_amd64.deb
RUN sudo apt-get install -y gphoto2

# #build from source  DOESNT make all the configurations that the deb version of 2.5.22 has
# RUN sudo apt-get install -y usbutils libusb-dev automake autoconf pkg-config autopoint gettext libtool libpopt-dev libudev-dev
# #######TODO clone
# # RUN git clone --recursive https://github.com/gphoto/libgphoto2.git /opt/libgphoto2
# RUN git clone --recursive https://github.com/RaduAlexandru/libgphoto2 /opt/libgphoto2
# WORKDIR /opt/libgphoto2
# #no need to checkout the v2.5.27 because cloning from my repo already assumes that version as the latest one
# # RUN git checkout tags/v2.5.27
# # RUN git submodule sync
# # RUN git submodule update --init --recursive
# RUN autoreconf --install --symlink
# RUN ./configure --prefix=/usr/local
# RUN ./configure --with-camlibs=standard
# RUN make -j4
# RUN make install
# #the command line interface
# RUN git clone --recursive https://github.com/gphoto/gphoto2.git /opt/gphoto2
# WORKDIR /opt/gphoto2
# RUN git checkout tags/v2.5.27
# RUN git submodule sync
# RUN git submodule update --init --recursive
# RUN autoreconf -is
# RUN ./configure --prefix=/usr/local
# RUN make -j4
# RUN make install
# WORKDIR /

#get newer version of libgphoto from ubuntu 19.10 https://pkgs.org/search/?q=libgphoto
# RUN sudo apt-get install -y usbutils libusb-dev libgphoto2-dev
# RUN wget http://archive.ubuntu.com/ubuntu/pool/main/libg/libgphoto2/libgphoto2-6_2.5.23-2_amd64.deb
# RUN wget  http://archive.ubuntu.com/ubuntu/pool/main/libg/libgphoto2/libgphoto2-dev_2.5.23-2_amd64.deb
# RUN wget http://archive.ubuntu.com/ubuntu/pool/main/libg/libgphoto2/libgphoto2-port12_2.5.23-2_amd64.deb
# RUN  sudo dpkg -i libgphoto2-6_2.5.23-2_amd64.deb libgphoto2-dev_2.5.23-2_amd64.deb libgphoto2-dev_2.5.23-2_amd64.deb
# RUN sudo apt-get install -y gphoto2


#darktable as a dependency for the arc gantry which uses darktable for editing raw images
# RUN sudo apt-get install -y libsaxon-java xsltproc intltool desktop-file-utils librsvg2-dev liblcms2-dev libjson-glib-dev libexiv2-dev libpugixml-dev libsecret-1-dev libgraphicsmagick1-dev
# RUN git clone --recursive https://github.com/darktable-org/darktable.git /opt/darktable
# WORKDIR /opt/darktable
# RUN ./build.sh --prefix /opt/darktable --build-type Release
# RUN cmake --build "/opt/darktable/build" --target install -- -j8
# WORKDIR /

#libceres-dev from ubuntu repos is compiled against old eigen and not the new one that we set in this dockerfile so it's better if we just install from source
RUN sudo apt-get purge -y libceres-dev && \
git clone --recursive https://github.com/ceres-solver/ceres-solver.git /opt/ceres
WORKDIR /opt/ceres
RUN git checkout tags/2.0.0 && \
git submodule sync && \
git submodule update --init --recursive
RUN mkdir build
WORKDIR build
RUN cmake .. && make -j3 && sudo make install
WORKDIR /

# colmap  https://colmap.github.io/install.html
# RUN sudo apt-get install -y libboost-program-options-dev libboost-filesystem-dev libboost-graph-dev libboost-regex-dev libboost-system-dev libboost-test-dev libsuitesparse-dev libfreeimage-dev libgoogle-glog-dev libgflags-dev  libglew-dev qtbase5-dev libqt5opengl5-dev libcgal-dev libcgal-qt5-dev libmetis-dev && \
# git clone https://github.com/colmap/colmap.git /opt/colmap
# WORKDIR /opt/colmap
# RUN git checkout tags/3.6 && \
# git submodule sync && \
# git submodule update --init --recursive
# RUN mkdir build
# WORKDIR build
# RUN cmake .. && make -j 3 && sudo make install
# WORKDIR /


#apex
RUN git clone --recursive https://github.com/NVIDIA/apex.git /opt/apex
WORKDIR /opt/apex
RUN git checkout 1d7711100bb58dc761a2fad89f30d41239450f58 && \
git submodule sync && \
git submodule update --init --recursive
# RUN mkdir build
# WORKDIR build
# RUN cmake .. && make -j3 && sudo make install
RUN python3.8 -m pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
WORKDIR /


# ####----ALICEVISON-------
# #alicevision needs cmake bigger than 3.11
# RUN sudo dpkg -r --force-depends cmake cmake-curses-gui
# WORKDIR /
# RUN wget http://www.cmake.org/files/v3.14/cmake-3.14.0.tar.gz  && tar -xvzf cmake-3.14.0.tar.gz
# WORKDIR cmake-3.14.0/
# RUN ./configure && make -j4 && sudo checkinstall -D -y --pkgname=cmake --pkgversion=3.14
# WORKDIR /
# #other dependencies for alicevision
# # RUN sudo apt-get install -y openexr libopenimageio-dev
# RUN sudo apt-get install -y openexr
# #geogram
# RUN git clone https://github.com/alicevision/geogram.git /opt/geogram
# WORKDIR /opt/geogram
# RUN git checkout tags/v1.7.6 && \
# git submodule sync && \
# git submodule update --init --recursive && \
# sh -f configure.sh
# WORKDIR build/Linux64-gcc-dynamic-Release
# RUN make -j4 && make install
# WORKDIR /
# #OpenImageIO
# RUN git clone https://github.com/OpenImageIO/oiio.git /opt/oiio
# WORKDIR /opt/oiio
# RUN git checkout tags/Release-2.2.7.0 && \
# git submodule sync && \
# git submodule update --init --recursive && \
# mkdir build
# WORKDIR build
# RUN cmake -DUSE_PYTHON=0 -DOIIO_BUILD_TESTS=0 .. && make -j4 && make install
# WORKDIR /
# #alicevision itself
# RUN git clone --recursive https://github.com/alicevision/AliceVision.git /opt/alicevision
# WORKDIR /opt/alicevision
# RUN git checkout tags/v2.3.0 && \
# git submodule sync && \
# git submodule update --init --recursive && \
# mkdir build
# WORKDIR build
# RUN cmake -DCMAKE_BUILD_TYPE=Release .. && make -j4 && sudo make install
# WORKDIR /
# #meshroom
# RUN sudo python3 -m pip install psutil enum34 PySide2 markdown requests
# ENV ALICEVISION_SENSOR_DB=/opt/alicevision/src/aliceVision/sensorDB







#oniv2 I couldnt build it from source because it fails at esy-autoconf with some texinfo error of misplaced  }
# RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
# RUN sudo bash nodesource_setup.sh
# RUN sudo apt-get install -y nodejs
# RUN sudo apt-get install -y ragel nasm libharfbuzz-dev clang automake1.11 libacl1-dev
# RUN sudo npm install -g esy -unsafe-perm=true
#YOU ALSO NEED TO INSTALL GN FROM HERE https://gn.googlesource.com/gn/
# AND THE DO A sudo ln -s gn /bin/gn
#follow the steps in https://onivim.github.io/docs/for-developers/building so you have to clone when you are in docker this and run the build thingies
# git clone https://github.com/onivim/oni2
# cd oni2
# git checkout 221bef9c94ba1a8794a049a1fdf846d5aea1899c
# sudo esy install
# sudo esy bootstrap
# sudo esy build
# sudo npm install -g node-gyp
# sudo node install-node-deps.js
# esy run


#audacity which is nice to have to remove noise from recorded videos
RUN sudo add-apt-repository -y ppa:ubuntuhandbook1/audacity
RUN sudo apt update
RUN sudo apt install -y audacity


#qt which is needed for some packages
RUN sudo apt-get install -y qt4-qmake libqt4-dev



#other pakcages
RUN sudo apt-get install -y build-essential git python3-dev python3-pip libopenexr-dev libxi-dev libglfw3-dev libglew-dev libomp-dev libxinerama-dev libxcursor-dev

#rawtherapee for processing raw images for phenorob
RUN sudo add-apt-repository -y ppa:dhor/myway
RUN sudo apt update
RUN sudo apt install -y rawtherapee


#nvidia compute for profiling kernels #you cna then start it from /opt/nvidia/nsight-compute/ncu-ui
#or you cna run /opt/nvidia/nsight-compute/2022.1.0/ncu --target-processes all <my_executabel>
# RUN sudo apt-get install -y nsight-compute-2022.1.0 





# #python libs
# RUN conda install -n pt  matplotlib pyyaml scikit-image && conda clean -ya

# #python libs for python 2.7 because there are some sripts out there that only work with 2.7
# RUN conda create -n py27 python=2.7 numpy tk matplotlib pyyaml qt pyqt && conda clean -ya
# #dvipng is sometimes needed by matplotlib but somehow it is not mentioned as dependency and some plotting may fail because of that
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends dvipng && sh "./cleanup.sh"



# ###   BUG FIXES   ################################3
# # need to downgrade fontconfig from 2.13 to 2.12 because with 2.13 I get a linking error of /opt/conda/envs/pt/lib/libfontconfig.so.1: undefined reference to `FT_Done_MM_Var'
# RUN conda install -n pt fontconfig=2.12 && conda clean -ya



#THIS HAS TO BE THE LAST thing after we instal things 
#if you ever need to do add-reposityo you need you change alternative back to python3.6
RUN sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2 



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
RUN usermod -a -G dialout ${user} && usermod -a -G video ${user} && usermod -a -G audio ${user} && usermod -a -G audio ${user}


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
