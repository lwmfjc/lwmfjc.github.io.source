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
updated: 2022-11-21 10:54:33

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 线程池

- 为什么要使用线程池

  > - 池化技术：**线程池**、**数据库连接池**、**Http连接池**
  > - 池化技术思想意义：为了减少每次**获取资源**的**消耗**，提高对**资源的利用率**

  - 线程池提供了**限制**和**管理** **资源**(包括执行一个任务)的方式
  - 每个线程池还维护**基本统计信息**，例如**已完成**任务的数量
  - 好处：
    1. **降低资源消耗**  **重复利用已创建线程**降低**线程创建**和**销毁**造成的消耗
    2. 提高响应速度 任务到达时，任务可以**不需等到线程创建**就能继续执行
    3. 提高线程的**可管理性** 线程是稀缺资源，如果无限制创建，不仅**消耗系统资源**，还会**降低系统的稳定性**，使用线程池统一**管理分配**、**调优**和**监控**。

- 实现Runnable接口和Callable接口的区别

  - Runnable接口不会返回接口或抛出检查异常，Callable接口可以

  - Executors可以实现将Runnable对象转换成Callable对象  
    Executors.callable(Runnable task)` 或 `Executors.callable(Runnable task, Object result)  //则两个方法，运行的结果是 Callable<Object>   
    
    ```java
    //一个不指定结果，另一个指定结果  
        public static void main(String[] args) throws Exception {
            Callable<Object> abc = Executors.callable(() -> {
                try {
                    TimeUnit.SECONDS.sleep(2);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("abc");
            },"abcccc");//如果没有"abcccc"，则下面输出null
            FutureTask<Object> futureTask = new FutureTask<>(abc);
            new Thread(futureTask).start();
            Object o = futureTask.get();
            System.out.println("获取值："+o);
        }
    ```

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

     - 这个Future的get()方法来获取返回值，**get()方法会阻塞当前线程**直到任务完成； 使用get(long timeout,TimeUnit unit) 方法会在**阻塞当前线程一段时间后立即返回(此时任务不一定已经执行完)**
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

       当submit一个Callable对象的时候，能从submit返回的Futureget到返回值；当submit一个**FutureTask对象（FutureTask有参构造函数包含Callable对象，但它本身不是Callable）**时，没法获取返回值，因为会**被当作Runnable对象**submit进来

       ![image-20221109103922513](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221109103922513.png)
       而入参为Runnable时返回值里是get不到结果的

  3. 下面这段源码，解释了为什么当传入的类型是Runnable对象时，结果为null  

     > 只要是submit（Runnable ），就会返回null
     
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

    ```java
    /*
    工具的方式创建线程池
    */
    void test(){
        ExecutorService executorService = Executors.newCachedThreadPool();
            Callable<MyClass> myClassCallable = new Callable<MyClass>() 	  {
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
    }
    ```

    > 使用Executors返回线程池对象的弊端：
    >
    > ```java
    > ThreadPoolExecutor(int corePoolSize,
    >                       int maximumPoolSize,
    >                       long keepAliveTime,
    >                       TimeUnit unit,
    >                       BlockingQueue<Runnable> workQueue,
    >                       ThreadFactory threadFactory,
    >                       RejectedExecutionHandler handler){}
    > ```
    >
    > ```java
    > //#####时间表示keepAliveTime#####
    > //########线程数量固定，队列长度为Integer.MAX################
    > Executors.newFixedThreadPool(3);
    > public static ExecutorService newFixedThreadPool(int nThreads) {
    >      return new ThreadPoolExecutor(nThreads, nThreads,
    >                                    0L, TimeUnit.MILLISECONDS,
    >                                    new LinkedBlockingQueue<Runnable>());
    >  }
    > //############线程数量固定，队列长度为Integer.MAX############## 
    > Executors.newSingleThreadExecutor(Executors.defaultThreadFactory());
    > public static ExecutorService newSingleThreadExecutor(ThreadFactory threadFactory) {
    >      return new FinalizableDelegatedExecutorService
    >          (new ThreadPoolExecutor(1, 1,
    >                                  0L, TimeUnit.MILLISECONDS,
    >                                  new LinkedBlockingQueue<Runnable>(),
    >                                  threadFactory));
    > //############线程数量为Integer.MAX############# 
    > Executors.newCachedThreadPool(Executors.defaultThreadFactory());
    > public static ExecutorService newCachedThreadPool(ThreadFactory threadFactory) {
    >      return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
    >                                    60L, TimeUnit.SECONDS,
    >                                    new SynchronousQueue<Runnable>(),
    >                                    threadFactory);
    >  }
    > //#############线程数量为Integer.MAX############# 
    > Executors.newScheduledThreadPool(3, Executors.defaultThreadFactory()); 
    >   public static ScheduledExecutorService newScheduledThreadPool(
    >          int corePoolSize, ThreadFactory threadFactory) {
    >      return new ScheduledThreadPoolExecutor(corePoolSize, threadFactory);
    >  }
    >   ====================>
    > public ScheduledThreadPoolExecutor(int corePoolSize,
    >                                     ThreadFactory threadFactory) {
    >      super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
    >            new DelayedWorkQueue(), threadFactory);
    >  }
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
  由结果可以看出，线程池**先执行5个任务**，此时多出的任务会放到**队列**，那5个任务中**有任务执行完**的话，会拿新的任务执行
  
  ```java
  //源码分析
  // 存放线程池的运行状态 (runState) 和线程池内有效线程的数量 (workerCount)
  private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
  
  private static int workerCountOf(int c) {
      return c & CAPACITY;
  }
  
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
  
  如图
  ![image-20221117140008973](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221117140008973.png)
  分析上面的例子，
  
  > 我们在代码中模拟了 10 个任务，我们配置的核心线程数为 5 、等待队列容量为 100 ，所以每次只可能存在 5 个任务同时执行，剩下的 5 个任务会被放到等待队列中去。当前的5个任务中如果有任务被执行完了，线程池就会去拿新的任务执行。

