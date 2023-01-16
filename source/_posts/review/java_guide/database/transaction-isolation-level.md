---
title: MySQL事务隔离级别详解
description: 隔离级别
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-database
date: 2023-01-16 01:00:44
updated: 2023-01-16 01:00:44
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 事务隔离级别总结

- SQL标准定义了**四个隔离级别**

  1. **READ-UNCOMMITTED(读取未提交)**：**最低**的隔离级别，允许读取**尚未提交的数据**变更，可能会导致**脏读、幻读或不可重复读**
  2. **READ-COMMITED(读取已提交)**：允许读取**并发事务** **已经提交**的数据，可以阻止**脏读**，但是**幻读**或**不可重复读**仍有可能发生
  3. **REPEATABLE-READ(可重复读)**：对**同一字段的多次读取**结果都是一致的，除非数据是被**本身事务自己**所修改，可以**阻止脏读**和**不可重复读**，但**幻读**仍有可能发生
  4. **SERIALIZABLE(可串行化)**：**最高**的隔离级别，**完全服从ACID**的隔离级别。所有的**事务依次逐个**执行，这样事务之间就**完全不可能产生干扰**，也就是说，该级别可以防止**脏读**、**不可重复读**以及**幻读**。

  |     隔离级别     | 脏读 | 不可重复读 | 幻读 |
  | :--------------: | :--: | :--------: | :--: |
  | READ-UNCOMMITTED |  √   |     √      |  √   |
  |  READ-COMMITTED  |  ×   |     √      |  √   |
  | REPEATABLE-READ  |  ×   |     ×      |  √   |
  |   SERIALIZABLE   |  ×   |     ×      |  ×   |

- MySQL InnoDB 存储引擎的默认支持的隔离级别是 **REPEATABLE-READ（可重读）**

  > 使用命令查看，通过```SELECT @@tx_isolation;```。  
  > MySQL 8.0 该命令改为```SELECT @@transaction_isolation;```
  >
  > ```shell
  > MySQL> SELECT @@tx_isolation;
  > +-----------------+
  > | @@tx_isolation  |
  > +-----------------+
  > | REPEATABLE-READ |
  > +-----------------+ 
  > ```

- 从上面对SQL标准定义了**四个隔离级别**的介绍可以看出，标准的SQL隔离级别里，**REPEATABLE-READ(可重复读)**是不可以防止幻读的。但是，**InnoDB实现的REPEATABLE-READ** 隔离级别其实是可以**解决幻读**问题发生的，分两种情况

  1. **快照读**：由**MVCC**机制来保证不出现幻读
  2. **当前读**：使用**Next-Key Lock**进行加锁来保证不出现幻读，Next-Key Lock是**行锁（Record Lock ）和间隙锁（Gap Lock）的结合**，行锁只能锁住已经存在的行，为了避免插入新行，需要依赖**间隙锁**  (**只用间隙锁不行，因为间隙锁是 > 或 < ，不包括等于，所以再可重复读下原记录可能会被删掉**)

  因为**隔离级别越低，事务请求的锁越少**，所以大部分数据库系统的隔离级别都是 **READ-COMMITTED** ，但是你要知道的是 InnoDB 存储引擎默认使用 **REPEATABLE-READ** 并不会有任何性能损失。

- InnoDB 存储引擎在**分布式事务**的情况下一般会用到 **SERIALIZABLE 隔离级别**

  1. InnoDB 存储引擎提供了对 **XA 事务**的支持，并**通过 XA 事务来支持分布式事务**的实现。
  2. 分布式事务指的是允许**多个独立的事务资源（transactional resources）**参与到**一个全局的事务**中。事务资源通常是关系型数据库系统，但也可以是其他类型的资源。**全局事务**要求在其中的**所有参与的事务要么都提交**，要么**都回滚**，这对于事务原有的 ACID 要求又有了提高。
  3. 在**使用分布式事务时**，InnoDB 存储引擎的**事务隔离级别必须设置为 SERIALIZABLE**。

# 实际情况演示

