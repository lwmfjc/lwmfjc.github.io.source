---
title: ly0305lyjava线程池详解
description: java线程池详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-11-23 14:40:41
updated: 2022-11-29 14:40:41
---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 一 使用线程池的好处

- 池化技术：减少每次获取资源的消耗，提高对资源的利用率
- 线程池提供一种**限制**和**管理资源（包括执行一个任务）**的方式，每个线程池还维护一些基本统计信息，例如**已完成任务**的数量
- 线程池的好处
  - 降低**资源消耗**（重复利用，降低**线程创建和销毁**造成的消耗）
  - 提高**响应速度**（任务到达直接执行，**无需等待线程创建**）
  - 提高线程**可管理性**（**避免无休止创建**，使用线程池统一**分配**、**调优**、**监控**）

## 二 Executor框架

Java5之后，通过Executor启动线程，比使用Thread的start方法更好，更**易于管理**，**效率高**，还能有助于避免this逃逸的问题

> this逃逸，指的是**构造函数返回之前**，**其他线程就持有该对象的引用**，会导致调用尚未构造完全的对象  
> 例子：  
>
> ```java
> public class ThisEscape { 
>   public ThisEscape() { 
>     new Thread(new EscapeRunnable()).start(); 
>     // ... 
>   } 
>     
>   private class EscapeRunnable implements Runnable { 
>     @Override
>     public void run() { 
>       // 通过ThisEscape.this就可以引用外围类对象, 但是此时外围类对象可能还没有构造完成, 即发生了外围类的this引用的逃逸 
>     } 
>   } 
> }
> ```
>
> 处理办法  
>
> ```java
> public class ThisEscape { 
>   private Thread t; 
>   public ThisEscape() { 
>     t = new Thread(new EscapeRunnable()); 
>     // ... 
>   } 
>     
>   public void init() { 
>     //也就是说对象没有构造完成前，不要调用ThisEscape.this即可
>     t.start(); 
>   } 
>     
>   private class EscapeRunnable implements Runnable { 
>     @Override
>     public void run() { 
>       // 通过ThisEscape.this就可以引用外围类对象, 此时可以保证外围类对象已经构造完成 
>     } 
>   } 
> }
> ```

Executor框架不仅包括**线程池的管理**，提供**线程工厂**、**队列**以及**拒绝策略**。

### Executor框架结构

主要是**三大部分**：**任务（Runnable/Callable）**，**任务的执行(Executor)**，**异步计算的结果Future**

1. 任务
   执行的任务需要的**Runnable/Callable**接口，他们的实现类，都可以被**ThreadPoolExecutor**或**ScheduleThreadPoolExecutor**执行

2. 任务的执行
   ![image-20221123163721335](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221123163721335.png)
   我们更多关注的，是ThreadPoolExecutor类。另外，ScheduledThreadPoolExecutor类，继承了ThreadPoolExecutor类，并实现了ScheduledExecutorService接口

   ```java
   //ThreadPoolExecutor类描述
   //AbstractExecutorService实现了ExecutorService接口
   public class ThreadPoolExecutor extends AbstractExecutorService{}
   
   //ScheduledThreadPoolExecutor类描述
   //ScheduledExecutorService继承ExecutorService接口
   public class ScheduledThreadPoolExecutor
           extends ThreadPoolExecutor
           implements ScheduledExecutorService {}
   ```

   

