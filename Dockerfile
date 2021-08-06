# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: glibc
# Minimum Panel Version: 0.6.0
# ----------------------------------
FROM zenika/alpine-chrome:with-node

LABEL author="Michael Parker" maintainer="parker@pterodactyl.io"

RUN useradd -m -d /home/container container

USER container
ENV  USER=container HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD  ["/bin/bash", "/entrypoint.sh"]
