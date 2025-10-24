# CentOS SV41 Docker環境 (PowerShell版)

Windows PowerShell向けのCentOSベースのApache + PHP-FPM環境をDockerで構築するプロジェクトです。

## 🚀 クイックスタート (Windows)

```powershell
# 1. PowerShellを管理者権限で起動
# 2. 実行ポリシーを設定（初回のみ）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. プロジェクトディレクトリに移動
cd "path\to\centos"

# 4. 初期セットアップ
.\init.ps1

# 5. コンテナ起動
.\setup.ps1 start

# 6. ブラウザでアクセス
start http://localhost
```

## 📁 プロジェクト構造

```
centos\
├── docker-compose.yaml     # Docker Compose設定
├── Dockerfile             # Dockerイメージ定義
├── setup.ps1              # メインセットアップスクリプト (PowerShell)
├── init.ps1               # 初期化スクリプト (PowerShell)
├── setup.sh               # Unix/Linux/macOS用スクリプト
├── init.sh                # Unix/Linux/macOS用初期化スクリプト
├── www\                   # Webコンテンツ（/var/www にマウント）
│   └── html\
│       ├── index.php      # メインページ
│       ├── info.php       # PHP情報
│       └── secret\        # Basic認証テストページ
├── etc\                   # システム設定ファイル
│   ├── hostname           # ホスト名設定
│   ├── httpd\            # Apache設定（/etc/httpd にマウント）
│   │   ├── conf\
│   │   ├── conf.d\
│   │   └── conf.modules.d\
│   └── pki\tls\          # SSL/TLS設定
├── httpd\                # 追加Apache設定（/opt/httpd にマウント）
│   ├── conf.d\
│   └── conf.modules.d\
└── data\                 # データ保存用（/root/data にマウント）
```

## 🛠️ PowerShellスクリプトの使い方

### setup.ps1 - メインスクリプト

```powershell
.\setup.ps1 [オプション]
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
```powershell
# 初回セットアップ + 起動
.\setup.ps1 init
.\setup.ps1 start

# コンテナにログイン
.\setup.ps1 shell

# ログ確認
.\setup.ps1 logs

# 停止
.\setup.ps1 stop
```

### init.ps1 - 初期化スクリプト

初回実行時やファイル構造をリセットしたい場合に使用します。

```powershell
.\init.ps1
```

## 🌐 アクセス情報

### Webページ

- **メインページ:** http://localhost
- **PHP情報:** http://localhost/info.php
- **Basic認証テスト:** http://localhost/secret/

### Basic認証情報

- **ユーザー名:** `cent`
- **パスワード:** `osaka`

### コンテナアクセス

```powershell
# シェルアクセス
.\setup.ps1 shell

# 直接Docker経由
docker exec -it centos-sv-container /bin/bash
```

## ⚙️ Windows固有の設定

### PowerShell実行ポリシー

初回実行時に以下のコマンドを管理者権限のPowerShellで実行してください：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Docker Desktop for Windows

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/)をダウンロード・インストール
2. Docker Desktopを起動
3. 設定で以下を確認：
   - **General** → "Use WSL 2 based engine" を有効
   - **Resources** → **File Sharing** でプロジェクトフォルダを共有

### Windows Defender

Windows Defenderがファイルアクセスをブロックする場合があります：

1. Windows Defender設定を開く
2. 「ウイルスと脅威の防止」
3. 「除外の追加または削除」
4. プロジェクトフォルダを除外リストに追加

## 🔧 Windows固有のトラブルシューティング

### よくある問題

**1. PowerShellスクリプトが実行できない**
```powershell
# 実行ポリシーを確認
Get-ExecutionPolicy

# 実行ポリシーを変更
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**2. Docker Desktopが起動しない**
- Windows Updateを最新にする
- WSL 2を有効にする
- BIOS/UEFIで仮想化が有効になっていることを確認

**3. ファイル共有の問題**
```powershell
# Docker Desktop設定でファイル共有を確認
# プロジェクトフォルダが共有されていることを確認
```

**4. パスの問題**
```powershell
# PowerShellでは \ を使用
cd "C:\Users\YourName\Projects\centos"

# パスにスペースが含まれる場合はクォートで囲む
cd "C:\Users\Your Name\Projects\centos"
```

**5. 文字エンコーディングの問題**
```powershell
# PowerShellでUTF-8を使用
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### パフォーマンス最適化

**1. WSL 2を使用する**
- Docker Desktop設定で「Use WSL 2 based engine」を有効
- WSL 2内でプロジェクトを実行すると高速

**2. Windows Defenderの除外設定**
- プロジェクトフォルダを除外
- Docker Desktop関連フォルダを除外

## 📝 Windows開発環境のセットアップ

### 推奨ツール

1. **PowerShell 7+**
   ```powershell
   winget install Microsoft.PowerShell
   ```

2. **Windows Terminal**
   ```powershell
   winget install Microsoft.WindowsTerminal
   ```

3. **Visual Studio Code**
   ```powershell
   winget install Microsoft.VisualStudioCode
   ```

4. **Docker Desktop**
   - [公式サイト](https://www.docker.com/products/docker-desktop/)からダウンロード

### VSCode拡張機能

推奨拡張機能：
- Docker (ms-azuretools.vscode-docker)
- Remote - Containers (ms-vscode-remote.remote-containers)
- PowerShell (ms-vscode.powershell)

## 🔐 セキュリティ注意事項 (Windows)

⚠️ **Windows環境での注意事項:**

1. **Windows Defenderの設定**
   - 除外設定は最小限に
   - 定期的なスキャンを実行

2. **ファイアウォール設定**
   - Docker用ポートの開放確認
   - 不要なポート開放の回避

3. **実行ポリシー**
   - `RemoteSigned`レベルを推奨
   - `Unrestricted`は避ける

## 💡 パフォーマンス改善のコツ

1. **WSL 2を活用**
   - プロジェクトをWSL 2内に配置
   - LinuxベースのDockerコンテナとの親和性が高い

2. **SSDを使用**
   - Docker Desktop用ストレージはSSDに
   - 仮想ディスクのサイズを適切に設定

3. **メモリ割り当て**
   - Docker Desktopのメモリ設定を調整
   - 8GB以上のRAMを推奨

## 📚 参考情報 (Windows)

- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/)
- [WSL 2 Documentation](https://docs.microsoft.com/windows/wsl/)
- [Windows Terminal](https://docs.microsoft.com/windows/terminal/)

## 🤝 コントリビューション

プロジェクトへの貢献を歓迎します！Windows固有の改善提案も大歓迎です。

1. このリポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更をコミット
4. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。