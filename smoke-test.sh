#!/usr/bin/env bash
set -eo pipefail

PYTHON_VERSION="${1}"
DOCKER_IMAGE="${2}"

# Run a command in either the specified image or the local shell.
run () {
    COMMAND="${1}"
    if [ -n "${DOCKER_IMAGE}" ]; then
        # docker run --rm "${DOCKER_IMAGE}" $COMMAND
        eval "docker run --rm '${DOCKER_IMAGE}' ${COMMAND}"
    else
        eval "$COMMAND"
    fi
}

if [ -n "${DOCKER_IMAGE}" ]; then
    FRIENDLY_TARGET="image ${DOCKER_IMAGE}"
else
    FRIENDLY_TARGET='current shell'
fi

echo "=== Testing ${FRIENDLY_TARGET} ==="

# The "t" suffix (e.g. "3.130b4t") indicates this is the the given version with
# free-threading (no GIL) turned on. The actual version of Python it represents
# is the build version without the suffix (e.g. "3.13.0b4").
EXPECTED_VERSION="${PYTHON_VERSION%t}"
ACTUAL_VERSION="$(run 'python --version')"
echo "'python --version' > '${ACTUAL_VERSION}'"
if [ "${ACTUAL_VERSION}" != "Python ${EXPECTED_VERSION}" ]; then
    echo "Did not find expected Python version (${EXPECTED_VERSION})!"
    exit 1
fi

EXPECTED_OUTPUT='Hello from Python'
ACTUAL_OUTPUT=$(run "python -c 'print(\"${EXPECTED_OUTPUT}\")'")
echo "Python output: '${ACTUAL_OUTPUT}'"
if [ "${ACTUAL_OUTPUT}" != "${EXPECTED_OUTPUT}" ]; then
    echo 'Did not get expected output!'
    exit 1
fi
