---
title: ly03122ly锁升级
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

> *为什么要这样做呢？因为经验表明，其实大部分情况下，都会是同一个线程进入同一块同步代码块的。这也是为什么会有偏向锁出现的原因。*

如果支持偏向锁（没有计算 hashCode），那么在分配(创建)对象时，分配一个可偏向而未偏向的对象（MarkWord的最后 3 位为 101，并且 Thread Id 字段的值为 0）

#### 1. 偏向锁的加锁

- 偏向锁标志是**未偏向状态**，使用 **CAS 将 MarkWord 中的线程ID**设置为**自己的线程ID**
  - 如果成功，则获取偏向锁成功
  - 如果失败，则进行**锁升级**（也就是被别人抢了，没抢过）

- 偏向锁状态是已偏向状态

  - MarkWord中的线程ID**是自己的线程ID，则成功获取锁**

  - MarkWord中的线程ID**不是自己的线程ID，则需要进行锁升级**

注意，这里说的锁升级，需要进行**偏向锁的撤销**

#### 2. 偏向锁的撤销

前提：**撤销偏向的操作需要在全局检查点执行** 。我们假设线程A曾经拥有锁（不确定是否释放锁）， 线程B来竞争锁对象，如果当**线程A不在拥有锁时或者死亡时，线程B直接去尝试获得锁**（根据是否 允许重偏向（`rebiasing`），获得偏向锁或者轻量级锁）；如果**线程A仍然拥有锁，那么锁 升级为轻量级锁，线程B自旋请求获得锁**。

- 对象是不可偏向状态
  不需要撤销

- 对象是可偏向状态
  - 如果MarkWord中指向的线程**不存活** （这里说的是拥有偏向锁的**线程正常执行完毕后释放锁**）
    如果允许重偏向，则退回到可偏向但未偏向的状态；如果不允许重偏向，则变为无锁状态
  - 如果MarkWord中的线程仍然存活 （这里说的是拥有偏向锁的**线程未执行完毕但进行了锁撤销：（包括释放锁及未释放锁(有线程来抢)两种情形）**）
    如果线程ID指向的线程**仍然拥有锁**，则**★★升级为轻量级锁，MarkWord复制到线程栈中★★**；如果线程ID**不再拥有锁**（那个线程已经释放了锁），则同样是退回到可偏向(如果允许)但未偏向的状态（即线程ID未空），如果不允许重偏向，则变为无锁状态

偏向锁的撤销流程如图：  
![image-20221106144334151](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221106144334151.png)

### 轻量级锁

之所以称为轻量级，是因为它仅仅使用CAS进行操作，实现获取锁

#### 1. 加锁流程

- 如果线程发现**对象头中Mark Word已经存在指向自己栈帧的指针**，即**线程已经获得轻量级锁**，那么只需要将0存储在自己的栈帧中（此过程称为递归加锁）；在解锁的时候，如果发现锁记录的内容为0， 那么只需要移除栈帧中的锁记录即可，而不需要更新Mark Word。
  ![image-20221106145155638](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221106145155638.png)

  线程尝试**使用 CAS 将对象头中的 Mark Word 替换为指向锁记录（`Lock Record`）的指针（这里说的是，MarkWord中并没有指向其他线程栈帧）**， 如上图所示。（我觉得**★这里的CAS，原值为原来的markword，而不是指向其他线程的线程栈地址，这样意义就不对了，会导致别的线程执行到一半失去锁★**）

  - 如果成功，当前线程获得轻量级锁
  - 如果失败，虚拟机**先检查当前对象头的 Mark Word 是否指向当前线程的栈帧**
    - 如果指向，则说明当前线程已经拥有这个对象的锁，则可以直接进入同步块 执行操作
    - 否则表示其他线程竞争锁，当前线程便尝试使用自旋来获取锁。当竞争线程的自旋次数 达到界限值（`threshold`），轻量级锁将会膨胀为重量级锁。

#### 2. 撤销流程

轻量级锁解锁时，如果对象的Mark Word仍然指向着线程的锁记录，会使用CAS操作， 将Dispalced Mark Word替换到对象头，如果成功，则表示没有竞争发生。如果失败， 表示当前锁存在锁竞争，锁就会膨胀为重量级锁。

### 重量级锁

重量级锁（`heavy weight lock`），是**使用操作系统互斥量（`mutex`）来实现的传统锁**。 当所有对锁的优化都失效时，将退回到重量级锁。它与轻量级锁不同竞争的线程**不再通过自旋来竞争线程， 而是直接进入堵塞状态**，此时**不消耗CPU**，然后等拥有锁的线程释放锁后，唤醒堵塞的线程， 然后线程再次竞争锁。但是注意，当**锁膨胀（`inflate`）为重量锁时，就不能再退回到轻量级锁**。

## 总结

首先要明确一点是引入这些锁是为了提高获取锁的效率, 要明白每种锁的使用场景, 比如**偏向锁**适合**一个线程对一个锁的多次获取**的情况; **轻量级锁**适合**锁执行体比较简单(即减少锁粒度或时间)**, 自旋一会儿就可以成功获取锁的情况.

要明白MarkWord中的内容表示的含义.