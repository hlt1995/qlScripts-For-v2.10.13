#!/bin/sh
## name: ydns IP更新
## cron: */5 * * * *

# 1. 添加IP变化检测，避免不必要的更新
# 2. 只处理IPv4地址，适合公网用户
# 3. 第36和38行，根据自己的青龙版本把不要的注释掉即可

# 环境变量：YDNS_CONFIG
# 格式：域名|用户名|密码    举例：abc.ydns.eu|12345678@qq.com|a123456

# ========== 读取并解析环境变量 ==========
CONFIG="${YDNS_CONFIG:-}"

if [ -z "$CONFIG" ]; then
    echo "❌ 缺少环境变量 YDNS_CONFIG，格式应为：域名|用户名|密码"
    exit 1
fi

# 分割配置
YDNS_HOST=$(echo "$CONFIG" | cut -d '|' -f1)
YDNS_USER=$(echo "$CONFIG" | cut -d '|' -f2)
YDNS_PASS=$(echo "$CONFIG" | cut -d '|' -f3)

# 检查解析结果
if [ -z "$YDNS_HOST" ] || [ -z "$YDNS_USER" ] || [ -z "$YDNS_PASS" ]; then
    echo "❌ YDNS_CONFIG 格式错误，应为：域名|用户名|密码"
    exit 1
fi
# =======================================

# IPv4 地址获取接口
IP_API="http://members.3322.org/dyndns/getip"

# 上次IP记录文件路径（青龙v2.12.2以下）
IP_FILE="/ql/scripts/hlt1995_qlScript/ydns_last_ip.txt"
# 上次IP记录文件路径（青龙v2.12.2及以上）
# IP_FILE="/ql/data/scripts/hlt1995_qlScript/ydns_last_ip.txt"

# 调试模式
DEBUG="${DEBUG:-false}"

# 日志输出路径
LOG="/dev/null"

get_current_ip() {
    curl -4 -s "$IP_API" 2>/dev/null
}

get_last_ip() {
    [ -f "$IP_FILE" ] && cat "$IP_FILE" || echo ""
}

save_current_ip() {
    echo "$1" > "$IP_FILE"
}

update_ydns() {
    local ip="$1"
    local url="https://ydns.io/api/v1/update/?host=${YDNS_HOST}&ip=${ip}"
    echo "请求URL: $url" | tee -a "$LOG"

    local response=$(curl -s -u "${YDNS_USER}:${YDNS_PASS}" "$url")
    echo "原始响应: $response" | tee -a "$LOG"

    if echo "$response" | grep -q -E "ok|good|nochg"; then
        echo "✅ 更新成功！响应: ${response}" | tee -a "$LOG"
        return 0
    else
        echo "❌ 更新失败或响应异常：${response}" >&2 | tee -a "$LOG"
        return 1
    fi
}

main() {
    [ "$DEBUG" = "true" ] && set -x

    echo "===== YDNS DDNS 更新启动 =====" | tee -a "$LOG"
    echo "域名: ${YDNS_HOST}" | tee -a "$LOG"

    current_ip=$(get_current_ip)
    last_ip=$(get_last_ip)

    if [ -z "$current_ip" ]; then
        echo "❌ 无法获取公网IPv4地址" >&2 | tee -a "$LOG"
        exit 1
    fi

    echo "当前IP: $current_ip" | tee -a "$LOG"
    echo "上次IP: $last_ip" | tee -a "$LOG"

    if [ "$current_ip" = "$last_ip" ]; then
        echo "ℹ️ IP未变化，跳过更新" | tee -a "$LOG"
    else
        echo "🔄 IP已变化，开始更新..." | tee -a "$LOG"
        if update_ydns "$current_ip"; then
            save_current_ip "$current_ip"
            echo "📌 已保存新IP: $current_ip" | tee -a "$LOG"
        fi
    fi

    echo "===== 更新完成 =====" | tee -a "$LOG"
}

main
