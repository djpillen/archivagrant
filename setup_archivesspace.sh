#!/usr/bin/env bash

# Download and unzip a packaged ArchivesSpace release and corresponding source code
export AS_VERSION=2.7.1
mkdir /aspace
mkdir /aspace/source
mkdir /aspace/zips
cd /aspace/zips
wget -nv https://github.com/archivesspace/archivesspace/releases/download/v$AS_VERSION/archivesspace-v$AS_VERSION.zip
wget -nv https://github.com/archivesspace/archivesspace/archive/v$AS_VERSION.zip
cd /aspace
unzip /aspace/zips/archivesspace-v$AS_VERSION.zip
cd /aspace/source
unzip /aspace/zips/v$AS_VERSION.zip
mv *$AS_VERSION archivesspace

# Setting up ArchivesSpace from source
DEVDBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/aspacedev?user=root\&password=rootpwd\&useUnicode=true\&characterEncoding=UTF-8"'
cd /aspace/source/archivesspace/common/config
echo $DEVDBURL >> config.rb
cd /aspace/source/archivesspace
build/run bootstrap
build/run db:migrate

# These variables will be used to edit the ArchivesSpace config file to use the correct database URL and setup our plugins
DBURL='AppConfig[:db_url] = "jdbc:mysql://localhost:3306/archivesspace?user=root\&password=rootpwd\&useUnicode=true\&characterEncoding=UTF-8"'
BROWSEURL='AppConfig[:browse_page_db_url] = "jdbc:mysql://localhost:3306/browse_pages?user=root\&password=rootpwd\&useUnicode=true\&characterEncoding=UTF-8"'
PLUGINS="AppConfig[:plugins] = ['accession_events', 'aspace-jsonmodel-from-format', 'bhl_accession_readonly_fields', 'bhl_accession_search', 'bhl_aspace_accessrestrict_text', 'bhl_aspace_archive_it', 'bhl_aspace_branding', 'bhl_aspace_handle_verifier', 'bhl_aspace_print_template', 'bhl_aspace_reports', 'bhl_aspace_translations', 'bhl_barcode', 'bhl_browse_pages', 'bhl-ead-exporter', 'bhl-ead-importer', 'bulk_create_containers', 'donor_details', 'generate_bhl_identifiers', 'timewalk', 'user_defined_in_basic']"
PUBLIC="AppConfig[:enable_public] = false"
FRONTEND="AppConfig[:enable_frontend] = true"
INDEXER="AppConfig[:enable_indexer] = false"
PUBLIC_INDEXER="AppConfig[:pui_indexer_enabled] = false"
OAI="AppConfig[:enable_oai] = false"

Install plugins
cd /aspace/archivesspace/plugins
git clone https://github.com/bentley-historical-library/accession_events.git
git clone https://github.com/bentley-historical-library/aspace-jsonmodel-from-format.git
git clone https://github.com/bentley-historical-library/bhl_accession_readonly_fields.git
git clone https://github.com/bentley-historical-library/bhl_accession_search.git
git clone https://github.com/bentley-historical-library/bhl_aspace_accessrestrict_text.git
git clone https://github.com/bentley-historical-library/bhl_aspace_archive_it.git
git clone https://github.com/bentley-historical-library/bhl_aspace_branding.git
git clone https://github.com/bentley-historical-library/bhl_aspace_handle_verifier.git
git clone https://github.com/bentley-historical-library/bhl_aspace_print_template.git
git clone https://github.com/bentley-historical-library/bhl_aspace_reports.git
git clone https://github.com/bentley-historical-library/bhl_aspace_translations.git
git clone https://github.com/bentley-historical-library/bhl_barcode.git
git clone https://github.com/bentley-historical-library/bhl_browse_pages.git
git clone https://github.com/bentley-historical-library/bhl-ead-exporter.git
git clone https://github.com/bentley-historical-library/bhl-ead-importer.git
git clone https://github.com/bentley-historical-library/bulk_create_containers.git
git clone https://github.com/bentley-historical-library/donor_details.git
git clone https://github.com/bentley-historical-library/generate_bhl_identifiers.git
git clone https://github.com/bentley-historical-library/timewalk.git
git clone https://github.com/bentley-historical-library/user_defined_in_basic.git

# http://archivesspace.github.io/archivesspace/user/running-archivesspace-against-mysql/
cd /aspace/archivesspace/lib
wget -nv http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.46/mysql-connector-java-5.1.46.jar

# Edit the config file to use the MySQL database, setup our plugins, and disable the public and staff interfaces
# http://stackoverflow.com/questions/14643531/changing-contents-of-a-file-through-shell-script
cd /aspace/archivesspace/config
sed -i "s@#AppConfig\[:db_url\].*@$DBURL@" config.rb
sed -i "s@#AppConfig\[:plugins\].*@$PLUGINS@" config.rb
sed -i "s@#AppConfig\[:enable_public\].*@$PUBLIC@" config.rb
sed -i "s@#AppConfig\[:enable_frontend\].*@$FRONTEND@" config.rb
sed -i "s@#AppConfig\[:enable_indexer\].*@$INDEXER@" config.rb
sed -i "s@#AppConfig\[:pui_indexer_enabled\].*@$PUBLIC_INDEXER@" config.rb
sed -i "s@#AppConfig\[:enable_oai\].*@$OAI@" config.rb
echo $BROWSEURL >> config.rb
cat /aspace/archivesspace/plugins/user_defined_in_basic/bhl_config.txt >> config.rb
echo "" >> config.rb
cat /aspace/archivesspace/plugins/accession_events/bhl_config.txt >> config.rb

# Make the archivesspace.sh and setup-database.sh scripts executable
cd /aspace/archivesspace/scripts
chmod +x setup-database.sh
cd /aspace/archivesspace
chmod +x archivesspace.sh

# Run the setup database script
scripts/setup-database.sh

# Add ArchivesSpace to system startup and create an ArchivesSpace service
echo "[Unit]
Description=ArchivesSpace
After=network.target

[Service]
Type=forking
RemainAfterExit=yes
ExecStart=/aspace/archivesspace/archivesspace.sh start
ExecStop=/aspace/archivesspace/archivesspace.sh stop

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/archivesspace.service

# Usage: sudo systemctl stop|start archivesspace.service
systemctl start archivesspace.service
systemctl enable archivesspace.service

chown -R vagrant:vagrant /aspace

echo "Browse to http://localhost:8080 to begin using the ArchivesSpace application"
echo "Use vagrant ssh to access the virtual machine"
