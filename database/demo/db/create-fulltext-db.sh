#!/bin/sh

echo "CREATE DATABASE IF NOT EXISTS \`fulltext_db\`;" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"
echo "GRANT ALL ON \`fulltext_db\`.* TO 'root'@'%' ;" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" fulltext_db < /db/fulltext.sql