## Atomic原子类

Atomic ``` 英[əˈtɒmɪk] ```原子，即不可分割

线程中，Atomic，指一个操作是不可中断的，即使在多线程一起执行时，一个操作一旦开始，就不会被其他线程干扰

原子类，即具有**原子/原子操作特性**的类。并发包```java.util.concurrent```原子类都放在```java.util.concurrent.atomit```
![image-20221117152847851](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221117152847851.png)

Java中存在四种原子类（基本、数组、引用、对象属性）

1. 基本类型：AtomicInteger，AtomicLong，AtomicBoolean
2. 数组类型：AtomicIntegerArray，AtomicLongArray，AtomicReferenceArray
3. 引用类型：AtomicReference，AtomicStampedReference（原子更新带有版本号的引用类型。该类将整数值与引用关联，解决原子的更新数据和数据的版本号，解决使用CAS进行原子更新可能出现的ABA问题），AtomicMarkableReference（原子更新带有标记位的引用类型）
4. 对象属性修改类型：AtomicIntegerFiledUpdater原子更新整型字段的更新器；AtomicLongFiledUpdater；AtomicReferenceFieldUpdater

### AtomicInteger的使用

```java
//AtomicInteger类常用方法(下面的自增，都使用了CAS，是同步安全的)
ublic final int get() //获取当前的值
public final int getAndSet(int newValue)//获取当前的值，并设置新的值
public final int getAndIncrement()//获取当前的值，并自增
public final int getAndDecrement() //获取当前的值，并自减
public final int getAndAdd(int delta) //获取当前的值，并加上预期的值
boolean compareAndSet(int expect, int update) //如果输入的数值等于预期值，则以原子方式将该值设置为输入值（update）
public final void lazySet(int newValue)//最终设置为newValue,使用 lazySet 设置之后可能导致其他线程在之后的一小段时间内还是可以读到旧的值。
------
//使用如下
class AtomicIntegerTest {
    private AtomicInteger count = new AtomicInteger();
    //使用AtomicInteger之后，不需要对该方法加锁，也可以实现线程安全。
    public void increment() {
        count.incrementAndGet();
    }

    public int getCount() {
        return count.get();
    }
} 
```

### 浅谈AtomicInteger实现原理

