#!/usr/bin/env bash

# Check args
if [ "$#" -ne 1 ]; then
  echo "usage: ./run.sh IMAGE_NAME"
  return 1
fi

# Get this script's path
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

set -e

# Run the container with shared X11
docker run\
  --shm-size 2G\
  --gpus all\
  --publish-all=true\
  --net=host\
  --privileged\
  -e SHELL\
  -e DISPLAY\
  -e DOCKER=1\
  -v /dev:/dev\
  -v "$HOME:$HOME:rw"\
  -v "/media/rosu/Data:/media/rosu/Data:rw"\
  -v "/media/rosu/HDD:/media/rosu/HDD:rw"\
  -v "/media/rosu/INTENSO:/media/rosu/INTENSO:rw"\
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw"\
  -v "/opt/intel:/opt/intel:rw"\
  -it $1