#!/usr/bin/env bash
set -eo pipefail

ALL_PLATFORMS='linux/amd64,linux/arm64'
IMAGE_NAME='test/circle-python-pre'
PLATFORM='local'
FLAGS=''

HELP="
Usage: build-image.sh PYTHON_VERSION [PLATFORM [FLAGS [NAME]]]

Example build-image.sh 3.13.0b4 linux/arm64 '--enable-optimizations' 'test/circle-python-pre'
"

if [[ "$@" == *"--help"* ]]; then
    echo "${HELP}"
    exit 0
fi

PYTHON_VERSION="${1}"

if [ -n "${2}" ]; then
    PLATFORM="${2}"
    if [[ "${PLATFORM}" == 'multiplatform' ]]; then
        PLATFORM="${ALL_PLATFORMS}"
    fi
fi

if [[ -n "${3}" ]] && [[ "${3}" != "noflags" ]]; then
    FLAGS="${3}"
fi

echo "Options:"
echo "  PYTHON_VERSION: '${PYTHON_VERSION}'"
echo "  IMAGE_NAME: '${IMAGE_NAME}'"
echo "  PLATFORM: '${PLATFORM}'"
echo "  FLAGS: '${FLAGS}'"
exit 0

# In CI, don't rewrite lines. We want a clean, complete log so we see things
# printed by the image's RUN steps.
if [ -n "${CI}" ]; then
    export BUILDKIT_PROGRESS='plain'
fi

echo "=== Setting Up Docker Context ==="

# Set up a custom build context using the containerd driver so we can store
# multiplatform images in order to test before publishing (otherwise you must
# publish them as part of the build).
docker context create circle || true
docker context use circle
docker buildx create --name circle-builder --driver docker-container circle || true
docker buildx use circle-builder

if [[ "${PLATFORM}" != "local" ]]; then
    echo 'Setting up QEMU...'
    # Enable `sudo` to work inside a multi-architecture Docker build. See:
    #   https://github.com/docker/buildx/issues/1335
    #   https://github.com/multiarch/alpine/issues/32#issuecomment-604521491
    #   https://github.com/multiarch/qemu-user-static/issues/17
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes
fi

echo ""
echo "=== Building Image for Python ${PYTHON_VERSION} ==="

docker buildx build \
    --platform="${PLATFORM}" \
    --tag "${IMAGE_FULL_NAME}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
    --build-arg "ARG_PYTHON_FLAGS=${FLAGS}" \
    --load \
    .
