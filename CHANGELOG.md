# Changelog

## 33965-r0 (2022/12/29)

* JetBrains License Server 33965 (#75)
* Alpine Linux 3.17 (#74)

## 32800-r0 (2022/07/20)

* JetBrains License Server 32800 (#70)
* Alpine Linux 3.16 (#71)

## 31550-r0 (2022/04/10)

* JetBrains License Server 31550 (#64)

## 30803-r0 (2022/02/07)

* JetBrains License Server 30803 (#61)
* OpenJDK 11 required (drops support for `arm/v6` and `arm/v7`)

## 30333-r0 (2021/12/22)

* JetBrains License Server 30333 (#60)

## 30241-r0 (2021/12/17)

* JetBrains License Server 30241 (#59)

## 30211-r0 (2021/12/12)

* JetBrains License Server 30211 (#57)
* Alpine Linux 3.15 (#58)

## 29591-r0 (2021/10/26)

* JetBrains License Server 29591 (#56)

## 28662-r1 (2021/09/18)

* Alpine Linux 3.14 (#55)
* Fix JRE (#54)

## 28662-r0 (2021/08/15)

* JetBrains License Server 28662

## 28150-r0 (2021/07/14)

* JetBrains License Server 28150

## 27608-r0 (2021/06/29)

* JetBrains License Server 27608

## 26498-r0 (2021/03/17)

* JetBrains License Server 26498

## 26301-r3 (2021/03/04)

* Renamed `yasu` (more info https://github.com/crazy-max/yasu#yet-another)

## 26301-r2 (2021/03/03)

* Switch to `gosu`

## 26301-r1 (2021/02/21)

* Fix permissions (#44)

## 26301-r0 (2021/02/11)

* JetBrains License Server 26301

## 25980-r0 (2021/01/18)

* JetBrains License Server 25980
* OpenJDK JRE 15
* Switch to buildx bake

## 24694-RC1 (2020/10/08)

* JetBrains License Server 24694
* Add `JLS_SERVICE_LOGLEVEL`, `JLS_REPORTING_LOGLEVEL` and `JLS_TICKETS_LOGLEVEL` env vars

## 24086-RC1 (2020/08/17)

* JetBrains License Server 24086

## 23527-RC1 (2020/06/19)

* JetBrains License Server 23527

## 22218-RC1 (2020/02/04)

* JetBrains License Server 22218
* AdoptOpenJDK JRE 13

## 21137-RC5 (2019/12/07)

* Fix timezone

## 21137-RC4 (2019/11/28)

* Proxy type defaults to `https`
* More unset

## 21137-RC3 (2019/11/28)

* Add env vars to set proxy settings (#21)
* Unset sensitive vars

## 21137-RC2 (2019/11/17)

* Allow to set custom `PUID`/`PGID`

## 21137-RC1 (2019/10/24)

* JetBrains License Server 21137

## 20308-RC4 (2019/10/10)

* Optimize layers

## 20308-RC3 (2019/10/10)

* Multi-platform Docker image
* Switch to GitHub Actions
* :warning: Stop publishing Docker image on Quay
* :warning: Run as non-root user
* Set timezone through tzdata

> :warning: **UPGRADE NOTES**
> As the Docker container now runs as a non-root user, you have to first stop the container and change permissions to `data` volume:
> ```
> docker-compose stop
> chown -R 1000:1000 data/
> docker-compose pull
> docker-compose up -d
> ```

## 20308-RC2 (2019/08/04)

* Add healthcheck

## 20308-RC1 (2019/07/30)

* JetBrains License Server 20308

## 20267-RC2 (2019/07/22)

* OpenJDK JRE 12
* Alpine Linux 3.10

## 20267-RC1 (2019/07/19)

* JetBrains License Server 20267

## 19488-RC1 (2019/04/02)

* JetBrains License Server 19488

## 19340-RC1 (2019/03/15)

* JetBrains License Server 19340

## 18692-RC2 (2019/01/22)

* Bind to unprivileged port : `8000`

## 18692-RC1 (2018/12/25)

* JetBrains License Server 18692

## 17955-RC1 (2018/09/26)

* JetBrains License Server 17955

## 17768-RC1 (2018/09/05)

* JetBrains License Server 17768

## 17437-RC1 (2018/07/30)

* JetBrains License Server 17437

## 17211-RC1 (2018/06/29)

* JetBrains License Server 17211

## 17043-RC1 (2018/05/31)

* JetBrains License Server 17043

## 16429-RC2 (2018/04/20)

* JetBrains accidentally published 16743. Revert to 16429 (Issue #1)

## 16743-RC1 (2018/04/20)

* JetBrains License Server 16743
* Replace Nginx + Let's Encrypt with Traefik (see docker-compose)

## 16429-RC1 (2018/03/20)

* JetBrains License Server 16429

## 15802-RC2 (2018/02/16)

* Add `JLS_CONTEXT` and `JLS_REPORT_OUT_OF_LICENSE` env vars
* Timezone was not setted
* No need of Nginx and Supervisor
* Error while saving stats
* Remove build dependencies

## 15802-RC1 (2018/02/01)

* Initial version based on JetBrains License Server 15802
