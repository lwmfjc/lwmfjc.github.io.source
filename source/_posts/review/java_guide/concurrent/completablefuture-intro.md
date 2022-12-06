---
title: completablefuture-intro
description: completablefuture-intro
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-12-06 17:13:41
updated: 2022-12-06 17:13:41
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

Java8被引入的一个非常有用恶用于异步编程的类

# 简单介绍

CompletableFuture同时实现了**Future**和**CompletionStage**接口

```java
public class CompletableFuture<T> implements Future<T>, CompletionStage<T> {
}
```

`CompletableFuture` 除了提供了更为好用和强大的 `Future` 特性之外，还提供了函数式编程的能力。

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20210902092441434.png)

Future接口有5个方法：  

- `boolean cancel(boolean mayInterruptIfRunning)` ：尝试取消执行任务。
- `boolean isCancelled()` ：判断任务是否被取消。
- `boolean isDone()` ： 判断任务是否已经被执行完成。
- `get()` ：等待任务执行完成并获取运算结果。
- `get(long timeout, TimeUnit unit)` ：多了一个超时时间。

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20210902093026059.png)

CompletionStage<T> 接口中的方法比较多，CompoletableFuture的函数式能力就是这个接口赋予的，大量使用**Java8引入的函数式编程**

# 常见操作

## 创建CompletableFuture

两种方法：new或静态方法

1. 通过new关键字
   这个方式，可以看作是将CompletableFuture当作Future来使用，如下：  

   > 我们通过创建了一个结果值类型为 `RpcResponse<Object>` 的 `CompletableFuture`，你可以把 `resultFuture` 看作是异步运算结果的载体
   >
   > ```java
   > CompletableFuture<RpcResponse<Object>> resultFuture = new CompletableFuture<>();
   > ```

   如果后面某个时刻，得到了最终结果，可以调用complete()方法传入结果，表示resultFuture已经被完成：

   ```java
   // complete() 方法只能调用一次，后续调用将被忽略。
   resultFuture.complete(rpcResponse);
   ```

   通过isDone()检查是否完成：

   ```java
   public boolean isDone() {
       return result != null;
   }
   ```

   获取异步结果，使用get() ，调用get()方法的线程会阻塞 直到CompletableFuture完成运算：
   ```rpcResponse = completableFuture.get();```

   如果已经知道结果：

   ```java
   CompletableFuture<String> future = CompletableFuture.completedFuture("hello!");
   assertEquals("hello!", future.get()); 
   //completedFuture() 方法底层调用的是带参数的 new 方法，只不过，这个方法不对外暴露。
   public static <U> CompletableFuture<U> completedFuture(U value) {
       return new CompletableFuture<U>((value == null) ? NIL : value);
   } 
   ```

2. 基于CompletableFuture自带的静态工厂方法：runAsync()、supplyAsync()
   
```Supplier 供应商; 供货商; 供应者; 供货方;```
   这两个方法可以帮助我们封装计算逻辑
   
   ```java
   static <U> CompletableFuture<U> supplyAsync(Supplier<U> supplier);
   // 使用自定义线程池(推荐)
   static <U> CompletableFuture<U> supplyAsync(Supplier<U> supplier, Executor executor);
   static CompletableFuture<Void> runAsync(Runnable runnable);
   // 使用自定义线程池(推荐)
static CompletableFuture<Void> runAsync(Runnable runnable, Executor executor);
   ```
   
   > 备注，自定义线程池使用：  
   > ![image-20221206220534852](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206220534852.png)
   >
   > ```java
   > ThreadPoolExecutor executor = new ThreadPoolExecutor(
   >                 CORE_POOL_SIZE, //5
   >                 MAX_POOL_SIZE,  //10
   >                 KEEP_ALIVE_TIME, //1L
   >                 TimeUnit.SECONDS, //单位
   >                 new ArrayBlockingQueue<>(QUEUE_CAPACITY),//100
   >                 new ThreadPoolExecutor.CallerRunsPolicy()); //主线程中运行
   > ```
   
   - `runAsync()` 方法接受的参数是 `Runnable` ，这是一个函数式接口，不允许返回值。当你需要异步操作且不关心返回结果的时候可以使用 `runAsync()` 方法。
   
     ```java
     @FunctionalInterface
     public interface Runnable {
         public abstract void run();
     }
     ```
   
   - `supplyAsync()` 方法接受的参数是 `Supplier<U>` ，这也是一个函数式接口，**`U` 是返回结果值的类型**。
   
     ```java
     @FunctionalInterface
     public interface Supplier<T> {
     
         /**
          * Gets a result.
          *
          * @return a result
          */
         T get();
     } 
     ```
   
     当需要异步操作且关心返回的结果时，可以使用supplyAsync()方法
   
     ```java
     CompletableFuture<Void> future = CompletableFuture.runAsync(() -> System.out.println("hello!"));
     future.get();// 输出 "hello!" **注意，不是get()返回的**
     CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> "hello!");
     assertEquals("hello!", future2.get()); 
     ```
   
     

