#!/bin/bash

# CentOS SV41 初期化スクリプト
# Apache設定ファイルの権限設定と初期セットアップ

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Apache設定ファイルのサンプル作成
create_sample_configs() {
    log_info "Apache設定ファイルのサンプルを作成中..."
    
    # Basic認証用の設定ファイルをhttpd/conf.dに作成（setup.shでマウントされる）
    if [ ! -f "httpd/conf.d/secret-auth.conf" ]; then
        cat > "httpd/conf.d/secret-auth.conf" << 'EOF'
# Basic認証設定
<Directory "/var/www/html/secret">
    AuthUserFile /etc/httpd/conf/.htpasswd
    AuthGroupFile /dev/null
    AuthName "Secret Area"
    AuthType Basic
    Require user cent
    AllowOverride AuthConfig
</Directory>
EOF
        log_success "secret-auth.confを作成しました"
    fi
    
    # PHP設定の確認
    if [ ! -f "etc/httpd/conf.d/php.conf" ]; then
        log_warning "php.confが見つかりません。デフォルトの設定を作成します..."
        cat > "etc/httpd/conf.d/php.conf" << 'EOF'
#
# PHP is an HTML-embedded scripting language which attempts to make it
# easy for developers to write dynamically generated webpages.
#
<IfModule prefork.c>
  LoadModule php_module modules/libphp.so
</IfModule>
<IfModule !prefork.c>
  LoadModule php_module modules/libphp.so
</IfModule>

#
# Cause the PHP interpreter to handle files with a .php extension.
#
<FilesMatch \.(php|phar)$>
    SetHandler application/x-httpd-php
</FilesMatch>

#
# Allow php to handle Multiviews
#
AddType text/html .php

#
# Add index.php to the list of files that will be served as directory
# indexes.
#
DirectoryIndex index.php

# Configure proxy for PHP-FPM
<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
EOF
        log_success "デフォルトのphp.confを作成しました"
    fi
}

# ディレクトリ構造の確認と作成
setup_directories() {
    log_info "必要なディレクトリ構造を確認・作成中..."
    
    local dirs=(
        "www/html"
        "www/html/secret"
        "data"
        "etc/httpd/conf"
        "etc/httpd/conf.d"
        "etc/httpd/conf.modules.d"
        # "etc/httpd/logs" "etc/httpd/modules" "etc/httpd/run" "etc/httpd/state" は既存のシンボリックリンクのためスキップ
        "etc/pki/tls"
        "etc/pki/tls/certs"
        "etc/pki/tls/private"
        "httpd/conf.d"
        "httpd/conf.modules.d"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ] && [ ! -L "$dir" ]; then
            mkdir -p "$dir"
            log_info "ディレクトリを作成: $dir"
        elif [ -L "$dir" ]; then
            log_info "シンボリックリンクをスキップ: $dir"
        fi
    done
    
    log_success "ディレクトリ構造の確認が完了しました"
}

# Apache設定ファイルの権限設定
setup_permissions() {
    log_info "Apache設定ファイルの権限を設定中..."
    
    # macOS環境での権限設定
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "macOS環境を検出しました"
        
        # ファイルとディレクトリの権限を適切に設定
        find etc/httpd -type f -exec chmod 644 {} \; 2>/dev/null || true
        find etc/httpd -type d -exec chmod 755 {} \; 2>/dev/null || true
        find httpd -type f -exec chmod 644 {} \; 2>/dev/null || true
        find httpd -type d -exec chmod 755 {} \; 2>/dev/null || true
        
        # www-dataディレクトリの権限
        find www -type f -exec chmod 644 {} \; 2>/dev/null || true
        find www -type d -exec chmod 755 {} \; 2>/dev/null || true
        
        log_success "macOS用の権限設定が完了しました"
        
    # Linux環境での権限設定
    else
        log_info "Linux環境を検出しました"
        
        # Apache用のUID/GID (通常は48:48)
        local apache_uid=48
        local apache_gid=48
        
        # 権限設定を試行
        if command -v chown >/dev/null 2>&1; then
            if sudo -n true 2>/dev/null; then
                sudo chown -R ${apache_uid}:${apache_gid} etc/httpd/ 2>/dev/null || log_warning "etc/httpd/の権限設定に失敗"
                sudo chown -R ${apache_uid}:${apache_gid} httpd/ 2>/dev/null || log_warning "httpd/の権限設定に失敗"
                sudo chown -R ${apache_uid}:${apache_gid} www/ 2>/dev/null || log_warning "www/の権限設定に失敗"
                log_success "Linux用の権限設定が完了しました"
            else
                log_warning "sudo権限がありません。Docker内で権限が自動調整されます"
            fi
        fi
    fi
}

