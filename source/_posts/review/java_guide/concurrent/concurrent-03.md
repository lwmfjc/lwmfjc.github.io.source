---
title: 并发03
description: 并发03
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-11-07 16:04:33
updated: 2022-11-07 16:04:33

---

> 转载自https://github.com/Snailclimb/JavaGuide

## 线程池

- 为什么要使用线程池

  > - 池化技术：线程池、数据库连接池、Http连接池
  > - 池化技术思想意义：为了减少每次获取资源的消耗，提高对资源的利用率

  - 线程池提供了**限制**和**管理**资源(包括执行一个任务)的方法
  - 每个线程池还维护基本统计信息，例如已完成任务的数量
  - 好处：
    1. **降低资源消耗**  重复利用已创建线程降低线程创建和销毁造成的消耗
    2. 提高响应速度 任务到达时，任务可以不需等到线程创建就能继续执行
    3. 提高线程的可管理性 线程是稀缺资源，如果无限制创建，不仅**消耗系统资源**，还会**降低系统的稳定性**，使用线程池统一**管理分配**、**调优**和**监控**。

- 实现Runnable接口和Callable接口的区别

  - Runnable接口不会返回接口或抛出检查异常，Callable接口可以
  - Executors可以实现将Runnable对象转换成Callable对象  
    Executors.callable(Runnable task)` 或 `Executors.callable(Runnable task, Object result)  //则两个方法，运行的结果是 Callable<Object> 

  Runnable和Callable：

  ```java
  //Runnable.java
  @FunctionalInterface
  public interface Runnable {
     /**
      * 被线程执行，没有返回值也无法抛出异常
      */
      public abstract void run();
  }
  //=========================================
  //Callable.java
  @FunctionalInterface
  public interface Callable<V> {
      /**
       * 计算结果，或在无法这样做时抛出异常。
       * @return 计算得出的结果
       * @throws 如果无法计算结果，则抛出异常
       */
      V call() throws Exception;
  }
  ```

- 执行execute()和submit()方法的区别是什么

  1. **execute()** 方法用于提交**不需要返回值的任务**，所以**无法判断任务是否被线程池执行成功**

  2. **submit()**方法用于提交**需要返回值的任务**，线程池会**返回一个Future类型**的对象，通过这个Future对象**可以判断任务是否返回成功**

     - 这个Future的get()方法来获取返回值，get()方法会阻塞当前线程直到任务完成； 使用get(long timeout,TimeUnit unit) 方法会在阻塞当前线程一段时间后立即返回(此时任务不一定已经执行完)
       注意: 这里的get()不一定会有返回值的，例子如下

       ```java
               ExecutorService executorService = Executors.newCachedThreadPool();
               Callable<MyClass> myClassCallable = new Callable<MyClass>() {
                   @Override
                   public MyClass call() throws Exception {
                       MyClass myClass1 = new MyClass();
                       myClass1.setName("ly-callable-测试");
                       TimeUnit.SECONDS.sleep(2);
                       return myClass1;
                   }
               };
               Future<?> submit = executorService.submit(myClassCallable);
               //这里会阻塞
               Object o = submit.get();
               log.info("ly-callable-打印结果1:" + o);
       
       
               FutureTask<MyClass> futureTask = new FutureTask<>(() -> {
                   MyClass myClass1 = new MyClass();
                   myClass1.setName("ly-FutureTask-测试");
                   TimeUnit.SECONDS.sleep(2);
                   return myClass1;
               });
               Future<?> submit2 = executorService.submit(futureTask);
               //这里会阻塞
               Object o2 = submit2.get();
               log.info("ly-callable-打印结果2:" + o2);
               executorService.shutdown();
       
       /*结果
       2022-11-09 10:19:10 上午 [Thread: main] 
       INFO:ly-callable-打印结果1:MyClass(name=ly-callable-测试)
       2022-11-09 10:19:12 上午 [Thread: main] 
       INFO:ly-callable-打印结果2:null
       */
       ```

       当submit一个Callable对象的时候，能从submit返回的Futureget到返回值；当submit一个FutureTask对象时，没法获取返回值，因为会被当作Runnable对象submit进来

       ![image-20221109103922513](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221109103922513.png)
       而入参为Runnable时返回值里是get不到结果的

  3. 下面这段源码，解释了为什么当传入的类型是Runnable对象时，结果为null

     ```java
     //源码AbstractExecutorService 接口中的一个submit方法
     public Future<?> submit(Runnable task) {
         if (task == null) throw new NullPointerException();
         RunnableFuture<Void> ftask = newTaskFor(task, null);
         execute(ftask);
         return ftask;
     }
     //其中的newTaskFor方法
     protected <T> RunnableFuture<T> newTaskFor(Runnable runnable, T value) {
         return new FutureTask<T>(runnable, value);
     }
     //execute()方法
     public void execute(Runnable command) {
       ...
     }
     ```

