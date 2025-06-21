#!/bin/bash
## name: 清理任务日志
## cron: 15 12 * * *

# ===== 用户配置区域 =====
# 设置日志保留天数（超过这个天数的日志将被删除）
LOG_KEEP_DAYS=10
# ========================

echo "开始清理日志（保留最近 $LOG_KEEP_DAYS 天的日志）"

# 青龙日志主目录
QL_LOG_DIR="/ql/log"

# 计算实际需要匹配的时间（mtime +N 表示 N+1 天前）
DAYS_AGO=$((LOG_KEEP_DAYS - 1))

# 显示将被删除的日志文件
echo "以下日志将被删除："
find "$QL_LOG_DIR" -type f -name "*.log" -mtime +$DAYS_AGO

# 删除超过保留天数的日志文件
find "$QL_LOG_DIR" -type f -name "*.log" -mtime +$DAYS_AGO -exec rm -f {} \;

# 清理空目录（可选）
find "$QL_LOG_DIR" -type d -empty -delete

echo "清理日志完成"
