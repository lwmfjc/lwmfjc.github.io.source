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

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

Java8被引入的一个非常有用的用于异步编程的类【**没看**】

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

两种方法：new关键字或 CompletableFuture自带的静态工厂方法 ```runAysnc()```或```supplyAsync()```

1. 通过new关键字
   这个方式，可以看作是将**CompletableFuture当作Future**来使用，如下：  

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

   ```java
public class CompletableFutureTest {
       public static void main(String[] args) throws ExecutionException, InterruptedException {
           /*CompletableFuture<Object> resultFuture=new CompletableFuture<>();
           resultFuture.complete("hello world");
           System.out.println(resultFuture.get());*/
           CompletableFuture<String> stringCompletableFuture = CompletableFuture.supplyAsync(() -> {
               try {
                   TimeUnit.SECONDS.sleep(3);
               } catch (InterruptedException e) {
                e.printStackTrace();
               }
               return "hello,world!";
           });
           System.out.println("被阻塞啦----");
           String s = stringCompletableFuture.get();
           System.out.println("结果---"+s); 
       }
   }
   ```
   
   
   
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

   ```java
//简单使用
public class CompletableFutureTest {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        CompletableFuture<String> completableFuture = CompletableFuture.supplyAsync(() -> {
            //3s后返回结果
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return "abc";
        });
        //这里会被阻塞
        String s = completableFuture.get();
        System.out.println(s); 
    }
}
//例子2  

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

public class CompletableFutureTest {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        CountDownLatch countDownLatch=new CountDownLatch(2);
        //相当于使用了一个线程池，开启线程，提交了任务
        CompletableFuture<Void> a = CompletableFuture.runAsync(() -> {
            System.out.println("a");
            //执行了3s的任务
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            countDownLatch.countDown();
        });
        CompletableFuture<Void> b = CompletableFuture.runAsync(() -> {
            System.out.println("b");
            //执行了3s的任务
            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            countDownLatch.countDown();
        });
        countDownLatch.await();
        System.out.println("执行完毕");//3s后会执行

    }
}
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

例子：  

```java
public class CompletableFutureTest {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        CompletableFuture<String> stringCompletableFuture = CompletableFuture.supplyAsync(() -> {
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return "hello,world!";
        });
        System.out.println("被阻塞啦----");
         stringCompletableFuture
                 .whenComplete((s,e)->{
                     System.out.println("complete1----"+s);
                 })
                 .whenComplete((s,e)->{
                     System.out.println("complete2----"+s);
                 })
                 .thenAccept(s->{
                     System.out.println("打印结果"+s);
                 })
                 .thenRun(()->{
                    System.out.println("阻塞结束啦");
                });
         while (true){

         }
    }
}
/*-------------
2022-12-07 10:16:44 上午 [Thread: main] 
INFO:被阻塞啦----
2022-12-07 10:16:47 上午 [Thread: ForkJoinPool.commonPool-worker-1] 
INFO:complete1----hello,world!
2022-12-07 10:16:47 上午 [Thread: ForkJoinPool.commonPool-worker-1] 
INFO:complete2----hello,world!
2022-12-07 10:16:47 上午 [Thread: ForkJoinPool.commonPool-worker-1] 
INFO:打印结果hello,world!
2022-12-07 10:16:47 上午 [Thread: ForkJoinPool.commonPool-worker-1] 
INFO:阻塞结束啦
*/
```



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

   whenComplete()的方法参数是BiConsumer<? super T , ? super Throwable >

   ```java
   public CompletableFuture<T> whenComplete(
       BiConsumer<? super T, ? super Throwable> action) {
       return uniWhenCompleteStage(null, action);
   }
   
   
   public CompletableFuture<T> whenCompleteAsync(
       BiConsumer<? super T, ? super Throwable> action) {
       return uniWhenCompleteStage(defaultExecutor(), action);
   }
   // 使用自定义线程池(推荐)
   public CompletableFuture<T> whenCompleteAsync(
       BiConsumer<? super T, ? super Throwable> action, Executor executor) {
       return uniWhenCompleteStage(screenExecutor(executor), action);
   } 
   ```

   相比Consumer，BiConsumer可以接收2个输入对象然后进行"消费"

   ```java
   @FunctionalInterface
   public interface BiConsumer<T, U> {
       void accept(T t, U u);
   
       default BiConsumer<T, U> andThen(BiConsumer<? super T, ? super U> after) {
           Objects.requireNonNull(after);
   
           return (l, r) -> {
               accept(l, r);
               after.accept(l, r);
           };
       }
   } 
   ```

   使用：  

   ```java
   CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> "hello!")
           .whenComplete((res, ex) -> {
               // res 代表返回的结果
               // ex 的类型为 Throwable ，代表抛出的异常
               System.out.println(res);
               // 这里没有抛出异常所有为 null
               assertNull(ex);
           });
   assertEquals("hello!", future.get()); 
   ```

   **其他区别暂时不知道**

## 异常处理

使用handle（） 方法来处理任务执行过程中可能出现的抛出异常的情况

```java
public <U> CompletableFuture<U> handle(
    BiFunction<? super T, Throwable, ? extends U> fn) {
    return uniHandleStage(null, fn);
}

