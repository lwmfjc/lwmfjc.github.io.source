---
title: 集合_2
description: 集合_2
categories:
  - 学习
tags:
  - '复习'
  - '复习--知识点' 
date: 2022-10-18 08:54:49
updated: 2022-10-18 08:54:49

---



## Map

- HashMap和Hashtable的区别
  - HashMap是非线程安全的，Hashtable是线程安全的，因为Hashtable内部方法都经过synchronized修饰（不过要保证线程安全一般用ConcurrentHashMap）
  - 由于加了synchronized修饰，HashTable效率没有HashMap高
  - HashMap可以存储null的key和value，但null作为key的键只能由一个；HashTable不允许有null键和null值
  - 初始容量及每次扩容
    - Hashtable默认初始大小11，之后扩容为2n+1;HashMap初始大小16，之后扩容2n
    - 如果指定初始大小，HashTable直接使用初始大小，而HashMap使用2的幂作为哈希表的大小（我猜是大于初始大小的最小2的n次方）
  - 底层数据结构
    - JDK1.8之后HashMap解决哈希冲突时，当链表大于阈值（默认8）时，将链表转为红黑树（转换前判断，如果当前数组长度小于64，则先进行数组扩容，而不转成红黑树），以减少搜索时间
  - 

## Collections工具类

## Java集合使用注意事项总结



