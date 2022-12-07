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
updated: 2022-11-07 16:00:06

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

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
  
- Java1.6之后的synchronized关键字底层做了哪些优化
  这是一个链接 [详情见另一个文章](/2022/11/06/review/java_guide/concurrent/lock_escalation/)

  - JDK1.6对锁的实现，引入了大量的优化，如**偏向锁、轻量级锁、自旋锁、适应性自旋锁、锁消除、锁粗化**等技术来减少操作的开销
  - 锁主要存在**四种状态**，依次是：无锁状态、偏向锁状态、轻量级锁状态、重量级锁状态，他们会随着竞争的激烈而逐渐升级**锁可以升级但不可以降级，这种策略是为了提高获得锁和释放锁的效率**

- synchronized和volatile的区别
  synchronized和volatile是互补的存在，而非对立

  - volatile关键字是线程同步的轻量级实现，所以volatile性能肯定比synchronized关键字好，但volatile用于变量而synchronized关键字修饰方法及代码块
  - volatile关键字能保证数据的可见性、有序性，但无法保证原子性；synchronized三者都能保证
  - volatile主要还是用于解决变量在线程之间的可见性，而synchronized关键字解决的是多个线程之间访问资源的同步性

- synchronized 和 ReentrantLock 的区别

  1. 两者都是可重入锁
     ”可重入锁“指的是，自己可以再次获取自己的内部锁。比如一个线程获得了某个对象的锁，此时这个对象锁还没有释放，当其再次想要获取这个对象的锁的时候还是可以获取的  
     反之，如果是不可重入锁的话，就会造成死锁。
     同一个线程，每次获取锁，锁的计数器都自增1，所以要等到锁的计数器下降为0时才能释放锁
  2. synchronized依赖于JVM而ReentrantLock依赖于API
     synchronized为虚拟机在JDK1.6进行的优化，但这些优化是在虚拟机层面实现的；ReentrantLock是JDK层面实现的，使用时，使用lock()和unlock()并配合try/finally语句块来完成 （Java代码）

- ReentrantLock 比 synchronized 增加了一些高级功能
  ReentrantLock增加了一些高级功能，主要有

  1. 等待可中断，提供了能够**中断等待锁的线程**的机制，通过lock.lockInterruptibly()来实现该机制。即正在等待的线程可以放弃等待，改为处理其他事情

  2. 可实现公平锁：可以指定是公平锁还是非公平锁，而synchronized只能是非公平锁。
     所谓公平锁就是先等待的线程先获得锁。ReentrantLock默认是非公平的，可以通过构造方法指定是否公平

  3. 可实现选择性的通知（锁可以绑定多个条件）
     **`synchronized`关键字与`wait()`和`notify()`/`notifyAll()`**方法相结合可以实现等待/通知机制。**`ReentrantLock`**类当然也可以实现，但是需要借助于**`Condition`接口与`newCondition()`**方法。

     > - `Condition`是 JDK1.5 之后才有的，它具有很好的灵活性，比如可以实现多路通知功能也就是在一个`Lock`对象中可以创建多个`Condition`实例（即对象监视器），**线程对象可以注册在指定的`Condition`中，从而可以有选择性的进行线程通知，在调度线程上更加灵活。 **
     > - **在使用`notify()/notifyAll()`方法进行通知时，被通知的线程是由 JVM 选择的，用`ReentrantLock`类结合`Condition`实例可以实现“选择性通知”** ，这个功能非常重要，而且是 Condition 接口默认提供的。
     >   - `synchronized`关键字就相当于整个 Lock 对象中只有一个`Condition`实例，所有的线程都注册在它一个身上。如果执行`notifyAll()`方法的话就会通知所有处于等待状态的线程这样会造成很大的效率问题，
     >   - `Condition`实例的`signalAll()`方法 只会唤醒注册在该`Condition`实例中的所有等待线程。


## ThreadLocal

- ThreadLocal有什么用

  1. 通常情况下，创建的变量是可以被**任何一个线程访问并修改**的
  2. JDK自带的ThreadLocal类，该类主要解决的就是让**每个线程绑定自己的值**，可以将ThreadLocal类形象的比喻成存放数据的盒子，盒子中可以存储每个线程的私有数据
  3. 对于ThreadLocal变量，访问这个变量的每个线程都会有这个变量的本地副本。使用get()和set()来获取默认值或将其值更改为当前线程所存的副本的值

