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

- 执行execute()

## Atomic原子类

## AQS

## 参考