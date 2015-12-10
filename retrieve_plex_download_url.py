#!/usr/bin/env python
'''
Retrieves the latests Plex Media Server PlexPass downlaod URL for Debian 64-bit.
'''
import os
import sys
try:
    import mechanize
except ImportError:
    sys.stderr.write('You need to install the "Mechanize" Python package.\n')
    sys.exit(1)

__author__ = 'Werner Beroux <werner@beroux.com>'


def retrieve_latest_download_url(login, password):
    browser = mechanize.Browser()
    
    # Ignore robots by default
    browser.set_handle_robots(False)

    if login and password:
        sys.stderr.write('Retrieving the latest Plex release for PlexPass users...\n')
        browser.open('https://plex.tv/users/sign_in')
        browser.select_form(nr=0)
        browser['user[login]'] = login
        browser['user[password]'] = password
        browser.submit()

        browser.open('https://plex.tv/downloads?channel=plexpass')
    else:
        sys.stderr.write('Retrieving latest public Plex release...\n')
        browser.open('https://plex.tv/downloads')

    links = [link for link in browser.links() if '.deb' in link.url and link.text == '64-bit']
    assert len(links) == 1
    link = links[0]
    return link.absolute_url


if __name__ == '__main__':
    login = os.environ.get('PLEXPASS_LOGIN')
    password = os.environ.get('PLEXPASS_PASSWORD')
    if bool(login) != bool(password):
        sys.stderr.write('To get the latest release for Plex Pass users, you must provide "PLEXPASS_LOGIN" and "PLEXPASS_PASSWORD" environment variables.\n')
        sys.exit(1)
    print(retrieve_latest_download_url(login, password))
