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

wget -P /tmp https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_virtualgl
wget -P /tmp https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_glvnd
wget -P /tmp https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_entrypoint

ORIGIN_IMAGE=ros:${ROS_DISTRO_}-ros-base
TARGET_NAME=irslrepo/humanoid_sim:${ROS_DISTRO_}

BUILD_A=build_temp/add_glvnd:${ROS_DISTRO_}
BUILD_B=build_temp/add_virtualgl:${ROS_DISTRO_}
BUILD_C=build_temp/humanoid_sim:${ROS_DISTRO_}

echo "## ADD glvnd"
docker build . ${CACHED} ${PULLORIGIN} -f /tmp/Dockerfile.add_glvnd      --build-arg BASE_IMAGE=${ORIGIN_IMAGE} -t ${BUILD_A}
echo "## ADD virtual_gl"
docker build . ${CACHED}               -f /tmp/Dockerfile.add_virtualgl  --build-arg BASE_IMAGE=${BUILD_A} -t ${BUILD_B}
echo "## BUILD main"
docker build . ${CACHED}               -f Dockerfile                     --build-arg BASE_IMAGE=${BUILD_B} -t ${BUILD_C}
echo "## ADD entrypoint"
docker build . ${CACHED}               -f /tmp/Dockerfile.add_entrypoint --build-arg BASE_IMAGE=${BUILD_C} -t ${TARGET_NAME}

if [ "${ADD_SOURCE}" = "add" ]; then
    docker build . ${CACHED}           -f Dockerfile.hrpsys_source   --build-arg BASE_IMAGE=${TARGET_NAME} -t irslrepo/humanoid_sim_source:${ROS_DISTRO_}
fi

## docker push
