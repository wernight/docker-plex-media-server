FROM debian:jessie

# Install required packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*

# Create plex user
RUN useradd --system --uid 797 -M --shell /usr/sbin/nologin plex

# Download and install Plex (non plexpass)
# This gets the latest plexpass version
# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
# We won't use upstart anyway.
RUN apt-get -q update && \
    VERSION=$(curl -s https://tools.linuxserver.io/latest-plex.json| grep "version" | cut -d '"' -f 4) && \
    apt-get install -qy dbus gdebi-core avahi-daemon wget && \
    wget -P /tmp "https://downloads.plex.tv/plex-media-server/$VERSION/plexmediaserver_${VERSION}_amd64.deb" && \
    touch /bin/start && \
    chmod +x /bin/start && \
    gdebi -n /tmp/plexmediaserver_${VERSION}_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /tmp/plexmediaserver_${VERSION}_amd64.deb && \
    rm -f /bin/start

# Create writable config directory in case the volume isn't mounted
RUN mkdir /config
RUN chown plex:plex /config

VOLUME /config
VOLUME /media

USER plex

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

WORKDIR /usr/lib/plexmediaserver
CMD test -f /config/Plex\ Media\ Server/plexmediaserver.pid && rm -f /config/Plex\ Media\ Server/plexmediaserver.pid; \
    ulimit -s $PLEX_MAX_STACK_SIZE && ./Plex\ Media\ Server
