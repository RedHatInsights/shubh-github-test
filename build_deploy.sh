#!/bin/bash

set -exv

IMAGE_DEFAULT="quay.io/cloudservices/rhsm-auto-registration-listener"
# If not running in cicd and developer wants image somewhere else, use that.
# Just export IMAGE_DEV to the appropriate quay.io location
IMAGE="${IMAGE_DEV:-$IMAGE_DEFAULT}"
IMAGE_TAG=$(git rev-parse --short=7 HEAD)

if [[ -z "$QUAY_USER" || -z "$QUAY_TOKEN" ]]; then
    echo "QUAY_USER and QUAY_TOKEN must be set"
    exit 1
fi

DOCKER_CONF="$PWD/.podman"
mkdir -p "$DOCKER_CONF"
podman --config="$DOCKER_CONF" login -u="$QUAY_USER" -p="$QUAY_TOKEN" quay.io
podman --config="$DOCKER_CONF" build -f Dockerfile -t "${IMAGE}:${IMAGE_TAG}" .
podman --config="$DOCKER_CONF" tag "${IMAGE}:${IMAGE_TAG}" "${IMAGE}:latest"
podman --config="$DOCKER_CONF" push "${IMAGE}:${IMAGE_TAG}"
podman --config="$DOCKER_CONF"t push "${IMAGE}:latest"