- 如何创建线程池

  - 不允许使用Executors去创建，而是通过new ThreadPoolExecutor的方式：能让写的同学明确线程池运行规则，规避资源耗尽

    > 使用Executors返回线程池对象的弊端：
    >
    > ```java
    > //#####时间表示keepAliveTime#####
    > //########线程数量固定，队列长度为Integer.MAX################
    > Executors.newFixedThreadPool(3);
    > public static ExecutorService newFixedThreadPool(int nThreads) {
    >         return new ThreadPoolExecutor(nThreads, nThreads,
    >                                       0L, TimeUnit.MILLISECONDS,
    >                                       new LinkedBlockingQueue<Runnable>());
    >     }
    > //############线程数量固定，队列长度为Integer.MAX############## 
    > Executors.newSingleThreadExecutor(Executors.defaultThreadFactory());
    >  public static ExecutorService newSingleThreadExecutor(ThreadFactory threadFactory) {
    >         return new FinalizableDelegatedExecutorService
    >             (new ThreadPoolExecutor(1, 1,
    >                                     0L, TimeUnit.MILLISECONDS,
    >                                     new LinkedBlockingQueue<Runnable>(),
    >                                     threadFactory));
    > //############线程数量为Integer.MAX############# 
    > Executors.newCachedThreadPool(Executors.defaultThreadFactory());
    > public static ExecutorService newCachedThreadPool(ThreadFactory threadFactory) {
    >         return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
    >                                       60L, TimeUnit.SECONDS,
    >                                       new SynchronousQueue<Runnable>(),
    >                                       threadFactory);
    >     }
    > //#############线程数量为Integer.MAX############# 
    > Executors.newScheduledThreadPool(3, Executors.defaultThreadFactory()); 
    >      public static ScheduledExecutorService newScheduledThreadPool(
    >             int corePoolSize, ThreadFactory threadFactory) {
    >         return new ScheduledThreadPoolExecutor(corePoolSize, threadFactory);
    >     }
    >      ====================>
    > public ScheduledThreadPoolExecutor(int corePoolSize,
    >                                        ThreadFactory threadFactory) {
    >         super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
    >               new DelayedWorkQueue(), threadFactory);
    >     }
    > 
    > ```
    >
    > - **FixedThreadPool**和**SingleThreadExecutor**：这两个方案允许请求的队列长度为Integer.MAX_VALUE，可能**堆积大量请求**，导致OOM
    > - **CachedThreadPool**和**ScheduledThreadPool**：允许创建的线程数量为Integer.MAX_VALUE，可能**创建大量线程**，导致OOM

  - 通过构造方法实现
    ![image-20221109171604573](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221109171604573.png)

  - 通过Executor框架的工具类Executors来实现
    以下三个方法，返回的类型都是ThreadPoolExecutor

    - FixedThreadPool : 该方法返回**固定线程数量**的线程池，线程数量**始终不变**。当有新任务提交时，线程池中若有空闲线程则立即执行；若没有，则新任务被暂存到任务队列中，待有线程空闲时，则处理在任务队列中的任务
    - SingleThreadExecutor：方法返回一个**只有一个线程**的线程池。若多余一个任务被提交到该线程池，任务被保存到一个任务队列中，待线程空闲，按先进先出的顺序执行队列中任务
    - CachedThreadPool：该方法返回一个**根据实际情况调整线程数量**的线程池。
      数量不固定，若有空闲线程可以复用则**优先使用可复用**线程。若**所有线程均工作，此时又有新任务**提交，则**创建新线程**处理任务。所有线程在当前任务执行完毕后返回线程池进行复用

    Executors工具类中的方法  
    ![image-20221110104950618](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221110104950618.png)

  - ThreadPoolExecutor类分析
    该类提供四个构造方法，看最长那个，其余的都是（给定默认值后）调用这个方法

    ```java
    /**
     * 用给定的初始参数创建一个新的ThreadPoolExecutor。
     */
    public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          ThreadFactory threadFactory,
                          RejectedExecutionHandler handler) {
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

    构造函数重要参数分析  
    corePoolSize : 核心线程数定义**最小可以运行的线程数**量  
    maximumPoolSize: 当队列中存放的任务**达到队列容量时**，当前可以同时运行的线程数量**变为最大线程数**  
    workQueue：当新线程来的时候先判断当前运行线程数量是否**达到核心**线程数，如果达到的话，**新任务就会被存放在队列**中
    ThreadPoolExecutor其他常见参数：  
    
    1. keepAliveTime：如果线程池中的线程数量大于corePoolSize时，如果这时没有新任务提交，核心线程外的线程不会立即销毁，而是等待，等待的时间超过了keepAliveTime就会被回收
    
    2. unit: keepAliveTime参数的时间单位
    
    3. threadFactory: executor创建新线程的时候会用到
    
    4. handle: 饱和策略
    
       > 如果同时运行的线程数量达到最大线程数，且队列已经被放满任务，ThreadPoolTaskExecutor定义该情况下的策略：
       >
       > - **`ThreadPoolExecutor.AbortPolicy`：** 抛出 `RejectedExecutionException`来拒绝新任务的处理。
       > - **`ThreadPoolExecutor.CallerRunsPolicy`：** 调用**执行自己的线程(如果在main方法中，那就是main线程)**运行任务，也就是直接在**调用`execute`方法的线程**中**运行(`run`)被拒绝的任务**，如果**执行程序已关闭，则会丢弃该任务**。因此这种策略会降低对于新任务提交速度，影响程序的整体性能。如果您的应用程序可以承受此延迟并且你要求任何一个任务请求都要被执行的话，你可以选择这个策略。
       > - **`ThreadPoolExecutor.DiscardPolicy`：** 不处理新任务，直接丢弃掉。
       > - **`ThreadPoolExecutor.DiscardOldestPolicy`：** 此策略将丢弃最早的未处理的任务请求。
       
       使用ThreadPoolTaskExecutor或ThreadPoolExecutor构造函数创建线程池时，若不指定RejectExcecutorHandler饱和策略则默认使用ThreadPoolExecutor.AbortPolicy，即抛出RejectedExecution来拒绝新来的任务；对于可伸缩程序，建议使用ThreadPoolExecutor.CallerRunsPolicy， 
    
  - 一个简单的线程池Demo

    ```java
    //定义一个Runnable接口实现类
    import java.util.Date;
    
    /**
     * 这是一个简单的Runnable类，需要大约5秒钟来执行其任务。
     * @author shuang.kou
     */
    public class MyRunnable implements Runnable {
    
        private String command;
    
        public MyRunnable(String s) {
            this.command = s;
        }
    
        @Override
        public void run() {
            System.out.println(Thread.currentThread().getName() + " Start. Time = " + new Date());
            processCommand();
            System.out.println(Thread.currentThread().getName() + " End. Time = " + new Date());
        }
    
        private void processCommand() {
            try {
                Thread.sleep(5000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    
        @Override
        public String toString() {
            return this.command;
        }
    }
    //实际执行
    import java.util.concurrent.ArrayBlockingQueue;
    import java.util.concurrent.ThreadPoolExecutor;
    import java.util.concurrent.TimeUnit;
    
    public class ThreadPoolExecutorDemo {
    
        private static final int CORE_POOL_SIZE = 5;//核心线程数5
        private static final int MAX_POOL_SIZE = 10;//最大线程数10
        private static final int QUEUE_CAPACITY = 100;//队列容量100
        private static final Long KEEP_ALIVE_TIME = 1L;//等待时间
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
                //创建 MyRunnable 对象（MyRunnable 类实现了Runnable 接口）
                Runnable worker = new MyRunnable("" + i);
                //执行Runnable
                executor.execute(worker);
            }
            //终止线程池
            executor.shutdown();
            while (!executor.isTerminated()) {
            }
            System.out.println("Finished all threads");
        }
    }
    /*------输出
    pool-1-thread-3 Start. Time = Sun Apr 12 11:14:37 CST 2020
    pool-1-thread-5 Start. Time = Sun Apr 12 11:14:37 CST 2020
    pool-1-thread-2 Start. Time = Sun Apr 12 11:14:37 CST 2020
    pool-1-thread-1 Start. Time = Sun Apr 12 11:14:37 CST 2020
    pool-1-thread-4 Start. Time = Sun Apr 12 11:14:37 CST 2020
    pool-1-thread-3 End. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-4 End. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-1 End. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-5 End. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-1 Start. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-2 End. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-5 Start. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-4 Start. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-3 Start. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-2 Start. Time = Sun Apr 12 11:14:42 CST 2020
    pool-1-thread-1 End. Time = Sun Apr 12 11:14:47 CST 2020
    pool-1-thread-4 End. Time = Sun Apr 12 11:14:47 CST 2020
    pool-1-thread-5 End. Time = Sun Apr 12 11:14:47 CST 2020
    pool-1-thread-3 End. Time = Sun Apr 12 11:14:47 CST 2020
    pool-1-thread-2 End. Time = Sun Apr 12 11:14:47 CST 2020
    ------ 
    */
    ```

    

- 线程池分析原理
  由结果可以

## Atomic原子类

## AQS

## 参考