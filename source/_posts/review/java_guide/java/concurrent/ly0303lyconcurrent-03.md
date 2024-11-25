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

  ```java
  //Callable的用法 
  public class TestLy {
  
      //如果加上volatile,就能保证可见性，线程1 才能停止
        boolean stop = false;//对象属性
  
      public static void main(String[] args) throws InterruptedException, ExecutionException {
          FutureTask<String> futureTask=new FutureTask<>(new Callable<String>() {
              @Override
              public String call() throws Exception {
                  System.out.println("等3s再把结果给你");
                  TimeUnit.SECONDS.sleep(3);
                  return "hello world";
              }
          });
          new Thread(futureTask).start();
          String s = futureTask.get();
          System.out.println("3s后获取到了结果"+s);
  
          new Thread(new Runnable() {
              @Override
              public void run() {
                  System.out.println("abc");
              }
          }).start();
      }
  }
  /*
  等3s再把结果给你
  3s后获取到了结果hello world
  abc
  */
  ```

  

  - Runnable接口不会返回结果或抛出检查异常，Callable接口可以

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

       当submit一个Callable对象的时候，能从submit返回的Future.get到返回值；当submit一个**FutureTask对象（FutureTask有参构造函数包含Callable对象，但它本身不是Callable）**时，没法获取返回值，因为会**被当作Runnable对象**submit进来  

       > 虚线是实现，实线是继承。
       
       ![image-20221109103922513](images/mypost/image-20221109103922513.png)
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

- FutureTask、Thread、Callable、Executors   
  ![image-20230307144132470](images/mypost/image-20230307144132470.png)

