#!/bin/sh
## name: ydns IP更新 (支持IPv4/IPv6)
## cron: */5 * * * *

# [37-38]行和[40-41]行，根据自己的青龙版本把不要的注释掉即可

# 环境变量：YDNS_CONFIG
# 格式：域名|用户名|密码|IP类型
# 举例：
#   只更新IPv4：abc.ydns.eu|123456@qq.com|a123456|4
#   只更新IPv6：abc.ydns.eu|123456@qq.com|a123456|6
#   同时更新v4/v6：abc.ydns.eu|123456@qq.com|a123456|46

CONFIG="${YDNS_CONFIG:-}"

if [ -z "$CONFIG" ]; then
    echo "❌ 缺少环境变量 YDNS_CONFIG，格式应为：域名|用户名|密码|IP类型(4/6/46)"
    exit 1
fi

# 分割配置
YDNS_HOST=$(echo "$CONFIG" | cut -d '|' -f1)
YDNS_USER=$(echo "$CONFIG" | cut -d '|' -f2)
YDNS_PASS=$(echo "$CONFIG" | cut -d '|' -f3)
IP_TYPE=$(echo "$CONFIG" | cut -d '|' -f4)

if [ -z "$YDNS_HOST" ] || [ -z "$YDNS_USER" ] || [ -z "$YDNS_PASS" ] || [ -z "$IP_TYPE" ]; then
    echo "❌ YDNS_CONFIG 格式错误，应为：域名|用户名|密码|IP类型(4/6/46)"
    exit 1
fi

# API
IPV4_API="http://members.3322.org/dyndns/getip"
IPV6_API="https://api64.ipify.org"   # 获取IPv6

# 上次IP记录文件（青龙v2.12.2以下）
IPV4_FILE="/ql/scripts/hlt1995_qlScript/ydns_last_ipv4.txt"
IPV6_FILE="/ql/scripts/hlt1995_qlScript/ydns_last_ipv6.txt"
# 青龙v2.12.2及以上请改路径：
# IPV4_FILE="/ql/data/scripts/hlt1995_qlScript/ydns_last_ipv4.txt"
# IPV6_FILE="/ql/data/scripts/hlt1995_qlScript/ydns_last_ipv6.txt"

DEBUG="${DEBUG:-false}"
LOG="/dev/null"

get_ipv4() { curl -4 -s "$IPV4_API" 2>/dev/null; }
get_ipv6() { curl -6 -s "$IPV6_API" 2>/dev/null; }

get_last_ip() { [ -f "$1" ] && cat "$1" || echo ""; }
save_ip() { echo "$2" > "$1"; }

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

update_ip() {
    local type="$1"
    local current_ip last_ip file

    if [ "$type" = "4" ]; then
        current_ip=$(get_ipv4)
        file="$IPV4_FILE"
    else
        current_ip=$(get_ipv6)
        file="$IPV6_FILE"
    fi

    last_ip=$(get_last_ip "$file")

    if [ -z "$current_ip" ]; then
        echo "❌ 无法获取公网IPv${type}地址" >&2 | tee -a "$LOG"
        return
    fi

    echo "IPv${type} 当前: $current_ip" | tee -a "$LOG"
    echo "IPv${type} 上次: $last_ip" | tee -a "$LOG"

    if [ "$current_ip" = "$last_ip" ]; then
        echo "ℹ️ IPv${type} 未变化，跳过更新" | tee -a "$LOG"
    else
        echo "🔄 IPv${type} 已变化，开始更新..." | tee -a "$LOG"
        if update_ydns "$current_ip"; then
            save_ip "$file" "$current_ip"
            echo "📌 已保存IPv${type}: $current_ip" | tee -a "$LOG"
        fi
    fi
}

main() {
    [ "$DEBUG" = "true" ] && set -x

    echo "===== YDNS DDNS 更新启动 =====" | tee -a "$LOG"
    echo "域名: ${YDNS_HOST}" | tee -a "$LOG"
    echo "更新类型: IPv${IP_TYPE}" | tee -a "$LOG"

    case "$IP_TYPE" in
        4)  update_ip 4 ;;
        6)  update_ip 6 ;;
        46) update_ip 4; update_ip 6 ;;
        *)  echo "❌ IP类型无效，应为 4 / 6 / 46" ;;
    esac

    echo "===== 更新完成 =====" | tee -a "$LOG"
}

main
