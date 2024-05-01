<p align="center"><a href="https://github.com/crazy-max/docker-jetbrains-license-server" target="_blank"><img height="128" src="https://raw.githubusercontent.com/crazy-max/docker-jetbrains-license-server/master/.github/docker-jetbrains-license-server.jpg"></a></p>

<p align="center">
  <a href="https://hub.docker.com/r/crazymax/jetbrains-license-server/tags?page=1&ordering=last_updated"><img src="https://img.shields.io/github/v/tag/crazy-max/docker-jetbrains-license-server?label=version&style=flat-square" alt="Latest Version"></a>
  <a href="https://github.com/crazy-max/docker-jetbrains-license-server/actions?workflow=build"><img src="https://img.shields.io/github/actions/workflow/status/crazy-max/docker-jetbrains-license-server/build.yml?branch=master&?label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/jetbrains-license-server/"><img src="https://img.shields.io/docker/stars/crazymax/jetbrains-license-server.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/jetbrains-license-server/"><img src="https://img.shields.io/docker/pulls/crazymax/jetbrains-license-server.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

[JetBrains License Server](https://www.jetbrains.com/help/license_server/getting_started.html)
Docker image.

> [!TIP]
> Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun)
> project!

___

* [Features](#features)
* [Build locally](#build-locally)
* [Image](#image)
* [Environment variables](#environment-variables)
* [Volumes](#volumes)
* [Ports](#ports)
* [Usage](#usage)
  * [Docker Compose](#docker-compose)
  * [Command line](#command-line)
* [Upgrade](#upgrade)
* [Notes](#notes)
  * [Error 403 Passed value of header "Host" is not allowed](#error-403-passed-value-of-header-host-is-not-allowed)
* [Contributing](#contributing)
* [License](#license)

## Features

* Run as non-root user
* Multi-platform image
* License server completely customizable via environment variables
* Registration data and configuration in a single directory
* [msmtpd SMTP relay](https://github.com/crazy-max/docker-msmtpd) image to send emails
* [Traefik](https://github.com/containous/traefik-library-image) as reverse proxy and creation/renewal of Let's Encrypt certificates (see [this template](examples/traefik))

## Build locally

```shell
git clone https://github.com/crazy-max/docker-jetbrains-license-server.git
cd docker-jetbrains-license-server

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

## Image

| Registry                                                                                                            | Image                                        |
|---------------------------------------------------------------------------------------------------------------------|----------------------------------------------|
| [Docker Hub](https://hub.docker.com/r/crazymax/jetbrains-license-server/)                                           | `crazymax/jetbrains-license-server`          |
| [GitHub Container Registry](https://github.com/users/crazy-max/packages/container/package/jetbrains-license-server) | `ghcr.io/crazy-max/jetbrains-license-server` |

## Environment variables

* `TZ`: The timezone assigned to the container (default `UTC`)
* `PUID`: JLS UID (default `1000`)
* `PGID`: JLS GID (default `1000`)
* `JLS_VIRTUAL_HOSTS`: [Virtual hosts](https://www.jetbrains.com/help/license_server/setting_host_and_port.html#d1010e63) where license server will be available (comma delimited for several hosts)
* `JLS_CONTEXT`:  [Context path](https://www.jetbrains.com/help/license_server/setting_host_and_port.html#d1010e63) used by the license server (default `/`)
* `JLS_PROXY_TYPE`: Type of [proxy](https://www.jetbrains.com/help/license_server/configuring_proxy_settings.html) to use. Can be `http` or `https` (default `https`)
* `JLS_PROXY_HOST`: The host name of your proxy server
* `JLS_PROXY_PORT`: The port number that the proxy server listens to
* `JLS_PROXY_USER`: Username to connect to the proxy server (no auth if empty)
* `JLS_PROXY_PASSWORD`: Password to connect to the proxy server (no auth if empty)
* `JLS_ACCESS_CONFIG`: JSON file to configure [user restrictions](https://www.jetbrains.com/help/license_server/configuring_user_restrictions.html) (default `/data/access-config.json`)
* `JLS_STATS_RECIPIENTS`: [Reports recipients](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) email addresses for stats (comma delimited)
* `JLS_REPORT_OUT_OF_LICENSE`: [Warn about lack of licenses](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) every hour following the percentage threshold (default `0`)
* `JLS_SMTP_SERVER`: SMTP server host to use for sending [stats](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html) (stats disabled if empty)
* `JLS_SMTP_PORT`: SMTP server port (default `25`)
* `JLS_SMTP_USERNAME`: SMTP username (auth disabled if empty)
* `JLS_SMTP_PASSWORD`: SMTP password (auth disabled if empty)
* `JLS_STATS_FROM`: [From address](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e40) for stats emails
* `JLS_STATS_TOKEN`: Enables an auth token for the [stats API](https://www.jetbrains.com/help/license_server/detailed_server_usage_statistics.html#d461e312) at `/reportApi` (HTTP POST)
* `JLS_SERVICE_LOGLEVEL`: Logging of IDE requests and responses (default `warn`)
* `JLS_REPORTING_LOGLEVEL`: Logging of actions on a server: tickets obtaining and revoking with user and license information (default `warn`) 
* `JLS_TICKETS_LOGLEVEL`: Logging of actions with tickets. For example, manual ticket revoking (default `warn`)

## Volumes

* `/data`: Contains [registration data](https://www.jetbrains.com/help/license_server/migrate.html) and configuration

> [!WARNING]
> Note that the volumes should be owned by the user/group with the specified
> `PUID` and `PGID`. If you don't give the volume correct permissions, the
> container may not start.

## Ports

* `8000`: Jetbrains License Server HTTP port

## Usage

### Docker Compose

Docker compose is the recommended way to run this image. Copy the content of
folder [examples/compose](examples/compose) in `/var/jls/` on your host for
example. Edit the compose and env files with your preferences and run the
following commands:

```bash
docker compose up -d
docker compose logs -f
```

### Command line

You can also use the following minimal command:

```bash
$ docker run -d -p 8000:8000 --name jetbrains_license_server \
  -e TZ="Europe/Paris" \
  -e JLS_VIRTUAL_HOSTS=jls.example.com \
  -v $(pwd)/data:/data \
  crazymax/jetbrains-license-server:latest
```

## Upgrade

Recreate the container whenever I push an update:

```bash
docker compose pull
docker compose up -d
```

## Notes

If you have any trouble using the license server, check the official
[Troubleshooting page](https://www.jetbrains.com/help/license_server/troubleshooting.html)
of Jetbrains.

### Error 403 Passed value of header "Host" is not allowed

If you've got the following message :

```
Passed value of header "Host" is not allowed. Please contact your license server administrator.
```

That's because the license server is running behind a reverse proxy. Please
configure virtual hosts using the `JLS_VIRTUAL_HOSTS` variable.

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star
the project, or to raise issues. You can also support this project by [**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max)
or by making a [PayPal donation](https://www.paypal.me/crazyws) to ensure this
journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
