#!/bin/sh

JLS_PATH="/opt/jetbrains-license-server"
JLS_LISTEN_ADDRESS="127.0.0.1"
JLS_PORT=8080
JLS_ACCESS_CONFIG=${JLS_ACCESS_CONFIG:-"/data/access-config.json"}

# https://www.jetbrains.com/help/license_server/setting_host_and_port.html
echo "Configuring Jetbrains License Server..."
license-server configure --listen ${JLS_LISTEN_ADDRESS} --port ${JLS_PORT}

# https://www.jetbrains.com/help/license_server/setting_host_and_port.html
if [ ! -z "$JLS_VIRTUAL_HOSTS" ] ; then
  echo "Following virtual hosts will be used :"
  for JLS_VIRTUAL_HOST in $(echo ${JLS_VIRTUAL_HOSTS} | tr "," "\n"); do
    echo "-> ${JLS_VIRTUAL_HOST}"
  done
  license-server configure --jetty.virtualHosts.names=${JLS_VIRTUAL_HOSTS}
fi

# https://www.jetbrains.com/help/license_server/configuring_user_restrictions.html
if [ -s "$JLS_ACCESS_CONFIG" ]; then
  echo "Enabling user restrictions access from $JLS_ACCESS_CONFIG..."
  license-server configure --access.config=file:${JLS_ACCESS_CONFIG}
fi

# https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html
if [ ! -z "$JLS_SMTP_SERVER" -a ! -z "$JLS_STATS_RECIPIENTS" ] ; then
  JLS_SMTP_PORT=${JLS_SMTP_PORT:-"25"}
  echo "Enabling User Reporting via SMTP at $JLS_SMTP_SERVER:$JLS_SMTP_PORT..."
  license-server configure --smtp.server ${JLS_SMTP_SERVER} --smtp.server.port ${JLS_SMTP_PORT}

  if [ ! -z "$JLS_SMTP_USERNAME" -a ! -z "$JLS_SMTP_PASSWORD" ] ; then
    echo "Using SMTP username $JLS_SMTP_USERNAME with password..."
    license-server configure --smtp.server.username ${JLS_SMTP_USERNAME}
    license-server configure --smtp.server.password ${JLS_SMTP_PASSWORD}
  fi

  if [ ! -z "$JLS_STATS_FROM" ] ; then
    echo "Setting stats sender to $JLS_STATS_FROM..."
    license-server configure --stats.from ${JLS_STATS_FROM}
  fi

  echo "Stats recipients: $JLS_STATS_RECIPIENTS..."
  license-server configure --stats.recipients ${JLS_STATS_RECIPIENTS}
fi

# https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html
if [ ! -z "$JLS_STATS_TOKEN" ] ; then
  echo "Enabling stats via API at /$JLS_STATS_TOKEN..."
  license-server configure --reporting.token ${JLS_STATS_TOKEN}
fi

exec "$@"
