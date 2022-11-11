#!/bin/bash

set -e

## noetic or melodic
ROS_DISTRO_=${BUILD_ROS:-"melodic"}
## --no-cache
CACHED=${BUILD_CACHED:-""}
## --pull
PULLORIGIN=${BUILD_PULLED:-""}
##
ADD_SOURCE=${BUILD_SOURCE:-"add"}

REPO=repo.irsl.eiiris.tut.ac.jp/
#REPO=irslrepo/
ORIGIN_IMAGE=${REPO}irsl_base:${ROS_DISTRO_}_nvidia
TARGET_NAME=${REPO}humanoid_sim:${ROS_DISTRO_}

echo "## BUILD main"
docker build . ${CACHED} ${PULLORIGIN} -f Dockerfile --build-arg BASE_IMAGE=${ORIGIN_IMAGE} -t ${TARGET_NAME}

if [ "${ADD_SOURCE}" = "add" ]; then
    docker build . ${CACHED}           -f Dockerfile.hrpsys_source --build-arg BASE_IMAGE=${TARGET_NAME} -t ${REPO}humanoid_sim_source:${ROS_DISTRO_}
fi

## docker push
