---
title: ThreadLocal详解
description: ThreadLocal详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-12-05 17:31:52
updated: 2022-12-05 17:31:52
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!
>
> 本文来自一枝花算不算浪漫投稿， 原文地址：[https://juejin.cn/post/6844904151567040519open in new window](https://juejin.cn/post/6844904151567040519)。 感谢作者!

思维导图  
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1.af0577dc.png)

# 目录

# ThreadLocal代码演示

简单使用

```java
public class ThreadLocalTest {
    private List<String> messages = Lists.newArrayList();

    public static final ThreadLocal<ThreadLocalTest> holder = ThreadLocal.withInitial(ThreadLocalTest::new);

    public static void add(String message) {
        holder.get().messages.add(message);
    }

    public static List<String> clear() {
        List<String> messages = holder.get().messages;
        holder.remove();

        System.out.println("size: " + holder.get().messages.size());
        return messages;
    }

    public static void main(String[] args) {
        ThreadLocalTest.add("一枝花算不算浪漫");
        System.out.println(holder.get().messages);
        ThreadLocalTest.clear();
    }
}
/* 结果 
[一枝花算不算浪漫]
size: 0
*/
```

**`ThreadLocal`**对象可以提供**线程局部变量**，**每个线程`Thread`拥有一份自己的副本变量**，多个线程互不干扰。

# ThreadLocal的数据结构

# GC之后key是否为null

# ThreadLocal.set()方法源码详解

# ThreadLocalMap Hash算法

# ThreadLocalMap Hash冲突

# ThreadLocalMap.set() 详解

# ThreadLocalMap过期key的探索

# ThreadLocalMap扩容机制

# ThreadLocalMap.get() 详解

# ThreadLocalMap过期key的启发

# Inheritable ThreadLocal

# ThreadLocal项目中使用实战



