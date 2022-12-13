---
title: java垃圾回收器
description: java垃圾回收器
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-12 15:58:48
updated: 2022-12-12 15:58:48
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 前言

当**需要排查各种内存溢出问题**、当**垃圾收集**成为系统达到更高并发的瓶颈时，我们就需要对这些**“自动化”**的技术实施必要的**监控**和**调节**

# 堆空间的基本结构

- Java的**自动内存管理**主要是针对对象内存的**回收**和对象内存的**分配**。且Java自动内存管理最核心的功能是**堆**内存中的对象**分配**和**回收**

- Java堆是垃圾收集器管理的主要区域，因此也被称作**GC堆（Garbage Collected Heap）**
- 从**垃圾回收的角度**来说，由于现在收集器基本都采用**分代垃圾收集算法**，所以Java堆被划分为了几个不同的区域，这样我们就可以**根据各个区域的特点**选择**合适的垃圾收集算法**
- JDK7版本及JDK7版本之前，堆内存被通常分为下面三部分：
  1. 新生代内存（Young Generation）
  2. 老生代（Old Generation）
  3. 永久代（Permanent Generation）

![hotspot-heap-structure](https://javaguide.cn/assets/hotspot-heap-structure.41533631.png)

JDK8版本之后PermGen（永久）已被Metaspace（元空间）取代，且已经不在堆里面了，元空间使用的是**直接内存**。

# 内存分配和回收原则

## 对象优先在Eden区分配

- 多数情况下，对象在**新生代中Eden区**分配。当Eden区没有足够空间进行分配时，会触发一次MinorGC
  首先，先添加一下参数打印GC详情：```-XX:+PrintGCDetails```

  ```java
  public class GCTest {
  	public static void main(String[] args) {
  		byte[] allocation1, allocation2;
  		allocation1 = new byte[30900*1024];//会用掉3万多K
  	}
  } 
  ```

  运行后的结果（这里应该是配过xms和xmx了，即堆内存大小）
  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/28954286.jpg)
  如上，**Eden区内存几乎被分配完全**（即使程序什么都不做，新生代也会使用2000多K）

  > 注： PSYoungGen 为 38400K ，= 33280K + 5120K （Survivor区总会有一个是空的，所以只加了一个5120K ）

  假如我们再为allocation2分配内存会怎么样(不处理的话，年轻代会溢出)

  ```java
  allocation2 = new byte[900 * 1024];
  ```

  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/28128785.jpg)

  

  

## 大对象直接进入老年代

## 长期存活的对象进入老年代

## 主要进行gc的区域

## 空间分配担保

# 死亡对象判断方法

## 引用计数法

## 可达性分析算法

## 引用类型总结

## 如何判断一个常量是废弃常量

## 如何判断一个类是无用类

# 垃圾收集算法

## 标记-清除算法

## 标记-复制算法

## 标记-整理算法

## 分代收集算法

# 垃圾收集器