---
title: 并发01
description: 并发01
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-10-26 16:46:32
updated: 2022-10-26 21:16:32

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!



- 什么是进程和线程

  - 进程：是程序的**一次执行过程**，是系统运行程序的**基本单位**
    系统运行一个程序，即一个进程从**创建、运行到消亡**的过程

    - 启动main函数则启动了一个JVM进程，**main函数所在线程**为进程中的一个线程，也称**主线程**
    
    - 以下为一个个的进程  
      ![image-20221026212505577](images/mypost/image-20221026212505577.png)
    
      - 查看java进程    
        
      
        ```shell
        jps -l
        32 org.jetbrains.jps.cmdline.Launcher
        10084
        16244 com.Test
        17400 sun.tools.jps.Jps
        ```
      
      - 杀死进程  
      
        ```shell
         taskkill /f /pid 16244
        ```
      
        
    

  - 何为线程

    - 线程，比进程更小的执行单位

    - 同类的**多个线程**共享**进程**的**堆和方法区**资源，但每个线程有自己的**程序计数器、虚拟机栈、本地方法栈**，又被称为**轻量级进程**

    - Java天生就是多线程程序，如：

      ```java
      public class MultiThread {
      	public static void main(String[] args) {
      		// 获取 Java 线程管理 MXBean
      	ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
      		// 不需要获取同步的 monitor 和 synchronizer 信息，仅获取线程和线程堆栈信息
      		ThreadInfo[] threadInfos = threadMXBean.dumpAllThreads(false, false);
      		// 遍历线程信息，仅打印线程 ID 和线程名称信息
      		for (ThreadInfo threadInfo : threadInfos) {
      			System.out.println("[" + threadInfo.getThreadId() + "] " + threadInfo.getThreadName());
      		}
      	}
      }
      //输出
      [5] Attach Listener //添加事件
      [4] Signal Dispatcher // 分发处理给 JVM 信号的线程
      [3] Finalizer //调用对象 finalize 方法的线程
      [2] Reference Handler //清除 reference 线程
      [1] main //main 线程,程序入口
      ```

      也就是说，一个Java程序的运行，是main线程和多个其他线程同时运行
    
  - 请简要描述线程与进程的关系，区别及优缺点

    - 从JVM角度说明
      Java内存区域
      ![image-20221026213728776](images/mypost/image-20221026213728776.png)
      一个**进程拥有多个线程**，多个线程共享进程的**堆**和**方法区（JDK1.8: 元空间）**，每个线程拥有自己的**程序计数器**、**虚拟机栈**、**本地方法栈**
    
  - 总结

    - 线程是**进程划分成的更小运行单位**
    - 线程和进程最大不同在于**各进程基本独立**，而**各线程极有可能**互相影响
    - 线程**开销小**，但**不利于资源保护**；进程反之

  - 程序计数器为什么是私有  
    程序计数器的作用  

    1. **单线程情况下**，**字节码解释器**通过改变程序计数器来**依次读取**指令，从而实现代码的流程控制，如：**顺序执行**、**选择**、**循环**、**异常处理**。
    2. 在多线程的情况下，程序计数器用于记录**当前线程执行的位置**，从而**当线程被切换回来**的时候能够知道该线程上次运行到哪儿了。

    如果执行的是native方法，则程序计数器记录的是**undefined**地址；执行Java方法则记录的是**下一条指令的地址**

    **私有，是为了线程切换后能恢复到正确的执行位置**

  - 虚拟机栈和本地方法栈为什么私有

    - 虚拟机栈：每个Java方法执行时同时会创建一个**栈帧**用于**存储局部变量表**、**操作数栈**、**常量池引用**等信息
    - 本地方法栈：和虚拟机栈类似，区别是**虚拟机栈**为虚拟机执行**Java方法** （字节码）服务，**本地方法栈**则为虚拟机使用到的**Native方法**服务。HotSpot虚拟机中和Java虚拟机栈合二为一
    - 为了保证**线程中局部变量不被别的线程访问**到，**虚拟机栈**和**本地方法栈**是私有的

  - **堆和方法区**是所有线程共享的资源，**堆**是进程中最大一块内存，用于**存放新创建的对象**（几乎所有对象都在这分配内存）; 方法区则存放**已被加载的 ** **类信息、常量、静态变量**、**即时编译器编译后的代码**等数据

- 并发与并行的区别

  - 并发：两个及两个以上的作业在**同一时间段**内执行（线程，同一个代码同一秒只能由一个线程访问）
  - 并行：两个及两个以上的作业**同一时刻**执行
  - 关键点：是否同时执行，**只有并行才能同时执行**

- 同步和异步

  - **同步**：发出调用后，**没有得到结果前**，该**调用不能返回**，一直等待
  - **异步**：发出调用后，**不用等返回结果**，该调用**直接返回**

