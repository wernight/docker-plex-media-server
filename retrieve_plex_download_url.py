#!/usr/bin/env python
import argparse
import re
import sys
try:
    import mechanize
except ImportError:
    sys.stderr.write('You need to install the "Mechanize" Python package.\n')
    sys.exit(1)

__author__ = 'Werner Beroux <werner@beroux.com>'


def retrieve_latest_download_url(login, password):
    browser = mechanize.Browser()

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


def update_download_url_in_dockerfile(f, download_url):
    # Search & replace
    regex = re.compile(r"(?<=DOWNLOAD_URL=')[^']*(?=')")
    lines = [regex.sub(download_url, line) for line in f.readlines()]

    # Replace content
    f.seek(0)
    f.truncate()
    f.writelines(lines)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Retrieves the latests Plex Media Server PlexPass downlaod URL for Debian 64-bit.')
    parser.add_argument('login')
    parser.add_argument('password')
    args = parser.parse_args()

    print(retrieve_latest_download_url(args.login, args.password))