# サンプルWebページの作成
create_sample_pages() {
    log_info "サンプルWebページを作成中..."
    
    # index.phpが存在しない場合は作成
    if [ ! -f "www/html/index.php" ]; then
        cat > "www/html/index.php" << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CentOS SV41 - Apache Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #333; color: white; padding: 20px; border-radius: 5px; }
        .content { margin: 20px 0; }
        .info-box { background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 CentOS SV41 Apache Server</h1>
            <p>Apache + PHP-FPM が正常に動作しています！</p>
        </div>
        
        <div class="content">
            <div class="info-box success">
                <h3>✅ サーバー情報</h3>
                <p><strong>サーバー時刻:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
                <p><strong>PHP バージョン:</strong> <?php echo phpversion(); ?></p>
                <p><strong>サーバーソフトウェア:</strong> <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown'; ?></p>
            </div>
            
            <div class="info-box">
                <h3>📁 テストページ</h3>
                <ul>
                    <li><a href="info.php">PHP情報 (phpinfo)</a></li>
                    <li><a href="secret/">Basic認証テスト</a> - ユーザー: cent, パスワード: osaka</li>
                </ul>
            </div>
            
            <div class="info-box warning">
                <h3>⚠️ セキュリティ注意</h3>
                <p>本番環境では info.php を削除し、適切なセキュリティ設定を行ってください。</p>
            </div>
        </div>
    </div>
</body>
</html>
EOF
        log_success "index.phpを作成しました"
    fi
    
    # info.phpが存在しない場合は作成
    if [ ! -f "www/html/info.php" ]; then
        cat > "www/html/info.php" << 'EOF'
<?php
// PHP情報表示ページ
// セキュリティのため、本番環境では削除してください

phpinfo();
?>
EOF
        log_success "info.phpを作成しました"
    fi
    
    # secret/index.htmlが存在しない場合は作成
    if [ ! -f "www/html/secret/index.html" ]; then
        cat > "www/html/secret/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secret Area - CentOS SV41</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #333; }
        .success { background: #d4edda; padding: 20px; border-radius: 5px; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Secret Area</h1>
        </div>
        
        <div class="success">
            <h3>✅ Basic認証が成功しました！</h3>
            <p>このページはBasic認証で保護されています。</p>
            <p><strong>認証情報:</strong></p>
            <ul>
                <li>ユーザー名: cent</li>
                <li>パスワード: osaka</li>
            </ul>
        </div>
        
        <p><a href="../">← メインページに戻る</a></p>
    </div>
</body>
</html>
EOF
        log_success "secret/index.htmlを作成しました"
    fi
}

# .htpasswdファイルの作成確認
check_htpasswd() {
    log_info ".htpasswdファイルの確認中..."
    
    if [ ! -f "etc/httpd/conf/.htpasswd" ]; then
        log_warning ".htpasswdファイルが見つかりません"
        log_info "Dockerfileで自動作成されますが、手動で作成する場合は以下のコマンドを使用してください:"
        log_info "  htpasswd -b -c etc/httpd/conf/.htpasswd cent osaka"
    else
        log_success ".htpasswdファイルが見つかりました"
    fi
}

# メイン実行
main() {
    echo "=== CentOS SV41 初期化スクリプト ==="
    echo ""
    
    setup_directories
    create_sample_configs
    create_sample_pages
    setup_permissions
    check_htpasswd
    
    echo ""
    log_success "初期化が完了しました！"
    log_info "次のステップ:"
    log_info "  1. ./setup.sh build   - Dockerイメージをビルド"
    log_info "  2. ./setup.sh start   - コンテナを起動"
    log_info "  3. http://localhost にアクセス"
    echo ""
}

# 実行
main "$@"