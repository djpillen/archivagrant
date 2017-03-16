#!/usr/bin/env bash

echo "Stopping ArchivesSpace"
service archivesspace stop

echo "Dropping and recreating database"
mysql -uroot -prootpwd -e "drop database archivesspace"
mysql -uroot -prootpwd -e "create database archivesspace"
mysql -uroot -prootpwd -e "grant all on archivesspace.* to 'as'@'localhost' identified by 'as123'"

mysql -uroot -prootpwd -e "drop database browse_pages"
mysql -uroot -prootpwd -e "create database browse_pages"
mysql -uroot -prootpwd -e "grant all on browse_pages.* to 'as'@'localhost' identified by 'as123'"

echo "Deleting indexer state"
cd /aspace/archivesspace/data
rm -rf indexer_state
rm -rf solr_backups
rm -rf solr_index

echo "Setting up database"
cd /aspace/archivesspace
scripts/setup-database.sh

echo "Starting ArchivesSpace"
service archivesspace start

echo "All done! Reapply ArchivesSpace defaults"
#echo "Applying ArchivesSpace defaults"
#cd /vagrant
#python archivesspace_defaults.py
