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

#the shm-size had to be increased to avoid bus error(core dumped) when using phoxi controller https://github.com/pytorch/pytorch/issues/2244#issuecomment-318864552

# Run the container with shared X11
docker run\
  --shm-size 2G\
  --runtime=nvidia\
  --publish-all=true\
  --net=host\
  --privileged\
  -e SHELL\
  -e DISPLAY\
  -e DOCKER=1\
  -v /dev:/dev\
  -v "$HOME:$HOME:rw"\
  -v "/media/rosu/Data:/media/rosu/Data:rw"\
  -v "/media/rosu/INTENSO:/media/rosu/INTENSO:rw"\
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw"\
  -v "/opt/intel:/opt/intel:rw"\
  -it $1