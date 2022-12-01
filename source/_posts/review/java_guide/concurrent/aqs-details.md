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
updated: 2022-11-30 14:48:01
---

> 转载自https://github.com/Snailclimb/JavaGuide

```Semaphore  [ˈseməfɔː(r)]```

> - 何为 AQS？AQS 原理了解吗？
> - `CountDownLatch` 和 `CyclicBarrier` 了解吗？两者的区别是什么？
> - 用过 `Semaphore` 吗？应用场景了解吗？
> - ......

# AQS简单介绍

AQS,AbstractQueueSyschronizer，即抽象队列同步器，这个类在java.util.concurrent.locks包下面

![image-20221130154309546](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221130154309546.png)

AQS是一个抽象类，主要用来构建锁和同步器

```java
public abstract class AbstractQueuedSynchronizer extends AbstractOwnableSynchronizer implements java.io.Serializable {
} 
```

AQS **为构建锁和同步器提供了一些通用功能**的是实现，因此，使用 AQS 能简单且高效地**构造出应用广泛的大量的同步器**，比如我们提到的 **`ReentrantLock`**，**`Semaphore`**，其他的诸如 `ReentrantReadWriteLock`，`SynchronousQueue`，`FutureTask`(jdk1.7) 等等皆是基于 AQS 的。

# AQS原理

**面试不是背题，大家一定要加入自己的思想，即使加入不了自己的思想也要保证自己能够通俗的讲出来而不是背出来**

AQS 核心思想是，如果被请求的共享资源空闲，则将当前请求资源的线程设置为有效的工作线程，并且将共享资源设置为锁定状态。如果被请求的共享资源被占用，那么就需要一套线程阻塞等待以及被唤醒时锁分配的机制，这个机制 AQS 是用 **CLH 队列锁**实现的，即**将暂时获取不到锁的线程加入到队列**中。 

  > CLH(Craig,Landin and Hagersten)队列是一个**虚拟的双向队列**（虚拟的双向队列即不存在队列实例，仅存在结点之间的关联关系）。AQS 是**将每条请求共享资源的线程封装成一个 CLH 锁队列的一个结点**（Node）来实现锁的分配。
  > 搜索了一下，CLH好像是人名

- AQS（AbstractQueuedSynchronized）原理图   
    ![image-20221120193141243](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221120193141243.png)

  AQS使用一个**int成员变量来表示同步状态**，通过内置的FIFO队列来获取资源线程的排队工作。AQS**使用CAS对同步状态进行原子操作**并实现对其值的修改

  ```java
  private volatile int state;//共享变量，使用volatile修饰保证线程可见性
  ```

  状态信息的操作  

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

