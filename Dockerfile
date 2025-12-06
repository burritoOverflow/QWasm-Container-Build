FROM fedora:42

RUN dnf install -y \
    clang \
    make \
    cmake \
    git \
    && dnf clean all

WORKDIR /opt

ENV EMSDK_DIR=/opt/emsdk
ENV QWASM_DIR=/opt/quake-wasm
ENV GL4ES_DIR=/opt/gl4es

RUN git clone https://github.com/emscripten-core/emsdk.git $EMSDK_DIR

# set up emsdk
WORKDIR $EMSDK_DIR
RUN ./emsdk install latest
RUN ./emsdk activate latest

RUN git clone https://github.com/ptitSeb/gl4es.git $GL4ES_DIR

# build gl4es
WORKDIR $GL4ES_DIR
RUN . $EMSDK_DIR/emsdk_env.sh && \
    emcmake cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DNOX11=ON \
        -DNOEGL=ON \
        -DSTATICLIB=ON && \
    make VERBOSE=1 -C build

# clone and build Qwasm
RUN git clone https://github.com/GMH-Code/Qwasm.git $QWASM_DIR

# see: https://github.com/GMH-Code/Qwasm/blob/master/README.md#building-software-rendered-qwasm-on-linux
WORKDIR $QWASM_DIR/WinQuake

COPY id1 ./id1/

RUN . $EMSDK_DIR/emsdk_env.sh && \
    make -f Makefile.emscripten GL4ES_PATH=$GL4ES_DIR
