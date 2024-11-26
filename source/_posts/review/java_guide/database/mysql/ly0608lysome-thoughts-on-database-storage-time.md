---
title: MySQL数据库时间类型数据存储建议
description: MySQL数据库时间类型数据存储建议
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-database
date: 2023-01-19 17:10:06
updated: 2023-01-19 17:10:06
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 不要用字符串存储日期

- 优点：简单直白
- 缺点
  1. 字符串**占有的空间更大**
  2. 字符串存储的日期**效率比较低**（逐个字符进行比较），**无法用日期相关的API**进行计算和比较

# Datetime和Timestamp之间抉择

Datetime 和 Timestamp 是 MySQL 提供的两种**比较相似**的保存时间的数据类型。他们两者究竟该如何选择呢？

**通常我们都会首选 Timestamp**

## Datetime类型没有时区信息

1. **DateTime 类型是没有时区信息的（时区无关）** ，DateTime 类型保存的时间都是**当前会话所设置的时区**对应的时间。这样就会有什么问题呢？当你的时区更换之后，比如你的服务器更换地址或者更换客户端连接时区设置的话，就会导致你从数据库中读出的时间错误。不要小看这个问题，很多系统就是因为这个问题闹出了很多笑话。
2. **Timestamp 和时区有关**。Timestamp 类型字段的值会随着服务器时区的变化而变化，自动换算成相应的时间，说简单点就是**在不同时区**，**查询到同一个条记录此字段的值会不一样**

案例  

```mysql
-- 建表
CREATE TABLE `time_zone_test` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date_time` datetime DEFAULT NULL,
  `time_stamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 

-- 插入数据
INSERT INTO time_zone_test(date_time,time_stamp) VALUES(NOW(),NOW());
-- 查看数据
select date_time,time_stamp from time_zone_test;
-- 结果
/*
 +---------------------+---------------------+
| date_time           | time_stamp          |
+---------------------+---------------------+
| 2020-01-11 09:53:32 | 2020-01-11 09:53:32 |
+---------------------+---------------------+
------ 
*/
```

修改时区并查看数据  

```mysql
set time_zone='+8:00';
/*
+---------------------+---------------------+
| date_time           | time_stamp          |
+---------------------+---------------------+
| 2020-01-11 09:53:32 | 2020-01-11 17:53:32 |
+---------------------+---------------------+
------ 
*/
```

关于MySQL时区设置的一个**常用sql命令**

```mysql
# 查看当前会话时区
SELECT @@session.time_zone;
# 设置当前会话时区
SET time_zone = 'Europe/Helsinki';
SET time_zone = "+00:00";
# 数据库全局时区设置
SELECT @@global.time_zone;
# 设置全局时区
SET GLOBAL time_zone = '+8:00';
SET GLOBAL time_zone = 'Europe/Helsinki'; 
```

## DateTime类型耗费空间更大

Timestamp 只需要使用 **4** 个字节的存储空间，但是 DateTime 需要耗费 **8** 个字节的存储空间。但是，这样同样造成了一个问题，**Timestamp 表示的时间范围更小**。

- DateTime ：1000-01-01 00:00:00 ~ 9999-12-31 23:59:59
- Timestamp： 1970-01-01 00:00:01 ~ 2037-12-31 23:59:59

> Timestamp 在不同版本的 MySQL 中有细微差别。

# 再看MySQL日期类型存储空间

- MySQL 5.6 版本中日期类型所占的存储空间
  ![img](attachments/img/lyx-20241126133520116.jpeg)

1. 可以看出 5.6.4 之后的 MySQL 多出了一个需要 **0 ～ 3 字节**的小数位。DateTime 和 Timestamp 会有几种不同的存储空间占用。
2. 为了方便，本文我们还是默认 **Timestamp 只需要使用 4 个字节**的存储空间，但是 **DateTime** 需要**耗费 8 个字节**的存储空间

# 数值型时间戳是更好的选择吗

使用**int**或者**bigint**类型数值，即时间戳来表示时间

1. 优点：使用它进行**日期排序**以及**对比**等操作效率更高，跨系统也方便
2. 缺点：可读性差

时间戳的定义  

> 时间戳的定义是从一个基准时间开始算起，这个基准时间是「1970-1-1 00:00:00 +0:00」，从这个时间开始，用整数表示，以秒计时，随着时间的流逝这个时间整数不断增加。这样一来，我只需要一个数值，就可以完美地表示时间了，而且这个数值是一个绝对数值，即无论的身处地球的任何角落，这个表示时间的时间戳，都是一样的，生成的数值都是一样的，并且没有时区的概念，所以在系统的中时间的传输中，都不需要进行额外的转换了，只有在显示给用户的时候，才转换为字符串格式的本地时间

实际操作  

```mysql
mysql> select UNIX_TIMESTAMP('2020-01-11 09:53:32');
+---------------------------------------+
| UNIX_TIMESTAMP('2020-01-11 09:53:32') |
+---------------------------------------+
|                            1578707612 |
+---------------------------------------+
1 row in set (0.00 sec)

mysql> select FROM_UNIXTIME(1578707612);
+---------------------------+
| FROM_UNIXTIME(1578707612) |
+---------------------------+
| 2020-01-11 09:53:32       |
+---------------------------+
1 row in set (0.01 sec) 
```

# 总结

- 推荐使用《高性能MySQL》  
  ![lyx-20241126133520672](attachments/img/lyx-20241126133520672.png)
- 对比  
  ![lyx-20241126133521098](attachments/img/lyx-20241126133521098.png)