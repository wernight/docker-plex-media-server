#!/bin/sh -e

# Delete PID file (we don't use that)
if [ -f /config/Plex\ Media\ Server/plexmediaserver.pid ]
then
    rm -f /config/Plex\ Media\ Server/plexmediaserver.pid
fi

# Set the stack size
ulimit -s $PLEX_MAX_STACK_SIZE

exec "$@"
