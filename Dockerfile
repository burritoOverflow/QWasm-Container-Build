# responsible for building Qwasm with both software rendering and WebGL support
FROM fedora:42

RUN dnf install -y \
    clang \
    make \
    cmake \
    git \
    brotli \
    bc \
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

# Build gl4es--this is a dependency for Qwasm's WebGL renderer
# See: https://github.com/ptitSeb/gl4es/blob/master/COMPILE.md#emscripten
RUN git clone https://github.com/ptitSeb/gl4es.git $GL4ES_DIR
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
# this applies to both the software-rendered and WebGL builds
WORKDIR $QWASM_DIR/WinQuake

COPY id1 ./id1/

# Build Software-Rendered version; clean afterwards to prepare for next build
RUN . $EMSDK_DIR/emsdk_env.sh && \
    make -f Makefile.emscripten && \
    mkdir -p release/soft && \
    mv index.html index.js index.wasm index.data release/soft/ && \
    make -f Makefile.emscripten clean

# Build WebGL version
RUN . $EMSDK_DIR/emsdk_env.sh && \
    make -f Makefile.emscripten GL4ES_PATH=$GL4ES_DIR && \
    mkdir -p release/gl && \
    mv index.html index.js index.wasm index.data release/gl/

COPY compress.sh .
RUN chmod +x compress.sh && \
    find release -type f \( -name "*.html" -o -name "*.js" -o -name "*.wasm" -o -name "*.data" \) -print0 | \
    xargs -0 -P "$(nproc)" -I {} ./compress.sh "{}"