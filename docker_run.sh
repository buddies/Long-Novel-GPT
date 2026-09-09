#!/bin/bash

# 构建并启动docker
# docker build -t maoxiaoyuz/long-novel-gpt .
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker build --network host --build-arg HTTP_PROXY=http://127.0.0.1:7890 --build-arg HTTPS_PROXY=http://127.0.0.1:7890 -t maoxiaoyuz/long-novel-gpt .
docker tag maoxiaoyuz/long-novel-gpt maoxiaoyuz/long-novel-gpt:2.2
docker tag maoxiaoyuz/long-novel-gpt maoxiaoyuz/long-novel-gpt:latest

# 运行：将项目代码与资源挂载进容器，修改代码/资源后无需重新 docker build
#  - 后端代码（backend/ core/ llm_api/ prompts/ custom/ config.py start.sh）挂载到 /app
#  - 前端静态资源（frontend/）挂载到 nginx 的 /usr/share/nginx/html
# 修改代码后需重启容器生效：docker restart <容器名>（或设置 RELOAD=true 自动重载）
docker run -p 80:80 \
    --env-file "$SCRIPT_DIR/.env" \
    -v "$SCRIPT_DIR":/app \
    -v "$SCRIPT_DIR/frontend":/usr/share/nginx/html \
    --add-host=host.docker.internal:host-gateway \
    -d maoxiaoyuz/long-novel-gpt:latest