- 为什么要使用多线程

  - 从计算机底层来说：线程是**轻量级进程**，**程序执行最小单位**，线程间**切换**和**调度** **成本远小于进程**。**多核CPU**时代意味着**多个线程可以同时运行**，**减少线程上下文切换**
  - 从当代互联网发展趋势：如今系统并发量大，利用多线程机制可以大大提高系统整体**并发**能力及性能
  - 深入计算机底层
    - **单核**时代：提高单进程利用CPU和IO系统的效率。当请求IO的时候，如果Java进程中只有一个线程，此线程被IO阻塞则整个进程被阻塞，CPU和IO设备只有一个运行，系统整体效率50%；而多线程时，**如果一个线程被IO阻塞，其他线程还可以继续使用CPU**
    - **多核**时代：多核时代多线程主要是提高**进程利用多核CPU**的能力，如果要计算复杂任务，只有一个线程的话，不论系统几个CPU核心，都只有一个CPU核心被利用；而创建多个线程，**这些线程可以被映射到底层多个CPU**上执行，如果任务中的**多个线程没有资源竞争**，那么执行效率会显著提高

- 多线程带来的问题：**内存泄漏**（对象，没有释放）、**死锁**、**线程不安全**等

- 说说线程的声明周期和状态
  Java线程在运行的生命周期中的指定时刻，只可能处于下面6种不同状态中的一个

  - **NEW**：初始状态，线程被创建出来但没有调用start()

  - **RUNNABLE**：运行状态，线程被调用了start() 等待运行的状态

  - **BLOCKED**：阻塞状态，需要**等待锁释放**

  - **WAITING**：等待状态，表示该线程需要**等待其他线程做出一些特定**动作（**通知**或**中断**）

  - **TIME_WAITING**：超时等待状态，在**指定的时间后自行返回**而不是像WAITING一直等待

  - **TERMINATED**：终止状态，表示该线程**已经运行完毕**
    如图  
    ![image-20221027094635757](images/mypost/image-20221027094635757.png)
    对于该图有以下几点要注意：  

    1. 线程创建后处于**NEW**状态，之后调用**start()**方法运行，此时线程处于**READY**，可运行的线程获得CPU时间片（timeslice）后处于**RUNNING**状态

       > - 操作系统中有READY和RUNNING两个状态，而JVM中只有RUNNABLE状态
       > - 现在的操作系统通常都是**“时间分片“**方法进行**抢占式 轮转调度**“，一个线程最多**只能在CPU上运行10-20ms**的时间（此时处于RUNNING)状态，时间过短，时间片之后放入**调度队列**末尾等待再次调度（回到READY状态），太快所以不区分两种状态
       >   ![image-20221027095421280](images/mypost/image-20221027095421280.png)

    2. 线程执行**wait()**方法后，进入**WAITING(等待 )**状态，进入等待状态的线程需要依靠其他线程**通知**才能回到运行状态 

    3. **TIMED_WAITING(超时等待)**状态，在**等待状态的基础上**增加**超时限制**，通过sleep(long millis)或wait(long millis) 方法可以将线程置于**TIMED_WAITING**状态，超时结束后返回到**RUNNABLE**状态（注意，不是RUNNING）
    
    4. 当线程进入**synchronized**方法/块或者调用wait后(被notify)重新进入**synchronized**方法/块，但是锁被其他线程占有，这个时候线程就会进入BLOCKED（阻塞）状态
    
    5. 线程在执行完了**run()**方法之后就会进入到**TERMINATED（终止）**状态
    
    6. 注意上述，阻塞和等待的区别
  
- 什么是上下文切换

  - 线程在执行过程中会有自己的运行条件和状态（也称上下文），比如上文提到的**程序计数器**，**栈信息**等。当出现下面情况时，线程从**占用CPU状态中退出**：

    1. **主动**让出CPU，如sleep(),wait()等
    2. 时间片用完了
    3. 调用了**阻塞**类型的**系统中断**（请求IO，线程被阻塞）
    4. **被终止**或**结束运行**

    前3种会发生**线程切换**：需要**保存当前线程上下文**，留待线程下次占用CPU的时候恢复，并**加载下一个将要占用CPU的线程上下文**，即所谓的上下文切换

  - 是现代系统基本功能，每次都要**保存信息恢复信息**，将会**占用CPU**，**内存**等系统资源，即**效率有一定损耗**，频繁切换会造成**整体效率低下**

