# CentOS SV41 Docker環境

CentOSベースのApache + PHP-FPM環境をDockerで構築するプロジェクトです。

## 🚀 クイックスタート

```bash
# 1. 初期セットアップ
chmod +x setup.sh init.sh
./init.sh

# 2. コンテナ起動
./setup.sh start

# 3. ブラウザでアクセス
open http://localhost
```

## 📁 プロジェクト構造

```
centos/
├── docker-compose.yaml     # Docker Compose設定
├── Dockerfile             # Dockerイメージ定義
├── setup.sh              # メインセットアップスクリプト
├── init.sh               # 初期化スクリプト
├── www/                  # Webコンテンツ（/var/www にマウント）
│   └── html/
│       ├── index.php     # メインページ
│       ├── info.php      # PHP情報
│       └── secret/       # Basic認証テストページ
├── etc/                  # システム設定ファイル
│   ├── hostname          # ホスト名設定
│   ├── httpd/           # Apache設定（/etc/httpd にマウント）
│   │   ├── conf/
│   │   ├── conf.d/
│   │   └── conf.modules.d/
│   └── pki/tls/         # SSL/TLS設定
├── httpd/               # 追加Apache設定（/opt/httpd にマウント）
│   ├── conf.d/
│   └── conf.modules.d/
└── data/                # データ保存用（/root/data にマウント）
```

## 🛠️ スクリプトの使い方

### setup.sh - メインスクリプト

```bash
./setup.sh [オプション]
```

**利用可能なオプション:**

| オプション | 説明 |
|-----------|------|
| `build`   | Dockerイメージをビルド |
| `start`   | コンテナを起動（自動ビルド含む） |
| `stop`    | コンテナを停止 |
| `restart` | コンテナを再起動 |
| `clean`   | コンテナとイメージを削除 |
| `logs`    | コンテナのログを表示 |
| `shell`   | コンテナにシェルでアクセス |
| `status`  | コンテナの状態を確認 |
| `init`    | 初期セットアップ実行 |
| `help`    | ヘルプを表示 |

**使用例:**
```bash
# 初回セットアップ + 起動
./setup.sh init
./setup.sh start

# コンテナにログイン
./setup.sh shell

# ログ確認
./setup.sh logs

# 停止
./setup.sh stop
```

### init.sh - 初期化スクリプト

初回実行時やファイル構造をリセットしたい場合に使用します。

```bash
./init.sh
```

**実行内容:**
- 必要なディレクトリ構造の作成
- Apache設定ファイルのサンプル作成
- サンプルWebページの作成
- 権限設定の調整

## 🌐 アクセス情報

### Webページ

- **メインページ:** http://localhost
- **PHP情報:** http://localhost/info.php
- **Basic認証テスト:** http://localhost/secret/

### Basic認証情報

- **ユーザー名:** `cent`
- **パスワード:** `osaka`

### コンテナアクセス

```bash
# シェルアクセス
./setup.sh shell

# 直接Docker経由
docker exec -it centos-sv-container /bin/bash
```

## ⚙️ 設定ファイルのカスタマイズ

### Apache設定

**メイン設定:**
- `etc/httpd/conf/httpd.conf` - Apache メイン設定
- `etc/httpd/conf.d/` - 追加設定ファイル
- `etc/httpd/conf.modules.d/` - モジュール設定

**追加設定:**
- `httpd/conf.d/` - カスタム設定（/opt/httpd にマウント）

### PHP設定

- `etc/httpd/conf.d/php.conf` - PHP-FPM連携設定

### SSL/TLS設定

- `etc/pki/tls/` - SSL証明書設定
- `certs` ボリューム - 永続化された証明書

## 🔧 トラブルシューティング

### よくある問題

**1. 権限エラー**
```bash
# macOSの場合
./init.sh  # 権限を自動調整

# Linuxの場合
sudo chown -R 48:48 etc/httpd/ httpd/ www/
```

**2. ポート競合**
```bash
# 使用中のポートを確認
lsof -i :80
lsof -i :443

# 競合するプロセスを停止してから再試行
./setup.sh restart
```

**3. コンテナが起動しない**
```bash
# エラーログを確認
./setup.sh logs

# 設定を確認
./setup.sh status

# クリーンビルド
./setup.sh clean
./setup.sh start
```

**4. ファイルマウントの問題**
```bash
# 初期化をやり直し
./init.sh

# 権限確認
ls -la etc/httpd/
```

### ログの確認

```bash
# リアルタイムログ
./setup.sh logs

# Apache固有のログ（コンテナ内）
./setup.sh shell
tail -f /var/log/httpd/error_log
tail -f /var/log/httpd/access_log
```

## 📝 開発ガイド

### 新しい設定の追加

1. **Apache設定の追加**
   ```bash
   # etc/httpd/conf.d/ に新しい.confファイルを作成
   vim etc/httpd/conf.d/my-custom.conf
   
   # コンテナを再起動
   ./setup.sh restart
   ```

2. **Webコンテンツの追加**
   ```bash
   # www/html/ にファイルを追加
   echo "Hello World" > www/html/hello.txt
   
   # ブラウザで確認
   open http://localhost/hello.txt
   ```

### 設定の永続化

このプロジェクトでは以下の設定が永続化されます：

- **Apache設定:** `etc/httpd/` → `/etc/httpd/`
- **Webコンテンツ:** `www/` → `/var/www/`
- **カスタム設定:** `httpd/` → `/opt/httpd/`
- **SSL証明書:** `certs` ボリューム → `/etc/pki/tls/certs/`
- **データファイル:** `data/` → `/root/data/`

## 🔐 セキュリティ注意事項

⚠️ **本番環境での使用時は以下を確認してください:**

1. **info.phpの削除**
   ```bash
   rm www/html/info.php
   ```

2. **Basic認証パスワードの変更**
   ```bash
   # コンテナ内で実行
   htpasswd -b /etc/httpd/conf/.htpasswd cent 新しいパスワード
   ```

3. **SSL証明書の設定**
   - 本物の証明書を `etc/pki/tls/` に配置
   - SSL設定の有効化

4. **ファイアウォール設定**
   - 必要なポートのみ開放
   - 不要なサービスの無効化

## 📚 参考情報

- [Apache HTTP Server Documentation](https://httpd.apache.org/docs/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [CentOS/RHEL Documentation](https://access.redhat.com/documentation/)

## 🤝 コントリビューション

プロジェクトへの貢献を歓迎します！

1. このリポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。