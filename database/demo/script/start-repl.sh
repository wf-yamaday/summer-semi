#!/bin/bash

IP=`hostname -i`
IFS='.'
set -- $IP
IFS=''
SOURCE_IP="$1.$2.%.%"

# create repl user
echo "CREATE USER 'repl'@'$SOURCE_IP' IDENTIFIED BY 'repl';" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"
echo "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'$SOURCE_IP';" | mysql -u root -p"$MYSQL_ROOT_PASSWORD"

# check master bin-log statu
MASTER_STATUS_FILE="/tmp/master-status"

echo "SHOW MASTER STATUS\G" | mysql -u root -p"$MYSQL_ROOT_PASSWORD" > $MASTER_STATUS_FILE

BIN_LOG_FILE=`cat $MASTER_STATUS_FILE | grep File | xargs | cut -d' ' -f2`
BIN_LOG_POS=`cat $MASTER_STATUS_FILE | grep Position | xargs | cut -d' ' -f2`

echo "CHANGE MASTER TO MASTER_HOST='mysql_master', MASTER_PORT=3306, MASTER_LOG_FILE='$BIN_LOG_FILE',MASTER_LOG_POS=$BIN_LOG_POS;" | mysql -h mysql_slave -u root -pslave

# start replication
echo "START SLAVE USER = 'repl' PASSWORD = 'repl';" | mysql -h mysql_slave -u root -pslave
