#!/usr/bin/env bash

# Update packages
apt-get -y update

# For ArchivesSpace, Ruby, Python, etc.
# Ruby installs from here: https://gorails.com/setup/ubuntu/14.04
apt-get -y install automake bison git git-core curl zlib1g-dev build-essential libffi-dev \
        libgdbm-dev libssl-dev  libncurses5-dev libreadline-dev libyaml-dev libsqlite3-dev \
        libtool openjdk-8-jdk sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties unzip

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs