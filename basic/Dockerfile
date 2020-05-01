# FROM ubuntu:bionic
# FROM ubuntu:18.04 
# FROM continuumio/miniconda
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
# RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh tmux git meld cmake cmake-curses-gui htop vim iputils-ping apt-utils apt-transport-https software-properties-common wget build-essential gdb valgrind silversearcher-ag curl dirmngr gpg-agent checkinstall locate baobab && sh "./cleanup.sh"
RUN apt-get -y update && apt-get install -y --no-install-recommends sudo ssh

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

#-------------------------------------------------------------------------------

# #needed by pybind11
# RUN apt-get -y update && apt-get install -y --no-install-recommends python3-distutils && sh "./cleanup.sh"

# #needed so that gl applications that are build with conda find a gpu driver and don't fail when testing them inside this container: https://github.com/conda-forge/pygridgen-feedstock/issues/10
# RUN sudo apt-get -y update && sudo apt install -y libgl1-mesa-glx  && sh "./cleanup.sh"

# #download conda install script 
# # RUN curl -o /tmp/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
#     #  chmod +x /tmp/miniconda.sh && mkdir /opt/conda

# #create the current user and switch to it so we don't have to use root for installing conda https://github.com/ContinuumIO/docker-images/issues/151#issuecomment-545177971
# # RUN useradd --shell /bin/bash ${user}
# # WORKDIR /home/${user}
# # USER ${user}
# # RUN groupadd -r ${user}  && ${user} -r -g ${user} ${user}

# # #conda
# # RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
# #      chmod +x ~/miniconda.sh && \
# #      ~/miniconda.sh -b -p /opt/conda && \
# #      rm ~/miniconda.sh && "./cleanup.sh"
# # https://hub.docker.com/r/continuumio/miniconda3/dockerfile
# RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#     /bin/bash ~/miniconda.sh -b -p /opt/conda && \
#     rm ~/miniconda.sh && \
#     /opt/conda/bin/conda clean -tipsy && \
#     ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
#     echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc 
#     #&& \
#     #echo "conda activate base" >> ~/.bashrc
# # WORKDIR /tmp
# # RUN pwd
# # RUN ls /tmp
# # RUN  /tmp/miniconda.sh -b /opt/conda 
# ENV PATH /opt/conda/bin:$PATH


# # #python with conda https://medium.com/@chadlagore/conda-environments-with-docker-82cdc9d25754
# ARG PYTHON_VERSION=3.6
# RUN conda create -n pt python=${PYTHON_VERSION}
# ENV PATH /opt/conda/envs/pt/bin:$PATH
# RUN /bin/bash -c "source activate pt"
# RUN echo "source activate pt" >> ~/.bashrc
# RUN echo "conda activate pt" >> ~/.bashrc
# RUN conda config --add channels conda-forge
# ENV PATH /opt/conda/envs/pt/bin:$PATH
# RUN conda install -n pt anaconda-client conda-build conda-verify conda-press patchelf  && conda clean -ya
# RUN source activate pt
# RUN conda install -n pt -c conda-forge   conda-press && conda clean -ya

#update pip 
# RUN sudo apt install python3-distutils
# RUN pip3 install --upgrade pip

# USER root
#They cause conflicts with the library installed in the system
# RUN rm /opt/conda/envs/pt/lib/libfontconfig.so.1 /opt/conda/envs/pt/lib/libfontconfig.so /opt/conda/envs/pt/lib/libfontconfig.so.1.11.1 

#conda got installed as root but we want to access it's packages from non root user 
RUN useradd --shell /bin/bash ${user}
# RUN sudo chown -R ${user} /opt/conda


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
