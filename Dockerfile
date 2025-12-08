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
ENV QWASM2_DIR=/opt/qwasm2
ENV GL4ES_DIR=/opt/gl4es

# set to 1 to enable parallel builds for both gl4es and qwasm2
ARG PARALLEL=0
# compress the build artifacts with gzip and brotli
ARG COMPRESS=0

RUN git clone https://github.com/emscripten-core/emsdk.git $EMSDK_DIR

# set up emsdk
WORKDIR $EMSDK_DIR
RUN ./emsdk install latest
RUN ./emsdk activate latest

RUN git clone https://github.com/ptitSeb/gl4es.git $GL4ES_DIR

# build gl4es (with -fPIC) as per: https://github.com/GMH-Code/Qwasm2?tab=readme-ov-file#how-to-build-on-linux-for-webassembly
WORKDIR $GL4ES_DIR
RUN . $EMSDK_DIR/emsdk_env.sh && \
    emcmake cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DNOX11=ON \
        -DNOEGL=ON \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DSTATICLIB=ON && \
    make VERBOSE=1 -C build $([ "$PARALLEL" = "1" ] && echo "-j$(nproc)")

# clone Qwasm2
RUN git clone https://github.com/GMH-Code/Qwasm2.git $QWASM2_DIR

WORKDIR $QWASM2_DIR

# populate the required pak files to the source tree. See docs ref'd above.
COPY *.pak wasm/baseq2/

RUN . $EMSDK_DIR/emsdk_env.sh && \
    emmake make GL4ES_PATH=$GL4ES_DIR VERBOSE=1 $([ "$PARALLEL" = "1" ] && echo "-j$(nproc)")

WORKDIR $QWASM2_DIR/release

COPY compress.sh /compress.sh

RUN  if [ "$COMPRESS" == "1" ]; then \
    chmod +x /compress.sh && \
    ls -1 . && \
    find . -type f \( -name "*.html" -o -name "*.js" -o -name "*.wasm" -o -name "*.data" \) -print0 | \
    xargs -0 -P "$(nproc)" -I {} /compress.sh "{}"; \
    fi

RUN ls -lRh .