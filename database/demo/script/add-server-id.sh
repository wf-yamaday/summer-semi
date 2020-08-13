#!/bin/sh

OCTETS=`hostname -i | tr -s '.' ' '`

i=3
set $OCTETS
if [ $i -ge 10 ]
then
 i=`expr $i - 9`
 shift 9
fi
v1="v1=\$$i"
eval $v1

i=4
if [ $i -ge 10 ]
then
 i=`expr $i - 9`
 shift 9
fi
v2="v2=\$$i"
eval $v2

MYSQL_SERVER_ID=`expr $v1 \* 256 + $v2`

sed -i -e "/# START/,/# END/ s/SERVER_ID/$MYSQL_SERVER_ID/g" /etc/mysql/conf.d/my.cnf
sed -i -e '/# START/,/# END/ s/# server_id/server_id/g' /etc/mysql/conf.d/my.cnf
sed -i -e '/# START/,/# END/ s/# log_bin/log_bin/g' /etc/mysql/conf.d/my.cnf
