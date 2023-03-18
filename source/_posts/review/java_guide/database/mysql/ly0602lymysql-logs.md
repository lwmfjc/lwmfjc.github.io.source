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

  > 在概念上，innodb通过***force log at commit\***机制实现事务的持久性，即在事务提交的时候，必须先将该事务的所有事务日志写入到磁盘上的redo log file和undo log file中进行持久化

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
  > 3. mysql 的 WAL，大家可能都比较熟悉。mysql 通过 redo、undo 日志实现 WAL。redo log 称为重做日志，每当有操作时，在**数据变更之前将操作写入 redo log**，这样当发生掉电之类的情况时系统可以在重启后继续操作。undo log 称为撤销日志，当一些变更执行到一半无法完成时，可以根据撤销日志恢复到变更之间的状态。mysql 中用 redo log 来在系统 Crash 重启之类的情况时修复数据（事务的持久性），而 undo log 来保证事务的原子性。

- `MySQL` 日志 主要包括**错误日志**、**查询日志**、**慢查询日志**、**事务日志**、**二进制日志**几大类

- mysql执行  
  ![image-20230313164253061](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230313164253061.png)

- 总结  
  ![image-20230318140400678](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230318140400678.png)

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
> 再具体点：防止在**发生故障的时间点**，尚有**脏页未写入磁盘**，在重启mysql服务的时候，根据redo log进行重做，从而达到事务的持久性这一特性

  ![image-20230114185737370](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114185737370.png)

1. MySQL中数据是以**页（这个很重要，重点是针对页）**为单位，你查询一条记录，会**从硬盘把一页的数据加载出来**，加载出来的数据叫**数据页**，会放到**Buffer Pool**中  (这个时候 如果更新，buffer pool 中的数据页就与磁盘上的数据页**内容不一致**，我们称 buffer pool 的数据页为 **dirty page 脏数据**)

   > 以页为单位：  
   > 页是InnoDB 管理存储空间的基本单位，一个页的大小一般是16KB 。可以理解为创建一个表时，会创建一个大小为16KB大小的空间，也就是数据页。新增数据时会往该页中User Records中添加数据，如果页的大小不够使用了继续创建新的页。也就是说一般情况下一次最少从磁盘读取16kb的内容到内存，**一次最少把16kb的内容刷新到磁盘中**，其作用有点缓存行的意思
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

- `InnoDB` 存储引擎有一个后台线程，每隔`1` 秒，就会把 `redo log buffer` 中的内容写到文件系统缓存（`page cache`），然后调用 `fsync` 刷盘。(★★重要★★即使**没有提交事务的redo log记录，也有可能会刷盘，因为在事务执行过程 `redo log` 记录是会写入`redo log buffer` 中，这些 `redo log` 记录会被后台线程刷盘。**)  

  > 除了后台线程每秒`1`次的轮询操作，还有一种情况，当 `redo log buffer` 占用的空间即将达到 `innodb_log_buffer_size` 一半的时候，后台线程会主动刷盘 

![image-20230114210732904](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114210732904.png)

![image-20230114211124499](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114211124499.png)

**不同刷盘策略的流程图**  

### innodb_flush_log_at_trx_commit=0（不对是否刷盘做出处理）  

  > 为`0`时，如果`MySQL`挂了或宕机可能会有`1`秒数据的丢失。  
  > （**由于事务提交成功也不会主动写入page cache，所以即使只有MySQL 挂了，没有宕机，也会丢失。**）

  ![image-20230114211255976](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114211255976.png)

### innodb_flush_log_at_trx_commit=1  

  > 为`1`时， **只要事务提交成功**，**`redo log`记录就一定在硬盘里**，不会有任何数据丢失。如果事务执行期间`MySQL`挂了或宕机，这部分日志丢了，但是事务并没有提交，所以日志丢了也不会有损失。

  ![image-20230114211419216](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230114211419216.png)

### innodb_flush_log_at_trx_commit=2

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

- **redo log**是**物理**日志，记录内容是**“在某个数据页上做了什么修改”**，属于**InnoDB 存储引擎**；而**bin log**是逻辑日志，记录内容是**语句的原始逻辑**，类似于 “给ID = 2 这一行的 c 字段加1”，属于**MYSQL Server**层  

  > 无论用什么存储引擎，只要**发生了表数据更新**，都会产生于binlog 日志

