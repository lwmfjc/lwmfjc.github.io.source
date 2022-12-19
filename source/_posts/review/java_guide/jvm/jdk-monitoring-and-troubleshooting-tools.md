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

- jps（**JVM Process Status**）命令类似于UNIX的**ps**命令
- jps：显示**虚拟机执行主类名称**以及**这些进程的本地虚拟机唯一ID （Local Virtual Machine Identifier，LVMID)**。`jps -q` ：只输出进程的本地虚拟机**唯一 ID**

```shell
C:\Users\SnailClimb>jps
7360 NettyClient2
17396
7972 Launcher
16504 Jps
17340 NettyServer
```

- 面试准备
- Java
  - 基础
    - Java基础常见面试题总结(上)
    - Java基础常见面试题总结(中)
    - Java基础常见面试题总结(下)
    - 重要知识点
  - 集合
    - Java集合常见面试题总结(上)
    - Java集合常见面试题总结(下)
    - Java集合使用注意事项总结
    - 源码分析
  - IO
    - Java IO基础知识总结
    - Java IO设计模式总结
    - Java IO模型详解
  - 并发编程
    - Java 并发常见面试题总结（上）
    - Java 并发常见面试题总结（中）
    - Java 并发常见面试题总结（下）
    - 重要知识点
  - JVM
    - Java 内存区域详解
    - JVM 垃圾回收详解
    - 类文件结构详解
    - 类加载过程详解
    - 类加载器详解
    - 最重要的 JVM 参数总结
    - 大白话带你认识JVM
    - JDK 监控和故障处理工具总结
      - JDK 命令行工具
        - jps:查看所有 Java 进程
        - jstat: 监视虚拟机各种运行状态信息
        - jinfo: 实时地查看和调整虚拟机各项参数
        - jmap:生成堆转储快照
        - jhat: 分析 heapdump 文件
        - jstack :生成虚拟机当前时刻的线程快照
      - JDK 可视化分析工具
        - JConsole:Java 监视与管理控制台
        - Visual VM:多合一故障处理工具
  - 新特性
- 计算机基础
- 数据库
- 开发工具
- 常用框架
- 系统设计
- 分布式
- 高性能
- 高可用

[Java 面试指南]()[JDK 监控和故障处理工具总结]()

# JDK 监控和故障处理工具总结

[Guide](https://javaguide.cn/article/)JavaJVM2021年11月9日约 2985 字大约 10 分钟

------

此页内容

- [JDK 命令行工具]()

- - [jps:查看所有 Java 进程]()
  - [jstat: 监视虚拟机各种运行状态信息]()
  - [jinfo: 实时地查看和调整虚拟机各项参数]()
  - [jmap:生成堆转储快照]()
  - [jhat: 分析 heapdump 文件]()
  - [jstack :生成虚拟机当前时刻的线程快照]()

- [JDK 可视化分析工具]()

- - [JConsole:Java 监视与管理控制台]()
  - [Visual VM:多合一故障处理工具]()

# [#](#jdk-监控和故障处理工具总结) JDK 监控和故障处理工具总结

## [#](#jdk-命令行工具) JDK 命令行工具

这些命令在 JDK 安装目录下的 bin 目录下：

- **`jps`** (JVM Process Status）: 类似 UNIX 的 `ps` 命令。用于查看所有 Java 进程的启动类、传入参数和 Java 虚拟机参数等信息；
- **`jstat`**（JVM Statistics Monitoring Tool）: 用于收集 HotSpot 虚拟机各方面的运行数据;
- **`jinfo`** (Configuration Info for Java) : Configuration Info for Java,显示虚拟机配置信息;
- **`jmap`** (Memory Map for Java) : 生成堆转储快照;
- **`jhat`** (JVM Heap Dump Browser) : 用于分析 heapdump 文件，它会建立一个 HTTP/HTML 服务器，让用户可以在浏览器上查看分析结果;
- **`jstack`** (Stack Trace for Java) : 生成虚拟机当前时刻的线程快照，线程快照就是当前虚拟机内每一条线程正在执行的方法堆栈的集合。

### [#](#jps-查看所有-java-进程) `jps`:查看所有 Java 进程

`jps`(JVM Process Status) 命令类似 UNIX 的 `ps` 命令。

`jps`：显示虚拟机执行主类名称以及这些进程的本地虚拟机唯一 ID（Local Virtual Machine Identifier,LVMID）。`jps -q` ：只输出进程的本地虚拟机唯一 ID。



```powershell
C:\Users\SnailClimb>jps
7360 NettyClient2
17396
7972 Launcher
16504 Jps
17340 NettyServer
```

`jps -l`:输出主类的全名，如果进程执行的是 Jar 包，输出 Jar 路径。

```shell
C:\Users\SnailClimb>jps -l
7360 firstNettyDemo.NettyClient2
17396
7972 org.jetbrains.jps.cmdline.Launcher
16492 sun.tools.jps.Jps
17340 firstNettyDemo.NettyServer
```

`jps -v`：输出虚拟机进程启动时 JVM 参数。

`jps -m`：输出传递给 Java 进程 main() 函数的参数。

## jstat：监视虚拟机各种运行状态信息



## jinfo：实时地查看和调整虚拟机各项参数

## jmap：生成堆转储快照

## jhat：分析heapdump文件

## jstack： 生成虚拟机当前时刻的线程快照

# JDK可视化分析工具

## JConsole：Java监视与管理控制台

## VisualVM： 多合一故障处理工具