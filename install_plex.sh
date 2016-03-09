#!/bin/sh -x

# Download and install Plex Media Server
DOWNLOAD_URL=$(/retrieve_plex_download_url.py)
if [ $? -eq 2 ]
then
    echo "Skip install because it failed to retrieve latest Plex download URL."
else
    curl -L $DOWNLOAD_URL -o plexmediaserver.deb
    dpkg -i plexmediaserver.deb
    rm -f plexmediaserver.deb
fi

# Clean-up (we also don't need the PlexPass login/password after this point
# so it's safer if we also unset them).
unset X_PLEX_TOKEN
