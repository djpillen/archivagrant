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

# Install the python requests library
pip install requests