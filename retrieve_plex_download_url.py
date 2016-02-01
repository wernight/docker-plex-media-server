#!/usr/bin/env python
'''
Retrieves the latests Plex Media Server PlexPass download URL for Debian 64-bit.
'''
import json
import os
import re
import sys
import ssl
import time
import traceback
try:
    import mechanize
except ImportError:
    sys.stderr.write('You need to install the "Mechanize" Python package.\n')
    sys.exit(1)

__author__ = 'Werner Beroux <werner@beroux.com>'


class PutRequest(mechanize.Request):
    def get_method(self):
        return 'PUT'


def retrieve_latest_download_url(login, password):
    # Ignore SSL certificate errors (for some versions of SSL only).
    if hasattr(ssl, '_create_default_https_context'):
        ssl._create_default_https_context = ssl._create_unverified_context
    
    browser = mechanize.Browser()
    
    # Ignore robots by default
    browser.set_handle_robots(False)

    # Change language to English.
    browser.open(
        PutRequest('https://plex.tv/language',
        data=json.dumps({'locale': 'en'}),
        headers={'Content-Type': 'application/json'}))

    if login and password:
        sys.stderr.write('Retrieving the latest Plex release for PlexPass Premium users...\n')

        browser.open('https://plex.tv/users/sign_in')
        browser.select_form(nr=0)
        browser['user[login]'] = login
        browser['user[password]'] = password
        browser.submit()

        browser.open('https://plex.tv/downloads?channel=plexpass')
    else:
        sys.stderr.write('Retrieving latest public Plex release...\n')
        browser.open('https://plex.tv/downloads')

    links = [link for link in browser.links() if '.deb' in link.url and re.match(r'64[ -]?[Bb]its?', link.text)]
    assert len(links) == 1
    link = links[0]
    return link.absolute_url


if __name__ == '__main__':
    # Skip update completely?
    skip_update = os.environ.get('PLEX_SKIP_UPDATE')
    if skip_update and skip_update.lower() not in ('no', 'false', '0'):
        print('Skip install of latest Plex because PLEX_SKIP_UPDATE was provided.')
        sys.exit(2)

    # Force downloading a specific URL?
    download_url = os.environ.get('PLEX_FORCE_DOWNLOAD_URL')
    if download_url:
        print(download_url)
    else:
        x_plex_token = os.environ.get('X_PLEX_TOKEN')
        login = os.environ.get('PLEXPASS_LOGIN')
        password = os.environ.get('PLEXPASS_PASSWORD')
        if x_plex_token and (login or password):
            sys.stderr.write('If you provide a "X_PLEX_TOKEN" you do not need to provide a "PLEXPASS_LOGIN" or "PLEXPASS_PASSWORD".\n')
            sys.exit(1)
        if bool(login) != bool(password):
            sys.stderr.write('To get the latest release for Plex Pass users, you must provide "X_PLEX_TOKEN" (see https://support.plex.tv/hc/en-us/articles/204059436), or provide "PLEXPASS_LOGIN" and "PLEXPASS_PASSWORD" environment variables.\n')
            sys.exit(1)

        if login and password:
            # Retrieve download URL using login/password.
            try:
                print(retrieve_latest_download_url(login, password))
            except Exception as ex:
                traceback.print_exc()
                print('')
                sys.stdout.flush()
                sys.stderr.write('\033[31m{}\033[0m\n'.format(ex))
                print('\033[1mTry retrieving the latest wernight/plex-media-server:')
                print('')
                print('  $ docker pull wernight/plex-media-server:autoupdate\033[0m')
                print('')
                sys.stdout.flush()
                if os.isatty(sys.stdin.fileno()):
                    print('** Press ENTER to continue, or Ctrl+C to stop here **')
                    sys.stdin.readline()
                else:
                    print('** Waiting for 30 seconds... **')
                    time.sleep(30)
                sys.exit(2)
        else:
            download_url = 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu'
            if x_plex_token:
                download_url += '&X-Plex-Token={}'.format(x_plex_token)
            print(download_url)
