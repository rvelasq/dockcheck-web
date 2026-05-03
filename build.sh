#!/usr/bin/env bash

set -e

if [ -z "$3" ]; then
    echo "provide 3 digits to represent semver"
    exit 1
fi;


GITHUB_USER=rvelasq


echo "* building image"

docker system prune --all --volumes --force
docker buildx prune --force 

docker buildx build --platform linux/amd64,linux/arm64 \
    --no-cache \
    --tag ghcr.io/$GITHUB_USER/dockcheck-web:latest \
    --build-arg DCW_VERSION=$1.$2.$3 .

docker tag ghcr.io/$GITHUB_USER/dockcheck-web:latest ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3


# echo "* logging in to github"
echo $CR_PAT | docker login ghcr.io -u $GITHUB_USER --password-stdin

# push to  ghcr.io
docker push ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3
docker push ghcr.io/$GITHUB_USER/dockcheck-web:latest

