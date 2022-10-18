#!/bin/bash

MYREPO=repo.irsl.eiiris.tut.ac.jp/
UBUNTU_VER=20.04
## xeus
## choreonoid_src

docker build -f Dockerfile.choreonoid_src \
       --build-arg UBUNTU_VER=${UBUNTU_VER} \
       --build-arg BASE_IMAGE=ubuntu:${UBUNTU_VER} \
       -t ${MYREPO}choreonoid_src:${UBUNTU_VER} .

wget https://github.com/IRSL-tut/irsl_docker/raw/xeus/Dockerfile -O Dockerfile.build_xeus
docker build -f Dockerfile.build_xeus \
       --build-arg BUILD_IMAGE=ubuntu:${UBUNTU_VER} \
       --build-arg BASE_IMAGE=ubuntu:${UBUNTU_VER} \
       -t ${MYREPO}xeus:${UBUNTU_VER} .

## docker build -f Dockerfile.add_xeus --build-arg BUILD_IMAGE=${MYREPO}xeus:20.04 --build-arg BASE_IMAGE=${MYREPO}choreonoid_src:20.04 -t temp_test/cnoid_with_xeus:20.04 .

git clone --depth=1 https://github.com/IRSL-tut/robot_assembler_plugin.git
docker build -f Dockerfile.add_assembler \
       --build-arg BASE_IMAGE=${MYREPO}choreonoid_src:${UBUNTU_VER} \
       -t temp_test/cnoid_with_assembler:${UBUNTU_VER} .

git clone --depth=1 https://github.com/IRSL-tut/jupyter_plugin.git
docker build -f Dockerfile.add_jupyter_plugin \
       --build-arg BUILD_IMAGE=${MYREPO}xeus:${UBUNTU_VER} \
       --build-arg BASE_IMAGE=${MYREPO}choreonoid_src:${UBUNTU_VER} \
       -t temp_test/cnoid_with_jupyter:${UBUNTU_VER} .
