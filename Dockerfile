# create /choreonoid_ws
# choreonoid_ws: choreonoid
ARG BASE_IMAGE=ros:ros-melodic-base
FROM ${BASE_IMAGE}

LABEL maintainer "YoheiKakiuchi <kakiuchi.yohei.sw@tut.jp>"

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

### install choreonoid
WORKDIR /choreonoid_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    wstool init src https://raw.githubusercontent.com/IRSL-tut/irsl_choreonoid/main/config/dot.rosinstall && \
    wstool update -t src

RUN apt update -q -qq && \
    sed -i -e 's@sudo apt-get -y install@apt-get install -y -q -qq @g' src/choreonoid/misc/script/install-requisites-ubuntu-18.04.sh && \
    src/choreonoid/misc/script/install-requisites-ubuntu-18.04.sh && \
    apt install -q -qq -y curl python-catkin-tools libreadline-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/

RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && catkin config --install && catkin build irsl_choreonoid --no-status --no-notify -p 1 && catkin clean -d -b -l -y"

### ADD entry point
