#!/bin/sh -ex

# Download and install Plex Media Server
curl -L $(/retrieve_plex_download_url.py) -o plexmediaserver.deb
dpkg -i plexmediaserver.deb

# Clean-up (we also don't need the PlexPass login/password after this point
# so it's safer if we also unset them).
unset PLEXPASS_LOGIN
unset PLEXPASS_PASSWORD
rm -f plexmediaserver.deb