3. 异步计算的结果
   **Future接口以及其实现类FutueTask类**都可以代表异步计算的结果(下面就是Future接口)
   当我们把**Runnable接口（结果为null）**或**Callable接口**的实现类提交给ThreadPoolExecutor或ScheduledThreadPoolExecutor执行（）

   ```java
         ExecutorService executorService = Executors.newCachedThreadPool();
           Callable<MyClass> myClassCallable = new Callable<MyClass>() {
               
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

   

### Executor框架的使用示意图

![image-20221123173130638](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221123173130638.png)

1. **主线程首先要创建实现 `Runnable` 或者 `Callable` 接口的任务对象。**

2. **把创建完成的实现 `Runnable`/`Callable`接口的 对象直接交给 `ExecutorService` 执行**: `ExecutorService.execute（Runnable command）`）或者也可以把 `Runnable` 对象或`Callable` 对象提交给 `ExecutorService` 执行（`ExecutorService.submit（Runnable task）`或 `ExecutorService.submit（Callable <T> task）`）。

3. **如果执行 `ExecutorService.submit（…）`，`ExecutorService` 将返回一个实现`Future`接口的对象**（我们刚刚也提到过了执行 `execute()`方法和 `submit()`方法的区别，`submit()`会返回一个 `FutureTask 对象）。由于 FutureTask` 实现了 `Runnable`，我们也可以创建 `FutureTask`，然后直接交给 `ExecutorService` 执行（FutureTask实现了Runnable，不是一个Callable 所以直接使用```future.get()```获取的是null）。  

   ```java
   
   public class MyMain {
       private byte[] x = new byte[10 * 1024 * 1024];//10M
   
       public static void main(String[] args) throws Exception {
           Callable<Object> abc = Executors.callable(() -> {
               try {
                   TimeUnit.SECONDS.sleep(2);
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
               System.out.println("aaa");//输出aaa
           }, "abcccc");//如果没有"abcccc"，则下面输出null
           FutureTask<Object> futureTask = new FutureTask<>(abc);
           /*new Thread(futureTask).start();
           Object o = futureTask.get();
           System.out.println("获取值："+o); //输出abc
           */
           ExecutorService executorService = Executors.newSingleThreadExecutor();
           Future<?> future = executorService.submit(futureTask);
           Future<?> future1 = executorService.submit(new Callable<String>() {
               @Override
               public String call() throws Exception {
                   try {
                       TimeUnit.SECONDS.sleep(2);
                   } catch (InterruptedException e) {
                       e.printStackTrace();
                   }
                   return "hello";
               }
           });
           /*System.out.println(future.get());//输出null*/
           System.out.println(future1.get()); //输出hello
           //System.out.println(futureTask.get());//输出abcccc
   
           System.out.println("阻塞结束");
           executorService.shutdown();
       }
   }
   
   ```

   

4. **最后，主线程可以执行 `FutureTask.get()`方法来等待任务执行完成。主线程也可以执行 `FutureTask.cancel（boolean mayInterruptIfRunning）`来取消此任务的执行。**

## 三 (重要)ThreadPoolExecutor类简单介绍

**线程池实现类 `ThreadPoolExecutor` 是 `Executor` 框架最核心的类。**

### ThreadPoolExecutor类分析

- 这里看最长的那个，其余三个都是在该构造方法的基础上产生，即**给定某些默认参数**的构造方法，比如**默认的拒绝策略**

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

- ThreadPoolExecutor中，3个最重要的参数

  1. **corePoolSize**：**核心线程数**，定义了最小可以同时运行的线程数量
  2. **maximumPoolSize**：**当队列中存放的任务达到队列容量**时，当前**可以同时运行的线程数量变为最大线程数**
  3. **workQueue**：当新任务来的时候，会先判断当前运行的线程数量**是否达到核心线程数**，如果**达到**的话，新任务就会被存放在**队列**中

- ThreadPoolExecutor其他常见参数

  1. **keepAliveTime**：当线程池中的**线程数量大于corePoolSize**时，如果此时**没有新任务提交，核心线程外的线程不会立即销毁，而是会等待**，直到等待时间超过了keepAliveTime才会被回收销毁
  2. **unit**：keepAliveTime参数的时间单位
  3. **threadFactory**：executor创建新线程的时候会用到
  4. **handler**：饱和策略

  线程池各个参数的相互关系的理解  
  ![image-20221124095832400](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221124095832400.png)
  
- ThreadPoolExecutor饱和策略定义
  如果当前**同时运行的线程数量达到最大线程数量**并且**队列也已经被放满了任务**时，ThreadPoolTaskExecutor定义了一些策略： 

  1. **`ThreadPoolExecutor.AbortPolicy`** ：抛出 `RejectedExecutionException`来拒绝新任务的处理。
  2. **`ThreadPoolExecutor.CallerRunsPolicy`** ：调用执行自己的线程运行任务，也就是直接在**调用`execute`方法的线程中运行(`run`)被拒绝的任务**，如果执行程序已关闭，则会丢弃该任务。因此这种策略会降低对于新任务提交速度，影响程序的整体性能。如果您的应用程序可以承受此延迟并且你要求任何一个任务请求都要被执行的话，你可以选择这个策略。
  3. **`ThreadPoolExecutor.DiscardPolicy`** ：不处理新任务，直接丢弃掉。
  4. **`ThreadPoolExecutor.DiscardOldestPolicy`** ： 此策略将丢弃最早的未处理的任务请求。

  > 举例：  Spring 通过 `ThreadPoolTaskExecutor` 或者我们直接通过 `ThreadPoolExecutor` 的构造函数创建线程池的时候，当我们不指定 `RejectedExecutionHandler` 饱和策略的话来配置线程池的时候默认使用的是 `ThreadPoolExecutor.AbortPolicy`。在默认情况下，`ThreadPoolExecutor` 将抛出 `RejectedExecutionException` 来拒绝新来的任务 ，这代表你将丢失对这个任务的处理。 对于可伸缩的应用程序，建议使用 `ThreadPoolExecutor.CallerRunsPolicy`。当最大池被填满时，此策略为我们提供可伸缩队列。（这个直接查看 `ThreadPoolExecutor` 的构造函数源码就可以看出，比较简单的原因，这里就不贴代码了。

### 推荐使用 `ThreadPoolExecutor` 构造函数创建线程池

> 阿里巴巴Java开发手册"并发处理"这一章节，明确指出，线程资源必须通过线程池提供，不允许在应用中自行显示创建线程

原因：使用线程池的好处是**减少在创建和销毁线程上所消耗的时间以及系统资源开销**，**解决资源不足**的问题。如果**不使用线程池**，有可能会**造成系统创建大量同类线程**而导致消耗完内存或者“过度切换”的问题。也**不允许使用Executors去创建，而是通过ThreadPoolExecutor构造方式**  
Executors返回线程池对象的弊端：

- FixedThreadPool和SingleThreadExecutor：允许请求的队列长度为Integer.MAV_VALUE 可能堆积大量请求，导致OOM
- CachedThreadPool和ScheduledThreadPool，允许创建的线程数量为Integer.MAX_VALUE 可能创建大量线程，从而导致OOM

创建线程的几种方法

1. 通过ThreadPoolExecutor构造函数实现（推荐）
   ![image-20221124105119802](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221124105119802.png)
2. 通过Executors框架的工具类Executors来实现，我们可以创建三红类型的ThreadPoolExecutor
   FixedThreadPool、SingleThreadExecutor、CachedThreadPool

## 四 ThreadPoolExecutor使用+原理分析

### 示例代码：Runnable+ThreadPoolExecutor

先创建一个Runnable接口的实现类

```java
//MyRunnable.java
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
```

使用自定义的线程池

```java
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ThreadPoolExecutorDemo {

    private static final int CORE_POOL_SIZE = 5;
    private static final int MAX_POOL_SIZE = 10;
    private static final int QUEUE_CAPACITY = 100;
    private static final Long KEEP_ALIVE_TIME = 1L;
    public static void main(String[] args) {

        //使用阿里巴巴推荐的创建线程池的方式
        //通过ThreadPoolExecutor构造函数自定义参数创建
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
                CORE_POOL_SIZE, //5
                MAX_POOL_SIZE,  //10
                KEEP_ALIVE_TIME, //1L
                TimeUnit.SECONDS, //单位
                new ArrayBlockingQueue<>(QUEUE_CAPACITY),//100
                new ThreadPoolExecutor.CallerRunsPolicy()); //主线程中运行

        for (int i = 0; i < 10; i++) {
            //创建WorkerThread对象（WorkerThread类实现了Runnable 接口）
            Runnable worker = new MyRunnable("" + i);
            //执行Runnable
            executor.execute(worker);
        }
        //终止线程池
        executor.shutdown();
        // isTerminated 判断所有提交的任务是否完成(保证之前调用过shutdown方法) 
        while (!executor.isTerminated()) {
        }
        System.out.println("Finished all threads");
    }
} 
//结果：  
/*
corePoolSize: 核心线程数为 5。
maximumPoolSize ：最大线程数 10
keepAliveTime : 等待时间为 1L。
unit: 等待时间的单位为 TimeUnit.SECONDS。
workQueue：任务队列为 ArrayBlockingQueue，并且容量为 100;
handler:饱和策略为 CallerRunsPolicy
---output--- 
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

### 线程池原理分析

如上，**线程池首先会先执行 5 个任务，然后这些任务有任务被执行完的话，就会去拿新的任务执行**

![image-20221124133637560](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221124133637560.png)

execute方法源码  

```java
 // 存放线程池的运行状态 (runState) 和线程池内有效线程的数量 (workerCount)
   private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));

    private static int workerCountOf(int c) {
        return c & CAPACITY;
    }
    //任务队列
    private final BlockingQueue<Runnable> workQueue;

    public void execute(Runnable command) {
        // 如果任务为null，则抛出异常。
        if (command == null)
            throw new NullPointerException();
        // ctl 中保存的线程池当前的一些状态信息
        int c = ctl.get();

        //  下面会涉及到 3 步 操作
        // 1.首先判断当前线程池中执行的任务数量是否小于 corePoolSize
        // 如果小于的话，通过addWorker(command, true)新建一个线程，并将任务(command)添加到该线程中；然后，启动该线程从而执行任务。
        if (workerCountOf(c) < corePoolSize) {
            if (addWorker(command, true))
                return;
            c = ctl.get();
        }
        // 2.如果当前执行的任务数量大于等于 corePoolSize 的时候就会走到这里
        // 通过 isRunning 方法判断线程池状态，线程池处于 RUNNING 状态并且队列可以加入任务，该任务才会被加入进去
        if (isRunning(c) && workQueue.offer(command)) {
            int recheck = ctl.get();
            // 再次获取线程池状态，如果线程池状态不是 RUNNING 状态就需要从任务队列中移除任务，并尝试判断线程是否全部执行完毕。同时执行拒绝策略。
            if (!isRunning(recheck) && remove(command))
                reject(command);
                // 如果当前线程池为空就新创建一个线程并执行。
            else if (workerCountOf(recheck) == 0)
                addWorker(null, false);
        }
        //3. 通过addWorker(command, false)新建一个线程，并将任务(command)添加到该线程中；然后，启动该线程从而执行任务。
        //如果addWorker(command, false)执行失败，则通过reject()执行相应的拒绝策略的内容。
        else if (!addWorker(command, false))
            reject(command);
    }
------ 
```

图示：  
![image-20221124133846191](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221124133846191.png)

源码

```java
 // 全局锁，并发操作必备
    private final ReentrantLock mainLock = new ReentrantLock();
    // 跟踪线程池的最大大小，只有在持有全局锁mainLock的前提下才能访问此集合
    private int largestPoolSize;
    // 工作线程集合，存放线程池中所有的（活跃的）工作线程，只有在持有全局锁mainLock的前提下才能访问此集合
    private final HashSet<Worker> workers = new HashSet<>();
    //获取线程池状态
    private static int runStateOf(int c)     { return c & ~CAPACITY; }
    //判断线程池的状态是否为 Running
    private static boolean isRunning(int c) {
        return c < SHUTDOWN;
    }


    /**
     * 添加新的工作线程到线程池
     * @param firstTask 要执行
     * @param core参数为true的话表示使用线程池的基本大小，为false使用线程池最大大小
     * @return 添加成功就返回true否则返回false
     */
   private boolean addWorker(Runnable firstTask, boolean core) {
        retry:
        for (;;) {
            //这两句用来获取线程池的状态
            int c = ctl.get();
            int rs = runStateOf(c);

            // Check if queue empty only if necessary.
            if (rs >= SHUTDOWN &&
                ! (rs == SHUTDOWN &&
                   firstTask == null &&
                   ! workQueue.isEmpty()))
                return false;

            for (;;) {
               //获取线程池中工作的线程的数量
                int wc = workerCountOf(c);
                // core参数为false的话表明队列也满了，线程池大小变为 maximumPoolSize
                if (wc >= CAPACITY ||
                    wc >= (core ? corePoolSize : maximumPoolSize))
                    return false;
               //原子操作将workcount的数量加1
                if (compareAndIncrementWorkerCount(c))
                    break retry;
                // 如果线程的状态改变了就再次执行上述操作
                c = ctl.get();
                if (runStateOf(c) != rs)
                    continue retry;
                // else CAS failed due to workerCount change; retry inner loop
            }
        }
        // 标记工作线程是否启动成功
        boolean workerStarted = false;
        // 标记工作线程是否创建成功
        boolean workerAdded = false;
        Worker w = null;
        try {

            w = new Worker(firstTask);
            final Thread t = w.thread;
            if (t != null) {
              // 加锁
                final ReentrantLock mainLock = this.mainLock;
                mainLock.lock();
                try {
                   //获取线程池状态
                    int rs = runStateOf(ctl.get());
                   //rs < SHUTDOWN 如果线程池状态依然为RUNNING,并且线程的状态是存活的话，就会将工作线程添加到工作线程集合中
                  //(rs=SHUTDOWN && firstTask == null)如果线程池状态小于STOP，也就是RUNNING或者SHUTDOWN状态下，同时传入的任务实例firstTask为null，则需要添加到工作线程集合和启动新的Worker
                   // firstTask == null证明只新建线程而不执行任务
                    if (rs < SHUTDOWN ||
                        (rs == SHUTDOWN && firstTask == null)) {
                        if (t.isAlive()) // precheck that t is startable
                            throw new IllegalThreadStateException();
                        workers.add(w);
                       //更新当前工作线程的最大容量
                        int s = workers.size();
                        if (s > largestPoolSize)
                            largestPoolSize = s;
                      // 工作线程是否启动成功
                        workerAdded = true;
                    }
                } finally {
                    // 释放锁
                    mainLock.unlock();
                }
                //// 如果成功添加工作线程，则调用Worker内部的线程实例t的Thread#start()方法启动真实的线程实例
                if (workerAdded) {
                    t.start();
                  /// 标记线程启动成功
                    workerStarted = true;
                }
            }
        } finally {
           // 线程启动失败，需要从工作线程中移除对应的Worker
            if (! workerStarted)
                addWorkerFailed(w);
        }
        return workerStarted;
    }