1. 位于Java.util.concurrent.atomic包下，对int封装，提供**原子性的访问和更新**操作，其原子性操作的实现基于CAS（CompareAndSet）
   - CAS，比较并交换，Java并发中lock-free机制的基础，调用Sun的Unsafe的CompareAndSwapInt完成，为native方法，**基于CPU的CAS**指令来实现的，即无阻塞；且为CAS原语
   - CAS：三个参数，1. 当前内存值V 2.旧的预期值  3.即将更新的值，当且仅当预期值A和内存值相同时，将内存值改为 8 并返回true；否则返回false ```在JAVA中,CAS通过调用C++库实现，由C++库再去调用CPU指令集。```
   - CAS确定
     - ABA　问题
       如果期间发生了 A -> B -> A 的更新，仅仅判断数值是 A，可能导致不合理的修改操作；为此，提供了AtomicStampedReference 工具类，为引用建立类似版本号ｓｔａｍｐ的方式
     - 循环时间长，开销大。CAS适用于**竞争情况短暂**的情况，有需要的时候要限制自旋次数，以免过度消耗CPU
     - 只能保证一个共享变量的原子操作
       对多个共享变量操作时，循环CAS就无法保证操作的原子性，这个时候就可以用锁；或者取巧一下，比如 i = 2 , j = a ，合并后为 ij = 2a ，然后cas操作2a 
       
       > Java1.5开始JDK提供了**AtomicReference**类来保证引用对象之间的原子性，你可以把**多个变量放在一个对象**里来进行CAS操作，例子如下：
       > ![image-20221118113655799](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221118113655799.png)
       > 如图，它是同时更新了两个变量，而这两个变量都在新的对象上，所以就能解决多个共享变量的问题，即“将问题转换成，如果变量更新了，则更换一个对象”
   
2. AtomicInteger原理浅析

   一些公共属性：

   ```java
   public class AtomicInteger extends Number implements java.io.Serializable {
       private static final long serialVersionUID = 6214790243416807050L;
   
       // setup to use Unsafe.compareAndSwapInt for updates
       private static final Unsafe unsafe = Unsafe.getUnsafe();
       private static final long valueOffset;
   
       static {
           try {
               valueOffset = unsafe.objectFieldOffset
                   (AtomicInteger.class.getDeclaredField("value"));
           } catch (Exception ex) { throw new Error(ex); }
       }
   
       private volatile int value;
   }
   ```

   AtomicInteger，根据**valueOffset**代表的该变量值，**在内存中的偏移地址**，从而获取数据；且value用volatile修饰，保证多线程之间的可见性

   ```java
   public final int getAndIncrement() {
       return unsafe.getAndAddInt(this, valueOffset, 1);
   }
   
   //unsafe.getAndAddInt
   public final int getAndAddInt(Object var1, long var2, int var4) {
       int var5;
       do {
           var5 = this.getIntVolatile(var1, var2);
       } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));//先获取var1对象的偏移量为var2的内存地址上的值，设置为var5
   //如果此刻还是var5，+1并赋值，否则重新获取
   
       return var5;
   }
   ```

   - 假设线程1和线程2通过getIntVolatile拿到value的值都为1，线程1被挂起，线程2继续执行
   - 线程2在compareAndSwapInt操作中由于预期值和内存值都为1，因此成功将内存值更新为2
   - 线程1继续执行，在compareAndSwapInt操作中，预期值是1，而当前的内存值为2，CAS操作失败，什么都不做，返回false
   - 线程1重新通过getIntVolatile拿到最新的value为2，再进行一次compareAndSwapInt操作，这次操作成功，内存值更新为3

3. 原子操作的实现原理

   - Java中的CAS操作正是利用了处理器提供的CMPXCHG指令实现的。自旋CAS实现的基本思路就是循环进行CAS操作直到操作成功为止。
   - 在CAS中有三个操作数：分别是内存地址（在Java中可以简单理解为变量的内存地址，用V表示）、旧的预期值（用A表示）和新值（用B表示）。CAS指令执行时，当且仅当V符合旧的预期值A时，处理器才会用新值B更新V的值，否则他就不执行更新，但无论是否更新了V的值，都会返回V的旧值。(**这里说的三个值，指的是逻辑概念，而不是实际概念**)

### Java实现CAS的原理

i++是非线程安全的，因为**i++不是原子**操作；可以使用**synchronized和CAS实现加锁**

