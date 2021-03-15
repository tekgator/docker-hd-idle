# build image legacy version
FROM debian:buster-slim as build-legacy

ARG HD_IDLE_VERSION="1.05"

WORKDIR /src

# Install required build packages
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends curl ca-certificates debhelper build-essential

# download and unpack hd-idle
RUN  \ 
  cd /src && \
  curl -o hd-idle.tgz -L https://sourceforge.net/projects/hd-idle/files/hd-idle-${HD_IDLE_VERSION}.tgz && \
  tar -xzvf hd-idle.tgz && \
  cd hd-idle && \
  dpkg-buildpackage && \
  dpkg -i ../hd-idle_*.deb



# download image golang version
FROM debian:buster-slim as download-golang

ARG HD_IDLE_VERSION="1.13"

# Install required packages
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends curl ca-certificates

# Install hd-idle
RUN \
  cd /tmp && \
  curl -o hd-idle.deb -L https://github.com/adelolmo/hd-idle/releases/download/v${HD_IDLE_VERSION}/hd-idle_${HD_IDLE_VERSION}_amd64.deb && \
  dpkg -i *.deb



# bin image
FROM debian:buster-slim as bin

ENV \
  APP_PATH="/app" \
  CONFIG_PATH="/config"

# Install required packages
RUN \
  apt-get update && apt-get install -y --no-install-recommends dumb-init && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Copy hd-idle from build and download image 
COPY --from=build-legacy /usr/sbin/hd-idle /usr/sbin/hd-idle.legacy
COPY --from=download-golang /usr/sbin/hd-idle /usr/sbin/hd-idle
RUN chmod -v a+rx /usr/sbin/hd-idle*

# Copy local files to image and allow read and execution of all scripts
COPY app/ /app/
RUN chmod -v a+rx $APP_PATH/*.sh

# Create config path and change dir
WORKDIR ${CONFIG_PATH}

# Start up
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/docker-entrypoint.sh"]