- 如何使用ThreadLocal
  Demo演示实际中如何使用ThreadLocal  

  ```java
  import java.text.SimpleDateFormat;
  import java.util.Random;
  
  public class ThreadLocalExample implements Runnable{
  
       // SimpleDateFormat 不是线程安全的，所以每个线程都要有自己独立的副本
      private static final ThreadLocal<SimpleDateFormat> formatter = ThreadLocal.withInitial(() -> new SimpleDateFormat("yyyyMMdd HHmm"));
      /* 非lambda写法
        private static final ThreadLocal<SimpleDateFormat> formatter = new ThreadLocal<SimpleDateFormat>(){
      @Override
      protected SimpleDateFormat initialValue(){
          return new SimpleDateFormat("yyyyMMdd HHmm");
      }
  };
      */
  
      public static void main(String[] args) throws InterruptedException {
          ThreadLocalExample obj = new ThreadLocalExample();
          for(int i=0 ; i<10; i++){
              Thread t = new Thread(obj, ""+i);
              Thread.sleep(new Random().nextInt(1000));
              t.start();
          }
      }
  
      //formatter.get().toPattern() 同一个对象的线程变量formatter(里面封装了一个simpleDateFormate对象，具有初始值)
      //每个线程访问时，先打印它的初始值，然后休眠1s（1s内的随机数），反正每个线程随机数不同，然后修改它
      //结果：虽然前面执行的线程，修改值，但是后面执行的线程打印的值还是一样的 没有修改
      @Override
      public void run() {
          System.out.println("Thread Name= "+Thread.currentThread().getName()+" default Formatter = "+formatter.get().toPattern());
          try {
              Thread.sleep(new Random().nextInt(1000));
          } catch (InterruptedException e) {
              e.printStackTrace();
          }
          //formatter pattern is changed here by thread, but it won't reflect to other threads
          formatter.set(new SimpleDateFormat());
  
          System.out.println("Thread Name= "+Thread.currentThread().getName()+" formatter = "+formatter.get().toPattern());
      }
  
  }
  /*虽然前面执行的线程，修改值，但是后面执行的线程打印的值还是一样的 没有修改 , 结果如下：
   Thread Name= 0 default Formatter = yyyyMMdd HHmm
  Thread Name= 0 formatter = yy-M-d ah:mm
  Thread Name= 1 default Formatter = yyyyMMdd HHmm
  Thread Name= 2 default Formatter = yyyyMMdd HHmm
  Thread Name= 1 formatter = yy-M-d ah:mm
  Thread Name= 3 default Formatter = yyyyMMdd HHmm
  Thread Name= 2 formatter = yy-M-d ah:mm
  Thread Name= 4 default Formatter = yyyyMMdd HHmm
  Thread Name= 3 formatter = yy-M-d ah:mm
  Thread Name= 4 formatter = yy-M-d ah:mm
  Thread Name= 5 default Formatter = yyyyMMdd HHmm
  Thread Name= 5 formatter = yy-M-d ah:mm
  Thread Name= 6 default Formatter = yyyyMMdd HHmm
  Thread Name= 6 formatter = yy-M-d ah:mm
  Thread Name= 7 default Formatter = yyyyMMdd HHmm
  Thread Name= 7 formatter = yy-M-d ah:mm
  Thread Name= 8 default Formatter = yyyyMMdd HHmm
  Thread Name= 9 default Formatter = yyyyMMdd HHmm
  Thread Name= 8 formatter = yy-M-d ah:mm
  Thread Name= 9 formatter = yy-M-d ah:mm
  */
  ```

