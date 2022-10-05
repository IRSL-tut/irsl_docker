ARG BUILD_IMAGE=ubuntu:20.04
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BUILD_IMAGE} as builder
## BUILD_PREFIX=repo.irsl.eiiris.tut.ac.jp/
## docker build -f Dockerfile --build-arg BUILD_IMAGE=ubuntu:20.04 --build-arg BASE_IMAGE=ubuntu:20.04 -t ${BUILD_PREFIX}xeus:20.04 .
## docker build -f Dockerfile --build-arg BUILD_IMAGE=ubuntu:22.04 --build-arg BASE_IMAGE=ubuntu:22.04 -t ${BUILD_PREFIX}xeus:22.04 .

LABEL maintainer "YoheiKakiuchi <kakiuchi.yohei.sw@tut.jp>"

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -q -qq && \
    apt install -q -qq -y wget libssl-dev openssl cmake g++ pkg-config git uuid-dev libsodium-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/

WORKDIR /build_xeus
RUN (mkdir json && wget https://github.com/nlohmann/json/archive/refs/tags/v3.11.2.tar.gz --quiet -O - | tar zxf - --strip-components 1 -C json)
RUN (cd json; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j$(nproc) )
#RUN wget https://github.com/nlohmann/json/archive/refs/tags/v3.11.2.tar.gz
#RUN tar zxf v3.11.2.tar.gz
#RUN (cd json-3.11.2; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j12)

RUN (mkdir xtl && wget https://github.com/xtensor-stack/xtl/archive/refs/tags/0.7.4.tar.gz --quiet -O - | tar zxf - --strip-components 1 -C xtl)
RUN (cd xtl; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j$(nproc) )
#RUN wget https://github.com/xtensor-stack/xtl/archive/refs/tags/0.7.4.tar.gz
#RUN tar zxf 0.7.4.tar.gz
#RUN (cd xtl-0.7.4; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j12)

RUN (mkdir libzmq && wget https://github.com/zeromq/libzmq/archive/refs/tags/v4.3.4.tar.gz --quiet -O - | tar zxf - --strip-components 1 -C libzmq)
RUN (cd libzmq; mkdir build; cd build; cmake -D WITH_PERF_TOOL=OFF -D ZMQ_BUILD_TESTS=OFF -D ENABLE_CPACK=OFF -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/opt/xeus ..; make install -j$(nproc) )
#RUN wget https://github.com/zeromq/libzmq/archive/refs/tags/v4.3.4.tar.gz
#RUN tar zxf v4.3.4.tar.gz
#RUN (cd libzmq-4.3.4; mkdir build; cd build; cmake -D WITH_PERF_TOOL=OFF -D ZMQ_BUILD_TESTS=OFF -D ENABLE_CPACK=OFF -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/opt/xeus ..; make install -j12)

RUN (mkdir cppzmq && wget https://github.com/zeromq/cppzmq/archive/refs/tags/v4.8.1.tar.gz --quiet -O - | tar zxf - --strip-components 1 -C cppzmq)
RUN (cd cppzmq; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j$(nproc) )
#RUN wget https://github.com/zeromq/cppzmq/archive/refs/tags/v4.8.1.tar.gz
#RUN tar zxf v4.8.1.tar.gz
#RUN (cd cppzmq-4.8.1; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j12)

RUN (mkdir xeus && wget https://github.com/jupyter-xeus/xeus/archive/refs/tags/2.4.1.tar.gz --quiet -O - | tar zxf - --strip-components 1 -C xeus)
RUN (cd xeus; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j$(nproc) )
#RUN wget https://github.com/jupyter-xeus/xeus/archive/refs/tags/2.4.1.tar.gz
#RUN tar zxf 2.4.1.tar.gz
#RUN (cd xeus-2.4.1; cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus . ; make install -j12)

### build example
#RUN cd xeus/example && \
#    mkdir build; cd build && \
#    cmake .. -DCMAKE_PREFIX_PATH=/opt/xeus/share/cmake -DZeroMQ_DIR=/opt/xeus/lib/cmake/ZeroMQ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/xeus && \
#    make install

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

COPY --from=builder /opt/xeus /opt/xeus
COPY --from=builder /usr/local /usr/local

RUN apt update -q -qq && \
    apt install -q -qq -y python3-pip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/ && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install jupyterlab

## docker run -it --net=host -v $(pwd):/hoge -w /hoge xeus:20.04 bash
## jupyter lab --allow-root
## cmake -DCMAKE_PREFIX_PATH=/opt/xeus/share/cmake -DZeroMQ_DIR=/opt/xeus/lib/cmake/ZeroMQ ....
ENV JUPYTER_PATH=/opt/xeus/share/jupyter/kernels
CMD ["jupyter", "lab", "--allow-root"]
