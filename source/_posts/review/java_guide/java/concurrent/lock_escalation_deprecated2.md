---
title: (该文弃用)锁升级
description: (该文弃用)锁升级
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuisde
  - 复习-javaGuide-并发
date: 2022-11-03 11:08:59
updated: 2022-11-03 11:08:59
---



 本文主要讲解synchronized原理和偏向锁、轻量级锁、重量级锁的升级过程，基本都转自 

https://blog.csdn.net/MariaOzawa/article/details/107665689  原作者:[MariaOzawa](https://blog.csdn.net/MariaOzawa) 

## 简介

- 为什么需要锁  
  并发编程中，多个线程访问同一共享资源时，必须考虑如何维护数据的**原子性**
- 历史
  - JDK1.5之前，Java依靠Synchronized关键字实现锁功能，Synchronized是**Jvm**实现的**内置锁**，锁的**获取与释放**由JVM隐式实现
  - JDK1.5，并发包新增Lock接口实现锁功能，提供同步功能，使用时**显式获取和释放锁**
- 区别
  - Lock同步锁基于Java实现，Synchronized基于底层操作系统的MutexLock实现
     ```/ˈmjuːtɛks/ ```，每次**获取和释放锁**都会带来**用户态和内核态的切换**，从而**增加系统性能开销**，性能糟糕，又称**重量级锁**
  - JDK1.6之后，对**Synchronized同步锁**做了**充分优化**

## Synchronized同步锁实现原理

- Synchronized实现同步锁的两种方式：修饰方法；修饰方法块

  ```java
    // 关键字在实例方法上，锁为当前实例
    public synchronized void method1() {
        // code
    }
    
    // 关键字在代码块上，锁为括号里面的对象
    public void method2() {
        Object o = new Object();
        synchronized (o) {
            // code
        }
    }
  
  ```

  这里使用编译--及javap 打印字节文件

  ```shell
  javac -encoding UTF-8 SyncTest.java  //先运行编译class文件命令
  
  javap -v SyncTest.class //再通过javap打印出字节文件
  ```

  结果如下，Synchronized修饰代码块时，由monitorenter和monitorexist指令实现同步。进入monitorenter指令后线程持有Monitor对象；退出monitorenter指令后，线程释放该Monitor对象

  ```java
    public void method2();
      descriptor: ()V
      flags: ACC_PUBLIC
      Code:
        stack=2, locals=4, args_size=1
           0: new           #2                  
           3: dup
           4: invokespecial #1                  
           7: astore_1
           8: aload_1
           9: dup
          10: astore_2
          11: monitorenter //monitorenter 指令
          12: aload_2
          13: monitorexit  //monitorexit  指令
          14: goto          22
          17: astore_3
          18: aload_2
          19: monitorexit
          20: aload_3
          21: athrow
          22: return
        Exception table:
           from    to  target type
              12    14    17   any
              17    20    17   any
        LineNumberTable:
          line 18: 0
          line 19: 8
          line 21: 12
          line 22: 22
        StackMapTable: number_of_entries = 2
          frame_type = 255 /* full_frame */
            offset_delta = 17
            locals = [ class com/demo/io/SyncTest, class java/lang/Object, class java/lang/Object ]
            stack = [ class java/lang/Throwable ]
          frame_type = 250 /* chop */
            offset_delta = 4
  
  ```

  如果Synchronized修饰同步方法，代替monitorenter和monitorexit的是 ```ACC_SYNCHRONIZED```标志，即：JVM使用该访问标志区分方法是否为同步方法。方法调用时，调用指令检查是否设置ACC_SYNCHRONIZED标志，如有，则执行线程**先持有**该Monitor对象，再执行该方法；**运行期间**，**其他线程无法获取到该Monitor**对象；方法**执行完成**后，**释放该Monitor**对象
  javap -v xx.class 字节文件查看

  ```java
     public synchronized void method1();
      descriptor: ()V
      flags: ACC_PUBLIC, ACC_SYNCHRONIZED // ACC_SYNCHRONIZED 标志
      Code:
        stack=0, locals=1, args_size=1
           0: return
        LineNumberTable:
          line 8: 0 
  ```

  

