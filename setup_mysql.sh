#!/usr/bin/env bash

# Export MySQL root password before installing to prevent MySQL from prompting for a password during the installation process
# http://stackoverflow.com/questions/18812293/vagrant-ssh-provisioning-mysql-password
echo "mysql-server mysql-server/root_password password rootpwd" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password rootpwd" | debconf-set-selections

# Install mysql-server and create the archivesspace database
# http://archivesspace.github.io/archivesspace/user/running-archivesspace-against-mysql/
# https://gist.github.com/rrosiek/8190550
apt-get -y install mysql-server
mysql -uroot -prootpwd -e "create database archivesspace"
mysql -uroot -prootpwd -e "grant all on archivesspace.* to 'as'@'localhost' identified by 'as123'"