------ 
```

完整源码分析 https://www.throwx.cn/2020/08/23/java-concurrency-thread-pool-executor/

> 对于代码中，进行分析：  
>
> 我们在代码中模拟了 10 个任务，我们配置的核心线程数为 5 、等待队列容量为 100 ，所以每次只可能存在 5 个任务同时执行，剩下的 5 个任务会被放到等待队列中去。当前的 5 个任务中如果有任务被执行完了，线程池就会去拿新的任务执行。

### 几个常见的对比

- Runnable VS Callable
  Runnable Java 1.0，不会返回结果或抛出检查异常

  Callable Java 1.5 可以

  > 工具类Executors可以实现，将Runnable对象转换成Callable对象( Executors.callable(Runnable task)` 或 `Executors.callable(Runnable task, Object result) )

  ```java
  //Runnable
  @FunctionalInterface
  public interface Runnable {
     /**
      * 被线程执行，没有返回值也无法抛出异常
      */
      public abstract void run();
  }
  ------
  //Callable
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

- execute() VS submit()

  - `execute()`方法用于提交不需要返回值的任务，所以无法判断任务是否被线程池执行成功与否；
  - `submit()`方法用于提交需要返回值的任务。线程池会返回一个 `Future` 类型的对象，通过这个 `Future` 对象可以判断任务是否执行成功，并且可以通过 `Future` 的 `get()`方法来获取返回值，`get()`方法会阻塞当前线程直到任务完成，而使用 `get（long timeout，TimeUnit unit）`方法的话，如果在 `timeout` 时间内任务还没有执行完，就会抛出 `java.util.concurrent.TimeoutException`。

  ```java
  //真实使用，建议使用ThreadPoolExecutor构造方法
  ExecutorService executorService = Executors.newFixedThreadPool(3);
  
  Future<String> submit = executorService.submit(() -> {
      try {
          Thread.sleep(5000L);
      } catch (InterruptedException e) {
          e.printStackTrace();
      }
      return "abc";
  });
  
  String s = submit.get();
  System.out.println(s);
  executorService.shutdown();
  /*
   abc
  */
  ```

  使用抛异常的方法

  ```java
  ExecutorService executorService = Executors.newFixedThreadPool(3);
  
  Future<String> submit = executorService.submit(() -> {
      try {
          Thread.sleep(5000L);
      } catch (InterruptedException e) {
          e.printStackTrace();
      }
      return "abc";
  });
  
  String s = submit.get(3, TimeUnit.SECONDS);
  System.out.println(s);
  executorService.shutdown();
  /* 控制台输出
   Exception in thread "main" java.util.concurrent.TimeoutException
  	at java.util.concurrent.FutureTask.get(FutureTask.java:205)
  
  */
  ```

  

