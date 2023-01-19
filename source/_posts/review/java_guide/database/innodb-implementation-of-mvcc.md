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
updated: 2023-01-19 10:18:00
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

- MVCC的实现依赖于：**隐藏字段（每条记录的）**、**ReadView（当前事务生成的）**、**undo log（当前事务执行时，为每个操作（记录）生成的）**
- **内部实现**中，InnoDB通过数据行的**DB_TRX_ID**和**Read View**来判断数据的可见性，如不可见，则通过**数据行的DB_ROLL_PTR**找到**undo log**中的历史版本。**因此**，每个事务读到的**数据版本**可能是不一样的，**在同一个事务中**，用户只能看到**该事务创建ReadView**之前**（其实这个说法不太准确，m_up_limit_id不一定大于当前事务id）**已经提交的修改和**该事务本身做的修改**

## 隐藏字段

- **内部**，**InnoDB**存储引擎为**每行数据**添加了**三个隐藏字段**：  
  1. **DB_TRX_ID(6字节)**：表示**最后一次插入**或**更新该行**的**事务id**。此外，**delete**操作在内部被视为更新，只不过会在**记录头Record header**中的**deleted_flag**字段将其标记为**已删除**  
  2. **DB_ROLL_PTR(7字节)**：回滚指针，指向**该行的undo log**。如果该行**违背更新**，则为**空**
  3. **DB_ROW_ID(6字节)**：如果**没有设置主键**且**该表没有唯一非空索引**时，InnoDB会使用该id来**生成聚簇索引**

## ReadView

```java
class ReadView {
  /* ... */
private:
  trx_id_t m_low_limit_id;      /* 大于等于这个 ID 的事务均不可见 */

  trx_id_t m_up_limit_id;       /* 小于这个 ID 的事务均可见 */

  trx_id_t m_creator_trx_id;    /* 创建该 Read View 的事务ID */

  trx_id_t m_low_limit_no;      /* 事务 Number, 小于该 Number 的 Undo Logs 均可以被 Purge */ 

  ids_t m_ids;                  /* 创建 Read View 时的活跃事务列表 */

  m_closed;                     /* 标记 Read View 是否 close */
} 
```

- **Read View** 主要是用来做**可见性**判断，里面保存了 “**当前对本事务不可见的其他活跃事务**”  

- ReadView主要有以下字段  

  1. `m_low_limit_id`：**目前出现过的最大的事务 ID+1**，即下一个将被分配的事务 ID。大于等于这个 ID 的数据版本均不可见
  2. `m_up_limit_id`：**活跃事务列表 `m_ids` 中最小的事务 ID**，如果 `m_ids` 为空，则 `m_up_limit_id` 为 `m_low_limit_id`。小于这个 ID 的数据版本均可见
  3. `m_ids`：**`Read View` 创建时其他未提交的活跃事务 ID 列表**。创建 `Read View`时，将当前未提交事务 ID 记录下来，后续即使它们修改了记录行的值，对于当前事务也是不可见的。`m_ids` 不包括当前事务自己和已提交的事务（正在内存中）
  4. `m_creator_trx_id`：**创建该 `Read View` 的事务 ID**

- **事务可见性**示意图（这个图容易理解）：  

  > 为什么不是分**大于m_low_limit_id**和**在小于m_low_limit_id里过滤存在于活跃事务列表**，应该和算法有关吧


  ![image-20230118155617419](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230118155617419.png)

## undo-log

- undo log主要有两个作用

  1. 当**事务回滚时用于将数据恢复**到修改前的样子
  2. 用于**MVCC**，读取记录时，若该记录被其他事务**占用**或当前版本**对该事务不可见**，则可以**通过**undo log 读取之前的版本数据，以此实现**非锁定读**

- **InnoDB**存储引擎中**undo log**分为两种：**insert undo log**和**update undo log**

  1. **insert undo log**：指在**insert**操作中产生的**undo log**，因为**insert**操作的记录只对事务本身可见，对其他事务不可见，故**该undo log**可以在**事务提交后直接删除**。不需要进行**purge**操作（purge：清洗）

     **insert**时的数据初始状态：(DB_ROLL_PTR为空)  
     ![image-20230119092412325](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230119092412325.png)

  2. **update undo log**：**undate**或**delete**操作产生的undo log。该undo log 可能需要**提供给MVCC机制**，因此不能在事务提交时就进行删除。提交时放入undo log链表，等待**purge线程**进行最后的删除

- 数据第一次修改时  
  ![image-20230119092627138](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230119092627138.png)

- 数据第二次被修改时  
  ![image-20230119092833856](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230119092833856.png)
  **不同事务**或者**相同事务**的**对同一记录行的修改**，会使**该记录行**的 **`undo log` 成为一条链表**，**链首**就是**最新**的记录，**链尾**就是**最早**的旧记录。

## 数据可见性算法

