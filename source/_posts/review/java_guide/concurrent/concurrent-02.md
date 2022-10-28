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

## ThreadLocal

