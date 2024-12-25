# syntax=docker/dockerfile:1

ARG JLS_VERSION=39687
ARG JLS_SHA256=bcb5fa802993894c61bc4da96ffd823cbb90a3151ab4da57ae7cc8c4301d3eab
ARG ALPINE_VERSION=3.21

FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS src
RUN apk add --update --no-cache curl zip
WORKDIR /src/jls
ARG JLS_SHA256
RUN <<EOT
  set -ex
  curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/jls.zip"
  echo "$JLS_SHA256  /tmp/jls.zip" | sha256sum -c - | grep OK
  unzip "/tmp/jls.zip" -d .
  chmod a+x ./bin/license-server.sh
EOT

FROM alpine:${ALPINE_VERSION}

ENV JLS_PATH="/opt/jetbrains-license-server" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

RUN apk add --update --no-cache \
    bash \
    ca-certificates \
    openjdk11-jre \
    openssl \
    shadow \
    tzdata \
  && mkdir -p /data \
  && addgroup -g ${PGID} jls \
  && adduser -u ${PUID} -G jls -h /data -s /bin/bash -D jls

COPY --from=crazymax/yasu:latest / /
COPY --from=src /src/jls $JLS_PATH

RUN ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && chown -R jls:jls /data "$JLS_PATH"

COPY entrypoint.sh /entrypoint.sh

EXPOSE 8000
WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD license-server status || exit 1
