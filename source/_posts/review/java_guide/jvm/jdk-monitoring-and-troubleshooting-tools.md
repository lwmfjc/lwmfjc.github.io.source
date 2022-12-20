---
title: jvm监控和故障处理工具 总结
description: jvm监控和故障处理工具 总结
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-19 16:04:34
updated: 2022-12-19 17:04:34
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# JDK 命令行工具

这些命令在 JDK 安装目录下的 bin 目录下：

- **`jps`** (JVM Process Status）: 类似 UNIX 的 `ps` 命令。用于查看所有 Java 进程的启动类、传入参数和 Java 虚拟机参数等信息；
- **`jstat`**（JVM Statistics Monitoring Tool）:  用于收集 HotSpot 虚拟机各方面的运行数据;
- **`jinfo`** (Configuration Info for Java) : Configuration Info for Java,显示虚拟机配置信息;
- **`jmap`** (Memory Map for Java) : 生成堆转储快照;
- **`jhat`** (JVM Heap Dump Browser) : 用于分析 heapdump 文件，它会建立一个 HTTP/HTML 服务器，让用户可以在浏览器上查看分析结果;
- **`jstack`** (Stack Trace for Java) : 生成虚拟机当前时刻的线程快照，线程快照就是当前虚拟机内每一条线程正在执行的方法堆栈的集合。

## jps: 查看所有 Java 进程

`jps`(JVM Process Status) 命令类似 UNIX 的 `ps` 命令。

`jps`：显示虚拟机执行主类名称以及这些进程的本地虚拟机唯一 ID（Local Virtual Machine Identifier,LVMID）。`jps -q` ：只输出进程的本地虚拟机唯一 ID。

```powershell
C:\Users\SnailClimb>jps
7360 NettyClient2
17396
7972 Launcher
16504 Jps
17340 NettyServer
```

`jps -l`:输出主类的全名，如果进程执行的是 Jar 包，输出 Jar 路径。

```powershell
C:\Users\SnailClimb>jps -l
7360 firstNettyDemo.NettyClient2
17396
7972 org.jetbrains.jps.cmdline.Launcher
16492 sun.tools.jps.Jps
17340 firstNettyDemo.NettyServer
```

`jps -v`：输出虚拟机进程启动时 JVM 参数。

`jps -m`：输出传递给 Java 进程 main() 函数的参数。

## jstat：监视虚拟机各种运行状态信息

- jstat ( JVM Statistics Monitoring Tool ) 使用于**监视虚拟机**各种**运行状态信息**的命令行工具。

  > 可以显示**本地**或者**远程（需要远程主机提供RMI支持）**虚拟机进程中的**类信息**、**内存**、**垃圾收集**、**JIT编译**等运行数据，在**没有GUI**，只提供了**纯文本**控制台环境的服务器上，它将是运行期间**定位虚拟机性能问题**的首选工具

- jstat 命令使用格式  

  ```powershell
  jstat -<option> [-t] [-h<lines>] <vmid> [<interval> [<count>]]
  ```

  比如 `jstat -gc -h3 31736 1000 10`表示分析进程 id 为 31736 的 gc 情况，每隔 1000ms 打印一次记录，打印 10 次停止，每 3 行后打印指标头部。

  ```shell
  λ jstat -gc -h3 12224 1000 10  
  ```

  ![image-20221219210349920](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219210349920.png)

  常见的option如下  , 下面的vmid，即vm的id （id值）

  - `jstat -class vmid` ：显示 ClassLoader 的相关信息；
  - `jstat -compiler vmid` ：显示 JIT 编译的相关信息；
  - `jstat -gc vmid` ：显示与 GC 相关的堆信息；
  - `jstat -gccapacity vmid` ：显示各个代的容量及使用情况；
  - `jstat -gcnew vmid` ：显示新生代信息；
  - `jstat -gcnewcapcacity vmid` ：显示新生代大小与使用情况；
  - `jstat -gcold vmid` ：显示老年代和永久代的行为统计，从jdk1.8开始,该选项仅表示老年代，因为永久代被移除了；
  - `jstat -gcoldcapacity vmid` ：显示老年代的大小；
  - `jstat -gcpermcapacity vmid` ：显示永久代大小，从jdk1.8开始,该选项不存在了，因为永久代被移除了；
  - `jstat -gcutil vmid` ：显示垃圾收集信息

  使用```jstat -gcutil -h3 12224 1000 10```

  ![image-20221219210934394](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219210934394.png)

  另外，加上 `-t`参数可以在输出信息上加一个 Timestamp 列，显示程序的运行时间。
  各个参数的含义  
  ![image-20221219211407363](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219211407363.png)

## jinfo：实时地查看和调整虚拟机各项参数

`jinfo vmid` :输出当前 jvm 进程的全部参数和系统属性 (第一部分是系统的属性，第二部分是 JVM 的参数)。
如下图： 
![image-20221219211745724](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219211745724.png)
![image-20221219211839945](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219211839945.png)



![image-20221219211712746](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219211712746.png)



- `jinfo -flag name vmid` :输出**对应名称**的参数的**具体值**。比如输出 **MaxHeapSize**、查看当前 jvm 进程**是否开启打印 GC 日志** ( `-XX:PrintGCDetails` :详细 GC 日志模式，这两个都是默认关闭的)。

  ```shell
  C:\Users\SnailClimb>jinfo  -flag MaxHeapSize 17340
  -XX:MaxHeapSize=2124414976
  C:\Users\SnailClimb>jinfo  -flag PrintGC 17340
  -XX:-PrintGC
  ```

- 使用 jinfo 可以在不重启虚拟机的情况下，可以动态的修改 jvm 的参数。尤其在线上的环境特别有用,请看下面的例子：
  使用```jinfo -flag [+|-]name vmid 开启或者关闭对应名称的参数：  

  ```shell
  C:\Users\SnailClimb>jinfo  -flag  PrintGC 17340
  -XX:-PrintGC
  
  C:\Users\SnailClimb>jinfo  -flag  +PrintGC 17340
  
  C:\Users\SnailClimb>jinfo  -flag  PrintGC 17340
  -XX:+PrintGC
  ```

## jmap：生成堆转储快照

- **jmap(Memory Map for Java )**命令用于生成**堆转储**快照。如果不使用jmap命令，要想获取java**堆转储**，可以使用```-XX:+HeapDumpOutOfMemoryError```参数，可以让虚拟机在**OOM**异常出现**之后**，自动生成dump文件，Linux命令下通过```kill -3```发送进程推出信号也能拿到dump文件

- `jmap` 的作用并不仅仅是为了**获取 dump** 文件，它还可以**查询 finalizer 执行队列**、**Java 堆**和**永久代**的详细信息，如**空间使用率**、当前使用的是**哪种收集器**等。和`jinfo`一样，`jmap`有不少功能在 Windows 平台下也是受限制的。

- 将指定应用程序的**堆 快照**输出到桌面，后面可以通过**jhat**、**Visual VM**等工具分析该堆文件

  ```java
  C:\Users\SnailClimb>jmap -dump:format=b,file=C:\Users\SnailClimb\Desktop\heap.hprof 17340
  Dumping heap to C:\Users\SnailClimb\Desktop\heap.hprof ...
  Heap dump file created
  ```

## jhat：分析heapdump文件

**`jhat`** 用于分析 heapdump 文件，它会建立一个 HTTP/HTML 服务器，让用户可以在浏览器上查看分析结果。

```shell
C:\Users\SnailClimb>jhat C:\Users\SnailClimb\Desktop\heap.hprof
Reading from C:\Users\SnailClimb\Desktop\heap.hprof...
Dump file created Sat May 04 12:30:31 CST 2019
Snapshot read, resolving...
Resolving 131419 objects...
Chasing references, expect 26 dots..........................
Eliminating duplicate references..........................
Snapshot resolved.
Started HTTP server on port 7000
Server is ready. 
```

之后访问 http://localhost:7000/ 即可，如下：
进入/histo  会发现，有这个东西
![image-20221220094041210](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221220094041210.png)
这个对象创建了9次，因为我是在第9次循环后dump堆快照的

```java
//测试代码如下
public class MyMain {
    private byte[] x = new byte[10 * 1024 * 1024];//10M

    public static void main(String[] args) throws InterruptedException {
        System.out.println("开始循环--");
        int i=0;
        while (++i>0) {
            String a=new Date().toString();
            MyMain myMain = new MyMain();
            System.out.println(i+"循环中---" + new Date());
            TimeUnit.SECONDS.sleep(10);
        }
    }
}
```

## jstack： 生成虚拟机当前时刻的线程快照

- **jstack (Stack Trace for Java )** 命令用于生成**虚拟机当前时刻**的**线程快照**。线程快照就是当前虚拟机内**每一条线程正在执行**的**方法堆栈**的集合

- 生成线程快照的目的主要是**定位线程长时间出现停顿的原因**，如**线程间死锁**、**死循环**、**请求外部资源导致的长时间等待**等都是导致线程长时间停顿的原因。**线程出现停顿**的时候**通过`jstack`来查看各个线程的调用堆栈**，就可以知道没有响应的线程到底在后台做些什么事情，或者在等待些什么资源。

- 线程死锁的代码，通过**jstack** 命令进行**死锁检查**，输出**死锁信息**，找到**发生死锁的线程**

  ```java
  package com.jvm;
  
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
  /*------
  Thread[线程 1,5,main]get resource1
  Thread[线程 2,5,main]get resource2
  Thread[线程 2,5,main]waiting get resource1
  Thread[线程 1,5,main]waiting get resource2
  */
  ```

- 分析  线程 A 通过 synchronized (resource1) 获得 resource1 的监视器锁，然后通过` Thread.sleep(1000);`让线程 A 休眠 1s 为的是让线程 B 得到执行然后获取到 resource2 的监视器锁。线程 A 和线程 B 休眠结束了都开始企图请求获取对方的资源，然后这两个线程就会陷入互相等待的状态，这也就产生了死锁。

- 通过jstack 命令分析  

  ```shell
  # 先使用jps 找到思索地那个类
  C:\Users\SnailClimb>jps
  13792 KotlinCompileDaemon
  7360 NettyClient2
  17396
  7972 Launcher
  8932 Launcher
  9256 DeadLockDemo
  10764 Jps
  17340 NettyServer
  
  ## 然后使用jstack命令分析
  C:\Users\SnailClimb>jstack 9256 
  ```

  输出的部分如下

  ```shell
  Found one Java-level deadlock:
  =============================
  "线程 2":
    waiting to lock monitor 0x000000000333e668 (object 0x00000000d5efe1c0, a java.lang.Object),
    which is held by "线程 1"
  "线程 1":
    waiting to lock monitor 0x000000000333be88 (object 0x00000000d5efe1d0, a java.lang.Object),
    which is held by "线程 2"
  
  Java stack information for the threads listed above:
  ===================================================
  "线程 2":
          at DeadLockDemo.lambda$main$1(DeadLockDemo.java:31)
          - waiting to lock <0x00000000d5efe1c0> (a java.lang.Object)
          - locked <0x00000000d5efe1d0> (a java.lang.Object)
          at DeadLockDemo$$Lambda$2/1078694789.run(Unknown Source)
          at java.lang.Thread.run(Thread.java:748)
  "线程 1":
          at DeadLockDemo.lambda$main$0(DeadLockDemo.java:16)
          - waiting to lock <0x00000000d5efe1d0> (a java.lang.Object)
          - locked <0x00000000d5efe1c0> (a java.lang.Object)
          at DeadLockDemo$$Lambda$1/1324119927.run(Unknown Source)
          at java.lang.Thread.run(Thread.java:748)
  
  Found 1 deadlock.
  ```

  找到了发生死锁的线程的具体信息

# JDK可视化分析工具

## JConsole：Java监视与管理控制台

JConsole 是**基于 JMX 的可视化监视**、**管理工具**。可以很方便的**监视本地及远程服务器的 java 进程的内存使用情况**。你可以在控制台输出**`console`**命令启动或者在 JDK 目录下的 bin 目录**找到`jconsole.exe`然后双击启动**.
![连接 Jconsole](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1JConsole%25E8%25BF%259E%25E6%258E%25A5.7490f097.png)

对于远程连接

1. 在启动方  

   ```shell
   -Djava.rmi.server.hostname=外网访问 ip 地址 
   -Dcom.sun.management.jmxremote.port=60001   //监控的端口号
   -Dcom.sun.management.jmxremote.authenticate=false   //关闭认证
   -Dcom.sun.management.jmxremote.ssl=false 
   ```

   实例：  
   

   ```shell
   java -Djava.rmi.server.hostname=192.168.200.200  -Dcom.sun.management.jmxremote  -Dcom.sun.management.jmxremote.port=60001  -Dcom.sun.management.jmxremote.ssl=false  -Dcom.sun.management.jmxremote.authenticate=false  com.jvm.DeadLockDemo
   # 其中 192.168.200.200 为启动该类的机器的ip，而不是谁要连接 
   ```

   在使用 JConsole 连接时，远程进程地址如下：

   > ```
   > 外网访问 ip 地址:60001
   > ```
   >
   > ![image-20221220103410971](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221220103410971.png)

2. 注意，虚拟机中（这里ip xxx.200是虚拟机ip），需要开放的端口不只是60001，还要通过 ```netstat -nltp```开放另外两个端口
   ![image-20221220104157529](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221220104157529.png)
   centos中使用

   ```shell
   firewall-cmd --zone=public --add-port=45443/tcp --permanent
   firewall-cmd --zone=public --add-port=36521/tcp --permanent
   firewall-cmd --zone=public --add-port=60001/tcp --permanent
   firewall-cmd --reload #重启firewall
   ```

   之后才能连接上

   ![image-20221220104326724](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221220104326724.png)
   ![查看 Java 程序概况 ](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/2%25E6%259F%25A5%25E7%259C%258BJava%25E7%25A8%258B%25E5%25BA%258F%25E6%25A6%2582%25E5%2586%25B5.9c949b67.png)

### 内存监控

JConsole 可以显示**当前内存的详细信息**。不仅包括**堆内存/非堆内存**的整体信息，还可以细化到 **eden 区**、**survivor 区**等的使用情况，如下图所示。

点击右边的“执行 GC(G)”按钮可以强制应用程序执行一个 Full GC。

>  **新生代 GC（Minor GC）**:指发生新生代的的垃圾收集动作，Minor GC 非常频繁，回收速度一般也比较快。
>
> **老年代 GC（Major GC/Full GC）**:指发生在老年代的 GC，出现了 Major GC 经常会伴随至少一次的 Minor GC（并非绝对），Major GC 的速度一般会比 Minor GC 的慢 10 倍以上。

![内存监控 ](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/3%25E5%2586%2585%25E5%25AD%2598%25E7%259B%2591%25E6%258E%25A7.4f4b8a7f.png)

### 线程监控

类似我们前面讲的 `jstack` 命令，不过这个是可视化的。

最下面有一个"检测死锁 (D)"按钮，点击这个按钮可以自动为你找到发生死锁的线程以及它们的详细信息 。
![线程监控 ](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/4%25E7%25BA%25BF%25E7%25A8%258B%25E7%259B%2591%25E6%258E%25A7.4364833a.png)

## VisualVM： 多合一故障处理工具