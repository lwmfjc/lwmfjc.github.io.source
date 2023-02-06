---
title: aqs详解
description: aqs详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-11-30 14:48:01
updated: 2022-12-05 09:18:01
---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

```Semaphore  [ˈseməfɔː(r)]```

> - 何为 AQS？AQS 原理了解吗？
> - `CountDownLatch` 和 `CyclicBarrier` 了解吗？两者的区别是什么？
> - 用过 `Semaphore` 吗？应用场景了解吗？
> - ......

# AQS简单介绍

AQS,AbstractQueueSyschronizer，即抽象队列同步器，这个类在java.util.concurrent.locks包下面

![image-20221130154309546](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221130154309546.png)

AQS是一个抽象类，主要用来构建**锁**和**同步器**

```java
public abstract class AbstractQueuedSynchronizer extends AbstractOwnableSynchronizer implements java.io.Serializable {
} 
```

AQS **为构建锁和同步器提供了一些通用功能**的实现，因此，使用 AQS 能简单且高效地**构造出应用广泛的大量的同步器**，比如我们提到的 **`ReentrantLock`**，**`Semaphore`**，其他的诸如 `ReentrantReadWriteLock`，`SynchronousQueue`，`FutureTask`(jdk1.7) 等等皆是基于 AQS 的。

# AQS原理

**面试不是背题，大家一定要加入自己的思想，即使加入不了自己的思想也要保证自己能够通俗的讲出来而不是背出来**

AQS 核心思想是，如果被请求的**共享资源（AQS内部）**空闲，则将**当前请求资源的线程**设置为**有效**的工作线程，并且将**共享资源**设置为**锁定**状态。如果被请求的共享资源**被占用**，那么就需要一套**线程阻塞等待**以及**被唤醒时锁分配**的机制，这个机制 AQS 是用 **CLH 队列锁**实现的，即**将暂时获取不到锁的线程加入到队列**中。 

  > CLH(Craig,Landin and Hagersten)队列是一个**虚拟的双向队列**（虚拟的双向队列即**不存在队列实例**，仅存在结点之间的关联关系）。AQS 是**将每条请求共享资源的线程封装成一个 CLH 锁队列的一个结点**（Node）来实现锁的分配。  
  > [ 搜索了一下，CLH好像是人名 ]
  > 在 CLH 同步队列中，一个节点表示一个线程，它保存着**线程的引用**（thread）、 当前节点在**队列中的状态**（waitStatus）、**前驱节点**（prev）、**后继节点**（next）。  
  > CLH队列结构  
  > ![image-20230206085141770](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230206085141770.png)

- AQS（AbstractQueuedSynchronized）原理图   
    ![image-20221120193141243](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221120193141243.png)

  AQS使用一个**int成员变量来表示同步状态**，通过内置的**线程等待队列**来获取资源线程的排队工作。  
`state` 变量由 `volatile` 修饰，用于展示**当前临界资源的获锁**情况。
  
  ```java
  private volatile int state;//共享变量，使用volatile修饰保证线程可见性
  ```
```
  
状态信息的操作     
  
  > 通过 `protected` 类型的`getState()`、`setState()`和`compareAndSetState()` 进行操作。并且，这几个方法都是 `final` 修饰的，在子类中无法被重写。
  
  ```java
  //返回同步状态的当前值
  protected final int getState() {
      return state;
  }
  //设置同步状态的值
  protected final void setState(int newState) {
      state = newState;
  }
  //原子地（CAS操作）将同步状态值设置为给定值update如果当前同步状态的值等于expect（期望值）
  protected final boolean compareAndSetState(int expect, int update) {
    return unsafe.compareAndSwapInt(this, stateOffset, expect, update);
    }
