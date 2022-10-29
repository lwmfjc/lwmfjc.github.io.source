---
title: 并发02
description: 并发02
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-10-28 14:15:06
updated: 2022-10-28 14:15:06
---

## JMM（JavaMemoryModel)

详见-知识点

## volatile关键字

- 保证变量可见性

  - 使用volatile关键字保证变量可见性，如果将变量声明为volatile则**指示JVM该变量是共享且不稳定**的，每次使用它都到**主存**中读取
    ![image-20221028150859646](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221028150859646.png)
    原始意义即金庸CPU缓存
  - volatile关键字只能保证数据可见性，不能保证数据原子性。synchronized关键字两者都能保证

- 如何禁止指令重排
  使用**volatile**关键字，能**防止JVM指令重排**。当我们对这个变量进行读写操作的时候，-会通过插入特定的**内存屏障**来禁止指令重排

  - Java中，提供了三个关于**内存屏障**相关的方法，屏蔽了操作系统底层的差异，可以用来实现和volatile禁止重排序的效果

      ```java
      public native void loadFence(); //读指令屏障
      public native void storeFence(); //写指令屏障
      public native void fullFence(); //读写指令屏障
      ```

  - 例子（通过双重校验锁实现对象单例），保证线程安全
  
      ```java
      public class Singleton {
      
          private volatile static Singleton uniqueInstance;
      
          private Singleton() {
          }
      
          public  static Singleton getUniqueInstance() {
             //先判断对象是否已经实例过，没有实例化过才进入加锁代码
              if (uniqueInstance == null) {
                  //类对象加锁
                  synchronized (Singleton.class) {
                      if (uniqueInstance == null) {
                          uniqueInstance = new Singleton();
                      }
                  }
              }
              return uniqueInstance;
          }
      }
      ```
  
      这里，uniqueInstance采用volatile的必要性：主要分析``` uniqueInstance  = new Singleton(); ```分三步
  
      1. 为uniqueInstance分配内存空间
      2. 初始化 uniqueInstance
      3. 将uniqueInstance指向被分配的空间
  
      由于指令重排的关系，可能会编程1->3->2 ，指令重排在单线程情况下不会出现问题，而多线程，
  
      - 就会导致可能指针非空的时候，实际该指针所指向的对象（实例）并还没有初始化
      - 例如，线程 T1 执行了 1 和 3，此时 T2 调用 `getUniqueInstance`() 后发现 `uniqueInstance` 不为空，因此返回 `uniqueInstance`，但此时 `uniqueInstance` 还未被初始化
  
- volatile不能保证原子性

  - 下面的代码，输出结果小于2500

    ```java
    public class VolatoleAtomicityDemo {
        public volatile static int inc = 0;
    
        public void increase() {
            inc++;
        }
    
        public static void main(String[] args) throws InterruptedException {
            ExecutorService threadPool = Executors.newFixedThreadPool(5);
            VolatoleAtomicityDemo volatoleAtomicityDemo = new VolatoleAtomicityDemo();
            for (int i = 0; i < 5; i++) {
                threadPool.execute(() -> {
                    for (int j = 0; j < 500; j++) {
                        volatoleAtomicityDemo.increase();
                    }
                });
            }
            // 等待1.5秒，保证上面程序执行完成
            Thread.sleep(1500);
            System.out.println(inc);
            threadPool.shutdown();
        }
    }
    ```

    对于上面例子, inc++ 是原子性的，实际上inc ++ 是一个符合操作，即

    1. 读取inc的值
    2. 对inc加1
    3. 将加1后的值写回内存

    这三部操作并不是原子性的，有可能出现：

    1. 线程1对inc读取后，尚未修改
    2. 线程2又读取了，并对他进行+1，然后将+1后的值写回主存
    3. 此时线程2操作完毕后，线程1在之前读取的基础上进行一次自增，这将覆盖第2步操作的值，导致inc只增加了1

    如果要保证上面代码运行正确，可以使用synchronized、Lock或者AtomicInteger，如

    ```java
    //synchronized
    public synchronized void increase() {
        inc++;
    }
    //或者AtomicInteger
    public AtomicInteger inc = new AtomicInteger();
    
    public void increase() {
        inc.getAndIncrement();
    }
    //或者ReentrantLock改进
    Lock lock = new ReentrantLock();
    public void increase() {
        lock.lock();
        try {
            inc++;
        } finally {
            lock.unlock();
        }
    }
    ```

## synchronized关键字

- 说一说自己对synchronized的理解

  - 翻译成中文是同步的意思，主要解决的是多个线程之间访问资源的同步性，保证**被它修饰的方法/代码块**，在**任一时刻只有一个线程**执行
  - Java早期版本中，synchronized属于重量级锁；监视器锁（monitor）依赖底层操作系统的**Mutex Lock**来实现，**Java线程映射到操作系统的原生线程上**
    - 挂起或唤醒线程，都需要操作系统帮忙完成，即操作系统实现线程之间切换，需要**从用户态转换到内核态**，这个转换时间成本高
  - Java 6 之后，Java官方对synchronized较大优化，引入了大量优化：自旋锁、适应性自旋锁、锁消除、锁粗化、偏向锁、轻量级锁等减少所操作的开销

