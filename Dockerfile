FROM ubuntu:15.04

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://downloads.plex.tv/plex-media-server/0.9.11.16.958-80f1748/plexmediaserver_0.9.11.16.958-80f1748_amd64.deb -o plexmediaserver.deb
RUN dpkg -i plexmediaserver.deb

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