- AQS对资源的共享方式

  - 包括Exclusive（独占）和Share（共享）

  - Exclusive（独占）
    **只有一个线程能执行，如ReentrantLock，又分为公平锁和非公平锁**，Reentrant同时支持两种所，定义：  

    - 公平锁：按照线程在队列中的排队顺序，先到者先拿到锁

      ```java
      //例子
         public void tt() throws InterruptedException {
              Lock reLock=new ReentrantLock();
              //reLock.lock();
              for(int i=0;i<100;i++){
                  int finalI = i;
                  new Thread(()->{
                      reLock.lock();
                      try {
                          log.info("线程标志"+finalI+"即将停止5s");
                          TimeUnit.SECONDS.sleep(5);
                          log.info("线程标志"+finalI+"停止结束");
                      } catch (InterruptedException e) {
                          e.printStackTrace();
                      }
                      reLock.unlock();
                  }).start();
                  TimeUnit.SECONDS.sleep(1);
              }
              while (true){}
          }
      /* 结果
      2022-11-30 17:27:31 下午 [Thread: Thread-1] 
      INFO:线程标志0即将停止10s
      2022-11-30 17:27:41 下午 [Threa2022-12-01 10:19:50 上午 [Thread: Thread-1] 
      INFO:线程标志0即将停止5s
      2022-12-01 10:19:55 上午 [Thread: Thread-1] 
      INFO:线程标志0停止结束
      2022-12-01 10:19:55 上午 [Thread: Thread-2] 
      INFO:线程标志1即将停止5s
      2022-12-01 10:20:00 上午 [Thread: Thread-2] 
      INFO:线程标志1停止结束
      2022-12-01 10:20:00 上午 [Thread: Thread-3] 
      INFO:线程标志2即将停止5s
      2022-12-01 10:20:05 上午 [Thread: Thread-3] 
      INFO:线程标志2停止结束
      2022-12-01 10:20:05 上午 [Thread: Thread-4] 
      INFO:线程标志3即将停止5s
      2022-12-01 10:20:10 上午 [Thread: Thread-4] 
      INFO:线程标志3停止结束
      2022-12-01 10:20:10 上午 [Thread: Thread-5] 
      INFO:线程标志4即将停止5s
      2022-12-01 10:20:15 上午 [Thread: Thread-5] 
      INFO:线程标志4停止结束
      2022-12-01 10:20:15 上午 [Thread: Thread-6] 
      INFO:线程标志5即将停止5s
      2022-12-01 10:20:20 上午 [Thread: Thread-6] 
      INFO:线程标志5停止结束
      2022-12-01 10:20:20 上午 [Thread: Thread-7] 
      INFO:线程标志6即将停止5s
      2022-12-01 10:20:25 上午 [Thread: Thread-7] 
      INFO:线程标志6停止结束
      2022-12-01 10:20:25 上午 [Thread: Thread-8] 
      INFO:线程标志7即将停止5s
       
      */
      ```
      
      
      
    - 非公平锁：当线程要获取锁时，**先通过两次CAS操作去抢锁**，如果没抢到，当前线程**再加入到队列**中等待唤醒
      **注意这个逻辑，所以其实不好测试**
    
  - **`ReentrantLock` 中相关的源代码**
    ReentrantLock默认采用非公平锁，考虑获得更好的性能，通过boolean决定是否用公平锁（传入true用公平锁）
  
    ```java
    /** Synchronizer providing all implementation mechanics */
  private final Sync sync;
    public ReentrantLock() {
      // 默认非公平锁
        sync = new NonfairSync();
  }
    public ReentrantLock(boolean fair) {
        sync = fair ? new FairSync() : new NonfairSync();
  } 
    ```
  
    ReentrantLock中公平锁的lock方法
    
    ```java
    static final class FairSync extends Sync {
        final void lock() {
            acquire(1);
        }
        // AbstractQueuedSynchronizer.acquire(int arg)
        public final void acquire(int arg) {
            if (!tryAcquire(arg) &&
                acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
                selfInterrupt();
        }
        protected final boolean tryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            if (c == 0) {
                // 1. 和非公平锁相比，这里多了一个判断：是否有线程在等待
                if (!hasQueuedPredecessors() &&
                    compareAndSetState(0, acquires)) {
                    setExclusiveOwnerThread(current);
                    return true;
                }
            }
            else if (current == getExclusiveOwnerThread()) {
                int nextc = c + acquires;
                if (nextc < 0)
                    throw new Error("Maximum lock count exceeded");
                setState(nextc);
                return true;
            }
            return false;
        }
    }
    ```
    
    ReentrantLock中非公平锁的方法
    
    ```java
    static final class NonfairSync extends Sync {
        final void lock() {
            // 2. 和公平锁相比，这里会直接先进行一次CAS，成功就返回了
            if (compareAndSetState(0, 1))
                setExclusiveOwnerThread(Thread.currentThread());
            else
                acquire(1);
        }
        // AbstractQueuedSynchronizer.acquire(int arg)
        public final void acquire(int arg) {
            if (!tryAcquire(arg) &&
                acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
                selfInterrupt();
        }
        protected final boolean tryAcquire(int acquires) {
            return nonfairTryAcquire(acquires);
        }
    }
    /**
     * Performs non-fair tryLock.  tryAcquire is implemented in
     * subclasses, but both need nonfair try for trylock method.
     */
    final boolean nonfairTryAcquire(int acquires) {
        final Thread current = Thread.currentThread();
        int c = getState();
        if (c == 0) {
            // 这里没有对阻塞队列进行判断
            if (compareAndSetState(0, acquires)) {
                setExclusiveOwnerThread(current);
                return true;
            }
        }
        else if (current == getExclusiveOwnerThread()) {
            int nextc = c + acquires;
            if (nextc < 0) // overflow
                throw new Error("Maximum lock count exceeded");
            setState(nextc);
            return true;
        }
        return false;
    } 
    ```
    
    **公平锁和非公平锁的两处不同:** 
    
    1. **非公平锁**在调用 **lock 后**，首先就会**调用 CAS 进行一次抢锁**，如果这个时候**恰巧锁没有被占用，那么直接就获取到锁返回**了。
    2. **非公平锁**在 **CAS 失败**后，和公平锁一样都会进入到 **`tryAcquire`** 方法，在 `tryAcquire` 方法中，**如果发现锁这个时候被释放了（state == 0），非公平锁会直接 CAS 抢锁**，但是**公平锁会判断等待队列是否有线程处于等待状态**，如果有则不去抢锁，乖乖排到后面。
    
    **关键字：非公平锁，公平锁，CAS，等待队列**
    也就是说，非公平锁有一次必须的CAS和(进入acquire)一次非必须的**CAS（锁已经释放则进行）**。而公平锁是直接进入acquire方法，其中先判断state 是否为0，非公平锁直接CAS，若失败则进入队列；而公平锁则会检测等待队列是否有线程处于等待
    
    > 相对来说，非公平锁会有更好的性能，因为它的吞吐量比较大。当然，非公平锁让获取锁的时间变得更加不确定，可能会导致在阻塞队列中的线程长期处于饥饿状态。
    
  - Share(共享)
    多个线程同时执行，如Semaphore/CountDownLatch。Semaphore，CountDownLatch，CyclicBarrier，ReadWriteLock后面会讲
    `ReentrantReadWriteLock` 可以看成是组合式，因为 **`ReentrantReadWriteLock` 也就是读写锁允许多个线程同时对某一资源进行读**。(时而独占，时而共享)
  
  不同的自定义同步器争用共享资源的方式也不同。**自定义同步器在实现时只需要实现共享资源 state 的获取与释放方式即可**，至于**具体线程等待队列的维护（如获取资源失败入队/唤醒出队等），AQS 已经在上层已经帮我们实现**好了。
  
