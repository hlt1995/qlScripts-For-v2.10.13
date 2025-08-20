#!/bin/sh
## name: duckdns IP更新 (支持A/AAAA/双栈)
## cron: */5 * * * *

# [36-37]行和[39-40]行，根据自己的青龙版本把不要的注释掉即可

# 环境变量：DUCKDNS_CONFIG
# 格式：域名前缀|token|记录类型
# 举例：
#   只更新IPv4：abc|efdg5657e-6gh7-67gb-gh78-45djf4945040a|A
#   只更新IPv6：abc|efdg5657e-6gh7-67gb-gh78-45djf4945040a|AAAA
#   同时更新v4/v6：abc|efdg5657e-6gh7-67gb-gh78-45djf4945040a|A&AAAA

CONFIG="${DUCKDNS_CONFIG:-}"

if [ -z "$CONFIG" ]; then
    echo "❌ 缺少环境变量 DUCKDNS_CONFIG，格式应为：域名前缀|token|记录类型(A/AAAA/A&AAAA)"
    exit 1
fi

# 拆分配置
DUCKDNS_DOMAIN=$(echo "$CONFIG" | cut -d '|' -f1)
DUCKDNS_TOKEN=$(echo "$CONFIG" | cut -d '|' -f2)
IP_TYPE=$(echo "$CONFIG" | cut -d '|' -f3)

if [ -z "$DUCKDNS_DOMAIN" ] || [ -z "$DUCKDNS_TOKEN" ] || [ -z "$IP_TYPE" ]; then
    echo "❌ DUCKDNS_CONFIG 格式错误，应为：域名前缀|token|记录类型(A/AAAA/A&AAAA)"
    exit 1
fi

# API 获取服务
IPV4_API="http://members.3322.org/dyndns/getip"
IPV6_API="https://api64.ipify.org"

# 上次记录文件路径（青龙v2.12.2以下）
IPV4_FILE="/ql/scripts/hlt1995_qlScript/duckdns_last_ipv4.txt"
IPV6_FILE="/ql/scripts/hlt1995_qlScript/duckdns_last_ipv6.txt"
# 青龙v2.12.2及以上请改路径
# IPV4_FILE="/ql/data/scripts/hlt1995_qlScript/duckdns_last_ipv4.txt"
# IPV6_FILE="/ql/data/scripts/hlt1995_qlScript/duckdns_last_ipv6.txt"

DEBUG="${DEBUG:-false}"
LOG="/dev/null"

# 获取 IP
get_ipv4() { curl -4 -s "$IPV4_API" 2>/dev/null | tr -d '\n'; }
get_ipv6() { curl -6 -s "$IPV6_API" 2>/dev/null | tr -d '\n'; }

# 文件读写
get_last_ip() { [ -f "$1" ] && cat "$1" | tr -d '\n' || echo ""; }
save_ip() { echo "$2" > "$1"; }

# DuckDNS 更新
update_duckdns() {
    local ip="$1"
    local url="https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&ip=${ip}"
    [ "$DEBUG" = "true" ] && echo "请求URL: $url" | tee -a "$LOG"

    local response=$(curl -s "$url")
    [ "$DEBUG" = "true" ] && echo "原始响应: $response" | tee -a "$LOG"

    if [ "$response" = "OK" ]; then
        echo "✅ DuckDNS 更新成功 (IP: $ip)" | tee -a "$LOG"
        return 0
    else
        echo "❌ DuckDNS 更新失败: $response" >&2 | tee -a "$LOG"
        return 1
    fi
}

# 更新逻辑
update_ip() {
    local type="$1"
    local current_ip last_ip file label

    if [ "$type" = "A" ]; then
        current_ip=$(get_ipv4)
        file="$IPV4_FILE"
        label="IPv4"
    else
        current_ip=$(get_ipv6)
        file="$IPV6_FILE"
        label="IPv6"
    fi

    last_ip=$(get_last_ip "$file")

    if [ -z "$current_ip" ]; then
        echo "❌ 无法获取公网${label}地址" >&2 | tee -a "$LOG"
        return
    fi

    echo "${label} 当前: $current_ip" | tee -a "$LOG"
    echo "${label} 上次: $last_ip" | tee -a "$LOG"

    if [ "$current_ip" = "$last_ip" ]; then
        echo "ℹ️ ${label} 未变化，跳过更新" | tee -a "$LOG"
    else
        echo "🔄 ${label} 已变化，开始更新..." | tee -a "$LOG"
        if update_duckdns "$current_ip"; then
            save_ip "$file" "$current_ip"
            echo "📌 已保存${label}: $current_ip" | tee -a "$LOG"
        fi
    fi
}

# 主流程
main() {
    [ "$DEBUG" = "true" ] && set -x

    echo "===== DuckDNS DDNS 更新启动 =====" | tee -a "$LOG"
    echo "域名: ${DUCKDNS_DOMAIN}.duckdns.org" | tee -a "$LOG"
    echo "更新类型: ${IP_TYPE}" | tee -a "$LOG"

    case "$IP_TYPE" in
        A)       update_ip A ;;
        AAAA)    update_ip AAAA ;;
        "A&AAAA")  update_ip A; update_ip AAAA ;;
        *)       echo "❌ 记录类型无效，应为 A / AAAA / A&AAAA" ;;
    esac

    echo "===== 更新完成 =====" | tee -a "$LOG"
}

main
