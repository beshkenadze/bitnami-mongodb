# Copyright ${AUTHOR:-beshkenadze}. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0
# Use full GHCR path for minideb
ARG MINIDEB_DIST="bookworm"

FROM ${REGISTRY:-ghcr.io}/${REPOSITORY:-beshkenadze/bitnami-mongodb}/minideb:${MINIDEB_DIST:-bookworm}

ARG TARGETARCH
ARG AUTHOR="beshkenadze"

LABEL org.opencontainers.image.base.name="${REGISTRY:-ghcr.io}/${REPOSITORY:-beshkenadze/bitnami-mongodb}/minideb:${MINIDEB_DIST:-bookworm}" \
      org.opencontainers.image.created="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
      org.opencontainers.image.description="Application packaged by ${AUTHOR:-beshkenadze}" \
      org.opencontainers.image.documentation="https://github.com/${REPOSITORY:-beshkenadze/bitnami-mongodb}/README.md" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="${MONGO_VERSION:-6.0.1}-debian-${MINIDEB_DIST}-r$(date -u +%Y%m%d)" \
      org.opencontainers.image.source="https://github.com/${REPOSITORY:-beshkenadze/bitnami-mongodb}" \
      org.opencontainers.image.title="mongodb" \
      org.opencontainers.image.vendor="${AUTHOR:-beshkenadze}" \
      org.opencontainers.image.version="${MONGO_VERSION:-6.0.20}"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
# CHANGE: "mongodb-6.0.20-4-linux-${OS_ARCH}-debian-11" is removed from list because it is not available as arm64
# CHANGE: "mongodb-shell-2.1.4-0-linux-${OS_ARCH}-debian-11" removed because it will be built as part of mongodb image
# CHANGE: update package versions to match debian 12 compatibility
# libffi7 -> libffi8
# libldap-2.4-2 -> libldap-2.5-0
# libssl1.1 -> libssl3

RUN install_packages wget curl gnupg software-properties-common apt-transport-https lsb-release ca-certificates curl libbrotli1 libcom-err2 libcurl4 libffi8 libgcc-s1 libgcrypt20 libgmp10 libgnutls30 libgpg-error0 libgssapi-krb5-2 libhogweed6 libidn2-0 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libldap-2.5-0 liblzma5 libnettle8 libnghttp2-14 libp11-kit0 libpsl5 librtmp1 libsasl2-2 libssh2-1 libssl3 libtasn1-6 libunistring2 numactl procps zlib1g

#import the GPG key for the MongoDB repository
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc| gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg
# Add the MongoDB 6.0 repository to the system.

RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ ; \
    COMPONENTS=( \
      "yq-4.41.1-0-linux-${OS_ARCH}-debian-11" \
      "wait-for-port-1.0.7-8-linux-${OS_ARCH}-debian-11" \
      "render-template-1.0.6-8-linux-${OS_ARCH}-debian-11" \
    ) ; \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz.sha256" -O ; \
      fi ; \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" ; \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner --wildcards '*/files' ; \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done
RUN apt-get autoremove --purge -y curl && \
    apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN echo install global