- 如何使用synchronized关键字

  1. 修饰实例方法
  2. 修饰静态方法
  3. 修饰代码块

  - 修饰实例方法（锁当前对象实例）
    给当前对象实例加锁，进入同步代码前要获得**当前对象实例**的锁

    ```java
    synchronized void method() {
        //业务代码
    }
    ```

  - 修饰静态方法（锁当前类）
    给当前类枷锁，会作用于类的所有对象实例，进入同步代码前要获得**当前class**的锁; 这是因为静态成员归整个类所有，而**不属于任何一个实例对象**，不依赖于类的特定实例，被类所有实例共享
  
    ```java
    synchronized static void method() {
        //业务代码
    }
    ```
  
    静态synchronized方法和非静态synchronized方法之间的调用互斥吗：不互斥
  
    > 如果线程A调用实例对象的非静态方法，而线程B调用这个实例所属类的静态synchronized方法，是允许的，不会发生互斥；因为访问**静态synchronized**方法占用的锁是**当前类的锁**；**非静态synchronized方法**占用的是**当前实例对象的锁** 
  
  - 修饰代码块（锁指定对象/类）
  
    1. `synchronized(object)` 表示进入同步代码库前要获得 **给定对象的锁**。
    2. `synchronized(类.class)` 表示进入同步代码前要获得 **给定 Class 的锁**
  
    ```java
    synchronized(this) {
        //业务代码
    }
    ```
  
  - 总结
  
    > - `synchronized` 关键字加到 `static` 静态方法和 `synchronized(class)` 代码块上都是是给 Class 类上锁；
    > - `synchronized` 关键字加到实例方法上是给对象实例上锁；
    > - 尽量不要使用 `synchronized(String a)` 因为 JVM 中，字符串常量池具有缓存功能。(所以就会导致，容易和其他地方的代码（同样的值的字符串）互斥，因为是缓冲池的同一个对象)
  
- 将一下synchronized关键字的底层原理
  synchronized底层原理是属于JVM层面的

  - synchronized + 代码块
    例子：  

      ```java
      public class SynchronizedDemo {
          public void method() {
              synchronized (this) {
                  System.out.println("synchronized 代码块");
              }
          }
      }
      ```

      使用javap命令查看SynchronizedDemo类**相关字节码信息**：对编译后的SynchronizedDemo.class文件，使用```javap -c -s -v -l SynchronizedDemo.class```

      ![image-20221029185709116](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221029185709116.png)

      同步代码块的实现，使用的是**monitorenter**和**monitorexit**指令，其中**monitorenter**指令指向**同步代码块开始**的地方，**monitorexit**指向同步代码块结束的结束位置
      执行monitorenter指令就是获取**对象监视器monitor**的持有权

      ```java
      在HotSport虚拟机中，Monitor基于C++实现，由ObjectMonitor实现：每个对象内置了ObjectMonitor对象。wait/notify等方法也基于monitor对象，所以只有在同步块或者方法中（获得锁）才能调用wait/notify方法，否则会抛出java.lang.IllegalMonitorStateException异常的原因
      ```

      执行monitorenter时，尝试获取对象的锁，如果锁计数器为0则表示所可以被获取，获取后锁计数器设为1，简单的流程  
      ![image-20221029190656612](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221029190656612.png)
      **只有拥有者线程**才能执行**monitorexit**来释放锁，执行monitorexit指令后，锁计数器设为0（应该是减一，与可重入锁有关），当计数器为0时，表明锁被释放，其他线程可以尝试获得锁(如果某个线程获取锁失败，那么该线程就会阻塞等待，知道锁被（另一个线程）释放)
      ![image-20221029190841776](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221029190841776.png)
    
  - synchronized修饰方法
  
    ```java
    public class SynchronizedDemo2 {
        public synchronized void method() {
            System.out.println("synchronized 方法");
        }
    }
    ```
  
    如图  :
    ![image-20221029191336048](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221029191336048.png)
  
    对比（下面是对synchronized代码块）：  
    ![image-20221029192437491](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221029192437491.png)
  
    > synchronized修饰的方法没有monitorenter和monitorexit指令，而是ACC_SYNCHRONIZED标识（flags），该标识指明方法是一个同步方法（JVM通过访问标志判断方法是否声明为同步方法），从而执行同步调用
    > 如果是**实例方法**，JVM 会尝试**获取实例对象的锁**。如果是**静态方法**，JVM 会尝试**获取当前 class 的锁**。
  
  - 总结
  
    - `synchronized` 同步语句块的实现使用的是 **`monitorenter` 和 `monitorexit`** 指令，其中 `monitorenter` 指令指向同步代码块的开始位置，`monitorexit` 指令则指明同步代码块的结束位置。
  
    - **`synchronized` 修饰的方法并没有 `monitorenter` 指令和 `monitorexit` 指令**，取得代之的确实是 **`ACC_SYNCHRONIZED` 标识**，该标识指明了该方法是一个同步方法。
  
      **不过两者的本质都是对对象监视器 monitor 的获取。**


## ThreadLocal

