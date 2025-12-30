FROM fedora:42

RUN dnf install -y \
    clang \
    make \
    cmake \
    git \
    && dnf clean all

WORKDIR /opt

# set up emsdk
ENV EMSDK_DIR=/opt/emsdk
RUN git clone https://github.com/emscripten-core/emsdk.git $EMSDK_DIR

WORKDIR $EMSDK_DIR
RUN ./emsdk install latest
RUN ./emsdk activate latest

ENV IOQUAKE3_DIR=/opt/ioquake3
RUN git clone https://github.com/ioquake/ioq3.git $IOQUAKE3_DIR

WORKDIR $IOQUAKE3_DIR

RUN . $EMSDK_DIR/emsdk_env.sh && \
    emcmake cmake \
        -S . \
        -B build-wasm \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build-wasm --parallel

# build assets are in the build-wasm/<CMAKE_BUILD_TYPE> directory
RUN ls -lR build-wasm/Release/

# populate the required pk3 files to the build tree
COPY baseq3/*.pk3 build-wasm/Release/baseq3/
