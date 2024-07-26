#!/usr/bin/env bash
set -eo pipefail

export PYTHON_VERSION='3.13.0b4'
export PYTHON_BUILD='3.13.0b4t'
export IMAGE_NAME='mr0grog/circle-python-pre'

# In CI, don't rewrite lines. We want a clean, complete log so we see things
# printed by the image's RUN steps.
if [ -n "${CI}" ]; then
    export BUILDKIT_PROGRESS='plain'
fi

echo "=== Building Image for Python ${PYTHON_BUILD} ==="

# Multi-platform builds must be pushed directly and are not supported in local
# Docker. See https://github.com/docker/roadmap/issues/371
# platform_and_push='--load'
# if [ "${1}" = 'push' ]; then
#     echo '--- Building for multiple platforms and pushing to Docker Hub --'
#     platform_and_push='--platform=linux/amd64,linux/arm64 --push'
# fi

# Disabled temporarily
# PLATFORMS='--platform=linux/amd64,linux/arm64'
PLATFORMS=''

docker context create circle || true
docker context use circle
docker buildx create --name circle-builder --driver docker-container circle || true
docker buildx use circle-builder

# Enable `sudo` to work inside a multi-architecture Docker build. See:
#   https://github.com/docker/buildx/issues/1335
#   https://github.com/multiarch/alpine/issues/32#issuecomment-604521491
#   https://github.com/multiarch/qemu-user-static/issues/17
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes

docker buildx build \
    $PLATFORMS \
    --tag "${IMAGE_NAME}:${PYTHON_BUILD}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_BUILD}" \
    .

echo "=== Testing Image ==="

ACTUAL_VERSION="$(docker run --rm "${IMAGE_NAME}:${PYTHON_BUILD}" python --version)"
echo "'python --version' > '${ACTUAL_VERSION}'"
if [ "${ACTUAL_VERSION}" != "Python ${PYTHON_VERSION}" ]; then
    echo "Did not find expected Python version (${PYTHON_VERSION})!"
    exit 1
fi

EXPECTED_OUTPUT='Hello from Python'
ACTUAL_OUTPUT="$(docker run --rm "${IMAGE_NAME}:${PYTHON_BUILD}" python -c "print('${EXPECTED_OUTPUT}')")"
echo "Python output: '${ACTUAL_OUTPUT}'"
if [ "${ACTUAL_OUTPUT}" != "${EXPECTED_OUTPUT}" ]; then
    echo 'Did not get expected output!'
    exit 1
fi
