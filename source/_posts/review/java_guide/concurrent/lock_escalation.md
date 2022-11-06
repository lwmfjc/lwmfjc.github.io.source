---
title: 锁升级
description: 锁升级
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-11-06 12:31:02
updated: 2022-11-06 12:31:02
---







>  以下内容均转自 https://www.cnblogs.com/wuqinglong/p/9945618.html，部分疑惑参考自另一作者 https://github.com/farmerjohngit/myblog/issues/12 ，感谢原作者。

## 概述

传统的synchronized为重量级锁，但是随着JavaSE1.6对synchronized优化后，部分情况下他就没有那么重了。本文介绍了JavaSE1.6为了减少获得锁和释放锁带来的性能消耗而引入的**偏向锁**和**轻量级锁**，以及**锁结构**、及**锁升级**过程

## 实现同步的基础

Java中每个对象都可以作为锁，具体变现形式

1. 对于普通同步方法，锁是当前实例对象
2. 对于静态同步方法，锁是当前类的Class对象
3. 对于同步方法块，锁是synchronized括号里配置的对象

一个线程试图访问同步代码块时，必须获取锁；在退出或者抛出异常时，必须释放锁

## 实现方式

JVM 基于**进入和退出 Monitor 对象**来实现**方法同步**和**代码块同步**，但是两者的**实现细节不一样**

1. **代码块同步**：通过使用 **monitorenter** 和 **monitorexit** 指令实现的
2. 同步方法：**ACC_SYNCHRONIZED** 修饰

monitorenter 指令是在**编译后插入到同步代码块的开始位置**，而 monitorexit 指令是在**编译后插入到同步代码块的结束处或异常处**

对于同步方法，**进入方法前**添加一个 monitorenter 指令，**退出方法后**添加一个 monitorexit 指令。

demo：  

```java
public class Demo {

    public void f1() {
        synchronized (Demo.class) {
            System.out.println("Hello World.");
        }
    }

    public synchronized void f2() {
        System.out.println("Hello World.");
    }

}
```

编译之后的字节码（使用 javap )

```java
public void f1();
  descriptor: ()V
  flags: ACC_PUBLIC
  Code:
    stack=2, locals=3, args_size=1
       0: ldc           #2                  // class me/snail/base/Demo
       2: dup
       3: astore_1
       4: monitorenter
       5: getstatic     #3                  // Field java/lang/System.out:Ljava/io/PrintStream;
       8: ldc           #4                  // String Hello World.
      10: invokevirtual #5                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
      13: aload_1
      14: monitorexit
      15: goto          23
      18: astore_2
      19: aload_1
      20: monitorexit
      21: aload_2
      22: athrow
      23: return
    Exception table:
       from    to  target type
           5    15    18   any
          18    21    18   any
    LineNumberTable:
      line 6: 0
      line 7: 5
      line 8: 13
      line 9: 23
    StackMapTable: number_of_entries = 2
      frame_type = 255 /* full_frame */
        offset_delta = 18
        locals = [ class me/snail/base/Demo, class java/lang/Object ]
        stack = [ class java/lang/Throwable ]
      frame_type = 250 /* chop */
        offset_delta = 4

public synchronized void f2();
  descriptor: ()V
  flags: ACC_PUBLIC, ACC_SYNCHRONIZED
  Code:
    stack=2, locals=1, args_size=1
       0: getstatic     #3                  // Field java/lang/System.out:Ljava/io/PrintStream;
       3: ldc           #4                  // String Hello World.
       5: invokevirtual #5                  // Method java/io/PrintStream.println:(Ljava/lang/String;)V
       8: return
    LineNumberTable:
      line 12: 0
      line 13: 8
```

先说 **f1() 方法**，发现其中**一个 monitorenter 对应了两个 monitorexit**，这是不对的。**但是**仔细看 #15: goto 语句，直接跳转到了 #23: return 处，再看 #22: athrow 语句发现，原来**第二个 monitorexit** 是**保证同步代码块抛出异常**时锁能**得到正确的释放**而存在的，这就理解了。

