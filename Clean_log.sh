#!/bin/bash
## name: 清理任务日志
## cron: 15 12 * * *

# ===== 用户配置区域 =====
# 设置日志保留天数
LOG_KEEP_DAYS=10
# ========================

echo "开始清理日志（保留最近 $LOG_KEEP_DAYS 天的日志）"
pwd

# 显示将被删除的日志文件
find ../log -mtime +$LOG_KEEP_DAYS -name "*.log"

# 删除超过保留天数的日志文件
find ../log -mtime +$LOG_KEEP_DAYS -name "*.log" -exec rm -rf {} \;

echo "清理日志完成"
