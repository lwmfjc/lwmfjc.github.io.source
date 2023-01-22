---
title: MySQL常见面试题总结
description: MySQL常见面试题总结
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-database
date: 2023-01-20 11:36:06
updated: 2023-01-20 11:36:06
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!====

# MySQL基础
## 关系型数据库介绍

- **关系型数据库**，建立在**关系模型**的基础上的数据库。表明数据库中所**存储**的数据之间的**联系**（一对一、一对多、多对多）
- 关系型数据库中，我们的数据都被**存放在各种表**中（比如用户表），表中的**每一行**存放着**一条数据（比如一个用户的信息）**
  ![关系型数据库表关系](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/5e3c1a71724a38245aa43b02_99bf70d46cc247be878de9d3a88f0c44.png)
- 大部分关系型数据库都使用**SQL**来操作数据库中的数据，并且大部分**关系型数据库**都支持**事务**的**四大特性（ACID）**

**常见的关系型数据库**  
**MySQL**、**PostgreSQL**、**Oracle**、**SQL Server**、**SQLite**（**微信本地的聊天记录**的存储就是用的 SQLite） ......

## MySQL介绍

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/20210327143351823.png)

- MySQL是一种**关系型数据库**，主要用于**持久化存储**我们系统中的一些数据比如**用户信息**

- 由于 MySQL 是**开源**免费并且比较**成熟**的数据库，因此，MySQL 被大量使用在各种系统中。任何人都可以在 **GPL(General Public License 通用性公开许可证)** 的许可下下载并根据**个性化的需要**对其进行**修改**。MySQL 的默认端口号是**3306**。

  

# MySQL基础架构

- MySQL的一个**简要机构图**，客户端的一条**SQL语句**在MySQL内部如何执行
  ![img](https://guide-blog-images.oss-cn-shenzhen.aliyuncs.com/javaguide/13526879-3037b144ed09eb88.png)
- MySQL主要由几部门构成
  1. **连接器**：**身份认证**和**权限相关**（登录MySQL的时候）
  2. **查询缓存**：执行**查询**语句的时候，会先**查询缓存**（MySQL8.0版本后**移除**，因为这个功能不太实用）
  3. **分析器**：**没有命中缓存**的话，SQL语句就会经过分析器，分析器说白了就是要先看你的SQL语句**要干嘛**，再检查你的**SQL语句语法**是否正确
  4. **优化器**：按照**MySQL认为最优的方案**去执行
  5. **执行器**：**执行**语句，然后从**存储引擎返回**数据。执行语句之前会**先判断是否有权限**，如果没有权限，就会报错
  6. **插件式存储引擎**：主要负责**数据**的**存储**和**读取**，采用的是**插件式架构**，支持**InnoDB**、**MyISAM**、**Memory**等多种存储引擎

# MySQL存储引擎

MySQL**核心**在于**存储引擎**

## MySQL支持哪些存储引擎？默认使用哪个？

- MySQL支持**多种存储引擎**，可以通过```show engines```命令来**查看MySQL支持的所有存储引擎**
  ![查看 MySQL 提供的所有存储引擎](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220510105408703.png)

- **默认**存储引擎为InnoDB，并且，所有存储引擎中**只有InnoDB是事务性存储引擎**，也就是说**只有InnoDB支持事务**

- **这里使用MySQL 8.x**
  MySQL 5.5.5之前，MyISAM是MySQL的默认存储引擎；5.5.5之后，InnoDB是MySQL的默认存储疫情，可以通过```select version()```命令查看你的MySQL版本

  ```mysql
  mysql> select version();
  +-----------+
  | version() |
  +-----------+
  | 8.0.27    |
  +-----------+
  1 row in set (0.00 sec) 
  ```

  使用```show variables like %storage_engine%```命令直接查看MySQL**当前默认的存储引擎**    
  ![查看 MySQL 当前默认的存储引擎](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220510105837786.png)

  如果只想**查看数据库中某个表使用的存储引擎**的话，可以使用```show table status from db_name where name = 'table_name'```命令  
  ![查看表的存储引擎](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220510110549140.png)

> 如果你想要深入了解每个存储引擎以及它们之间的区别，推荐你去阅读以下 MySQL 官方文档对应的介绍(面试不会问这么细，了解即可)：
>
> - InnoDB 存储引擎详细介绍：https://dev.mysql.com/doc/refman/8.0/en/innodb-storage-engine.html 。
> - 其他存储引擎详细介绍：https://dev.mysql.com/doc/refman/8.0/en/storage-engines.html 。
>
> ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220510155143458.png)

