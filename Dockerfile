# syntax=docker/dockerfile:experimental
FROM --platform=${TARGETPLATFORM:-linux/amd64} adoptopenjdk:12-jre-hotspot

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

LABEL maintainer="CrazyMax" \
  org.label-schema.name="jetbrains-license-server" \
  org.label-schema.description="JetBrains License Server" \
  org.label-schema.url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

ENV JLS_PATH="/opt/jetbrains-license-server" \
  JLS_VERSION="20308" \
  JLS_SHA256="15cd436d41b1af8e273b8f8b037d654a9e9d9ca8a5f188e08426ca1024ba143a" \
  TZ="UTC"

RUN apt-get update \
  && apt-get install -y \
    bash \
    curl \
    zip \
    tzdata \
  && curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/jls.zip" \
  && echo "$JLS_SHA256  /tmp/jls.zip" | sha256sum -c - | grep OK \
  && unzip "/tmp/jls.zip" -d "$JLS_PATH" \
  && rm -f "/tmp/jls.zip" \
  && chmod a+x "$JLS_PATH/bin/license-server.sh" \
  && ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /entrypoint.sh

RUN mkdir -p /data "$JLS_PATH" \
  && chmod a+x /entrypoint.sh \
  && groupadd -f -g 1000 jls \
  && useradd -o -s /bin/bash -d /data -u 1000 -g 1000 -m jls \
  && chown -R jls. /data "$JLS_PATH"

USER jls

EXPOSE 8000
WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD license-server status || exit 1
