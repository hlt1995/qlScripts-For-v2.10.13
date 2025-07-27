## 🔗 拉库地址

```plaintext
ql repo https://github.com/hlt1995/qlScript.git "" "restoreQL|jd_|ql"
```
> 脚本基于Android手机+ZeroTermux+Alpine部署青龙面板v2.10.13运行[部署教程参考](https://blog.csdn.net/SXIAOtian/article/details/124820799)，不同版本需要确认青龙文件路径
---

## 🚀 自动更新YDNS、DuckDNS动态域名服务的IP地址

YDNS：https://ydns.io

DuckDNS：https://www.duckdns.org

*_last_ip.txt用于保存上一次成功更新的IP地址，以判断是否发送更新请求。

拉取的文件后缀名：`js sh txt`

环境变量：`YDNS_CONFIG` `DUCKDNS_CONFIG`

---

## 🐲 青龙面板维护

Clean_log.sh：脚本内可修改日志保留天数，默认为10天

backupQL.js：备份内容如下

            1. /ql/db  环境变量、定时任务、通知配置
            2. /ql/config/  面板登录信息与设置
            3. /ql/scripts/  脚本文件
     
restoreQL.sh：复制代码在青龙容器内手动运行

---

## 🎮️ Epic免费游戏领取提醒

只写了bark推送，bark_Key直接读取配置文件config.sh中的`export BARK_PUSH=""`

点击bark通知即可跳转领取页面

---

## 🗃️ 存档

jd_bean_change.js

jd_CheckCK.js

ql.sh
