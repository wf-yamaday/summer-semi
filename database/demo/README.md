# Guide

## 演習環境

必要なソフトウェアは以下（ただしWindowsでの動作確認が十分にできていないのでVagrantfileを用意した．）

- GNU make
- docker
- docker-compose

### Vagrantによる演習環境の構築

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

## Transaction

```bash
# start mysql server
make up

# check mysql server status
make ps

# init database
make db.bank

# login mysql server
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

## レプリケーション

### server-idの付与

```sh
make add-server-id
```

### Master側のレプリケーションの設定

#### レプリケーション用のユーザを作成

```sql
CREATE USER 'repl'@'192.0.%.%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.0.%.%';
```

#### Masterのbinlogのポジションを取得

```sql
SHOW MASTER STATUS;
```

#### Slave側のレプリケーションの設定

```sql
CHANGE MASTER TO
  MASTER_HOST='mysql_master',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='mysql-bin.000004',
  MASTER_LOG_POS=1806;
```

```sql
START SLAVE USER = 'repl' PASSWORD = 'repl';
```


```sql
select user, host from mysql.user where user='repl'\G;
```

```sql
SHOW SLAVE STATUS\G;
```

## EXPLAINとindex

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

## 全文検索（Full text search）

```bash
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
