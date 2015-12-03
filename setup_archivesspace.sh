#!/usr/bin/env bash


echo "Installing java"
apt-get -y install default-jre

DBURL='jdbc:mysql://localhost:3306/archivesspace\?user\=as\&password=as123\&useUnicode=true\&characterEncoding\=UTF\-8'
PLUGINS="\['bhl-ead-importer','bhl-ead-exporter','container_management','aspace_jsonmodel_from_format'\]"

cd /vagrant

echo "Downloading latest ArchivesSpace release"
python download_latest_archivesspace.py

echo "Installing plugins"
apt-get -y install unzip
apt-get -y install git

cd /home/vagrant

wget https://github.com/hudmol/container_management/releases/download/1.1/container_management-1.1.zip

unzip container_management-1.1.zip -d /home/vagrant/archivesspace/plugins

git clone https://github.com/bentley-historical-library/bhl-ead-importer.git /home/vagrant/archivesspace/plugins
git clone https://github.com/bentley-historical-library/bhl-ead-exporter.git /home/vagrant/archivesspace/plugins

cp -avr /vagrant/local/aspace_jsonmodel_from_format /home/vagrant/archivesspace/plugins

cd /home/vagrant/archivesspace/lib

wget -Oq "http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.37/mysql-connector-java-5.1.37.jar"

echo "Editing config"

cd /home/vagrant/archivesspace/config

# http://stackoverflow.com/questions/14643531/changing-contents-of-a-file-through-shell-script

sed -i 's@\#AppConfig\[:db_url\] = .*@AppConfig\[:db_url\] = "'$DBURL'"@' config.rb
sed -i 's@\#AppConfig\[:plugins\] = .*@AppConfig\[:plugins\] = '$PLUGINS'@' config.rb

cd /home/vagrant/archivesspace/scripts

chmod +x setup-database.sh

cd ..

chmod +x archivesspace.sh

echo "Setting up database"
scripts/setup-database.sh

echo "Starting ArchivesSpace"
./archivesspace.sh start