- 在 `InnoDB` 存储引擎中，创建一个新事务后，**执行每个 `select` 语句前(RC下是)**，都会创建一个快照（**Read View**），**快照中保存了当前数据库系统中正处于活跃（没有 commit）的事务的 ID 号**。其实简单的说保存的是系统中**当前不应该被本事务看到的其他事务 ID 列表（即 m_ids）**。当用户在这个事务中要读取某个记录行的时候，`InnoDB` 会将该**记录行的 `DB_TRX_ID`** 与 **`Read View` 中的一些变量**及**当前事务 ID** 进行比较，判断是否满足可见性条件

- 具体的比较算法  
  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/8778836b-34a8-480b-b8c7-654fe207a8c2.3d84010e.png)

  1. 如果**记录 DB_TRX_ID < m_up_limit_id**，那么表明最新修改该行的事务（DB_TRX_ID）在当前事务创建快照之前就提交了，所以该记录行的值对当前事务是**可见**的
  2. 如果 **DB_TRX_ID >= m_low_limit_id**，那么表明最新修改该行的事务（DB_TRX_ID）在当前事务创建快照之后才修改该行，所以该记录行的值对当前事务**不可见**。跳到步骤 5
  3. **m_ids 为空（且DB_TRX_ID < m_low_limit_id）**，则表明在当前事务创建快照之前，修改该行的事务就已经提交了，所以该记录行的值**对当前事务是可见**的
  4. 如果 **m_up_limit_id <= DB_TRX_ID < m_low_limit_id**，表明最新修改该行的事务（DB_TRX_ID）在当前事务创建快照的时候可能处于“活动状态”或者“已提交状态”；所以就要对活跃事务列表 m_ids 进行查找（源码中是用的二分查找，因为是有序的）
     - 如果**在活跃事务列表 m_ids 中能找到 DB_TRX_ID**，表明：① 在当前事务**创建快照前**，该记录行的值被事务 ID 为 DB_TRX_ID 的事务**修改了，但没有提交**；或者 ② 在**当前事务创建快照后**，该记录行的值**被事务 ID 为 DB_TRX_ID 的事务修改**了。这些情况下，这个记录行的值对当前事务都是不可见的。跳到步骤 5
     - 在活跃事务列表中**找不到**，则表明“id 为 trx_id 的事务”在修改“该记录行的值”后，在**“当前事务”创建快照前就已经提交**了，所以记录行对当前事务可见
  5. **在该记录行的 DB_ROLL_PTR 指针所指向的 `undo log` 取出快照记录**，用快照记录的 DB_TRX_ID 跳到步骤 1 重新开始判断，直到找到满足的快照版本或返回空

  

# RC 和 RR 隔离级别下 MVCC 的差异

在事务隔离级别 **`RC` 和 `RR`** （InnoDB 存储引擎的默认事务隔离级别）下，**`InnoDB` 存储引擎使用 `MVCC`（非锁定一致性读）**，但它们**生成 `Read View` 的时机却不同**
【**RC：Read Commit 读已提交，RR：Repeatable Read 可重复读**】

- 在 RC 隔离级别下的 **`每次select`** 查询前都生成一个`Read View` (m_ids 列表)
- 在 RR 隔离级别下只在事务开始后 **`第一次select`** 数据前生成一个`Read View`（m_ids 列表）

# MVCC解决不可重复读问题

虽然 RC 和 RR 都通过 `MVCC` 来读取快照数据，但由于 **生成 Read View 时机不同**，从而在 **RR 级别下实现可重复读**

举例：  （Tn 表示时间线）  
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/6fb2b9a1-5f14-4dec-a797-e4cf388ed413.ea9e47d7.png)

## 在RC下ReadView生成情况

**1. 假设时间线来到 T4 ，那么此时数据行 id = 1 的版本链为：**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/a3fd1ec6-8f37-42fa-b090-7446d488fd04.bf41f07c.png)

由于 RC 级别下每次查询都会生成`Read View` ，并且事务 101、102 并未提交，此时 `103` 事务生成的 `Read View` 中活跃的事务 **`m_ids` 为：[101,102]** ，`m_low_limit_id`为：104，`m_up_limit_id`为：101，`m_creator_trx_id` 为：103

- 此时最新记录的 `DB_TRX_ID` 为 101，m_up_limit_id <= 101 < m_low_limit_id，所以要在 **`m_ids` 列表中查找**，发现 **`DB_TRX_ID` 存在列表**中，那么这个记录不可见
- **根据 `DB_ROLL_PTR` 找到 `undo log` 中的上一版本记录**，上一条记录的 `DB_TRX_ID` 还是 101，不可见
- 继续找**上一条 `DB_TRX_ID`为 1**，满足 **1 < m_up_limit_id，可见**，所以事务 103 查询到数据为 `name = 菜花`

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/6fb2b9a1-5f14-4dec-a797-e4cf388ed413.ea9e47d7.png)

**2. 时间线来到 T6 ，数据的版本链为：**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/528559e9-dae8-4d14-b78d-a5b657c88391.2ff79120.png)

因为在 RC 级别下，重新生成 `Read View`，这时事务 **101 已经提交，102 并未提交**，所以此时 `Read View` 中活跃的事务 **`m_ids`：[102]** ，`m_low_limit_id`为：104，`m_up_limit_id`为：102，`m_creator_trx_id`为：103