- 如何创建线程池

  > ```executor [ɪɡˈzekjətə(r)] 遗嘱执行人(或银行等)```

  关于SynchronousQueue（具有0个元素的阻塞队列）：  

  ```java
          SynchronousQueue<String> synchronousQueue
                  =new SynchronousQueue<>();
          new Thread(()->{
              try {
                  log.info("放入数据A");
                  synchronousQueue.put("A");
              } catch (InterruptedException e) {
                  e.printStackTrace();
              }
              log.info("继续执行");
          },"子线程1").start();
          new Thread(()->{
              try {
                  TimeUnit.SECONDS.sleep(3);
              } catch (InterruptedException e) {
                  e.printStackTrace();
              }
              String poll = null;
              try {
                  poll = synchronousQueue.take();
              } catch (InterruptedException e) {
                  e.printStackTrace();
              }
              log.info(poll);
          },"子线程2").start();
  /**输出
  2023-03-07 15:20:17 下午 [Thread: 子线程1] 
  INFO:放入数据A   ---这里会等待3s(等子线程2 task()消费掉)
  2023-03-07 15:20:20 下午 [Thread: 子线程2] 
  INFO:A
  2023-03-07 15:20:20 下午 [Thread: 子线程1] 
  INFO:继续执行
  */
  ```

  

  - 不允许使用Executors去创建，而是通过new ThreadPoolExecutor的方式：能让写的同学**明确线程池运行规则**，**规避资源耗尽**

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
    >                    int maximumPoolSize,
    >                    long keepAliveTime,
    >                    TimeUnit unit,
    >                    BlockingQueue<Runnable> workQueue,
    >                    ThreadFactory threadFactory,
    >                    RejectedExecutionHandler handler){}
    > ```
    >
    > ```java
    > //#####时间表示keepAliveTime#####
    > //########线程数量固定，队列长度为Integer.MAX################
    > Executors.newFixedThreadPool(3);
    > public static ExecutorService newFixedThreadPool(int nThreads) {
    >   return new ThreadPoolExecutor(nThreads, nThreads,
    >                                 0L, TimeUnit.MILLISECONDS,
    >                                 new LinkedBlockingQueue<Runnable>());
    > }
    > //############线程数量固定，队列长度为Integer.MAX############## 
    > Executors.newSingleThreadExecutor(Executors.defaultThreadFactory());
    > public static ExecutorService newSingleThreadExecutor(ThreadFactory threadFactory) {
    >   return new FinalizableDelegatedExecutorService
    >       (new ThreadPoolExecutor(1, 1,
    >                               0L, TimeUnit.MILLISECONDS,
    >                               new LinkedBlockingQueue<Runnable>(),
    >                               threadFactory));
    > //############线程数量为Integer.MAX############# 
    > Executors.newCachedThreadPool(Executors.defaultThreadFactory());
    > public static ExecutorService newCachedThreadPool(ThreadFactory threadFactory) {
    >   return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
    >                                 60L, TimeUnit.SECONDS,
    >                                 new SynchronousQueue<Runnable>(),
    >                                 threadFactory);
    > }
    > //#############线程数量为Integer.MAX############# 
    > Executors.newScheduledThreadPool(3, Executors.defaultThreadFactory()); 
    > public static ScheduledExecutorService newScheduledThreadPool(
    >       int corePoolSize, ThreadFactory threadFactory) {
    >   return new ScheduledThreadPoolExecutor(corePoolSize, threadFactory);
    > }
    > ====================>
    > public ScheduledThreadPoolExecutor(int corePoolSize,
    >                                  ThreadFactory threadFactory) {
    >   super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
    >         new DelayedWorkQueue(), threadFactory);
    > }
    > 
    > ```
    >
    > 
    >
    > - **FixedThreadPool**和**SingleThreadExecutor**：这两个方案允许请求的队列长度为Integer.MAX_VALUE，可能**堆积大量请求**，导致OOM
    > - **CachedThreadPool**和**ScheduledThreadPool**：允许创建的线程数量为Integer.MAX_VALUE，可能**创建大量线程**，导致OOM

  - 通过构造方法实现
    ![image-20221109171604573](images/mypost/image-20221109171604573.png)

  - 通过Executor框架的工具类Executors来实现
    以下三个方法，返回的类型都是ThreadPoolExecutor

    - FixedThreadPool : 该方法返回**固定线程数量**的线程池，线程数量**始终不变**。当有新任务提交时，线程池中若有空闲线程则立即执行；若没有，则新任务被暂存到任务队列中，待有线程空闲时，则处理在任务队列中的任务
    - SingleThreadExecutor：方法返回一个**只有一个线程**的线程池。若多余一个任务被提交到该线程池，任务被保存到一个任务队列中，待线程空闲，按先进先出的顺序执行队列中任务
    - CachedThreadPool：该方法返回一个**根据实际情况调整线程数量**的线程池。
      数量不固定，若有空闲线程可以复用则**优先使用可复用**线程。若**所有线程均工作，此时又有新任务**提交，则**创建新线程**处理任务。所有线程在当前任务执行完毕后返回线程池进行复用

    Executors工具类中的方法  
    ![image-20221110104950618](images/mypost/image-20221110104950618.png)

  - 核心线程数和最大线程数有什么区别？
    该类提供四个构造方法，看最长那个，其余的都是（给定默认值后）调用这个方法

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
  - 构造函数重要参数分析  
      **corePoolSize** : 核心线程数定义**最小可以运行的线程数**量  
      **maximumPoolSize**: 当队列中存放的任务**达到队列容量时**，当前可以同时运行的线程数量**变为最大线程数**  
      **workQueue**：当新线程来的时候先判断当前运行线程数量是否**达到核心**线程数，如果达到的话，**新任务就会被存放在队列**中
      ThreadPoolExecutor其他常见参数：  

    1. keepAliveTime：如果线程池中的线程数量大于corePoolSize时，如果这时**没有新任务提交**，**核心线程外**的线程**不会立即销毁**，而是等待，**等待的时间超过了keepAliveTime**就会被回收
    
    2. unit: keepAliveTime参数的**时间单位**
    
    3. **threadFactory**: **executor创建新线程**的时候会用到
    
    4. handle: 饱和策略
    
       > 如果**同时运行的线程数量**达到**最大线程数**，且**队列已经被放满**任务，ThreadPoolTaskExecutor定义该情况下的策略：
       >
       > - **`ThreadPoolExecutor.AbortPolicy`：** 抛出 **`RejectedExecutionException`**来**拒绝**新任务的处理。
       > - **`ThreadPoolExecutor.CallerRunsPolicy`：** 调用**执行自己的线程(如果在main方法中，那就是main线程)**运行任务，也就是直接在**调用`execute`方法的线程**中**运行(`run`)被拒绝的任务**，如果**执行程序已关闭，则会丢弃该任务**。因此这种策略会降低对于新任务提交速度，影响程序的整体性能。如果您的应用程序可以承受此延迟并且你要求任何一个任务请求都要被执行的话，你可以选择这个策略。
       > - **`ThreadPoolExecutor.DiscardPolicy`：** 不处理新任务，直接丢弃掉。
       > - **`ThreadPoolExecutor.DiscardOldestPolicy`：** 此策略将**丢弃最早的未处理**的任务请求。
       
       举个例子：如果在**Spring中通过ThreadPoolTaskExecutor**或**直接通过ThreadPoolExecutor**构造函数创建线程池时，若**不指定RejectExcecutorHandler**饱和策略则默认使用**ThreadPoolExecutor.AbortPolicy**，即**抛出RejectedExecution**来拒绝新来的任务；对于可伸缩程序，**建议使用ThreadPoolExecutor.CallerRunsPolicy**， 

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
                    KEEP_ALIVE_TIME,8
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

- 线程池原理是什么？
  
  > 由结果可以看出，线程池**先执行5个任务**，此时多出的任务会放到**队列**，那5个任务中**有任务执行完**的话，会拿新的任务执行
  
  **为了搞懂线程池的原理，我们需要首先分析一下 `execute`方法。**
  
  我们可以使用 `executor.execute(worker)`来提交一个任务到线程池中去，这个方法非常重要，下面我们来看看它的源码：
  
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
  ![image-20221117140008973](images/mypost/image-20221117140008973.png)
  分析上面的例子，
  
  > 我们在代码中模拟了 10 个任务，我们配置的核心线程数为 5 、等待队列容量为 100 ，所以每次只可能存在 5 个任务同时执行，剩下的 5 个任务会被放到等待队列中去。当前的5个任务中如果有任务被执行完了，线程池就会去拿新的任务执行。
  
  addWorker 这个方法主要用来**创建新的工作线程**，如果返回 true 说明**创建和启动工作线程成功**，否则的话返回的就是 false。
  
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
  ```
  

