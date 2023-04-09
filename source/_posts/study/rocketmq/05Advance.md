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

> 学习来源 https://www.bilibili.com/video/BV1L4411y7mn（添加小部分笔记）感谢作者!消息存储

## 流程

![image-20230409093042579](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230409093042579.png)

## 存储介质

### 关系型数据库DB

适合数据量不够大，比如ActiveMQ可选用JDBC方式作为消息持久化

### 文件系统

1. 关系型数据库最终也是要存到文件系统中的，不如直接存到文件系统，绕过关系型数据库
2. 常见的RocketMQ/RabbitMQ/Kafka都是采用消息刷盘到计算机的文件系统来做持久化(**同步刷盘**/**异步刷盘**)

# 高可用性机制

# 负载均衡

# 消息重试

# 死信队列

# 消费幂等