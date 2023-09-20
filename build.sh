#!/usr/bin/env bash
set -eo pipefail

export PYTHON_VERSION='3.12.0rc3'
export IMAGE_NAME='mr0grog/circle-python-pre'

echo "=== Building Image for Python ${PYTHON_VERSION} ==="

# Multi-platform builds must be pushed directly and are not support in local
# Docker. See https://github.com/docker/roadmap/issues/371
platform_and_push='--load'
if [ "${1}" = 'push' ]; then
    echo '--- Building for multiple platforms and pushing to Docker Hub --'
    platform_and_push='--platform=linux/amd64,linux/arm64 --push'
fi

keep_builder="${BUILDER_NAME}"
if [ -z "${BUILDER_NAME}" ]; then
    echo '--- Creating new builder instance --'
    docker context create circle || true
    export BUILDER_NAME=$(docker buildx create circle)
fi
echo "builder: ${BUILDER_NAME}"
docker buildx use "${BUILDER_NAME}"

docker run --privileged multiarch/qemu-user-static:latest --reset -p yes --credential yes
docker buildx build \
    $platform_and_push \
    --tag "${IMAGE_NAME}:${PYTHON_VERSION}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
    .

if [ -z "${keep_builder}" ]; then
    echo "--- Deleting temporary builder instance ${BUILDER_NAME} --"
    docker buildx rm "${BUILDER_NAME}"
fi
