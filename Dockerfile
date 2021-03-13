# build image
FROM debian:buster-slim

ENV \
  APP_PATH="/app" \
  CONFIG_PATH="/config"

# Install required packages
RUN \
  apt-get update && apt-get install -y --no-install-recommends dumb-init curl ca-certificates htop && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install hd-idle
RUN \
  cd /tmp && \
  curl -o hd-idle.deb -L https://github.com/adelolmo/hd-idle/releases/download/v1.13/hd-idle_1.13_amd64.deb && \
  dpkg -i *.deb && \
  rm -rf /tmp/* /var/tmp/*

# Copy local files to image and allow read and execution of all scripts
COPY app/ /app/
RUN chmod -v a+rx $APP_PATH/*.sh

# Create config path and change dir
WORKDIR ${CONFIG_PATH}

# Start up
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/app/docker-entrypoint.sh"]