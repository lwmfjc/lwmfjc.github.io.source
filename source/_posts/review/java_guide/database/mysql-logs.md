---
title: 日志
description: 日志
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-database
date: 2023-01-14 17:31:53
updated: 2023-01-14 17:31:53
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 前言

- 首先要了解一个东西 ：WAL，全称 Write-Ahead Logging`，它的关键点就是`先写日志，再写磁盘

  > 1. WAL 机制的原理也很简单：**修改并不直接写入到数据库文件中，而是写入到另外一个称为 WAL 的文件中；如果事务失败，WAL 中的记录会被忽略，撤销修改；如果事务成功，它将在随后的某个时间被写回到数据库文件中，提交修改**
  >
  > 2. 使用 WAL 的数据库系统不会再每新增一条 WAL 日志就将其刷入数据库文件中，一般**积累一定的量然后批量写入，通常使用页为单位，这是磁盘的写入单位**。 同步 **WAL 文件和数据库文件的行为被称为 checkpoint（检查点）**，一般在 WAL 文件积累到一定页数修改的时候；当然，有些系统也可以手动执行 checkpoint。执行 checkpoint 之后，WAL 文件可以被清空，这样可以保证 WAL 文件不会因为太大而性能下降。
  >
  >    有些数据库系统读取请求也可以使用 WAL，通过读取 WAL 最新日志就可以获取到数据的最新状态  
  >
  >    > 关于checkpoint：https://www.cnblogs.com/chenpingzhao/p/5107480.html**思考一下这个场景**：如果重做日志可以无限地增大，同时缓冲池也足够大 ，那么是不需要将缓冲池中页的新版本刷新回磁盘。因为当发生宕机时，完全可以通过重做日志来恢复整个数据库系统中的数据到宕机发生的时刻。但是这需要两个前提条件：1、缓冲池可以缓存数据库中所有的数据；2、重做日志可以无限增大
  >    >
  >    > 因此Checkpoint（检查点）技术就诞生了，目的是解决以下几个问题：1、**缩短数据库的恢复时间**；2、**缓冲池不够用时，将脏页刷新到磁盘**；3、**重做日志不可用时，刷新脏页**。
  >    >
  >    > - 当数据库发生宕机时，数据库**不需要重做所有的日志，因为Checkpoint之前的页都已经刷新回磁盘**。数据库只需对Checkpoint后的重做日志进行恢复，这样就大大缩短了恢复的时间。
  >    > - 当缓冲池不够用时，根据LRU算法会溢出最近最少使用的页，若此页为脏页，那么需要强制执行Checkpoint，将脏页也就是页的新版本刷回磁盘。
  >    > - 当重做日志出现不可用时，因为当前事务数据库系统对重做日志的设计都是循环使用的，并不是让其无限增大的，重做日志可以被重用的部分是指这些重做日志已经不再需要，当数据库发生宕机时，数据库恢复操作不需要这部分的重做日志，因此这部分就可以被覆盖重用。如果重做日志还需要使用，那么必须强制Checkpoint，将缓冲池中的页至少刷新到当前重做日志的位置。
  >
  > 3. mysql 的 WAL，大家可能都比较熟悉。mysql 通过 redo、undo 日志实现 WAL。redo log 称为重做日志，每当有操作时，在数据变更之前将操作写入 redo log，这样当发生掉电之类的情况时系统可以在重启后继续操作。undo log 称为撤销日志，当一些变更执行到一半无法完成时，可以根据撤销日志恢复到变更之间的状态。mysql 中用 redo log 来在系统 Crash 重启之类的情况时修复数据（事务的持久性），而 undo log 来保证事务的原子性。

- `MySQL` 日志 主要包括**错误日志**、**查询日志**、**慢查询日志**、**事务日志**、**二进制日志**几大类
- 比较重要的
  1. 二进制日志： **binlog（归档日志）**【server层】
  2. 事务日志：**redo log（重做日志）**和**undo log（回滚日志）** 【引擎层】
  3. redo log是记录物理上的改变；  
     undo log是从逻辑上恢复，**产生时机：事务开始之前**
  4. MySQL InnoDB 引擎使用 **redo log(重做日志)** 保证事务的**持久性**，使用 **undo log(回滚日志)** 来保证事务的**原子性**。

