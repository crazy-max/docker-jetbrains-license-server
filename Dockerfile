ARG JLS_VERSION=27608
ARG JLS_SHA256=20f237eb4e87de82aeabaf065e0fd0df72c6a65fb86d3b797822cb9b6ef740f3

FROM crazymax/yasu:latest AS yasu
FROM adoptopenjdk:15-jre-hotspot
LABEL maintainer="CrazyMax"

ENV JLS_PATH="/opt/jetbrains-license-server" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

ARG JLS_SHA256
RUN apt-get update \
  && apt-get install -y \
    bash \
    curl \
    zip \
    tzdata \
  && mkdir -p /data "$JLS_PATH" \
  && curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/jls.zip" \
  && echo "$JLS_SHA256  /tmp/jls.zip" | sha256sum -c - | grep OK \
  && unzip "/tmp/jls.zip" -d "$JLS_PATH" \
  && rm -f "/tmp/jls.zip" \
  && chmod a+x "$JLS_PATH/bin/license-server.sh" \
  && ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && groupadd -f -g ${PGID} jls \
  && useradd -o -s /bin/bash -d /data -u ${PUID} -g jls -m jls \
  && chown -R jls. /data "$JLS_PATH" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=yasu / /
COPY entrypoint.sh /entrypoint.sh

EXPOSE 8000
WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD license-server status || exit 1
