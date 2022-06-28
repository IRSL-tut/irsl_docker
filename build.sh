#!/bin/bash

set -e

## noetic or melodic
ROS_DISTRO_=${BUILD_ROS:-"noetic"}
## --no-cache
CACHED=${BUILD_CACHED:-""}
## --pull
PULLORIGIN=${BUILD_PULLED:-""}
##
ADD_OPENSCAD=${BUILD_OPEN_SCAD:-"add"}

wget -P /tmp https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_virtualgl
wget -P /tmp https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_glvnd
wget -P /tmp https://raw.githubusercontent.com/IRSL-tut/irsl_docker/main/Dockerfile.add_entrypoint

ORIGIN_IMAGE=ros:${ROS_DISTRO_}-ros-base
TARGET_NAME=irslrepo/irsl_choreonoid:${ROS_DISTRO_}

BUILD_A=build_temp/add_glvnd:${ROS_DISTRO_}
BUILD_B=build_temp/add_virtualgl:${ROS_DISTRO_}
BUILD_C=build_temp/irsl_choreonoid:${ROS_DISTRO_}

echo "## ADD glvnd"
docker build . ${CACHED} ${PULLORIGIN} -f /tmp/Dockerfile.add_glvnd      --build-arg BASE_IMAGE=${ORIGIN_IMAGE} -t ${BUILD_A}
echo "## ADD virtual_gl"
docker build . ${CACHED}               -f /tmp/Dockerfile.add_virtualgl  --build-arg BASE_IMAGE=${BUILD_A} -t ${BUILD_B}
echo "## BUILD main"
docker build . ${CACHED}               -f Dockerfile                     --build-arg BASE_IMAGE=${BUILD_B} -t ${BUILD_C}
echo "## ADD entrypoint"
docker build . ${CACHED}               -f /tmp/Dockerfile.add_entrypoint --build-arg BASE_IMAGE=${BUILD_C} -t ${TARGET_NAME}

if [ "${ROS_DISTRO_}" = "noetic" -a "${ADD_OPENSCAD}" = "add" ]; then
    docker build . ${CACHED}           -f Dockerfile.add_openscad   --build-arg BASE_IMAGE=${TARGET_NAME} -t irslrepo/irsl_choreonoid_openscad:${ROS_DISTRO_}
fi
## docker push

docker run -it \
    --env="DOCKER_ROS_SETUP=/choreonoid_ws/install/setup.bash" \
    ${TARGET_NAME} \
    -- bash -c 'source /irsl_entryrc; roscd irsl_choreonoid/test; PYTHONPATH=$PYTHONPATH:$(dirname $(which choreonoid))/../lib/choreonoid-1.8/python/cnoid python3 coords_test.py'

echo "BUILD: successfully finished"