- shutdown() VS shutdownNow()
  ![image-20221124135602080](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221124135602080.png)

  - **`shutdown（）`** :关闭线程池，线程池的状态变为 `SHUTDOWN`。线程池**不再接受新任务**了，但是**队列里的任务得执行完毕**。
  - **`shutdownNow（）`** :关闭线程池，线程的状态变为 `STOP`。线程池会**终止当前正在运行的任务**，并**停止处理排队的任务**并**返回正在等待执行的 List**。

- isTerminated() VS isshutdown()

  - **`isShutDown`** 当调用 `shutdown()` 方法后返回为 true。
  - **`isTerminated`** 当调用 `shutdown()` 方法后，并且**所有提交的任务完成**后返回为 true

- callable+ThreadPoolExecutor示例代码
  源代码
  //MyCallable.java

  ```java
  import java.util.ArrayList;
  import java.util.Date;
  import java.util.List;
  import java.util.concurrent.ArrayBlockingQueue;
  import java.util.concurrent.Callable;
  import java.util.concurrent.ExecutionException;
  import java.util.concurrent.Future;
  import java.util.concurrent.ThreadPoolExecutor;
  import java.util.concurrent.TimeUnit;
  
  public class CallableDemo {
  
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
  
          List<Future<String>> futureList = new ArrayList<>();
          Callable<String> callable = new MyCallable();
          for (int i = 0; i < 10; i++) {
              //提交任务到线程池
              Future<String> future = executor.submit(callable);
              //将返回值 future 添加到 list，我们可以通过 future 获得 执行 Callable 得到的返回值
              futureList.add(future);
          }
          for (Future<String> fut : futureList) {
              try {
                  System.out.println(new Date() + "::" + fut.get());
              } catch (InterruptedException | ExecutionException e) {
                  e.printStackTrace();
              }
          }
          //关闭线程池
          executor.shutdown();
      }
  }
  /*
  运行结果
  Wed Nov 13 13:40:41 CST 2019::pool-1-thread-1
  Wed Nov 13 13:40:42 CST 2019::pool-1-thread-2
  Wed Nov 13 13:40:42 CST 2019::pool-1-thread-3
  Wed Nov 13 13:40:42 CST 2019::pool-1-thread-4
  Wed Nov 13 13:40:42 CST 2019::pool-1-thread-5
  Wed Nov 13 13:40:42 CST 2019::pool-1-thread-3
  Wed Nov 13 13:40:43 CST 2019::pool-1-thread-2
  Wed Nov 13 13:40:43 CST 2019::pool-1-thread-1
  Wed Nov 13 13:40:43 CST 2019::pool-1-thread-4
  Wed Nov 13 13:40:43 CST 2019::pool-1-thread-5
  ------
   
  */
  ```

  

