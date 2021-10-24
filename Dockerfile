ARG JLS_VERSION=29591
ARG JLS_SHA256=c361ab16bf25a4d2e14dd32fec20ecfc5b845716badf861e404edbd1ec2a5712

FROM crazymax/yasu:latest AS yasu
FROM alpine:3.14

ENV JLS_PATH="/opt/jetbrains-license-server" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

ARG JLS_SHA256
RUN apk add --update --no-cache \
    bash \
    ca-certificates \
    curl \
    openjdk8-jre \
    openssl \
    shadow \
    zip \
    tzdata \
  && mkdir -p /data "$JLS_PATH" \
  && curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/jls.zip" \
  && echo "$JLS_SHA256  /tmp/jls.zip" | sha256sum -c - | grep OK \
  && unzip "/tmp/jls.zip" -d "$JLS_PATH" \
  && rm -f "/tmp/jls.zip" \
  && chmod a+x "$JLS_PATH/bin/license-server.sh" \
  && ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && addgroup -g ${PGID} jls \
  && adduser -u ${PUID} -G jls -h /data -s /bin/bash -D jls \
  && chown -R jls. /data "$JLS_PATH" \
  && rm -rf /tmp/* /var/cache/apk/*

COPY --from=yasu / /
COPY entrypoint.sh /entrypoint.sh

EXPOSE 8000
WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD license-server status || exit 1
