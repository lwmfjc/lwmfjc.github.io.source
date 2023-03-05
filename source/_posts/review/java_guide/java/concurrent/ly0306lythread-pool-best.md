---
title: 线程池最佳实践
description: 线程池最佳实践
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-11-29 11:31:20
updated: 2022-11-29 11:31:20
---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 线程池知识回顾

### 1. 为什么要使用线程池

- 池化技术的思想，主要是为了**减少每次获取资源（线程资源）的消耗**，提高对资源的利用率
- 线程池提供了一种**限制**和**管理资源**（包括执行一个任务）的方法，每个线程池还维护一些**基本统计**信息，例如已完成任务的数量

好处：

1. 降低资源消耗
2. 提高响应速度
3. 提高线程的可管理性

### 2. 线程池在实际项目的使用场景

线程池一般用于执行**多个不相关联的耗时任务**，没有多线程的情况下，任务顺序执行，使用了线程池的话可让多个不相关联的任务**同时执行**。

![image-20221129144110632](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129144110632.png)

### 3. 如何使用线程池

一般是通过 `ThreadPoolExecutor` 的构造函数来创建线程池，然后提交任务给线程池执行就可以了。构造函数如下：  

```java
  /**
     * 用给定的初始参数创建一个新的ThreadPoolExecutor。
     */
    public ThreadPoolExecutor(int corePoolSize,//线程池的核心线程数量
                              int maximumPoolSize,//线程池的最大线程数
                              long keepAliveTime,//当线程数大于核心线程数时，多余的空闲线程存活的最长时间
                              TimeUnit unit,//时间单位
                              BlockingQueue<Runnable> workQueue,//任务队列，用来储存等待执行任务的队列
                              ThreadFactory threadFactory,//线程工厂，用来创建线程，一般默认即可
                              RejectedExecutionHandler handler//拒绝策略，当提交的任务过多而不能及时处理时，我们可以定制策略来处理任务
                               ) {
        if (corePoolSize < 0 ||
            maximumPoolSize <= 0 ||
            maximumPoolSize < corePoolSize ||
            keepAliveTime < 0)
            throw new IllegalArgumentException();
        if (workQueue == null || threadFactory == null || handler == null)
            throw new NullPointerException();
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }
```

使用代码：  

```java

private static final int CORE_POOL_SIZE = 5;
    private static final int MAX_POOL_SIZE = 10;
    private static final int QUEUE_CAPACITY = 100;
    private static final Long KEEP_ALIVE_TIME = 1L;

    public static void main(String[] args) {

        //使用阿里巴巴推荐的创建线程池的方式
        //通过ThreadPoolExecutor构造函数自定义参数创建
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
                CORE_POOL_SIZE,
                MAX_POOL_SIZE,
                KEEP_ALIVE_TIME,
                TimeUnit.SECONDS,
                new ArrayBlockingQueue<>(QUEUE_CAPACITY),
                new ThreadPoolExecutor.CallerRunsPolicy());

        for (int i = 0; i < 10; i++) {
            executor.execute(() -> {
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("CurrentThread name:" + Thread.currentThread().getName() + "date：" + Instant.now());
            });
        }
        //终止线程池
        executor.shutdown();
        try {
            /* 
            awaitTermination()方法的作用:
			当前线程阻塞，直到
			1. 等所有已提交的任务（包括正在跑的和队列中等待的）执行完
			2. 或者等超时时间到
			3. 或者线程被中断，抛出InterruptedException 然后返回true（shutdown请求后所有任务执行完毕）或false（已超时）
            */
            executor.awaitTermination(5, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Finished all threads");
    }
/*输出
 CurrentThread name:pool-1-thread-5date：2020-06-06T11:45:31.639Z
CurrentThread name:pool-1-thread-3date：2020-06-06T11:45:31.639Z
CurrentThread name:pool-1-thread-1date：2020-06-06T11:45:31.636Z
CurrentThread name:pool-1-thread-4date：2020-06-06T11:45:31.639Z
CurrentThread name:pool-1-thread-2date：2020-06-06T11:45:31.639Z
CurrentThread name:pool-1-thread-2date：2020-06-06T11:45:33.656Z
CurrentThread name:pool-1-thread-4date：2020-06-06T11:45:33.656Z
CurrentThread name:pool-1-thread-1date：2020-06-06T11:45:33.656Z
CurrentThread name:pool-1-thread-3date：2020-06-06T11:45:33.656Z
CurrentThread name:pool-1-thread-5date：2020-06-06T11:45:33.656Z
Finished all threads 
*/
```



