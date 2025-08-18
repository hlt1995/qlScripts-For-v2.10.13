### 安装依赖

第一步、Alpine下执行`npm install -g npm@6` 安装完成后Zerotermux退出后台重新打开

第二步、打开科学上网，进入Alpine安装依赖
```
npm install axios moment ds jsdom sharp@0.32.0 --prefix /ql

```

第三步、安装完成后恢复mpn版本，在Alpine下执行
```
rm -f /usr/local/bin/npm
rm -f /usr/local/bin/npx

```

---

### 定期重启

第一步、手机设定定时开关机，每周六 关机`3：31` - 开机`3：36`

第二步、通过MacroDroid设置开机启动ZeroTermux

第三步、Alpine下执行`nano ~/.profile`,在文件中添加

```
cd ~

# 判断青龙面板是否已经启动 
if ! pm2 list | grep -qE 'panel|schedule'; then
  ./ql.sh
fi
```

---

### 面板配置

第一步、拉qlScript库

第二步、配置文件关闭`自动删除失效的脚本与定时任务`和`自动增加新的本地定时任务`

第三步、拉jdpro库，完整拉一次

第四步、打开自动增加新的本地定时任务,用推荐拉库指令再拉一次jdpro

第五步、新建脚本`新农场幸运转盘_2`、`jd_CheckCK1.js`、`jd_bean_change1.js`

---

### 通过IPv6地址进行青龙面板外网访问

在Alpine下执行`nano /etc/nginx/conf.d/front.conf`找到

```
server {
  listen 5700;
  root /ql/dist;
  ssl_session_timeout 5m;
```
在`listen 5700;`下增加一行`listen [::]:5700;`

修改后

```
server {
  listen 5700;
  listen [::]:5700;
  root /ql/dist;
  ssl_session_timeout 5m;
```

按Ctrl+O再按Enter保存文件，按Ctrl+X退出

检查配置是否正确：
```
nginx -t
```
如果提示 `syntax is ok`，继续下一步

重新加载 Nginx：
```
nginx -s reload
```

在浏览器里输入 [IPv6地址]:5700 或者 你的动态域名:5700 即可外网访问青龙面板

### 这里注意，IPv6访问青龙面板的前提是访问设备也需要获取IPv6地址！

由于每次重启青龙面板都要执行ql.sh，其中的`cp -fv $nginx_app_conf /etc/nginx/conf.d/front.conf`会把默认文件覆盖我们修改的`front.conf`

所以需要注释掉这行，在Alpine下执行`nano ql.sh`

找到一下内容

```
echo -e "======================1. 检测配置文件======================\n"
make_dir /etc/nginx/conf.d
make_dir /run/nginx
cp -fv $nginx_conf /etc/nginx/nginx.conf
cp -fv $nginx_app_conf /etc/nginx/conf.d/front.conf
pm2 l &>/dev/null
echo
```
修改为

```
echo -e "======================1. 检测配置文件======================\n"
make_dir /etc/nginx/conf.d
make_dir /run/nginx
cp -fv $nginx_conf /etc/nginx/nginx.conf
#cp -fv $nginx_app_conf /etc/nginx/conf.d/front.conf
pm2 l &>/dev/null
echo
```

按Ctrl+O再按Enter保存文件，按Ctrl+X退出

这样每次重启青龙面板执行ql.sh后，依然能够让青龙面板保持监听IPv6地址，从而行进外网远程访问

---
