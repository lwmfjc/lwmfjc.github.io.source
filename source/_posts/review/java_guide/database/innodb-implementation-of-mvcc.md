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