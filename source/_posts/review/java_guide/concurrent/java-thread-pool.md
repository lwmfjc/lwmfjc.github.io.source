---
title: java线程池
description: java线程池
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-11-23 14:40:41
updated: 2022-11-23 14:40:41
---

> 转载自https://github.com/Snailclimb/JavaGuide

## 使用线程池的好处

- 池化技术：减少每次获取资源的消耗，提高对资源的利用率
- 线程池提供一种**限制**和**管理资源（包括执行一个任务）**的方式，每个线程池还维护一些基本统计信息，例如**已完成任务**的数量
- 线程池的好处
  - 降低资源消耗（重复利用，降低线程创建和销毁造成的消耗）
  - 提高响应速度（任务到达直接执行，无需等待线程创建）
  - 提高线程可管理性（避免无休止创建，使用线程池同一分配、调优、监控）

## Executor框架

Java5之后，通过Executor启动线程，比使用Thread的start方法更好，更易于管理，效率高，还能有助于避免this逃逸的问题

> this逃逸，指的是构造函数返回之前，其他线程就持有该对象的引用，会导致调用尚未构造完全的对象

Executor框架不仅包括**线程池的管理**，提供**线程工厂**、**队列**以及**拒绝策略**。

### Executor框架结构

主要是三大部分：任务（Runnable/Callable），任务的执行(Executor)，异步计算的结果Future

1. 任务
   执行任务需要的Runnable/Callable接口，他们的实现类，都可以被ThreadPoolExecutor或ScheduleThreadPoolExecutor执行

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



## (重要)ThreadPoolExecutor类简单介绍

## ThreadPoolExecutor使用+原理分析

## 几种常见的线程池详解

## ScheduledThreadPoolExecutor详解

## 线程池大小确定

## 参考

