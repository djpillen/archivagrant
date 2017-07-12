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
#cd /aspace/source
#git clone https://github.com/archivesspace/archivesspace.git
cd /aspace/zips
wget https://github.com/archivesspace/archivesspace/releases/download/v1.5.4/archivesspace-v1.5.4.zip
wget https://github.com/archivesspace/archivesspace/archive/v1.5.4.zip
cd /aspace
unzip /aspace/zips/archivesspace-v1.5.4.zip
cd /aspace/source
unzip /aspace/zips/v1.5.4.zip 
mv *1.5.4 archivesspace

# Setting up ArchivesSpace from source
DEVDBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/aspacedev?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
cd /aspace/source/archivesspace/common/config
echo $DEVDBURL >> config.rb
cd /aspace/source/archivesspace 
build/run bootstrap
build/run db:migrate

chown -R vagrant:vagrant /aspace

# These variables will be used to edit the ArchivesSpace config file to use the correct database URL and setup our plugins
DBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/archivesspace?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
BROWSEURL='AppConfig[:browse_page_db_url] = "jdbc:mysql://localhost:3306/browse_pages?user=as\&password=as123\&useUnicode=true\&characterEncoding=UTF-8"'
PLUGINS="AppConfig[:plugins] = ['accession_events', 'aspace-jsonmodel-from-format', 'bhl_accession_readonly_fields', 'bhl_accession_search', 'bhl_aspace_print_template', 'bhl_aspace_reports', 'bhl_aspace_translations', 'bhl_browse_pages', 'bhl-ead-exporter', 'bhl-ead-importer', 'bulk_create_containers', 'donor_details', 'generate_bhl_identifiers', 'timewalk', 'user_defined_in_basic']"
PUBLIC="AppConfig[:enable_public] = false"
FRONTEND="AppConfig[:enable_frontend] = true"

echo "Installing plugins"
cd /aspace/archivesspace/plugins

git clone https://github.com/bentley-historical-library/accession_events.git
git clone https://github.com/bentley-historical-library/aspace-jsonmodel-from-format.git
git clone https://github.com/bentley-historical-library/bhl_accession_readonly_fields.git
git clone https://github.com/bentley-historical-library/bhl_accession_search.git
git clone https://github.com/bentley-historical-library/bhl_aspace_print_template.git
git clone https://github.com/bentley-historical-library/bhl_aspace_reports.git
git clone https://github.com/bentley-historical-library/bhl_aspace_translations.git
git clone https://github.com/bentley-historical-library/bhl_browse_pages.git
git clone https://github.com/bentley-historical-library/bhl-ead-exporter.git
git clone https://github.com/bentley-historical-library/bhl-ead-importer.git
git clone https://github.com/bentley-historical-library/bulk_create_containers.git
git clone https://github.com/bentley-historical-library/donor_details.git
git clone https://github.com/bentley-historical-library/generate_bhl_identifiers.git
git clone https://github.com/alexduryee/timewalk.git
git clone https://github.com/bentley-historical-library/user_defined_in_basic.git

echo "Installing mysql java connector"
# http://archivesspace.github.io/archivesspace/user/running-archivesspace-against-mysql/
cd /aspace/archivesspace/lib
wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.39/mysql-connector-java-5.1.39.jar

echo "Editing config"
cd /aspace/archivesspace/config

# Edit the config file to use the MySQL database, setup our plugins, and disable the public and staff interfaces
# http://stackoverflow.com/questions/14643531/changing-contents-of-a-file-through-shell-script
sed -i "s@#AppConfig\[:db_url\].*@$DBURL@" config.rb
sed -i "s@#AppConfig\[:plugins\].*@$PLUGINS@" config.rb
sed -i "s@#AppConfig\[:enable_public\].*@$PUBLIC@" config.rb
sed -i "s@#AppConfig\[:enable_frontend\].*@$FRONTEND@" config.rb

echo $BROWSEURL >> config.rb
cat /aspace/archivesspace/plugins/user_defined_in_basic/bhl_config.txt >> config.rb
echo "" >> config.rb
cat /aspace/archivesspace/plugins/accession_events/bhl_config.txt >> config.rb

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