- 下面会使用2个命令行MySQL，模拟多线程（多事务）对同一份数据的(脏读等)问题

  > MySQL 命令行的默认配置中事务都是自动提交的，即执行 SQL 语句后就会马上执行 COMMIT 操作。如果要显式地开启一个事务需要使用命令：**`START TRANSACTION`**

- 通过下面的命令来设置隔离级别
  session ：更改只有本次会话有效；global：更改在**所有会话都有效，且不会影响已开启的session**

  ```shell
  SET [SESSION|GLOBAL] TRANSACTION ISOLATION LEVEL [READ UNCOMMITTED|READ COMMITTED|REPEATABLE READ|SERIALIZABLE] 
  ```

- 实际操作中使用到的一些并发控制的语句

  1. ```START TRANSACTION | BEGIN```：显示地**开启一个事务** （begin也能开启一个事务）
  2. ```COMMIT```：**提交事务**，使得对数据库做的所有**修改成为永久性**
  3. ```ROLLBACK```：**回滚**，会**结束用户的事务**，并**撤销正在进行的所有未提交**的修改

## 脏读（读未提交）

1. 事务1 设置为**读未提交**级别 ```SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;```

   事务1开启事务并查看数据

   ```shell
   START TRANSACTION;
   SELECT salary FROM employ WHERE id = 1;
   
   # 结果
   +--------+
   | salary |
   +--------+
   |   5000 |
   +--------+
   ```

2. 开启新连接，事务2 开启事务并更新数据

   ```shell
   START TRANSACTION;
   UPDATE employ SET salary = 4500 ;
   ```

3. 事务1查看 ``` SELECT salary FROM employ WHERE id = 1;```

   ```shell
   +--------+
   | salary |
   +--------+
   |   4500 |
   +--------+
   ```

4. 此时事务2 进行回滚 ``` ROLLBACK;```
   使用事务1再次查看 ```SELECT salary FROM employ WHERE id = 1;```

   ```shell
   +--------+
   | salary |
   +--------+
   |   5000 |
   +--------+
   ```

   事务二进行了回滚，但是之前事务1却读取到了4500（是个脏数据）

## 避免脏读（读已提交）

**不要在上面的连接里继续**

1. 事务1 设置为读已提交```SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;```

   事务1 开启事务并查询数据  

   ```shell
   START TRANSACTION;
   SELECT salary FROM employ WHERE id = 1;
   
   # 结果
   +--------+
   | salary |
   +--------+
   |   5000 |
   +--------+
   ```

   

2. 事务2 开启并修改数据(未提交)

   ```shell
   START TRANSACTION;
    UPDATE employ SET salary =  4500 ;
   ```