## Java对象头（存储锁类型）

HotSpot虚拟机中，对象在内存中的布局分为三块区域：**对象头**、**实例数据**、**对齐填充**

对象头又包括两部分：**MarkWord**和**类型指针**，对于**数组对象**，对象头中还有一部分时存储**数组的长度**

**多线程下synchronized的加锁，就是对同一个对象的对象头中的MarkWord中的变量进行CAS操作**

1. MarkWord
   

2. 类型指针
   虚拟机通过这个指针确定该对象是哪个类的实例

3. 对象头的长度

   | 长度     | **内容**               | **说明**                       |
   | :------- | :--------------------- | :----------------------------- |
   | 32/64bit | MarkWord               | 存储对象的hashCode或锁信息等   |
   | 32/64bit | Class Metadada Address | 存储对象类型数据的指针         |
   | 32/64bit | Array Length           | 数组的长度(如果当前对象是数组) |

   如果是数组对象的话，虚拟机用3个字宽(32/64bit + 32/64bit + 32/64bit)存储对象头，如果是普通对象的话，虚拟机用2字宽存储对象头(32/64bit + 32/64bit)。

## 优化后synchronized锁的分类

级别从低到高依次是：无锁状态 -> 偏向锁状态 -> 轻量级锁状态 -> 重量级锁状态

锁可以升级，但不能降级，即顺序为单向

下面以32位系统为例，每个锁状态下，每个字宽中的内容

1. 无锁状态

   | 25bit          | 4bit         | 1bit(是否是偏向锁) | 2bit(锁标志位) |
   | -------------- | ------------ | ------------------ | -------------- |
   | 对象的hashCode | 对象分代年龄 | 0                  | 01             |

   这里的 hashCode 是 **Object#hashCode** 或者 **System#identityHashCode** 计算出来的值，不是用户覆盖产生的 hashCode。

2. 偏向锁状态

   | 25bit  | 4bit  | 1bit(是否是偏向锁) | 2bit(锁标志位) |
   | ------ | ----- | ------------------ | -------------- |
   | 线程ID | epoch | 1                  | 01             |

   这里 **线程ID 和 epoch 占用了 hashCode** 的位置，所以，如果对象如果**计算过 identityHashCode** 后，便**无法进入偏向锁**状态，反过来，如果对象**处于偏向锁状态**，并且**需要计算其 identityHashCode** 的话，则偏向锁会被撤销，**升级为重量级锁**。
   对于偏向锁，如果线程ID=0 表示为加锁

   > 什么时候会计算 HashCode 呢？比如：**将对象作为 Map 的 Key 时会自动触发计算**，List 就不会计算，日常创建一个对象，持久化到库里，进行 json 序列化，或者作为临时对象等，这些情况下，并不会触发计算 hashCode，所以大部分情况不会触发计算 hashCode。

   Identity hash code是未被覆写的 java.lang.Object.hashCode() 或者 java.lang.System.identityHashCode(Object) 所返回的值。

3. 轻量级锁状态

   | 30bit                  | **2bit** |
   | ---------------------- | -------- |
   | 指向线程栈锁记录的指针 | 00       |

   这里指向栈帧中的LockRecord记录，里面当然可以记录对象的identityHashCode

4. 重量级锁状态

   | 30bit              | 2bit |
   | ------------------ | ---- |
   | 指向锁监视器的指针 | 10   |

   这里指向了**内存中对象的 ObjectMonitor** 对象，而 **ObectMontitor** 对象可以**存储对象的 identityHashCode** 的值。

## 锁的升级

###  偏向锁

偏向锁是**针对于一个线程**而言的，线程获得锁之后就不会再有解锁等操作了，这样可以**省略很多开销**。**假如有两个线程来竞争该锁话，那么偏向锁就失效了，进而升级成轻量级锁**了【注意这段解释，网上很多都错了，没有什么CAS失败才升级，只要有线程来抢，就直接升级为轻量级锁】



### 轻量级锁

### 重量级锁

