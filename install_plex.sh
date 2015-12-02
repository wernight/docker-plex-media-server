#!/bin/sh -ex

# Download and install Plex Media Server
DOWNLOAD_URL=$(/retrieve_plex_download_url.py "$PLEXPASS_LOGIN" "$PLEXPASS_PASSWORD")
curl -L $DOWNLOAD_URL -o plexmediaserver.deb
dpkg -i plexmediaserver.deb

# Clean-up (we also don't need the PlexPass login/password after this point
# so it's safer if we also unset them).
unset PLEXPASS_LOGIN
unset PLEXPASS_PASSWORD
rm -f plexmediaserver.deb
