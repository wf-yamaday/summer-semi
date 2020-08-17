#!/bin/sh

echo "CREATE DATABASE IF NOT EXISTS \`bank_db\`;" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"
echo "GRANT ALL ON \`bank_db\`.* TO 'root'@'%' ;" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" bank_db < /db/bank.sql