**synchronized是悲观锁**，一旦获得锁，其他线程进入后就会阻塞等待锁；而**CAS是乐观锁**，执行时不会加锁，假设没有冲突，**如果因为冲突失败了就重试**，直到成功

- 乐观锁和悲观锁

  - 这是一种分类方式
  - **悲观锁**，总是认为**每次访问共享资源会发生冲突**，所以**必须对每次数据操作加锁**，以**保证临界区的程序同一时间只能有一个线程**在执行
  - 乐观锁，又称**“无锁”**，**假设对共享资源访问没有冲突**，线程可以不停的执行，无需加锁无需等待；一旦发生冲突，通常是使用一种称为CAS的技术保证线程执行安全  
    - 无锁没有锁的存在，因此不可能发生死锁，即乐观锁天生免疫死锁
    - 乐观锁用于“读多写少”的环境，避免加锁频繁影响性能；悲观锁用于“写多读少”，避免频繁失败及重试影响性能

- CAS概念，即CompareAndSwap ，比较和交换，CAS中，有三个值（概念上）  
  V：要更新的变量(var)；E：期望值（expected）；N：新值（new）
  判断V是否等于E，如果等于，将V的值设置为N；如果不等，说明已经有其它线程更新了V，则当前线程放弃更新，什么都不做。
  一般来说，预期值E本质上指的是“旧值”（判断是否修改了）

  > 1. 如果有一个多个线程共享的变量`i`原本等于5，我现在在线程A中，想把它设置为新的值6;
  > 2. 我们使用CAS来做这个事情；
  > 3. 首先我们用i去与5对比，发现它等于5，说明没有被其它线程改过，那我就把它设置为新的值6，此次CAS成功，`i`的值被设置成了6；
  > 4. 如果不等于5，说明`i`被其它线程改过了（比如现在`i`的值为2），那么我就什么也不做，此次CAS失败，`i`的值仍然为2。
  >
  > 其中i为V，5为E，6为N

  CAS是一种原子操作，它是一种系统原语，是一条CPU原子指令，从CPU层面保证它的原子性（**不可能出现说，判断了i为5之后，正准备更新它的值，此时该值被其他线程改了**）

  当**多个线程同时使用CAS操作一个变量**时，**只有一个会胜出，并成功更新**，**其余均会失败**，但**失败的线程并不会被挂起**，仅是**被告知失败，并且允许再次尝试**，当然也**允许失败的线程放弃**操作。

- Java实现CAS的原理 - Unsafe类

  - 在Java中，如果一个方法是native的，那Java就不负责具体实现它，而是交给底层的JVM使用c或者c++去实现

  - Java中有一个Unsafe类，在sun.misc包中，里面有一些native方法，其中包括：  

    > ```java
    > boolean compareAndSwapObject(Object o, long offset,Object expected, Object x);
    > boolean compareAndSwapInt(Object o, long offset,int expected,int x);
    > boolean compareAndSwapLong(Object o, long offset,long expected,long x);
    > //AtomicInteger.class
    > public class AtomicInteger extends Number implements java.io.Serializable {
    >     private static final long serialVersionUID = 6214790243416807050L;
    > 
    >     // setup to use Unsafe.compareAndSwapInt for updates
    >     private static final Unsafe unsafe = Unsafe.getUnsafe();
    >     private static final long valueOffset;
    > 
    >     static {
    >         try {
    >             valueOffset = unsafe.objectFieldOffset
    >                 (AtomicInteger.class.getDeclaredField("value"));
    >         } catch (Exception ex) { throw new Error(ex); }
    >     }
    > 
    >     private volatile int value;
    >     public final int getAndIncrement() {
    >     	return unsafe.getAndAddInt(this, valueOffset, 1);
    > 	}
    > }
    > ```

    **Unsafe中对CAS的实现是C++**写的，它的具体实现和操作系统、CPU都有关系。Linux的X86中主要通过cmpxchgl这个指令在CPU级完成CAS操作，如果是多处理器则必须使用lock指令加锁

    Unsafe类中还有park(线程挂起)和unpark(线程恢复)，LockSupport底层则调用了该方法；还有支持反射操作的allocateInstance()

