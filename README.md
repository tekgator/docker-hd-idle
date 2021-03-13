# docker-hd-idle

Bundle `hd-idle` application to run in a docker environment.

## Description

`hd-idle` is a utility program for spinning-down external disks after a period of idle time. Since most external IDE disk enclosures don't support setting the IDE idle timer, a program like hd-idle is required to spin down idle disks automatically.

The goal of this docker image is to make the use of `hd-idle` an easy. The configuration of the application can either be done via environment variables or via a config file in a mounted volume.

As an implemantation for `hd-idle` I have choosen [adelolmo's](https://github.com/adelolmo) version over the original [hd-idle](http://hd-idle.sourceforge.net) version, just because it implements more features and apperantly more logging which is nice to have in a docker environment.

For any configuartion topics concerning `hd-idle` I recommend visiting *adelolmo's* repository as you can find a good documentation there.

`hd-idle` repository: [adelolmo/hd-idle](https://github.com/adelolmo/hd-idle)

## Run

### Basic run command to get things up and running

```bash
docker run -d \
  --name hd-idle \
  --restart unless-stopped \
  tekgator/docker-hd-idle:latest
``` 

This will run the container with default settings, no configuration possible. All Hard drives will spin down after 10 minutes inactivity.

### Configuration option 1: Map to volume

```bash
docker run -d \
  --name hd-idle \
  -v /host_machine/hd-idle:/config
  tekgator/docker-hd-idle:latest
``` 

On first start of the container it will create a config file in the provided volume. Make adjustments as described in the `hd-idle` [repository](https://github.com/adelolmo/hd-idle]) and restart the container afterwards to apply the changes.


#### Configuration option 2: Setting environment variables

```bash
docker run -d \
  --name hd-idle \
  -e IDLE_TIME='0' # Optional: set default stand-by for all disks, e.g. 0 for turn off
  -e DISK_ID1='/dev/disk/by-uuid/994dffb1-96f0-4440-9ee1-4711' # 
  -e DISK_CMD1='scsi' # Optional (default ATA): mode on how to send HDD into stand-by, see hd-idle doc
  -e IDLE_TIME1='900' # Optional (default 600s): if disk is idle 900s go into stand-by
  -e DISK_ID2='/dev/disk/by-uuid/fa376393-91e4-4d9f-8914-4712'
  tekgator/docker-hd-idle:latest
``` 

Special configurations for certain disks can be made by utilizing environment variables. For each disk setting just increase the number on the variable, e.g. if you like to add a third disk to the config just add **DISK_ID3** and so on.

In this example we will create the following config:
- Turn off stand-by for all disks by using **IDLE_TIME='0'**
- Create a special stand-by rule for **DISK_ID1='/dev/disk/by-uuid/994dffb1-96f0-4440-9ee1-4711'** with stand-by time after 15 minutes by utilizting **IDLE_TIME1='900'**. The SCSI command set is to be used to force the HDD into stand-by **DISK_CMD1='scsi'**.
- Create a special stand-by rule for **DISK_ID2='/dev/disk/by-uuid/fa376393-91e4-4d9f-8914-4712'** with stand-by time after 10 minutes as default time. The ATA command set is to be used to force the HDD into stand-by by default.

#### Configuration option 3: Utilize config file and environment together

Just combine option 1 and 2 togehter. At first start up a config file is created in the mounted volume with the passed environment variables. Afterwards the config file can be adjusted to your needs. As mentioned already the config file will be parsed on container startup.

### Use with docker-compose:

A [sample](docker-compose.yml) docker-compose file can be found within the repository. Also the [test cases](test) are worth a look.

```yml
  hd-idle:
    image: tekgator/docker-hd-idle:latest
    container_name: hd-idle
    environment:
      IDLE_TIME: 0
      DISK_ID1: /dev/disk/by-uuid/994dffb1-96f0-4440-9ee1-4711
      DISK_CMD1: SCSI
      IDLE_TIME1: 30
      DISK_ID2: /dev/disk/by-uuid/fa376393-91e4-4d9f-8914-4712
    volumes:
      - ./config:/config
    restart: unless-stopped
``` 

## Additional info

* Shell access whilst the container is running: `docker exec -it hd-idle /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f hd-idle`