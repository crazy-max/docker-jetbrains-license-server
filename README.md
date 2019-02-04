<p align="center"><a href="https://github.com/crazy-max/docker-jetbrains-license-server" target="_blank"><img height="128"src="https://raw.githubusercontent.com/crazy-max/docker-jetbrains-license-server/master/.res/docker-jetbrains-license-server.jpg"></a></p>

<p align="center">
  <a href="https://microbadger.com/images/crazymax/jetbrains-license-server"><img src="https://images.microbadger.com/badges/version/crazymax/jetbrains-license-server.svg?style=flat-square" alt="Version"></a>
  <a href="https://travis-ci.com/crazy-max/docker-jetbrains-license-server"><img src="https://img.shields.io/travis/com/crazy-max/docker-jetbrains-license-server/master.svg?style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/jetbrains-license-server/"><img src="https://img.shields.io/docker/stars/crazymax/jetbrains-license-server.svg?style=flat-square" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/jetbrains-license-server/"><img src="https://img.shields.io/docker/pulls/crazymax/jetbrains-license-server.svg?style=flat-square" alt="Docker Pulls"></a>
  <a href="https://quay.io/repository/crazymax/jetbrains-license-server"><img src="https://quay.io/repository/crazymax/jetbrains-license-server/status?style=flat-square" alt="Docker Repository on Quay"></a>
  <a href="https://www.codacy.com/app/crazy-max/docker-jetbrains-license-server"><img src="https://img.shields.io/codacy/grade/eb420bc3e6ed49ff97cc261602228efa.svg?style=flat-square" alt="Code Quality"></a>
  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3BXL8EBDJALHQ"><img src="https://img.shields.io/badge/donate-paypal-7057ff.svg?style=flat-square" alt="Donate Paypal"></a>
</p>

## About

🐳 [JetBrains License Server](https://www.jetbrains.com/help/license_server/getting_started.html) Docker image based on Alpine Linux.<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other 🐳 Docker images!

## Features

### Included

* License server completely customizable via environment variables
* Registration data and configuration in a single directory

### From docker-compose

* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates

## Docker

### Environment variables

* `TZ` : The timezone assigned to the container (default `UTC`)
* `JLS_VIRTUAL_HOSTS` : [Virtual hosts](https://www.jetbrains.com/help/license_server/setting_host_and_port.html#d1010e63) where license server will be available (comma delimited for several hosts)
* `JLS_CONTEXT` :  [Context path](https://www.jetbrains.com/help/license_server/setting_host_and_port.html#d1010e63) used by the license server (default `/`)
* `JLS_ACCESS_CONFIG` : JSON file to configure [user restrictions](https://www.jetbrains.com/help/license_server/configuring_user_restrictions.html) (default `/data/access-config.json`)
* `JLS_STATS_RECIPIENTS` : [Reports recipients](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) email addresses for stats (comma delimited)
* `JLS_REPORT_OUT_OF_LICENSE` : [Warn about lack of licenses](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) every hour following the percentage threshold (default `0`)
* `JLS_SMTP_SERVER` : SMTP server host to use for sending [stats](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html) (stats disabled if empty)
* `JLS_SMTP_PORT` : SMTP server port (default `25`)
* `JLS_SMTP_USERNAME` : SMTP username (auth disabled if empty)
* `JLS_SMTP_PASSWORD` : SMTP password (auth disabled if empty)
* `JLS_STATS_FROM` : [From address](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) for stats emails
* `JLS_STATS_TOKEN` : Enables an auth token for the [stats API](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e312) at `/reportApi` (HTTP POST)

### Volumes

* `/data` : Contains [registration data](https://www.jetbrains.com/help/license_server/migrate.html) and configuration

### Ports

* `8000` : Jetbrains License Server HTTP port

## Use this image

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of folder [examples/compose](examples/compose) in `/var/jls/` on your host for example. Edit the compose and env files with your preferences and run the following commands :

```bash
touch acme.json
chmod 600 acme.json
docker-compose up -d
docker-compose logs -f
```

### Command line

You can also use the following minimal command :

```bash
$ docker run -d -p 8000:8000 --name jetbrains_license_server \
  -e TZ="Europe/Paris" \
  -e JLS_VIRTUAL_HOSTS=jetbrains-license-server.example.com \
  -v $(pwd)/data:/data \
  crazymax/jetbrains-license-server:latest
```

## Update

Recreate the container whenever i push an update :

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

That's because the license server is running behind a reverse proxy. Please configure virtual hosts using the `JLS_VIRTUAL_HOSTS` variable.

## How can I help ?

All kinds of contributions are welcome :raised_hands:!<br />
The most basic way to show your support is to star :star2: the project, or to raise issues :speech_balloon:<br />
But we're not gonna lie to each other, I'd rather you buy me a beer or two :beers:!

[![Paypal](.res/paypal.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3BXL8EBDJALHQ)

## License

MIT. See `LICENSE` for more details.
