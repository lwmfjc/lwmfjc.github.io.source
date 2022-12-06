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

> 回顾之前的知识点  
>
> ```java
> public void set(T value) {
>     //获取当前请求的线程    
>     Thread t = Thread.currentThread();
>     //取出 Thread 类内部的 threadLocals 变量(哈希表结构)
>     ThreadLocalMap map = getMap(t);
>     if (map != null)
>         // 将需要存储的值放入到这个哈希表中
>         //★★实际使用的方法
>         map.set(this, value);
>     else
>         //★★实际使用的方法
>         createMap(t, value);
> }
> ThreadLocalMap getMap(Thread t) {
>     return t.threadLocals;
> }
> ```
>
> - 如上，实际存取都是从Thread的threadLocals （ThreadLocalMap类）中，并不是存在ThreadLocal上，ThreadLocal用来传递了变量值，只是ThreadLocalMap的封装
> - ThreadLocal类中通过Thread.currentThread()获取到当前线程对象后，直接通过getMap(Thread t) 可以访问到该线程的ThreadLocalMap对象
> - 每个Thread中具备一个ThreadLocalMap，而ThreadLocalMap可以存储以ThreadLocal为key，Object对象为value的键值对

# ThreadLocal的数据结构

由上面回顾的知识点可知，value实际上都是保存在**线程类(Thread类)中的某个属性(ThreadLocalMap类)**中
![image-20221206091635103](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206091635103.png)

`Thread`类有一个类型为**`ThreadLocal.ThreadLocalMap`**的实例变量`threadLocals`，也就是说每个线程有一个自己的`ThreadLocalMap`。
ThreadLocalMap是一个静态内部类

> 没有修饰符，为包可见。比如父类有一个protected修饰的方法f()，不同包下存在子类A和其他类X，在子类中可以访问方法f()，即使在其他类X创建子类A实例a1，也不能调用a1.f() 
>
> ![image-20221206092433827](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206092433827.png)

ThreadLocalMap有自己独立实现，简单地将它的**key视作ThreadLocal**，**value为代码中放入的值**，（看底层代码可知，实际key不是ThreadLocal本身，而是它的一个弱引用）

**★每个线程**在往`ThreadLocal`里放值的时候，都会往**自己的`ThreadLocalMap`**里存，读也是**以`ThreadLocal`作为引用，在自己的`map`里找对应的`key`**，从而实现了**线程隔离**。

`ThreadLocalMap`有点类似`HashMap`的结构，只是`HashMap`是由**数组+链表**实现的，而`ThreadLocalMap`中并没有**链表**结构。其中，还要注意`Entry`类， 它的`key`是`ThreadLocal<?> k` ，(Entry类)继承自`WeakReference`， 也就是我们常说的弱引用类型。

> 如下，有个数组存放Entry(弱引用类，且有属性value)，且
>
> ![image-20221206094304751](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206094304751.png)
>
> ---
>
> ```java
> static class ThreadLocalMap { 
>         static class Entry extends WeakReference<ThreadLocal<?>> {
>             /** The value associated with this ThreadLocal. */
>             Object value;
> 
>             Entry(ThreadLocal<?> k, Object v) {
>                 super(k);
>                 value = v;
>             }
>         }
>     //.....
> }
> ```

# 为上面的知识点总结一张图

![image-20221206095002176](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206095002176.png)

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



