#!/usr/bin/env bash
set -eo pipefail

export PYTHON_VERSION="${1}"
export IMAGE_NAME='mr0grog/circle-python-pre-test'

# In CI, don't rewrite lines. We want a clean, complete log so we see things
# printed by the image's RUN steps.
if [ -n "${CI}" ]; then
    export BUILDKIT_PROGRESS='plain'
fi

echo "=== Building Image for Python ${PYTHON_VERSION} ==="

# Multi-platform builds must be pushed directly and are not supported in local
# Docker. See https://github.com/docker/roadmap/issues/371
platform_and_push='--load'
if [ "${2}" = 'push' ]; then
    echo '--- Building for multiple platforms and pushing to Docker Hub --'
    platform_and_push="--output 'push-by-digest=true,type=image,push=true'"
fi

docker context create circle || true
docker context use circle
docker buildx create --name circle-builder circle || true
docker buildx use circle-builder

# # Enable `sudo` to work inside a multi-architecture Docker build. See:
# #   https://github.com/docker/buildx/issues/1335
# #   https://github.com/multiarch/alpine/issues/32#issuecomment-604521491
# #   https://github.com/multiarch/qemu-user-static/issues/17
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes

# docker buildx build \
#     $platform_and_push \
#     --tag "${IMAGE_NAME}:${PYTHON_VERSION}" \
#     --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
#     .
BUILD_ERROR=$(docker buildx build \
    $platform_and_push \
    --tag "${IMAGE_NAME}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
    . \
    > build-log.txt 2>&1 \
    || echo $?
)

cat build-log.txt
if [[ -n "${BUILD_ERROR}" ]]; then
    exit "${BUILD_ERROR}"
fi

echo '--- Digest ---'
IMAGE_DIGEST=$(grep 'exporting manifest list sha256:' build-log.txt | sed -e 's/^.*\(sha256:[0-9a-f]*\).*/\1/')
echo "IMAGE_DIGEST=${IMAGE_DIGEST}" >> $GITHUB_ENV
echo "${IMAGE_DIGEST}"

mkdir -p ./digests
touch "./digests/${IMAGE_DIGEST#sha256:}"
