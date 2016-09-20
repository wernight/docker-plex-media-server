#!/bin/sh -e

runuser -u plex /plex-entrypoint.sh

exec "$@"
