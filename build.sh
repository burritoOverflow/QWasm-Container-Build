#!/usr/bin/env bash

set -e

IMAGE_NAME="qwasm-build"
DIST_DIR="$(pwd)/dist"

if [ ! -d "id1" ]; then
    echo "Error: 'id1' directory not found." >&2
    exit 1
fi

podman build -t "${IMAGE_NAME}" .

# clean-slate for the container name
podman rm -f "${IMAGE_NAME}-container" 2>/dev/null || true

CID=$(podman create --name "${IMAGE_NAME}-container" "${IMAGE_NAME}")

cleanup() {
    echo "Removing temporary container ${CID}"
    podman rm "${CID}"
}
trap cleanup EXIT

echo "Copying build assets to ${DIST_DIR}"

# copy assets from each build variant to each of our target directories
mkdir -p "${DIST_DIR}/soft"
mkdir -p "${DIST_DIR}/gl"

for variant in soft gl; do
    for f in index.html index.js index.wasm index.data; do
        podman cp "${CID}:/opt/quake-wasm/WinQuake/release/${variant}/${f}" "${DIST_DIR}/${variant}/"
        podman cp "${CID}:/opt/quake-wasm/WinQuake/release/${variant}/${f}.gz" "${DIST_DIR}/${variant}/"
        podman cp "${CID}:/opt/quake-wasm/WinQuake/release/${variant}/${f}.br" "${DIST_DIR}/${variant}/"
    done
done

# for the 'landing page'
echo "Copying static site assets..."
cp index.html "${DIST_DIR}/"
cp style.css "${DIST_DIR}/"

echo "Build complete. Assets are in ${DIST_DIR}"
ls -ltsh "${DIST_DIR}"