public <U> CompletableFuture<U> handleAsync(
    BiFunction<? super T, Throwable, ? extends U> fn) {
    return uniHandleStage(defaultExecutor(), fn);
}

public <U> CompletableFuture<U> handleAsync(
    BiFunction<? super T, Throwable, ? extends U> fn, Executor executor) {
    return uniHandleStage(screenExecutor(executor), fn);
} 
```

代码：  

```java

    public static void test() throws ExecutionException, InterruptedException {
        CompletableFuture<String> future
                = CompletableFuture.supplyAsync(() -> {
            if (true) {
                throw new RuntimeException("Computation error!");
            }
            return "hello!";
        }).handle((res, ex) -> {
            // res 代表返回的结果
            // ex 的类型为 Throwable ，代表抛出的异常
            return res != null ? res : ex.toString()+"world!";
        });
        String s = future.get();
        log.info(s);

    }
/**
2022-12-07 11:14:44 上午 [Thread: main] 
INFO:java.util.concurrent.CompletionException: java.lang.RuntimeException: Computation error!world!
*/
```

通过exceptionally处理异常  

```java
CompletableFuture<String> future
        = CompletableFuture.supplyAsync(() -> {
    if (true) {
        throw new RuntimeException("Computation error!");
    }
    return "hello!";
}).exceptionally(ex -> {
    System.out.println(ex.toString());// CompletionException
    return "world!";
});
assertEquals("world!", future.get()); 
```

让异步的结果直接就抛异常  

```java
CompletableFuture<String> completableFuture = new CompletableFuture<>();
// ...
completableFuture.completeExceptionally(
  new RuntimeException("Calculation failed!"));
// ...
completableFuture.get(); // ExecutionException 
```

## 组合CompletableFuture

使用thenCompose() 按顺序连接两个CompletableFuture对象  

```java
public <U> CompletableFuture<U> thenCompose(
    Function<? super T, ? extends CompletionStage<U>> fn) {
    return uniComposeStage(null, fn);
}

public <U> CompletableFuture<U> thenComposeAsync(
    Function<? super T, ? extends CompletionStage<U>> fn) {
    return uniComposeStage(defaultExecutor(), fn);
}

public <U> CompletableFuture<U> thenComposeAsync(
    Function<? super T, ? extends CompletionStage<U>> fn,
    Executor executor) {
    return uniComposeStage(screenExecutor(executor), fn);
} 
```

使用示例：  

```java
CompletableFuture<String> future
        = CompletableFuture.supplyAsync(() -> "hello!")
        .thenCompose(s -> CompletableFuture.supplyAsync(() -> s + "world!"));
