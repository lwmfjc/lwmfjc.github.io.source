---
title: redis问题图解
description: redis问题图解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-diagram
date: 2023-02-27 22:11:02
updated: 2023-02-27 22:11:02
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

1. 主从复制原理  

   ![主从复制原理](images/mypost/image-20230227221119208.png)

2. 哨兵模式(简单)  
    ![image-20230227231636309](images/mypost/image-20230227231636309.png)
    
3. 哨兵模式详解  
   
   > 先配置**主从模式**，再配置**哨兵模式**
   
    所有的哨兵 sentinel.conf 都是配置为监听master--> 192.168.14.101，如果主机宕机，sentinel.conf 中的配置也会自动更改为选举后的![image-20230228151217464](images/mypost/image-20230228151217464.png)
   
   1. Java客户端连接原理  
   
       > 客户端是和Sentinel来进行交互的,通过Sentinel来获取真正的Redis节点信息,然后来操作.实际工作时,Sentinel 内部维护了一个主题队列,用来保存Redis的节点信息,并实时更新,客户端订阅了这个主题,然后实时的去获取这个队列的Redis节点信息.  
       >
       > ```java
       > /**
       > 代码相对比较简单
       > **/
       > //1.设置sentinel 各个节点集合
       > Set<String> sentinelSet = new HashSet<>();
       > sentinelSet.add("192.168.14.101:26379");
       > sentinelSet.add("192.168.14.102:26380");
       > sentinelSet.add("192.168.14.103:26381");
       >  
       > //2.设置jedispool 连接池配置文件
       > JedisPoolConfig config = new JedisPoolConfig();
       > config.setMaxTotal(10);
       > config.setMaxWaitMillis(1000);
       >  
       > //3.设置mastername,sentinelNode集合,配置文件,Redis登录密码
       > JedisSentinelPool jedisSentinelPool = new JedisSentinelPool("mymaster",sentinelSet,config,"123");
       > Jedis jedis = null;
       > try {
       >     jedis = jedisSentinelPool.getResource();
       >     //获取Redis中key=hello的值
       >     String value = jedis.get("hello");
       >     System.out.println(value);
       > } catch (Exception e) {
       >     e.printStackTrace();
       > } finally {
       >     if(jedis != null){
       >         jedis.close();
       >     }
       > }
       > ```
   
       ![image-20230228152739283](images/mypost/image-20230228152739283.png)
   
   2. 哨兵工作原理  
       主观宕机：sentinel自认为redis不可用  
       客观宕机：sentinel集群认为redis不可用  
       ![image-20230228155513262](images/mypost/image-20230228155513262.png)
   
   3. 故障转移  
       ![image-20230228173124506](images/mypost/image-20230228173124506.png)