## 几种常见的线程池详解

1. FixedThreadPool
   称之为**可重用固定线程数**的线程池，Executors类中源码：  

   ```java
     /**
        * 创建一个可重用固定数量线程的线程池
     */
   public static ExecutorService newFixedThreadPool(int nThreads, ThreadFactory threadFactory) {
           return new ThreadPoolExecutor(nThreads, nThreads,
                                         0L, TimeUnit.MILLISECONDS,
                                         new LinkedBlockingQueue<Runnable>(),
                                         threadFactory);
       } 
   //================或================
   public static ExecutorService newFixedThreadPool(int nThreads) {
           return new ThreadPoolExecutor(nThreads, nThreads,
                                         0L, TimeUnit.MILLISECONDS,
                                         new LinkedBlockingQueue<Runnable>());
       } 
   ```

   如上得知，新创建的FixedThreadPool的**corePoolSize**和**maximumPoolSize**都被设置为nThreads 

   - 执行任务过程介绍
     FixedThreadPool的execute()方法运行示意图  
     ![image-20221124155404087](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221124155404087.png)
     上图分析
     1. 如果当前运行的线程数小于 corePoolSize， 如果再来新任务的话，就创建新的线程来执行任务；
     2. 当前运行的线程数等于 corePoolSize 后， 如果再来新任务的话，会将任务加入 `LinkedBlockingQueue`；
     3. 线程池中的线程执行完 手头的任务后，会在循环中反复从 `LinkedBlockingQueue` 中获取任务来执行；
   - 为什么不推荐使用FixedThreadPool
     主要原因，FixedThreadPool**使用无界队列LinkedBlockingQueue（队列容量为Integer.MAX_VALUE)作为线程池的工作队列**
     1. 线程池的线程数达到corePoolSize后，新任务在**无界队列**中等待，因此线程池中**线程数不超过corePoolSize**
     2. 由于使用无界队列时 `maximumPoolSize` 将是一个无效参数，因为**不可能存在任务队列满**的情况。所以，【不需要空闲线程，因为corePool，然后Queue，最后才是空闲线程】通过创建 `FixedThreadPool`的源码可以看出创建的 `FixedThreadPool` 的 **`corePoolSize` 和 `maximumPoolSize` 被设置为同一个值**。
     3. 又由于1、2原因，使用无界队列时，**keepAliveTime将是无效参数**
     4. 运行中的FixedThreadPool（如果未执行shutdown()或shutdownNow()）则不会拒绝任务，因此在任务较多时会导致**OOM**（**内存溢出,Out Of Memory**）

