FROM dokken/centos-stream-9:latest

ARG DOCKER_USER="jimbo"
ARG PASSWORD="coFa3LMmKf4FLMu"

RUN mkdir -p /home && \
    chmod 755 /home

# create needed users
RUN useradd \
    -m -s /bin/bash \
    -c "HAL" \
    hal
RUN useradd \
    -m -s /bin/bash \
    -c "${DOCKER_USER}" \
    ${DOCKER_USER}

# ユーザ hal のパスワードを変更
RUN echo "hal:halhal" | chpasswd && \
    echo "${DOCKER_USER}:${PASSWORD}" | chpasswd

RUN dnf update -y
RUN dnf install -y \
    vim \
    git \
    which

# sudo をユーザーで使用できるようにする
# visudo 
## 100行目付近
# hal ALL=(ALL) ALL

# 前期・後期試験ともに先生がlinuxイメージを用意するので、その際はそちらを使うこと
RUN dnf install -y sudo && \
    echo "hal ALL=(ALL) ALL" >> /etc/sudoers && \
    echo "${DOCKER_USER} ALL=(ALL) ALL" >> /etc/sudoers && \
    chmod 0440 /etc/sudoers

# echo "jimbo.local" >> /etc/hostname

# xeyesを使用できるようインストール
#RUN dnf install xorg-x11-apps -y 

# $xeyes &
# を実行することで、バックグラウンドでの実行することができる。

# cat /etc/passwd

USER hal
CMD [ "/bin/bash" ]