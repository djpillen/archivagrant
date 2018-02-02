#!/usr/bin/env bash

# Install pip and lxml dependencies
apt-get -y install python-pip python-dev libxml2-dev libxslt1-dev zlib1g-dev

# Upgrade it
pip install --upgrade pip

# Set the system to use the upgraded version
rm /usr/bin/pip
ln -s /usr/local/bin/pip /usr/bin/pip

# Install the Python requests library
pip install requests

# Install lxml
pip install lxml