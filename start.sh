#!/bin/bash

# 设置默认值
FRONTEND_PORT=${FRONTEND_PORT:-80}
BACKEND_PORT=${BACKEND_PORT:-7869}
BACKEND_HOST=${BACKEND_HOST:-0.0.0.0}
WORKERS=${WORKERS:-4}
THREADS=${THREADS:-2}
TIMEOUT=${TIMEOUT:-120}
RELOAD=${RELOAD:-false}

# 项目根目录挂载在 /app，后端代码位于 /app/backend，
# 通过 PYTHONPATH 让 gunicorn 能直接找到 app 模块

export PYTHONPATH="${PYTHONPATH:+$PYTHONPATH:}/app/backend"

# 替换nginx配置中的端口
sed -i "s/listen 9999/listen $FRONTEND_PORT/g" /etc/nginx/conf.d/default.conf
sed -i "s/host.docker.internal:7869/localhost:$BACKEND_PORT/g" /etc/nginx/conf.d/default.conf

# 启动nginx
nginx

# 启动gunicorn（保持工作目录为 /app，使 prompts/、tmp.yaml 等相对路径正确）
# 设置 RELOAD=true 可在修改 Python 代码后自动重载，无需重启容器
GUNICORN_ARGS=""
if [ "$RELOAD" = "true" ]; then
    GUNICORN_ARGS="--reload"
fi

gunicorn --bind $BACKEND_HOST:$BACKEND_PORT \
    --workers $WORKERS \
    --threads $THREADS \
    --worker-class gthread \
    --timeout $TIMEOUT \
    --access-logfile - \
    --error-logfile - \
    $GUNICORN_ARGS \
    app:app