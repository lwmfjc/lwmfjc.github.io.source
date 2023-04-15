---
title: "一些基本操作"
date: 2023-04-05 17:23:19 
draft: false
description: 一些基本操作
updated: 2023-04-05 17:23:19 
categories:
 - "学习"
tags: 
 - "linux_其他"

---



# yum源替换成阿里云

```shell
yum install -y wget
## 备份
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
## 下载
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
## 重建缓存
yum clean all
yum makecache
```

# Java环境搭建

```shell
yum search java | grep jdk
yum install -y java-1.8.0-openjdk-devel.x86_64
# java -version 正常
# javac -version 正常
```

# 解压相关

-zxvf 

```shell
tar -zxvf redis* -C /usr/local/redis*
# z ：表示 tar 包是被 gzip 压缩过的 (后缀是.tar.gz)，所以解压时需要用 gunzip 解压 (.tar不需要)
# x ：表示 从 tar 包中把文件提取出来
# v ：表示 显示打包过程详细信息
# f ：指定被处理的文件是什么
# 适用于参数分开使用的情况，连续无分隔参数不应该再使用（所以上面的命令不标准），
# 应该是 tar zxvf redis* -C /usr/local/redis*
```

# 主题修改

oh my zsh

## 在线

| Method    | Command                                                      |
| --------- | ------------------------------------------------------------ |
| **curl**  | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |
| **wget**  | `sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |
| **fetch** | `sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |

## 手动安装

```shell
yum install -y zsh #一定要先装
sh -c "$(wget https://gitee.com/liu_yi_er/ohmyzsh/raw/master/tools/install.sh -O -)" #自己的gitee目录，从官网下载
sh install.sh
```

## 修改主题

//该主题样式如下

![image-20230414123619385](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414123619385.png)

```shell
$ vi ~/.zshrc

# 找到这一行，修改为自己喜欢的主题名称
# ZSH_THEME="ys"
ZSH_THEME="avit"
# 修改保存后，使配置生效
$ source ~/.zshrc
```

zsh home和end失效，可以改用ctrl+a / ctrl+e 代替

# Vim的使用快捷使用

```shell
# 清空文件--命令模式下输入 :%d  回车
# 处理粘贴时多出的行带#的问题-- 命令模式下输入 :set paste  再输入i进行粘贴
#快速修改-- 命令模式下输入  :%s/6379/6380/g （将文件中所有6379替换成6380）
```

# 基本网络工具安装

```shell
yum install -y net-tools
```

查看端口监听情况

```shell
netstat -lntup | grep redis
```

解释  

> -a (all)显示所有选项，默认不显示LISTEN相关
> -t (tcp)仅显示tcp相关选项
> -u (udp)仅显示udp相关选项
> -n 拒绝显示别名，能显示数字的全部转化成数字。
> -l 仅列出有在 Listen (监听) 的服務状态
>
> -p 显示建立相关链接的程序名
> -r 显示路由信息，路由表
> -e 显示扩展信息，例如uid等
> -s 按各个协议进行统计
> -c 每隔一个固定时间，执行该netstat命令。
>
> 提示：LISTEN和LISTENING的状态只有用-a或者-l才能看到

# ps命令

ps -ef //-e表示全部进程 ，-f表示全部的列

# 树形结构查看文件夹

```yum install -y tree```

# 快捷键

ctrl+w 快速删除光标前的整个单词

ctrl+a 光标移到行首 [xshell]

ctrl+e 光标移到行尾 [xshell]

# 创建多级目录

```mkdir -p /usr/local/redis_cluster/redis_63{79,80}/{conf,pid,logs}```