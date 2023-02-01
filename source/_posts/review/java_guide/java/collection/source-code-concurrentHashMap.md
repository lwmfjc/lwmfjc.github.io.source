---
title: ConcurrentHashMap源码
description: ConcurrentHashMap源码
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-集合
date: 2022-10-22 18:26:52
updated: 2022-10-22 18:26:52

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!



## 总结

Java7 中 `ConcurrentHashMap` 使用的**分段锁**，也就是**每一个 Segment** 上同时只有一个线程可以操作，**每一个 `Segment`** 都是一个类似 `HashMap` 数组的结构，每一个HashMap**可以扩容**，它的**冲突会转化为链表**。但是 `Segment` 的个数一但初始化就不能改变。

Java8 中的 `ConcurrentHashMap` 使用的 `Synchronized` 锁加 CAS 的机制。结构也由 Java7 中的 **`Segment` 数组 + `HashEntry` 数组 + 链表** 进化成了 **Node 数组 + 链表 / 红黑树**，**Node 是类似于一个 HashEntry 的结构**。它的冲突再达到一定大小时会转化成红黑树，在冲突小于一定数量时又退回链表。

## 源码 （略过）

## ConcurrentHashMap1.7

- 存储结构
  - Segment数组（该数组用来加锁，每个数组元素是一个HashEntry数组（该数组可能包含链表）
  - 如图，ConcurrentHashMap由多个Segment组合，每一个Segment是一个类似HashMap的结构，每一个HashMap内部可以扩容，但是Segment个数初始化后不能改变，默认16个（即默认支持16个线程并发）
    ![image-20221023124636646](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221023124636646.png)

## ConcurrentHashMap1.8

- 存储结构
  ![image-20221023124708670](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221023124708670.png)
  可以发现 Java8 的 ConcurrentHashMap 相对于 Java7 来说变化比较大，不再是之前的 **Segment 数组 + HashEntry 数组 + 链表**，而是 **Node 数组 + 链表 / 红黑树**。当冲突链表达到一定长度时，链表会转换成红黑树。

- 初始化 initTable

  ```java
  /**
   * Initializes table, using the size recorded in sizeCtl.
   */
  private final Node<K,V>[] initTable() {
      Node<K,V>[] tab; int sc;
      while ((tab = table) == null || tab.length == 0) {
          //　如果 sizeCtl < 0 ,说明另外的线程执行CAS 成功，正在进行初始化。
          if ((sc = sizeCtl) < 0)
              // 让出 CPU 使用权
              Thread.yield(); // lost initialization race; just spin
          else if (U.compareAndSwapInt(this, SIZECTL, sc, -1)) {
              try {
                  if ((tab = table) == null || tab.length == 0) {
                      int n = (sc > 0) ? sc : DEFAULT_CAPACITY;
                      @SuppressWarnings("unchecked")
                      Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];
                      table = tab = nt;
                      sc = n - (n >>> 2);
                  }
              } finally {
                  sizeCtl = sc;
              }
              break;
          }
      }
      return tab;
  }
  ```

  - 是通过自旋和CAS操作完成的，注意的变量是sizeCtl，它的值决定着当前的初始化状态

    > 1. -1 说明正在初始化
    > 2. -N 说明有N-1个线程正在进行扩容
    > 3. 表示 table 初始化大小，如果 table 没有初始化
    > 4. 表示 table 容量，如果 table　已经初始化。

- put

  > 根据 key 计算出 hashcode 。
  >
  > 判断是否需要进行初始化。
  >
  > 即为当前 key 定位出的 Node，**如果为空表示当前位置可以写入**数据，利用 **CAS** 尝试写入，**失败则自旋**保证成功。
  >
  > 如果当前位置的 hashcode == MOVED == -1,则需要进行扩容。
  >
  > 如果都不满足，则**利用 synchronized 锁写入**数据。
  >
  > 如果数量大于 TREEIFY_THRESHOLD 则要执行树化方法，在 treeifyBin 中会首先判断当前数组长度≥64时才会将链表转换为红黑树。
  
- get 流程比较简单

  1. 根据 hash 值计算位置。
  2. 查找到指定位置，如果头节点就是要找的，直接返回它的 value.
  3. 如果头节点 hash 值小于 0 ，说明正在扩容或者是红黑树，查找之。
  4. 如果是链表，遍历查找之。
