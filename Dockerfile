FROM docker.io/redhat/ubi9-init:latest

# EPELリポジトリとCRBを有効にしてBINDをインストール
RUN dnf update -y && \
    dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    /usr/bin/crb enable && \
    dnf install -y \
      sudo \
      which \
      git \
      openssh-clients \
      tar \
      gzip \
      bzip2 \
      xz \
      make \
      cmake \
      gcc \
      gcc-c++ \
      glibc-langpack-en \
      httpd \
      vim \
      php \
      php-pear \
      php-fpm \
      mod_ssl \
      bind-utils \
      dnsmasq && \
    dnf clean all

# ユーザーを追加してパスワードをhalhalに設定
RUN useradd -m hal && \
    echo "hal:halhal" | chpasswd

# PHP-FPM設定: UnixソケットからTCPソケットに変更
RUN sed -i 's|^listen = /run/php-fpm/www.sock|listen = 127.0.0.1:9000|' /etc/php-fpm.d/www.conf && \
    sed -i 's|^listen.acl_users = apache,nginx|;listen.acl_users = apache,nginx|' /etc/php-fpm.d/www.conf

# Apache設定: PHP-FPMとの連携をTCPソケットに変更
RUN sed -i 's|proxy:unix:/run/php-fpm/www.sock\|fcgi://localhost|proxy:fcgi://127.0.0.1:9000|g' /etc/httpd/conf.d/php.conf

# DNS設定ディレクトリを作成
RUN mkdir -p /etc/dnsmasq.d && \
    chmod 755 /etc/dnsmasq.d

# サービス自動起動設定
RUN systemctl enable httpd && \
    systemctl enable php-fpm && \
    systemctl enable dnsmasq

COPY .bashrc /root/.bashrc

# Basic 認証 (.htaccess 方式) 設定（ユーザ: cent / パスワード: centpass）
# RUN set -e; \
#         mkdir -p /var/www/html/secret; \
#         echo 'secret page' > /var/www/html/secret/index.html; \
#         printf '%s\n' \
#             'AuthUserFile /etc/httpd/conf/.htpasswd' \
#             'AuthGroupFile /dev/null' \
#             'AuthName "Secret Area"' \
#             'AuthType Basic' \
#             'Require user cent' \
#             > /var/www/html/secret/.htaccess; \
#         htpasswd -b -c /etc/httpd/conf/.htpasswd cent osaka; \
#         chown apache:apache /etc/httpd/conf/.htpasswd; chmod 640 /etc/httpd/conf/.htpasswd; \
#         printf '%s\n' '<Directory "/var/www/html/secret">' '    AllowOverride AuthConfig' '</Directory>' > /etc/httpd/conf.d/secret-override.conf

USER root