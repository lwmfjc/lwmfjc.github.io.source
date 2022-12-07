---
title: memory-area
description: memory-area
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-12-07 13:49:39
updated: 2022-12-07 13:49:39
---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!
>
> 如果没有特殊说明，针对的都是HotSpot虚拟机

# 前言

- 对于Java程序员，虚拟机自动管理机制，不需要像C/C++程序员为每一个new 操作去写对应的delete/free 操作，不容易出现**内存泄漏** 和 **内存溢出**问题
- 但由于内存控制权交给Java虚拟机，一旦出现内存泄漏和溢出方面问题，如果不了解虚拟机是怎么样使用内存，那么很难**排查任务**

# 运行时数据区域



## 程序计数器

## Java虚拟机栈

## 本地方法栈

## 堆

## 方法区

## 运行时常量池

## 直接内存

# HotSpot虚拟机对象探秘

## 对象的创建

## 对象的内存布局

## 对象的访问定位