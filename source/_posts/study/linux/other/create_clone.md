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

### Centos

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

### Debian

1. 查看当前网卡
   ```shell
   ip link
   #1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
   #    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
   #2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
   #    link/ether 00:0c:29:ed:95:f5 brd ff:ff:ff:ff:ff:ff
   #    altname enp2s1
   ```

   得知网卡名为ens33

2. ```vim /etc/network/interfaces```
   添加内容，为网卡（ens33）设置静态ip

   ```shell
   #ly-update
   auto ens33
   iface ens33 inet static
   address 192.168.1.206
   netmask 255.255.255.0
   gateway 192.168.1.1
   dns-nameservers 223.5.5.5 223.6.6.6
   ```

3. 重启网络  
   ```shell
   sudo service networking restart
   ```

4. 查看ip
   ```shell
   ip a
   #---------------------结果显示
   1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
       link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
       inet 127.0.0.1/8 scope host lo
          valid_lft forever preferred_lft forever
       inet6 ::1/128 scope host noprefixroute 
          valid_lft forever preferred_lft forever
   2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether 00:0c:xx:xx:23:f5 brd ff:ff:ff:ff:ff:ff
       altname enp2s1
       inet 192.168.1.206/24 brd 192.168.1.255 scope global ens33
          valid_lft forever preferred_lft forever
       inet6 xxxx::20c:29ff:feed:xxxx/64 scope link 
          valid_lft forever preferred_lft forever
   ```

   

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

