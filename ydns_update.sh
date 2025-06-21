#!/bin/sh
## name: ydns IP更新
## cron: */5 * * * *

# YDNS DDNS 更新脚本 for 青龙面板 (带IP变化检测)
# 优化内容：
# 1. 添加IP变化检测，避免不必要的更新
# 2. 直接内嵌配置变量
# 3. 只处理IPv4地址

# ==================== 用户配置区域 =====================
YDNS_HOST="yourdomian.ydns.eu"    # 您的域名
YDNS_USER="youremail"             # YDNS用户名/邮箱
YDNS_PASS="yourpassword"          # YDNS密码

# 获取IPv4的服务（确保只返回IPv4地址）
IP_API="http://members.3322.org/dyndns/getip"

# 上次IP记录文件（用于检测变化）
# 青龙版本v2.12.2以下    "/ql/scripts/hlt1995_qlScript/ydns_last_ip.txt"
# 青龙版本v2.12.2及以上  "/ql/data/scripts/hlt1995_qlScript/ydns_last_ip.txt"
IP_FILE="/ql/scripts/hlt1995_qlScript/ydns_last_ip.txt"

# 调试模式（true时显示详细输出）
DEBUG="false"
# =====================================================

# 日志文件路径（青龙面板可查看执行日志，无需文件）
LOG="/dev/null"

# 获取当前公网IPv4地址
get_current_ip() {
    curl -4 -s "$IP_API" 2>/dev/null
}

# 获取上次记录的IP
get_last_ip() {
    if [ -f "$IP_FILE" ]; then
        cat "$IP_FILE" 2>/dev/null
    else
        echo ""
    fi
}

# 保存当前IP到记录文件
save_current_ip() {
    echo "$1" > "$IP_FILE"
}

# 更新YDNS记录
update_ydns() {
    local ip="$1"
    
    # 发送更新请求
    local url="https://ydns.io/api/v1/update/?host=${YDNS_HOST}&ip=${ip}"
    echo "请求URL: $url" | tee -a "$LOG"
    
    local response=$(curl -s -u "${YDNS_USER}:${YDNS_PASS}" "$url")
    echo "原始响应: $response" | tee -a "$LOG"
    
    # 处理响应 (支持ok/good/nochg响应)
    if echo "$response" | grep -q -E "ok|good|nochg"; then
        echo "更新成功！响应: ${response}" | tee -a "$LOG"
        return 0
    elif echo "$response" | grep -q "error"; then
        echo "更新失败：${response}" >&2 | tee -a "$LOG"
        return 1
    else
        echo "未知响应：${response}" >&2 | tee -a "$LOG"
        return 1
    fi
}

# 主函数
main() {
    [ "$DEBUG" = "true" ] && set -x
    
    echo "===== YDNS DDNS 更新启动 =====" | tee -a "$LOG"
    echo "域名: ${YDNS_HOST}" | tee -a "$LOG"
    
    # 获取当前IP和上次IP
    current_ip=$(get_current_ip)
    last_ip=$(get_last_ip)
    
    if [ -z "$current_ip" ]; then
        echo "错误：无法获取公网IP" >&2 | tee -a "$LOG"
        exit 1
    fi
    
    echo "当前公网IPv4: $current_ip" | tee -a "$LOG"
    echo "上次记录IPv4: $last_ip" | tee -a "$LOG"
    
    # 比较当前IP和上次IP
    if [ "$current_ip" = "$last_ip" ]; then
        echo "IP地址未变化，跳过更新" | tee -a "$LOG"
    else
        echo "检测到IP变化，执行更新..." | tee -a "$LOG"
        if update_ydns "$current_ip"; then
            save_current_ip "$current_ip"
            echo "已保存新IP: $current_ip" | tee -a "$LOG"
        fi
    fi
    
    echo "===== 更新完成 =====" | tee -a "$LOG"
}

# 执行主函数
main
