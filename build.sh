#!/usr/bin/env bash

set -e

IMAGE_NAME="ioquake3-build"

# output directory on host
DIST_DIR="$(pwd)/dist"

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
        --dest)
            # we only want relative 'dist' directories here
            if [[ "$2" = /* ]]; then
                echo "Error: --dest must be a relative path, not absolute" >&2
                exit 1
            fi
            DIST_DIR="$(pwd)/$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--clean] [--rebuild] [--dest <directory>]" >&2
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

# we require .pk3 files to build properly,
# expected in a 'baseq3' directory at the source root
if ! compgen -G "baseq3/*.pk3" > /dev/null; then
    echo "Error: No .pk3 files found in 'baseq3' directory." >&2
    echo "Please ensure the 'baseq3' directory exists and contains the required .pk3 files." >&2
    exit 1
fi

BUILD_FLAGS=()
if [[ "$REBUILD" == true ]]; then
    BUILD_FLAGS+=(--no-cache)
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

# source directory inside the container
IOQ3_CONTAINER_DIR="/opt/ioquake3"

# build directory is at build-wasm/Release
BUILD_DIR="${IOQ3_CONTAINER_DIR}/build-wasm/Release"

podman cp "${CID}:${BUILD_DIR}/." "${DIST_DIR}/"

echo "Build complete. Assets are in ${DIST_DIR}"
ls -l "${DIST_DIR}"