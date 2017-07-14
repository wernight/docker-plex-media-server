FROM debian:stretch-slim

# Install basic required packages.
RUN set -x \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        dumb-init \
        xmlstarlet \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN set -x \
    # Upgrade to get possible critical fixes.
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
    # Create plex user
 && useradd --system --uid 797 --create-home --shell /usr/sbin/nologin plex \
    # Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
    # We won't use upstart anyway.
 && touch /bin/start \
 && chmod +x /bin/start \
 && touch /bin/stop \
 && chmod +x /bin/stop \
    # Create writable config directory in case the volume isn't mounted
 && mkdir /config \
 && chown plex:plex /config

# PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS: The number of plugins that can run at the same time.
# PLEX_MEDIA_SERVER_MAX_STACK_SIZE: Used for "ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE".
# PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR: defines the location of the configuration directory,
#   default is "${HOME}/Library/Application Support".
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6 \
    PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000 \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/config \
    PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver \
    LD_LIBRARY_PATH=/usr/lib/plexmediaserver \
    TMPDIR=/tmp \
    PLEXPASS_LOGIN='' \
    PLEXPASS_PASSWORD=''

# Temporary workound
# https://github.com/wernight/docker-plex-media-server/issues/38
RUN ln -sf $(which true) /sbin/udevadm

COPY root /

VOLUME ["/config", "/media"]

EXPOSE 32400

WORKDIR /usr/lib/plexmediaserver
ENTRYPOINT ["dumb-init", "/plex-autoupdate-entrypoint.sh"]
CMD ["/install_run_plex.sh"]
