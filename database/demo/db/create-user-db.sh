#!/bin/sh

echo "CREATE DATABASE IF NOT EXISTS \`user_db\`;" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"
echo "GRANT ALL ON \`user_db\`.* TO 'root'@'%' ;" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" user_db < /db/user.sql
