# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

# 设置环境变量避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gzip \
    tar \
    systemctl \
    coreutils \
    bash \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 设置脚本执行权限
RUN chmod +x install.sh uninstall.sh
RUN chmod +x script/*.sh

# 创建必要的目录
RUN mkdir -p /opt/clash

# 运行安装脚本 (非交互模式)
# 注意：由于安装脚本需要交互输入订阅链接，我们需要修改或提供默认配置
RUN ./install.sh || true

# 暴露 Clash 常用端口
# 7890: HTTP 代理端口
# 7891: SOCKS5 代理端口
# 9090: 外部控制 API 端口
EXPOSE 7890 7891 9090

# 设置启动命令
# 使用 mihomo 作为主进程启动
CMD ["/opt/clash/bin/mihomo", "-d", "/opt/clash", "-f", "/opt/clash/runtime.yaml"]