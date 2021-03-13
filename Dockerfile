# build image
FROM debian:buster-slim as build

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
  dpkg-buildpackage

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

# Install hd-idle
COPY --from=build /src/*.deb /tmp/
RUN \
  cd /tmp && \
  dpkg -i hd-idle_*.deb && \
  rm -rf /tmp/* /var/tmp/*

# Copy local files to image and allow read and execution of all scripts
COPY app/ /app/
RUN chmod -v a+rx $APP_PATH/*.sh

# Create config path and change dir
WORKDIR ${CONFIG_PATH}

# Start up
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/docker-entrypoint.sh"]