## MySQL存储引擎架构了解吗？

- MySQL 存储引擎采用的是**插件式架构**，支持**多种存储引擎**，我们甚至可以**为不同的数据库表设置不同的存储引擎**以**适应不同场景的需要**。存储引擎是**基于表**的，**而不是数据库**
- 可以**根据 MySQL 定义的存储引擎实现标准接口**来编写一个**属于自己的存储引擎**。这些**非官方提供的存储引擎**可以称为**第三方存储引擎**，**区别于官方存储引擎**

> 像目前最常用的 InnoDB 其实刚开始就是一个第三方存储引擎，后面由于过于优秀，其被 Oracle 直接收购了。
>
> MySQL 官方文档也有介绍到如何编写一个自定义存储引擎，地址：https://dev.mysql.com/doc/internals/en/custom-engine.html 

## MyISAM和InnoDB的区别是什么？

- ISAM全称：**Indexed Sequential Access Method**(索引 顺序 访问 方法)
- 虽然，MyISAM 的性能还行，各种特性也还不错（比如**全文索引**、**压缩**、**空间函数**等）。但是，**MyISAM 不支持事务**和**行级锁**，而且最大的缺陷就是**崩溃后无法安全恢复**

1. **是否支持行级锁**
   **MyISAM** 只有**表级锁(table-level locking)**，而 **InnoDB** 支持**行级锁(row-level locking)**和**表级锁**,**默认为行级锁**。

   > MyISAM 一锁就是锁住了整张表，这在并发写的情况下是多么滴憨憨啊！这也是为什么 InnoDB 在并发写的时候，性能更牛皮了！

2. **是否支持事务**

   MyISAM不支持事务，InnoDB提供事务支持  

   - InnoDB实现了SQL标准，定义了**四个隔离级别**，具有**提交（commit）**和**回滚（rollback）事务**的能力
   - InnoDB默认使用的**REPEATABLE-READ(可重复读)**隔离级别是可以解决**幻读问题发生的（部分幻读）**，基于**MVCC**和**Next-Key Lock（间隙锁）**  

   详细可以查看**MySQL 事务隔离级别详解**

3. **是否支持外键**

   MyISAM不支持，而InnoDB支持

   > 外键对于维护数据一致性非常有帮助，但是对性能有一定的损耗。因此，通常情况下，我们是不建议在实际生产项目中使用外键的，在业务代码中进行约束即可！
   >
   > 阿里的《Java 开发手册》也是明确规定禁止使用外键的。
   >
   > ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220510090309427.png)
   >
   > 不过，在代码中进行约束的话，对程序员的能力要求更高，具体是否要采用外键还是要根据你的项目实际情况而定

   - 一般我们也是**不建议在数据库层面使用外键**的，**应用层面可以解决**。不过，这样会对数据的一致性造成威胁。具体要不要使用外键还是要根据你的项目来决定

4. **是否支持数据库异常崩溃后的安全恢复**
   MyISAM 不支持，而 InnoDB 支持。  

   - 使用 InnoDB 的数据库在异常崩溃后，数据库重新启动的时候会**保证数据库恢复到崩溃前的状态**。这个**恢复的过程依赖于 `redo log`** 

5. **是否支持MVCC**
   MyISAM 不支持，而 InnoDB 支持。  

   - MyISAM 连行级锁都不支持。**MVCC 可以看作是行级锁的一个升级**，可以有效**减少加锁**操作，**提高性能**。

6. **索引实现不一样**

   - 虽然 **MyISAM 引擎和 InnoDB 引擎都是使用 B+Tree** 作为索引结构，但是两者的**实现方式不太一样**。
   - InnoDB 引擎中，其**数据文件本身就是索引文件**。而 **MyISAM中，索引文件和数据文件是分离**的
   - InnoDB引擎中，表数据文件本身就是按 B+Tree 组织的一个索引结构，**树的叶节点 data 域保存了完整的数据记录**。

