#!/bin/bash

# CentOS SV41 Docker セットアップスクリプト
# 使用方法: ./setup.sh [オプション]

set -e  # エラー時に停止

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
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

# ヘルプ表示
show_help() {
    echo "CentOS SV41 Docker セットアップスクリプト"
    echo ""
    echo "使用方法:"
    echo "  ./setup.sh [オプション]"
    echo ""
    echo "オプション:"
    echo "  build     - Dockerイメージをビルド"
    echo "  start     - コンテナを起動（ビルドも実行）"
    echo "  stop      - コンテナを停止"
    echo "  restart   - コンテナを再起動"
    echo "  clean     - コンテナとイメージを削除"
    echo "  logs      - コンテナのログを表示"
    echo "  shell     - コンテナにシェルでアクセス"
    echo "  status    - コンテナの状態を確認"
    echo "  init      - 初期セットアップ（権限設定など）"
    echo "  help      - このヘルプを表示"
    echo ""
}

# 初期セットアップ
init_setup() {
    log_info "初期セットアップを開始します..."
    
    # 必要なディレクトリが存在するか確認
    local dirs=("www/html" "data" "etc/httpd/conf" "etc/httpd/conf.d" "etc/httpd/conf.modules.d" "etc/pki/tls" "httpd/conf.d" "httpd/conf.modules.d")
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_warning "ディレクトリが存在しません: $dir"
            mkdir -p "$dir"
            log_info "ディレクトリを作成しました: $dir"
        fi
    done
    
    # Apache設定ディレクトリの権限設定
    log_info "Apache設定ディレクトリの権限を設定中..."
    
    # macOSの場合、apacheユーザー（UID 48）の代わりに適切な権限を設定
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "macOS環境を検出しました。適切な権限を設定します..."
        find etc/httpd -type f -exec chmod 644 {} \;
        find etc/httpd -type d -exec chmod 755 {} \;
        find httpd -type f -exec chmod 644 {} \;
        find httpd -type d -exec chmod 755 {} \;
    else
        # Linux環境の場合
        if command -v chown >/dev/null 2>&1; then
            sudo chown -R 48:48 etc/httpd/ 2>/dev/null || log_warning "権限設定に失敗しました（sudo権限が必要な可能性があります）"
            sudo chown -R 48:48 httpd/ 2>/dev/null || log_warning "権限設定に失敗しました（sudo権限が必要な可能性があります）"
        fi
    fi
    
    log_success "初期セットアップが完了しました！"
}

# Dockerイメージビルド
build_image() {
    log_info "Dockerイメージをビルドしています..."
    
    # プロキシ設定の確認
    if [ ! -z "$HTTP_PROXY" ] || [ ! -z "$HTTPS_PROXY" ]; then
        log_info "プロキシ設定を検出しました"
        log_info "HTTP_PROXY: ${HTTP_PROXY:-未設定}"
        log_info "HTTPS_PROXY: ${HTTPS_PROXY:-未設定}"
        
        # プロキシ引数を構築
        PROXY_ARGS=""
        if [ ! -z "$HTTP_PROXY" ]; then
            PROXY_ARGS="$PROXY_ARGS --build-arg HTTP_PROXY=$HTTP_PROXY"
        fi
        if [ ! -z "$HTTPS_PROXY" ]; then
            PROXY_ARGS="$PROXY_ARGS --build-arg HTTPS_PROXY=$HTTPS_PROXY"
        fi
        if [ ! -z "$NO_PROXY" ]; then
            PROXY_ARGS="$PROXY_ARGS --build-arg NO_PROXY=$NO_PROXY"
        fi
        
        log_info "プロキシ設定でビルドを実行します..."
        if docker build $PROXY_ARGS -t centos-sv .; then
            log_success "Dockerイメージのビルドが完了しました！"
        else
            log_error "Dockerイメージのビルドに失敗しました"
            log_info "プロキシ設定を確認してください: DOCKER_PROXY_SETUP.md"
            exit 1
        fi
    else
        log_info "プロキシ設定なしでビルドを実行します..."
        if docker build -t centos-sv .; then
            log_success "Dockerイメージのビルドが完了しました！"
        else
            log_error "Dockerイメージのビルドに失敗しました"
            exit 1
        fi
    fi
}

# コンテナ起動
start_container() {
    log_info "コンテナを起動しています..."
    
    # まずイメージをビルド
    build_image
    
    # 既存のコンテナを停止・削除
    if docker ps -a --format "table {{.Names}}" | grep -q "centos-sv-container"; then
        log_info "既存のコンテナを停止・削除しています..."
        docker stop centos-sv-container 2>/dev/null || true
        docker rm centos-sv-container 2>/dev/null || true
    fi
    
    # コンテナを起動
    if docker compose up -d; then
        log_success "コンテナが起動しました！"
        log_info "アクセスURL:"
        log_info "  HTTP:  http://localhost"
        log_info "  HTTPS: https://localhost"
        log_info "コンテナにアクセス: ./setup.sh shell"
    else
        log_error "コンテナの起動に失敗しました"
        exit 1
    fi
}

# コンテナ停止
stop_container() {
    log_info "コンテナを停止しています..."
    
    if docker compose down; then
        log_success "コンテナを停止しました"
    else
        log_error "コンテナの停止に失敗しました"
        exit 1
    fi
}

# コンテナ再起動
restart_container() {
    log_info "コンテナを再起動しています..."
    stop_container
    start_container
}

# クリーンアップ
clean_all() {
    log_warning "コンテナとイメージを削除します..."
    read -p "本当に削除しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down 2>/dev/null || true
        docker rmi centos-sv 2>/dev/null || true
        docker volume prune -f 2>/dev/null || true
        log_success "クリーンアップが完了しました"
    else
        log_info "キャンセルしました"
    fi
}

# ログ表示
show_logs() {
    log_info "コンテナのログを表示します..."
    docker compose logs -f
}

# シェルアクセス
shell_access() {
    log_info "コンテナにシェルでアクセスします..."
    
    if docker ps --format "table {{.Names}}" | grep -q "centos-sv-container"; then
        docker exec -it centos-sv-container /bin/bash
    else
        log_error "コンテナが起動していません。先に 'start' を実行してください"
        exit 1
    fi
}

# ステータス確認
check_status() {
    log_info "コンテナの状態を確認しています..."
    
    echo ""
    echo "=== Docker Compose サービス ==="
    docker compose ps 2>/dev/null || echo "docker-compose.yamlが見つかりません"
    
    echo ""
    echo "=== Docker イメージ ==="
    docker images | grep centos-sv || echo "centos-svイメージが見つかりません"
    
    echo ""
    echo "=== Docker ボリューム ==="
    docker volume ls | grep centos || echo "関連するボリュームが見つかりません"
}

# メイン処理
main() {
    case "${1:-help}" in
        "build")
            build_image
            ;;
        "start")
            start_container
            ;;
        "stop")
            stop_container
            ;;
        "restart")
            restart_container
            ;;
        "clean")
            clean_all
            ;;
        "logs")
            show_logs
            ;;
        "shell")
            shell_access
            ;;
        "status")
            check_status
            ;;
        "init")
            init_setup
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            log_error "不明なオプション: $1"
            show_help
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@"