- 此时最新记录的 **`DB_TRX_ID` 为 102**，m_up_limit_id <= 102 < m_low_limit_id，所以要**在 `m_ids` 列表中查找**，发现 `DB_TRX_ID` 存在列表中，那么这个记录不可见
- 根据 `DB_ROLL_PTR` 找到 `undo log` 中的上一版本记录，**上一条记录的 `DB_TRX_ID` 为 101，满足 101 < m_up_limit_id**，记录可见，所以在 `T6` 时间点查询到数据为 `name = 李四`，与时间 T4 查询到的结果不一致，不可重复读！

**3. 时间线来到 T9 ，数据的版本链为：**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/6f82703c-36a1-4458-90fe-d7f4edbac71a.c8de5ed7.png)

重新生成 `Read View`， 这时**事务 101 和 102 都已经提交，所以 m_ids 为空**，则 m_up_limit_id = m_low_limit_id = 104，最新版本事务 ID 为 102，满足 102 < m_low_limit_id，可见，查询结果为 `name = 赵六`

> **总结：** **在 RC 隔离级别下，事务在每次查询开始时都会生成并设置新的 Read View，所以导致不可重复读**

## 在RR下ReadView生成情况

在可重复读级别下，只会在事务开始后**第一次读取数据时生成一个 Read View（m_ids 列表）**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/6fb2b9a1-5f14-4dec-a797-e4cf388ed413.ea9e47d7.png)

**1. 在 T4 情况下的版本链为：**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/0e906b95-c916-4f30-beda-9cb3e49746bf.3a363d10.png)

在当前执行 `select` 语句时生成一个 `Read View`，此时 **`m_ids`：[101,102]** ，`m_low_limit_id`为：104，`m_up_limit_id`为：101，`m_creator_trx_id` 为：103

此时和 RC 级别下一样：

- 最新记录的 `DB_TRX_ID` 为 101，m_up_limit_id <= 101 < m_low_limit_id，所以要在 `m_ids` 列表中查找，发现 `DB_TRX_ID` 存在列表中，那么这个记录不可见
- 根据 `DB_ROLL_PTR` 找到 `undo log` 中的上一版本记录，上一条记录的 `DB_TRX_ID` 还是 101，不可见
- 继续找上一条 `DB_TRX_ID`为 1，满足 1 < m_up_limit_id，可见，所以事务 103 查询到数据为 `name = 菜花`

**2. 时间点 T6 情况下：**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/79ed6142-7664-4e0b-9023-cf546586aa39.9c5cd303.png)

在 RR 级别下只会生成一次`Read View`，所以此时依然沿用 **`m_ids` ：[101,102]** ，`m_low_limit_id`为：104，`m_up_limit_id`为：101，`m_creator_trx_id` 为：103

- **最新记录的 `DB_TRX_ID` 为 102**，m_up_limit_id <= 102 < m_low_limit_id，所以要在 `m_ids` 列表中查找，**发现 `DB_TRX_ID` 存在列表中，那么这个记录不可见**
- 根据 **`DB_ROLL_PTR` 找到 `undo log` 中的上一版本记录，上一条记录的 `DB_TRX_ID` 为 101，不可见** 【**从这步开始就跟T4一样了**】
- 继续根据 `DB_ROLL_PTR` 找到 `undo log` 中的上一版本记录，上一条记录的 `DB_TRX_ID` 还是 101，不可见
- 继续找上一条 `DB_TRX_ID`为 1，满足 1 < m_up_limit_id，可见，所以事务 103 查询到数据为 `name = 菜花`

**3. 时间点 T9 情况下：**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/cbbedbc5-0e3c-4711-aafd-7f3d68a4ed4e.7b4a86c0.png)

此时情况跟 T6 完全一样，由于已经生成了 `Read View`，此时依然沿用 **`m_ids` ：[101,102]** ，所以查询结果依然是 `name = 菜花`

# MVCC+Next-key -Lock防止幻读

`InnoDB`存储引擎在 RR 级别下通过 `MVCC`和 `Next-key Lock` 来解决幻读问题：

**1、执行普通 `select`，此时会以 `MVCC` 快照读的方式读取数据**

在快照读的情况下，RR 隔离级别只会在事务开启后的第一次查询生成 `Read View` ，并使用至事务提交。所以在生成 **`Read View` 之后其它事务所做的更新、插入记录版本对当前事务并不可见**，实现了**可重复读**和**防止快照读下的 “幻读”**

**2、执行 select...for update/lock in share mode、insert、update、delete 等当前读**

- 在当前读下，读取的都是**最新**的数据，如果其它事务有插入新的记录，并且刚好在当前事务查询范围内，就会产生幻读！

- `InnoDB` 使用 [Next-key Lockopen in new window](https://dev.mysql.com/doc/refman/5.7/en/innodb-locking.html#innodb-next-key-locks) 来防止这种情况。当执行当前读时，会**锁定读取到的记录的同时，锁定它们的间隙**，防止**其它事务在查询范围内插入数据**。只要我**不让你插入，就不会发生幻读**

> Next-Key* Lock(临键锁) 是**Record Lock(记录锁) 和Gap* Lock(间隙锁)** 的结合