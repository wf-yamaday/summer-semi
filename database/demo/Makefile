# セットアップ
setup:
	docker-compose build

# 起動
up:
	docker-compose up -d --remove-orphans

# 停止
down:
	docker-compose down

# 状態確認
ps:
	docker-compose ps

# masterへ接続(docker-exec)
master.login:
	docker container exec -it mysql_master mysql -u root -p

# slaveへ接続(docker-exec)
slave.login:
	docker container exec -it mysql_slave mysql -u root -p
