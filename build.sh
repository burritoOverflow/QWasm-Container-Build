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
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--clean]" >&2
            exit 1
            ;;
    esac
done

# clean previous build artifacts; perhaps this should be the default?
if [[ "$CLEAN" == true ]]; then
    echo "Cleaning '${DIST_DIR}'"
    rm -rf "${DIST_DIR}"
fi

# we require .pak files to build properly, expected at src root
if ! compgen -G "*.pak" > /dev/null; then
    echo "Error: No .pak files found in current directory." >&2
    exit 1
fi

podman build -t "${IMAGE_NAME}" .
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