## 线程池最佳实践

### 1. 使用ThreadPoolExecutor的构造函数声明线程池

线程池必须手动通过 `ThreadPoolExecutor` 的构造函数来声明，避免使用`Executors` 类的 **`newFixedThreadPool`** 和 **`newCachedThreadPool`** ，因为可能会有 OOM 的风险。

> **`FixedThreadPool` 和 `SingleThreadExecutor`** ： 允许请求的队列长度为 `Integer.MAX_VALUE`,可能堆积大量的请求，从而导致 OOM。
>
> **CachedThreadPool 和 ScheduledThreadPool** ： 允许创建的线程数量为 `Integer.MAX_VALUE` ，可能会创建大量线程，从而导致 OOM。

总结：使用**有界队列**，**控制线程创建数量**

其他原因：

1. 实际中要根据自己机器的性能、业务场景来手动配置线程池参数，比如**核心线程数**、**使用的任务队列**、**饱和策略**
2. 给**线程池命名**，方便定位问题

### 2. 监测线程池运行状态

可以通过一些手段检测线程池运行状态，比如SpringBoot中的Actuator组件

或者利用ThreadPoolExecutor相关的API做简陋监控，ThreadPoolExecutor提供了**获取线程池当前的线程数**和**活跃线程数**、**已经执行完成的任务数**，**正在排队中的任务数**等

![image-20221129151614427](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129151614427.png)

简单的demo，使用ScheduleExecutorService定时打印线程池信息

```java
    /**
     * 打印线程池的状态
     *
     * @param threadPool 线程池对象
     */
    public static void printThreadPoolStatus(ThreadPoolExecutor threadPool) {
        ScheduledExecutorService scheduledExecutorService = new ScheduledThreadPoolExecutor(1, createThreadFactory("print-images/thread-pool-status", false));
        scheduledExecutorService.scheduleAtFixedRate(() -> {
            log.info("=========================");
            log.info("ThreadPool Size: [{}]", threadPool.getPoolSize());
            log.info("Active Threads: {}", threadPool.getActiveCount());
            log.info("Number of Tasks : {}", threadPool.getCompletedTaskCount());
            log.info("Number of Tasks in Queue: {}", threadPool.getQueue().size());
            log.info("=========================");
        }, 0, 1, TimeUnit.SECONDS);
    }
```



### 3. 建议不同类别的业务用不同的线程池

> 建议是**不同的业务使用不同的线程池**，配置线程池的时候根据当前业务的情况对当前线程池进行配置，因为**不同的业务的并发**以及**对资源的使用情况**都不同，重心**优化系统性能瓶颈**相关的业务

极端情况导致死锁：  
![image-20221129153400643](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129153400643.png)

假如我们线程池的核心线程数为 **n**，父任务（扣费任务）数量为 **n**，父任务下面有两个子任务（扣费任务下的子任务），其中一个已经执行完成，另外一个被放在了任务队列中。由于**父任务把线程池核心线程资源用完**，所以子任务因为无法获取到线程资源无法正常执行，一直被阻塞在队列中。父任务等待子任务执行完成，而子任务等待父任务释放线程池资源，这也就造成了 **"死锁"**。

![image-20221129154616346](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129154616346.png)

![image-20221129154543256](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129154543256.png)

### 4. 别忘记给线程池命名

**初始化线程池时显示命名**（设置线程池名称前缀），有利于**定位问题**

- 利用guava的ThreadFactoryBuilder

  ```java
  ThreadFactory threadFactory = new ThreadFactoryBuilder()
                          .setNameFormat(threadNamePrefix + "-%d")
                          .setDaemon(true).build();
  ExecutorService threadPool = new ThreadPoolExecutor(corePoolSize, maximumPoolSize, keepAliveTime, TimeUnit.MINUTES, workQueue, threadFactory)
  ```

- 自己实现ThreadFactor

  ```java
  import java.util.concurrent.Executors;
  import java.util.concurrent.ThreadFactory;
  import java.util.concurrent.atomic.AtomicInteger;
  /**
   * 线程工厂，它设置线程名称，有利于我们定位问题。
   */
  public final class NamingThreadFactory implements ThreadFactory {
  
      private final AtomicInteger threadNum = new AtomicInteger();
      private final ThreadFactory delegate;
      private final String name;
  
      /**
       * 创建一个带名字的线程池生产工厂
       */
      public NamingThreadFactory(ThreadFactory delegate, String name) {
          this.delegate = delegate;
          this.name = name; // TODO consider uniquifying this
      }
  
      @Override
      public Thread newThread(Runnable r) {
          Thread t = delegate.newThread(r);
          t.setName(name + " [#" + threadNum.incrementAndGet() + "]");
          return t;
      }
  
  } 
  ```

  

