---
title: jvm参数
description: jvm参数
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-19 15:24:01
updated: 2022-12-19 15:24:01
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

> 本文由 JavaGuide 翻译自 [https://www.baeldung.com/jvm-parametersopen in new window](https://www.baeldung.com/jvm-parameters)，并对文章进行了大量的完善补充。翻译不易，如需转载请注明出处，作者：[baeldungopen in new window](https://www.baeldung.com/author/baeldung/) 。

# 概述

本篇文章中，将掌握最常用的**JVM参数配置**。下面提到了一些概念，**堆**、**方法区**、**垃圾回收**等。

# 堆内存相关

Java 虚拟机所管理的**内存中最大的一块**，**Java 堆**是**所有线程共享的一块内存区域**，在虚拟机**启动时创建**。此内存区域的**唯一目的就是存放对象实例**，**几乎** **所有的对象实例**以及**数组**都在这里分配内存。

## 显式指定堆内存-Xms和-Xmx

- 与**性能相关**的最常见实践之一是根据应用程序要求**初始化堆内存**。

- 如果我们需要指定**最小**和**最大堆**大小（推荐显示指定大小）：  

  ```shell
  -Xms<heap size>[unit] 
  -Xmx<heap size>[unit]
  ```

  - **heap size** 表示要初始化内存的具体大小。
  - **unit** 表示要初始化内存的单位。单位为***“ g”*** (GB) 、***“ m”***（MB）、***“ k”***（KB）。

- 举例，为JVM分配最小2GB和最大5GB的堆内存大小

  ```shell
  -Xms2G -Xmx5G
  ```

## 显示新生代内存（Young Generation）

- 在堆总可用内存配置完成之后，第二大影响因素是为 **`Young Generation`** 在堆内存所占的比例。默认情况下，**YG 的最小大小为 1310 *MB***，最大大小为*无限制*。

- 两种指定 **新生代内存(Young Generation)** 大小的方法  

  1. 通过 ```-XX:NewSize``` 和 ```-XX:MaxNewSize ```

     ```java
     -XX:NewSize=<young size>[unit] 
     -XX:MaxNewSize=<young size>[unit]
     ```

     如，为新生代分配**最小256m**的内存，**最大1024m**的内存我们的参数为：  

     ```java
     -XX:NewSize=256m
     -XX:MaxNewSize=1024m
     ```

  2. 通过`-Xmn<young size>[unit] `指定
     举例，为新生代分配256m的内存（NewSize与MaxNewSize设为一致）
     ```-Xmn256m ```

     > 将新对象预留在新生代，由于 **Full GC 的成本远高于 Minor GC**，因此尽可能**将对象分配在新生代**是明智的做法，实际项目中**根据 GC 日志分析新生代空间大小分配是否合理**，适当通过“-Xmn”命令调节新生代大小，**最大限度降低新对象直接进入老年代**的情况。

     另外，你还可以通过 **`-XX:NewRatio=<int>`** 来设置老年代与新生代内存的比值。

     > 下面的参数，设置**老年代**与**新生代**内存的比例为1，即 老年代：新生代 = 1：1，新生代占整个堆栈的1/2
     > ```-XX:NewRadio=1```

## 显示指定永久代/元空间的大小



# 垃圾收集相关

## 垃圾回收器

## GC记录