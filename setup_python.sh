#!/usr/bin/env bash

# Update packages
apt-get -y update

# Install pip, upgrade it, and add a symbolic link to use the latest version
apt-get -y install python-pip
pip install --upgrade pip
rm /usr/bin/pip
ln -s /usr/local/bin/pip /usr/bin/pip

# Install the python requests library
pip install requests