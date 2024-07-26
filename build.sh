#!/usr/bin/env bash
set -eo pipefail

IMAGE_NAME='mr0grog/circle-python-pre'
PLATFORM='local'
PUBLISH=''

while (( "$#" )); do
    case "$1" in
        --multiplatform)
            PLATFORM='linux/amd64,linux/arm64'
            shift
            ;;
        --publish)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                PUBLISH="${2}"
                if [ "${PUBLISH}" != *":"* ]; then
                    echo '--publish value must be formatted like "NAME:TAG"'
                    exit 1
                fi
                shift 2
            else
                PUBLISH="yes"
                shift
            fi
            ;;
        -*|--*=) # unsupported flags
            echo "Error: Unsupported flag '${1}'" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done
# Reset args to just the positionals.
eval set -- "$PARAMS"

PYTHON_VERSION="${1}"
IMAGE_NAME='mr0grog/circle-python-pre'
IMAGE_FULL_NAME="${IMAGE_NAME}:${PYTHON_VERSION}"

if [ "${PUBLISH}" == "yes" ]; then
    PUBLISH="${IMAGE_FULL_NAME}"
fi

# # El-cheapo arg reading. Should really be a loop and a case.
# if [[ $@ == *'--multiplatform'* ]]; then
#     export PLATFORM='linux/amd64,linux/arm64'
# fi

echo "OPTIONS:"
echo "  PYTHON_VERSION: '${PYTHON_VERSION}'"
echo "  PLATFORM: '${PLATFORM}'"
echo "  IMAGE_NAME: '${IMAGE_NAME}'"
echo "  IMAGE_FULL_NAME: '${IMAGE_FULL_NAME}'"
echo "  PUBLISH: '${PUBLISH}'"
exit 0

# In CI, don't rewrite lines. We want a clean, complete log so we see things
# printed by the image's RUN steps.
if [ -n "${CI}" ]; then
    export BUILDKIT_PROGRESS='plain'
fi

echo "=== Building Image for Python ${PYTHON_VERSION} ==="

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
    --platform="${PLATFORM}" \
    --tag "${IMAGE_FULL_NAME}" \
    --build-arg "ARG_PYTHON_VERSION=${PYTHON_VERSION}" \
    --load \
    .

echo ""
echo "=== Testing Image ==="

# The "t" suffix (e.g. "3.130b4t") indicates this is the the given version with
# free-threading (no GIL) turned on. The actual version of Python it represents
# is the build version without the suffix (e.g. "3.13.0b4").
EXPECTED_VERSION="${PYTHON_VERSION%t}"
ACTUAL_VERSION="$(docker run --rm "${IMAGE_FULL_NAME}" python --version)"
echo "'python --version' > '${ACTUAL_VERSION}'"
if [ "${ACTUAL_VERSION}" != "Python ${EXPECTED_VERSION}" ]; then
    echo "Did not find expected Python version (${EXPECTED_VERSION})!"
    exit 1
fi

EXPECTED_OUTPUT='Hello from Python'
ACTUAL_OUTPUT="$(docker run --rm "${IMAGE_FULL_NAME}" python -c "print('${EXPECTED_OUTPUT}')")"
echo "Python output: '${ACTUAL_OUTPUT}'"
if [ "${ACTUAL_OUTPUT}" != "${EXPECTED_OUTPUT}" ]; then
    echo 'Did not get expected output!'
    exit 1
fi

if [ -n "${PUBLISH}" ]; then
    echo ""
    echo "=== Publishing Image '${PUBLISH}' ==="

    docker image tag "${IMAGE_FULL_NAME}" "${PUBLISH}"
    docker push "${PUBLISH}"
fi
