#!/usr/bin/env bash

#variable
DBURL='jdbc:mysql://localhost:3306/archivesspace\?user\=as\&password=as123\&useUnicode=true\&characterEncoding\=UTF\-8'
PLUGINS="\['bhl-ead-importer','bhl-ead-exporter','container_management','aspace_jsonmodel_from_format'\]"


cd /home/vagrant/archivesspace/config

sed -i 's@\#AppConfig\[:db_url\] = .*@AppConfig\[:db_url\] = "'$DBURL'"@' config.rb
sed -i 's@\#AppConfig\[:plugins\] = .*@AppConfig\[:plugins\] = '$PLUGINS'@' config.rb
