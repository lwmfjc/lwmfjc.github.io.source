---
title: io模型
description: io模型
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-io
date: 2022-10-26 14:17:58
updated: 2022-10-26 14:17:58
---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## I/O

### 何为I/O

- I/O(**Input/Output**)，即**输入/输出**
  从计算机结构的角度来解读一下I/O，根据冯诺依曼结构，计算机结构分为5大部分：**运算器**、**控制器**、**存储器**、**输入设备**、**输出设备**
  ![image-20221026153939710](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026153939710.png)
  其中，输入设备：键盘；输出设备：显示器 
  网卡、硬盘既属于输入设备也属于输出设备
- 输入设备**向计算机输入（内存）**数据，输出设备**接收计算机（内存）**输出的数据，即I/O描述了**计算机系统**与**外部设备**之间**通信**的过程
- 从应用程序的角度解读I/O
  - 为了保证系统稳定性和安全性，一个进程的地址空间划分为**用户空间User space**和**内核空间Kernel space** ```kernel	英[ˈkɜːnl]```
  - 平常运行的应用程序都运行在用户空间，只有**内核空间才能进行系统态级别**的**资源**有关操作---**文件管理、进程通信、内存管理**
  - 如果要进行IO操作，就得依赖**内核空间**的能力，**用户空间的程序**不能直接访问**内核空间**
  - 用户进程要想执行IO操作，必须通过**系统调用**来间接访问内核空间
- 对于**磁盘IO（读写文件）**和**网络IO（网络请求和响应）**，从应用程序视角来看，**应用程序**对操作系统的**内核**发起**IO调用（系统调用）**，操作系统负责的**内核**执行具体**IO**操作
  - **应用程序只是发起了IO操作调用**，而具体的IO执行则由**操作系统内核**完成
- 应用程序**发起I/O后**，经历两个步骤
  - 内核**等待I/O设备**准备好数据
  - 内核将数据**从内核空间**拷贝**到用户空间**

### 有哪些常见的IO模型

UNIX系统下，包括5种：**同步阻塞I/O**，**同步非阻塞I/O**，**I/O多路复用**、**信号驱动I/O**和**异步I/O**

## Java中3中常见I/O模型

### BIO (Blocking I/O )

- 应用程序发起read调用后，会一直阻塞，**直到内核把数据拷贝到用户空间**
  ![image-20221026162316247](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026162316247.png)

### NIO (Non-blocking/New I/O)

- 对于java.nio包，提供了**Channel**、**Selector**、**Buffer**等抽象概念，对于**高负载高并发**，应使用NIO
- NIO是I/O多路复用模型，属于**同步非阻塞IO**模型
  - **一般的同步非阻塞 IO 模型**中，应用程序会**一直发起 read** 调用。  
    等待**数据从内核空间拷贝到用户空**间的这段时间里，**线程依然是阻塞**的**，**直到在内核把数据拷贝到用户空间。
  
    相比于同步阻塞 IO 模型，同步非阻塞 IO 模型确实有了很大改进。通过轮询操作，避免了一直阻塞。
  
    但是，这种 IO 模型同样存在问题：**应用程序不断进行 I/O 系统调用轮询数据是否已经准备好的过程是十分消耗 CPU 资源的。**  
  
    ★★ 也就是说，【准备数据，数据就绪】是**不阻塞**的。而【拷贝数据】是**阻塞**的
    ![图源：《深入拆解Tomcat & Jetty》](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/bb174e22dbe04bb79fe3fc126aed0c61~tplv-k3u1fbpfcp-watermark.image)  
  
  - I/O多路复用
    线程首先**发起select调用，询问内核数据是否准备就绪**，等准备好了，**用户线程再发起read调用**，r**ead调用的过程（数据从内核空间-->用户空间）**还是阻塞的  
    
    > IO 多路复用模型，通过**减少无效的系统调用**，**减少了对 CPU 资源的消耗**。
    >
    > Java 中的 NIO ，有一个非常重要的**选择器 ( Selector )** 的概念，也可以被称为 **多路复用器**。通过它，只需要**一个线程便可以管理多个客户端连接**。当**客户端数据到了**之后，才会为其服务。
    
  - Selector，即多路复用器，一个线程管理多个客户端连接
    ![image-20221026163835033](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026163835033.png)

### AIO(Asynchronous I/O )

- 异步 IO 是基于**事件和回调**机制实现的，也就是**应用操作之后会直接返回**，不会堵塞在那里，当后台处理完成，操作系统会通知相应的线程进行后续的操作
  如图  
  ![image-20221026164006797](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026164006797.png)

## 三者区别

![image-20221026164100906](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026164100906.png)


