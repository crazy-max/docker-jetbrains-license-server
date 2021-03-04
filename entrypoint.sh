#!/bin/sh

TZ=${TZ:-UTC}

JLS_PATH="/opt/jetbrains-license-server"
JLS_LISTEN_ADDRESS="0.0.0.0"
JLS_PORT=8000
JLS_CONTEXT=${JLS_CONTEXT:-/}
JLS_ACCESS_CONFIG=${JLS_ACCESS_CONFIG:-/data/access-config.json}
JLS_PROXY_TYPE=${JLS_PROXY_TYPE:-https}
JLS_SERVICE_LOGLEVEL=${JLS_SERVICE_LOGLEVEL:-warn}
JLS_REPORTING_LOGLEVEL=${JLS_REPORTING_LOGLEVEL:-warn}
JLS_TICKETS_LOGLEVEL=${JLS_TICKETS_LOGLEVEL:-warn}

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g jls)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^jls:\([^:]*\):[0-9]*/jls:\1:${PGID}/" /etc/group
  sed -i -e "s/^jls:\([^:]*\):\([0-9]*\):[0-9]*/jls:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u jls)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^jls:\([^:]*\):[0-9]*:\([0-9]*\)/jls:\1:${PUID}:\2/" /etc/passwd
fi
if [ -n "${PUID}" ] || [ -n "${PGID}" ]; then
  chown -R jls:jls /data "$JLS_PATH"
fi

# Timezone
echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

# Init
echo "Initializing files and folders..."
yasu jls:jls touch "/data/access-config.json"

# https://www.jetbrains.com/help/license_server/setting_host_and_port.html
echo "Configuring Jetbrains License Server..."
yasu jls:jls license-server configure --listen ${JLS_LISTEN_ADDRESS} --port ${JLS_PORT} --context ${JLS_CONTEXT}

# https://www.jetbrains.com/help/license_server/setting_host_and_port.html
if [ -n "$JLS_VIRTUAL_HOSTS" ]; then
  echo "Following virtual hosts will be used:"
  for JLS_VIRTUAL_HOST in $(echo ${JLS_VIRTUAL_HOSTS} | tr "," "\n"); do
    echo "-> ${JLS_VIRTUAL_HOST}"
  done
  yasu jls:jls license-server configure --jetty.virtualHosts.names=${JLS_VIRTUAL_HOSTS}
fi

# https://www.jetbrains.com/help/license_server/configuring_proxy_settings.html
if [ -n "$JLS_PROXY_HOST" ] && [ -n "$JLS_PROXY_PORT" ]; then
  echo "Setting ${JLS_PROXY_TYPE} proxy to $JLS_PROXY_HOST:$JLS_PROXY_PORT..."
  yasu jls:jls license-server configure \
    -J-D${JLS_PROXY_TYPE}.proxyHost=${JLS_PROXY_HOST} \
    -J-D${JLS_PROXY_TYPE}.proxyPort=${JLS_PROXY_PORT}

  if [ -n "$JLS_PROXY_USER" ] && [ -n "$JLS_PROXY_PASSWORD" ]; then
    echo "Setting ${JLS_PROXY_TYPE} proxy credentials..."
    yasu jls:jls license-server configure \
      -J-D${JLS_PROXY_TYPE}.proxyUser=${JLS_PROXY_USER} \
      -J-D${JLS_PROXY_TYPE}.proxyPassword=${JLS_PROXY_PASSWORD}
  fi
fi
unset JLS_PROXY_USER
unset JLS_PROXY_PASSWORD

# https://www.jetbrains.com/help/license_server/configuring_user_restrictions.html
if [ -s "$JLS_ACCESS_CONFIG" ]; then
  echo "Enabling user restrictions access from $JLS_ACCESS_CONFIG..."
  yasu jls:jls license-server configure --access.config=file:${JLS_ACCESS_CONFIG}
fi

# https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html
if [ -n "$JLS_SMTP_SERVER" ] && [ -n "$JLS_STATS_RECIPIENTS" ]; then
  JLS_SMTP_PORT=${JLS_SMTP_PORT:-25}
  echo "Enabling User Reporting via SMTP at $JLS_SMTP_SERVER:$JLS_SMTP_PORT..."
  yasu jls:jls license-server configure --smtp.server ${JLS_SMTP_SERVER} --smtp.server.port ${JLS_SMTP_PORT}

  if [ -n "$JLS_SMTP_USERNAME" ] && [ -n "$JLS_SMTP_PASSWORD" ]; then
    echo "Using SMTP username $JLS_SMTP_USERNAME with password..."
    yasu jls:jls license-server configure --smtp.server.username ${JLS_SMTP_USERNAME}
    yasu jls:jls license-server configure --smtp.server.password ${JLS_SMTP_PASSWORD}
  fi
  unset JLS_SMTP_USERNAME
  unset JLS_SMTP_PASSWORD

  if [ -n "$JLS_STATS_FROM" ]; then
    echo "Setting stats sender to $JLS_STATS_FROM..."
    yasu jls:jls license-server configure --stats.from ${JLS_STATS_FROM}
  fi

  if [ "$JLS_REPORT_OUT_OF_LICENSE" -gt 0 ]; then
    echo "Setting report out of licence to $JLS_REPORT_OUT_OF_LICENSE%..."
    yasu jls:jls license-server configure --reporting.out.of.license.threshold ${JLS_REPORT_OUT_OF_LICENSE}
  fi

  echo "Stats recipients: $JLS_STATS_RECIPIENTS..."
  yasu jls:jls license-server configure --stats.recipients ${JLS_STATS_RECIPIENTS}
fi

# https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html
if [ -n "$JLS_STATS_TOKEN" ]; then
  echo "Enabling stats via API at /$JLS_STATS_TOKEN..."
  yasu jls:jls license-server configure --reporting.token ${JLS_STATS_TOKEN}
fi
unset JLS_STATS_TOKEN

# https://www.jetbrains.com/help/license_server/changing_logging_level.html
cat > ${JLS_PATH}/web/WEB-INF/classes/log4j2.xml <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="info" monitorInterval="60">
    <Appenders>
        <Console name="CONSOLE" target="SYSTEM_OUT">
            <PatternLayout pattern="%-5p %c{1}:%L - %m%n"/>
        </Console>
        <Async name="ASYNC" includeLocation="true">
            <AppenderRef ref="CONSOLE"/>
        </Async>
    </Appenders>
    <Loggers>
        <Root level="info">
            <AppenderRef ref="ASYNC"/>
        </Root>
        <Logger name="l_service" level="${JLS_SERVICE_LOGLEVEL}" additivity="false">
            <AppenderRef ref="ASYNC"/>
        </Logger>
        <Logger name="Reporting" level="${JLS_REPORTING_LOGLEVEL}" additivity="false">
            <AppenderRef ref="ASYNC"/>
        </Logger>
        <Logger name="Tickets" level="${JLS_TICKETS_LOGLEVEL}" additivity="false">
            <AppenderRef ref="ASYNC"/>
        </Logger>
    </Loggers>
</Configuration>
EOL

echo "Fixing perms..."
chown -R jls:jls /data "$JLS_PATH"

exec yasu jls:jls "$@"