- MySQL的数据库的**数据备份**、**主备**、**主主**、**主从**都离不开binlog，需要依靠binlog来**同步数据**，**保证数据一致性**。
  ![image-20230115212733316](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115212733316.png)

- binlog会记录所有**涉及更新数据的逻辑操作**，而且是**顺序写**

## 记录格式

- `binlog` 日志有**三种格式**，可以通过**`binlog_format`**参数指定。
  1. **statement**
  2. **row**
  3. **mixed**

1. 指定**`statement`**，记录的内容是**`SQL`语句原文**，比如执行一条`update T set update_time=now() where id=1`，记录的内容如下
   ![image-20230115213035257](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115213035257.png)

   > 同步数据时会执行记录的SQL语句，但有个问题，**update_time = now() **会获取当前系统时间，直接执行会导致**与原库的数据不一致**

2. 为了解决上面问题，需要指定**row**，记录的不是简单的SQL语句，还包括**操作的具体数据**，记录内容如下  

   > - row格式的记录内容看不到详细信息，需要用**mysqlbinlog**工具解析出来
   > - `update_time=now()`变成了具体的时间`update_time=1627112756247`，条件后面的@1、@2、@3 都是该行数据第 1 个~3 个字段的原始值（**假设这张表只有 3 个字段**）

   ![image-20230115213231813](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115213231813.png)

   这样就能保证同步数据的一致性，通常情况下都是指定row，可以为**数据库的恢复与同步**带来更好的**可靠性**

3. 但是由于row需要更大的容量来记录，比较**占用空间**，**恢复与同步更消耗IO**资源，**影响执行速度**。
   折中方案，指定为**mixed**，记录内容为两者混合：MySQL会判断这条SQL语句是否引起数据不一致，如果是就用**row**格式，否则就使用**statement**格式

## 写入机制

- binlog的写入时机：**事务执行过程**中，先把日志写到**binlog cache**，**事务提交的时候（这个很重要，他不像redo log，binlog只有提交的时候才会刷盘）**，再把**binlog cache**写到binlog文件中

  > 因为一个事务的**`binlog`不能被拆开**，无论这个事务多大，也要确保**一次性写入**，所以系统会**给每个线程分配一个块内存作为`binlog cache`**

- 我们可以通过`binlog_cache_size`参数控制**单个线程 binlog cache 大小**，如果存储内容超过了这个参数，就要暂存到磁盘（`Swap`）：  
  binlog日志刷盘流程如下  
  ![image-20230115215957574](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115215957574.png)

  > - 上图的 write，是指把日志写入到文件系统的 **page cache**，并没有把数据持久化到磁盘，所以速度比较快
  > - 上图的 **fsync**，才是**将数据持久化到磁盘**的操作

- write和fsync的时机，由**sync_binlog**控制，默认为0

  1. 为**0**时，表示每次提交的事务都只**write**，由系统自行判断什么时候执行fsync
     ![image-20230115220404168](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115220404168.png)

     > 虽然性能会提升，但是如果机器宕机，**page cache**里面的binlog会**丢失**

  2. 设置为**1**，表示**每次提交事务**都会fsync ，就如同**redo log日志刷盘流程** 一样

  3. 折中，可以设置为**N(N>1)**，表示每次提交事物都write，但累积**N**个事务之后才**fsync**![image-20230115220338819](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115220338819.png)
     在出现**IO**瓶颈的场景里，将**sync_binlog**设置成一个较大的值，可以**提升性能**  
     同理，如果机器宕机，会**丢失最近N个事务的binlog日志**  



# 两阶段提交  



1. **redo log（重做日志）**让InnoDB存储引擎拥有了**崩溃恢复**的能力
2. **binlog（归档日志）**保证了MySQL**集群架构的数据一致性**

两者都属于**持久性**的保证，但**侧重点不同**  

- 更新语句过程，会记录**redo log**和**binlog**两块日志，以基本的事务为单位

- **redo log**在事务执行过程中可以**不断地写入**，而**binlog**只有在**提交事务时**才写入，所以**redo log**和**binlog**写入时机不一样

![image-20230115221716772](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115221716772.png)

**redo log**与**binlog** 两份日志之间的逻辑不一样，会出现什么问题？

- 以`update`语句为例，假设`id=2`的记录，字段`c`值是`0`，把字段`c`值更新成`1`，`SQL`语句为`update T set c=1 where id= 2`