- 原子操作- AtomicInteger类源码简析
  JDK提供了一些原子操作的类，在java.util.concurrent.atomic包下面，JDK11中有如下17个类
  ![image-20221120182811204](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221120182811204.png)

  - 包括 原子更新基本类型，原子更新数组，原子更新引用，原子更新字段(属性)

  - 其中，AtomicInteger类的getAndAdd(int data)

    ```java
     public final int getAndAdd(int delta) {
            return unsafe.getAndAddInt(this, valueOffset, delta);
        }
    //unsafe字段
    private static final jdk.internal.misc.Unsafe U = jdk.internal.misc.Unsafe.getUnsafe();
    //上面方法实际调用
    @HotSpotIntrinsicCandidate
    public final int getAndAddInt(Object o, long offset, int delta) {
        int v;
        do {
            v = getIntVolatile(o, offset);
        } while (!weakCompareAndSetInt(o, offset, v, v + delta));
        return v;
    }
    //对于offset，这是一个对象偏移量，用于获取某个字段相对Java对象的起始地址的偏移量
    /*
    一个java对象可以看成是一段内存，各个字段都得按照一定的顺序放在这段内存里，同时考虑到对齐要求，可能这些字段不是连续放置的，
    
    用这个方法能准确地告诉你某个字段相对于对象的起始内存地址的字节偏移量，因为是相对偏移量，所以它其实跟某个具体对象又没什么太大关系，跟class的定义和虚拟机的内存模型的实现细节更相关。
    */
    public class AtomicInteger extends Number implements java.io.Serializable {
        private static final long serialVersionUID = 6214790243416807050L;
    
        // setup to use Unsafe.compareAndSwapInt for updates
        private static final Unsafe unsafe = Unsafe.getUnsafe();
        private static final long valueOffset;
    
        static {
            try {
                valueOffset = unsafe.objectFieldOffset
                    (AtomicInteger.class.getDeclaredField("value"));
            } catch (Exception ex) { throw new Error(ex); }
        }
    
        private volatile int value;
        public final int getAndIncrement() {
        	return unsafe.getAndAddInt(this, valueOffset, 1);
    	}
    }
    ```

    再重新看这段代码

    ```java
    @HotSpotIntrinsicCandidate
    public final int getAndAddInt(Object o, long offset, int delta) {
        int v;
        do {
            v = getIntVolatile(o, offset);
        } while (!weakCompareAndSetInt(o, offset, v, v + delta));
        return v;
    }
    ```

    这里声明了v，即要返回的值，即不论如何都会返回原来的值(更新成功前的值)，然后新的值为v+delta

    使用do-while保证所有循环至少执行一遍  
    循环体的条件是一个CAS方法：  

    ```java
    public final boolean weakCompareAndSetInt(Object o, long offset,
                                              int expected,
                                              int x) {
        return compareAndSetInt(o, offset, expected, x);
    }
    
    public final native boolean compareAndSetInt(Object o, long offset,
                                                 int expected,
                                                 int x);
    ```

    最终调用了native方法：compareAndSetInt方法

    > 为甚么要经过一层weakCompareAndSetInt，在JDK 8及之前的版本，这两个方法是一样的。
    >
    > 而在JDK 9开始，这两个方法上面增加了@HotSpotIntrinsicCandidate注解。这个注解允许HotSpot VM自己来写汇编或IR编译器来实现该方法以提供性能。也就是说虽然外面看到的在JDK9中weakCompareAndSet和compareAndSet底层依旧是调用了一样的代码，但是不排除HotSpot VM会手动来实现weakCompareAndSet真正含义的功能的可能性。
    >
    > 简单来说，`weakCompareAndSet`操作仅保留了`volatile`自身变量的特性，而除去了happens-before规则带来的内存语义。也就是说，`weakCompareAndSet`**无法保证处理操作目标的volatile变量外的其他变量的执行顺序( 编译器和处理器为了优化程序性能而对指令序列进行重新排序 )，同时也无法保证这些变量的可见性。**这在一定程度上可以提高性能。（没看懂）

    CAS如果旧值V不等于预期值E，它就会更新失败。说明旧的值发生了变化。那我们当然需要返回的是被其他线程改变之后的旧值了，因此放在了do循环体内

