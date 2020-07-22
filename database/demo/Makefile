# セットアップ
setup:
	cp ./master/conf/my.cnf.sample ./master/conf/my.cnf
	cp ./slave/conf/my.cnf.sample ./slave/conf/my.cnf
	chmod +x ./master/db/create-bank.db.sh
	docker-compose build

# 起動
up:
	docker-compose up -d --remove-orphans

# 停止
down:
	docker-compose down

# 再起動
restart:
	make down
	make up

# 状態確認
ps:
	docker-compose ps

# masterへ接続(docker-exec)
master.login:
	docker container exec -it mysql_master mysql -u root -p

# slaveへ接続(docker-exec)
slave.login:
	docker container exec -it mysql_slave mysql -u root -p

# server-idの付与
add-server-id:
	docker container exec -it mysql_master add-server-id.sh

# bank_dbの作成とデータ投入
db.bank:
	docker container exec -it mysql_master /bin/sh ./db/create-bank-db.sh
