<?php
// サーバー情報とPHP情報を取得
$server_info = [
    'hostname' => gethostname(),
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    'php_version' => phpversion(),
    'current_time' => date('Y-m-d H:i:s'),
    'server_ip' => $_SERVER['SERVER_ADDR'] ?? 'Unknown',
    'client_ip' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
];

// システム負荷情報
$load_avg = sys_getloadavg();
$memory_usage = memory_get_usage(true);
$memory_peak = memory_get_peak_usage(true);
?>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SV41 実習環境 | 神保恒介</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@300;400;500;600&family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <!-- AOS Animation -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --secondary-gradient: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            --success-gradient: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            --dark-gradient: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }
        
        /* アニメーション背景 */
        .animated-bg {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            background: var(--primary-gradient);
        }
        
        .floating-elements {
            position: absolute;
            width: 100%;
            height: 100%;
        }
        
        .float-element {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            animation: float 6s ease-in-out infinite;
        }
        
        .float-element:nth-child(1) { width: 100px; height: 100px; left: 15%; top: 20%; animation-delay: 0s; }
        .float-element:nth-child(2) { width: 150px; height: 150px; right: 20%; top: 10%; animation-delay: 2s; }
        .float-element:nth-child(3) { width: 80px; height: 80px; left: 70%; bottom: 30%; animation-delay: 4s; }
        .float-element:nth-child(4) { width: 120px; height: 120px; left: 10%; bottom: 20%; animation-delay: 1s; }
        
        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg) scale(1); }
            33% { transform: translateY(-20px) rotate(120deg) scale(1.1); }
            66% { transform: translateY(10px) rotate(240deg) scale(0.9); }
        }
        
        /* ナビゲーション */
        .navbar-glass {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        /* ヒーローセクション */
        .hero-section {
            min-height: 80vh;
            display: flex;
            align-items: center;
            position: relative;
        }
        
        .hero-content {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 3rem;
        }
        
        .title-gradient {
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: titleGlow 3s ease-in-out infinite;
        }
        
        @keyframes titleGlow {
            0%, 100% { filter: brightness(1); }
            50% { filter: brightness(1.2); }
        }
        
        /* カード */
        .glass-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(15px);
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.3s ease;
        }
        
        .glass-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
        }
        
        /* コードブロック */
        .code-block {
            background: #2d3748;
            color: #e2e8f0;
            font-family: 'Fira Code', monospace;
            border-radius: 10px;
            position: relative;
            overflow: hidden;
        }
        
        .code-header {
            background: #4a5568;
            padding: 0.5rem 1rem;
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .code-dots {
            display: flex;
            gap: 5px;
        }
        
        .code-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }
        
        .dot-red { background: #ff5f56; }
        .dot-yellow { background: #ffbd2e; }
        .dot-green { background: #27ca3f; }
        
        /* ステータスインジケーター */
        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        .status-online { background: #10b981; }
        .status-warning { background: #f59e0b; }
        .status-error { background: #ef4444; }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        
        /* プログレスバー */
        .animated-progress {
            height: 8px;
            border-radius: 4px;
            overflow: hidden;
            background: rgba(0, 0, 0, 0.1);
        }
        
        .progress-bar-animated {
            background: var(--success-gradient);
            animation: progressShine 2s infinite;
        }
        
        @keyframes progressShine {
            0% { background-position: -200% center; }
            100% { background-position: 200% center; }
        }
        
        /* メトリクス */
        .metric-card {
            text-align: center;
            padding: 1.5rem;
            border-radius: 15px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
        }
        
        .metric-value {
            font-size: 2rem;
            font-weight: 700;
            color: white;
        }
        
        .metric-label {
            color: rgba(255, 255, 255, 0.8);
            font-size: 0.9rem;
        }
        
        /* レスポンシブ */
        @media (max-width: 768px) {
            .hero-content { padding: 2rem 1.5rem; }
            .metric-value { font-size: 1.5rem; }
        }
    </style>
</head>
<body>
    <!-- アニメーション背景 -->
    <div class="animated-bg">
        <div class="floating-elements">
            <div class="float-element"></div>
            <div class="float-element"></div>
            <div class="float-element"></div>
            <div class="float-element"></div>
        </div>
    </div>
    
    <!-- ナビゲーション -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-glass fixed-top">
        <div class="container">
            <a class="navbar-brand fw-bold" href="#">
                <i class="fas fa-server me-2"></i>SV41 Lab
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="#"><i class="fas fa-home me-1"></i>ホーム</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/secret/"><i class="fas fa-lock me-1"></i>秘密エリア</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/info.php"><i class="fas fa-info-circle me-1"></i>PHP情報</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    
    <!-- ヒーローセクション -->
    <section class="hero-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="hero-content" data-aos="fade-up">
                        <div class="text-center mb-5">
                            <h1 class="display-3 fw-bold title-gradient mb-3">
                                SV41 実習環境
                            </h1>
                            <p class="lead text-muted mb-4">
                                <i class="fas fa-user-graduate me-2"></i>
                                神保恒介の Linux サーバー構築実習プロジェクト
                            </p>
                            <div class="d-flex justify-content-center align-items-center mb-4">
                                <span class="status-indicator status-online me-2"></span>
                                <span class="text-success fw-semibold">システム稼働中</span>
                                <span class="mx-3">|</span>
                                <i class="fas fa-clock me-1"></i>
                                <span id="current-time"><?php echo $server_info['current_time']; ?></span>
                            </div>
                        </div>
                        
                        <!-- サーバー情報 -->
                        <div class="row g-4 mb-5">
                            <div class="col-md-3 col-6" data-aos="fade-up" data-aos-delay="100">
                                <div class="metric-card">
                                    <div class="metric-value">
                                        <i class="fas fa-server"></i>
                                    </div>
                                    <div class="metric-label">CentOS</div>
                                </div>
                            </div>
                            <div class="col-md-3 col-6" data-aos="fade-up" data-aos-delay="200">
                                <div class="metric-card">
                                    <div class="metric-value">
                                        <i class="fab fa-php"></i>
                                    </div>
                                    <div class="metric-label">PHP <?php echo substr($server_info['php_version'], 0, 3); ?></div>
                                </div>
                            </div>
                            <div class="col-md-3 col-6" data-aos="fade-up" data-aos-delay="300">
                                <div class="metric-card">
                                    <div class="metric-value">
                                        <i class="fas fa-shield-alt"></i>
                                    </div>
                                    <div class="metric-label">SSL対応</div>
                                </div>
                            </div>
                            <div class="col-md-3 col-6" data-aos="fade-up" data-aos-delay="400">
                                <div class="metric-card">
                                    <div class="metric-value">
                                        <i class="fas fa-docker"></i>
                                    </div>
                                    <div class="metric-label">Docker</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <!-- 詳細情報セクション -->
    <section class="py-5">
        <div class="container">
            <div class="row g-4">
                <!-- システム情報 -->
                <div class="col-lg-6" data-aos="fade-right">
                    <div class="glass-card p-4 h-100">
                        <h3 class="h4 mb-4">
                            <i class="fas fa-info-circle text-primary me-2"></i>
                            システム情報
                        </h3>
                        <div class="table-responsive">
                            <table class="table table-borderless">
                                <tr>
                                    <td><i class="fas fa-desktop text-muted me-2"></i>ホスト名</td>
                                    <td><code><?php echo $server_info['hostname']; ?></code></td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-globe text-muted me-2"></i>サーバーIP</td>
                                    <td><code><?php echo $server_info['server_ip']; ?></code></td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-user text-muted me-2"></i>クライアントIP</td>
                                    <td><code><?php echo $server_info['client_ip']; ?></code></td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-memory text-muted me-2"></i>メモリ使用量</td>
                                    <td><code><?php echo number_format($memory_usage / 1024 / 1024, 2); ?> MB</code></td>
                                </tr>
                                <tr>
                                    <td><i class="fas fa-chart-line text-muted me-2"></i>システム負荷</td>
                                    <td><code><?php echo number_format($load_avg[0], 2); ?></code></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- PHPコード例 -->
                <div class="col-lg-6" data-aos="fade-left">
                    <div class="glass-card p-4 h-100">
                        <h3 class="h4 mb-4">
                            <i class="fab fa-php text-primary me-2"></i>
                            PHP動作確認
                        </h3>
                        <div class="code-block">
                            <div class="code-header">
                                <div class="code-dots">
                                    <div class="code-dot dot-red"></div>
                                    <div class="code-dot dot-yellow"></div>
                                    <div class="code-dot dot-green"></div>
                                </div>
                                <span>index.php</span>
                            </div>
                            <div class="p-3">
                                <pre><code>&lt;?php
echo "Hello from SV41!";
echo "Current Time: " . date('Y-m-d H:i:s');
echo "PHP Version: " . phpversion();
?&gt;</code></pre>
                            </div>
                        </div>
                        <div class="mt-3">
                            <div class="alert alert-success border-0">
                                <i class="fas fa-check-circle me-2"></i>
                                <strong>出力:</strong> <?php echo "Hello from SV41! "; ?>
                                PHP <?php echo phpversion(); ?> が正常に動作しています。
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- 機能テスト -->
            <div class="row mt-4">
                <div class="col-12" data-aos="fade-up">
                    <div class="glass-card p-4">
                        <h3 class="h4 mb-4">
                            <i class="fas fa-flask text-primary me-2"></i>
                            機能テスト
                        </h3>
                        <div class="row g-3">
                            <div class="col-md-4">
                                <div class="d-flex align-items-center">
                                    <span class="status-indicator status-online me-2"></span>
                                    <span>Apache HTTP Server</span>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="d-flex align-items-center">
                                    <span class="status-indicator status-online me-2"></span>
                                    <span>PHP-FPM</span>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="d-flex align-items-center">
                                    <span class="status-indicator status-online me-2"></span>
                                    <span>SSL/TLS暗号化</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mt-4">
                            <h6>アップタイム</h6>
                            <div class="animated-progress">
                                <div class="progress-bar progress-bar-animated" style="width: 95%"></div>
                            </div>
                            <small class="text-muted">システム稼働率: 95%</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <!-- フッター -->
    <footer class="py-4 mt-5" style="background: rgba(0, 0, 0, 0.1);">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <p class="text-white mb-0">
                        <i class="fas fa-graduation-cap me-2"></i>
                        <strong>SV41 Linux実習環境</strong> - 神保恒介
                    </p>
                </div>
                <div class="col-md-6 text-md-end">
                    <p class="text-white-50 mb-0">
                        <i class="fas fa-code me-1"></i>
                        Powered by CentOS + Apache + PHP + Docker
                    </p>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- AOS Animation JS -->
    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    
    <script>
        // AOS 初期化
        AOS.init({
            duration: 800,
            easing: 'ease-in-out',
            once: true
        });
        
        // リアルタイム時刻更新
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleString('ja-JP', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
            const timeElement = document.getElementById('current-time');
            if (timeElement) {
                timeElement.textContent = timeString;
            }
        }
        
        // 1秒ごとに時刻を更新
        setInterval(updateTime, 1000);
        
        // コンソールに隠しメッセージ
        console.log(`
        🚀 SV41 実習環境へようこそ！
        
        ╔══════════════════════════════════════╗
        ║  システム情報:                        ║
        ║  - PHP: <?php echo $server_info['php_version']; ?>                    ║
        ║  - Apache: <?php echo $server_info['server_software']; ?>      ║
        ║  - ホスト: <?php echo $server_info['hostname']; ?>               ║
        ║                                      ║
        ║  製作者: 神保恒介 🧑‍💻                ║
        ╚══════════════════════════════════════╝
        `);
        
        // Easter egg: Konami Code
        let konamiCode = [38,38,40,40,37,39,37,39,66,65];
        let konamiIndex = 0;
        
        document.addEventListener('keydown', function(e) {
            if (e.keyCode === konamiCode[konamiIndex]) {
                konamiIndex++;
                if (konamiIndex === konamiCode.length) {
                    // Secret animation
                    document.body.style.animation = 'rainbow 2s infinite';
                    setTimeout(() => {
                        document.body.style.animation = '';
                        alert('🎉 隠しコマンド発見！神保恒介からの挨拶だよ〜！');
                    }, 2000);
                    konamiIndex = 0;
                }
            } else {
                konamiIndex = 0;
            }
        });
    </script>
    
    <style>
        @keyframes rainbow {
            0% { filter: hue-rotate(0deg); }
            100% { filter: hue-rotate(360deg); }
        }
    </style>
</body>
</html>