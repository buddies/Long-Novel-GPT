FROM python:3.12-slim

WORKDIR /app

# Install nginx and iproute2
RUN apt-get update && apt-get install -y nginx iproute2 && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default \
    && rm -f /etc/nginx/sites-available/default

# 只安装依赖，不复制项目代码/资源（项目代码在 docker run 时通过 -v 挂载）
COPY backend/requirements.txt .
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install -r requirements.txt

# 复制 nginx 配置模板（start.sh 会根据环境变量调整端口/后端地址）
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# 复制启动脚本（通常会被挂载到 /app 的 start.sh 覆盖，仅作兜底）
COPY start.sh .
RUN chmod +x start.sh

# EXPOSE $FRONTEND_PORT

CMD ["bash", "./start.sh"] 