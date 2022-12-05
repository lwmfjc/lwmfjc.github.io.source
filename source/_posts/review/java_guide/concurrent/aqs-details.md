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

# CountDownLatch(倒计时)

- ```翻译：闭锁(倒计时锁) ```
- 允许count个线程阻塞在一个地方，直至所有线程的任务都执行完毕
- CountDownLatch是共享锁的一种实现（**我的理解是await的时候，其他线程可以执行，而不是lock，所以是"共享"**），默认构造AQS的state值为count。当线程使用countDown()方法时，其实是使用了tryReleaseShared方法以CAS操作来减少state，直至state为0
- 当调用await()方法时，如果state不为0，那就证明任务还没有执行完毕,await()方法会一直阻塞，即await()方法之后的语句不会被执行。**之后**CountDownLatch会自旋CAS判断state==0，如果state == 0就会释放所有等待线程，await()方法之后的语句得到执行

## CountDownLatch的两种典型用法

1. 某线程在开始运行前等待n个线程执行完毕

   > 将 `CountDownLatch` 的计数器初始化为 n （**`new CountDownLatch(n)`**），每**当一个任务线程执行完毕**，就将计数器减 1 （**`countdownlatch.countDown()`**），当计数器的值**变为 0** 时，在 **`CountDownLatch 上 await()` 的线程就会被唤醒**。一个典型应用场景就是启动一个服务时，主线程需要等待多个组件加载完毕，之后再继续执行。

2. 实现多个线程开始执行任务的**最大并行性**
   **为什么是最大呢，我觉得是因为即使线程已经start，但是不一定就全部启动了，有可能cpu调度并没有真正启动它**（概率极小）

   > 注意是并行性，不是并发，强调的是多个线程在某一时刻同时开始执行。类似于赛跑，将多个线程放到起点，等待发令枪响，然后同时开跑。做法是初始化一个共享的 `CountDownLatch` 对象，将其计数器初始化为 1 （`new CountDownLatch(1)`），多个线程在开始执行任务前首先 `coundownlatch.await()`，当主线程调用 `countDown()` 时，计数器变为 0，多个线程同时被唤醒。

CountDownLatch使用示例  

300个线程，550个请求（及count = 550）。启动线程后，主线程阻塞。当所有请求都countDown，主线程恢复运行

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

- 其他N个线程必须引用闭锁对象，因为他们需要通知CountDownLatch对象 --已经完成各自任务（通过countDown()），每调用一次该方法count值减1

- 当count值为0时，主线程就能通过await()方法恢复执行自己的任务

- 如果使用不当会造成死锁（count始终不为0），导致一直等待

  ```java
  for (int i = 0; i < threadCount-1; i++) {
  .......
  }
  ```

## CountDownLatch 的不足

**`CountDownLatch` 是一次性的**，计数器的值只能在构造方法中初始化一次，之后没有任何机制再次对其设置值，当 `CountDownLatch` **使用完毕后，它不能再次被使用**。

## CountDownLatch 相常见面试题

- `CountDownLatch` 怎么用？应用场景是什么？
- `CountDownLatch` 和 `CyclicBarrier` 的不同之处？
- `CountDownLatch` 类中主要的方法？

# CyclicBarrier

- CyclicBarrier和CountDownLatch类似，可以实现线程间的技术等待，主要应用场景和CountDownLatch类似，但更复杂强大
- CountDownLatch基于AQS，而CycliBarrier基于ReentrantLock（ReentrantLock属于AQS同步器）和Condition
- `CyclicBarrier` 的字面意思是可循环使用（Cyclic）的屏障（Barrier）。它要做的事情是：让**一组线程(中的一个)到达一个屏障（也可以叫同步点）时**被阻塞，直到**最后一个线程到达屏障**时，**屏障才会开门**，所有被屏障拦截的线程才会继续干活。
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

# CyclicBarrier源码分析

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

# CyclicBarrier和CountDownLatch区别

1. `CountDownLatch` 是计数器，只能使用一次，而 `CyclicBarrier` 的计数器提供 `reset` 功能，可以多次使用。

2. 从jdk作者设计的目的来看，javadoc是这么描述他们的

   > CountDownLatch: A synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes.(CountDownLatch: 一个或者多个线程，等待其他多个线程完成某件事情之后才能执行；) CyclicBarrier : A synchronization aid that allows a set of threads to all wait for each other to reach a common barrier point.(CyclicBarrier : 多个线程互相等待，直到到达同一个同步点，再继续一起执行。)
   >
   > **需要结合上面的代码示例，CyclicBarrier示例是这个意思**

3. 对于 `CountDownLatch` 来说，重点是“一个线程（多个线程）等待”，而其他的 N 个线程在完成“某件事情”之后，可以终止，也可以等待。【强调的是某个(组)等另一组线程完成】  
   而对于 `CyclicBarrier`，重点是多个线程，在任意一个线程没有完成，所有的线程都必须等待。【强调的是互相】

4. `CountDownLatch` 是**计数器**，线程完成一个记录一个，只不过计数不是递增而是递减，而 `CyclicBarrier` 更像是一个**阀门**，需要所有线程都到达，阀门才能打开，然后继续执行。

# ReentrantLock和ReentrantReadWriteLock

读写锁 `ReentrantReadWriteLock` 可以保证**多个线程可以同时读**，所以在**读操作远大于写操作的时候**，读写锁就非常有用了。