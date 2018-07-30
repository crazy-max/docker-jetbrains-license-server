FROM openjdk:8-jre-alpine
MAINTAINER CrazyMax <crazy-max@users.noreply.github.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="jetbrains-license-server" \
  org.label-schema.description="JetBrains License Server image based on Alpine Linux" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

RUN apk --update --no-cache add tzdata \
  && rm -rf /var/cache/apk/* /tmp/*

ENV JLS_PATH="/opt/jetbrains-license-server" \
  JLS_VERSION="17437" \
  JLS_SHA256="9f15c63e9f40e2bf399b503d77a53ad3e4ff5deefb5d8bf29fad6d281b4be4ca"

ADD entrypoint.sh /entrypoint.sh

RUN apk --update --no-cache add -t build-dependencies \
    curl zip \
  && mkdir -p "$JLS_PATH" \
  && curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/jls.zip" \
  && echo "$JLS_SHA256  /tmp/jls.zip" | sha256sum -c - | grep OK \
  && unzip "/tmp/jls.zip" -d "$JLS_PATH" \
  && rm -f "/tmp/jls.zip" \
  && chmod a+x "$JLS_PATH/bin/license-server.sh" \
  && ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && chmod a+x /entrypoint.sh \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/* /tmp/*

EXPOSE 80
VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]
