自动更新YDNS、DuckDNS动态域名服务的IP地址

YDNS：https://ydns.io

DuckDNS：https://www.duckdns.org

脚本需要在txt中记录上次更新成功的IP地址，以判断是否发送更新请求。txt默认路径为/ql/scripts/hlt1995_qlScript/，不同版本的青龙面板请注意脚本文件路径

拉取的文件后缀名：sh txt

环境变量直接在脚本里配置

#

Clean_log.sh：清理超过10天的任务日志


backupQL.js：备份青龙面板

    1. /ql/db  环境变量、定时任务、通知配置
    2. /ql/config/  面板登录信息与设置
    3. /ql/scripts/  脚本文件

拉库指令：ql repo https://github.com/hlt1995/qlScript.git "backupQL.sh|Clean_log.sh"

##

restoreQL.sh：恢复青龙面板  ## 在Alpine终端手动运行 ##


jb_bean_change.js：京东资产统计 ## 去除多余信息 ##


jd_CheckCK.js：京东账号CK检测  ## 去除多余信息 ##