详细区别，推荐 ： MySQL 索引详解 

## MyISAM和InnoDB 如何选择

- 大多数时候我们使用的都是 **InnoDB 存储引擎**，在某些**读密集的情况**下，使用 MyISAM 也是合适的。不过，前提是你的项目**不介意 MyISAM 不支持事务**、**崩溃恢复等缺点**（可是~我们一般都会介意啊！）

- 《MySQL 高性能》上面有一句话这样写到:

  > 不要轻易相信“MyISAM 比 InnoDB 快”之类的经验之谈，这个结论往往不是绝对的。在很多我们已知场景中，InnoDB 的速度都可以让 MyISAM 望尘莫及，尤其是用到了聚簇索引，或者需要访问的数据都可以放入内存的应用。

- 一般情况下我们选择 InnoDB 都是没有问题的，但是某些情况下你并不在乎**可扩展能力**和**并发能力**，也不需要**事务支持**，也不在乎**崩溃后的安全恢复问题**的话，选择 MyISAM 也是一个不错的选择。但是一般情况下，我们都是需要考虑到这些问题的。

- 对于咱们日常开发的业务系统来说，你几乎**找不到什么理由再使用 MyISAM** 作为自己的 MySQL 数据库的存储引擎

# MySQL 索引

MySQL 索引相关的问题比较多，对于面试和工作都比较重要，于是，我**单独抽了一篇文章**专门来总结 MySQL 索引相关的知识点和问题： MySQL 索引详解] 

# MySQL查询缓存

执行查询语句的时候，会**先查询缓存**。不过**，MySQL 8.0 版本后移除**，因为这个功能不太实用

- `my.cnf` 加入以下配置，重启 MySQL **开启查询缓存**  

  ```properties
  query_cache_type=1
  query_cache_size=600000
  ```

- 执行以下命令也可以**开启查询缓存**

  ```mysql
  set global  query_cache_type=1;
  set global  query_cache_size=600000;
  ```

**开启查询缓存后在同样的查询条件以及数据情况下，会直接在缓存中返回结果**：  

> 查询条件包括查询本身、当前要查询的数据库、客户端协议版本号等一些可能影响结果的信息

**查询缓存不命中的情况**：  

1. 任何两个查询在**任何字符上的不同**都会导致缓存不命中
2. 如果查询中包含任何**用户自定义函数**、**存储函数**、**用户变量**、**临时表**、**MySQL 库中的系统表**，其查询结果也不会被缓存
3. **缓存建立之后**，MySQL 的**查询缓存系统会跟踪查询中涉及的每张表**，如果**这些表（数据或结构）发生变化**，那么和这张表相关的所有缓存数据都将失效

**缓存虽然能够提升数据库的查询性能，但是缓存同时也带来了额外的开销，每次查询后都要做一次缓存操作，失效后还要销毁。** 因此，开启查询缓存要谨慎，尤其对于写密集的应用来说更是如此。如果开启，要注意合理控制缓存空间大小，一般来说其大小设置为几十 MB 比较合适。此外，**还可以通过 sql_cache 和 sql_no_cache 来控制某个查询语句是否需要缓存  

```sql
select sql_no_cache count(*) from usr;
```

# MySQL事务
## 何谓事务



## 何谓数据库事务
## 并发事务带来了哪些问题
## 不可重复读和幻读有什么区别
## SQL标准定义了哪些事务隔离级别
## MySQL的隔离级别是基于锁实现的吗
## MySQL的默认隔离级别是什么
# MySQL锁
## 表级锁和行级锁了解吗？有什么区别
## 行级锁的使用有什么注意事项
## 共享锁和排他锁呢
## 意向锁有什么作用
## InnoDB 有哪几类行锁
## 当前读和快照读有什么区别
# MySQL 性能优化
## 能用MySQL直接存储文件（比如图片）吗
## MySQL如何存储IP 地址
## 有哪些常见的SQL优化手段吗
