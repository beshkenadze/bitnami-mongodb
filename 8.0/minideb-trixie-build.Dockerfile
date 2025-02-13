FROM debian:trixie-slim

WORKDIR /

COPY minideb/mkimage /mkimage
COPY minideb/pre-build.sh /pre-build.sh
COPY minideb/debootstrap/trixie /debootstrap-trixie
COPY minideb/buildone /buildone

RUN chmod +x /mkimage /pre-build.sh /buildone && \
    apt-get update && apt-get install -y \
    debootstrap \
    curl \
    ca-certificates \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN /pre-build.sh && /buildone trixie /debootstrap-trixie

CMD ["/mkimage"]

