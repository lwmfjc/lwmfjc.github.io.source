---
title: Java序列化详解
description: Java序列化详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 10:39:01
updated: 2022-10-10 10:39:01
---

## 什么是序列化？什么是反序列化

当需要持久化Java对象，比如将Java对象保存在文件中、或者在网络中传输Java对象，这些场景都需要用到序列化

即：  

- 序列化：将数据结构/对象，转换成二进制字节流
- 反序列化：将在序列化过程中所生成的二进制字节流的过程，转换成数据结构或者对象的过程

对于Java，序列化的是对象(Object)，也就是实例化后的类(Class)

序列化的目的，是通过网络传输对象，或者说是将对象存储到文件系统、数据库、内存中，如图：
![image-20221010105218691](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221010105218691.png)

