#!/usr/bin/env bash

# Update packages
apt-get -y update

# For ruby: https://gorails.com/setup/ubuntu/14.04
apt-get -y install git git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs

# For ArchivesSpace
apt-get install -y openjdk-8-jdk unzip
