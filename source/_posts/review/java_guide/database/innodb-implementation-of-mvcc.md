---
title: innodb引擎对MVCC的实现
description: innodb引擎对MVCC的实现
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-database
date: 2023-01-16 19:23:55
updated: 2023-01-16 19:23:55
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 一致性非锁定读和锁定读

## 一致性非锁定读

★★非锁定★★  

- 对于**一致性非锁定读（Consistent Nonlocking Reads）**的实现，通常做法是**加一个版本号**或者**时间戳**字段，在更新数据的同时**版本号+1**或者**更新时间戳**。查询时，将**当前可见的版本号**与**对应记录的版本号**进行比对，如果**记录的版本**小于**可见版本**，则表示**该记录可见**
- **InnoDB**存储引擎中，**多版本控制（multi versioning）**即使非锁定读的实现。如果读取的行**正在执行DELETE**或**UPDATE**操作，这时读取操作**不会去等待行上** **锁的释放**.相反地，Inn哦DB存储引擎会去读取**行的一个快照数据**，对于这种**读取历史数据**的方式，我们叫它**快照读（snapshot read）**。  
- 在 **`Repeatable Read`** 和 **`Read Committed`** 两个隔离级别下，如果是执行普通的 `select` 语句（**不包括 `select ... lock in share mode` ,`select ... for update`**）则会使用 **`一致性非锁定读（MVCC）`**。并且在 **`Repeatable Read` 下 `MVCC` 实现了可重复读和防止部分幻读**

## 锁定读

- 如果执行的是下列语句，就是**锁定读（Locking Reads）**

  1. ```select ... lock in share```
  2. ```select ... for update```
  3. ``insert ``、``upate``、```delete```

- 锁定读下，读取的是数据的最新版本，这种读也被称为**当前读current read**。**锁定读**会对读取到的记录加锁  

  1. ```select ... lock in share mode ```：对(读取到的)记录加**S锁**，其他事务也可以加S锁，如果加X锁则会被阻塞
  2. ```select ... for update```、```insert```、```update```、```delete```：对记录加**X锁**，且其他事务不能加任何锁

- 在一致性非锁定读下，即使读取的记录**已被其他事务加上X锁**，这时记录也是可以被读取的，即读取的**快照数据**。

  1. 在**RepeatableRead**下MVCC**防止了部分幻读**，这边的“**部分”**是指在**一致性非锁定读**情况下，只能读取到第一次查询之前所插入的数据（**根据ReadView判断数据可见性，ReadView在第一次查询时生成**），但如果是**当前读**，每次读取的都是**最新数据**，这时如果两次查询中间有其他事务插入数据，就会**产生幻读**
  2. 所以，InnoDB在实现RepeatableRead时，如果执行的是**当前读**，则会对读取的记录使用**Next-key Lock**，来防止其他事务在**间隙间插入数据**。

  > **RR产生幻读的另一个场景**
  >
  > - 假设有这样一张表  
  >   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/7f9df142b3594daeaaca495abb7133f5.png)
  >
  > - 事务 A 执行查询 id = 5 的记录，此时表中是没有该记录的，所以查询不出来。
  >
  >   ```shell
  >   # 事务 A
  >   mysql> begin;
  >   Query OK, 0 rows affected (0.00 sec)
  >   
  >   mysql> select * from t_stu where id = 5;
  >   Empty set (0.01 sec)
  >   ```
  >
  > - 然后事务 B 插入一条 id = 5 的记录，并且提交了事务。  
  >
  >   ```shell
  >   # 事务 B
  >   mysql> begin;
  >   Query OK, 0 rows affected (0.00 sec)
  >   
  >   mysql> insert into t_stu values(5, '小美', 18);
  >   Query OK, 1 row affected (0.00 sec)
  >   
  >   mysql> commit;
  >   Query OK, 0 rows affected (0.00 sec)
  >   ```
  >
  > - 此时，**事务 A 更新 id = 5 这条记录，对没错，事务 A 看不到 id = 5 这条记录，但是他去更新了这条记录，这场景确实很违和，然后再次查询 id = 5 的记录，事务 A 就能看到事务 B 插入的纪录了，幻读就是发生在这种违和的场景**。
  >
  >   ```shell
  >   # 事务 A
  >   mysql> update t_stu set name = '小林coding' where id = 5;
  >   Query OK, 1 row affected (0.01 sec)
  >   Rows matched: 1  Changed: 1  Warnings: 0
  >   
  >   mysql> select * from t_stu where id = 5;
  >   +----+--------------+------+
  >   | id | name         | age  |
  >   +----+--------------+------+
  >   |  5 | 小林coding   |   18 |
  >   +----+--------------+------+
  >   1 row in set (0.00 sec)
  >   ```
  >
  > - 时序图如下  
  >   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/%25E5%25B9%25BB%25E8%25AF%25BB%25E5%258F%2591%25E7%2594%259F.drawio.png)
  >
  > - 在可重复读隔离级别下，事务 A 第一次执行普通的 select 语句时生成了一个 ReadView，之后事务 B 向表中新插入了一条 id = 5 的记录并提交。接着，事务 A 对 id = 5 这条记录进行了更新操作，在这个时刻，**这条新记录的 trx_id 隐藏列的值**就**变成了事务 A 的事务 id**，之后事务 A 再使用普通 select 语句去查询这条记录时就可以看到这条记录了，于是就发生了幻读。
  >
  >   因为这种特殊现象的存在，所以我们认为 **MySQL Innodb 中的 MVCC 并不能完全避免幻读现象**。

# InnoDB对MVCC的实现
## 隐藏字段
## ReadView

## undo-log

## 数据可见性算法

# RC和RR隔离级别下MVCC的区别

# MVCC解决不可重复读问题

## 在RC下ReadView生成情况

## 在RR下ReadView生成情况

# MVCC+Next-key -Lock防止幻读