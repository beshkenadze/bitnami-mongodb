#!/bin/sh
set -e

# Common variables
REGISTRY="ghcr.io"
REPOSITORY="beshkenadze/bitnami-mongodb"
AUTHOR="beshkenadze"
IMAGE_NAME="ghcr.io/beshkenadze/bitnami-mongodb/mongodb"

# Configuration for different MongoDB versions
config_6="debian-12:6.0.20:bookworm"
config_8="debian-13:8.0.0:trixie"

# Build all versions or specific versions if provided
if [ $# -gt 0 ]; then
    versions="$@"
else
    versions="6.0 8.0"
fi

for MONGO_MAJOR in $versions; do
    case "$MONGO_MAJOR" in
        "6.0") config="$config_6" ;;
        "8.0") config="$config_8" ;;
        *) echo "Unsupported version: $MONGO_MAJOR"; continue ;;
    esac
    
    DEBIAN_VERSION=$(echo "$config" | cut -d: -f1)
    MONGO_VERSION=$(echo "$config" | cut -d: -f2)
    MINIDEB_DIST=$(echo "$config" | cut -d: -f3)
    BUILD_DIR="${MONGO_MAJOR}/${DEBIAN_VERSION}"
    
    echo "Building MongoDB ${MONGO_MAJOR} (${MONGO_VERSION}) for ${DEBIAN_VERSION}..."
    
    # Navigate to the build directory
    # cd "$(dirname "$0")/${BUILD_DIR}"
    
    # Build the Docker image
    docker build \
      --no-cache \
      --build-arg TARGETARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') \
      --build-arg MONGO_VERSION="${MONGO_VERSION}" \
      --build-arg MONGO_MAJOR="${MONGO_MAJOR}" \
      --build-arg REGISTRY="${REGISTRY}" \
      --build-arg REPOSITORY="${REPOSITORY}" \
      --build-arg MINIDEB_DIST="${MINIDEB_DIST}" \
      --build-arg AUTHOR="${AUTHOR}" \
      -t "${IMAGE_NAME}:${MONGO_MAJOR}" \
      ${BUILD_DIR}
    
    # Push the image to the registry
    echo "Pushing ${IMAGE_NAME}:${MONGO_MAJOR} to the registry..."
    docker push "${IMAGE_NAME}:${MONGO_MAJOR}"
    
    # If this is version 8.0, tag it as latest
    if [ "${MONGO_MAJOR}" = "8.0" ]; then
        docker tag "${IMAGE_NAME}:${MONGO_MAJOR}" "${IMAGE_NAME}:latest"
        docker push "${IMAGE_NAME}:latest"
    fi
    
    # Go back to the original directory
    cd "$(dirname "$0")"
    
    echo "Build completed successfully for MongoDB ${MONGO_MAJOR}!"
done

echo "All builds completed!"
echo "You can run the images with: docker run -d -p 27017:27017 ${IMAGE_NAME}:<version>"