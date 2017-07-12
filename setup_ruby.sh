#!/usr/bin/env bash

# https://gorails.com/setup/ubuntu/14.04
apt-get -y update
apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs

# RVM
apt-get -y install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source $HOME/.rvm/scripts/rvm || source /etc/profile.d/rvm.sh

rvm use --default --install 2.4.0

# sequel
gem install bundler
gem install sequel
gem install mysql2

rvm cleanup all