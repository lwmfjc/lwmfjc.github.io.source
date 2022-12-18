---
title: 类文件结构
description: 类文件结构
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-18 08:24:36
updated: 2022-12-18 09:03:36
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 概述

- Java中，JVM可以理解的代码就叫做**字节码**（即扩展名为.class的文件），它不面向任何特定的处理器，只**面向虚拟机**
- Java语言通过**字节码**的方式，在一定程度上解决了**传统解释型语言执行效率低**的问题，同时又保留了**解释型语言**可移植的特点。所以Java程序运行时**效率极高**，且由于字节码并不针对一种特定的**机器**。因此，Java程序无需重新编译便可在**多种不通操作系统的计算机**运行
- Clojure（Lisp 语言的一种方言）、Groovy、Scala 等语言都是运行在 Java 虚拟机之上。下图展示了**不同的语言被不同的编译器**编译**成`.class`**文件**最终运行在 Java 虚拟机**之上。**`.class`文件的二进制格式**可以使用 [WinHexopen in new window](https://www.x-ways.net/winhex/) 查看。

![image-20221218224536987](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221218224536987.png)

.class文件是不同语言在**Java虚拟机**之间的重要桥梁，同时也是**支持Java跨平台**很重要的一个原因

# Class文件结构总结

根据Java虚拟机规范，Class文件通过**ClassFile**定义，有点类似C语言的**结构体**

ClassFile的结构如下：  

```java
ClassFile {
    u4             magic; //Class 文件的标志
    u2             minor_version;//Class 的小版本号
    u2             major_version;//Class 的大版本号
    u2             constant_pool_count;//常量池的数量
    cp_info        constant_pool[constant_pool_count-1];//常量池
    u2             access_flags;//Class 的访问标记
    u2             this_class;//当前类
    u2             super_class;//父类
    u2             interfaces_count;//接口
    u2             interfaces[interfaces_count];//一个类可以实现多个接口
    u2             fields_count;//Class 文件的字段属性
    field_info     fields[fields_count];//一个类可以有多个字段
    u2             methods_count;//Class 文件的方法数量
    method_info    methods[methods_count];//一个类可以有个多个方法
    u2             attributes_count;//此类的属性表中的属性数
    attribute_info attributes[attributes_count];//属性表集合
} 
```

![image-20221218230117020](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221218230117020.png)

## 魔数（Magic Number）

## Class文件版本号（Minor&Major Version）

## 常量池（Constant Pool）

## 访问标志（Access Flag）

## 当前类（This Class）、父类（Super Class）、接口（Interfaces）索引集合

## 字段表集合 （Fields）

## 方法表集合（Methods）

## 属性表集合（Attributes）