**如何设定线程池的大小**  

- 如果线程池中的线程太多，就会增加**上下文切换**的成本

  > 多线程编程中**一般线程的个数**都**大于 CPU 核心的个数**，而**一个 CPU 核心**在**任意时刻**只能**被一个线程**使用，为了让这些线程都能得到有效执行，CPU 采取的策略是为**每个线程分配时间片并轮转**的形式。当**一个线程的时间片用完**的时候就会**重新处于就绪状态让给其他线程**使用，这个过程就属于**一次上下文切换**。概括来说就是：当前任务在执行完 CPU 时间片切换到另一个任务之前会先保存自己的状态，以便下次再切换回这个任务时，可以再加载这个任务的状态。**任务从保存到再加载的过程就是一次上下文切换**。
  >
  > 上下文切换通常是**计算密集型**的。也就是说，它需要相当可观的处理器时间，在每秒几十上百次的切换中，每次切换都需要纳秒量级的时间。所以，**上下文切换对系统来说意味着消耗大量的 CPU 时间**，事实上，可能是操作系统中时间消耗最大的操作。
  >
  > **Linux** 相比与其他操作系统（包括其他类 Unix 系统）有很多的优点，其中有一项就是，其**上下文切换和模式切换的时间消耗非常少**。

- 过大跟过小都不行

  - 如果我们设置的**线程池数量太小**的话，如果同一时间有大量任务/请求需要处理，可能会导致大**量的请求/任务在任务队列中排队等待执行**，甚至会出现**任务队列满了**之后任务/请求**无法处理**的情况，或者大量任**务堆积在任务队列导致 OOM**
  - 设置线程**数量太大**，**大量线程可能会同时在争取 CPU 资源**，这样会导致**大量的上下文切换**，从而**增加线程的执行时间**，影响了整体执行效率（**对于CPU密集型任务不能使用这个，因为本来CPU资源就紧张**，需要设置小一点，减小上下文切换）