- AQS底层使用了模板方法模式
  使用方式  

  1. 使用者继承AbstractQueueSynchronizer并重写指定方法（**无非是对于共享资源state的获取和释放**）

  2. 将AQS组合在自定义同步组件的实现中，并调用其模板方法，而**这些模板方法会调用使用者重写的方法**

  3. 自定义同步器时，需要重写下面几个AQS提供的钩子方法

     ```java
     protected boolean tryAcquire(int)//独占方式。尝试获取资源，成功则返回true，失败则返回false。
     protected boolean tryRelease(int)//独占方式。尝试释放资源，成功则返回true，失败则返回false。
     protected int tryAcquireShared(int)//共享方式。尝试获取资源。负数表示失败；0表示成功，但没有剩余可用资源；正数表示成功，且有剩余资源。
     protected boolean tryReleaseShared(int)//共享方式。尝试释放资源，成功则返回true，失败则返回false。
     protected boolean isHeldExclusively()//该线程是否正在独占资源。只有用到condition才需要去实现它。 
     ```

  4. **什么是钩子方法呢？** 钩子方法是一种被声明在抽象类中的方法，它可以是空方法（由子类实现），也可以是默认实现的方法。模板设计模式**通过钩子方法控制固定步骤的实现**。AQS类中除了钩子方法，其他方法都是final

  > 重点：以 `ReentrantLock` 为例，state 初始化为 0，表示未锁定状态。A 线程 `lock()` 时，会调用 `tryAcquire()` 独占该锁并将 `state+1` 。此后，其他线程再 `tryAcquire()` 时就会失败，直到 A 线程 `unlock()` 到 `state=`0（即释放锁）为止，其它线程才有机会获取该锁。当然，释放锁之前，A 线程自己是可以重复获取此锁的（state 会累加），这就是可重入的概念。但要注意，获取多少次就要释放多少次，这样才能保证 state 是能回到零态的。
  >
  > 再以 `CountDownLatch` 以例，任务分为 N 个子线程去执行，state 也初始化为 N（注意 N 要与线程个数一致）。这 N 个子线程是并行执行的，每个子线程执行完后` countDown()` 一次，state 会 CAS(Compare and Swap) 减 1。等到所有子线程都执行完后(即 `state=0` )，会 `unpark()` 主调用线程，然后主调用线程就会从 `await()` 函数返回，继续后余动作。
  >
  > 一般来说，自定义同步器要么是独占方法，要么是共享方式，他们也只需实现`tryAcquire-tryRelease`、`tryAcquireShared-tryReleaseShared`中的一种即可。但 AQS 也支持自定义同步器**同时实现独占和共享两种方式，如`ReentrantReadWriteLock`。** 

# Semaphore

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

2. sutdown只是将线程池的状态设置为SHUTWDOWN状态，正在执行的任务会继续执行下去，没有被执行的则中断。而shutdownNow则是将线程池的状态设置为STOP，正在执行的任务则被停止，没被执行任务的则返回。如果是shutdownNow,则会报这个问题 

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

   1. 执行acquire()方法会导致阻塞，知道有一个许可证可以获得然后拿走一个许可证
   2. 每个release()方法增加一个许可证，这可能会释放一个阻塞的acquire()方法
   3. Semaphore只是维持了一个可以获得许可证的数量，**没有实际的许可证这个对象**
   4. Semaphore经常用于**限制获取某种资源的线程数量**

   > 可以一次性获取或释放多个许可，不过没必要
   >
   > ```java
   > semaphore.acquire(5);// 获取5个许可，所以可运行线程数量为20/5=4
   > test(threadnum);
   > semaphore.release(5);// 释放5个许可
   > ```

   对应的使用tryAcquire，如果获取不到许可就立即返回false

Semaphore有两种模式，**公平模式**和**非公平模式**

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

> `Semaphore` 与 `CountDownLatch` 一样，也是共享锁的一种实现。它**默认构造 AQS 的 state 为 `permits`**。当执行任务的线程**数量超出 `permits`，那么多余的线程将会被放入阻塞队列 Park,并自旋判断 state 是否大于 0。只有当 state 大于 0 的时候，阻塞的线程才能继续执行**,此时先前执行任务的线程继续执行 `release()` 方法，**`release()` 方法使得 state 的变量会加 1，那么自旋的线程便会判断成功**。 如此，每次只有最多不超过 `permits` 数量的线程能自旋成功，便限制了执行任务线程的数量。

# CountDownLatch

# CyclicBarrier

