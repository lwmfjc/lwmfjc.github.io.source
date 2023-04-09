---
title: 高级功能
description: 高级功能
tags:
  - rocketmq-hm
categories:
  - 学习
date: 2023-04-09 09:20:04
updated: 2023-04-09 09:20:04
---

> 学习来源 https://www.bilibili.com/video/BV1L4411y7mn（添加小部分笔记）感谢作者！

# 消息存储

## 流程

![image-20230409093042579](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230409093042579.png)

## 存储介质

### 关系型数据库DB

适合数据量不够大，比如**ActiveMQ**可选用JDBC方式作为消息持久化

### 文件系统

1. 关系型数据库最终也是要存到文件系统中的，不如直接存到文件系统，绕过关系型数据库
2. 常见的RocketMQ/RabbitMQ/Kafka都是采用消息刷盘到计算机的文件系统来做持久化(**同步刷盘**/**异步刷盘**)

# 高可用性机制

## 消息发送

1. 顺序写：600MB/s，随机写：100KB/s  

   > - 系统运行一段时间后，我们对文件的增删改会导致磁盘上数据无法连续，非常的分散。
   >
   > - 顺序读也只是逻辑上的顺序，也就是按照当前文件的相对偏移量顺序读取，并非磁盘上连续空间读取
   > - 对于磁盘的读写分为两种模式，**顺序IO**和**随机IO**。 随机IO存在一个寻址的过程，所以效率比较低。而顺序IO，相当于有一个**物理索引**，在读取的时候不需要寻找地址，效率很高。 
   > - 来源： https://www.cnblogs.com/liuche/p/15455808.html

2. 数据网络传输  

   零拷贝技术**MappedByteBuffer**，省去了用户态，由**内核态**直接拷贝到**网络驱动内核**。    
   RocketMQ默认设置单个CommitLog日志数据文件为1G


   ![image-20230409100016046](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230409100016046.png)

## 消息存储

三个概念：commitLog、ConsumerQueue、index

### CommitLog

1. 默认大小1G  
   ![image-20230409101340190](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230409101340190.png)
2. 存储消息的元数据，包括了Topic、QueueId、Message
3. 还存储了ConsumerQueue相关信息，所以ConsumerQueue丢了也没事

### ConsumerQueue

1. 存储了消息在CommitLog的索引（几百K，Linux会事先加载到内存中）
2. 包括最小/最大偏移量、已经消费的偏移量
3. 一个Topic多个队列，每个队列对应一个ConsumerQueue  
   ![image-20230409104112974](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230409104112974.png)

### Index

也是索引文件，为消息查询服务，通过key或时间区间查询消息

### 总结

![image-20230409104824102](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230409104824102.png)

# 负载均衡

# 消息重试

# 死信队列

# 消费幂等