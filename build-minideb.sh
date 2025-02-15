#!/bin/sh
set -e
REGISTRY="ghcr.io"
REPOSITORY="beshkenadze/bitnami-mongodb"
AUTHOR="beshkenadze"
  
# Build minideb images for both bookworm and trixie
for DIST in bookworm trixie; do
  echo "Building minideb:${DIST} base image..."
  # Build the image with proper tags
  docker build \
    -t ${REGISTRY}/${REPOSITORY}/minideb:${DIST} \
    -t ${REGISTRY}/${REPOSITORY}/minideb:${DIST}-latest \
    --build-arg DIST=${DIST} \
    -f minideb-build.Dockerfile \
    .

  # Push both tags to the registry
  echo "Pushing ${DIST} images to the registry..."
  docker push ${REGISTRY}/${REPOSITORY}/minideb:${DIST}
  docker push ${REGISTRY}/${REPOSITORY}/minideb:${DIST}-latest
  
  echo "Build and push completed successfully for ${DIST}!"
done