---
title: 类加载器详解
description: 类加载器详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-17 22:39:21
updated: 2022-12-17 22:39:21
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 回顾一下类加载过程

- 类加载过程：**加载**->**连接**->**初始化**，连接又分为**验证** - > **准备** -> **解析**
  ![image-20221217225702126](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221217225702126.png)
- 一个**非数组类的加载阶段**（加载阶段**获取类的二进制字节流**的动作）是可控性最强的阶段，这一步我们可以去**自定义类加载器**去**控制字节流的获取方式**（**重写一个类加载器的 `loadClass()` 方法**）
- **数组类型不通过类加载器创建**，它**由 Java 虚拟机直接创建**。
- 所有的类都**由类加载器**加载，加载的作用就是将 **`.class`文件加载到内存**。

# 类加载器总结

JVM 中内置了**三个重要的 ClassLoader**，除了 **BootstrapClassLoader** ，**其他类加载器均由 Java 实现**且全部**继承自`java.lang.ClassLoader`**：

1. **BootstrapClassLoader(启动类加载器)** ：最顶层的加载类，由 C++实现，负责加载 **`%JAVA_HOME%/lib`**目录下的 jar 包和类或者被 **`-Xbootclasspath`**参数指定的路径中的所有类。
2. **ExtensionClassLoader(扩展类加载器)** ：主要负责加载 **`%JRE_HOME%/lib/ext`** 目录下的 jar 包和类，或被 **`java.ext.dirs` 系统变量**所指定的路径下的 jar 包
3. **AppClassLoader(应用程序类加载器)** ：面向我们用户的加载器，负责加载**当前应用 classpath** 下的**所有 jar 包和类**。

#  双亲委派模型

## 双亲委派模型介绍

## 双亲委派模型实现源码分析

## 双亲委派模型的好处

## 如果我们不想用双清委派模型

# 自定义类加载器

# 推荐阅读