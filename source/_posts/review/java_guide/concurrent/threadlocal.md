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

> WeakReference的使用 
>
> ```java  
> WeakReference<Car> weakCar = new WeakReference(Car)(car); 
> weakCar.get();  //如果值为null表示已经被回收了
> ```

问题：  ThreadLocal的key为弱引用，那么在ThreadLocal.get()的时候，发生GC之后，key是否为null

- Java的四种引用类型
  - 强引用：通常情况new出来的为强引用，只要强引用存在，垃圾回收器**永远不会**回收被引用的对象（即使内存不足）
  - 软引用：使用SoftReference修饰的对象称软引用，软引用指向的对象在**内存要溢出的时候**被回收
  - 弱引用：使用WeakReference修饰的对象称为弱引用，只要发生垃圾回收，如果这个对象只被弱引用指向，那么就会被回收
  - 虚引用：虚引用是最弱的引用，用PhantomReference定义。唯一的作用就是**用队列接收对象即将死亡的通知**

使用反射方式查看GC后ThreadLocal中的数据情况

```java
/*
t.join()方法阻塞调用此方法的线程(calling thread)进入 TIMED_WAITING 状态，直到线程t完成，此线程再继续
*/
public class ThreadLocalDemo {

    public static void main(String[] args) throws NoSuchFieldException, IllegalAccessException, InterruptedException {
        Thread t = new Thread(()->test("abc",false));
        t.start();
        t.join();
        System.out.println("--gc后--");
        Thread t2 = new Thread(() -> test("def", true));
        t2.start();
        t2.join();
    }

    private static void test(String s,boolean isGC)  {
        try {
            new ThreadLocal<>().set(s);
            if (isGC) {
                System.gc();
            }
            Thread t = Thread.currentThread();
            Class<? extends Thread> clz = t.getClass();
            Field field = clz.getDeclaredField("threadLocals");
            field.setAccessible(true);
            Object ThreadLocalMap = field.get(t);
            Class<?> tlmClass = ThreadLocalMap.getClass();
            Field tableField = tlmClass.getDeclaredField("table");
            tableField.setAccessible(true);
            Object[] arr = (Object[]) tableField.get(ThreadLocalMap);
            for (Object o : arr) {
                if (o != null) {
                    Class<?> entryClass = o.getClass();
                    Field valueField = entryClass.getDeclaredField("value");
                    Field referenceField = entryClass.getSuperclass().getSuperclass().getDeclaredField("referent");
                    valueField.setAccessible(true);
                    referenceField.setAccessible(true);
                    System.out.println(String.format("弱引用key:%s,值:%s", referenceField.get(o), valueField.get(o)));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
/* 结果如下
弱引用key:java.lang.ThreadLocal@433619b6,值:abc
弱引用key:java.lang.ThreadLocal@418a15e3,值:java.lang.ref.SoftReference@bf97a12
--gc后--
弱引用key:null,值:def 
*/

```

gc之后的图：  
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/3.a63c3de1.png)
```new ThreadLocal<>().set(s);```  GC之后，key就会被回收，我们看到上面的debug中referent=null 

如果这里修改代码，

```
ThreadLocal<Object> threadLocal=new ThreadLocal<>();
threadLocal.set(s);
```

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/4.c4285c13.png)

使用弱引用+垃圾回收

垃圾回收前，ThreadLoal是存在强引用的  
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/5.deed12c8.png)

**只有当强引用不存在**

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



