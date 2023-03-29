---
title: "vmware上linux主机的安装和克隆"
date: 2023-03-29 17:23:19 
draft: false
description: vmware上linux主机的安装和克隆
updated: 2023-03-29 17:23:19 
categories:
 - "学习"
tags: 
 - "linux_其他"
---

# 安装

## 虚拟机向导

1. 典型---稍后安装--linux--RedhatEnterpriseLinux7 64
2. 虚拟机名称rheCentos700
3. 接下来都默认即可(20G硬盘，2G内存，网络适配器(桥接模式))

## 安装界面

1. 日期--亚洲上海，键盘--汉语，语言支持--简体中文(中国)

2. 软件安装  
   最小安装---> 兼容性程序库+开发工具

3. 其他存储选项--配置分区  

   > 1. /boot 1G 标准分区，文件系统ext4
   > 2. swap 2G 标准分区 ，文件系统swap
   > 3. /  17G 标准分区，文件系统ext4

4. 网络和主机名  
   打开网络+设置主机名(rheCentos700)

5. 完成---过程中配置密码 默认用户root+其他用户ly

## 安装完成后修改ip及网关

1. ```vi /etc/sysconfig/network-scripts/ifcfg-ens**```

2. 修改部分键值对  

   ```shell
   BOOTPROTO="static"
   IPADDR=192.168.1.100
   NETMASK=255.255.255.0
   GATEWAY=192.168.1.1
   DNS1=223.5.5.5
   DNS2=223.6.6.6
   ```

3. ```systemctl restart network```

# 克隆虚拟机

1. 右键--管理--克隆--创建完整克隆

2. 修改MAC、主机名、ip、uuid

   1. 右键--设置--网络适配器--高级--MAC地址->生成

   2. ```vi /etc/hostname```修改主机名  

      > reboot 

   3. ```vi /etc/sysconfig/network-scripts/ifcfg-ens**```修改ip及uuid  

      > uuid自动生成

# 常用操作

1. 常用命令安装  

   > 1. ```yum install -y wget```

2. yum阿里云源切换  

   > 1. 备份```mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak ```
   > 2. 下载并切换```wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo ```
   > 3. 清理```yum clean all ```
   > 4. 缓存处理```yum makecache ```

