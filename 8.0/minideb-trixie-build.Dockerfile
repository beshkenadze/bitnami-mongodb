FROM debian:trixie-slim

WORKDIR /

COPY mkimage /mkimage
COPY pre-build.sh /pre-build.sh
COPY debootstrap/trixie /debootstrap-trixie

RUN apt-get update && apt-get install -y \
    debootstrap \
    curl \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN /pre-build.sh && /buildone trixie /debootstrap-trixie

CMD ["/mkimage"]

