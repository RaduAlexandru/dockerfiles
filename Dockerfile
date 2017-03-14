FROM ros:indigo

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# Basic Utilities
RUN apt-get -y update && apt-get install -y zsh screen tree sudo ssh synaptic


#Needed for the command add-apt-repository
RUN apt-get -y install software-properties-common python-software-properties

#Tmux version 2.3 for ubuntu 14.04
RUN add-apt-repository -y ppa:pi-rho/dev
RUN apt-get -y update
RUN apt-get install -y tmux-next

#Others
RUN apt-get install -y  git checkinstall cmake vim




# Latest X11 / mesa GL
RUN apt-get install -y\
  xserver-xorg-dev-lts-wily\
  libegl1-mesa-dev-lts-wily\
  libgl1-mesa-dev-lts-wily\
  libgbm-dev-lts-wily\
  mesa-common-dev-lts-wily\
  libgles2-mesa-lts-wily\
  libwayland-egl1-mesa-lts-wily\
  libopenvg1-mesa

# Dependencies required to build rviz
RUN apt-get install -y\
  qt4-dev-tools\
  libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0\
  libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1\
  libxcb-render-util0 libxcb-util0 libxcb-xkb1 libxkbcommon-x11-0\
  libxkbcommon0

# The rest of ROS-desktop
RUN apt-get install -y ros-indigo-desktop-full

# Additional development tools
RUN apt-get install -y x11-apps python-pip build-essential
RUN pip install catkin_tools


#pcl, openc and eigen3
RUN add-apt-repository -y ppa:v-launchpad-jochen-sprickerhof-de/pcl
RUN apt-get -y update
RUN apt-get -y install libpcl-all libopencv-dev libeigen3-dev
#RUN apt-get -y upgrade 


#librealsense prerequisites
RUN apt-get install -y libusb-1.0-0-dev pkg-config
RUN sudo apt-get update && sudo apt-get install -y build-essential cmake git xorg-dev libglu1-mesa-dev && git clone https://github.com/glfw/glfw.git /tmp/glfw && cd /tmp/glfw && git checkout latest && cmake . -DBUILD_SHARED_LIBS=ON && make && sudo make install && sudo ldconfig && rm -rf /tmp/glfw


#RUN cp /media/alex/Data/Master/SHK/shk_ws/src/realsense/config/99-realsense-libusb.rules /etc/udev/rules.d/

COPY resources /resources/
RUN cp /resources/99-realsense-libusb.rules /etc/udev/rules.d/

RUN apt-get install -y udev
#RUN udevadm control --reload-rules && udevadm trigger
#RUN /media/alex/Data/Master/SHK/shk_ws/src/realsense/scripts/patch-uvcvideo-16.04.simple_unsafe.sh
RUN sudo apt-get install -y 'ros-indigo-realsense-camera'
RUN sudo apt-get install -y gdb
#RUN sudo apt-get install -y gnuplot
RUN sudo apt-get install -y libvxl1-dev
RUN sudo apt-get install -y libceres-dev
RUN sudo apt-get install -y libsuitesparse-dev

RUN apt-get update
RUN apt-get install -y tcpdump --fix-missing
# HACK around https://github.com/dotcloud/docker/issues/5490
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump
RUN mv /sbin/dhclient  /usr/sbin/dhclient

#Make SSH keys work inside the container
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config




# Make SSH available
EXPOSE 22

# Mount the user's home directory
VOLUME "${home}"

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
