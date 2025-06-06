## centos docker実行環境
### 使い方
1. `docker-compose up -d` でコンテナを起動
2. `docker exec -it centos /bin/bash` でコンテナに入る
3. `docker-compose down` でコンテナを停止

### 注意点
- **初回だけ、Dockerfile内の3,4行目のユーザー名とパスワードを変更してください。**
- ホスト側の`./data`ディレクトリがコンテナの`/home/centos/data`にマウントされます。
- homeディレクトリ以外のファイルはコンテナ内で変更しても、ホスト側に反映されません。

その他不明点あれば[Issues](https://github.com/Alpha9n/centos-sv41/issues)にあげてください！
