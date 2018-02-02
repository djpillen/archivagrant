#!/usr/bin/env bash

# RVM
apt-get -y install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source $HOME/.rvm/scripts/rvm || source /etc/profile.d/rvm.sh

# ruby 2.4.0
rvm use --default --install 2.4.0
echo "gem: --no-rdoc --no-ri" >> ~/.gemrc

# gems
gem install bundler
gem install rails -v 5.1.3
gem install sequel
gem install mysql2

rvm cleanup all