assertEquals("hello!world!", future.get()); 
```

> 在实际开发中，这个方法还是非常有用的。比如说，我们先要获取用户信息然后再用用户信息去做其他事情。

和thenCompose()方法类似的还有thenCombine()方法，thenCombine()同样可以组合两个CompletableFuture对象

```java
CompletableFuture<String> completableFuture
        = CompletableFuture.supplyAsync(() -> "hello!")
        .thenCombine(CompletableFuture.supplyAsync(
                () -> "world!"), (s1, s2) -> s1 + s2)
        .thenCompose(s -> CompletableFuture.supplyAsync(() -> s + "nice!"));
assertEquals("hello!world!nice!", completableFuture.get()); 
```

★★ thenCompose() 和 thenCombine()有什么区别呢

- `thenCompose()` 可以两个 `CompletableFuture` 对象，并将前一个任务的返回结果作为下一个任务的参数，它们之间存在着先后顺序。
- `thenCombine()` 会在两个任务都执行完成后，把两个任务的结果合并。两个任务是并行执行的，它们之间并没有先后依赖顺序。

```java
/*
结果是有顺序的，但是执行的过程是无序的
*/
CompletableFuture<String> completableFuture
                = CompletableFuture.supplyAsync(() -> {
            System.out.println("执行了第1个");
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("第1个执行结束啦");
            return "hello!";
        })
                .thenCombine(CompletableFuture.supplyAsync(
                        () -> {
                            System.out.println("执行了第2个");
                            System.out.println("第2个执行结束啦");
                            return "world!";
                        }), (s1, s2) -> s1 + s2);
        System.out.println(completableFuture.get());
/*
执行了第1个
执行了第2个
第2个执行结束啦
 第1个执行结束啦
hello!world!
*/
```



## 并行运行多个CompletableFuture

通过CompletableFuture的allOf()这个静态方法并行运行多个CompletableFuture

> 实际项目中，我们经常需要并行运行多个互不相关的任务，这些任务没有依赖关系

比如读取处理6个文件，没有顺序依赖关系 但我们需要返回给用户的时候将这几个文件的处理结果统计整理，示例：  

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
    ......
  }
System.out.println("all done. "); 
```

**调用join()可以让程序等future1和future2都运行完后继续执行**

```java
CompletableFuture<Void> completableFuture = CompletableFuture.allOf(future1, future2);
completableFuture.join();
assertTrue(completableFuture.isDone());
System.out.println("all futures done..."); 
/**---
future1 done...
future2 done...
all futures done...
*/
```

anyOf则其中一个执行完就立马返回

```java
CompletableFuture<Object> f = CompletableFuture.anyOf(future1, future2);
System.out.println(f.get());
/*
future2 done...
efg
*/ //或
/*
future1 done...
abc
*/
```

例子2  

```java
CompletableFuture<Object> a = CompletableFuture.supplyAsync(() -> {
            System.out.println("a");
            //执行了3s的任务
            try {
                TimeUnit.SECONDS.sleep(3);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return "a-hello";
        });
        CompletableFuture<Object> b = CompletableFuture.supplyAsync(() -> {
            System.out.println("b");
            //执行了3s的任务
            try {
                TimeUnit.SECONDS.sleep(10);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            return "b-hello";
        });
        
        /*
        //会等两个任务都执行完才继续
        CompletableFuture<Void> voidCompletableFuture = CompletableFuture.allOf(a, b); 
        voidCompletableFuture.join();
        //停顿10s
        System.out.println("主线程继续执行");*/
        
        //任何一个任务执行完就会继续执行
        CompletableFuture<Object> objectCompletableFuture = CompletableFuture.anyOf(a, b);
        objectCompletableFuture.join();
        //会得到最快返回值的那个CompletableFuture的值 
        System.out.println(objectCompletableFuture.get());
        //停顿3s
        System.out.println("主线程继续执行");
```



# 后记

京东的aysncTool框架  
https://gitee.com/jd-platform-opensource/asyncTool#%E5%B9%B6%E8%A1%8C%E5%9C%BA%E6%99%AF%E4%B9%8B%E6%A0%B8%E5%BF%83%E4%BB%BB%E6%84%8F%E7%BC%96%E6%8E%92