- CAS实现原子操作的三大问题

  - ABA问题
  
    - 就是一个值**原来是A，变成了B，又变回了A**。这个时候使用CAS是检查不出变化的，但实际上却被更新了两次
  
    - 在变量前面追加上**版本号或者时间戳**。从JDK 1.5开始，JDK的atomic包里提供了一个类`AtomicStampedReference`类来解决ABA问题
  
    - `AtomicStampedReference`类的`compareAndSet`方法的作用是首先检查当前引用是否等于预期引用，并且检查当前标志是否等于预期标志，如果二者都相等，才使用CAS设置为新的值和标志。
  
      > ```java
      > public boolean compareAndSet(V   expectedReference,
      >                              V   newReference,
      >                              int expectedStamp,
      >                              int newStamp) {
      >     Pair<V> current = pair;
      >     return
      >         expectedReference == current.reference &&
      >         expectedStamp == current.stamp &&
      >         ((newReference == current.reference &&
      >           newStamp == current.stamp) ||
      >          casPair(current, Pair.of(newReference, newStamp)));
      > }
      > ```
  
  - 循环时间长开销大
    
    - CAS多与自旋结合，如果自旋CAS长时间不成功，则会占用大量CPU资源，解决思路是让**JVM支持处理器提供的pause指令**
    
      > pause指令能让自旋失败时cpu睡眠一小段时间再继续自旋，从而使得读操作的频率低很多,为解决内存顺序冲突而导致的CPU流水线重排的代价也会小很多。
    
    - 限制次数（如果可以放弃操作的话）
    
  - 只能保证一个共享变量的原子操作
    - 使用JDK 1.5开始就提供的`AtomicReference`类保证对象之间的原子性，把多个变量放到一个对象里面进行CAS操作；
    - 使用锁。锁内的临界区代码可以保证只有当前线程能操作。

## AQS

- AQS介绍
  全程，AbstractQueuedSynchronizer抽象队列同步器，在java.util.concurrent.locks包下
  ![image-20221121094942039](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221121094942039.png)

  AQS：用来构建锁和同步器的框架，能**简单且高效**地构造出大量应用广泛的同步器，例如ReentrantLock，Semaphore```[ˈseməfɔː(r)]```以及ReentrantReadWriteLock，SynchronousQueue，FutureTask都基于AQS

- AQS原理分析

  **面试不是背题，大家一定要加入自己的思想，即使加入不了自己的思想也要保证自己能够通俗的讲出来而不是背出来**

  AQS 核心思想是，如果被请求的共享资源空闲，则将当前请求资源的线程设置为有效的工作线程，并且将共享资源设置为锁定状态。如果被请求的共享资源被占用，那么就需要一套线程阻塞等待以及被唤醒时锁分配的机制，这个机制 AQS 是用 **CLH 队列锁**实现的，即**将暂时获取不到锁的线程加入到队列**中。 

    > CLH(Craig,Landin and Hagersten)队列是一个**虚拟的双向队列**（虚拟的双向队列即不存在队列实例，仅存在结点之间的关联关系）。AQS 是**将每条请求共享资源的线程封装成一个 CLH 锁队列的一个结点**（Node）来实现锁的分配。
    > 搜索了一下，CLH好像是人名

    AQS（AbstractQueuedSynchronized）原理图   
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

  - AQS定义两种资源共享方式
    - Exclusive 独占：**只有一个线程**能执行，如ReentrantLock，又分公平锁（按照线程在队列中排队顺序，先到者先拿到锁）及非公平锁（当线程要获取锁时，无视队列顺序直接去抢锁，谁抢到就是谁的）
    - Share 共享：**多个线程可同时执行**，如CountDownLatch、Semaphore、CyclicBarrier、ReadWriteLock
  - ReentrantReadWriteLock是组合式，读写锁允许**多个线程同时对某一资源**进行读
  - ★不同定义器同步器征用共享资源的方式不同，**自定义同步器在实现时只需要实现共享资源state的获取与释放方法**，至于具体线程等待队列的维护（获取资源失败入队/唤醒出队等），AQS已经在顶层实现好

- AQS底层使用了模板方法模式
  使用方式  

  1. 使用者继承AbstractQueueSynchronizer并重写指定方法（无**非是对于共享资源state的获取和释放**）

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
  > 一般来说，自定义同步器要么是独占方法，要么是共享方式，他们也只需实现`tryAcquire-tryRelease`、`tryAcquireShared-tryReleaseShared`中的一种即可。但 AQS 也支持自定义同步器同时实现独占和共享两种方式，如`ReentrantReadWriteLock`。 

