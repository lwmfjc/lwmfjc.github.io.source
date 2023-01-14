---
title: 日志
description: 日志
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-database
date: 2023-01-14 17:31:53
updated: 2023-01-14 17:31:53
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 前言

- `MySQL` 日志 主要包括**错误日志**、**查询日志**、**慢查询日志**、**事务日志**、**二进制日志**几大类
- 比较重要的
  1. 二进制日志： **binlog（归档日志）**【server层】
  2. 事务日志：**redo log（重做日志）**和**undo log（回滚日志）** 【引擎层】
  3. redo log是记录物理上的改变；undo log是从逻辑上恢复
  4. MySQL InnoDB 引擎使用 **redo log(重做日志)** 保证事务的**持久性**，使用 **undo log(回滚日志)** 来保证事务的**原子性**。

![image-20230114174517643](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114174517643.png)

# redo log

- redo log（重做日志）是**InnoDB**存储引擎独有的，它让MySQL拥有了**崩溃恢复**的能力

  > 比如 `MySQL` 实例**挂了或宕机**了，**重启**时，`InnoDB`存储引擎会使用`redo log`恢复数据，保证数据的**持久性**与**完整性**。

  ![image-20230114185737370](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114185737370.png)

1. MySQL中数据是以**页**为单位，你查询一条记录，会从硬盘把一页的数据加载出来，加载出来的数据叫**数据页**，会放到**Buffer Pool**中

   > - 后续的查询都是先从 `Buffer Pool` 中找，没有命中再去硬盘加载，减少硬盘 `IO` 开销，提升性能。
   >
   > - 更新表数据的时候，也是如此，发现 `Buffer Pool` 里存在要更新的数据，就直接在 `Buffer Pool` 里更新

2. 把“**在某个数据页上做了什么修改**”记录到**重做日志缓存**（`redo log buffer`）里，接着**刷盘到 `redo log` 文件**里  
   即  从 硬盘上db数据文件 --> BufferPool --> redo log buffer --> redo log
   ![image-20230114190158828](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114190158828.png)

3. 理想情况，事务**一提交就会进行刷盘**操作，但**实际上**，刷盘的时机是**根据策略**

   > 每条redo记录由**”表空间号+数据页号+偏移量+修改数据长度+具体修改的数据“**组成

## 刷盘时机

## 日志文件组

## redo log 小结

# binlog

## 记录格式

## 写入机制

# 两阶段提交

# undo log

