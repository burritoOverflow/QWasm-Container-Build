#!/usr/bin/env bash

set -e

IMAGE_NAME="qwasm-nginx"
CONTAINER_NAME="qwasm-server"
PORT="${PORT:-8080}"
DIST_DIR="$(pwd)/dist"

if [ ! -d "${DIST_DIR}" ]; then
    echo "Error: '${DIST_DIR}' directory not found." >&2
    echo "Run ./build.sh first to generate the assets." >&2
    exit 1
fi

if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping existing container..."
    podman stop "${CONTAINER_NAME}" || true
    podman rm "${CONTAINER_NAME}" || true
fi

echo "Building nginx image..."
podman build -f Dockerfile.nginx -t "${IMAGE_NAME}" .

echo "Starting nginx container on port ${PORT}..."
podman run -d \
    --name "${CONTAINER_NAME}" \
    -p "${PORT}:8080" \
    "${IMAGE_NAME}"
