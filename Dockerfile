FROM debian:jessie

# 1. Create plex user
# 2. Create writable config directory in case the volume isn't mounted
# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
# We won't use upstart anyway.
RUN set -x \
 && useradd --system --uid 797 -M --shell /usr/sbin/nologin plex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python \
        python-mechanize \
        xmlstarlet \
 && touch /bin/start \
 && chmod +x /bin/start \
 && touch /bin/stop \
 && chmod +x /bin/stop \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /config \
 && chown plex:plex /config

# PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS: The number of plugins that can run at the same time.
# $PLEX_MEDIA_SERVER_MAX_STACK_SIZE: Used for "ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE".
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

COPY *.sh *.py Preferences.xml /

VOLUME /config
VOLUME /media

EXPOSE 32400

WORKDIR /usr/lib/plexmediaserver
ENTRYPOINT ["/entrypoint.sh"]
CMD /install_plex.sh && runuser -u plex ./Plex\ Media\ Server
