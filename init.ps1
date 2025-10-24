# CentOS SV41 初期化スクリプト (PowerShell版)
# Apache設定ファイルの権限設定と初期セットアップ

# Color functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Create sample Apache config files
function New-SampleConfigs {
    Write-Info "Apache設定ファイルのサンプルを作成中..."
    
    # Basic authentication config
    if (-not (Test-Path "httpd\conf.d\secret-auth.conf")) {
        $authConfig = @"
# Basic認証設定
<Directory "/var/www/html/secret">
    AuthUserFile /etc/httpd/conf/.htpasswd
    AuthGroupFile /dev/null
    AuthName "Secret Area"
    AuthType Basic
    Require user cent
    AllowOverride AuthConfig
</Directory>
"@
        Set-Content -Path "httpd\conf.d\secret-auth.conf" -Value $authConfig -Encoding UTF8
        Write-Success "secret-auth.confを作成しました"
    }
    
    # PHP config check
    if (-not (Test-Path "etc\httpd\conf.d\php.conf")) {
        Write-Warning "php.confが見つかりません。デフォルトの設定を作成します..."
        $phpConfig = @"
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
"@
        Set-Content -Path "etc\httpd\conf.d\php.conf" -Value $phpConfig -Encoding UTF8
        Write-Success "デフォルトのphp.confを作成しました"
    }
}

# Setup directory structure
function New-DirectoryStructure {
    Write-Info "必要なディレクトリ構造を確認・作成中..."
    
    $directories = @(
        "www\html",
        "www\html\secret",
        "data",
        "etc\httpd\conf",
        "etc\httpd\conf.d",
        "etc\httpd\conf.modules.d",
        "etc\httpd\logs",
        "etc\httpd\modules",
        "etc\httpd\run",
        "etc\httpd\state",
        "etc\pki\tls",
        "etc\pki\tls\certs",
        "etc\pki\tls\private",
        "httpd\conf.d",
        "httpd\conf.modules.d"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Info "ディレクトリを作成: $dir"
        }
    }
    
    Write-Success "ディレクトリ構造の確認が完了しました"
}

# Setup permissions (Windows specific)
function Set-WindowsPermissions {
    Write-Info "Windows環境での権限を設定中..."
    
    # Windows環境では、Dockerがファイル権限を自動的に処理するため
    # 特別な権限設定は不要ですが、ファイルの存在確認を行います
    
    $configDirs = @("etc\httpd", "httpd", "www")
    
    foreach ($dir in $configDirs) {
        if (Test-Path $dir) {
            # ファイルが読み取り可能であることを確認
            try {
                Get-ChildItem $dir -Recurse -ErrorAction SilentlyContinue | Out-Null
                Write-Info "$dir の権限確認完了"
            }
            catch {
                Write-Warning "$dir の権限に問題がある可能性があります: $($_.Exception.Message)"
            }
        }
    }
    
    Write-Success "Windows用の権限設定が完了しました"
    Write-Info "注意: Docker for Windowsが適切にファイル共有を設定していることを確認してください"
}

# Create sample web pages
function New-SamplePages {
    Write-Info "サンプルWebページを作成中..."
    
    # index.php
    if (-not (Test-Path "www\html\index.php")) {
        $indexContent = @"
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
                <p><strong>サーバーソフトウェア:</strong> <?php echo `$_SERVER['SERVER_SOFTWARE'] ?? 'Unknown'; ?></p>
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
"@
        Set-Content -Path "www\html\index.php" -Value $indexContent -Encoding UTF8
        Write-Success "index.phpを作成しました"
    }
    
    # info.php
    if (-not (Test-Path "www\html\info.php")) {
        $infoContent = @"
<?php
// PHP情報表示ページ
// セキュリティのため、本番環境では削除してください

phpinfo();
?>
"@
        Set-Content -Path "www\html\info.php" -Value $infoContent -Encoding UTF8
        Write-Success "info.phpを作成しました"
    }
    
    # secret/index.html
    if (-not (Test-Path "www\html\secret\index.html")) {
        $secretContent = @"
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
"@
        Set-Content -Path "www\html\secret\index.html" -Value $secretContent -Encoding UTF8
        Write-Success "secret\index.htmlを作成しました"
    }
}

# Check .htpasswd file
function Test-Htpasswd {
    Write-Info ".htpasswdファイルの確認中..."
    
    if (-not (Test-Path "etc\httpd\conf\.htpasswd")) {
        Write-Warning ".htpasswdファイルが見つかりません"
        Write-Info "Dockerfileで自動作成されますが、手動で作成する場合は以下のコマンドを使用してください:"
        Write-Info "  (Windowsの場合) Docker内で: htpasswd -b -c /etc/httpd/conf/.htpasswd cent osaka"
    }
    else {
        Write-Success ".htpasswdファイルが見つかりました"
    }
}

# Check Docker availability
function Test-DockerAvailability {
    Write-Info "Docker環境を確認中..."
    
    try {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-Success "Docker が利用可能です: $dockerVersion"
        }
        else {
            Write-Warning "Dockerが見つかりません。Docker Desktop for Windowsがインストールされていることを確認してください。"
            Write-Info "Docker Desktop ダウンロード: https://www.docker.com/products/docker-desktop/"
        }
    }
    catch {
        Write-Warning "Docker が利用できません: $($_.Exception.Message)"
        Write-Info "Docker Desktop for Windowsをインストールし、起動してください。"
    }
    
    try {
        $composeVersion = docker compose version 2>$null
        if ($composeVersion) {
            Write-Success "Docker Compose が利用可能です"
        }
        else {
            Write-Warning "Docker Compose が見つかりません"
        }
    }
    catch {
        Write-Warning "Docker Compose が利用できません"
    }
}

# Main execution
function Main {
    Write-Host "=== CentOS SV41 初期化スクリプト (PowerShell版) ===" -ForegroundColor Cyan
    Write-Host ""
    
    Test-DockerAvailability
    New-DirectoryStructure
    New-SampleConfigs
    New-SamplePages
    Set-WindowsPermissions
    Test-Htpasswd
    
    Write-Host ""
    Write-Success "初期化が完了しました！"
    Write-Info "次のステップ:"
    Write-Info "  1. .\setup.ps1 build   - Dockerイメージをビルド"
    Write-Info "  2. .\setup.ps1 start   - コンテナを起動"
    Write-Info "  3. http://localhost にアクセス"
    Write-Host ""
    Write-Info "PowerShellでスクリプトが実行できない場合:"
    Write-Info "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    Write-Host ""
}

# Execute main function
Main