3. 事务1查看数据  `` SELECT salary FROM employ WHERE id = 1;```
   因为事务隔离级别为**读已提交**，所以不会发生脏读

   ```shell
   # 结果
   +--------+
   | salary |
   +--------+
   |   5000 |
   +--------+
   ```

4. 事务2提交  ```COMMIT;```后，事务1再次读取数据 

   ```shell
   SELECT salary FROM employ WHERE id = 1;
   +--------+ 
   | salary | 
   +--------+ 
   |   4500 | 
   +--------+ 
   ```

## 不可重复读

还是刚才**读已提交**的那些步骤，重复操作可以知道  虽然**避免了读未提交**，但是出现了，**一个事务还没结束**，就发生了**不可重复读**问题   

> 同一个数据，在同一事务内读取多次但值不一样


![image-20230116150215200](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230116150215200.png)

## 可重复读

断开连接后重新连接MySQL，默认就是**REPEATABLE-READ** 可重复读

1. 事务1查看当前事务隔离级别 ```select @@tx_isolation;```

   ```shell
   +-----------------+
   | @@tx_isolation  |
   +-----------------+
   | REPEATABLE-READ |
   +-----------------+
   ```

   事务1 开启事务并查询数据

   ```shell
   START TRANSACTION;
   SELECT salary FROM employ WHERE id = 1;
   
   # 结果
   +--------+
   | salary |
   +--------+
   |   5000 |
   +--------+
   ```

2. 事务2 开启事务并更新数据

   ```shell
   START TRANSACTION;
   UPDATE employ SET salary = 4500 WHERE id = 1;
   ```

3. 事务1 读取数据（结果仍不变，避免了读未提交的问题）

   ```shell
   SELECT salary FROM employ WHERE id = 1;
   +--------+
   | salary |
   +--------+
   |   5000 |
   +--------+
   ```

4. 事务2提交事务 ```COMMIT ;```

5. 提交后事务1再次读取

   ```shell
    SELECT salary FROM employ WHERE id = 1;
   +--------+
   | salary |
   +--------+
   |   5000 |
   +--------+
   ```

6. 与MySQL建立新连接并查询数据（发现数据确实是已经更新了的）

   ```shell
   SELECT salary FROM employ WHERE id = 1;
   +--------+
   | salary |
   +--------+
   |   4500 |
   +--------+
   ```



## 幻读

**接下来测试一下该隔离策略下是否幻读**
这里是在**可重复读下**

1. 先查看一下当前数据库表的数据 

   ```shell
   SELECT * FROM test;
   +----+--------+
   | id | salary |
   +----+--------+
   |  1 |   8000 |
   |  6 |   500 |
   +----+--------+
   ```

2. ```use lydb;```  ---> 事务1和事务2都开启事务 ```START TRANSACTION;```

3. 事务2插入一条薪资为500的数据并提交

   ```shell
   INSERT INTO test(salary) values (500);
   COMMIT;
   #此时数据库已经有两条500的数据了(事务2)
    select * from test;
   +----+--------+
   | id | salary |
   +----+--------+
   |  1 |   8000 |
   |  6 |   500 |
   |  10 |   500 |
   +----+--------+
   ```

4. 事务1查询500的数据(**★★如果在事务2提交之前查询 SELECT * FROM test WHERE salary = 500; 或者 SELECT * FROM test; 那么这里[快照读]就只会查出一条，但是不管怎么样 [当前读]都会查出两条**)

   ```shell
   #---------------- # 快照读------------------
   SELECT * FROM test WHERE salary = 500;
   +----+--------+
   | id | salary |
   +----+--------+
   |  6 |    500 | 
   +----+--------+
   #----------------# 当前读------------------
   SELECT * FROM test WHERE salary = 500 FOR UPDATE;
   +----+--------+
   | id | salary |
   +----+--------+
   |  6 |    500 |
   | 11 |    500 |
   +----+--------+
   
   ```

5.  SQL 事务1 在第一次查询工资为 500 的记录时只有一条，SQL 事务2 插入了一条工资为 500 的记录，提交之后；SQL 事务1  在同一个事务中再次使用当前读查询发现出现了两条工资为 500 的记录这种就是幻读。

> 这里说明一下**当前读**和**快照读**：  
>
> 1. MySQL 里除了普通查询是**快照读**，其他都是**当前读**，比如 update、insert、delete，这些语句执行前都会查询最新版本的数据，然后再做进一步的操作
> 2. 【为什么上面要先进行查询的原因】可重复读隔离级是由 MVCC（多版本并发控制）实现的，实现的方式是开始事务后（执行 begin 语句后），在执行第一个查询语句后，会创建一个 Read View，**后续的查询语句利用这个 Read View，通过这个 Read View 就可以在 undo log 版本链找到事务开始时的数据，所以事务过程中每次查询的数据都是一样的**，即使中途有其他事务插入了新纪录，是查询不出来这条数据的，所以就很好了避免幻读问题。

## 解决幻读的方法

解决幻读的方式有很多，但是它们的核心思想就是**一个事务在操作某张表数据**的时候，另外一个事务**不允许新增或者删除这张表中的数据**了。解决幻读的方式主要有以下几种：

1. 将事务隔离级别调整为 `SERIALIZABLE` 。
2. 在**可重复读**的事务级别下，给**事务操作的这张表添加表锁**。
3. 在**可重复读**的事务级别下，给**事务操作的这张表添加 `Next-key Lock（Record Lock+Gap Lock）`**。