- 假设执行过程中**写完redo log**日志后，**binlog日志写期间发生了异常**，会出现什么情况
  ![image-20230115222416227](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115222416227.png)

  > 由于`binlog`没写完就异常，这时候**`binlog`里面没有对应的修改记录**。因此，之后用**`binlog`日志恢复(备库)数据**时，就会少这一次更新，恢复出来的这一行`c`值是`0`，而**原库因为`redo log`日志恢复，这一行`c`值是`1`，最终数据不一致**。
  >
  > ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/03-20220305235104445.png)

- 为了解决**两份日志之间的逻辑一致**问题，InnoDB存储引擎使用**两阶段提交**方案
  即将redo log的写入拆成了两个步骤**prepare**和**commit**，这就是**两阶段提交**（**其实就是等binlog正式写入后redo log才正式提交**）
  ![image-20230115222722278](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115222722278.png)

  > 使用**两阶段提交**后，写入`binlog`时发生异常也不会有影响，因为**`MySQL`根据`redo log`日志恢复数据**时，**发现`redo log`还处于`prepare`阶段（也就是下图的`非commit阶段`）**，并且**没有对应`binlog`日志**，就会**回滚该事务**。
  >
  > 其实下图中，**是否存在对应的binlog**，就是想知道**binlog是否是完整的**，如果完整的话 redolog就可以提交 （箭头前面**是否commit阶段**，是的话就表示binlog写入期间没有出错，即binlog完整）
  > ![image-20230115222906325](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115222906325.png)
  >
  > 还有个问题，**`redo log`设置`commit`阶段发生异常**，那会不会回滚事务呢？    
  >  ![image-20230115223656461](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230115223656461.png)
  >
  > > 并不会回滚事务，它会执行上图框住的逻辑，虽然`redo log`是处于`prepare`阶段，但是**能通过事务`id`找到对应的`binlog`日志**，所以**`MySQL`认为(binlog)是完整的**，就会**提交事务恢复数据**。

# undo log

- 如果想要保证**事务的原子性**，就需要在**异常发生**时，对已经执行的操作进行**回滚**，在 MySQL 中，恢复机制是通过 **回滚日志（undo log）** 实现的，**所有事务进行的修改都会先记录到这个回滚日志**中，**然后再执行相关的操作**
- 如果**执行过程中遇到异常**的话，我们直接利用 **回滚日志** 中的信息将数据回滚到修改之前的样子即可！
- 回滚日志会**先于数据（数据库数据）持久化到磁盘**上。这样就保证了即使遇到数据库突然宕机等情况，当用户再次启动数据库的时候，数据库还**能够通过查询回滚日志来回滚将之前未完成的事务**。

关于undo log：

> 参考https://blog.csdn.net/Weixiaohuai/article/details/117867353
>
> 1. undo log是**逻辑日志**，而且记录的是**相反的语句**
>
> 2. undo log日志里面不仅存放着数据更新前的记录，还记录着RowID、事务ID、回滚指针。其中事务ID每次递增，回滚指针第一次如果是insert语句的话，回滚指针为NULL**，第二次update之后的undo log的回滚指针就会指向刚刚那一条undo log日志**，依次类推，就会形成一条undo log的回滚链，方便找到该条记录的历史版本
>
> 3. **更新数据之前**，MySQL会**提前生成undo log日志**，当事务提交的时候，并不会立即删除undo log，因为后面可能需要进行回滚操作，要执行回滚（rollback）操作时，从缓存中读取数据。undo log日志的删除是通过通过后台purge线程进行回收处理的。
>
> 4. 举例  
>
>    > 假设有A、B两个数据，值分别为1,2。
>    >
>    > A. 事务开始  
>    > B. 记录A=1到undo log中  
>    > C. 修改A=3  
>    > D. 记录B=2到undo log中  
>    > E. 修改B=4  
>    > F. 将undo log写到磁盘 -------undo log持久化  
>    > G. 将数据写到磁盘 -------数据持久化  
>    > H. 事务提交 -------提交事务  
>
> 5. 由于以下特点，所以能保证原子性和持久化
>
>    1. 更新数据前记录undo log。  
>    2. 为了保证持久性，必须将数据在事务提交前写到磁盘，只要事务成功提交，数据必然已经持久化到磁盘。
>    3. **undo log必须先于数据持久化到磁盘**。如果在G,H之间发生系统崩溃，undo log是完整的，可以用来回滚。
>    4. 如果在A - F之间发生系统崩溃，因为数据没有持久化到磁盘，所以磁盘上的数据还是保持在事务开始前的状态。

