FROM fedora:42

RUN dnf install -y \
    clang \
    make \
    git \
    && dnf clean all

WORKDIR /opt

ENV EMSDK_DIR=/opt/emsdk
ENV QWASM_DIR=/opt/quake-wasm

RUN git clone https://github.com/emscripten-core/emsdk.git $EMSDK_DIR

# set up emsdk
WORKDIR $EMSDK_DIR
RUN ./emsdk install latest
RUN ./emsdk activate latest

# clone and build Qwasm
RUN git clone https://github.com/GMH-Code/Qwasm.git $QWASM_DIR

# see: https://github.com/GMH-Code/Qwasm/blob/master/README.md#building-software-rendered-qwasm-on-linux
WORKDIR $QWASM_DIR/WinQuake

COPY id1 ./id1/

RUN . $EMSDK_DIR/emsdk_env.sh && \
    make -f Makefile.emscripten
