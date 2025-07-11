如果遇到sharp依赖安装失败，可尝试以下方法：

第一步、alpine下执行which npm，记下npm安装位置。

第二步、执行npm -v,记下版本。如果版本在7以上则执行npm install -g npm@6，安装npm6

第三步、回到青龙面板依赖管理，安装sharp依赖。

第四步、成功后在alpine下执行which npm，此时如果位置和第一步记下的位置不同，则执行

rm -f /usr/local/bin/npm
rm -f /usr/local/bin/npx

如果位置和第一步记下的位置相同，则执行npm install -g npm@版本号

---

定期重启

1.手机设定定时开关机，每周六3：31关机 - 3：36开机
2.设置开机启动ZeroTermux，使用
