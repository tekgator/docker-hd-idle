# docker-hd-idle

<p>
  <a href="https://hub.docker.com/r/tekgator/docker-hd-idle/tags?page=1&ordering=last_updated" alt="DockerBuildStatus">
    <img src="https://img.shields.io/docker/cloud/build/tekgator/docker-hd-idle" />
  </a>
  <a href="https://hub.docker.com/r/tekgator/docker-hd-idle" alt="DockerPulls">
    <img src="https://img.shields.io/docker/pulls/tekgator/docker-hd-idle" />
  </a>
  <a href="https://hub.docker.com/r/tekgator/docker-hd-idle/tags?page=1&ordering=last_updated" alt="DockerBuilds">
    <img src="https://img.shields.io/docker/cloud/automated/tekgator/docker-hd-idle" />
  </a>
  <a href="https://hub.docker.com/r/tekgator/docker-hd-idle/tags?page=1&ordering=last_updated" alt="DockerBuildStatus">
    <img src="https://img.shields.io/docker/image-size/tekgator/docker-hd-idle/latest" />
  </a>
  <a href="https://github.com/tekgator/docker-hd-idle/blob/main/LICENSE" alt="License">
    <img src="https://img.shields.io/github/license/tekgator/docker-hd-idle" />
  </a>
  <a href="https://github.com/tekgator/docker-hd-idle/releases" alt="Releases">
    <img src="https://img.shields.io/github/v/release/tekgator/docker-hd-idle" />
  </a>
</p>

Bundle `hd-idle` application to run in a docker environment.

- Maintained by [Patrick Weiss](https://github.com/tekgator)
- Problems and issues can be filed on the [Github repository](https://github.com/tekgator/docker-hd-idle/issues)

## buy-me-a-coffee
Like some of my work? Buy me a coffee ☕ (or more likely a beer 🍺, or even more likly shoes 👠 or purse 👜 for the wify 😄)

<a href="https://www.buymeacoffee.com/tekgator" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

## Description

`hd-idle` is a utility program for spinning-down external disks after a period of idle time. Since most external IDE disk enclosures don't support setting the IDE idle timer, a program like hd-idle is required to spin down idle disks automatically.

The goal of this docker image is to make the use of `hd-idle` an easy. The configuration of the application can either be done via environment variables or via a config file in a mounted volume.

## Implementations

The image implements the 2 available hd-idle versions:

1. The Golang implementation by [Andoni del Olmo](https://github.com/adelolmo). The **[documentation](https://github.com/adelolmo/hd-idle)** and source code can be found on Github repository page.

2. The orignal (legacy) implementation by [Christina Mueller](https://sourceforge.net/u/cjmueller/profile/). The **[documentation](http://hd-idle.sourceforge.net/)** can be found on the Sourceforge page. This version can be used by setting `LEGACY=1` environment variable. 

For any configuartion topics concerning `hd-idle` I recommend visiting either project site.

Many thanks to to both of them for this great tool!

## Supported tags and respective `Dockerfile` links

* [`1.2.0`, `latest`](https://github.com/tekgator/docker-hd-idle/blob/main/Dockerfile):  Golang version 1.13 and legacy version 1.05

* [`dev`](https://github.com/tekgator/docker-hd-idle/blob/main/Dockerfile): Development build

## Word of cautions

In order to set the disks in stand-by the container needs to be in `privileged` mode and the `/dev` path has to be forwarded to the container. Of course that could be a potential security risk. For me personally, I can live with it in my homelab setup.

## Run

### Basic run command to get things up and running

```bash
docker run -d \
  --name hd-idle \
  --privileged \
  -v /dev:/dev \
  tekgator/docker-hd-idle:latest
``` 

This will run the container with default settings, no configuration possible. All Hard drives will spin down after 10 minutes inactivity.

### Configuration option 1: Map to volume

```bash
docker run -d \
  --name hd-idle \
  --privileged \
  -v /dev:/dev \
  -v /path_to_config/hd-idle:/config \
  tekgator/docker-hd-idle:latest
``` 

On first start of the container it will create a config file in the provided volume. Make adjustments as described in the `hd-idle` **documentation** and restart the container afterwards to apply the changes.

### Configuration option 2: Setting environment variables

```bash
docker run -d \
  --name hd-idle \
  --privileged \
  -v /dev:/dev \
  -e IDLE_TIME='0' \ # Optional: set default stand-by for all disks, e.g. 0 for turn off
  -e DISK_ID1='/dev/disk/by-uuid/994dffb1-96f0-4440-9ee1-4711' \
  -e IDLE_TIME1='900' \ # Optional (default 600s): if disk is idle 900s go into stand-by
  -e DISK_CMD1='ata' \ # Optional (default: scsi): which API to use to communicate with the device (not evaluated in legacy version)
  -e DISK_ID2='/dev/disk/by-uuid/fa376393-91e4-4d9f-8914-4712' \
  tekgator/docker-hd-idle:latest
``` 

Configurations for certain disks can be made by utilizing environment variables. For each disk setting just increase the number on the variable, e.g. if you like to add a third disk to the config just add **DISK_ID3** and so on.

In this example we are creating the following config:
- Turn off stand-by for all disks by using `IDLE_TIME='0'`
- Create a special stand-by rule for `DISK_ID1='/dev/disk/by-uuid/994dffb1-96f0-4440-9ee1-4711'` with stand-by time after 15 minutes by utilizting `IDLE_TIME1='900'`. To set the disk into stand-by the ATA command set is used `DISK_CMD1=ata`.
- Create a special stand-by rule for `DISK_ID2='/dev/disk/by-uuid/fa376393-91e4-4d9f-8914-4712'` with stand-by time after 10 minutes as default time.

### Configuration option 3: Utilize config file and environment together

Just combine option 1 and 2 togehter. At first start up a config file is created in the mounted volume with the passed environment variables. Afterwards the config file can be adjusted to your needs. As mentioned already the config file will be parsed on container startup.

### Legacy version

If you like to use the legacy hd-idle version you can achive this by setting the environment variable `LEGACY=1` like so:

```bash
docker run -d \
  --name hd-idle \
  --privileged \
  -v /dev:/dev \
  -e LEGACY='1' \
  tekgator/docker-hd-idle:latest
``` 

**Note:** If you previously utilized the flags `-c` and `-s` from the Golang version it needs to be removed from the config. Otherwise legacy `hd-idle` will not start. But this can also be seen in the log.

## Use with docker-compose

A [sample](docker-compose.yml) docker-compose file can be found within the repository. Also the [test cases](test) are worth a look.

```yml
  hd-idle:
    image: tekgator/docker-hd-idle:latest
    container_name: hd-idle
    privileged: true
    environment:
      # LEGACY: 1    #uncomment to use legacy version of hd-idle
      IDLE_TIME: 0
      DISK_ID1: /dev/disk/by-uuid/994dffb1-96f0-4440-9ee1-4711
      DISK_CMD1: ata
      IDLE_TIME1: 900
      DISK_ID2: /dev/disk/by-uuid/fa376393-91e4-4d9f-8914-4712
    volumes:
      - /dev:/dev
      - ./config:/config
    restart: unless-stopped
``` 

## Additional info

* Shell access whilst the container is running: `docker exec -it hd-idle /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f hd-idle`