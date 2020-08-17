# セットアップ
setup:
	cp ./master/conf/my.cnf.sample ./master/conf/my.cnf
	cp ./slave/conf/my.cnf.sample ./slave/conf/my.cnf
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

# masterのログを確認する
master.logs:
	docker-compose logs master

# slaveのログを確認する
slave.logs:
	docker-compose logs slave

# slaveのIPアドレスを取得
slave.ip:
	docker container exec -it mysql_slave hostname -i

# masterのIPアドレスを取得
master.ip:
	docker container exec -it mysql_master hostname -i

# server-idの付与
add-server-id:
	docker container exec -it mysql_master add-server-id.sh
	docker container exec -it mysql_slave add-server-id.sh
	make restart

# bank_dbの作成とデータ投入
db.bank:
	docker container exec -it mysql_master bin/sh ./db/create-bank-db.sh

# user_dbの作成とデータ投入
db.user:
	docker container exec -it mysql_master bin/sh ./db/create-user-db.sh

# fulltext_dbの作成とデータ投入
db.fulltext:
	docker container exec -it mysql_master bin/sh ./db/create-fulltext-db.sh

# レプリケーションの開始
repl:
	@make add-server-id
	sleep 2;docker container exec -it mysql_master bin/sh ./script/start-repl.sh

# データを初期状態に戻す
clean:
	-@rm -r ./master/data/**
	-@rm -r ./slave/data/**
	-@rm -r ./master/log/**
	-@rm -r ./slave/log/**
	-@rm -r ./master/conf/my.cnf
	-@rm -r ./slave/conf/my.cnf
	-@touch ./master/data/.keep
	-@touch ./slave/data/.keep
	-@touch ./master/log/.keep
	-@touch ./slave/log/.keep
	-@cp ./master/conf/my.cnf.sample ./master/conf/my.cnf
	-@cp ./slave/conf/my.cnf.sample ./slave/conf/my.cnf
