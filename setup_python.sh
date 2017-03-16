#!/usr/bin/env bash

# Update packages
apt-get -y update

# Install pip
apt-get -y install python-pip

# Upgrade it
pip install --upgrade pip

# Set the system to use the upgraded version
rm /usr/bin/pip
ln -s /usr/local/bin/pip /usr/bin/pip

# Install the Python requests library
pip install requests

# Install lxml and dependencies
apt-get -y install python-dev libxml2-dev libxslt1-dev zlib1g-dev
pip install lxml
