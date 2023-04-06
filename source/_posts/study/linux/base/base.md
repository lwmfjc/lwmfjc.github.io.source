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



## yum源替换成阿里云

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

## Java环境搭建

```shell
yum search java | grep jdk
yum install -y java-1.8.0-openjdk-devel.x86_64
# java -version 正常
# javac -version 正常
```

