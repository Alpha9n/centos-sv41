# BIND DNSサーバー設定ガイド

## 概要
このプロジェクトには、BINDを使用したDNSサーバーが組み込まれています。

## 構成

### インストールされたパッケージ
- `bind`: DNS サーバー (named)
- `bind-utils`: DNS クエリツール (dig, nslookup など)

### 設定ファイル

#### `/etc/named/named.conf`
BIND のメイン設定ファイル
- リッスンポート: 53 (TCP/UDP)
- クエリ許可: any (全てのIPから)
- 再帰クエリ: 有効

#### ゾーンファイル

**正引きゾーン: `/etc/named/zones/db.example.local`**
- ドメイン: example.local
- レコード:
  - ns1.example.local → 10.0.0.10 (ネームサーバー)
  - www.example.local → 10.0.0.10 (Webサーバー)
  - mail.example.local → 10.0.0.20 (メールサーバー)
  - ftp.example.local → 10.0.0.30 (FTPサーバー)

**逆引きゾーン: `/etc/named/zones/db.10.0.0`**
- ネットワーク: 10.0.0.0/24
- PTRレコード設定済み

## 使用方法

### コンテナのビルドと起動

```bash
# イメージをビルド
docker-compose build

# コンテナを起動
docker-compose up -d
```

### DNSサービスの確認

```bash
# コンテナに接続
docker exec -it centos-sv-container bash

# named サービスの状態確認
systemctl status named

# named サービスの起動/停止/再起動
systemctl start named
systemctl stop named
systemctl restart named
```

### DNSクエリのテスト

```bash
# ホストから（コンテナ起動後）
dig @localhost www.example.local
dig @localhost -x 10.0.0.10

# コンテナ内から
dig @localhost www.example.local
nslookup www.example.local localhost
```

### 設定の変更

ゾーンファイルを編集した場合:

1. シリアル番号を増やす（各ゾーンファイルのSOAレコード）
2. namedサービスを再起動

```bash
docker exec -it centos-sv-container systemctl restart named
```

## ポート

- TCP/UDP 53: DNS クエリ
- TCP 80: HTTP
- TCP 443: HTTPS

## トラブルシューティング

### ログの確認

```bash
# named のログ
docker exec -it centos-sv-container journalctl -u named -f

# 設定の構文チェック
docker exec -it centos-sv-container named-checkconf /etc/named.conf

# ゾーンファイルの構文チェック
docker exec -it centos-sv-container named-checkzone example.local /etc/named/zones/db.example.local
docker exec -it centos-sv-container named-checkzone 0.0.10.in-addr.arpa /etc/named/zones/db.10.0.0
```

### よくある問題

1. **namedが起動しない**
   - 設定ファイルの構文エラーを確認: `named-checkconf`
   - ポート53が既に使用されていないか確認

2. **名前解決ができない**
   - namedが起動しているか確認: `systemctl status named`
   - ファイアウォール設定を確認
   - クエリを送信しているIPアドレスが許可されているか確認

3. **ゾーンファイルの変更が反映されない**
   - シリアル番号を増やしたか確認
   - namedを再起動: `systemctl restart named`

## カスタマイズ

### 新しいレコードの追加

1. 適切なゾーンファイルを編集
2. シリアル番号を増やす
3. namedを再起動

例: test.example.local → 10.0.0.40 を追加

```bash
# etc/named/zones/db.example.local に追加
test    IN      A       10.0.0.40

# シリアル番号を 3 → 4 に変更
# namedを再起動
docker exec -it centos-sv-container systemctl restart named
```

### 新しいゾーンの追加

1. `/etc/named/named.conf` に新しいゾーンを定義
2. `/etc/named/zones/` に新しいゾーンファイルを作成
3. namedを再起動
