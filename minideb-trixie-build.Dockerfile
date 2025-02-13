FROM debian:trixie-slim

ARG DIST=trixie
ENV DIST=${DIST}

# Copy build scripts
COPY 8.0/minideb/mkimage /usr/local/bin/mkimage
COPY 8.0/minideb/buildone /usr/local/bin/buildone
COPY 8.0/minideb/debootstrap/${DIST} /usr/share/debootstrap/scripts/${DIST}

# Install required packages
RUN apt-get update && apt-get install -y \
    debootstrap \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/local/bin/mkimage /usr/local/bin/buildone

WORKDIR /build

# Run build
CMD ["buildone", "trixie"]