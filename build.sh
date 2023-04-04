#!/bin/bash

set -e

## noetic or melodic
ROS_DISTRO_=${BUILD_ROS:-"noetic"}
UBUNTU_VER="22.04"
if [ ${ROS_DISTRO} == "noetic" ]; then
    UBUNTU_VER="20.04"
elif [ ${ROS_DISTRO} == "melodic" ]; then
    UBUNTU_VER="18.04"
fi
## --no-cache
CACHED=${BUILD_CACHED:-""}
CACHED_MAIN=${CACHED}
if [ -n "${FORCE_BUILD}"  ]; then
    CACHED_MAIN=--no-cache
fi
## --pull
PULLORIGIN=${BUILD_PULLED:-""}
##
ADD_OPENSCAD=${BUILD_OPEN_SCAD:-"add"}

wget https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_virtualgl  -O /tmp/Dockerfile.add_virtualgl
wget https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_glvnd      -O /tmp/Dockerfile.add_glvnd
wget https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_entrypoint -O /tmp/Dockerfile.add_entrypoint

ORIGIN_IMAGE=ros:${ROS_DISTRO_}-ros-base
REPO=repo.irsl.eiiris.tut.ac.jp/
TARGET_NAME=${REPO}irsl_choreonoid:${ROS_DISTRO_}

BUILD_A=build_temp/add_glvnd:${ROS_DISTRO_}
BUILD_B=build_temp/add_virtualgl:${ROS_DISTRO_}
BUILD_C=build_temp/add_xeus:${ROS_DISTRO_}
BUILD_D=build_temp/irsl_choreonoid:${ROS_DISTRO_}

###
wget https://github.com/IRSL-tut/irsl_docker/raw/xeus/Dockerfile -O /tmp/Dockerfile.xeus
docker build . -f /tmp/Dockerfile.xeus --build-arg BASE_IMAGE=${ORIGIN_IMAGE} -t build_temp/xeus:${ROS_DISTRO_}
###

echo "## ADD glvnd"
docker build . ${CACHED} ${PULLORIGIN} -f /tmp/Dockerfile.add_glvnd      --build-arg BASE_IMAGE=${ORIGIN_IMAGE} -t ${BUILD_A}
echo "## ADD virtual_gl"
docker build . ${CACHED}               -f /tmp/Dockerfile.add_virtualgl  --build-arg BASE_IMAGE=${BUILD_A} -t ${BUILD_B}
echo "## ADD xeus"
docker build . ${CACHED}               -f Dockerfile.add_xeus  --build-arg BASE_IMAGE=${BUILD_B} --build-arg BUILD_IMAGE=build_temp/xeus:${ROS_DISTRO_} -t ${BUILD_C}
echo "## BUILD main"
docker build . ${CACHED_MAIN}          -f Dockerfile  --build-arg UBUNTU_VER=${UBUNTU_VER} --build-arg BASE_IMAGE=${BUILD_C} -t ${BUILD_D}
echo "## ADD entrypoint"
docker build . ${CACHED}               -f /tmp/Dockerfile.add_entrypoint --build-arg BASE_IMAGE=${BUILD_D} -t ${TARGET_NAME}

if [ "${ROS_DISTRO_}" = "noetic" -a "${ADD_OPENSCAD}" = "add" ]; then
    docker build . ${CACHED}           -f Dockerfile.add_openscad   --build-arg BASE_IMAGE=${TARGET_NAME} -t ${TARGET_NAME}
fi
## docker push

docker run -it \
    --env="DOCKER_ROS_SETUP=/choreonoid_ws/install/setup.bash" \
    ${TARGET_NAME} \
    -- bash -c 'source /irsl_entryrc; roscd irsl_choreonoid/test; PYTHONPATH=$PYTHONPATH:$(dirname $(which choreonoid))/../lib/choreonoid-1.8/python python3 coords_test.py'

echo "BUILD: successfully finished"
