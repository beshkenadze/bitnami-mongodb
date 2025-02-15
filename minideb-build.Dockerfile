ARG DIST=trixie
FROM debian:${DIST}-slim

ENV DIST=${DIST}

# Copy build scripts
COPY minideb/mkimage /usr/local/bin/mkimage
COPY minideb/buildone /usr/local/bin/buildone
COPY minideb/debootstrap/${DIST} /usr/share/debootstrap/scripts/${DIST}

# Install required packages and verify DIST value
RUN echo "Building for DIST=${DIST}" && \
    apt-get update && apt-get install -y \
    debootstrap \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /usr/local/bin/mkimage /usr/local/bin/buildone

WORKDIR /build

# Use JSON form for CMD to handle signals properly
CMD ["sh", "-c", "buildone $DIST"]