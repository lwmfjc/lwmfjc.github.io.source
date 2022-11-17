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

> 转载自https://github.com/Snailclimb/JavaGuide

## I/O

### 何为I/O

- I/O(Input/Output)，即输入/输出
  从计算机结构的角度来解读一下I/O，根据冯诺依曼结构，计算机结构分为5大部分：运算器、控制器、存储器、输入设备、输出设备
  ![image-20221026153939710](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026153939710.png)
  其中，输入设备：键盘；输出设备：显示器 
  网卡、硬盘既属于输入设备也属于输出设备
- 输入设备**向计算机输入（内存）**数据，输出设备**接收计算机（内存）**输出的数据，即I/O描述了计算机系统与外部设备之间通信的过程
- 从应用程序的角度解读I/O
  - 为了保证系统稳定性和安全性，一个进程的地址空间划分为**用户空间User space**和**内核空间Kernel space** 
  - 平常运行的应用程序都运行在用户空间，只有内核空间才能进行系统态级别的资源有关操作---**文件管理、进程通信、内存管理**
  - 如果要进行IO操作，就得依赖**内核空间**的能力，**用户空间的程序**不能直接访问**内核空间**
  - 用户进程要想执行IO操作，必须通过**系统调用**来间接访问内核空间
- 对于**磁盘IO（读写文件）**和**网络IO（网络请求和响应）**，从应用程序视角来看，**应用程序**对操作系统的**内核**发起**IO调用（系统调用）**，操作系统负责的**内核**执行具体**IO**操作
  - 应用程序只是发起了IO操作调用，而具体的IO执行则由操作系统内核完成
- 应用程序**发起I/O后**，经历两个步骤
  - 内核**等待I/O设备**准备好数据
  - 内核将数据**从内核空间**拷贝**到用户空间**

### 有哪些常见的IO模型

UNIX系统下，包括5种：同步阻塞I/O，同步非阻塞I/O，I/O多路复用、信号驱动I/O和异步I/O

## Java中3中常见I/O模型

### BIO (Blocking I/O )

- 应用程序发起read调用后，会一直阻塞，**直到内核把数据拷贝到用户空间**
  ![image-20221026162316247](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026162316247.png)

### NIO (Non-blocking/New I/O)

- 对于java.nio包，提供了Channel、Selector、Buffer等抽象概念，对于高负载高并发，应使用NIO
- NIO是I/O多路复用模型，属于同步非阻塞IO模型
  - 普通的同步非阻塞：应用程序会一直发起read调用，等待数据从内核空间拷贝到用户空间的这段时间，线程依然是阻塞的，知道内核把数据拷贝到用户空间（这里是通过不断轮询操作去数据）
  - I/O多路复用
    线程首先发起select调用，询问内核数据是否准备就绪，等准备好了，用户线程再发起read调用，read调用的过程（数据从内核空间-->用户空间）还是阻塞的
  - Selector，即多路复用器，一个线程管理多个客户端连接
    ![image-20221026163835033](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026163835033.png)

### AIO(Asynchronous I/O )

- 异步 IO 是基于**事件和回调**机制实现的，也就是**应用操作之后会直接返回**，不会堵塞在那里，当后台处理完成，操作系统会通知相应的线程进行后续的操作
  如图  
  ![image-20221026164006797](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026164006797.png)

## 三者区别

![image-20221026164100906](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026164100906.png)



> 大部分转自https://github.com/Snailclimb/JavaGuide