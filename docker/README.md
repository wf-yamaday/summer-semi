# Docker

- 標準化された実行環境でホストに依存しない
- Dockerfileによるコードベースでの定義
- イメージのバージョン管理
- Dockerレジストリによるイメージの再配布・再利用
- 豊富なAPI

## Dockerfileからイメージをビルドする

Dockerではインフラについての構成が記述された`Dockerfile`を基にDockerイメージをビルドします．  
と言っても実際にやってみないと理解がしにくい部分ではあるので実際にやってみましょう．  

はじめに`hellowrold.sh`というシェルスクリプトをコンテナで実行します．  
`hellowrold.sh`の中身は以下のようになっています．  
標準出力に**Hello, World**と出力するだけのスクリプトになります．  

```bash
#!/bin/sh

echo "Hello, World"
```

では実際に`Dockerfile`を記述しましょう．  
`Dockerfile`では`FROM`によってベースとなるイメージを指定することができます．  
ベースとなるイメージを指定することで自分が実行したい内容や設定などの**差分**だけを記述することができます．  

今回はDockerイメージを作成する際にホストマシンから`helloworld.sh`をコピーし，実行権限を付与します．  
`CMD`命令はDockeコンテナとして起動する前に実行される命令を記述します．

```Dockerfile
FROM ubuntu:16.04

COPY helloworld.sh /usr/local/bin
RUN chmod +x /usr/local/bin/helloworld.sh
CMD ["helloworld.sh"]
```

以上の内容で`Dockerfile`を作成したら実際にイメージをビルドしてみましょう．  

```bash
docker image build -t helloworld:1.0 .
```

`Successfully tagged helloworld:1.0`と出力されれば問題ありません．  
次は作成したイメージからDockerコンテナを生成しましょう．

```bash
docker container run helloworld:1.0
```

標準出力で`Hello, World`と出力されていれば問題ありません．  
以上がDockerを扱う上で最も基本となるDockerfileによる構成の記述，イメージのビルド，コンテナの生成でした．  

## Dockerイメージのバージョン管理

Dockerイメージのバージョン管理について体験するために`hellowrold.sh`を編集して新しいバージョンのDockerイメージを作成してみましょう．  
具体的には`World`の部分を自分の名前に置き換えます．  

```bash
#!/bin/sh

echo "Hello, yamaday"
```

そしてDockerイメージをビルドする際にバージョンの部分を`latest`に変更します．  

```bash
docker image build -t helloworld:latest .
```

更新されたDockerイメージからコンテナを生成してみましょう．  

```bash
docker container run helloworld:latest
```

標準出力に自分の名前が出力されていれば問題ありません．  
また先ほどの`1.0`のDockerイメージも残っているためコンテナが生成できることを確認してみましょう．  

```bash
docker container run helloworld:1.0
```

## Dockerコンテナでアプリケーションを動作させる

先ほどの例とは異なり次はDockerコンテナでアプリケーションを動作させてみましょう．  

Docker hubで配布されているサンプルの[static-site](https://hub.docker.com/r/dockersamples/static-site)のDockerイメージを取得し実行してみましょう．  
`docker pull`コマンドで取得することができます．  

```bash
 docker pull dockersamples/static-site
```

次に取得したイメージからコンテナを生成しましょう．  

```bash
docker container run -d dockersamples/static-site
```

```bash
docker container ls
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                               NAMES
ee9524505be9        dockersamples/static-site    "/bin/sh -c 'cd /usr…"   3 minutes ago       Up 3 minutes        80/tcp, 443/tcp                     distracted_benz
```

これでコンテナを生成することはできましたがアクセスすることはできません．  
なぜならコンテナはホストOSからは独立した環境で動作しているためです．ホストOSからアクセスするためにはいくつか設定をする必要があります．

起動したコンテナを停止・破棄しましょう．

```bash
docker container stop ee9524505be9
docker container rm ee9524505be9
```

次にDockerコンテナとホスト間でポートをマッピングした状態でコンテナを生成してみましょう．  
`-P`オプションを付与することでホストのランダムなポートがマッピングされます．

```bash
docker run --name static-site -d -P dockersamples/static-site
```

どのポートがマッピングされているかは`docker port`コマンドで確認することができます．

```bash
docker port static-site
```

80/tcpがマッピングされているポートを確認しブラウザからアクセスしてみましょう．  

このままだとランダムにポートが割り当てられるため次にポートを指定する方法で実行してみましょう．  
まず既に起動しているコンテナを停止・破棄します．(`-f`オプションによって停止から破棄まで行うことができます)  

```bash
docker container rm -f static-site
```

破棄後に今度はホストの8888番ポートをコンテナの80番ポートにマッピングして起動します．  

```bash
docker run --name static-site -d -p 8888:80 dockersamples/static-site
```

このようにして起動するとhttp://localhost:8888/でアクセスすることができます．  
またDockerコンテナの状態をより詳細に知りたければ`docker container inspect`コマンドを利用します．  

```bash
docker container inspect static-site
```

`inspect`コマンドの出力フォーマットはデフォルトではJSONです．  
JSONの中にはコンテナに割り当てられるMACアドレスやIPアドレスなど様々な情報を見ることができます．  

全ての演習が終了したらコンテナを停止・破棄しましょう．  

```bash
docker container rm -f static-site
```

## まとめ

- Dockerfileによるコードベースでのインフラの定義ができる
- イメージのバージョン管理にインフラの状態やバージョンの管理ができる
- Dockerレジストリによるイメージの再利用ができる
- Dockerで提供される豊富なAPIによってDockerコンテナの操作ができる

## 参考資料

- 山田明憲，”Docker/Kubernetes 実践コンテナ開発入門”, [Amazonへのリンク](https://www.amazon.co.jp/Docker-Kubernetes-%E5%AE%9F%E8%B7%B5%E3%82%B3%E3%83%B3%E3%83%86%E3%83%8A%E9%96%8B%E7%99%BA%E5%85%A5%E9%96%80-%E5%B1%B1%E7%94%B0-%E6%98%8E%E6%86%B2/dp/4297100339/ref=tmm_pap_swatch_0?_encoding=UTF8&qid=1597812454&sr=8-1)
- webapps, https://github.com/docker/labs/blob/master/beginner/chapters/webapps.md