### 5. 正确配置线程池参数

- 如果线程池中的线程太多，就会增加**上下文切换**的成本

  > 多线程编程中一般线程的个数都大于 CPU 核心的个数，而一个 CPU 核心在任意时刻只能被一个线程使用，为了让这些线程都能得到有效执行，CPU 采取的策略是为每个线程分配时间片并轮转的形式。当一个线程的时间片用完的时候就会重新处于就绪状态让给其他线程使用，这个过程就属于一次上下文切换。概括来说就是：当前任务在执行完 CPU 时间片切换到另一个任务之前会先保存自己的状态，以便下次再切换回这个任务时，可以再加载这个任务的状态。**任务从保存到再加载的过程就是一次上下文切换**。
  >
  > 上下文切换通常是计算密集型的。也就是说，它需要相当可观的处理器时间，在每秒几十上百次的切换中，每次切换都需要纳秒量级的时间。所以，**上下文切换对系统来说意味着消耗大量的 CPU 时间**，事实上，可能是操作系统中时间消耗最大的操作。
  >
  > **Linux** 相比与其他操作系统（包括其他类 Unix 系统）有很多的优点，其中有一项就是，其**上下文切换和模式切换的时间消耗非常少**。

- 过大跟过小都不行

  - 如果我们设置的**线程池数量太小**的话，如果同一时间有大量任务/请求需要处理，可能会导致大**量的请求/任务在任务队列中排队等待执行**，甚至会出现**任务队列满了**之后任务/请求**无法处理**的情况，或者大量任**务堆积在任务队列导致 OOM**
  - 设置线程**数量太大**，**大量线程可能会同时在争取 CPU 资源**，这样会导致**大量的上下文切换**，从而**增加线程的执行时间**，影响了整体执行效率

- 简单且适用面较广的公式

  - **CPU 密集型任务(N+1)：** 这种**任务消耗的主要是 CPU 资源**，可以将线程数设置为 N（CPU 核心数）+1，比 CPU 核心数多出来的一个线程是为了防止线程偶发的缺页中断，或者其它原因导致的任务暂停而带来的影响。一旦任务暂停，CPU 就会处于空闲状态，而在这种情况下多出来的一个线程就可以充分利用 CPU 的空闲时间。

  - **I/O 密集型任务(2N)：** 这种任务应用起来，系统会用**大部分的时间来处理 I/O 交互**，而**线程在处理 I/O 的时间段内不会占用 CPU 来处理**，这时就可以将 CPU 交出给其它线程使用。因此**在 I/O 密集型任务的应用中，我们可以多配置一些线程**，具体的计算方法是 2N。

  - > 如何判断是CPU密集任务还是IO密集任务
    >
    > CPU 密集型简单理解就是利用 CPU 计算能力的任务比如你在内存中对大量数据进行排序。但凡涉及到网络读取，文件读取这类都是 IO 密集型，这类任务的特点是 CPU 计算耗费时间相比于等待 IO 操作完成的时间来说很少，大部分时间都花在了等待 IO 操作完成上。
    >
    > 

- 美团线程池的处理
  主要对线程池的核心参数实现自定义可配置

  - **`corePoolSize` :** 核心线程数线程数定义了最小可以同时运行的线程数量。
  - **`maximumPoolSize` :** 当队列中存放的任务达到队列容量的时候，当前可以同时运行的线程数量变为最大线程数。
  - **`workQueue`:** 当新任务来的时候会先判断当前运行的线程数量是否达到核心线程数，如果达到的话，新任务就会被存放在队列中

  参数动态配置
  ![image-20221129154916589](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129154916589.png)

  1. 格外需要注意的是`corePoolSize`， **程序运行期间**的时候，我们**调用 `setCorePoolSize（）`**这个方法的话，线程池会**首先判断当前工作线程数是否大于`corePoolSize`**，如果**大于的话就会回收工作线程**。【**ThreadPoolExecutor里面的**】
  2. 另外，你也看到了上面并没有动态指定队列长度的方法，美团的方式是自定义了一个叫做 `ResizableCapacityLinkedBlockIngQueue` 的队列（主要就是**把`LinkedBlockingQueue`的 capacity 字段的 final 关键字修饰给去掉了，让它变为可变的**）

  ![image-20221129155849107](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129155849107.png)