#!/bin/sh
## name: duckdns IP更新
## cron: */5 * * * *

# 1. 添加IP变化检测，避免不必要的更新
# 2. 只处理IPv4地址，适合公网用户
# 3. 第33和35行，根据自己的青龙版本把不要的注释掉即可

# 环境变量：DUCKDNS_CONFIG
# 格式：域名前缀|token    举例：abc|efdg5657e-6gh7-67gb-gh78-45djf4945040a

# ========== 读取并解析环境变量 ==========
CONFIG="${DUCKDNS_CONFIG:-}"

if [ -z "$CONFIG" ]; then
    echo "❌ 缺少环境变量 DUCKDNS_CONFIG，格式应为：域名前缀|token"
    exit 1
fi

# 拆分配置
DUCKDNS_DOMAIN=$(echo "$CONFIG" | cut -d '|' -f1)
DUCKDNS_TOKEN=$(echo "$CONFIG" | cut -d '|' -f2)

if [ -z "$DUCKDNS_DOMAIN" ] || [ -z "$DUCKDNS_TOKEN" ]; then
    echo "❌ DUCKDNS_CONFIG 格式错误，应为：域名前缀|token"
    exit 1
fi

# 获取IPv4地址的服务
IP_API="http://members.3322.org/dyndns/getip"

# 上次IP记录文件路径（青龙v2.12.2以下）
IP_FILE="/ql/scripts/hlt1995_qlScript/duckdns_last_ip.txt"
# 上次IP记录文件路径（青龙2.12.2及以上）
# IP_FILE="/ql/data/scripts/hlt1995_qlScript/duckdns_last_ip.txt"

# 是否开启调试模式（通过另一个变量控制）
DEBUG="${DEBUG:-false}"

# 日志路径（青龙面板可直接查看日志）
LOG="/dev/null"

# 获取当前公网IP
get_current_ip() {
    curl -4 -s "$IP_API" 2>/dev/null | tr -d '\n'
}

# 获取上次记录的IP
get_last_ip() {
    [ -f "$IP_FILE" ] && cat "$IP_FILE" | tr -d '\n' || echo ""
}

# 保存当前IP到文件
save_current_ip() {
    echo "$1" > "$IP_FILE"
}

# 检查IP格式合法性
is_valid_ip() {
    echo "$1" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
}

# 更新DuckDNS
update_duckdns() {
    local ip="$1"
    local url="https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&ip=${ip}"
    [ "$DEBUG" = "true" ] && echo "请求URL: $url" | tee -a "$LOG"

    local response=$(curl -4 -s "$url")
    [ "$DEBUG" = "true" ] && echo "原始响应: $response" | tee -a "$LOG"

    if [ "$response" = "OK" ]; then
        echo "✅ 更新成功：$response" | tee -a "$LOG"
        return 0
    else
        echo "❌ 更新失败：$response" >&2 | tee -a "$LOG"
        return 1
    fi
}

# 主流程
main() {
    [ "$DEBUG" = "true" ] && set -x

    echo "===== DuckDNS DDNS 更新启动 =====" | tee -a "$LOG"
    echo "域名: ${DUCKDNS_DOMAIN}.duckdns.org" | tee -a "$LOG"

    current_ip=$(get_current_ip)
    last_ip=$(get_last_ip)

    if ! is_valid_ip "$current_ip"; then
        echo "❌ 错误：获取到无效IP地址：'$current_ip'" >&2 | tee -a "$LOG"
        exit 1
    fi

    echo "当前公网IPv4: $current_ip" | tee -a "$LOG"
    echo "上次记录IPv4: $last_ip" | tee -a "$LOG"

    if [ "$current_ip" = "$last_ip" ]; then
        echo "ℹ️ IP未变，跳过更新" | tee -a "$LOG"
    else
        echo "🔄 IP变化，准备更新..." | tee -a "$LOG"
        if update_duckdns "$current_ip"; then
            save_current_ip "$current_ip"
            echo "📌 新IP已记录: $current_ip" | tee -a "$LOG"
        else
            exit 1
        fi
    fi

    echo "===== 更新完成 =====" | tee -a "$LOG"
}

main