# CHANGE: Install mongodb based on https://github.com/docker-library/mongo/blob/master/6.0/Dockerfile

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		jq \
		numactl \
		procps \
	; \
	rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root (https://github.com/tianon/gosu/releases)
ENV GOSU_VERSION=1.17
# grab "js-yaml" for parsing mongod's YAML config files (https://github.com/nodeca/js-yaml/releases)
ENV JSYAML_VERSION=3.13.1
ENV JSYAML_CHECKSUM=662e32319bdd378e91f67578e56a34954b0a2e33aca11d70ab9f4826af24b941

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		gnupg \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
# download/install gosu
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# download/install js-yaml
	mkdir -p /opt/js-yaml/; \
	wget -O /opt/js-yaml/js-yaml.tgz https://registry.npmjs.org/js-yaml/-/js-yaml-${JSYAML_VERSION}.tgz; \
	echo "$JSYAML_CHECKSUM */opt/js-yaml/js-yaml.tgz" | sha256sum -c -; \
	tar -xz --strip-components=1 -f /opt/js-yaml/js-yaml.tgz -C /opt/js-yaml package/dist/js-yaml.js package/package.json; \
	rm /opt/js-yaml/js-yaml.tgz; \
	ln -s /opt/js-yaml/dist/js-yaml.js /js-yaml.js; \
	\
# download/install MongoDB PGP keys
	export GNUPGHOME="$(mktemp -d)"; \
	wget -O KEYS 'https://pgp.mongodb.com/server-6.0.asc'; \
	gpg --batch --import KEYS; \
	mkdir -p /etc/apt/keyrings; \
	gpg --batch --export --armor '39BD841E4BE5FB195A65400E6A26B1AE64C3C388' > /etc/apt/keyrings/mongodb.asc; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" KEYS; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
# smoke test
	chmod +x /usr/local/bin/gosu; \
	gosu --version; \
	gosu nobody true

# Allow build-time overrides (eg. to build image with MongoDB Enterprise version)
# Options for MONGO_PACKAGE: mongodb-org OR mongodb-enterprise
# Options for MONGO_REPO: repo.mongodb.org OR repo.mongodb.com
# Example: docker build --build-arg MONGO_PACKAGE=mongodb-enterprise --build-arg MONGO_REPO=repo.mongodb.com .
ARG MONGO_PACKAGE=mongodb-org
ARG MONGO_REPO=repo.mongodb.org
ARG MONGO_MAJOR=6.0
ARG MONGO_VERSION=6.0.20

ENV MONGO_PACKAGE=${MONGO_PACKAGE} 
ENV MONGO_REPO=${MONGO_REPO}
ENV MONGO_MAJOR=${MONGO_MAJOR} 
ENV MONGO_VERSION=${MONGO_VERSION}
# bookworm is code name for Debian 12 since Debian 11 is not supported anymore
RUN echo "deb http://${MONGO_REPO}/apt/ubuntu jammy/${MONGO_PACKAGE}/${MONGO_MAJOR} multiverse" | tee /etc/apt/sources.list.d/${MONGO_PACKAGE}-${MONGO_MAJOR}.list
# ARM64 support
# RUN echo "deb [arch=arm64] http://${MONGO_REPO}/apt/debian bookworm/${MONGO_PACKAGE}/${MONGO_MAJOR} main" | tee -a /etc/apt/sources.list.d/${MONGO_PACKAGE}-${MONGO_MAJOR}.list

RUN set -x \
# installing "mongodb-enterprise" pulls in "tzdata" which prompts for input
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get install -y \
		${MONGO_PACKAGE}=$MONGO_VERSION \
		${MONGO_PACKAGE}-server=$MONGO_VERSION \
		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
		${MONGO_PACKAGE}-database=$MONGO_VERSION \
		${MONGO_PACKAGE}-database-tools-extra=$MONGO_VERSION \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mongodb \
	&& rm -rf /etc/mongod.conf

# CHANGE: Link binaries as in https://github.com/xavidop/mongodb-7-bitnami/blob/main/Dockerfile#L85
RUN mkdir -p /opt/bitnami/mongodb/bin \
  && ln -s /usr/bin/install_compass            /opt/bitnami/mongodb/bin/ \
  && ln -s /usr/bin/bsondump                   /opt/bitnami/mongodb/bin/ \
  && ln -s /usr/bin/mongo*                     /opt/bitnami/mongodb/bin/ \
  && rm -rf /etc/mysql/mongodb.cnf \
  && chown 1001:1001 -R /opt/bitnami/mongodb

# Continue with the process from original bitnami Dockerfile

RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitnami/scripts/mongodb/postunpack.sh
ENV APP_VERSION="6.0.20" \
    BITNAMI_APP_NAME="mongodb" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/mongodb/bin:$PATH"

EXPOSE 27017

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mongodb/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/mongodb/run.sh" ]
