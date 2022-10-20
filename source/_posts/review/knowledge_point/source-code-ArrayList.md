---
title: ArrayList源码
description: ArrayList源码
categories:
  - 学习
tags:
  - 复习
  - 复习--知识点
date: 2022-10-20 17:01:47
updated: 2022-10-20 17:01:47
---

## 简介

- 底层是数组队列，相当于动态数组，能动态增长，可以在添加大量元素前先使用ensureCapacity来增加ArrayList容量，减少递增式再分配的数量
  源码：  

    ```java
  public class ArrayList<E> extends AbstractList<E>
                implements List<E>, RandomAccess, Cloneable, java.io.Serializable{ }
    ```

    1. Random Access，标志接口，表明这个接口的List集合支持**快速随机访问**，这里是指可通过元素序号快速访问
    2. 实现Cloneable接口，能被克隆
    3. 实现java.io.Serializable，支持序列化

- ArrayList和Vector区别

  - ArrayList和Vector都是List的实现类，Vector出现的比较早，底层都是Object[] 存储
  - ArrayList线程不安全（效率低所以适合频繁查找 ）
  - Vector 线程安全的

- ArrayList与LinkedList区别

  - 都是不同步的，即不保证线程安全
  - ArrayList底层为Object数组；LinkedList底层使用双向链表数据结构(1.6之前为循环链表，1.7取消了循环)
  - 插入和删除是否受元素位置影响
    - ArrayList采用数组存储，所以插入和删除元素的时间复杂度受元素位置影响[ 默认增加到末尾，O(1) ; 在指定位置，则O(n) , 要往后移动]

## 核心源码解读

## 扩容机制分析