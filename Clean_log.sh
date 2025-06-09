#!/bin/bash
## name: 清理青龙日志
## cron: 0 3 * * *

echo "开始清理日志"
pwd
# ls ../log
find ../log -mtime +10 -name "*.log"
find ../log -mtime +10 -name "*.log" -exec rm -rf {} \;
echo "清理日志完成"
