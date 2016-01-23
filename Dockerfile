FROM debian:jessie

# 1. Create plex user
# 2. Download and install Plex (non plexpass)
# 3. Create writable config directory in case the volume isn't mounted
# This gets the latest non-plexpass version
# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
# We won't use upstart anyway.
RUN useradd --system --uid 797 -M --shell /usr/sbin/nologin plex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xmlstarlet \
 && DOWNLOAD_URL=`curl -Ls https://plex.tv/downloads \
    | grep -o '[^"'"'"']*amd64.deb' \
    | grep -v binaries` \
 && echo $DOWNLOAD_URL \
 && curl -L $DOWNLOAD_URL -o plexmediaserver.deb \
 && touch /bin/start \
 && chmod +x /bin/start \
 && dpkg -i plexmediaserver.deb \
 && rm -f plexmediaserver.deb \
 && rm -f /bin/start \
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

ADD *.sh /

ADD Preferences.xml /Preferences.xml

USER plex

WORKDIR /usr/lib/plexmediaserver
ENTRYPOINT ["/entrypoint.sh"]
CMD ./Plex\ Media\ Server
