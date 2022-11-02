---
title: 锁升级（该文弃用）
description: 锁升级（该文弃用）
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
  - 如果一个java对象被某个线程锁住，则该对象的MarkWord字段中，LockWord指向monitor的起始地址（这里说的应该是重量级锁）
  - Monitor的Owner字段会存放拥有相关联对象锁的线程id
  - 图
    ![image-20221031132702183](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221031132702183.png)

## 锁升级

- synchronized用的锁，存在Java对象头里的MarkWord中，锁升级功能主要依赖MarkWord中**锁标志位(后2位)**和**释放偏向锁标志位(无锁和偏向锁，倒数第3位)**

- 对于锁的指向

  1. 无锁情况：（放hashcode(调用了Object.hashcode才有))
  2. 偏向锁：MarkWord存储的是偏向的线程ID
  3. 轻量锁：MarkWord存储的是指向线程栈中LockRecord的指针
  4. 重量锁：MarkWord存储的是指向堆中的monitor对象的指针

- 无锁状态
  初始状态，一个对象被实例化后，如果还没有任何线程竞争锁，那么它就为无锁状态（001）

  ```java
      public static void main(String[] args) {
          Object o = new Object();
          System.out.println(ClassLayout.parseInstance(o).toPrintable()); //16字节
      }
  /* 输出( 这里的mark,VALUE为0x0000000000000001，没有hashCode的值):
  java.lang.Object object internals:
  OFF  SZ   TYPE DESCRIPTION               VALUE
    0   8        (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
    8   4        (object header: class)    0xf80001e5
   12   4        (object alignment gap)    
  Instance size: 16 bytes
  Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
  */
  ```

  下面是调用了hashCode()这个方法的情形:  

  ```java
      public static void main(String[] args) {
          Object o = new Object();
          System.out.println(Integer.toHexString(o.hashCode()));
          System.out.println(ClassLayout.parseInstance(o).toPrintable()); //16字节
      }
  /**输出:
  74a14482
  java.lang.Object object internals:
  OFF  SZ   TYPE DESCRIPTION               VALUE
    0   8        (object header: mark)     0x00000074a1448201 (hash: 0x74a14482; age: 0)
    8   4        (object header: class)    0xf80001e5
   12   4        (object alignment gap)    
  Instance size: 16 bytes
  Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
  */
  ```

- 偏向锁：单线程竞争

  - 当线程A第一次竞争到锁时，通过操作修改MarkWord中的偏向线程ID、偏向模式。如果不存在其他线程竞争，那么持有偏向锁的线程将永远不需要同步
  
  - 如果没有偏向锁，那么就会频繁出现**用户态**到**内核态**的切换
  
  - 意义：当一段同步代码，一直**被同一个线程**多次访问，由于**只有一个线程**那么该线程在后续访问时便会**自动获得锁**
    ![image-20221031172548988](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221031172548988.png)
    
  - 锁在**第一次被拥有**的时候，记录下**偏向线程ID**（后续这个线程进入和退出这段加了同步锁的代码块时，不需要再次加锁和释放锁，只需要**直接检查锁的MarkWord**是不是放的**自己的线程ID**）
    - 如果相等，表示**偏向锁是偏向于当前线程**的，不需要再尝试获得锁，**直到竞争才会释放锁**；以后每次同步，检查**锁的偏向线程ID与当前线程ID**是否一致，若一致则进入同步，无需每次都加锁解锁去CAS更新对象头；如果自始至终使用锁的线程只有一个，很明显偏向锁几乎没有额外开销
    - 如果不等，表示**发生了竞争**，锁已经**不偏向于同一个线程**，此时会尝试**使用CAS来替换MarkWord里面的线程ID**为新线程的ID
      - **竞争成功**，说明之前线程不存在了，MarkWord里的线程ID为新线程ID，所不会升级，**仍然为偏向锁**
      - **竞争失败**，需要升级为**轻量级锁**，才能保证线程间公平竞争锁
    
  - 偏向锁只有遇到**其他线程尝试竞争偏向锁**时，持有偏向锁的线程才会释放锁，**线程是不会主动释放锁的**（尽量不会涉及用户到内核态转换）
  
- 一个**synchronized方法被一个线程抢到锁**时，这个方法所在的对象，就会在**其所在的MarkWord**中**将偏向锁修改状态位 
  
  - 如图  
    ![image-20221031174605461](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221031174605461.png)
    
  - JVM不用和操作系统协商设置Mutex（争取内核），不需要操作系统介入
  
  - 偏向锁相关参数
  
      ```shell
      java -XX:+PrintFlagsInitial | grep BiasedLock*
           intx BiasedLockingBulkRebiasThreshold          = 20
          {product}
           intx BiasedLockingBulkRevokeThreshold          = 40
          {product}
           intx BiasedLockingDecayTime                    = 25000
          {product}
         intx BiasedLockingStartupDelay                 = 4000 #偏向锁启动延迟 4s
          {product}
         bool TraceBiasedLocking                        = false
          {product}
           bool UseBiasedLocking                          = true #默认开启偏向锁
          {product}
      # 使用-XX:UseBiasedLocking 关闭偏向锁
      ```
  
    例子：  
  
      ```java
          public static void main(String[] args) throws InterruptedException {
              TimeUnit.SECONDS.sleep(5); //1 如果1跟下面的2兑换，则就不是偏向锁，是否是偏向锁，在创建对象的时候，就已经确认了
              Object o = new Object();   //2
              //System.out.println(Integer.toHexString(o.hashCode()));
              synchronized (o){
  
              }
              System.out.println(ClassLayout.parseInstance(o).toPrintable()); //16字节
          }
      //延迟5秒(>4)后，就会看到偏向锁
      /* 打印，005，即二进制101
      java.lang.Object object internals:
    OFF  SZ   TYPE DESCRIPTION               VALUE
        0   8        (object header: mark)     0x0000000002f93005 (biased: 0x000000000000be4c; epoch: 0; age: 0)
        8   4        (object header: class)    0xf80001e5
       12   4        (object alignment gap)    
      Instance size: 16 bytes
      Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
      */
      ```
  
  - 偏向锁的升级
    - 是一种等到**竞争出现**才释放锁的机制，只有当其他线程竞争锁时，持有偏向锁的原来线程才会被撤销；撤销需要等待全局安全点（该时间点没有字节码在执行），同时检查持有偏向锁的线程是否还在执行
      - 如果此时第一个线程**正在**执行synchronized方法（处于同步块），还没执行完其他线程来抢，该偏向锁被取消并出现**锁升级**；此时**轻量级锁**由**原持有偏向锁的线程**持有，**继续执行其同步代码**，而**正在竞争**的线程会进入**自旋等待**获得该轻量级锁
      - 如果第一个线程执行完成synchronized方法（**退出同步块**），而将**对象头**设置成**无锁状态**并撤销偏向锁，重新偏向
      - ![image-20221101171515521](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221101171515521.png)
    
  - Java15之后，HotSpot不再默认开启偏向锁，使用```+XX:UseBiasedLocking```手动开启
  
  - 偏向锁流程总结 (转自https://blog.csdn.net/MariaOzawa/article/details/107665689)
    ![](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/20221102153032.png)
  
- 轻量级锁
  主要是为了在线程近乎交替执行同步块时提高性能
  升级时机，当关闭偏向锁或多线程竞争偏向锁会导致偏向锁升级为轻量级锁
  标志位为00