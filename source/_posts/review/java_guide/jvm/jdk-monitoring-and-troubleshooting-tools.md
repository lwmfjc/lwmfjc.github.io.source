---
title: jvm监控和故障处理工具 总结
description: jvm监控和故障处理工具 总结
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-19 16:04:34
updated: 2022-12-19 17:04:34
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# JDK命令行工具

这些命令在JDK安装目录下的bin目录下：  

- **`jps`** (JVM Process Status）: 类似 UNIX 的 `ps` 命令。用于查看所有 Java 进程的启动类、传入参数和 Java 虚拟机参数等信息；
- **`jstat`**（JVM Statistics Monitoring Tool）: 用于收集 HotSpot 虚拟机各方面的运行数据;
- **`jinfo`** (Configuration Info for Java) : Configuration Info for Java,显示虚拟机配置信息;
- **`jmap`** (Memory Map for Java) : 生成堆转储快照;
- **`jhat`** (JVM Heap Dump Browser) : 用于分析 heapdump 文件，它会建立一个 HTTP/HTML 服务器，让用户可以在浏览器上查看分析结果;
- **`jstack`** (Stack Trace for Java) : 生成虚拟机当前时刻的线程快照，线程快照就是当前虚拟机内每一条线程正在执行的方法堆栈的集合。

## jps：查看所有Java进程



## jstat：监视虚拟机各种运行状态信息

## jinfo：实时地查看和调整虚拟机各项参数

## jmap：生成堆转储快照

## jhat：分析heapdump文件

## jstack： 生成虚拟机当前时刻的线程快照

# JDK可视化分析工具

## JConsole：Java监视与管理控制台

## VisualVM： 多合一故障处理工具