- 简单且适用面较广的公式

  - **CPU 密集型任务(N+1)：** 这种**任务消耗的主要是 CPU 资源**，可以将线程数设置为 N（CPU 核心数）+1，比 CPU 核心数多出来的一个线程是为了防止**线程偶发的缺页中断**，或者**其它原因导致的任务暂停**而带来的影响。**一旦任务暂停，CPU 就会处于空闲状态，而在这种情况下多出来的一个线程就可以充分利用 CPU 的空闲时间**。

  - **I/O 密集型任务(2N)：** 这种任务应用起来，系统会用**大部分的时间来处理 I/O 交互**，而**线程在处理 I/O 的时间段内不会占用 CPU 来处理**，这时就可以将 CPU 交出给其它线程使用。因此**在 I/O 密集型任务的应用中，我们可以多配置一些线程**，具体的计算方法是 2N。

  - > 如何判断是CPU密集任务还是IO密集任务
    >
    > CPU 密集型简单理解就是**利用 CPU 计算能力**的任务比如你在**内存中对大量数据进行排序**。但凡涉及到**网络读取**，**文件读取**这类都是 **IO 密集型**，这类任务的特点是 **CPU 计算耗费时间**相比于等待 **IO 操作**完成的时间来说很少，大部分时间都花在了**等待 IO 操作**完成上。
    >
  
   ![image-20230307155552472](images/mypost/image-20230307155552472.png)

## Atomic原子类

Atomic ``` 英[əˈtɒmɪk] ```原子，即不可分割

线程中，Atomic，指一个操作是不可中断的，即使在多线程一起执行时，一个操作一旦开始，就不会被其他线程干扰

原子类，即具有**原子/原子操作特性**的类。并发包```java.util.concurrent```原子类都放在```java.util.concurrent.atomit```
![image-20221117152847851](images/mypost/image-20221117152847851.png)

Java中存在四种原子类（基本、数组、引用、对象属性）

1. 基本类型：AtomicInteger，AtomicLong，AtomicBoolean
2. 数组类型：AtomicIntegerArray，AtomicLongArray，AtomicReferenceArray
3. 引用类型：AtomicReference，AtomicStampedReference（[**原子更新**] **带有版本号的引用类型**。该类将整数值与引用关联，解决原子的更新数据和数据的版本号，解决使用CAS进行原子更新可能出现的ABA问题），AtomicMarkableReference（原子更新带有标记位的引用类型）
4. 对象属性修改类型：AtomicIntegerFiledUpdater原子更新整型字段的更新器；AtomicLongFiledUpdater；AtomicReferenceFieldUpdater

[详见](/2022/12/05/review/java_guide/java/concurrent/atomic-classes) 


## AQS

- AQS介绍
  全程，AbstractQueuedSynchronizer抽象队列同步器，在java.util.concurrent.locks包下
  ![image-20221121094942039](images/mypost/image-20221121094942039.png)
AQS是一个抽象类，主要用来**构建锁**和**同步器**    
  
  ```java
  public abstract class AbstractQueuedSynchronizer extends AbstractOwnableSynchronizer implements java.io.Serializable {
  } 
  ```

  AQS 为**构建锁**和**同步器**提供了一些通用功能的实现，能**简单且高效**地构造出大量应用广泛的同步器，例如ReentrantLock，Semaphore```[ˈseməfɔː(r)]```以及ReentrantReadWriteLock，SynchronousQueue 等等都基于AQS