2. SingleThreadExecutor

   - SingleThreadExecutor是只有一个线程的线程池，源码：  

     ```java
      /**
          *返回只有一个线程的线程池
          */
         public static ExecutorService newSingleThreadExecutor(ThreadFactory threadFactory) {
             return new FinalizableDelegatedExecutorService
                 (new ThreadPoolExecutor(1, 1,
                                         0L, TimeUnit.MILLISECONDS,
                                         new LinkedBlockingQueue<Runnable>(),
                                         threadFactory));
         }
     //另一种构造函数
       public static ExecutorService newSingleThreadExecutor() {
             return new FinalizableDelegatedExecutorService
                 (new ThreadPoolExecutor(1, 1,
                                         0L, TimeUnit.MILLISECONDS,
                                         new LinkedBlockingQueue<Runnable>()));
         }
     ```

     新创建的 `SingleThreadExecutor` 的 `corePoolSize` 和 `maximumPoolSize` 都被设置为 1.其他参数和 `FixedThreadPool` 相同

   - 执行过程
     ![image-20221124173110534](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221124173110534.png)
     如果当前运行线程数少于corePoolSize（1），则创建一个新的线程执行任务；当前线程池有一个运行的线程后，将任务加入LinkedBlockingQueue；线程执行完当前的任务后，会在循环中反复从LinkedBlockingQueue中获取任务执行
     
   - 为什么不推荐使用SingleThreadExecutor
     SingleThreadExecutor使用**无界队列LinkedBlockingQueue**作为线程池的工作队列（容量为Integer.MAX_VALUE) 。SingleThreadExecutor使用无界队列作为线程池的工作队列会对线程池带来的影响与FixedThreadPoll相同，即导致OOM