> 参考https://developer.aliyun.com/article/1009683
>
> https://www.cnblogs.com/defectfixer/p/15835714.html
>
> **MySQL 的 InnoDB 存储引擎使用“Write-Ahead Log”日志方案实现本地事务的原子性、持久性。**
>
> **“提前写入”（Write-Ahead），就是在事务提交之前，允许将变动数据写入磁盘。与“提前写入”相反的就是，在事务提交之前，不允许将变动数据写入磁盘，而是等到事务提交之后再写入。**
>
> **“提前写入”的好处是：有利于利用空闲 I/O 资源。但“提前写入”同时也引入了新的问题：在事务提交之前就有部分变动数据被写入磁盘，那么如果事务要回滚，或者发生了崩溃，这些提前写入的变动数据就都成了错误。“Write-Ahead Log”日志方案给出的解决办法是：增加了一种被称为 Undo Log 的日志，用于进行事务回滚。**
>
> **变动数据写入磁盘前，必须先记录 Undo Log，Undo Log 中存储了回滚需要的数据。在事务回滚或者崩溃恢复时，根据 Undo Log 中的信息对提前写入的数据变动进行擦除。**
>
> **更新一条语句的执行过程(ly:根据多方资料验证，这个是对的，事务提交前并不会持久化到db磁盘数据库文件中)**
>
> > 回答题主的问题，对MySQL数据库来说，事务提交之前，操作的数据存储在数据库在内存区域中的缓冲池中，即写的是内存缓冲池中的页(page cache)，同时会在缓冲池中写undolog(用于回滚)和redolog、binlog(用于故障恢复，保证数据持久化的一致性)，事务提交后，有数据变更的页，即脏页，会被持久化到物理磁盘。
> >
> > 
> >
> > 作者：王同学
> > 链接：https://www.zhihu.com/question/278643174/answer/1998207141
> > 来源：知乎
> > 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
>
> 执行后的几个步骤
>
> 1. **事务开始**
> 2. 申请加锁：表锁、MDL 锁、行锁、索引区间锁（看情况加哪几种锁）
> 3. **执行器找存储引擎**取数据。
> 4. 1. 如果记录所在的数据页本来就在内存（innodb_buffer_cache）中，存储引擎就直接返回给执行器；
>    2. 否则，存储引擎需要先将该数据页**从磁盘读取到内存**，然后再返回给执行器。
> 5. **执行器拿到存储引擎给的行数据**，**进行更新**操作后，**再调用存储引擎接口写入这行新数据(6 - 9)**。
> 6. 存储引擎将回滚需要的数据记录到 Undo Log，并将这个更新操作记录到 Redo Log，此时 Redo Log 处于 prepare 状态。并将这行新数据更新到内存（innodb_buffer_cache）中。同时，然后告知执行器执行完成了，随时可以提交事务。
> 7. **手动事务 commit**：执行器生成这个操作的 Binary Log，并把 Binary Log 写入磁盘。
> 8. 执行器调用存储引擎的提交事务接口，存储引擎把刚刚写入的 Redo Log 改成 commit 状态。
> 9. **事务结束**

# MVCC

- `MVCC` 的实现依赖于：**隐藏字段、Read View、undo log**。

- 内部实现中，`InnoDB` 通过数据行的 **`DB_TRX_ID`** 和 **`Read View`** 来判断数据的可见性，如不可见，则通过数据行的 `DB_ROLL_PTR` 找到 `undo log` 中的历史版本。

  > 每个事务读到的数据版本可能是不一样的，在同一个事务中，用户只能看到该事务创建 `Read View` 之前已经提交的修改和该事务本身做的修改

# 总结

- MySQL InnoDB 引擎使用 **redo log(重做日志)** 保证事务的**持久性**，使用 **undo log(回滚日志)** 来保证事务的**原子性**。
- `MySQL`数据库的**数据备份、主备、主主、主从**都离不开`binlog`，需要依靠`binlog`来同步数据，保证数据一致性。
- 三大日志大概的流程
  ![image-20230116002657069](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230116002657069.png)



