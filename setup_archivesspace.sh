#!/usr/bin/env bash

echo "Installing dependencies"
apt-get -y install openjdk-7-jdk
apt-get -y install unzip
apt-get -y install git
apt-get -y install curl

echo "Downloading latest ArchivesSpace release"
# Use a Python script to download the latest ArchivesSpace release, because this is the only way that I know how
#cd /vagrant
#python download_latest_archivesspace.py

# Sometimes I want to download a release candidate. Uncomment the below lines, add the direct link to the release candidate, and comment out the above python script
cd /home/vagrant
wget https://github.com/archivesspace/archivesspace/releases/download/v1.5.0-RC2/archivesspace-v1.5.0-RC2.zip
unzip archivesspace-v1.5.0-RC2.zip

# These variables will be used to edit the ArchivesSpace config file to use the correct database URL and setup our plugins
DBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/archivesspace?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
PLUGINS="AppConfig[:plugins] = ['bhl-ead-importer','bhl-ead-exporter','aspace-jsonmodel-from-format','donor_details']" #'container_management'
PUBLIC="AppConfig[:enable_public] = false"
FRONTEND="AppConfig[:enable_frontend] = true"

echo "Installing plugins"
cd /home/vagrant

#echo "Installing container management"
# Grab a release instead of cloning the repo to make sure it's a version compatible with latest ArchivesSpace releases
#wget https://github.com/hudmol/container_management/releases/download/1.1/container_management-1.1.zip
#unzip container_management-1.1.zip -d /home/vagrant/archivesspace/plugins

cd archivesspace/plugins
echo "Installing BHL EAD Importer and Exporter"
git clone https://github.com/bentley-historical-library/bhl-ead-importer.git
git clone https://github.com/bentley-historical-library/bhl-ead-exporter.git

echo "Installing BHL Donor Details Plugin"
git clone https://github.com/bentley-historical-library/donor_details.git

echo "Installing Mark Cooper's JSONModel from Format plugin"
git clone https://github.com/bentley-historical-library/aspace-jsonmodel-from-format.git

echo "Installing mysql java connector"
# http://archivesspace.github.io/archivesspace/user/running-archivesspace-against-mysql/
cd /home/vagrant/archivesspace/lib
wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.37/mysql-connector-java-5.1.37.jar

echo "Editing config"
cd /home/vagrant/archivesspace/config

# Edit the config file to use the MySQL database, setup our plugins, and disable the public and staff interfaces
# http://stackoverflow.com/questions/14643531/changing-contents-of-a-file-through-shell-script
sed -i "s@#AppConfig\[:db_url\].*@$DBURL@" config.rb
sed -i "s@#AppConfig\[:plugins\].*@$PLUGINS@" config.rb
sed -i "s@#AppConfig\[:enable_public\].*@$PUBLIC@" config.rb
sed -i "s@#AppConfig\[:enable_frontend\].*@$FRONTEND@" config.rb

echo "Setting up database and starting ArchivesSpace"
# First, make the setup-database.sh and archivesspace.sh scripts executable
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

#echo "Set up ArchivesSpace defaults"
#cd /vagrant
#python archivesspace_defaults.py

echo "All done!"
echo "Set up ArchivesSpace defaults and point your host machine's browser to http://localhost:8080 to begin using ArchivesSpace"
echo "Use vagrant ssh to access the virtual machine"