FROM debian:wheezy

# Install required packages
RUN apt-get update && apt-get install -y curl

# Download and install Plex (non plexpass)
# This gets the latest non-plexpass version
RUN curl -Ls `curl -Ls https://plex.tv/downloads | grep -o '[^"'"'"']*amd64.deb' | grep -v binaries` -o plexmediaserver.deb
RUN dpkg -i plexmediaserver.deb
RUN rm -f plexmediaserver.deb

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
CMD ulimit -s $PLEX_MAX_STACK_SIZE && ./Plex\ Media\ Server
