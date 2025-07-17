### 安装依赖

目前的青龙面板部署方式，如果在面板中安装依赖，那么在重启青龙面板后，大概率会出现重装依赖的问题

所以我推荐在Alpine下安装依赖，以下是执行步骤：

第一步、Alpine下执行`which npm`，记下npm安装位置。

第二步、执行`npm install -g npm@6`，安装npm6

第三步、安装依赖
```
cd /ql
npm install axios moment ds jsdom sharp@0.32.0
```
（第一、二步目的是为了安装sharp依赖，npm版本是8.6.0，安装sharp时可能会出现安装失败，降级npm到6后可以成功安装。）

第四步、安装完成后在Alpine下执行`which npm`，此时如果位置和第一步记下的位置不同，则执行
```
rm -f /usr/local/bin/npm
rm -f /usr/local/bin/npx
```
如果位置和第一步记下的位置相同，则执行`npm install -g npm@版本号`

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
