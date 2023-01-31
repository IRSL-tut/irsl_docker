#!/bin/bash

VAR=${@:-"-- choreonoid --assembler /choreonoid_ws/src/choreonoid/ext/robot_assembler_plugin/config/irsl/irsl_assembler_config.yaml /choreonoid_ws/src/choreonoid/ext/robot_assembler_plugin/config/assembler.cnoid"}

DOCKER_CONTAINER=docker_robot_assembler \
./run_local.sh  \
${VAR}