![image-20230114174517643](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114174517643.png)

# redo log

- redo log（重做日志）是**InnoDB**存储引擎独有的，它让MySQL拥有了**崩溃恢复**的能力

  > 比如 `MySQL` 实例**挂了或宕机**了，**重启**时，`InnoDB`存储引擎会使用`redo log`恢复数据，保证数据的**持久性**与**完整性**。

  ![image-20230114185737370](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114185737370.png)

1. MySQL中数据是以**页（这个很重要，重点是针对页）**为单位，你查询一条记录，会**从硬盘把一页的数据加载出来**，加载出来的数据叫**数据页**，会放到**Buffer Pool**中  (这个时候 如果更新，buffer pool 中的数据页就与磁盘上的数据页**内容不一致**，我们称 buffer pool 的数据页为 **dirty page 脏数据**)

   > 以页为单位：  
   > 页是InnoDB 管理存储空间的基本单位，一个页的大小一般是16KB 。可以理解为创建一个表时，会创建一个大小为16KB大小的空间，也就是数据页。新增数据时会往该页中User Records中添加数据，如果页的大小不够使用了继续创建新的页。也就是说一般情况下一次最少从磁盘读取16kb的内容到内存，一次最少把16kb的内容刷新到磁盘中，其作用有点缓存行的意思
   > 原文链接：https://blog.csdn.net/qq_31142237/article/details/125447413

   > - 后续的查询都是先从 `Buffer Pool` 中找，没有命中再去硬盘加载，减少硬盘 `IO` 开销，提升性能。
   >
   > - 更新表数据的时候，也是如此，发现 `Buffer Pool` 里存在要更新的数据，就直接在 `Buffer Pool` 里更新

2. 把“**在某个数据页上做了什么修改**”记录到**重做日志缓存**（`redo log buffer`）里，接着**刷盘到 `redo log` 文件**里  
   即  从 硬盘上db数据文件 --> BufferPool --> redo log buffer --> redo log
   ![image-20230114190158828](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114190158828.png)

3. 理想情况，事务**一提交就会进行刷盘**操作，但**实际上**，刷盘的时机是**根据策略**

   > 每条redo记录由**”表空间号+数据页号+偏移量+修改数据长度+具体修改的数据“**组成

## 刷盘时机

- `InnoDB` 存储**引擎为 `redo log` 的刷盘策略提供了 `innodb_flush_log_at_trx_commit` 参数**，它支持三种策略  
  	**0**：设置为0时，表示每次**事务提交时不进行刷盘**操作  
  	**1**：设置为1时，表示每次**事务提交时都将进行刷盘**操作（默认值）  
  	**2**：设置为2时，表示每次**事务提交时都只把redo log buffer内容写入page cache(系统缓存)**

- `innodb_flush_log_at_trx_commit` 参数默认为 1 ，也就是说当事务提交时会**调用 `fsync` 对 redo log 进行刷盘**

- `InnoDB` 存储引擎有一个后台线程，每隔`1` 秒，就会把 `redo log buffer` 中的内容写到文件系统缓存（`page cache`），然后调用 `fsync` 刷盘。(即**没有提交事务的redo log记录，也有可能会刷盘，因为在事务执行过程 `redo log` 记录是会写入`redo log buffer` 中，这些 `redo log` 记录会被后台线程刷盘。**)  

  > 除了后台线程每秒`1`次的轮询操作，还有一种情况，当 `redo log buffer` 占用的空间即将达到 `innodb_log_buffer_size` 一半的时候，后台线程会主动刷盘 

![image-20230114210732904](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114210732904.png)

![image-20230114211124499](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114211124499.png)

**不同刷盘策略的流程图**  

- #### innodb_flush_log_at_trx_commit=0（不对是否刷盘做出处理）  

  > 为`0`时，如果`MySQL`挂了或宕机可能会有`1`秒数据的丢失。

  ![image-20230114211255976](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114211255976.png)

