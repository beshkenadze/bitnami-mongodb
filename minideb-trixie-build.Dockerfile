FROM debian:trixie-slim

ARG DIST=trixie
ENV DIST=${DIST}

# Copy build scripts
COPY mkimage /usr/local/bin/mkimage
COPY buildone /usr/local/bin/buildone
COPY debootstrap/${DIST} /usr/share/debootstrap/scripts/${DIST}

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