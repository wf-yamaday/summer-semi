# Guide

## 演習環境

必要なソフトウェアは以下
※Windowsでの動作確認が十分にできていないのでVagrantfileを用意した．

- GNU make
- docker
- docker-compose
- Bash

### Vagrantによる演習環境の構築（うまくいかない人向け）

<details>
<summary具体的な処理内容`(クリックで展開)</summary>

### Pluginのインストール

以下のプラグインをインストールしておく．

```bash
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-docker-compose
```

### 仮想マシンの起動と接続

```bash
vagrant up
vagrant ssh
```

</details>

## 基本操作

必要な操作はMakefileにタスクとして定義してある．
masterの部分はslaveに置き換えることでslave側への操作となる．

```sh
# 初期設定(docker-compose buildなど)
make setup

# 演習環境の立ち上げ(docker-compse up)
make up

# 演習環境の状態を確認(docker-compse ps)
make ps

# 演習環境のMySQLサーバへの接続(docker exec)
make master.login

# MySQLサーバのログを確認(docker-compose logs)
make master.logs

# 演習環境の停止(docker-compose down)
make down

# データなどを全て削除して初期状態に戻す(docker-compose down -v)
make clean
```

## データ投入

`make db.*`でmasterにデータを投入することができる．
今回は3種類のデータを用意している．

```sh
make db.bank

make db.user

make db.fulltext
```

## 演習1：Transaction

```bash
# データの投入
make db.bank

# mysqlへログイン
make master.login
```

### ROLLBACK

```sql
USE bank_db;

SELECT * FROM accounts;

START TRANSACTION;
UPDATE accounts SET money=money-1000 WHERE id=1;
ROLLBACK;

SELECT * FROM accounts;
```

### COMMIT

```sql
USE bank_db;

SELECT * FROM accounts;

START TRANSACTION;
UPDATE accounts SET money=money-1000 WHERE id=1;
UPDATE accounts SET money=money+1000 WHERE id=2;
COMMIT;

SELECT * FROM accounts;
```

## 演習2：レプリケーション

```sh
# server-idの付与
make add-server-id

# レプリケーションの設定
make repl
```

<details>
<summary具体的な処理内容(クリックで展開)</summary>

#### master側でレプリケーション用のユーザを作成

```sql
CREATE USER 'repl'@'192.0.%.%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.0.%.%';
```

#### Slave側のレプリケーションの設定

```sql
CHANGE MASTER TO
  MASTER_HOST='mysql_master',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='{masterのbinlogのファイル名}',
  MASTER_LOG_POS={binlogのポジション};
```

```sql
START SLAVE USER = 'repl' PASSWORD = 'repl';
```

</details>

#### Masterのbinlogのポジションを確認

```sql
SHOW MASTER STATUS;
```

#### レプリケーション用のユーザーの確認

```sql
SELECT user, host FROM mysql.user WHERE user='repl'\G;
```

#### slave側でmasterと接続できているかの確認

```sh
make slave.login
```

```sql
SHOW SLAVE STATUS\G;
```

#### masterにデータを投入しslaveに反映されるかを確認

```
make db.user
```

## 演習3：EXPLAINとindex

```sql
USE user_db;
SELECT * FROM users WHERE email = 'jjanodetro@vinaora.com';
```

### EXPLAIN

```sql
EXPLAIN SELECT * FROM users WHERE email = 'jjanodetro@vinaora.com';
```

```
(master) [user_db] > EXPLAIN SELECT * FROM users WHERE email = 'jjanodetro@vinaora.com';
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | users | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 1000 |    10.00 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
```

```sql
ALTER TABLE users ADD INDEX email_idx(email);
```

```
(master) [user_db] > EXPLAIN SELECT * FROM users WHERE email = 'jjanodetro@vinaora.com';
+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | users | NULL       | ref  | idx           | idx  | 203     | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
```

```sql
ALTER TABLE users ADD UNIQUE(email);
```

```
(master) [user_db] > EXPLAIN SELECT * FROM users WHERE email = 'jjanodetro@vinaora.com';
+----+-------------+-------+------------+-------+---------------+-------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key   | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+-------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | users | NULL       | const | email,idx     | email | 203     | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+-------+---------+-------+------+----------+-------+
```

## 演習4：全文検索（Full text search）

```bash
# 全文検索用のデータを投入
make db.fulltext
```

```sql
SELECT * FROM documents WHERE MATCH (content) AGAINST ('やうやう');
```

### フルテキストインデックスの確認

```sql
SET GLOBAL innodb_ft_aux_table = 'fulltext_db/documents';
SELECT * FROM INFORMATION_SCHEMA.INNODB_FT_INDEX_CACHE;
```
