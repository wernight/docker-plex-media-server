#!/bin/sh -e

# Legacy environment variables support.
if [ -n "$PLEX_USERNAME" ]; then
    echo "WARNING: 'PLEX_USERNAME' has been deprecated and is now called 'PLEX_LOGIN'."
    PLEX_LOGIN="$PLEX_USERNAME"
    unset PLEX_USERNAME
fi

if [ -n "$PLEXPASS_LOGIN" ]; then
    echo "WARNING: 'PLEXPASS_LOGIN' has been deprecated and is now called 'PLEX_LOGIN'."
    PLEX_LOGIN="$PLEXPASS_LOGIN"
    unset PLEXPASS_LOGIN
fi

if [ -n "$PLEXPASS_PASSWORD" ]; then
    echo "WARNING: 'PLEXPASS_PASSWORD' has been deprecated and is now called 'PLEX_PASSWORD'."
    PLEX_PASSWORD="$PLEXPASS_PASSWORD"
    unset PLEXPASS_PASSWORD
fi

if [ -n "$PLEX_EXTERNALPORT" ]; then
    echo "WARNING: 'PLEXEXTERNALPORT' has been deprecated and is now called 'PLEX_EXTERNAL_PORT'."
    PLEX_EXTERNAL_PORT="$PLEXPASS_EXTERNALPORT"
    unset PLEXPASS_EXTERNALPORT
fi

# Delete PID file (we don't use that)
if [ -f /config/Plex\ Media\ Server/plexmediaserver.pid ]; then
    rm -f /config/Plex\ Media\ Server/plexmediaserver.pid
fi

# Get plex token if Plex username and password are defined.
if [ -n "$PLEX_LOGIN" ] && [ -n "$PLEX_PASSWORD" ]; then
    # Retrieve a token from Plex.tv
    X_PLEX_TOKEN=$(curl -u "${PLEX_LOGIN}":"${PLEX_PASSWORD}" 'https://plex.tv/users/sign_in.xml' \
        -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
        -H 'X-Plex-Provides: server' \
        -H 'X-Plex-Version: 0.9' \
        -H 'X-Plex-Platform-Version: 0.9' \
        -H 'X-Plex-Platform: xcid' \
        -H 'X-Plex-Product: Plex Media Server'\
        -H 'X-Plex-Device: Linux'\
        -H 'X-Plex-Client-Identifier: XXXX' --compressed | sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p')
fi

# Default Preferences.
if [ ! -f /config/Plex\ Media\ Server/Preferences.xml ]; then
    mkdir -p /config/Plex\ Media\ Server
    cp /Preferences.xml /config/Plex\ Media\ Server/Preferences.xml
fi

# Sets PlexOnlineToken in Preferences.xml if provided.
if [ -n "$X_PLEX_TOKEN" ]; then
    #if [ ! $(xmlstarlet sel -T -t -m "/Preferences" -v "@PlexOnlineToken" -n /config/Plex\ Media\ Server/Preferences.xml) ]; then
        xmlstarlet ed --inplace --insert "Preferences" --type attr -n PlexOnlineToken -v ${X_PLEX_TOKEN} /config/Plex\ Media\ Server/Preferences.xml
    #fi
fi

# Sets ManualPortMappingPort in Preferences.xml if provided.
if [ -n "$PLEX_EXTERNAL_PORT" ]; then
    xmlstarlet ed --inplace --insert "Preferences" --type attr -n ManualPortMappingMode -v 1 /config/Plex\ Media\ Server/Preferences.xml
    xmlstarlet ed --inplace --insert "Preferences" --type attr -n ManualPortMappingPort -v ${PLEX_EXTERNAL_PORT} /config/Plex\ Media\ Server/Preferences.xml
fi

# Unset any environment variable we used (just for safety as we don't need them anymore).
unset PLEX_LOGIN
unset PLEX_PASSWORD
unset PLEX_EXTERNAL_PORT
unset X_PLEX_TOKEN

echo "Starting Plex..."

# Output logs to stdout.
mkdir -p '/config/Plex Media Server/Logs'
touch '/config/Plex Media Server/Logs/Plex Media Server.log'
(sleep 2 && tail -f '/config/Plex Media Server/Logs/Plex Media Server.log') &

# Set the stack size
ulimit -s $PLEX_MAX_STACK_SIZE

exec "$@"
