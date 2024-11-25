---
title: Debian问题处理2
description: Debian问题处理2
categories: 
  - 问题
tags:
  - linux问题
date: 2023-08-17 23:49:36
updated: 2023-08-17 23:49:36
---

# 代理

Vmware里面的debian,连接外面物理机的v2ray。

## 对于浏览器

无论是firefox还是chromium，都可以直接通过v2ray允许局域网，然后使用ProxySwitchOmege代理访问

## 对于命令

可以使用proxychains，直接用apt-get 安装即可，注意事项

### 作用范围

对tcp生效，ping是不生效的，不要白费力气

### 需要修改两个地方

1. libproxychains.so.3 提示不存在  ly
   ```shell
   whereis libproxychains.so.3 
   #libproxychains.so.3: /usr/lib/x86_64-linux-gnu/libproxychains.so.3
   #修改/usr/bin/proxychains
   #export LD_PRELOAD = libproxychains.so.3 修改为：
   export LD_PRELOAD = /usr/lib/x86_64-linux-gnu/libproxychains.so.3
   ```

2. l'y配置修改
   ```shell
   #修改文件/etc/proxychains.conf，在最后一行添加
   socks5 	192.168.1.201 1082
   ```

3. 使用
   ```shell
   proxychains git pull
   #直接在命令最前面输入proxychains即可
   ```

## 直接网络（gui）配置代理

这个对于终端不生效

# zsh安装

```shell
proxychains wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
proxychains sh install.sh
```

## zsh主题安装

```shell
proxychains git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#修改
vim ~/.zshrc
ZSH_THEME="powerlevel10k/powerlevel10k"
```

重新配置 ```p10k configure```

# 程序环境设置

环境变量

```shell
#java环境变量
export JAVA_HOME=/usr/local/jdk1.8.0_281
export CLASSPATH=$:CLASSPATH:$JAVA_HOME/lib/
export PATH=$PATH:$JAVA_HOME/bin
#maven环境变量
export MAVEN_HOME=/usr/local/apache-maven-3.3.9
export PATH=$PATH:$MAVEN_HOME/bin 
```



# typora破解

声明：破解可耻，尊重正版。这里仅以学习为目的  

> 来自文章 https://ccalt.cn/2023/04/07/%5BWindows%7CLinux%5DTypora%E6%9C%80%E6%96%B0%E7%89%88%E9%80%9A%E7%94%A8%E7%A0%B4%E8%A7%A3-%E8%87%B3%E4%BB%8A%E5%8F%AF%E7%94%A8/

## 程序

> https://github.com/DiamondHunters/NodeInject_Hook_example/actions/runs/4180836116

我自己fork了一份，不知道哪天就没了  

> https://github.com/lwmfjc/NodeInject_Hook_example/actions/runs/5888943386

## 步骤

将linux版本的文件，按下面的结构解压放入Typora文件夹中  
这里盗（借）用文章图片说明，不想截图了  
![https://ccalt.cn/2023/04/07/%5BWindows%7CLinux%5DTypora%E6%9C%80%E6%96%B0%E7%89%88%E9%80%9A%E7%94%A8%E7%A0%B4%E8%A7%A3-%E8%87%B3%E4%BB%8A%E5%8F%AF%E7%94%A8/image-20230407102721694.png](images/mypost/2023/08/18/20230818000939.png)  
之后先运行node_inject，后运行**license-gen** ，即可得到序列号

# 字体

很多程序都偏小，系统字体基本正常。  
firefox中，要设置最小字体。 Typor没找到。

# picgo问题

没有什么特别注意的，基本问题搜索引擎都有。对了，把windows下的picgo卸载了，只留下了picgo-core，还安装了 super-prefix，自定义上传路径及文件名

> 参考文章 https://connor-sun.github.io/posts/38835.html 

```shell
#自定义文件夹及文件名
picgo install super-prefix
#super-prefix地址 https://github.com/gclove/picgo-plugin-super-prefix 


```

picgo-core 配置手册 https://picgo.github.io/PicGo-Core-Doc/zh/guide/config.html

```shell

#插件配置 ~/.picgo/config.json ,在根结构里面添加
  "picgoPlugins": {
    "picgo-plugin-super-prefix": true
  },
  "picgo-plugin-super-prefix": {
    "prefixFormat": "YYYY/MM/DD/",
    "fileFormat": "YYYYMMDD-HHmmss"
  }
```

## Typora中文件上传对picgo-core的设置

自定义命令格式：```picgo upload```，windows中可以使用绝对路径(加双引号)

# 截图工具

```apt install flameshot ```  
使用```flameshot  gui``` 启动