```

    以 `ReentrantLock` 为例，**`state`** 初始值为 **0**，表示**未锁定**状态。A 线程 **`lock()`** 时，会调用 **`tryAcquire()`** 独占该锁并将 **`state+1`** 。此后，其他线程再 `tryAcquire()` 时就会失败，直到 A 线程 **`unlock()` 到 `state=`0**（即释放锁）为止，**其它线程**才有机会获取该锁。当然，**释放锁之前**，A 线程**自己是可以重复获取**此锁的（`state` 会累加），这就是可重入的概念。但要注意，获取多少次就要释放多少次，这样才能保证 state 是能回到零态的。
    
    再以 `CountDownLatch` 以例，任务分为 N 个子线程去执行，`state` 也**初始化为 N**（注意 N 要与线程个数一致）。这 **N 个子线程是并行执行**的，每个子线程执行完后`countDown()` 一次，**state 会 CAS(Compare and Swap) 减 1**。等到**所有子线程都执行完后(即 `state=0` )**，会 **`unpark()` 主调用线程**，然后**主调用线程**就会**从 `await()` 函数**返回，继续后余动作。


​    
- AQS对资源的共享方式

  - 包括Exclusive（独占，**只有一个线程**能执行，如ReentrantLock）和Share（共享，**多个线程**可同时执行，如`Semaphore`/`CountDownLatch`）  

    > 从另一个角度讲，就是**只有一个**线程能操作**state**变量以及**有n个线程**能操作**state变量**的区别  
    >
  > 一般来说，自定义同步器的共享方式**要么是独占**，**要么是共享**，他们也只需实现**`tryAcquire-tryRelease`**、**`tryAcquireShared-tryReleaseShared`**中的一种即可。但 AQS 也支持自定义同步器**同时实现独占**和**共享**两种方式，如**`ReentrantReadWriteLock`**。
  
- 自定义同步器
    同步器的设计是基于**模板方法模式**的，如果需要**自定义同步器**一般的方式是这样（模板方法模式很经典的一个应用）：

    1. 使用者继承 **`AbstractQueuedSynchronizer`** 并**重写**指定的方法。【**使用者**】
    2. 将 **AQS 组合**在**自定义同步组件的实现**中，并**调用其模板方法**，而这些模板方法会**调用使用者重写**的方法。【**AQS内部**】

    这和我们以往通过实现接口的方式有很大区别，这是模板方法模式很经典的一个运用。  

    ```java
    //独占方式。尝试获取资源，成功则返回true，失败则返回false。
    protected boolean tryAcquire(int)
    //独占方式。尝试释放资源，成功则返回true，失败则返回false。
    protected boolean tryRelease(int)
    //共享方式。尝试获取资源。负数表示失败；0表示成功，但没有剩余可用资源；正数表示成功，且有剩余资源。
    protected int tryAcquireShared(int)
    //共享方式。尝试释放资源，成功则返回true，失败则返回false。
    protected boolean tryReleaseShared(int)
    //该线程是否正在独占资源。只有用到condition才需要去实现它。
    protected boolean isHeldExclusively() 
    ```

    **什么是钩子方法呢？** 钩子方法是一种**被声明在抽象类中的方法**，一般使用 `protected` 关键字修饰，它**可以是空方法（由子类实现）**，**也可以是默认**实现的方法。模板设计模式**通过钩子方法控制固定步骤**的实现。

    > 篇幅问题，这里就不详细介绍模板方法模式了，不太了解的小伙伴可以看看这篇文章：[用 Java8 改造后的模板方法模式真的是 yyds!open in new window](https://mp.weixin.qq.com/s/zpScSCktFpnSWHWIQem2jg)。
    >
    > 除了上面提到的钩子方法之外，**AQS 类中的其他方法都是 `final`** ，所以**无法被其他类重写**。

# 常见同步类

## Semaphore

Semaphore（信号量）可以指定多个线程同时访问某个资源  

```java
/**
 *
 * @author Snailclimb
 * @date 2018年9月30日
 * @Description: 需要一次性拿一个许可的情况
 */
public class SemaphoreExample1 {
  // 请求的数量
  private static final int threadCount = 550;

  public static void main(String[] args) throws InterruptedException {
    // 创建一个具有固定线程数量的线程池对象（如果这里线程池的线程数量给太少的话你会发现执行的很慢）
    ExecutorService threadPool = Executors.newFixedThreadPool(300);
    // 一次只能允许执行的线程数量。
    final Semaphore semaphore = new Semaphore(20);

    for (int i = 0; i < threadCount; i++) {
      final int threadnum = i;
      threadPool.execute(() -> {// Lambda 表达式的运用
        try {
          //通行证发了20个之后，就不能再发放了
          semaphore.acquire();// 获取一个许可，所以可运行线程数量为20/1=20
          test(threadnum);
          semaphore.release();// 释放一个许可
        } catch (InterruptedException e) {
          // TODO Auto-generated catch block
          e.printStackTrace();
        }

      });
    }
    threadPool.shutdown();
    System.out.println("finish");
  }