- Monitor：JVM中的同步是基于**进入和退出管程（Monitor）**对象实现的。每个对象实例都会有一个Monitor，**Monitor**可以和对象一起**创建**、**销毁**。Monitor由ObjectMonitor实现，而ObjectMonitor由C++的ObjectMonitor.hpp文件实现，如下：  

  ```java
  ObjectMonitor() {
     _header = NULL;
     _count = 0; //记录个数
     _waiters = 0,
     _recursions = 0;
     _object = NULL;
     _owner = NULL;
     _WaitSet = NULL; //处于wait状态的线程，会被加入到_WaitSet
     _WaitSetLock = 0 ;
     _Responsible = NULL ;
     _succ = NULL ;
     _cxq = NULL ;
     FreeNext = NULL ;
     _EntryList = NULL ; //处于等待锁block状态的线程，会被加入到该列表(Contention List中那些有资格成为候选资源的线程被移动到Entry List中；)
     _SpinFreq = 0 ;
     _SpinClock = 0 ;
     OwnerIsThread = 0 ;
  } 
  //Contention List：竞争队列，所有请求锁的线程首先被放在这个竞争队列中
  ```

  - 如上，多个线程同时访问一段同步代码时，多个线程会**先被**存放在**ContentionList**和**_EntryList**集合中，处于block状态的线程都会加入该列表。
  - 当线程获取到对象的Monitor时，Monitor依靠底层操作系统的MutexLock实现互斥，线程申请Mutex成功，则持有该Mutex，其他线程无法获取；竞争失败的线程再次进入ContentionList被挂起
  - 如果线程调用wait()方法，则会释放当前持有的Mutex，并且该线程进入WaitSet集合中，等待下一次被唤醒（或者顺利执行完方法也会释放Mutex）
    ![image-20221103162008164](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221103162008164.png)

## 锁升级

- 为了提升性能，Java1.6，引入了**偏向锁、轻量级锁、重量级锁**，来**减少**锁竞争带来的上下文切换，由新增的**Java对象头**实现了**锁升级**。锁只能升级不能降级，目的是**提高获得锁和释放锁的效率**
- 当Java对象**被Synchronized**关键字修饰为同步锁后，围绕这个锁的一系列升级操作都和**Java对象头**有关
- JDK1.6 JVM中，对象实例在堆内存中被分为三个部分：**对象头**、**实例数据**和**对齐填充**。其中**对象头**由**MarkWord**、**指向类的指针**以及数组长度三部分组成
- MarkWord记录了对象和锁相关的信息，它在64为JVM的长度是64bit，下图为**64位JVM的存储结构**：
  ![image-20221103172236691](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221103172236691.png)
  32位如下
  ![image-20221106120357729](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221106120357729.png)
  - 锁标志位是两位，**无锁**和**偏向锁**的锁标志位实际为**01**，轻量级锁的锁标志位为**00**
  - 锁升级功能，主要依赖于MarkWord中的**锁标志位**和**释放偏向锁标志位**，Synchronized同步锁，是从**偏向锁**开始的，随着竞争越来越激烈，**偏向锁**升级到**轻量级锁**，最终升级到**重量级锁**



## =================================从这之后往下，是有误的的=============================

### 偏向锁

- JVM会为每个当前线程的栈帧中，创建用于**存储锁记录**的空间，官方称为**Displaced Mark Word**（**轻量级锁**会用到）
- 为什么引入偏向锁
  
- 多数情况，**锁不仅不存在多线程竞争，且经常由同一线程获得**，为了在这种情况让线程**获得锁的代价更低**而**引入了偏向锁**。例如：线程操作一个线程安全集合时，同一线程每次都需要获取和释放锁，则每次操作都会发生**用户态和内核态的切换（重量级锁）**
  
- 解决方案（偏向锁的作用）

  - 当一个线程再次访问这个同步代码或方法时，**该线程**只需去**对象头的MarkWord**中，判断一下是否有**偏向锁指向该线程的ID**，而无需再进入Monitor去竞争对象
  - 当**对象被当作同步锁**并**有一个线程抢到了锁**，**锁标志位**还是**01**，**是否偏向锁标志位**为1，并且记录抢到锁的**线程ID**，表示进入**偏向锁状态**

- 偏向锁的撤销
  一旦出现其他线程**竞争锁资源（竞争且CAS失败）**时，偏向锁就会被撤销。偏向锁的撤销需要**等待全局安全点**，暂停持有该锁的线程，**同时**检查该线程是否还在执行该方法，如果**是升级锁**，**反之(该锁)被其他线程抢占**

  > 注：对于“CAS操作替换线程ID”这个解释，我的理解是：
  >
  > 1. 偏向锁是不会被主动释放的
  > 2. 

  ![image-20221104105511181](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221104105511181.png)
  **偏向锁默认开启**（JDK15默认关闭)，如果**应用程序里所有的锁通常情况下处于竞争**状态，此时可以添加JVM参数关闭偏向锁来调优系统性能

  ```shell
  -XX:-UseBiasedLocking //关闭偏向锁（默认打开）
  ```

### 轻量级锁

- 何时升级为轻量级锁
  当有另外一个线程获取这个锁，由于该锁已经是偏向锁，当发现对象头MarkWord中的线程ID不是自己的线程ID，就会进行CAS操作获取锁
  - 如果**获取成功**，**直接替换MarkWord中的线程ID为自己ID**，该锁把持偏向锁状态
  - 如果**获取失败**，代表**当前锁有一定的竞争**，偏向锁将升级为轻量级锁
- 适用场景
  **”绝大部分的锁，在整个同步周期内都不存在长时间的竞争“**的场景