#!/usr/bin/env bash

set -e

IMAGE_NAME="qwasm2-build"
# output directory on host
DIST_DIR="$(pwd)/dist"
# source directory inside the container
QWASM_CONTAINER_DIR="/opt/qwasm2"

CLEAN=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --rebuild)
            # force rebuild of the container image
            REBUILD=true
            shift
            ;;
        --parallel)
            PARALLEL=true # perform the build(s) in parallel--passed to `make` for both gl4es and qwasm2.
            shift
            ;;
        --dest)
            # we only want relative 'dist' directories here
            if [[ "$2" = /* ]]; then
                echo "Error: --dest must be a relative path, not absolute" >&2
                exit 1
            fi
            DIST_DIR="$(pwd)/$2"
            echo "Setting output directory to '${DIST_DIR}'"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--clean] [--dest <directory>]" >&2
            exit 1
            ;;
    esac
done

# clean previous build artifacts; perhaps this should be the default?
if [[ "$CLEAN" == true ]]; then
    # WARN: this cleans the directory provided via the arg and will leave older
    # directories intact if a different `--dest`` is provided
    # than was used previously.
    echo "Cleaning '${DIST_DIR}'"
    rm -rf "${DIST_DIR}"
fi

# we require .pak files to build properly, expected at src root
if ! compgen -G "*.pak" > /dev/null; then
    echo "Error: No .pak files found in current directory." >&2
    exit 1
fi

BUILD_FLAGS=()
if [[ "$REBUILD" == true ]]; then
    BUILD_FLAGS+=(--no-cache)
fi
if [[ "$PARALLEL" == true ]]; then
    BUILD_FLAGS+=(--build-arg PARALLEL=1)
fi

podman build "${BUILD_FLAGS[@]}" -t "${IMAGE_NAME}" .
CID=$(podman create "${IMAGE_NAME}")

cleanup() {
    echo "Removing temporary container with id: '${CID}'"
    podman rm "${CID}"
}
trap cleanup EXIT

echo "Copying build assets to ${DIST_DIR}"
mkdir -p "${DIST_DIR}"
podman cp "${CID}:${QWASM_CONTAINER_DIR}/release/." "${DIST_DIR}/"

echo "Build complete. Assets are in ${DIST_DIR}"
ls -l "${DIST_DIR}"