3. CachedThreadPool
   CachedThreadPool是一个会根据需要创建新线程的线程池，源码：

   ```java
       /**
        * 创建一个线程池，根据需要创建新线程，但会在先前构建的线程可用时重用它。
        */
       public static ExecutorService newCachedThreadPool(ThreadFactory threadFactory) {
           return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                         60L, TimeUnit.SECONDS,
                                         new SynchronousQueue<Runnable>(),
                                         threadFactory);
       }
   //其他构造函数
   public static ExecutorService newCachedThreadPool() {
           return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                         60L, TimeUnit.SECONDS,
                                         new SynchronousQueue<Runnable>());
       } 
   ```

   `CachedThreadPool` 的**`corePoolSize` 被设置为空（0）**，**`maximumPoolSize`被设置为 `Integer.MAX.VALUE`**，即它是无界的，这也就意味着如果主线程提交任务的速度高于 `maximumPool` 中线程处理任务的速度时，`CachedThreadPool` 会**不断创建新的线程**。极端情况下，这样会导致**耗尽 cpu** 和**内存资源**

   ★：SynchronousQueue队列只能容纳单个元素
   执行过程（execute()示意图）


   ![image-20221128163237634](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221128163237634.png)
   上图说明：

   1. 首先执行 `SynchronousQueue.offer(Runnable task)` 提交任务到任务队列。如果当前 `maximumPool` 中有闲线程正在执行 `SynchronousQueue.poll(keepAliveTime,TimeUnit.NANOSECONDS)`，那么**主线程执行 offer 操作**与空**闲线程执行的 `poll`** 操作配对成功，主线程**把任务交给空闲线程**执行，`execute()`方法执行完成，否则执行下面的步骤 2；
   2. 当初始 `maximumPool` 为空，或者 `maximumPool` 中没有空闲线程时，将没有线程执行 `SynchronousQueue.poll(keepAliveTime,TimeUnit.NANOSECONDS)`。这种情况下，步骤 1 将失败，此时 `CachedThreadPool` 会**创建新线程**执行任务，execute 方法执行完成；

   不推荐使用CachedThreadPool? 因为它允许**创建的线程数量为Integer.MAX_VALUE**,可能创建大量线程，从而导致OOM

## ScheduledThreadPoolExecutor详解

项目中基本不会用到，主要用来在给定的延迟后运行任务，或者定期执行任务
它使用的**任务队列DelayQueue封装了一个PriorityQueue**，PriorityQueue会**对队列中的任务进行排序**，执行**所需时间（第一次执行的时间）短**的放在前面先被执行(**ScheduledFutureTask的time**变量小的先执行)，如果一致则先提交的先执行(**ScheduleFutureTask的sequenceNumber变量**)

- ScheduleFutureTask

  ```java
   /**
       * 其中, triggerTime(initialDelay, unit) 的结果即上面说的time，说的应该是第一次执行的时间，而不是整个任务的执行时间
       * @throws RejectedExecutionException {@inheritDoc}
       * @throws NullPointerException       {@inheritDoc}
       * @throws IllegalArgumentException   {@inheritDoc}
       */
      public ScheduledFuture<?> scheduleAtFixedRate(Runnable command,
                                                    long initialDelay,
                                                    long period,
                                                    TimeUnit unit) {
          if (command == null || unit == null)
              throw new NullPointerException();
          if (period <= 0)
              throw new IllegalArgumentException();
          ScheduledFutureTask<Void> sft =
              new ScheduledFutureTask<Void>(command,
                                            null,
                                            triggerTime(initialDelay, unit),
                                            unit.toNanos(period));
          RunnableScheduledFuture<Void> t = decorateTask(command, sft);
          sft.outerTask = t;
          delayedExecute(t);
          return t;
      }
  ```

  

