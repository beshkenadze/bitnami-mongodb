#!/bin/bash
set -e

# Build minideb:trixie base image
docker build \
  -t minideb-builder \
  -f minideb-build.Dockerfile \
  .