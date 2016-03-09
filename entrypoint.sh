#!/bin/sh -e

# Delete PID file (we don't use that)
if [ -f /config/Plex\ Media\ Server/plexmediaserver.pid ]
then
    rm -f /config/Plex\ Media\ Server/plexmediaserver.pid
fi

# Get plex token if PLEX_USERNAME and PLEX_PASSWORD are define
[ "${PLEX_USERNAME}" ] && [ "${PLEX_PASSWORD}" ] && {

  # Ask Plex.tv a token key
  TOKEN=$(curl -u "${PLEX_USERNAME}":"${PLEX_PASSWORD}" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 0.9' \
    -H 'X-Plex-Platform-Version: 0.9' \
    -H 'X-Plex-Platform: xcid' \
    -H 'X-Plex-Product: Plex Media Server'\
    -H 'X-Plex-Device: Linux'\
    -H 'X-Plex-Client-Identifier: XXXX' --compressed | sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p')

  if [ ! -f /config/Plex\ Media\ Server/Preferences.xml ]; then
    mkdir -p /config/Plex\ Media\ Server
    cp /Preferences.xml /config/Plex\ Media\ Server/Preferences.xml
  fi

  if [ ! $(xmlstarlet sel -T -t -m "/Preferences" -v "@PlexOnlineToken" -n /config/Plex\ Media\ Server/Preferences.xml) ]; then
    xmlstarlet ed --inplace --insert "Preferences" --type attr -n PlexOnlineToken -v ${TOKEN} /config/Plex\ Media\ Server/Preferences.xml
  fi

  if [ "${PLEX_EXTERNALPORT}" ]; then
    xmlstarlet ed --inplace --insert "Preferences" --type attr -n ManualPortMappingPort -v ${PLEX_EXTERNALPORT} /config/Plex\ Media\ Server/Preferences.xml
  fi

}

# Set the stack size
ulimit -s $PLEX_MAX_STACK_SIZE

exec "$@"
