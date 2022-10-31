---
title: 锁升级
description: 锁升级
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuisde
  - 复习-javaGuide-并发
date: 2022-10-31 11:08:59
updated: 2022-10-31 11:08:59
---



## 简介

无锁 => 偏向锁 => 轻量锁 => 重量锁

复习Class类锁和实例对象锁，说明Class类锁和实例对象锁不是同一把锁，互相不影响

```java
public static void main(String[] args) throws InterruptedException { 
        Object object=new Object();
        new Thread(()->{
           synchronized (Customer.class){
               System.out.println(Thread.currentThread().getName()+"Object.class类锁");
               try {
                   TimeUnit.SECONDS.sleep(5);
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
           }
            System.out.println(Thread.currentThread().getName()+"结束并释放锁");
        },"线程1").start();
        //保证线程1已经获得类锁
        try {
            TimeUnit.SECONDS.sleep(2);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        new Thread(()->{
            synchronized (object){
                System.out.println(Thread.currentThread().getName()+"获得object实例对象锁");
            }
            System.out.println(Thread.currentThread().getName()+"结束并释放锁");
        },"线程2").start();

    }

/* 输出
线程1Object.class类锁
线程2获得object实例对象锁
线程2结束并释放锁
线程1结束并释放锁
*/
```

总结图  , 00 , 01 , 10 ，没有11

001（无锁）和101（偏向锁），00（轻量级锁），10（重量级锁）

![image-20221031112225665](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221031112225665.png)

## 背景

下面这部分，其实在io模块有提到过

> - 为了保证系统稳定性和安全性，一个进程的地址空间划分为**用户空间User space**和**内核空间Kernel space** 
> - 平常运行的应用程序都运行在用户空间，只有内核空间才能进行系统态级别的资源有关操作---文件管理、进程通信、内存管理

如果直接synchronized加锁，会有下面图的流程出现，频繁进行用户态和内核态的切换(阻塞和唤醒线程[线程通信]，需要频繁切换cpu的状态)  
![image-20221031112946966](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221031112946966.png)

- 为什么每一个对象都可以成为一个锁
  markOop.hpp （对应对象标识）
  每一个java对象里面，有一个Monitor对象（ObjectMonitor.cpp)关联
  如图，_owner指向持有ObjectMonitor对象的线程
  ![image-20221031114235312](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221031114235312.png)
  Monitor本质依赖于底层操作系统的MutexLock实现，操作系统实现线程之间的切换，需要从用户态到内核态的切换，成本极高
- ★★ 重点：Monitor与Java对象以及线程是如何关联
  - 如果一个java对象被某个线程锁住，则该对象的MarkWord字段中，LockWord指向monitor的起始地址
  - Monitor的Owner字段会存放拥有相关

