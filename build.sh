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

docker context create circle || true
docker buildx create --use circle
docker buildx build \
    $platform_and_push \
    --tag "${IMAGE_NAME}:${PYTHON_VERSION}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
    .