  //拿了通行证之后，处理2s钟后才释放
  public static void test(int threadnum) throws InterruptedException {
    Thread.sleep(1000);// 模拟请求的耗时操作
    System.out.println("threadnum:" + threadnum);
    Thread.sleep(1000);// 模拟请求的耗时操作
  }
} 
```

//另一个例子

```java
    public static void main(String[] args) throws InterruptedException{
        AtomicInteger atomicInteger=new AtomicInteger();
        ExecutorService executorService = Executors.newCachedThreadPool();
        Semaphore semaphore=new Semaphore(3);
        for(int i=0;i<8;i++) {
            int finalI = i;
            executorService.submit(()->{
                try {
                    semaphore.acquire();
                    int i1 = atomicInteger.incrementAndGet();
                    log.info("获取一个通行证"+ finalI); 
                    TimeUnit.SECONDS.sleep(finalI+1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }finally {
                    log.info("通行证"+ finalI +"释放完毕");
                    semaphore.release();
                }

            });
        }
        log.info("全部获取完毕");
        //这个方法不会导致线程立即结束
        executorService.shutdown();
        log.info("线程池shutdown");
    }
/* 结果
2022-12-01 14:21:31 下午 [Thread: pool-1-thread-3] 
INFO:获取一个通行证2
2022-12-01 14:21:31 下午 [Thread: main] 
INFO:全部获取完毕
2022-12-01 14:21:31 下午 [Thread: main] 
INFO:线程池shutdown
2022-12-01 14:21:31 下午 [Thread: pool-1-thread-2] 
INFO:获取一个通行证1
2022-12-01 14:21:31 下午 [Thread: pool-1-thread-1] 
INFO:获取一个通行证0
2022-12-01 14:21:32 下午 [Thread: pool-1-thread-1] 
INFO:通行证0释放完毕
2022-12-01 14:21:32 下午 [Thread: pool-1-thread-4] 
INFO:获取一个通行证3
2022-12-01 14:21:33 下午 [Thread: pool-1-thread-2] 
INFO:通行证1释放完毕
2022-12-01 14:21:33 下午 [Thread: pool-1-thread-5] 
INFO:获取一个通行证4
2022-12-01 14:21:34 下午 [Thread: pool-1-thread-3] 
INFO:通行证2释放完毕
2022-12-01 14:21:34 下午 [Thread: pool-1-thread-6] 
INFO:获取一个通行证5
2022-12-01 14:21:36 下午 [Thread: pool-1-thread-4] 
INFO:通行证3释放完毕
2022-12-01 14:21:36 下午 [Thread: pool-1-thread-7] 
INFO:获取一个通行证6
2022-12-01 14:21:38 下午 [Thread: pool-1-thread-5] 
INFO:通行证4释放完毕
2022-12-01 14:21:38 下午 [Thread: pool-1-thread-8] 
INFO:获取一个通行证7
2022-12-01 14:21:40 下午 [Thread: pool-1-thread-6] 
INFO:通行证5释放完毕
2022-12-01 14:21:43 下午 [Thread: pool-1-thread-7] 
INFO:通行证6释放完毕
2022-12-01 14:21:46 下午 [Thread: pool-1-thread-8] 
INFO:通行证7释放完毕

Process finished with exit code 0

如上所示，先是获取了210，之后释放一个获取一个(最多获取3个)，
3+n*2 =10 ，之后陆续释放0获取3，释放1获取4，释放2获取5
之后 释放3获取6，释放4获取7；
这是还有5,7,6拿着通行证
之后随机将5，7，6释放掉即可。 
*/
```

//如上，shutdown不会立即停止，而是：  

1. 线程池shutdown之后不再接收新任务

2. sutdown只是**将线程池的状态设置为SHUTWDOWN**状态，**正在执行的任务会继续执行下去**，**没有被执行的则中断**。而shutdownNow则是将线程池的状态设置为STOP，**正在执行的任务则被停止，没被执行任务的则返回**。如果是shutdownNow,则会报这个问题 

    ```java
    java.lang.InterruptedException: sleep interrupted
      	at java.lang.Thread.sleep(Native Method)
      	at java.lang.Thread.sleep(Thread.java:340)
      	at java.util.concurrent.TimeUnit.sleep(TimeUnit.java:386)
      	at com.ly.SemaphoreExample2.lambda$main$0(SemaphoreExample2.java:45)
      	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
      	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
      	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
      	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
      	at java.lang.Thread.run(Thread.java:748)
    ```

    解释最上面的例子：  

   1. 执行acquire()方法会导致阻塞，直到有一个许可证可以获得然后拿走一个许可证
   2. 每个**release()**方法**增加**一个许可证，这**可能会释放一个阻塞的acquire()**方法
   3. Semaphore只是维持了一个可以获得许可证的数量，**没有实际的许可证这个对象**
   4. Semaphore经常用于**限制获取某种资源的线程数量**

   > 可以一次性获取或释放多个许可，不过没必要
   >
   > ```java
   > semaphore.acquire(5);// 获取5个许可，所以可运行线程数量为20/5=4
   > test(threadnum);
   > semaphore.release(5);// 释放5个许可
   > ```

   除了 `acquire()` 方法之外，另一个比较常用的与之对应的方法是 **`tryAcquire()`** 方法，该方法如果获取不到许可就立即返回 false

- **介绍**

  **`synchronized`** 和 **`ReentrantLock`** 都是**一次只允许一个线程访问某个资源**，而`Semaphore`(信号量)可以用来**控制同时访问特定资源的线程数量**。  
  Semaphore 的使用简单，我们这里**假设有 N(N>5) 个线程来获取 `Semaphore` 中的共享资源**，下面的代码表示**同一时刻 N 个线程中只有 5 个线程能获取到共享资源**，其他线程都会**阻塞**，只有**获取到共享资源的线程才能执行**。等到有线程**释放**了共享资源，其他阻塞的线程才能获取到。  

    ```java
    // 初始共享资源数量
    final Semaphore semaphore = new Semaphore(5);
    // 获取1个许可
    semaphore.acquire();
    // 释放1个许可
    semaphore.release(); 

    /*
    当初始的资源个数为 1 的时候，Semaphore 退化为排他锁。
    */
    ```

- Semaphore有两种模式，**公平模式**和**非公平模式**
  - 公平模式：调用acquire()方法的顺序，就是获取许可证的顺序，遵循FIFO
  - 非公平模式：抢占式的  

  两个构造函数，**必须提供许可数量**，第二个构造方法可以指定是公平模式还是非公平模式，**默认非公平模式**

    ```java
       public Semaphore(int permits) {
            sync = new NonfairSync(permits);
        }

        public Semaphore(int permits, boolean fair) {
            sync = fair ? new FairSync(permits) : new NonfairSync(permits);
        } 
    ```

    > `Semaphore` 通常用于那些**资源有明确访问数量限制**的场景比如限流（**仅限于单机模式**，实际项目中推荐使用 **Redis +Lua** 来做限流）

- 原理   
  `Semaphore` 是共享锁的一种实现，它**默认构造 AQS 的 `state` 值为 `permits`**，你可以将 `permits` 的值理解为**许可证的数量**，只有拿到许可证的线程才能执行。

  1. 调用`semaphore.acquire()` ，线程尝试获取许可证，**如果 `state >= 0`** 的话，则表示可以获取成功。如果获取成功的话，使用 **CAS 操作去修改 `state` 的值 `state=state-1`**。如果 **`state<0`** 的话，则表示许可证数量不足。此时会**创建一个 Node 节点加入阻塞队列**，挂起当前线程。

      ```java
      /**
       *  获取1个许可证
       */
      public void acquire() throws InterruptedException {
         sync.acquireSharedInterruptibly(1);
      }
      /**
       * 共享模式下获取许可证，获取成功则返回，失败则加入阻塞队列，挂起线程
       */
      public final void acquireSharedInterruptibly(int arg)
          throws InterruptedException {
          if (Thread.interrupted())
            throw new InterruptedException();
              // 尝试获取许可证，arg为获取许可证个数，当可用许可证数减当前获取的许可证数结果小于0,则创建一个节点加入阻塞队列，挂起当前线程。
          if (tryAcquireShared(arg) < 0)
            doAcquireSharedInterruptibly(arg);
      } 
      ```

  2. 调用`semaphore.release();` ，线程尝试释放许可证，并使用 CAS 操作去修改 `state` 的值 `state=state+1`。释放许可证成功之后，同时会**唤醒同步队列中的一个线程**。被唤醒的线程会重新尝试去修改 `state` 的值 `state=state-1` ，如果 `state>=0` 则获取令牌成功，否则重新进入阻塞队列，挂起线程。  

      ```java
    // 释放一个许可证
      public void release() {
        	sync.releaseShared(1);
      }
      
      // 释放共享锁，同时会唤醒同步队列中的一个线程。
      public final boolean releaseShared(int arg) {
          //释放共享锁
          if (tryReleaseShared(arg)) {
            //唤醒同步队列中的一个线程
            doReleaseShared();
            return true;
          }
          return false;
      } 
      ```
  
- 补充  

  > `Semaphore` 与 `CountDownLatch` 一样，也是共享锁的一种实现。它默认构造 AQS 的 `state` 为 `permits`。当**执行任务的线程数量超出 `permits`**，那么**多余的线程将会被放入阻塞队列 `Park`**,并自旋判断 `state` 是否大于 0。只有**当 `state` 大于 0 的时候，阻塞的线程才能继续执行**,此时先前执行任务的线程继续执行 **`release()` 方法，`release()` 方法使得 state 的变量会加 1**，那么自旋的线程便会判断成功。 如此，**每次只有最多不超过 `permits` 数量的线程能自旋成功**，**便限制了**执行任务线程的数量。

## CountDownLatch(倒计时)

- ```CountDown 倒计时器；Latch 门闩 ```
  - 允许count个线程阻塞在一个地方，直至所有线程的任务都执行完毕
  - `CountDownLatch` 是**一次性**的，计数器的值**只能**在构造方法中**初始化一次**，之后**没有任何机制再次对其设置值**，当 `CountDownLatch` 使用完毕后，它不能再次被使用。
- 原理
  - CountDownLatch是共享锁的一种实现（**我的理解是 本质上是说AQS内部的state变量可以被多个线程同时修改，所以是"共享"**），默认构造AQS的state值为count。当线程使用countDown()方法时，其实是使用了tryReleaseShared方法以CAS操作来减少state，直至state为0
  - 当**调用await()**方法时，**如果state不为0**，那就证明任务还没有执行完毕,await()方法会**一直阻塞**，即await()方法之后的语句不会被执行。**之后**CountDownLatch会自旋CAS判断state==0，如果**state == 0就会释放所有等待线程**，await()方法之后的语句得到执行

### CountDownLatch的两种典型用法

   **其实就是n个线程等待其他m个线程执行完毕后唤醒，只有n为1时是第一种情况，只有m为1时是第二种情况**  


1. **某线程在开始运行前等待n个线程执行完毕**

   > 将 `CountDownLatch` 的计数器初始化为 n （**`new CountDownLatch(n)`**），每**当一个任务线程执行完毕**，就将计数器减 1 （**`countdownlatch.countDown()`**），当计数器的值**变为 0** 时，在 **`CountDownLatch 上 await()` 的线程就会被唤醒**。一个典型应用场景就是启动一个服务时，主线程需要等待多个组件加载完毕，之后再继续执行。

2. 实现多个线程开始执行任务的**最大并行性**
   
> 注意是并行性，不是并发，强调的是多个线程在某一时刻同时开始执行。类似于赛跑，将多个线程放到起点，等待发令枪响，然后同时开跑。  
   > 做法是初始化一个共享的 `CountDownLatch` 对象，将其计数器初始化为 1 （`new CountDownLatch(1)`），**多个线程在开始执行任务前首先 `coundownlatch.await()`**，当主线程调用 `countDown()` 时，计数器变为 0，**多个线程同时被唤醒**。

CountDownLatch使用示例  

300个线程(说的是线程池有300个**核心线程**，而**不是CountDown300次**)，550个请求（及count = 550）。启动线程后，主线程阻塞。当所有请求都countDown，主线程恢复运行

```java
/**
 *
 * @author SnailClimb
 * @date 2018年10月1日
 * @Description: CountDownLatch 使用方法示例
 */
public class CountDownLatchExample1 {
  // 请求的数量
  private static final int threadCount = 550;

  public static void main(String[] args) throws InterruptedException {
    // 创建一个具有固定线程数量的线程池对象（如果这里线程池的线程数量给太少的话你会发现执行的很慢）
    ExecutorService threadPool = Executors.newFixedThreadPool(300);
    final CountDownLatch countDownLatch = new CountDownLatch(threadCount);
    for (int i = 0; i < threadCount; i++) {
      final int threadnum = i;
      threadPool.execute(() -> {// Lambda 表达式的运用
        try {
          test(threadnum);
        } catch (InterruptedException e) {
          // TODO Auto-generated catch block
          e.printStackTrace();
        } finally {
          countDownLatch.countDown();// 表示一个请求已经被完成
        }

      });
    }
    countDownLatch.await();
    threadPool.shutdown();
    System.out.println("finish");
  }

  public static void test(int threadnum) throws InterruptedException {
    Thread.sleep(1000);// 模拟请求的耗时操作
    System.out.println("threadnum:" + threadnum);
    Thread.sleep(1000);// 模拟请求的耗时操作
  }
} 
```

- 与CountDownLatch的第一次交互是主线程等待其他线程

- 主线程必须在启动其他线程后立即调用CountDownLatch.await()方法，这样主线程的操作就会在这个方法阻塞，直到其他线程完成各自任务

-  其他 N 个线程**必须引用闭锁对象（说的是CountDownLoatch对象）**，因为他们需要通知 `CountDownLatch` 对象，他们已经完成了各自的任务。这种通知机制是通过 `CountDownLatch.countDown()`方法来完成的；**每调用**一次这个方法，在构造函数中初始化的 **count 值就减 1**。所以**当 N 个线程都调 用**了这个方法，count 的值等于 0，然后**主线程就能通过 `await()`方法**，**恢复**执行自己的任务。

- `CountDownLatch` 的 `await()` 方法使用不当很容易产生死锁，比如我们上面代码中的 for 循环改为：

  ```java
  for (int i = 0; i < threadCount-1; i++) {
  .......
  }
  //这样就导致 count 的值没办法等于 0（最终为1），然后就会导致一直等待。
  ```

### CountDownLatch 的不足

**`CountDownLatch` 是一次性的**，计数器的值只能在构造方法中初始化一次，之后没有任何机制再次对其设置值，当 `CountDownLatch` **使用完毕后，它不能再次被使用**。

### CountDownLatch 相常见面试题（改版后没了）

- `CountDownLatch` 怎么用？应用场景是什么？
- `CountDownLatch` 和 `CyclicBarrier` 的不同之处？
- `CountDownLatch` 类中主要的方法？

## CyclicBarrier

- CyclicBarrier和CountDownLatch类似，可以实现线程间的技术等待，主要应用场景和CountDownLatch类似，但更复杂强大 主要应用场景和 `CountDownLatch` 类似。

  > CountDownLatch基于**AQS**，而CycliBarrier基于**ReentrantLock**（ReentrantLock属于AQS同步器）和**Condition**
- `CyclicBarrier` 的字面意思是**可循环**使用（Cyclic）的屏障（Barrier）。它要做的事情是：让**一组线程(中的一个)到达一个屏障（也可以叫同步点）时**被阻塞，直到**最后一个线程到达屏障**时，**屏障才会开门**，所有被屏障拦截的线程才会继续干活。
- `CyclicBarrier` 默认的构造方法是 `CyclicBarrier(int parties)`，其参数表示屏障拦截的线程数量，每个线程调用 `await()` 方法**告诉 `CyclicBarrier` 我已经到达了屏障，然后当前线程被阻塞**。

```java
/**
 *
 * @author Snailclimb
 * @date 2018年10月1日
 * @Description: 测试 CyclicBarrier 类中带参数的 await() 方法
 */
public class CyclicBarrierExample2 {
  // 请求的数量
  private static final int threadCount = 550;
  // 需要同步的线程数量
  private static final CyclicBarrier cyclicBarrier = new CyclicBarrier(5);

  public static void main(String[] args) throws InterruptedException {
    // 创建线程池
    ExecutorService threadPool = Executors.newFixedThreadPool(10);

    for (int i = 0; i < threadCount; i++) {
      final int threadNum = i;
      Thread.sleep(1000); ///注意这行
      threadPool.execute(() -> {
        try {
          test(threadNum);
        } catch (InterruptedException e) {
          // TODO Auto-generated catch block
          e.printStackTrace();
        } catch (BrokenBarrierException e) {
          // TODO Auto-generated catch block
          e.printStackTrace();
        }
      });
    }
    threadPool.shutdown();
  }

  public static void test(int threadnum) throws InterruptedException, BrokenBarrierException {
    System.out.println("threadnum:" + threadnum + "is ready");
    try {
      /**等待60秒，保证子线程完全执行结束*/
      //如果等待的时间，超过了60秒，那么就会抛出异常，而且还会进行重置(变为0个线程再等待)
      cyclicBarrier.await(60, TimeUnit.SECONDS);
      //最后一个(第5个到达后，count会重置为0)
    } catch (Exception e) {
      System.out.println("-----CyclicBarrierException------");
    }
    System.out.println("threadnum:" + threadnum + "is finish");
  }

}
/* 结果
 threadnum:0is ready
threadnum:1is ready
threadnum:2is ready
threadnum:3is ready
threadnum:4is ready
threadnum:4is finish
threadnum:0is finish
threadnum:1is finish
threadnum:2is finish
threadnum:3is finish
threadnum:5is ready
threadnum:6is ready
threadnum:7is ready
threadnum:8is ready
threadnum:9is ready
threadnum:9is finish
threadnum:5is finish
threadnum:8is finish
threadnum:7is finish
threadnum:6is finish
...... 
*/

//注意这里，如果把Thread.sleep(1000)去掉，顺序(情况之一)为：
//也就是说，上面的代码，导致的现象：所有的ready都挤在一起了(而且不分先后，随时执行，而某5个的finish，会等待那5个的ready执行完才会执行，且finish没有顺序的)
//★如上，ready也是没有顺序的
/*threadnum:0is ready
threadnum:5is ready
threadnum:9is ready
threadnum:7is ready
threadnum:3is ready
threadnum:8is ready
threadnum:4is ready
threadnum:2is ready
threadnum:1is ready
threadnum:6is ready
------当线程数达到之后，优先执行------
threadnum:3is finish
threadnum:10is ready
------当线程数达到之后，优先执行------
threadnum:10is finish
threadnum:11is ready
threadnum:0is finish
threadnum:5is finish
threadnum:4is finish
threadnum:1is finish
threadnum:8is finish
threadnum:12is ready
threadnum:9is finish
threadnum:7is finish
threadnum:16is ready
threadnum:15is ready
------当线程数达到之后，优先执行------
threadnum:14is ready
threadnum:6is finish
threadnum:13is ready
threadnum:2is finish
threadnum:19is ready
threadnum:16is finish
threadnum:12is finish
threadnum:18is ready
threadnum:11is finish
threadnum:23is ready
------当线程数达到之后，优先执行------
threadnum:17is ready
threadnum:19is finish
threadnum:15is finish
threadnum:25is ready
threadnum:24is ready
threadnum:18is finish
threadnum:26is ready
threadnum:13is finish
threadnum:14is finish
threadnum:23is finish
threadnum:22is ready
threadnum:21is ready
threadnum:20is ready
------当线程数达到之后，优先执行------
threadnum:29is ready
threadnum:28is ready
threadnum:27is ready
threadnum:22is finish
threadnum:24is finish
threadnum:25is finish
threadnum:32is ready
.....

*/
```

在看一个例子：

```java
public class BarrierTest1 {
    public static void main(String[] args) throws InterruptedException, TimeoutException, BrokenBarrierException {

        CyclicBarrier cyclicBarrier = new CyclicBarrier(3);
        ExecutorService executorService = Executors.newFixedThreadPool(10);
        executorService.submit(() -> {
            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            try {
                cyclicBarrier.await( );
                System.out.println("数量11===="+cyclicBarrier.getNumberWaiting());
                System.out.println("111");
            } catch (Exception e) {
                System.out.println("数量异常1111==="+cyclicBarrier.getNumberWaiting());
                // e.printStackTrace();
                System.out.println("报错1");
            }

        });
        executorService.submit(() -> {
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            try {
                System.out.println("数量2222===="+cyclicBarrier.getNumberWaiting());
                cyclicBarrier.await(111,TimeUnit.SECONDS);
                System.out.println("222");
            } catch (Exception e) {
                System.out.println("数量异常2222===="+cyclicBarrier.getNumberWaiting());
                System.out.println("报错2");
            }
        });
        executorService.submit(() -> {
            try {
                TimeUnit.SECONDS.sleep(10);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            try {
                System.out.println("数量33 await前===="+cyclicBarrier.getNumberWaiting());
                cyclicBarrier.await();
                System.out.println("数量33 await后===="+cyclicBarrier.getNumberWaiting());
                System.out.println("333");
            } catch (Exception e) {
                System.out.println("数量异常333===="+cyclicBarrier.getNumberWaiting());
                System.out.println("报错3");
            }
        });
    }
}
/*
 数量2222====1
数量33 await前====2
数量33 await后====0
333
数量11====0
111
222
*/
```

### CyclicBarrier源码分析

- 当调用CyclicBarrier对象调用await() 方法时，实际上调用的是dowait(false,0L )方法【主要用到false】

  > `await()` 方法就像树立起一个栅栏的行为一样，将线程挡住了，当拦住的线程数量达到 `parties` 的值时，栅栏才会打开，线程才得以通过执行。

  ```java
  public int await() throws InterruptedException, BrokenBarrierException {
    try {
      	return dowait(false, 0L);
    } catch (TimeoutException toe) {
     	 throw new Error(toe); // cannot happen
    }
  } 
  ```

- dowait(false,0L)方法

  ```java
     // 当线程数量或者请求数量达到 count 时 await 之后的方法才会被执行。上面的示例中 count 的值就为 5。
      private int count;
      /**
       * Main barrier code, covering the various policies.
       */
      private int dowait(boolean timed, long nanos)
          throws InterruptedException, BrokenBarrierException,
                 TimeoutException {
          final ReentrantLock lock = this.lock;
          // 锁住
          lock.lock();
          try {
              final Generation g = generation;
  
              if (g.broken)
                  throw new BrokenBarrierException();
  
              // 如果线程中断了，抛出异常
              if (Thread.interrupted()) {
                  breakBarrier();
                  throw new InterruptedException();
              }
              // cout减1  //★前面锁住了，所以不需要CAS
              int index = --count;
              //★★ 当 count 数量减为 0 之后说明最后一个线程已经到达栅栏了，也就是达到了可以执行await 方法之后的条件
              if (index == 0) {  // tripped
                  boolean ranAction = false;
                  try {
                      final Runnable command = barrierCommand;
                      if (command != null)
                          command.run();
                      ranAction = true;
                      // 将 count 重置为 parties 属性的初始化值
                      // 唤醒之前等待的线程
                      // 下一波执行开始
                      nextGeneration();
                      return 0;
                  } finally {
                      if (!ranAction)
                          breakBarrier();
                  }
              }
  
              // loop until tripped, broken, interrupted, or timed out
              for (;;) {
                  try {
                      if (!timed)
                          trip.await();
                      else if (nanos > 0L)
                          nanos = trip.awaitNanos(nanos);
                  } catch (InterruptedException ie) {
                      if (g == generation && ! g.broken) {
                          breakBarrier();
                          throw ie;
                      } else {
                          // We're about to finish waiting even if we had not
                          // been interrupted, so this interrupt is deemed to
                          // "belong" to subsequent execution.
                          Thread.currentThread().interrupt();
                      }
                  }
  
                  if (g.broken)
                      throw new BrokenBarrierException();
  
                  if (g != generation)
                      return index;
  
                  if (timed && nanos <= 0L) {
                      breakBarrier();
                      throw new TimeoutException();
                  }
              }
          } finally {
              lock.unlock();
          }
      } 
  ```

  > 总结：`CyclicBarrier` 内部通过一个 count 变量作为计数器，count 的初始值为 parties 属性的初始化值，每当一个线程到了栅栏这里了，那么就将计数器减一。如果 count 值为 0 了，表示这是这一代最后一个线程到达栅栏，就尝试执行我们构造方法中输入的任务
  >
  > ------
  >
  > 著作权归所有 原文链接：https://javaguide.cn/java/concurrent/aqs.html

## CyclicBarrier和CountDownLatch区别

1. `CountDownLatch` 是计数器，只能使用一次，而 `CyclicBarrier` 的计数器提供 `reset` 功能，可以多次使用。

2. 从jdk作者设计的目的来看，javadoc是这么描述他们的

   > CountDownLatch: A synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes.(CountDownLatch: 一个或者多个线程，等待其他多个线程完成某件事情之后才能执行；) CyclicBarrier : A synchronization aid that allows a set of threads to all wait for each other to reach a common barrier point.(CyclicBarrier : 多个线程互相等待，直到到达同一个同步点，再继续一起执行。)
   >
   > **需要结合上面的代码示例，CyclicBarrier示例是这个意思**

3. 对于 `CountDownLatch` 来说，重点是“一个线程（多个线程）等待”，而其他的 N 个线程在完成“某件事情”之后，可以终止，也可以等待。【强调的是某个(组)等另一组线程完成】  
   而对于 `CyclicBarrier`，重点是多个线程，在任意一个线程没有完成，所有的线程都必须等待。【强调的是互相】

4. `CountDownLatch` 是**计数器**，线程完成一个记录一个，只不过计数不是递增而是递减，而 `CyclicBarrier` 更像是一个**阀门**，需要所有线程都到达，阀门才能打开，然后继续执行。

## ReentrantLock和ReentrantReadWriteLock

读写锁 `ReentrantReadWriteLock` 可以保证**多个线程可以同时读**，所以在**读操作远大于写操作的时候**，读写锁就非常有用了。