#!/bin/bash

# Alpine下执行命令
# 定义备份包路径（你可手动修改日期）
BACKUP_FILE="/sdcard/ql_data_backup_$(date +%Y%m%d).tar.gz"

# 判断文件是否存在
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 未找到备份文件: $BACKUP_FILE"
    exit 1
fi

# 停止青龙服务（如 pm2 存在）
if command -v pm2 &> /dev/null; then
    echo "🛑 停止青龙服务..."
    pm2 stop all
fi

# 解压备份文件到 /ql
echo "📦 正在还原备份..."
tar -zxvf "$BACKUP_FILE" -C /ql

# 启动青龙服务
if command -v pm2 &> /dev/null; then
    echo "🚀 启动青龙服务..."
    pm2 restart all
fi

echo "✅ 青龙面板数据恢复完成！按Enter结束脚本！手动启动青龙面板！"
