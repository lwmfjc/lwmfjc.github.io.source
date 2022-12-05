---
title: Atomic原子类介绍
description: Atomic原子类介绍
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-12-05 09:24:36
updated: 2022-12-05 09:24:36
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者! 

# 原子类介绍

- 在化学上，原子是构成一般物质的最小单位，化学反应中是不可分割的，Atomic指**一个操作是不可中断的**，即使在多个线程一起执行时，一个操作一旦开始就**不会被其他线程干扰**
- 原子类-->具有原子/原子操作特征的类
- 并发包java.util.concurrent 的原子类都放着```java.util.concurrent.atomic```中
  ![image-20221205094229003](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221205094229003.png)
- 根据操作的数据类型，可以将JUC包中的原子类分为4类（基本类型、数组类型、引用类型、对象的属性修改类型）
  - 基本类型 
    使用原子方式更新基本类型，包括**AtomicInteger 整型原子类**，**AtomicLong 长整型原子类**，AtomicBoolean 布尔型原子类
  - 数组类型
    使用原子方式更新数组里某个元素，包括**AtomicIntegerArray 整型数组原子类**，**AtomicLongArray 长整型数组原子类**，**AtomicReferenceArray  引用类型数组原子类**
  - 引用类型
    **AtomicReference 引用类型原子类**，AtomicMarkableReference 原子更新带**有标记**的引用类型，该类将boolean标记与引用关联（**不可解决CAS进行原子操作出现的ABA问题**），**AtomicStampedReference** 原子更新带有版本号的引用类型 该类将整数值与引用关联，可用于解决原子更新**数据和数据的版本号(解决使用CAS进行原子更新时可能出现的ABA问题)**
  - 对象的属性修改类型
    **AtomicIntegerFieldUpdater 原子更新整型字段的更新器**，**AtomicLongFieldUpdater 原子更新长整型字段的更新器**，
    **AtomicReferenceFieldUpdater 原子更新引用类型里的字段**

  - `AtomicMarkableReference` 不能解决 ABA 问题

    ```java
    public class SolveABAByAtomicMarkableReference {
    
        private static AtomicMarkableReference atomicMarkableReference = new AtomicMarkableReference(100, false);
    
        public static void main(String[] args) {
    
            Thread refT1 = new Thread(() -> {
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                atomicMarkableReference.compareAndSet(100, 101, atomicMarkableReference.isMarked(), !atomicMarkableReference.isMarked());
                atomicMarkableReference.compareAndSet(101, 100, atomicMarkableReference.isMarked(), !atomicMarkableReference.isMarked());
            });
    
            Thread refT2 = new Thread(() -> {
                //获取原来的marked标记(false)
                boolean marked = atomicMarkableReference.isMarked();
                //2s之后进行替换,不应该替换成功
                try {
                    TimeUnit.SECONDS.sleep(2);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                boolean c3 = atomicMarkableReference.compareAndSet(100, 101, marked, !marked);
                System.out.println(c3); // 返回true,实际应该返回false
            });
    
            refT1.start();
            refT2.start();
        }
    }
    ```

  - CAS ABA问题

    > 描述: 第一个线程取到了变量 x 的值 A，然后巴拉巴拉干别的事，总之就是只拿到了变量 x 的值 A。这段时间内第二个线程也取到了变量 x 的值 A，然后把变量 x 的值改为 B，然后巴拉巴拉干别的事，最后又把变量 x 的值变为 A （相当于还原了）。在这之后第一个线程终于进行了变量 x 的操作，但是此时变量 x 的值还是 A，所以 compareAndSet 操作是成功。
    >
    > ---
    >
    > 也就是说，线程一无法保证自己操作期间，该值被修改了

  - 例子描述(可能不太合适，但好理解): 年初，现金为零，然后通过正常劳动赚了三百万，之后正常消费了（比如买房子）三百万。年末，虽然现金零收入（可能变成其他形式了），但是赚了钱是事实，还是得交税的！

  - 代码描述

    ```java
    import java.util.concurrent.atomic.AtomicInteger;
    
    public class AtomicIntegerDefectDemo {
        public static void main(String[] args) {
            defectOfABA();
        }
    
        static void defectOfABA() {
            final AtomicInteger atomicInteger = new AtomicInteger(1);
    
            Thread coreThread = new Thread(
                    () -> {
                        final int currentValue = atomicInteger.get();
                        System.out.println(Thread.currentThread().getName() + " ------ currentValue=" + currentValue);
    
                        // 这段目的：模拟处理其他业务花费的时间
                        //也就是说，在差值300-100=200ms内，值被操作了两次(但又改回去了)，然后线程coreThread并没有感知到，当作没有修改过来处理
                        try {
                            Thread.sleep(300);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
    
                        boolean casResult = atomicInteger.compareAndSet(1, 2);
                        System.out.println(Thread.currentThread().getName()
                                + " ------ currentValue=" + currentValue
                                + ", finalValue=" + atomicInteger.get()
                                + ", compareAndSet Result=" + casResult);
                    }
            );
            coreThread.start();
    
            // 这段目的：为了让 coreThread 线程先跑起来
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
    
            Thread amateurThread = new Thread(
                    () -> {
                        int currentValue = atomicInteger.get();
                        boolean casResult = atomicInteger.compareAndSet(1, 2);
                        System.out.println(Thread.currentThread().getName()
                                + " ------ currentValue=" + currentValue
                                + ", finalValue=" + atomicInteger.get()
                                + ", compareAndSet Result=" + casResult);
    
                        currentValue = atomicInteger.get();
                        casResult = atomicInteger.compareAndSet(2, 1);
                        System.out.println(Thread.currentThread().getName()
                                + " ------ currentValue=" + currentValue
                                + ", finalValue=" + atomicInteger.get()
                                + ", compareAndSet Result=" + casResult);
                    }
            );
            amateurThread.start();
        }
    } 
    /*输出内容
     Thread-0 ------ currentValue=1
    Thread-1 ------ currentValue=1, finalValue=2, compareAndSet Result=true
    Thread-1 ------ currentValue=2, finalValue=1, compareAndSet Result=true
    Thread-0 ------ currentValue=1, finalValue=2, compareAndSet Result=true 
    */
    ```

# 基本类型原子类

- 使用原子方式更新基本类型：AtomicInteger 整型原子类，AtomicLong 长整型原子类 ，AtomicBoolean 布尔型原子类，下文以AtomicInteger为例子来介绍
- 

# 数组类型原子类

# 引用类型原子类

# 对象的属性修改类型原子类