- AQS组件总结

  - **`Semaphore`(信号量)-允许多个线程同时访问：** `synchronized` 和 `ReentrantLock` 都是一次只允许一个线程访问某个资源，`Semaphore`(信号量)可以指定多个线程同时访问某个资源。
  - **`CountDownLatch `（倒计时器）：** `CountDownLatch` 是一个同步工具类，用来协调多个线程之间的同步。这个工具通常用来控制线程等待，它可以**让某一个线程等待直到倒计时结束**，再开始执行。
  - **`CyclicBarrier`(循环栅栏)：** `CyclicBarrier` 和 `CountDownLatch` 非常类似，它也可以实现线程间的技术等待，但是它的功能比 `CountDownLatch` 更加复杂和强大。主要应用场景和 `CountDownLatch` 类似。`CyclicBarrier` 的字面意思是可循环使用（`Cyclic`）的屏障（`Barrier`）。它要做的事情是，让一组线程到达一个屏障（也可以叫同步点）时被阻塞，直到最后一个线程到达屏障时，屏障才会开门，所有被屏障拦截的线程才会继续干活。`CyclicBarrier` 默认的构造方法是 `CyclicBarrier(int parties)`，其参数表示屏障拦截的线程数量，每个线程调用 `await()` 方法告诉 `CyclicBarrier` 我已经到达了屏障，然后当前线程被阻塞。

- 用过CountDownLatch么，什么场景下用的

  作用：**允许count个线程阻塞在一个地方，直到所有线程的任务都执行完毕**（例子种，需要读取处理6个文件，6个任务没有执行顺序依赖，但是返回的时候，需要将这几个文件的处理结果进行统计整理）


  解析：定义了一个线程池和 count 为 6 的`CountDownLatch`对象 。使用线程池处理读取任务，**每一个线程处理完之后就将 count-1，调用`CountDownLatch`对象的 `await()`方法，直到所有文件读取完之后，才会接着执行后面的逻辑** 

  ```java
  //共享
  public class CountDownLatchExample1 {
      // 处理文件的数量
      private static final int threadCount = 6;
  
      public static void main(String[] args) throws InterruptedException {
          // 创建一个具有固定线程数量的线程池对象（推荐使用构造方法创建）
          ExecutorService threadPool = Executors.newFixedThreadPool(10);
          final CountDownLatch countDownLatch = new CountDownLatch(threadCount);
          for (int i = 0; i < threadCount; i++) {
              final int threadnum = i;
              threadPool.execute(() -> {
                  try {
                      //处理文件的业务操作
                      //......
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  } finally {
                      //表示一个文件已经被完成(将count-1)
                      countDownLatch.countDown();
                  }
  
              });
          }
          countDownLatch.await();//会一直阻塞，直到count为0
          threadPool.shutdown();
          System.out.println("finish");
      }
  } 
  ```

  改进，使用CompletableFuture类改进，该类提供了很多对多线程有好的方式，包括 异步、串行、并行或者等待所有线程执行完任务

  ```java
  CompletableFuture<Void> task1 =
      CompletableFuture.supplyAsync(()->{
          //自定义业务操作
      });
  ......
  CompletableFuture<Void> task6 =
      CompletableFuture.supplyAsync(()->{
      //自定义业务操作
      });
  ......
  CompletableFuture<Void> headerFuture=CompletableFuture.allOf(task1,.....,task6);
  
  try {
      headerFuture.join();
  } catch (Exception ex) {
      //......
  }
  System.out.println("all done. "); 
  ```

  使用循环：  

  ```java
  //文件夹位置
  List<String> filePaths = Arrays.asList(...)
  // 异步处理所有文件
  List<CompletableFuture<String>> fileFutures = filePaths.stream()
      .map(filePath -> doSomeThing(filePath))
      .collect(Collectors.toList());
  // 将他们合并起来
  CompletableFuture<Void> allFutures = CompletableFuture.allOf(
      fileFutures.toArray(new CompletableFuture[fileFutures.size()])
  ); 
  ```

  

## 参考