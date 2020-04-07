# syntax=docker/dockerfile:experimental
FROM --platform=${TARGETPLATFORM:-linux/amd64} adoptopenjdk:13-jre-hotspot as suexec

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
    gcc \
    libc-dev \
  && curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c \
  && gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec \
  && chown root:root /usr/local/bin/su-exec \
  && chmod 0755 /usr/local/bin/su-exec

FROM --platform=${TARGETPLATFORM:-linux/amd64} adoptopenjdk:13-jre-hotspot

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.opencontainers.image.source="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.vendor="CrazyMax" \
  org.opencontainers.image.title="JetBrains License Server" \
  org.opencontainers.image.description="JetBrains License Server" \
  org.opencontainers.image.licenses="MIT"

ENV JLS_PATH="/opt/jetbrains-license-server" \
  JLS_VERSION="22218" \
  JLS_SHA256="f68027a8b2b4f2d9b03fe0b0fef4a9ffc0fdfaf2657ab26d545777973311b601" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

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

COPY --from=suexec /usr/local/bin/su-exec /usr/local/bin/su-exec
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8000
WORKDIR /data
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD license-server status || exit 1
