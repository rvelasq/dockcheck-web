#!/usr/bin/env bash

set -e

if [ -z "$3" ]; then
    echo "provide 3 digits to represent semver"
    exit 1
fi;


GITHUB_USER=rvelasq

echo "* logging in"
echo $CR_PAT | docker login ghcr.io -u $GITHUB_USER --password-stdin

echo "* building images"
docker build --platform linux/amd64 \
    -t ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64   \
    --build-arg ARCH=linux/amd64 \
    --build-arg DOCKCHECK_VERSION=0.5.8.0 \
    --build-arg DCW_VERSION=$1.$2.$3 .

docker build --platform linux/arm64/v8 \
    -t ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8 \
    --build-arg ARCH=linux/arm64 \
    --build-arg DOCKCHECK_VERSION=0.5.8.0 \
    --build-arg DCW_VERSION=$1.$2.$3 .

