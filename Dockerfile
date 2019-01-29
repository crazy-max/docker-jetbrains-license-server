FROM openjdk:8-jre-stretch

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="jetbrains-license-server" \
  org.label-schema.description="JetBrains License Server" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-jetbrains-license-server" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

ENV JLS_PATH="/opt/jetbrains-license-server" \
  JLS_VERSION="18692" \
  JLS_SHA256="e71c4abae7d144dda7af5775dd6812e93d5934de39134d97420b4b0db29e16f4"

COPY entrypoint.sh /entrypoint.sh

RUN apt update \ 
  && apt-get install -y tzdata build-essential curl unzip \
  && mkdir -p "$JLS_PATH" \
  && curl -L "https://download.jetbrains.com/lcsrv/license-server-installer.zip" -o "/tmp/jls.zip" \
  && echo "$JLS_SHA256  /tmp/jls.zip" | sha256sum -c - | grep OK \
  && unzip "/tmp/jls.zip" -d "$JLS_PATH" \
  && rm -f "/tmp/jls.zip" \
  && chmod a+x "$JLS_PATH/bin/license-server.sh" \
  && ln -sf "$JLS_PATH/bin/license-server.sh" "/usr/local/bin/license-server" \
  && chmod a+x /entrypoint.sh \
  && apt-get purge -y build-essential 

# SSH Server inside container for Azure App Service's web SSH console
RUN apt-get install -y --no-install-recommends openssh-server \
    && echo "root:Docker!" | chpasswd
COPY sshd_config /etc/ssh/

# Install Nginx to fix HTTP headers modified by Azure's proxy
RUN apt-get install -y --no-install-recommends nginx
COPY nginx.conf /etc/nginx/nginx.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log

# cleanup packages
RUN apt-get clean && apt auto-remove -y \
  && rm -rf /var/cache/apt/* /tmp/*

EXPOSE 2222 8080

# disabling IPv6 - not needed anymore
# COPY license-server.jvmoptions.tmpl ${JLS_PATH}/conf/license-server.jvmoptions


ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/local/bin/license-server", "run" ]