- 线程死锁是什么？如何避免?

  - 多个线程**同时被阻塞**，它们中的一个或者全部，都在**等待某个资源**被释放。由于**线程被无限期地阻塞**，因此**程序不可能正常终止**
  
  - 前提：**线程A持有资源2**，**线程B持有资源1**。现象：线程A在等待申请资源1，线程B在等待申请资源2，所以这两个线程就会**互相等待**而进入**死锁**状态
    ![image-20221028092652845](images/mypost/image-20221028092652845.png)
    使用代码描述上述问题
  
    ```java
    public class DeadLockDemo {
        private static Object resource1 = new Object();//资源 1
        private static Object resource2 = new Object();//资源 2
    
        public static void main(String[] args) {
            new Thread(() -> {
                synchronized (resource1) {
                    System.out.println(Thread.currentThread() + "get resource1");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println(Thread.currentThread() + "waiting get resource2");
                    synchronized (resource2) {
                        System.out.println(Thread.currentThread() + "get resource2");
                    }
                }
            }, "线程 1").start();
    
            new Thread(() -> {
                synchronized (resource2) {
                    System.out.println(Thread.currentThread() + "get resource2");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println(Thread.currentThread() + "waiting get resource1");
                    synchronized (resource1) {
                        System.out.println(Thread.currentThread() + "get resource1");
                    }
                }
            }, "线程 2").start();
        }
    }
    /*
    - 线程A通过synchronized(resource1)获得resource1的监视器锁，然后休眠1s（是为了保证线程B获得执行然后拿到resource2监视器锁）
    - 休眠结束了两线程都企图请求获得对方的资源，陷入互相等待的状态，于是产生了死锁
    */
    ```
  
  - 死锁产生条件
  
    - 互斥：该资源**任意一个时刻只由一个**线程占有
    - 请求与保持：一线程因请求资源而阻塞时，对**已获得**的资源**保持不放**
    - 不剥夺条件：线程**已获得的资源未使用完之前**不能被其他线程强行剥夺，只有自己使用完才释放（资源）
    - 循环等待：若干线程之间形成**头尾相接的循环等待资源**关系
  
- 如何预防死锁--->破坏死锁的必要条件

  - 破坏**请求与保持**条件：一次性申请所有资源
  - 破坏**不剥夺**条件：占用部分资源的线程进一步申请其他资源时，如果申请不到，可以**主动释放**它占有的资源
  - 破坏**循环等待**条件：靠**按需申请资源**来预防（按某顺序申请资源，**释放资源时反序**）

- 如何将避免死锁

  - 在资源分配时，借助于算法（银行家算法)对**资源分配计算评估**，使其进入安全状态

    > **安全状态** 指的是系统能够按照某种线程推进顺序（P1、P2、P3.....Pn）来为每个线程分配所需资源，直到满足每个线程对资源的最大需求，使每个线程都可顺利完成。称 `<P1、P2、P3.....Pn>` 序列为安全序列

  - 修改线程2的代码
    原线程1代码不变

    ```java
    new Thread(() -> {
                synchronized (resource1) {
                    System.out.println(Thread.currentThread() + "get resource1");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println(Thread.currentThread() + "waiting get resource2");
                    synchronized (resource2) {
                        System.out.println(Thread.currentThread() + "get resource2");
                    }
                }
            }, "线程 1").start();
    ```

    线程2代码修改：

    ```java
    new Thread(() -> {
                synchronized (resource1) {
                    System.out.println(Thread.currentThread() + "get resource1");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    System.out.println(Thread.currentThread() + "waiting get resource2");
                    synchronized (resource2) {
                        System.out.println(Thread.currentThread() + "get resource2");
                    }
                }
            }, "线程 2").start();
    /* 输出
  Thread[线程 1,5,main]get resource1
    Thread[线程 1,5,main]waiting get resource2
  Thread[线程 1,5,main]get resource2
    Thread[线程 2,5,main]get resource1
    Thread[线程 2,5,main]waiting get resource2
    Thread[线程 2,5,main]get resource2
    
    Process finished with exit code 0 
    */
    ```
    
    分析  
    
    > 线程 1 首先获得到 resource1 的监视器锁,这时候线程 2 就获取不到了。然后线程 1 再去获取 resource2 的监视器锁，可以获取到。然后**线程 1 释放了对 resource1、resource2 的监视器锁的占用，线程 2 获取到（resource1）就可以执行了**。这样就破坏了破坏循环等待条件，因此避免了死锁。

- sleep()方法和wait()方法对比

  - 共同点： 两者都可暂停线程执行
  - 区别
    1. seep() 方法**没有释放锁**，wait() 方法**释放了锁**
    2. wait() 通常用于**线程间交互/通信**，sleep()用于**暂停执行**
    3. wait()方法被调用后，**线程不会自动苏醒**，需要别的线程调用同一对象（监视器monitor）的**notify()**或者**notifyAll()**方法；sleep()方法执行完成后/或者wait(long timeout)超时后，线程会**自动苏醒**
    4. sleep时Thread类的**静态本地方法**，wait()则是**Object类的本地方法**

- 为什么wait()方法不定义在Thread中
  - wait() 目的是让**获得对象锁的线程**实现等待，会**自动释放当前线程占有的对象锁**
  - 每个**对象(Object)都拥有对象锁**，既然是**让获得对象锁的线程等待**，所以方法应该出现在对象Object上
  - sleep()是**让当前线程暂停执行**，**不涉及对象类**，也**不需要获得对象锁**
- 可以直接调用Thread类的run方法吗
  - new一个Thread之后，线程进入新建状态
  - 调用**start()**，会**启动线程并使他进入就绪**状态（Runable，可运行状态，又分为Ready和Running），分配到时间片后就开始运行
  - start()执行线程相应准备工作，之后**自动执行run()**方法的内容
  - 如果直接执行run()方法，则**会把run()方法当作main线程下普通方法去执行**，并不会在某个线程中执行它
  - 只有调用**start()**方法才可以**启动新的线程**使他**进入就绪**状态，**等待获取时间片后运行**
  
  

