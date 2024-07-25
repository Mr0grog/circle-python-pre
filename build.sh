#!/usr/bin/env bash
set -eo pipefail

export PYTHON_VERSION='3.13.0b4t'
export IMAGE_NAME='mr0grog/circle-python-pre'

# In CI, don't rewrite lines. We want a clean, complete log so we see things
# printed by the image's RUN steps.
if [ -n "${CI}" ]; then
    export BUILDKIT_PROGRESS='plain'
fi

echo "=== Building Image for Python ${PYTHON_VERSION} ==="

# Multi-platform builds must be pushed directly and are not supported in local
# Docker. See https://github.com/docker/roadmap/issues/371
# platform_and_push='--load'
# if [ "${1}" = 'push' ]; then
#     echo '--- Building for multiple platforms and pushing to Docker Hub --'
#     platform_and_push='--platform=linux/amd64,linux/arm64 --push'
# fi
PLATFORMS='linux/amd64,linux/arm64'

docker context create circle || true
docker context use circle
docker buildx create --name circle-builder circle || true
docker buildx use circle-builder

# Enable `sudo` to work inside a multi-architecture Docker build. See:
#   https://github.com/docker/buildx/issues/1335
#   https://github.com/multiarch/alpine/issues/32#issuecomment-604521491
#   https://github.com/multiarch/qemu-user-static/issues/17
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes

docker buildx build \
    --platform="${PLATFORMS}" \
    --tag "${IMAGE_NAME}:${PYTHON_VERSION}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
    .

# Quick smoketest
echo 'This should print "Hello from Python":'
docker run --rm "${IMAGE_NAME}:${PYTHON_VERSION}" python -c 'print("Hello from Python")'
