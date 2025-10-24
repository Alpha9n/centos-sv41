# CentOS SV41 Docker Setup Script for PowerShell
# Usage: .\setup.ps1 [option]

param(
    [Parameter(Position = 0)]
    [ValidateSet("build", "start", "stop", "restart", "clean", "logs", "shell", "status", "init", "help", "")]
    [string]$Action = "help"
)

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

# Help function
function Show-Help {
    Write-Host "CentOS SV41 Docker セットアップスクリプト (PowerShell版)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "使用方法:"
    Write-Host "  .\setup.ps1 [オプション]"
    Write-Host ""
    Write-Host "オプション:"
    Write-Host "  build     - Dockerイメージをビルド"
    Write-Host "  start     - コンテナを起動（ビルドも実行）"
    Write-Host "  stop      - コンテナを停止"
    Write-Host "  restart   - コンテナを再起動"
    Write-Host "  clean     - コンテナとイメージを削除"
    Write-Host "  logs      - コンテナのログを表示"
    Write-Host "  shell     - コンテナにシェルでアクセス"
    Write-Host "  status    - コンテナの状態を確認"
    Write-Host "  init      - 初期セットアップ（権限設定など）"
    Write-Host "  help      - このヘルプを表示"
    Write-Host ""
    Write-Host "例:"
    Write-Host "  .\setup.ps1 init     # 初期セットアップ"
    Write-Host "  .\setup.ps1 start    # コンテナ起動"
    Write-Host "  .\setup.ps1 shell    # コンテナにアクセス"
    Write-Host ""
}

# Check if Docker is available
function Test-Docker {
    try {
        $null = docker --version
        return $true
    }
    catch {
        Write-Error "Dockerが見つかりません。Docker Desktopがインストールされ、起動していることを確認してください。"
        return $false
    }
}

# Initial setup
function Initialize-Setup {
    Write-Info "初期セットアップを開始します..."
    
    # Create necessary directories
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
    
    # Create sample web pages
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
    
    # Create Apache config samples
    if (-not (Test-Path "httpd\conf.d\secret-auth.conf")) {
        $authContent = @"
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
        Set-Content -Path "httpd\conf.d\secret-auth.conf" -Value $authContent -Encoding UTF8
        Write-Success "secret-auth.confを作成しました"
    }
    
    Write-Success "初期セットアップが完了しました！"
    Write-Info "次のステップ:"
    Write-Info "  1. .\setup.ps1 build   - Dockerイメージをビルド"
    Write-Info "  2. .\setup.ps1 start   - コンテナを起動"
    Write-Info "  3. http://localhost にアクセス"
}

# Build Docker image
function Build-Image {
    if (-not (Test-Docker)) { return }
    
    Write-Info "Dockerイメージをビルドしています..."
    
    try {
        docker build -t centos-sv . 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Dockerイメージのビルドが完了しました！"
        }
        else {
            Write-Error "Dockerイメージのビルドに失敗しました"
            exit 1
        }
    }
    catch {
        Write-Error "ビルド中にエラーが発生しました: $($_.Exception.Message)"
        exit 1
    }
}

# Start container
function Start-Container {
    if (-not (Test-Docker)) { return }
    
    Write-Info "コンテナを起動しています..."
    
    # Build image first
    Build-Image
    
    # Stop and remove existing container
    $existingContainer = docker ps -a --format "table {{.Names}}" | Select-String "centos-sv-container"
    if ($existingContainer) {
        Write-Info "既存のコンテナを停止・削除しています..."
        docker stop centos-sv-container 2>$null | Out-Null
        docker rm centos-sv-container 2>$null | Out-Null
    }
    
    # Start container
    try {
        docker compose up -d 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -eq 0) {
            Write-Success "コンテナが起動しました！"
            Write-Info "アクセスURL:"
            Write-Info "  HTTP:  http://localhost"
            Write-Info "  HTTPS: https://localhost"
            Write-Info "コンテナにアクセス: .\setup.ps1 shell"
        }
        else {
            Write-Error "コンテナの起動に失敗しました"
            exit 1
        }
    }
    catch {
        Write-Error "起動中にエラーが発生しました: $($_.Exception.Message)"
        exit 1
    }
}

# Stop container
function Stop-Container {
    if (-not (Test-Docker)) { return }
    
    Write-Info "コンテナを停止しています..."
    
    try {
        docker compose down 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -eq 0) {
            Write-Success "コンテナを停止しました"
        }
        else {
            Write-Error "コンテナの停止に失敗しました"
            exit 1
        }
    }
    catch {
        Write-Error "停止中にエラーが発生しました: $($_.Exception.Message)"
        exit 1
    }
}

# Restart container
function Restart-Container {
    Write-Info "コンテナを再起動しています..."
    Stop-Container
    Start-Container
}

# Clean up
function Remove-All {
    Write-Warning "コンテナとイメージを削除します..."
    $confirmation = Read-Host "本当に削除しますか？ (y/N)"
    if ($confirmation -eq "y" -or $confirmation -eq "Y") {
        docker compose down 2>$null | Out-Null
        docker rmi centos-sv 2>$null | Out-Null
        docker volume prune -f 2>$null | Out-Null
        Write-Success "クリーンアップが完了しました"
    }
    else {
        Write-Info "キャンセルしました"
    }
}

# Show logs
function Show-Logs {
    if (-not (Test-Docker)) { return }
    
    Write-Info "コンテナのログを表示します..."
    try {
        docker compose logs -f
    }
    catch {
        Write-Error "ログの表示に失敗しました: $($_.Exception.Message)"
    }
}

# Shell access
function Enter-Shell {
    if (-not (Test-Docker)) { return }
    
    Write-Info "コンテナにシェルでアクセスします..."
    
    $running = docker ps --format "table {{.Names}}" | Select-String "centos-sv-container"
    if ($running) {
        try {
            docker exec -it centos-sv-container /bin/bash
        }
        catch {
            Write-Error "シェルアクセスに失敗しました: $($_.Exception.Message)"
        }
    }
    else {
        Write-Error "コンテナが起動していません。先に 'start' を実行してください"
        exit 1
    }
}

# Check status
function Show-Status {
    Write-Info "コンテナの状態を確認しています..."
    
    Write-Host ""
    Write-Host "=== Docker Compose サービス ===" -ForegroundColor Cyan
    try {
        docker compose ps
    }
    catch {
        Write-Host "docker-compose.yamlが見つかりません"
    }
    
    Write-Host ""
    Write-Host "=== Docker イメージ ===" -ForegroundColor Cyan
    $images = docker images | Select-String "centos-sv"
    if ($images) {
        $images | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "centos-svイメージが見つかりません"
    }
    
    Write-Host ""
    Write-Host "=== Docker ボリューム ===" -ForegroundColor Cyan
    $volumes = docker volume ls | Select-String "centos"
    if ($volumes) {
        $volumes | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "関連するボリュームが見つかりません"
    }
}

# Main execution
switch ($Action) {
    "build" { Build-Image }
    "start" { Start-Container }
    "stop" { Stop-Container }
    "restart" { Restart-Container }
    "clean" { Remove-All }
    "logs" { Show-Logs }
    "shell" { Enter-Shell }
    "status" { Show-Status }
    "init" { Initialize-Setup }
    "help" { Show-Help }
    "" { Show-Help }
    default {
        Write-Error "不明なオプション: $Action"
        Show-Help
        exit 1
    }
}