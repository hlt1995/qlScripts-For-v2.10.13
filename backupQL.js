#!/bin/bash

# 创建备份目录（如果不存在）
mkdir -p /sdcard/qlbackup

# 定义时间戳
DATE=$(date +%Y%m%d)

# 目标路径
BACKUP_PATH="/sdcard/qlbackup/ql_data_backup_${DATE}.tar.gz"

# 打包 config、db、scripts 目录
tar -zcvf "$BACKUP_PATH" -C /ql config db scripts

# 打印完成信息
echo "✅ 青龙面板已备份到：$BACKUP_PATH"
