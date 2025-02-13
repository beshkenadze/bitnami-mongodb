#!/bin/bash
set -e

# Build minideb:trixie base image
docker build -t minideb-builder -f 8.0/minideb-trixie-build.Dockerfile .
docker run --rm --privileged minideb-builder | docker import - bitnami/minideb:trixie

# Clean up
docker rmi minideb-builder