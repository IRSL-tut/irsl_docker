ARG BUILD_IMAGE=ubuntu:20.04
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BUILD_IMAGE} as builder

LABEL maintainer "YoheiKakiuchi <kakiuchi.yohei.sw@tut.jp>"

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -q -qq && \
    apt install -q -qq -y wget libssl-dev openssl cmake g++ pkg-config git uuid-dev libsodium-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/

WORKDIR /build_xeus
RUN wget https://github.com/nlohmann/json/archive/refs/tags/v3.11.2.tar.gz
RUN tar xf v3.11.2.tar.gz
RUN (cd json-3.11.2; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt . ; make install -j12)

RUN wget https://github.com/xtensor-stack/xtl/archive/refs/tags/0.7.4.tar.gz
RUN tar xf 0.7.4.tar.gz
RUN (cd xtl-0.7.4; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt . ; make install -j12)

RUN wget https://github.com/zeromq/libzmq/archive/refs/tags/v4.3.4.tar.gz
RUN tar xf v4.3.4.tar.gz
RUN (cd libzmq-4.3.4; mkdir build; cd build; cmake -D WITH_PERF_TOOL=OFF -D ZMQ_BUILD_TESTS=OFF -D ENABLE_CPACK=OFF -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/opt ..; make install -j12)

RUN wget https://github.com/zeromq/cppzmq/archive/refs/tags/v4.8.1.tar.gz
RUN tar xf v4.8.1.tar.gz
RUN (cd cppzmq-4.8.1; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt . ; make install -j12)

RUN wget https://github.com/jupyter-xeus/xeus/archive/refs/tags/2.4.1.tar.gz
RUN tar xf 2.4.1.tar.gz
RUN (cd xeus-2.4.1; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt . ; make install -j12)

####
#
#
#
####
FROM ${BASE_IMAGE}

LABEL maintainer "YoheiKakiuchi <kakiuchi.yohei.sw@tut.jp>"

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -q -qq && \
    apt install -q -qq -y libssl-dev openssl cmake g++ pkg-config git uuid-dev libsodium-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/

COPY --from=builder /opt /opt

RUN apt update -q -qq && \
    apt install -q -qq -y python3-pip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/ && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install jupyterlab

## build xeus/example at https://github.com/jupyter-xeus/xeus.git
## docker run -it --net=host -v $(pwd):/hoge -w /hoge xeus:20.04 bash
## jupyter lab --allow-root
