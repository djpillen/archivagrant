#!/usr/bin/env bash


# http://stackoverflow.com/questions/18812293/vagrant-ssh-provisioning-mysql-password

echo "mysql-server mysql-server/root_password password rootpwd" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password rootpwd" | debconf-set-selections

# https://gist.github.com/rrosiek/8190550

apt-get -y install mysql-server

mysql -uroot -prootpwd -e "create database archivesspace"
mysql -uroot -prootpwd -e "grant all on archivesspace.* to 'as'@'localhost' identified by 'as123'"
