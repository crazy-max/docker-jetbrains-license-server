<p align="center"><a href="https://github.com/crazy-max/docker-jetbrains-license-server" target="_blank"><img height="100"src="https://raw.githubusercontent.com/crazy-max/docker-jetbrains-license-server/master/.res/jetbrains-license-server_docker.png"></a></p>

<p align="center">
  <a href="https://microbadger.com/images/crazymax/jetbrains-license-server"><img src="https://images.microbadger.com/badges/version/crazymax/jetbrains-license-server.svg?style=flat-square" alt="Version"></a>
  <a href="https://travis-ci.org/crazy-max/docker-jetbrains-license-server"><img src="https://img.shields.io/travis/crazy-max/docker-jetbrains-license-server/master.svg?style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/jetbrains-license-server/"><img src="https://img.shields.io/docker/stars/crazymax/jetbrains-license-server.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/jetbrains-license-server/"><img src="https://img.shields.io/docker/pulls/crazymax/jetbrains-license-server.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/crazymax/jetbrains-license-server"><img src="https://quay.io/repository/crazymax/jetbrains-license-server/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3BXL8EBDJALHQ"><img src="https://img.shields.io/badge/donate-paypal-7057ff.svg?style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [JetBrains License Server](https://www.jetbrains.com/help/license_server/getting_started.html) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

## Features

### Included

* Nginx reverse proxy
* License server completely customizable via environment variables
* Registration data and configuration in a single directory

### From docker-compose

* Reverse proxy with [nginx-proxy](https://github.com/jwilder/nginx-proxy)
* Creation/renewal of Let's Encrypt certificates automatically with [letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)

## Docker

### Environment variables

* `TZ` : The timezone assigned to the container (default to `UTC`)
* `JLS_VIRTUAL_HOSTS` : [Virtual hosts](https://www.jetbrains.com/help/license_server/setting_host_and_port.html#d1010e63) where license server will be available (required ; comma delimited for several hosts)
* `JLS_ACCESS_CONFIG` : JSON file to configure [user restrictions](https://www.jetbrains.com/help/license_server/configuring_user_restrictions.html) (default to `/data/access-config.json`)
* `JLS_STATS_RECIPIENTS` : [Reports recipients](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) email addresses for stats (comma delimited)
* `JLS_SMTP_SERVER` : SMTP server host to use for sending [stats](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html) (stats disabled if empty)
* `JLS_SMTP_PORT` : SMTP server port (default to `25`)
* `JLS_SMTP_USERNAME` : SMTP username (auth disabled if empty)
* `JLS_SMTP_PASSWORD` : SMTP password (auth disabled if empty)
* `JLS_STATS_FROM` : [From address](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) for stats emails
* `JLS_STATS_TOKEN` : Enables an auth token for the [stats API](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e312) at `/reportApi` (HTTP POST)

### Volumes

* `/data` : Contains [registration data](https://www.jetbrains.com/help/license_server/migrate.html) and configuration

### Ports

* `80` : HTTP port

## Usage

Docker compose is the recommended way to run this image. You can use the following [docker compose template](docker-compose.yml), then run the container :

```bash
docker-compose up -d
docker-compose logs -f
```

Or use the following minimal command :

```bash
$ docker run -d -p 8000:80 --name jetbrains-license-server \
  -e TZ="Europe/Paris" \
  -e JLS_VIRTUAL_HOSTS=jetbrains-license-server.example.com \
  -v $(pwd)/data:/data \
  crazymax/jetbrains-license-server:latest
```

## Update

You can update Matomo automatically through the UI, it works well. But i recommend to recreate the container whenever i push an update :

```bash
docker-compose pull
docker-compose up -d
```

## Troubleshooting

If you have any trouble using the license server, check the official [Troubleshooting page](https://www.jetbrains.com/help/license_server/troubleshooting.html) of Jetbrains.

### Error 403 Passed value of header "Host" is not allowed

If you've got the following message :

```
Passed value of header "Host" is not allowed. Please contact your license server administrator.
```

That's because the license server is running behind the Nginx reverse proxy. Please configure virtual hosts using the `JLS_VIRTUAL_HOSTS` variable.

## How can i help ?

We welcome all kinds of contributions :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
Any funds donated will be used to help further development on this project! :gift_heart:

[![Donate Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3BXL8EBDJALHQ)

## License

MIT. See `LICENSE` for more details.
