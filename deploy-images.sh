set -e

if [ -z "$3" ]; then
    echo "provide 3 digits to represent semver"
    exit 1
fi;

GITHUB_USER=rvelasq

echo "* logging in"
echo $CR_PAT | docker login ghcr.io -u $GITHUB_USER --password-stdin


echo "* tagging versions"
docker tag ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 ghcr.io/$GITHUB_USER/dockcheck-web:$1-amd64 
docker tag ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2-amd64 
docker tag ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3-amd64 
docker tag ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8 ghcr.io/$GITHUB_USER/dockcheck-web:$1-arm64v8 
docker tag ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8 ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2-arm64v8 
docker tag ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8 ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3-arm64v8 

echo "* pushing images"
docker push ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3-amd64 
docker push ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2-amd64 
docker push ghcr.io/$GITHUB_USER/dockcheck-web:$1-amd64 
docker push ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 

docker push ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3-arm64v8 
docker push ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2-arm64v8 
docker push ghcr.io/$GITHUB_USER/dockcheck-web:$1-arm64v8 
docker push ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8 

echo "* removing local manifests"
docker manifest rm ghcr.io/$GITHUB_USER/dockcheck-web:latest || true
docker manifest rm ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3  || true
docker manifest rm ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2  || true
docker manifest rm ghcr.io/$GITHUB_USER/dockcheck-web:$1  || true

echo "* creating manifests"
docker manifest create \
ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3 \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8

docker manifest create \
ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2 \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8

docker manifest create \
ghcr.io/$GITHUB_USER/dockcheck-web:$1 \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8

docker manifest create \
ghcr.io/$GITHUB_USER/dockcheck-web:latest \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-amd64 \
--amend ghcr.io/$GITHUB_USER/dockcheck-web:latest-arm64v8

echo "* pushing manifests"
docker manifest push --purge ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2.$3
docker manifest push --purge ghcr.io/$GITHUB_USER/dockcheck-web:$1.$2
docker manifest push --purge ghcr.io/$GITHUB_USER/dockcheck-web:$1
docker manifest push --purge ghcr.io/$GITHUB_USER/dockcheck-web:latest