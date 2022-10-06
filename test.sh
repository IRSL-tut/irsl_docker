#!/bin/bash

MYREPO=repo.irsl.eiiris.tut.ac.jp/

## xeus
## choreonoid_src

docker build -f Dockerfile.choreonoid_src \
       --build-arg UBUNTU_VER=20.04 \
       --build-arg BASE_IMAGE=ubuntu:20.04 \
       -t ${MYREPO}choreonoid_src:20.04 .

## docker build -f Dockerfile.add_xeus --build-arg BUILD_IMAGE=${MYREPO}xeus:20.04 --build-arg BASE_IMAGE=${MYREPO}choreonoid_src:20.04 -t temp_test/cnoid_with_xeus:20.04 .

git clone --depth=1 https://github.com/IRSL-tut/robot_assembler_plugin.git
docker build -f Dockerfile.add_assembler \
       --build-arg BASE_IMAGE=${MYREPO}choreonoid_src:20.04 \
       -t temp_test/cnoid_with_assembler:20.04 .

git clone --depth=1 https://github.com/IRSL-tut/jupyter_plugin.git
docker build -f Dockerfile.add_jupyter_plugin \
       --build-arg BUILD_IMAGE=${MYREPO}xeus:20.04 \
       --build-arg BASE_IMAGE=${MYREPO}choreonoid_src:20.04 \
       -t temp_test/cnoid_with_jupyter:20.04 .