- AQS原理分析

  **面试不是背题，大家一定要加入自己的思想，即使加入不了自己的思想也要保证自己能够通俗的讲出来而不是背出来**

  AQS 核心思想是，如果**被请求的共享资源空闲**，则将**当前请求资源的线程**设置为**有效**的工作线程，并且将**共享资源**设置为**锁定**状态。如果被请求的共享资源**被占用**，那么就需要**一套线程阻塞等待**以及**被唤醒时锁分配的机制**，这个机制 AQS 是用 **CLH 队列锁**实现的，即**将暂时获取不到锁的线程加入到队列**中。 

    > CLH(Craig,Landin and Hagersten)队列是一个**虚拟的双向队列**（虚拟的双向队列即不存在队列实例，仅存在结点之间的关联关系）。AQS 是**将每条请求共享资源的线程封装成一个 CLH 锁队列的一个结点**（Node）来实现锁的分配。
    > 搜索了一下，CLH好像是人名

  CLH队列结构如下图所示  
  ![img](images/mypost/40cb932a64694262993907ebda6a0bfe%7Etplv-k3u1fbpfcp-zoom-1.image)
  
    AQS（AbstractQueuedSynchronized）原理图   
    ![image-20221120193141243](images/mypost/image-20221120193141243.png)
  
  AQS 使用 **int 成员变量 `state` 表示同步状态**，通过内置的 **线程等待队列** 来完成获取资源线程的**排队**工作。
  
  ```java
  //state 变量由 volatile 修饰，用于展示当前临界资源的获锁情况。
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
  
  1. 以 **`ReentrantLock`** 为例，**`state` 初始值为 0**，表示未锁定状态。A 线程 **`lock()`** 时，会调用 **`tryAcquire()`** 独占该锁并将 **`state+1`** 。此后，其他线程再 `tryAcquire()` 时就会失败，**直到 A 线程 `unlock()` 到 `state=`0（即释放锁）为止**，其它线程才有机会获取该锁。当然，**释放锁之前，A 线程自己是可以重复获取此锁的（`state` 会累加）**，这就是**可重入**的概念。但要注意，获取多少次就要释放多少次，这样才能保证 state 是能回到零态的。
  
  2. 以 **`CountDownLatch`** 为例，任务分为 N 个子线程去执行，`state` 也初始化为 N（注意 **N 要与线程个数一致**）。这 **N 个子线程是并行执行**的，**每个子线程执行完后`countDown()`** 一次，state 会 **CAS(Compare and Swap) 减 1**。等到所有子线程都执行完后(即 `state=0` )，会 **`unpark()` 主调用线**程，然后**主调用线程就会从 `await()` 函数返回**，继续后余动作  
  
     ```java
     //例子  
     public class TestCountDownLatch {
         public static void main(String[] args) {
              CountDownLatch countDownLatch=new CountDownLatch(3);
              new Thread(()->{
                  try {
                      TimeUnit.SECONDS.sleep(1);
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }
                  System.out.println(Thread.currentThread().getName()+"执行完毕");
                  countDownLatch.countDown();
              },"线程1").start();
             new Thread(()->{
                 try {
                     TimeUnit.SECONDS.sleep(2);
                 } catch (InterruptedException e) {
                     e.printStackTrace();
                 }
                 System.out.println(Thread.currentThread().getName()+"执行完毕");
                 countDownLatch.countDown();
             },"线程2").start();
             new Thread(()->{
                 try {
                     TimeUnit.SECONDS.sleep(3);
                 } catch (InterruptedException e) {
                     e.printStackTrace();
                 }
                 System.out.println(Thread.currentThread().getName()+"执行完毕");
                 countDownLatch.countDown();
             },"线程3").start();
             try {
                 System.out.println(Thread.currentThread().getName()+"等待中....");
                 countDownLatch.await();//阻塞
                 System.out.println(Thread.currentThread().getName()+"等待完毕，继续执行");
             } catch (InterruptedException e) {
                 e.printStackTrace();
             }
         }
     }
     /*
     main等待中....
     线程1执行完毕
     线程2执行完毕
     线程3执行完毕
     main等待完毕，继续执行
     */
     ```

### Semaphore

- Semaphore 有什么用？
  `synchronized` 和 `ReentrantLock` 都是一次只允许一个线程访问某个资源，而`Semaphore`(信号量)可以用来**控制同时访问特定资源的线程数量**。

  ```java
  //使用  
  public class TestSemaphore {
      public static void main(String[] args) {
          Semaphore semaphore = new Semaphore(3);//能同时运行3个
  
          for (int i = 0; i < 15; i++) {
              int finalI = i;
              new Thread(() -> {
                  try {
                      semaphore.acquire();//获取通行证
                      System.out.println(Thread.currentThread().getName() + "执行中...");
                      TimeUnit.SECONDS.sleep(finalI);
                      System.out.println(Thread.currentThread().getName() + "释放了通行证");
                      semaphore.release();
                  } catch (InterruptedException e) {
                      e.printStackTrace();
                  }
              },"线程"+finalI).start();
          }
      }
  }
  /*结果
  线程0执行中...
  线程2执行中...
  线程1执行中...
  线程0释放了通行证
  线程3执行中...
  线程1释放了通行证
  线程4执行中...
  线程2释放了通行证
  线程5执行中...
  线程3释放了通行证
  线程6执行中...
  线程4释放了通行证
  线程7执行中...
  线程5释放了通行证
  线程8执行中...
  线程6释放了通行证
  线程10执行中...
  线程7释放了通行证
  线程11执行中...
  线程8释放了通行证
  线程9执行中...
  线程10释放了通行证
  线程12执行中...
  线程11释放了通行证
  线程13执行中...
  线程9释放了通行证
  线程14执行中...
  线程12释放了通行证
  线程13释放了通行证
  线程14释放了通行证
  */
  ```

  Semaphore 的使用简单，我们这里假设有 N(N>5) 个线程来获取 `Semaphore` 中的共享资源，下面的代码表示**同一时刻** N 个线程中**只有 5 个线程**能**获取到**共享资源，其他线程都会阻塞，**只有获取到共享资源的线程才能执行**。等到有线程释放了共享资源，其他阻塞的线程才能获取到

  ```java
  // 初始共享资源数量
  final Semaphore semaphore = new Semaphore(5);
  // 获取1个许可
  semaphore.acquire();
  // 释放1个许可
  semaphore.release(); 
  ```

  当初始的资源个数为 **1** 的时候，`Semaphore` 退化为**排他锁**。

  Semaphore对应的两个构造方法  

  ```java
  public Semaphore(int permits) {
    	sync = new NonfairSync(permits);
  }
  
  public Semaphore(int permits, boolean fair) {
    	sync = fair ? new FairSync(permits) : new NonfairSync(permits);
  } 
  ```

  这两个构造方法，都**必须提供许可的数量**，第二个构造方法可以指定是**公平模式**还是**非公平模式**，默认非公平模式。  
  `Semaphore` 通常用于那些**资源有明确访问数量限制**的场景比如限流（**仅限于单机**模式，实际项目中推荐使用 **Redis** +**Lua** 来做限流）。
  
- Semaphore 的原理是什么？  

  > `Semaphore` 是共享锁的一种实现，它默认构造 AQS 的 `state` 值为 `permits`，你可以将 `permits` 的值理解为许可证的数量，只有拿到许可证的线程才能执行。
  >
  > 调用`semaphore.acquire()` ，**线程尝试获取许可证**，如果 **`state >= 0` 的话，则表示可以获取成功**。如果获取成功的话，使用 **CAS** 操作去**修改 `state` 的值 `state=state-1`**。如果 **`state<0`** 的话，则表示**许可证数量不足**。此时会**创建一个 Node 节点加入阻塞队列**，**挂起当前线程**。

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

  调用`semaphore.release();` ，线程尝试释放许可证，并**使用 CAS 操作去修改 `state` 的值 `state=state+1`**。释放许可证成功之后，同时会**唤醒同步队列中的一个线程**。被唤醒的线程会重新**尝试去修改 `state` 的值 `state=state-1`** ，如果 **`state>=0` 则获取令牌成功**，否则重新进入阻塞队列，挂起线程。

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

### CountDownLatch

- CountDownLatch有什么用

  1. `CountDownLatch` 允许 **`count` 个线程阻塞在一个地方(一般例子是阻塞在主线程中 ```countDownLatch.await()```)**，直至所有线程的任务都执行完毕**(再从阻塞的地方继续执行)**。
  2. `CountDownLatch` 是**一次性**的，计数器的值只能在构造方法中初始化一次，之后没有任何机制再次对其设置值，当 **`CountDownLatch` 使用完毕**后，它**不能再次被使用**。

- CountDownLatch的原理是什么
   `CountDownLatch` 是共享锁的一种实现,它默认构造 **AQS 的 `state` 值为 `count`**。当线程使用 `countDown()` 方法时,其实使用了**`tryReleaseShared`**方法**以 CAS 的操作来减少 `state`,**直至 `state` 为 0 。当调用 **`await()`** 方法的时候，**如果 `state` 不为 0**，那就证明任务还没有执行完毕，`await()` 方法就会**一直阻塞**，也就是说 **`await()` 方法之后的语句不会被执行**。然后，**`CountDownLatch` 会自旋 CAS 判断 `state == 0`**，如果 **`state == 0`** 的话，就会**释放所有等待的线程**，**`await()` 方法之后的语句得到执行**。

- 用过 CountDownLatch 么？什么场景下用的？  
   `CountDownLatch` 的作用就是 **允许 count 个线程阻塞在一个地方**，直至所有线程的任务都执行完毕。之前在项目中，有一个**使用多线程读取多个文件**处理的场景，我用到了 `CountDownLatch` 。具体场景是下面这样的：

  我们要读取处理 6 个文件，这 6 个任务都是没有执行顺序依赖的任务，但是我们需要**返回给用户的时候将这几个文件的处理的结果进行统计整理**。

  为此我们定义了一个线程池和 count 为 6 的`CountDownLatch`对象 。使用线程池处理读取任务，每一个线程处理完之后就将 count-1，调用`CountDownLatch`对象的 `await()`方法，直到所有文件读取完之后，才会接着执行后面的逻辑。

  ```java
  //伪代码  
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
                      //表示一个文件已经被完成
                      countDownLatch.countDown();
                  }
  
              });
          }
          countDownLatch.await();
          //这里应该是要对threadCound个线程的结果，进行汇总
          threadPool.shutdown();
          System.out.println("finish");
      }
  } 
  ```

  **上面的例子，也可以用CompletableFuture进行改进**  

  > Java8 的 `CompletableFuture` 提供了很多对多线程友好的方法，使用它可以很方便地为我们编写多线程程序，什么异步、串行、并行或者等待所有线程执行完任务什么的都非常方便。

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

  **通过循环添加任务**  

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

### CyclicBarrier

```java
//使用场景，不太一样的是，它一般是让子任务阻塞后，到时候一起执行 
public class TestCyclicBarrier {
    public static void main(String[] args) {
        CyclicBarrier cyclicBarrier = new CyclicBarrier(3, () -> {
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + "执行咯");
        });
        for (int n = 0; n < 15; n++) {
            int finalN = n;
            new Thread(() -> {
                try {
                    TimeUnit.SECONDS.sleep(finalN);
                    System.out.println(Thread.currentThread().getName() + "数据都准备好了,等待中....");
                    cyclicBarrier.await();
                } catch (InterruptedException | BrokenBarrierException e) {
                    e.printStackTrace();
                }
                System.out.println(Thread.currentThread().getName() + "出发咯!");
            }, "线程" + n).start();
        }
    }
}
/*
线程0数据都准备好了,等待中....
线程1数据都准备好了,等待中....
线程2数据都准备好了,等待中....
线程3数据都准备好了,等待中....
线程4数据都准备好了,等待中....
线程5数据都准备好了,等待中....
线程2执行咯
线程2出发咯!
线程6数据都准备好了,等待中....
线程7数据都准备好了,等待中....
线程8数据都准备好了,等待中....
线程5执行咯
线程5出发咯!
线程0出发咯!
线程1出发咯!
线程9数据都准备好了,等待中....
线程10数据都准备好了,等待中....
线程11数据都准备好了,等待中....
线程8执行咯
线程3出发咯!
线程8出发咯!
线程4出发咯!
线程12数据都准备好了,等待中....
线程13数据都准备好了,等待中....
线程14数据都准备好了,等待中....
线程11执行咯
线程11出发咯!
线程6出发咯!
线程7出发咯!
线程14执行咯
线程14出发咯!
线程12出发咯!
线程10出发咯!
线程9出发咯!
线程13出发咯!

Process finished with exit code 0


*/
```

- CyclicBarrier 有什么用？  
  `CyclicBarrier` 和 `CountDownLatch` 非常类似，它也可以实现**线程间的技术等待**，但是它的功能比 `CountDownLatch` 更加复杂和强大。**主要应用场景和 `CountDownLatch` 类似**。

  > `CountDownLatch` 的实现是基于 AQS 的，而 `CycliBarrier` 是基于 **`ReentrantLock`(`ReentrantLock` 也属于 AQS 同步器)**和 **`Condition`** 的。

  `CyclicBarrier` 的字面意思是**可循环使用（Cyclic）的屏障（Barrier）**。它要做的事情是：**让一组线程到达一个屏障（也可以叫同步点）时被阻塞**，**直到最后一个线程到达屏障**时，屏障才会开门，所有**被屏障拦截的线程**才会继续干活。

- CyclicBarrier的原理  
  `CyclicBarrier` 内部通过一个 `count` 变量作为计数器，`count` 的**初始值为 `parties`** 属性的初始化值，**每当一个线程到了栅栏**这里了，那么就将**计数器减 1**。如果 count 值为 0 了，表示这是这一代最后一个线程到达栅栏，就尝试**执行我们构造方法中输入的任务，之后再从线程阻塞的位置继续执行**。  

  ```java
  //每次拦截的线程数, 注意：这个是不可变的哦
  private final int parties;
  //计数器
  private int count;
  ```

  **结合源码**

  1. `CyclicBarrier` 默认的构造方法是 `CyclicBarrier(int parties)`，其参数表示**屏障拦截的线程数量**，每个线程调用 **`await()`** 方法告诉 **`CyclicBarrier` 我已经到达了屏障**，然后当前**线程被阻塞**。  

     ```java
     public CyclicBarrier(int parties) {
         this(parties, null);
     }
     
     public CyclicBarrier(int parties, Runnable barrierAction) {
         if (parties <= 0) throw new IllegalArgumentException();
         this.parties = parties;
         this.count = parties;
         this.barrierCommand = barrierAction;
     } 
     ```

     其中，`parties` 就代表了有（需要）**拦截的线程的数量**，当**拦截的线程数量达到这个值**的时候就打开栅栏，让所有线程通过。

  2. 当调用 `CyclicBarrier` 对象调用 `await()` 方法时，实际上调用的是 `dowait(false, 0L)`方法。 `await()` 方法就像**树立起一个栅栏**的行为一样，将线程挡住了，当**拦住的线程数量达到 `parties`** 的值时，栅栏才会打开，线程才得以通过执行  

     ```java
     ublic int await() throws InterruptedException, BrokenBarrierException {
       try {
         	return dowait(false, 0L);
       } catch (TimeoutException toe) {
        	 throw new Error(toe); // cannot happen
       }
     } 
     ```

  3. ```dowait(false,0L)```方法源码如下  

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
                 // cout减1
                 int index = --count;
                 // 当 count 数量减为 0 之后说明最后一个线程已经到达栅栏了，也就是达到了可以执行await 方法之后的条件
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

### 三者区别

![image-20230307233809052](images/mypost/image-20230307233809052.png)

**CountDownLatch也能实现CyclicBarrier类似功能，不过它的栅栏被推到后就不会再重新存在了(CyclicBarrier会重新建立栅栏)**

```java
CountDownLatch countDownLatch=new CountDownLatch(5);
        new Thread(()->{
            try {
                countDownLatch.await();
                log.info("栅栏被推开了");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        },"线程A").start();
        new Thread(()->{
            try {
                countDownLatch.await();
                log.info("栅栏被推开了");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        },"线程B").start();
        new Thread(()->{
            try {
                countDownLatch.await();
                log.info("栅栏被推开了");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        },"线程C").start();
        new Thread(()->{
            try {
                countDownLatch.await();
                log.info("栅栏被推开了");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        },"线程D").start();
        new Thread(()->{
            try {
                countDownLatch.await();
                log.info("栅栏被推开了");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        },"线程E").start();
        new Thread(()->{
                //countDownLatch.await();
            for(int i=0;i<5;i++) {
                //每隔一秒钟推开一个栅栏
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                log.info("推开一个栅栏");
                countDownLatch.countDown();
            }

        },"线程F").start();
        while (true){}
        
/**输出
2023-03-07 23:23:19 下午 [Thread: 线程F] 
INFO:推开一个栅栏
2023-03-07 23:23:20 下午 [Thread: 线程F] 
INFO:推开一个栅栏
2023-03-07 23:23:21 下午 [Thread: 线程F] 
INFO:推开一个栅栏
2023-03-07 23:23:22 下午 [Thread: 线程F] 
INFO:推开一个栅栏
2023-03-07 23:23:24 下午 [Thread: 线程F] 
INFO:推开一个栅栏
///////////////////////////////////////////推开5个栅栏后(这里是一个线程推开五个，也可以5个线程->每个各推开一个)，5个被阻塞的线程一起执行了
2023-03-07 23:23:24 下午 [Thread: 线程A] 
INFO:栅栏被推开了
2023-03-07 23:23:24 下午 [Thread: 线程E] 
INFO:栅栏被推开了
2023-03-07 23:23:24 下午 [Thread: 线程C] 
INFO:栅栏被推开了
2023-03-07 23:23:24 下午 [Thread: 线程D] 
INFO:栅栏被推开了
2023-03-07 23:23:24 下午 [Thread: 线程B] 
INFO:栅栏被推开了

*/
```