- #### innodb_flush_log_at_trx_commit=1  

  > 为`1`时， **只要事务提交成功**，**`redo log`记录就一定在硬盘里**，不会有任何数据丢失。如果事务执行期间`MySQL`挂了或宕机，这部分日志丢了，但是事务并没有提交，所以日志丢了也不会有损失。

  ![image-20230114211419216](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114211419216.png)

- #### innodb_flush_log_at_trx_commit=2

  > - 为`2`时， 只要**事务提交成功**，`redo log buffer`中的内容**只写入文件系统缓存**（`page cache`）。
  >
  > - 如果仅仅**只是`MySQL`挂了不会有任何数据丢失**，但是**宕机可能会有`1`秒数据的丢失**。

  ![image-20230114211535295](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114211535295.png)

## 日志文件组

- 硬盘上存储的 **`redo log` 日志文件不只一个**，而是以一个**日志文件组**的形式出现的，每个的`redo`日志文件大小都是一样的  

  > 比如可以配置为一组**`4`个文件**，**每个**文件的大小是 **`1GB`**，整个 `redo log` 日志文件组可以记录**`4G`**的内容

- 它采用的是**环形数组形式**，从头开始写，写到末尾又回到头循环写，如下图所示  
  ![image-20230114213913913](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114213913913.png)

- 在一个**日志文件组**中还有两个重要的属性，分别是 `write pos、checkpoint`

  1. **write pos** 是**当前记录**的位置，一边写一边后移
  2. **checkpoint** 是当前要**擦除**的位置，也是往后推移

  `write pos` 和 `checkpoint` 之间的还空着的部分可以用来写入新的 `redo log` 记录。    
  **ly: 我的理解是有个缓冲带**

  > 如果 `write pos` 追上 `checkpoint` (ly: 没有可以擦除的地方了），表示**日志文件组**满了，这时候不能再写入新的 `redo log` 记录，`MySQL` 得停下来，清空一些记录，把 `checkpoint` 推进一下。

![image-20230114214450281](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114214450281.png)

## redo log 小结

> 1. ★★这里有个很重要的问题，就是为什么允许擦除★★  
>    因为redo log记录的是数据页上的修改，如果Buffer Pool中数据页已经刷磁盘（这里说的磁盘是数据库数据吧）后，那这些记录就失效了，新日志会将这些失效的记录进行覆盖擦除。
> 2. redo log日志满了，在擦除之前，需要确保这些要**被擦除记录对应在内存中的数据页都已经刷到磁盘中**了。擦除旧记录腾出新空间这段期间，是不能再接收新的更新请求的，此刻MySQL的性能会下降。所以在并发量大的情况下，合理调整redo log的文件大小非常重要。

那为什么要绕这么一圈呢，**只要每次把修改后的数据页直接刷盘不就好了，还有 `redo log` 什么事？**  

![image-20230114221955537](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114221955537.png)

> ```java
> 1 Byte = 8bit
> 1 KB = 1024 Byte
> 1 MB = 1024 KB
> 1 GB = 1024 MB
> 1 TB = 1024 GB
> ```

1. 实际上，数据页是16KB，刷盘比较耗时，有时候可能就修改了数据页里的几Byte数据，有必要把完整的数据页刷盘吗

2. 数据页刷盘是随机写，因为**一个数据页对应的位置可能在硬盘文件的随机位置**，所以性能是很差  

   > 一个数据页对应的位置可能在硬盘文件的随机位置，即1页是16KB，这16KB，可能是在**某个硬盘文件的某个偏移量到某个偏移量之间**

3. 如果是写 `redo log`，一行记录可能就占几十 `Byte`，只包含表空间号、数据页号、磁盘文件偏移 量、更新值，再加上是**顺序写**，所以刷盘速度很快。

   > 其实内存的数据页在一定时机也会刷盘，我们把这称为页合并，讲 `Buffer Pool`的时候会对这块细说

# binlog



## 记录格式

## 写入机制

# 两阶段提交

# undo log

