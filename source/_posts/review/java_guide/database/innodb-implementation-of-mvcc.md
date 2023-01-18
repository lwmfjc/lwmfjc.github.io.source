---
title: innodb引擎对MVCC的实现
description: innodb引擎对MVCC的实现
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-database
date: 2023-01-16 19:23:55
updated: 2023-01-16 19:23:55
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 一致性非锁定读和锁定读

## 一致性非锁定读

★★非锁定★★  

- 对于**一致性非锁定读（Consistent Nonlocking Reads）**的实现，通常做法是**加一个版本号**或者**时间戳**字段，在更新数据的同时**版本号+1**或者**更新时间戳**。查询时，将**当前可见的版本号**与**对应记录的版本号**进行比对，如果**记录的版本**小于**可见版本**，则表示**该记录可见**
- **InnoDB**存储引擎中，**多版本控制（multi versioning）**即使非锁定读的实现。如果读取的行**正在执行DELETE**或**UPDATE**操作，这时读取操作**不会去等待行上** **锁的释放**.相反地，Inn哦DB存储引擎会去读取**行的一个快照数据**，对于这种**读取历史数据**的方式，我们叫它**快照读（snapshot read）**。  
- 在 **`Repeatable Read`** 和 **`Read Committed`** 两个隔离级别下，如果是执行普通的 `select` 语句（**不包括 `select ... lock in share mode` ,`select ... for update`**）则会使用 **`一致性非锁定读（MVCC）`**。并且在 **`Repeatable Read` 下 `MVCC` 实现了可重复读和防止部分幻读**

## 锁定读

# InnoDB对MVCC的实现
## 隐藏字段
## ReadView

## undo-log

## 数据可见性算法

# RC和RR隔离级别下MVCC的区别

# MVCC解决不可重复读问题

## 在RC下ReadView生成情况

## 在RR下ReadView生成情况

# MVCC+Next-key -Lock防止幻读