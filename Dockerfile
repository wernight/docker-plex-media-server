FROM debian:jessie

# 1. Create plex user
# 2. Create writable config directory in case the volume isn't mounted
# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
# We won't use upstart anyway.
RUN useradd --system --uid 797 -M --shell /usr/sbin/nologin plex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates \
        curl \
        python \
        python-mechanize \
 && touch /bin/start \
 && chmod +x /bin/start \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /config \
 && chown plex:plex /config

VOLUME /config
VOLUME /media

EXPOSE 32400

# the number of plugins that can run at the same time
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS 6

# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE 3000

# location of configuration, default is
# "${HOME}/Library/Application Support"
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR /config

ENV PLEX_MEDIA_SERVER_HOME /usr/lib/plexmediaserver
ENV LD_LIBRARY_PATH /usr/lib/plexmediaserver
ENV TMPDIR /tmp

ENV PLEXPASS_LOGIN ''
ENV PLEXPASS_PASSWORD ''

ADD *.sh *.py /

WORKDIR /usr/lib/plexmediaserver
ENTRYPOINT ["/entrypoint.sh"]
CMD /install_plex.sh && runuser -u plex ./Plex\ Media\ Server