- 代码，TimerTask

  ```java
  @Slf4j
  class MyTimerTask extends TimerTask{
  
      @Override
      public void run() {
          log.info("hello");
      }
  }
  public class TimerTaskTest {
      public static void main(String[] args) {
          Timer timer = new Timer();
          Calendar calendar = Calendar.getInstance();
          calendar.set(Calendar.HOUR_OF_DAY, 17);//控制小时
          calendar.set(Calendar.MINUTE, 1);//控制分钟
          calendar.set(Calendar.SECOND, 0);//控制秒
          Date time = calendar.getTime();//执行任务时间为17:01:00
  
          //每天定时17:02执行操作，每5秒执行一次
          timer.schedule(new MyTimerTask(), time, 5000 );
      }
  }
  ```

  

- 代码，ScheduleThreadPoolExecutor

  ```java
  @Slf4j
  public class ScheduleTask {
      public static void main(String[] args) throws InterruptedException {
          ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(3);
          scheduledExecutorService.scheduleAtFixedRate(new Runnable() {
              @Override
              public void run() {
                  log.info("hello world!");
              }
          }, 3, 5, TimeUnit.SECONDS);//10表示首次执行任务的延迟时间，5表示每次执行任务的间隔时间，Thread.sleep(10000);
  
          System.out.println("Shutting down executor...");
          TimeUnit.SECONDS.sleep(4);
          //线程池一关闭，定时器就不会再执行
          scheduledExecutorService.shutdown();
          while (true){}
      }
  }
  /*结果
  Shutting down executor...
  2022-11-28 17:25:06 下午 [Thread: pool-1-thread-1] 
  INFO:hello world!
  
  不会再执行定时任务，因为线程池已经关了*/
  ```

- ScheduleThreadPoolExecutor和Timer的比较
  ![image-20221129092155589](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129092155589.png)![image-20221129092022551](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129092022551.png)

  - Timer对系统时钟变化敏感，ScheduledThreadPoolExecutor不是
  
    > Timer使用的是**System.currentTime()**，而ScheduledThreadPoolExecutor使用的是**System.nanoTime()**

  - Timer**只有一个线程**（导致长时间运行的任务延迟其他任务），ScheduleThreadPoolExecutor**可以配置任意数量线程**

  - TimerTask中抛出运行时异常会杀死一个线程，从而导致Timer死机（即计划任务将不在运行）；而**ScheduleThreadExecutor**不仅**捕获运行时异常**，还允许**需要时处理（afterExecute方法）**，**抛出异常的任务会被取消**而**其他任务将继续运行**

  JDK1.5 之后，没有理由再使用Timer进行任务调度

- 运行机制
  ![image-20221129103700454](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129103700454.png)
  ScheduledThreadPoolExecutor的执行分为：

  1. 当调用scheduleAtFixedRate()或scheduleWithFixedDelay()方法时，会向ScheduleThreadPoolExector的DelayQueue添加一个**实现了RunnableScheduleFuture接口的ScheduleFutureTask(私有内部类)**
  2. 线程池中的线程**从DelayQueue中获取ScheduleFutureTask**，然后执行任务

  为了执行周期性任务，对ThreadPoolExecutor做了如下修改：

  - 使用**DelayQueue**作为任务队列
  - 获取任务的方式不同
  - 获取周期任务**后做了额外处理**

  ![image-20221129104234412](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221129104234412.png)
  **获取任务**，**执行任务**，**修改任务(time)**，**回放(添加)任务**

  > 1. 线程 1 从 `DelayQueue` 中获取已到期的 `ScheduledFutureTask（DelayQueue.take()）`。到期任务是指 `ScheduledFutureTask`的 time 大于等于当前系统的时间；
  > 2. 线程 1 执行这个 `ScheduledFutureTask`；
  > 3. 线程 1 修改 `ScheduledFutureTask` 的 time 变量为下次将要被执行的时间；
  > 4. 线程 1 把这个修改 time 之后的 `ScheduledFutureTask` 放回 `DelayQueue` 中（`DelayQueue.add()`)。

## 线程池大小确定

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

  