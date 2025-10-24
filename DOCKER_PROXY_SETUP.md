# Docker プロキシ設定ガイド

## ⚠️ 重要: パスワードの特殊文字

パスワードに特殊文字が含まれている場合、URLエンコードが必要です：

例: パスワードが `#B19991224` の場合
- ❌ 間違い: `http://user:#B19991224@proxy:8080`
- ✅ 正しい: `http://user:%23B19991224@proxy:8080`

### よく使われる文字のエンコード表
| 文字 | URLエンコード |
|------|---------------|
| `#`  | `%23`         |
| `@`  | `%40`         |
| `:`  | `%3A`         |
| `/`  | `%2F`         |
| `?`  | `%3F`         |
| `&`  | `%26`         |
| ` `  | `%20`         |

## 正しいプロキシURL（学校環境用）
```bash
export HTTP_PROXY="http://ohs学籍番号:%23B誕生日@proxy01.osaka.hal.ac.jp:8080"
export HTTPS_PROXY="$HTTP_PROXY"
export NO_PROXY="localhost,127.0.0.1,.local"
```

## 方法1: Docker Desktop設定（推奨）

1. Docker Desktopを開く
2. 設定（Settings/Preferences）を開く
3. "Resources" → "Proxies" を選択
4. 以下を設定：
   - HTTP Proxy: http://ohs20201:%23B20030804@proxy01.osaka.hal.ac.jp:8080
   - HTTPS Proxy: http://ohs20201:%23B20030804@proxy01.osaka.hal.ac.jp:8080
   - No Proxy: localhost,127.0.0.1,.local
5. "Apply & Restart" をクリック

## 方法2: システム環境変数（現在の設定）
URLエンコード済みの正しい設定：
```bash
export HTTP_PROXY="http://ohs学籍番号:%23B誕生日@proxy01.osaka.hal.ac.jp:8080"
export HTTPS_PROXY="$HTTP_PROXY"
export NO_PROXY="localhost,127.0.0.1,.local"
```

## 方法3: docker build時の引数指定
docker build 時に明示的にプロキシを指定：

```bash
docker build \
  --build-arg HTTP_PROXY="http://ohs学籍番号:%23B誕生日@proxy01.osaka.hal.ac.jp:8080" \
  --build-arg HTTPS_PROXY="http://ohs学籍番号:%23B誕生日@proxy01.osaka.hal.ac.jp:8080" \
  --build-arg NO_PROXY="localhost,127.0.0.1,.local" \
  -t centos-sv .
```

## 方法4: Dockerデーモン設定ファイル
~/.docker/config.json または /etc/docker/daemon.json に設定

## トラブルシューティング

1. Docker Desktopを再起動
2. プロキシサーバーが稼働していることを確認
3. 認証情報が正しいことを確認
4. ネットワーク管理者に相談（必要に応じて）