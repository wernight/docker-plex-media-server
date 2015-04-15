FROM debian:wheezy

# Install required packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl

# Create plex user
RUN useradd --system --uid 797 -M --shell /usr/sbin/nologin plex

# Hack to avoid install to fail due to upstart not being installed.
# We won't use upstart anyway.
RUN touch /bin/start
RUN chmod +x /bin/start

# Download and install Plex (non plexpass)
# This gets the latest non-plexpass version
RUN curl -Ls `curl -Ls https://plex.tv/downloads | grep -o '[^"'"'"']*amd64.deb' | grep -v binaries` -o plexmediaserver.deb
RUN dpkg -i plexmediaserver.deb
RUN rm -f plexmediaserver.deb

# Hack clean-up
RUN rm -f /bin/start

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
