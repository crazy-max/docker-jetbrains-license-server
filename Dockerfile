ARG JLS_VERSION=32800
ARG JLS_SHA256=a4dff1f4e1ac720ffdc62b3af0f52cd4e42487c6a08985d5b8863ad4c0889134

FROM crazymax/yasu:latest AS yasu
FROM alpine:3.16

ENV JLS_PATH="/opt/jetbrains-license-server" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

COPY entrypoint.sh /entrypoint.sh
ARG JLS_SHA256
RUN apk add --update --no-cache \
    bash \
    ca-certificates \
    curl \
    openjdk11-jre \
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
  && chmod a+x /entrypoint.sh \
  && apt-get purge -y build-essential \
  && addgroup -g ${PGID} jls \
  && adduser -u ${PUID} -G jls -h /data -s /bin/bash -D jls \
  && chown -R jls. /data "$JLS_PATH" \
  && rm -rf /tmp/*

# SSH Server inside container for Azure App Service's web SSH console
# RUN apt-get install -y --no-install-recommends openssh-server \
#     && echo "root:Docker!" | chpasswd
# COPY sshd_config /etc/ssh/

# Install Nginx to fix HTTP headers modified by Azure's proxy
RUN apt-get install -y --no-install-recommends nginx
COPY nginx.conf /etc/nginx/nginx.conf

# forward request and error logs to docker log collector
# RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#         && ln -sf /dev/stderr /var/log/nginx/error.log

# cleanup packages
RUN apt-get clean && apt auto-remove -y \
  && rm -rf /var/cache/apt/* /tmp/*

COPY --from=yasu / /

EXPOSE 2222 8080

WORKDIR /data
VOLUME [ "/data" ]
# disabling IPv6 - not needed anymore
# COPY license-server.jvmoptions.tmpl ${JLS_PATH}/conf/license-server.jvmoptions


ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD license-server status || exit 1
