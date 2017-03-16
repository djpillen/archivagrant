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
mkdir /aspace
mkdir /aspace/source
mkdir /aspace/zips
cd /aspace/source
git clone https://github.com/archivesspace/archivesspace.git
cd /aspace/zips
wget -nv https://github.com/archivesspace/archivesspace/releases/download/v1.5.3/archivesspace-v1.5.3.zip
cd /aspace
unzip /aspace/zips/archivesspace-v1.5.3.zip

chown -R vagrant:vagrant /aspace

# Setting up ArchivesSpace from source
DEVDBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/aspacedev?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
cd /aspace/source/archivesspace/common/config
echo $DEVDBURL >> config.rb
cd /aspace/source/archivesspace
build/run bootstrap
build/run db:migrate

# These variables will be used to edit the ArchivesSpace config file to use the correct database URL and setup our plugins
DBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/archivesspace?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
BROWSEURL='AppConfig[:browse_page_db_url] = "jdbc:mysql://localhost:3306/browse_pages?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
PLUGINS="AppConfig[:plugins] = ['bhl_browse_pages', 'timewalk', 'bhl_aspace_translations', 'bhl-ead-importer','bhl-ead-exporter','aspace-jsonmodel-from-format','donor_details', 'generate_bhl_identifiers']"
PUBLIC="AppConfig[:enable_public] = false"
FRONTEND="AppConfig[:enable_frontend] = true"

echo "Installing plugins"
cd /aspace/archivesspace/plugins
echo "Installing BHL EAD Importer and Exporter"
git clone https://github.com/bentley-historical-library/bhl-ead-importer.git
git clone https://github.com/bentley-historical-library/bhl-ead-exporter.git

echo "Installing BHL Donor Details plugin"
git clone https://github.com/bentley-historical-library/donor_details.git

echo "Installing BHL Identifier plugin"
git clone https://github.com/bentley-historical-library/generate_bhl_identifiers.git

echo "Installing BHL ASpace Translations plugin"
git clone https://github.com/bentley-historical-library/bhl_aspace_translations.git

echo "Installing BHL Browse Pages plugin"
git clone https://github.com/bentley-historical-library/bhl_browse_pages.git

echo "Installing Mark Cooper's JSONModel from Format plugin"
git clone https://github.com/bentley-historical-library/aspace-jsonmodel-from-format.git

echo "Installing Alexander Duryee's Timewalk plugin"
git clone https://github.com/alexduryee/timewalk.git

echo "Installing mysql java connector"
# http://archivesspace.github.io/archivesspace/user/running-archivesspace-against-mysql/
cd /aspace/archivesspace/lib
wget -nv http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.39/mysql-connector-java-5.1.39.jar

echo "Editing config"
cd /aspace/archivesspace/config

# Edit the config file to use the MySQL database, setup our plugins, and disable the public and staff interfaces
# http://stackoverflow.com/questions/14643531/changing-contents-of-a-file-through-shell-script
sed -i "s@#AppConfig\[:db_url\].*@$DBURL@" config.rb
sed -i "s@#AppConfig\[:plugins\].*@$PLUGINS@" config.rb
sed -i "s@#AppConfig\[:enable_public\].*@$PUBLIC@" config.rb
sed -i "s@#AppConfig\[:enable_frontend\].*@$FRONTEND@" config.rb

echo $BROWSEURL >> config.rb

echo "Setting up database and starting ArchivesSpace"
# First, make the setup-database.sh and archivesspace.sh scripts executable
cd /aspace/archivesspace/scripts
chmod +x setup-database.sh
cd /aspace/archivesspace
chmod +x archivesspace.sh

echo "Setting up database"
scripts/setup-database.sh

echo "Adding ArchivesSpace to system startup"
cd /etc/init.d
ln -s /aspace/archivesspace/archivesspace.sh archivesspace

update-rc.d archivesspace defaults
update-rc.d archivesspace enable

cd /aspace/archivesspace

echo "Starting ArchivesSpace"
./archivesspace.sh start

echo "All done!"
echo "Set up ArchivesSpace defaults (or import an ASpace mysql dump) and point your host machine's browser to http://localhost:8080 to begin using ArchivesSpace"
echo "Use vagrant ssh to access the virtual machine"