- ThreadLocal原理了解吗

  - 从Thread类源代码入手  

      ```java
      public class Thread implements Runnable {
          //......
          //与此线程有关的ThreadLocal值。由ThreadLocal类维护
          ThreadLocal.ThreadLocalMap threadLocals = null;

          //与此线程有关的InheritableThreadLocal值。由InheritableThreadLocal类维护
          ThreadLocal.ThreadLocalMap inheritableThreadLocals = null;
          //......
      }
      ```
      
      1. Thread类中有一个**threadLocals**和一个**inheritableThreadLocals**变量，它们都是ThreadLocalMap类型的变量，ThreadLocalMap可以理解为ThreadLocal类实现的定制化HashMap ( key为threadLocal , value 为值)
         默认两个变量都是null，当调用set或get时会创建，实际调用的是ThreadLocalMap类对应的get()、set()方法
      
         ```java
         public void set(T value) {
             //获取当前请求的线程    
             Thread t = Thread.currentThread();
             //取出 Thread 类内部的 threadLocals 变量(哈希表结构)
             ThreadLocalMap map = getMap(t);
             if (map != null)
                 // 将需要存储的值放入到这个哈希表中
                 //★★实际使用的方法
                 map.set(this, value);
             else
                 //★★实际使用的方法
                 createMap(t, value);
         }
         ThreadLocalMap getMap(Thread t) {
             return t.threadLocals;
         }
         ```
      
         - 如上，实际存取都是从Thread的threadLocals （ThreadLocalMap类）中，并不是存在ThreadLocal上，ThreadLocal用来传递了**变量值**，只是ThreadLocalMap的封装
      
         - ThreadLocal类中通过Thread.currentThread()获取到当前线程对象后，直接通过getMap(Thread t) 可以访问到该线程的ThreadLocalMap对象
      
         - **每个Thread中具备一个ThreadLocalMap，而ThreadLocalMap可以存储以ThreadLocal为key，Object对象为value的键值对**
      
           ```java
           ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
               //......
           }
           ```
      
           比如我们在同一个线程中声明了两个 `ThreadLocal` 对象的话， `Thread`内部都是使用仅有的那个`ThreadLocalMap` 存放数据的，`ThreadLocalMap`的 key 就是 `ThreadLocal`对象，value 就是 `ThreadLocal` 对象调用`set`方法设置的值
      
      2. ThreadLocal数据结构如下图所示
         ![image-20221107150751048](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221107150751048.png)
      
         **`ThreadLocalMap`是`ThreadLocal`的静态内部类。**
         ![image-20221107151155140](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221107151155140.png)
  
- ThreadLocal内存泄露问题时怎么导致的

  - 前提知识：强引用、软引用、弱引用和虚引用的区别

    1. 强引用StrongReference  
       是最普遍的一种引用方式，只要强引用存在，则垃圾回收器就不会回收这个对象

    2. 软引用 SoftReference  
       如果内存足够不回收，如果内存不足则回收

    3. 弱引用WeakReference  如果一个对象只具有弱引用，那就类似于**可有可无的生活用品**。弱引用与软引用的区别在于：只具有弱引用的对象拥有更短暂的生命周期。在垃圾回收器线程扫描它 所管辖的内存区域的过程中，一旦发现了只具有弱引用的对象，**不管当前内存空间足够与否，都会回收它的内存**。不过，由于垃圾回收器是一个优先级很低的线程， 因此不一定会很快发现那些只具有弱引用的对象。

       弱引用可以和一个引用队列（ReferenceQueue）联合使用，如果弱引用所引用的对象被垃圾回收，Java 虚拟机就会把这个弱引用加入到与之关联的引用队列中。

    4. 虚引用PhantomReference   

       - 如果一个对象仅持有虚引用，那么它就和没有任何引用一样，在任何时候都可能被垃圾回收器回收。**虚引用主要用来跟踪对象被垃圾回收器回收的活动**
       - 虚引用与软引用和弱引用的一个区别在于：**虚引用必须和引用队列 （ReferenceQueue）联合使用**。当垃圾回收器准备回收一个对象时，如果发现它还有虚引，就会在回收对象的内存之前，把这个虚引用加入到与之关联的引用队列中。 

  - ThreadLocalMap中，使用的key为ThreadLocal的弱引用（源码中，即Entry），而value是强引用
    所以，ThreadLocal没有被外部强引用的情况下，垃圾回收的时候 key会被清理掉，而value不会

    ```java
    static class Entry extends WeakReference<ThreadLocal<?>> {
        /** The value associated with this ThreadLocal. */
        Object value;
    
        Entry(ThreadLocal<?> k, Object v) {
            super(k);
            value = v;
        }
    }
    ```

  - 此时，ThreadLocalMap中就会出现key为null的Entry，如果不做任何措施，value永远无法被GC回收，此时会产生内存泄漏。ThreadLocaMap实现中已经考虑了这种情况，在调用set()、get()、remove()方法时，清理掉key为null的记录 所以使用完ThreadLocal的方法后，最好手动调用remove()方法