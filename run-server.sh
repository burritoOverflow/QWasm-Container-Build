#!/usr/bin/env bash

set -e

IMAGE_NAME="qwasm-nginx"
CONTAINER_NAME="qwasm-server"
PORT="${PORT:-8080}"

# location of the build assets for Qwasm
DIST_DIR="$(pwd)/dist"

# use existing image by default
FORCE_REBUILD=0

if [ ! -d "${DIST_DIR}" ]; then
    echo "Error: '${DIST_DIR}' directory not found." >&2
    echo "Run ./build.sh first to generate the assets." >&2
    exit 1
fi

# always rebuild the image if --rebuild longopt is present
for arg in "$@"; do
    if [ "$arg" == "--rebuild" ]; then
        echo "Forcing nginx image rebuild..."
        FORCE_REBUILD=1
    fi
done

if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping and removing existing container..."
    podman stop "${CONTAINER_NAME}" >/dev/null
    podman rm "${CONTAINER_NAME}" >/dev/null
fi

if [ "$FORCE_REBUILD" -eq 1 ] || ! podman image exists "${IMAGE_NAME}"; then
    echo "Building nginx image..."
    podman build -f Dockerfile.nginx -t "${IMAGE_NAME}" .
else
    echo "Using existing nginx image '${IMAGE_NAME}'."
fi

# NOTE: this is also done in the build script, but it's more likely
# that files could be changed between builds, so we do it again here.
echo "Copying landing page assets..."
cp index.html "${DIST_DIR}/"
cp style.css "${DIST_DIR}/"

echo "Starting nginx container on port ${PORT}..."
podman run -d \
    --name "${CONTAINER_NAME}" \
    -p "${PORT}:8080" \
    -v "${DIST_DIR}:/usr/share/nginx/html:ro,z" \
    "${IMAGE_NAME}"

echo "Server is running. View logs with: podman logs -f ${CONTAINER_NAME}"