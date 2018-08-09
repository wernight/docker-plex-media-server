#!/bin/sh -e

# Skip update completely?
if [ -n "$PLEX_SKIP_UPDATE" ] && [ "$PLEX_SKIP_UPDATE" != no ] && [ "$PLEX_SKIP_UPDATE" != false ] && [ $PLEX_SKIP_UPDATE != 0 ]; then
    echo 'Skipping install of latest Plex because PLEX_SKIP_UPDATE was provided.'
else

    # Force downloading a specific URL?
    if [ -n "$PLEX_FORCE_DOWNLOAD_URL" ]; then
        echo "Using PLEX_FORCE_DOWNLOAD_URL."
    else
        PLEX_FORCE_DOWNLOAD_URL='https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu'
        if [ -n "$X_PLEX_TOKEN" ]; then
            PLEX_FORCE_DOWNLOAD_URL="${PLEX_FORCE_DOWNLOAD_URL}&X-Plex-Token=${X_PLEX_TOKEN}"
        fi
    fi

    # Download and install Plex Media Server
    echo 'Downloading Plex Media Server...'
    wget -O plexmediaserver.deb $PLEX_FORCE_DOWNLOAD_URL

    echo 'Installing Plex Media Server...'
    dpkg -i plexmediaserver.deb
    rm -f plexmediaserver.deb
fi

# Clean-up (we also don't need the PlexPass login/password after this point
# so it's safer if we also unset them).
unset X_PLEX_TOKEN
unset PLEX_FORCE_DOWNLOAD_URL

echo 'Starting Plex Media Server...'
exec runuser -u plex ./Plex\ Media\ Server
