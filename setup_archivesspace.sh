#!/usr/bin/env bash


echo "Installing dependencies"
apt-get -y install default-jre
apt-get -y install curl
apt-get -y install unzip
apt-get -y install git

DBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/archivesspace?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
PLUGINS="AppConfig[:plugins] = ['bhl-ead-importer','bhl-ead-exporter','container_management','aspace-jsonmodel-from-format']"

cd /vagrant

echo "Downloading latest ArchivesSpace release"
python download_latest_archivesspace.py

echo "Installing plugins"
cd /home/vagrant

echo "Installing container management"
wget https://github.com/hudmol/container_management/releases/download/1.1/container_management-1.1.zip
unzip container_management-1.1.zip -d /home/vagrant/archivesspace/plugins

echo "Installing BHL EAD Importer and Exporter"
cd archivesspace/plugins
git clone https://github.com/bentley-historical-library/bhl-ead-importer.git
git clone https://github.com/bentley-historical-library/bhl-ead-exporter.git

echo "Installing Mark Cooper's JSONModel from Format plugin"
git clone https://github.com/bentley-historical-library/aspace-jsonmodel-from-format.git

echo "Installing mysql java connector"
cd /home/vagrant/archivesspace/lib
wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.37/mysql-connector-java-5.1.37.jar

echo "Editing config"
cd /home/vagrant/archivesspace/config

# http://stackoverflow.com/questions/14643531/changing-contents-of-a-file-through-shell-script

sed -i "s@#AppConfig\[:db_url\].*@$DBURL@" config.rb
sed -i "s@#AppConfig\[:plugins\].*@$PLUGINS@" config.rb

echo "Setting up database and starting ArchivesSpace"
cd /home/vagrant/archivesspace/scripts
chmod +x setup-database.sh
cd /home/vagrant/archivesspace
chmod +x archivesspace.sh

echo "Setting up database"
scripts/setup-database.sh

echo "Adding ArchivesSpace to system startup"
cd /etc/init.d
ln -s /home/vagrant/archivesspace/archivesspace.sh archivesspace

update-rc.d archivesspace defaults
update-rc.d archivesspace enable

cd /home/vagrant/archivesspace

echo "Starting ArchivesSpace"
./archivesspace.sh start

echo "Setting up ArchivesSpace defaults"
cd /vagrant
python archivesspace_defaults.py

echo "All done!"
echo "Point your host machine's browser to http://localhost:8080 to begin using ArchivesSpace"
echo "vagrant ssh to access the virtual machine"