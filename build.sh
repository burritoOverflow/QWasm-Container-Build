#!/usr/bin/env bash

set -e

IMAGE_NAME="qwasm-build"
DIST_DIR="$(pwd)/dist"

if [ ! -d "id1" ]; then
    echo "Error: 'id1' directory not found." >&2
    exit 1
fi

podman build -t "${IMAGE_NAME}" .
CID=$(podman create "${IMAGE_NAME}")

cleanup() {
    echo "Removing temporary container ${CID}"
    podman rm "${CID}"
}
trap cleanup EXIT

echo "Copying build assets to ${DIST_DIR}"
mkdir -p "${DIST_DIR}"

for f in index.html index.js index.wasm index.data; do
    podman cp "${CID}:/opt/quake-wasm/WinQuake/${f}" "${DIST_DIR}/"
    podman cp "${CID}:/opt/quake-wasm/WinQuake/${f}.gz" "${DIST_DIR}/"
    podman cp "${CID}:/opt/quake-wasm/WinQuake/${f}.br" "${DIST_DIR}/"
done

echo "Build complete. Assets are in ${DIST_DIR}"
ls -l "${DIST_DIR}"