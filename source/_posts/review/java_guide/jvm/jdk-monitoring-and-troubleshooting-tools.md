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

## jhat：分析heapdump文件

## jstack： 生成虚拟机当前时刻的线程快照

# JDK可视化分析工具

## JConsole：Java监视与管理控制台

## VisualVM： 多合一故障处理工具