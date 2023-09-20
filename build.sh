#!/usr/bin/env bash
set -eo pipefail

export PYTHON_VERSION='3.12.0rc3'
export IMAGE_NAME='mr0grog/circle-python-pre'

echo "=== Building Image for Python ${PYTHON_VERSION} ==="
docker context create circle || true
docker buildx create --use circle
docker buildx build \
    --platform=linux/amd64,linux/arm64 \
    --tag "${IMAGE_NAME}:${PYTHON_VERSION}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
    --load \
    .

if [ "${1}" = 'push' ]; then
    echo "=== Pushing ${IMAGE_NAME}:${PYTHON_VERSION} to Docker Hub ==="
    docker push "${IMAGE_NAME}:${PYTHON_VERSION}"
fi
