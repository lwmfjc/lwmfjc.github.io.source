---
title: Atomic原子类介绍
description: Atomic原子类介绍
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-12-05 09:24:36
updated: 2022-12-05 09:24:36
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者! 

# 原子类介绍

- 在化学上，原子是构成一般物质的最小单位，化学反应中是不可分割的，Atomic指**一个操作是不可中断的**，即使在多个线程一起执行时，一个操作一旦开始就**不会被其他线程干扰**
- 原子类-->具有原子/原子操作特征的类
- 并发包java.util.concurrent 的原子类都放着```java.util.concurrent.atomic```中
  ![image-20221205094229003](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221205094229003.png)
- 根据操作的数据类型，可以将JUC包中的原子类分为4类（基本类型、数组类型、引用类型、对象的属性修改类型）
  - 基本类型 
    使用原子方式更新基本类型，包括AtomicInteger 整型原子类，AtomicLong 长整型原子类，AtomicBoolean 布尔型原子类
  - 数组类型
    使用原子方式更新数组里某个元素，包括AtomicIntegerArray 整型数组原子类，AtomicLongArray 长整型数组原子类，AtomicReferenceArray：引用类型数组原子类
  - 引用类型
    AtomicReference 引用类型原子类，AtomicMarkableReference 原子更新带**有标记**的引用类型，该类将boolean标记与引用关联（**不可解决CAS进行原子操作出现的ABA问题**），AtomicStampedReference 原子更新带有版本号的引用类型 该类将整数值与引用关联，可用于解决原子更新**数据和数据的版本号(解决使用CAS进行原子更新时可能出现的ABA问题)**
  - 对象的属性修改类型
    AtomicIntegerFieldUpdater 原子更新整型字段的更新器，AtomicLongFieldUpdater 原子更新长整型字段的更新器，
    AtomicReferenceFieldUpdater 原子更新引用类型里的字段

# 基本类型原子类

# 数组类型原子类

# 引用类型原子类

# 对象的属性修改类型原子类