## 处理异步结算的结果

可以对异步计算的结果，进行进一步的处理，常用的方法有：  
`thenApply() ` 接收结果 产生结果
``thenAccept()` 接受结果不产生结果

`thenRun` 不接受结果不产生结果
`whenComplete()` 结束时处理结果

1. thenApply()方法接受Function实例，用它来处理结果

   ```java
   // 沿用上一个任务的线程池
   public <U> CompletableFuture<U> thenApply(
       Function<? super T,? extends U> fn) {
       return uniApplyStage(null, fn);
   }
   
   //使用默认的 ForkJoinPool 线程池（不推荐）
   public <U> CompletableFuture<U> thenApplyAsync(
       Function<? super T,? extends U> fn) {
       return uniApplyStage(defaultExecutor(), fn);
   }
   // 使用自定义线程池(推荐)
   public <U> CompletableFuture<U> thenApplyAsync(
       Function<? super T,? extends U> fn, Executor executor) {
       return uniApplyStage(screenExecutor(executor), fn);
   } 
   ```

   使用示例：  

   ```java
   CompletableFuture<String> future = CompletableFuture.completedFuture("hello!")
           .thenApply(s -> s + "world!");
   assertEquals("hello!world!", future.get());
   // 这次调用将被忽略。  //**我猜是因为只能get()一次**
   future.thenApply(s -> s + "nice!");
   assertEquals("hello!world!", future.get());
    
   ```

   流式调用：  

   ```java
   CompletableFuture<String> future = CompletableFuture.completedFuture("hello!")
           .thenApply(s -> s + "world!").thenApply(s -> s + "nice!");
   assertEquals("hello!world!nice!", future.get()); 
   ```

2. 如果不需要从回调函数中返回结果，可以使用thenAccept()或者thenRun() ，两个方法区别在于thenRun()不能访问异步计算的结果(因为thenAccept方法的参数为 **Consumer<? super T>** )

   ```java
   public CompletableFuture<Void> thenAccept(Consumer<? super T> action) {
       return uniAcceptStage(null, action);
   }
   
   public CompletableFuture<Void> thenAcceptAsync(Consumer<? super T> action) {
       return uniAcceptStage(defaultExecutor(), action);
   }
   
   public CompletableFuture<Void> thenAcceptAsync(Consumer<? super T> action,
                                                  Executor executor) {
       return uniAcceptStage(screenExecutor(executor), action);
   } 
   ```

   顾名思义，`Consumer` 属于消费型接口，它可以接收 1 个输入对象然后进行“消费”。

   ```java
   @FunctionalInterface
   public interface Consumer<T> {
   
       void accept(T t);
   
       default Consumer<T> andThen(Consumer<? super T> after) {
           Objects.requireNonNull(after);
           return (T t) -> { accept(t); after.accept(t); };
       }
   } 
   ```

   `thenRun()` 的方法是的参数是 `Runnable` 

   ```java
   public CompletableFuture<Void> thenRun(Runnable action) {
       return uniRunStage(null, action);
   }
   
   public CompletableFuture<Void> thenRunAsync(Runnable action) {
       return uniRunStage(defaultExecutor(), action);
   }
   
   public CompletableFuture<Void> thenRunAsync(Runnable action,
                                               Executor executor) {
       return uniRunStage(screenExecutor(executor), action);
   } 
   ```

   使用如下：  

   ```java
   CompletableFuture.completedFuture("hello!")
           .thenApply(s -> s + "world!").thenApply(s -> s + "nice!").thenAccept(System.out::println);//hello!world!nice!  //可以接收参数
   
   
   CompletableFuture.completedFuture("hello!")
           .thenApply(s -> s + "world!").thenApply(s -> s + "nice!").thenRun(() -> System.out.println("hello!"));//hello! 
   ```

   

## 异步处理

## 组合CompletableFuture

## 并行运行多个CompletableFuture

# 后记

