---
title: Debian问题处理1
description: Debian问题处理1
categories: 
  - 问题
tags:
  - linux问题
date: 2023-08-15 09:05:57
updated: 2023-08-15 09:05:57

---

# 清华源设置

```shell
vim /etc/apt/sources.list
#注释掉原来的，并添加
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
```

# 中文环境

```shell
su
sudo apt-get install locales
#配置中文环境 1.选择zh开头的 2 后面选择en(cn也行，不影响输入法)
sudo dpkg-reconfigure locales
#设置上海时区
sudo timedatectl set-timezone Asia/Shanghai
```

# 中文输入法

```shell
#清除旧的环境
apt-get remove ibus #不兼容问题
apt-get remove fcitx5 fcitx5-chinese-addons 
apt-get autoremove 
ly # gnome-shell-extension-kimpanel
sudo apt install fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2  fcitx5-frontend-qt5 
im-config #配置使用fcitx5 
```

```shell
#环境变量添加
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
#退出root用户权限，使用普通用户权限再终端
fcitx5-configtool #配置中文输入法即可
#附加组件-经典用户界面--这里可以修改字体及大小
```

# 其他

应用程序-优化   修改默认字体大小

桌面任务栏-- https://extensions.gnome.org/extension/1160/dash-to-panel

> 参考文章 https://itsfoss.com/gnome-shell-extensions/   
> 之后设置一下任务栏的位置即可

# 参考文章

https://zhuanlan.zhihu.com/p/508797663 