---
title: redis集群搭建
description:  redis集群搭建
tags:
  - rocketmq-hm
categories:
  - 学习
date: 2023-04-13 23:27:30
updated: 2023-04-13 23:27:30
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 基本准备

## 架构

采用Centos7，Redis版本为6.2，架构如下：  

![image-20230414104528632](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414104528632.png)

## hosts修改

```shell
vim /etc/hosts
#添加
192.168.1.101 node1
192.168.1.102 node2
192.168.1.103 node3
```

## 集群准备

### 对每个节点

1. 下载redis并解压到 /usr/local/redis-cluster中  

   ```shell
   cd /usr/local
   mkdir redis-cluster
   tar -zxvf redis* -C /usr/local/redis*
   ```

2. 进入redis根目录  

   ```shell
   make
   make install
   ```

3. 安装完毕

4. hosts修改  

   ```shell
   vim /etc/hosts
   #添加
   192.168.1.101 node1
   192.168.1.102 node2
   192.168.1.103 node3
   ```

## 配置文件修改(6个节点中的每一个)

创建多级目录  

```shell
mkdir -p /usr/local/redis_cluster/redis_63{79,80}/{conf,pid,logs}
```

![image-20230414144223428](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414144223428.png)

编写配置文件

```shell
vim /usr/local/redis_cluster/redis_6379/conf/redis.conf
# 命令行状态下输入 :%d  回车，清空文件
# 再输入 :set paste 处理多出的行带#的问题
# 再输入i

####内容#####
# 快速修改：:%s/6379/6380/g

# 守护进行模式启动
daemonize yes

# 设置数据库数量，默认数据库为0
databases 16

# 绑定地址，需要修改
# bind 192.168.1.101
bind node1

# 绑定端口，需要修改
port 6379

# pid文件存储位置，文件名需要修改
pidfile /usr/local/redis_cluster/redis_6379/pid/redis_6379.pid

# log文件存储位置，文件名需要修改
logfile /usr/local/redis_cluster/redis_6379/logs/redis_6379.log

# RDB快照备份文件名，文件名需要修改
dbfilename redis_6379.rdb

# 本地数据库存储目录，需要修改
dir /usr/local/redis_cluster/redis_6379

# 集群相关配置
# 是否以集群模式启动
cluster-enabled yes

# 集群节点回应最长时间，超过该时间被认为下线
cluster-node-timeout 15000

# 生成的集群节点配置文件名，文件名需要修改
cluster-config-file nodes_6379.conf
```

复制粘贴配置文件

```shell
cp /usr/local/redis_cluster/redis_6379/conf/redis.conf /usr/local/redis_cluster/redis_6380/conf/redis.conf
vim  /usr/local/redis_cluster/redis_6380/conf/redis.conf
#命令行模式下 :%s/6379/6380/g
```

查看文件夹当前情况

![image-20230414163620369](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414163620369.png)

# 运行

查看端口是否运行  

```shell
netstat -lntup | grep 6379
```

运行  

```shell
redis-server /usr/local/redis_cluster/redis_6379/conf/redis.conf &
redis-server /usr/local/redis_cluster/redis_6380/conf/redis.conf &
```

结果  

```shell
netstat -lntup |grep 6379
tcp        0      0 192.168.1.101:6379      0.0.0.0:*               LISTEN      6538/redis-server 1 
tcp        0      0 192.168.1.101:16379     0.0.0.0:*               LISTEN      6538/redis-server 1
#+10000端口出现，说明集群各个节点之间可以互相通信
```

结果  
![image-20230414163942512](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414163942512.png)

```shell
cat *6379/pid/*pid*      
6538  ##就是上面的进程id
```

```shell
cat *6379/logs/*log
6538:C 14 Apr 2023 16:37:04.893 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
6538:C 14 Apr 2023 16:37:04.893 # Redis version=6.2.6, bits=64, commit=00000000, modified=0, pid=6538, just started
6538:C 14 Apr 2023 16:37:04.893 # Configuration loaded
6538:M 14 Apr 2023 16:37:04.895 * Increased maximum number of open files to 10032 (it was originally set to 1024).
6538:M 14 Apr 2023 16:37:04.895 * monotonic clock: POSIX clock_gettime
6538:M 14 Apr 2023 16:37:04.898 * No cluster configuration found, I'm e13c04818944108ee3b0690d836466b4c0eb69fd
6538:M 14 Apr 2023 16:37:04.929 * Running mode=cluster, port=6379.
6538:M 14 Apr 2023 16:37:04.929 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
6538:M 14 Apr 2023 16:37:04.929 # Server initialized
6538:M 14 Apr 2023 16:37:04.929 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
6538:M 14 Apr 2023 16:37:04.930 * Ready to accept connections
```

集群节点配置文件，会发现生成了一组集群信息  
\# 第一段信息是这个Redis服务作为集群节点的一个身份编码 # 别名为集群的node-id

```shell
cat *6379/*nodes*conf
e13c04818944108ee3b0690d836466b4c0eb69fd :0@0 myself,master - 0 0 0 connected
vars currentEpoch 0 lastVoteEpoch 0

## 当后续所有节点都连接上时，内容会变成：
ls
conf  logs  nodes_6379.conf  pid  redis_6379.rdb

root@centos7101:local/redis_cluster/redis_6379                                                                                                                          
cat nodes_6379.conf 
f6cf3978d3397582c87480f8c335297675d4354a 192.168.1.103:6380@16380 master - 1681470597368 1681470597337 6 connected 0-5461
f1151c2350820b35e117d3c32b59b64917688745 192.168.1.103:6379@16379 master - 1681470597369 1681470597337 5 connected 10923-16383
83bfb30e39e3040397d995a7b1f560e8fb53c6a9 192.168.1.102:6380@16380 slave f1151c2350820b35e117d3c32b59b64917688745 1681470597369 1681470597337 5 connected
4e9452afe7a8f53dc546b0436109bef570e03888 192.168.1.101:6380@16380 slave 95b2dcd681674398d22817728af08c31d4bd4872 1681470597370 1681470597337 4 connected
95b2dcd681674398d22817728af08c31d4bd4872 192.168.1.102:6379@16379 master - 1681470597370 1681470597337 4 connected 5462-10922
fd6acb4af8afa5ddd31cf559ee2c80ffcbea456f 192.168.1.101:6379@16379 myself,slave f6cf3978d3397582c87480f8c335297675d4354a 0 1681470597337 6 connected
vars currentEpoch 6 lastVoteEpoch 0

```

# 加入集群

在node1:6379 查看当前cluster

```shell
redis-cli -h node1 -p 6379
node1:6379> cluster nodes
e13c04818944108ee3b0690d836466b4c0eb69fd :6379@16379 myself,master - 0 0 0 connected
node1:6379> cluster meet 192.168.1.102 6379
OK
node1:6379> cluster nodes
e13c04818944108ee3b0690d836466b4c0eb69fd 192.168.1.101:6379@16379 myself,master - 0 0 1 connected
fbe66448ee1baefa6e9fbd55e778c1d09054b59a 192.168.1.102:6379@16379 master - 0 1681464479300 0 connected
node1:6379> 
```

此时在node2:6379查看当前cluster

```shell
redis-cli -h node2 -p 6379
node2:6379> cluster nodes
fbe66448ee1baefa6e9fbd55e778c1d09054b59a 192.168.1.102:6379@16379 myself,master - 0 0 0 connected
e13c04818944108ee3b0690d836466b4c0eb69fd 192.168.1.101:6379@16379 master - 0 1681464547007 1 connected
```

切回node1:6379，将剩下的节点meet上  

```shell
node1:6379> cluster meet 192.168.1.103 6379
OK
node1:6379> cluster meet 192.168.1.101 6380
OK
node1:6379> cluster meet 192.168.1.102 6380
OK
node1:6379> cluster meet 192.168.1.103 6380
OK
node1:6379> clear
node1:6379> cluster nodes
84384230f256fae73ab5bbaf34b0479b67602d6e 192.168.1.102:6380@16380 master - 0 1681464635860 4 connected
e13c04818944108ee3b0690d836466b4c0eb69fd 192.168.1.101:6379@16379 myself,master - 0 1681464633000 1 connected
fbe66448ee1baefa6e9fbd55e778c1d09054b59a 192.168.1.102:6379@16379 master - 0 1681464636894 0 connected
43cdb0cd626a0341cf0c9fa31832735c5341a89b 192.168.1.103:6380@16380 master - 0 1681464635000 5 connected
a20b6da956145cfa06ed55159456de8259d9f246 192.168.1.103:6379@16379 master - 0 1681464637923 2 connected
4aeeaa0d87b91712576c6e995b355fe4a87b24e0 192.168.1.101:6380@16380 master - 0 1681464637000 3 connected
```

# 主从配置

上面发现的node-id  

| hostname | 节点               | node-id                                  |
| -------- | ------------------ | ---------------------------------------- |
| node1    | 192.168.1.101:6379 | e13c04818944108ee3b0690d836466b4c0eb69fd |
| node2    | 192.168.1.102:6379 | fbe66448ee1baefa6e9fbd55e778c1d09054b59a |
| node3    | 192.168.1.103:6379 | a20b6da956145cfa06ed55159456de8259d9f246 |

主从配置  
![image-20230414104528632](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414104528632.png)

```shell
#node1:6380->node2:6379
node1:6380> cluster replicate 95b2dcd681674398d22817728af08c31d4bd4872
OK
#node2:6380->node3:6379
node2:6380> cluster replicate f1151c2350820b35e117d3c32b59b64917688745
OK
#node3:6380->node1:6379
node3:6380> cluster replicate fd6acb4af8afa5ddd31cf559ee2c80ffcbea456f
OK
```

再一次查看节点信息，出现了master，slave  

```shell
node3:6380> cluster nodes
4aeeaa0d87b91712576c6e995b355fe4a87b24e0 192.168.1.101:6380@16380 slave fbe66448ee1baefa6e9fbd55e778c1d09054b59a 0 1681465221000 0 connected
43cdb0cd626a0341cf0c9fa31832735c5341a89b 192.168.1.103:6380@16380 myself,slave e13c04818944108ee3b0690d836466b4c0eb69fd 0 1681465222000 1 connected
fbe66448ee1baefa6e9fbd55e778c1d09054b59a 192.168.1.102:6379@16379 master - 0 1681465223000 0 connected
e13c04818944108ee3b0690d836466b4c0eb69fd 192.168.1.101:6379@16379 master - 0 1681465222000 1 connected
a20b6da956145cfa06ed55159456de8259d9f246 192.168.1.103:6379@16379 master - 0 1681465221814 2 connected
84384230f256fae73ab5bbaf34b0479b67602d6e 192.168.1.102:6380@16380 slave a20b6da956145cfa06ed55159456de8259d9f246 0 1681465223880 2 connected
```

# 分配槽位

只对主库分配，从库不进行分配  
```expr 16384 / 3 ``` 5461

下面平均分配到3个master中，其中: 

| 节点       | 槽位数量                  |
| ---------- | ------------------------- |
| node1:6379 | 0 - 5461 【多分配了一个】 |
| node2:6379 | 5461 - 10922              |
| node3:6379 | 10922 - 16383             |

 ```shell
redis-cli -h node1 -p 6379 cluster addslots {0..5461}
redis-cli -h node2 -p 6379 cluster addslots {5462..10922}
redis-cli -h node3 -p 6379 cluster addslots {10923..16383}
redis-cli -h node3 -p 6379
node1:6379> cluster nodes
84384230f256fae73ab5bbaf34b0479b67602d6e 192.168.1.102:6380@16380 slave a20b6da956145cfa06ed55159456de8259d9f246 0 1681467951000 2 connected
e13c04818944108ee3b0690d836466b4c0eb69fd 192.168.1.101:6379@16379 myself,master - 0 1681467948000 1 connected 0-5461
fbe66448ee1baefa6e9fbd55e778c1d09054b59a 192.168.1.102:6379@16379 master - 0 1681467949000 0 connected 5462-10922
43cdb0cd626a0341cf0c9fa31832735c5341a89b 192.168.1.103:6380@16380 slave e13c04818944108ee3b0690d836466b4c0eb69fd 0 1681467949690 1 connected
a20b6da956145cfa06ed55159456de8259d9f246 192.168.1.103:6379@16379 master - 0 1681467947626 2 connected 10923-16383
4aeeaa0d87b91712576c6e995b355fe4a87b24e0 192.168.1.101:6380@16380 slave fbe66448ee1baefa6e9fbd55e778c1d09054b59a 0 1681467951745 0 connected
 ```

检查集群状态是否OK  

```shell
node1:6379> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:5
cluster_my_epoch:1
cluster_stats_messages_ping_sent:3461
cluster_stats_messages_pong_sent:3530
cluster_stats_messages_meet_sent:5
cluster_stats_messages_sent:6996
cluster_stats_messages_ping_received:3530
cluster_stats_messages_pong_received:3466
cluster_stats_messages_received:6996
```

# MOVED重定向

```shell
redis-cli -h node1 -p 6379
node1:6379> set k1 "v1"
(error) MOVED 12706 192.168.1.103:6379
node1:6379> get k1
(error) MOVED 12706 192.168.1.103:6379
```

//上面没有设置成功，(连接时)使用下面的命令，Redis集群会自动进行MOVED重定向  

```shell
redis-cli -c -h node1 -p 6379
node1:6379> get k1
-> Redirected to slot [12706] located at 192.168.1.103:6379
(nil)
192.168.1.103:6379> set k1 "v1"
OK
192.168.1.103:6379> get k1
"v1"
#如上，会自动给你切换到slot对应的机器上
```

//在master3的slave3上查找数据

```shell
redis-cli -h node2 -p 6380 -c
node2:6380> keys *
1) "k1"
node2:6380> get k1
-> Redirected to slot [12706] located at 192.168.1.103:6379
"v1"
## 1 只有master分配了槽位，所以会重定向到master3去取数据
## 2 同一个槽位不能同时分配给2个节点
## 3 在redis的官方文档中，对redis-cluster架构上，有这样的说明：在cluster架构下，默认的，一般redis-master用于接收读写，而redis-slave则用于备份，当有请求是在向slave发起时，会直接重定向到对应key所在的master来处理。但如果不介意读取的是redis-cluster中有可能过期的数据并且对写请求不感兴趣时，则亦可通过readonly命令，将slave设置成可读，然后通过slave获取相关的key，达到读写分离。 
# readOnly设置
redis-cli -h node2 -p 6380                                       
node2:6380> get k1
(error) MOVED 12706 192.168.1.103:6379
node2:6380> keys *
1) "k1"
node2:6380> readonly
OK
node2:6380> keys *
1) "k1"
node2:6380> get k1
"v1"
## 重置Readonly
node2:6380> readwrite
OK
node2:6380> get k1
(error) MOVED 12706 192.168.1.103:6379
```



# 故障转移

关闭前

```shell
node2:6379> cluster nodes
f6cf3978d3397582c87480f8c335297675d4354a 192.168.1.103:6380@16380 slave fd6acb4af8afa5ddd31cf559ee2c80ffcbea456f 0 1681470413429 0 connected
fd6acb4af8afa5ddd31cf559ee2c80ffcbea456f 192.168.1.101:6379@16379 master - 0 1681470414459 0 connected 0-5461
95b2dcd681674398d22817728af08c31d4bd4872 192.168.1.102:6379@16379 myself,master - 0 1681470413000 4 connected 5462-10922
f1151c2350820b35e117d3c32b59b64917688745 192.168.1.103:6379@16379 master - 0 1681470412000 5 connected 10923-16383
83bfb30e39e3040397d995a7b1f560e8fb53c6a9 192.168.1.102:6380@16380 slave f1151c2350820b35e117d3c32b59b64917688745 0 1681470412397 5 connected
4e9452afe7a8f53dc546b0436109bef570e03888 192.168.1.101:6380@16380 slave 95b2dcd681674398d22817728af08c31d4bd4872 0 1681470411371 4 connected
```

关闭node1 master

```shell
redis-cli -h node1 -p 6379 shutdown
```

如下，node3的slave变成了master

```shell
redis-cli -h node1 -p 6380 
node1:6380> cluster nodes
f6cf3978d3397582c87480f8c335297675d4354a 192.168.1.103:6380@16380 master - 0 1681470479000 6 connected 0-5461 ###这里升级成了master，槽位也转移了
83bfb30e39e3040397d995a7b1f560e8fb53c6a9 192.168.1.102:6380@16380 slave f1151c2350820b35e117d3c32b59b64917688745 0 1681470479664 5 connected
4e9452afe7a8f53dc546b0436109bef570e03888 192.168.1.101:6380@16380 myself,slave 95b2dcd681674398d22817728af08c31d4bd4872 0 1681470479000 4 connected
fd6acb4af8afa5ddd31cf559ee2c80ffcbea456f 192.168.1.101:6379@16379 master,fail - 1681470463058 1681470459947 0 disconnected
95b2dcd681674398d22817728af08c31d4bd4872 192.168.1.102:6379@16379 master - 0 1681470478616 4 connected 5462-10922
f1151c2350820b35e117d3c32b59b64917688745 192.168.1.103:6379@16379 master - 0 1681470480698 5 connected 10923-16383
```

此时将6379再次上线

```shell
redis-server /usr/local/redis_cluster/redis_6379/conf/redis.conf 
## 此时node1的6379变成了node3的6380的从库
node1:6379> cluster nodes
f6cf3978d3397582c87480f8c335297675d4354a 192.168.1.103:6380@16380 master - 0 1681470625000 6 connected 0-5461
f1151c2350820b35e117d3c32b59b64917688745 192.168.1.103:6379@16379 master - 0 1681470628003 5 connected 10923-16383
83bfb30e39e3040397d995a7b1f560e8fb53c6a9 192.168.1.102:6380@16380 slave f1151c2350820b35e117d3c32b59b64917688745 0 1681470626979 5 connected
4e9452afe7a8f53dc546b0436109bef570e03888 192.168.1.101:6380@16380 slave 95b2dcd681674398d22817728af08c31d4bd4872 0 1681470627000 4 connected
95b2dcd681674398d22817728af08c31d4bd4872 192.168.1.102:6379@16379 master - 0 1681470627000 4 connected 5462-10922
fd6acb4af8afa5ddd31cf559ee2c80ffcbea456f 192.168.1.101:6379@16379 myself,slave f6cf3978d3397582c87480f8c335297675d4354a 0 1681470625000 6 connected
```

# cluster命令

 以下是集群中常用的可执行命令，命令执行格式为：

```undefined
cluster 下表命令
```

 命令如下，未全，如果想了解更多请执行cluster help操作：

| 命令                            | 描述                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| INFO                            | 返回当前集群信息                                             |
| MEET <ip> <port> [<bus-port>]   | 添加一个节点至当前集群                                       |
| MYID                            | 返回当前节点集群ID                                           |
| NODES                           | 返回当前节点的集群信息                                       |
| REPLICATE <node-id>             | 将当前节点作为某一集群节点的从库                             |
| FAILOVER [FORCE\|TAKEOVER]      | 将当前从库升级为主库                                         |
| RESET [HARD\|SOFT]              | 重置当前节点信息                                             |
| ADDSLOTS <slot> [<slot> ...]    | 为当前集群节点增加一个或多个插槽位，推荐在bash shell中执行，可通过{int..int}指定多个插槽位 |
| DELSLOTS <slot> [<slot> ...]    | 为当前集群节点删除一个或多个插槽位，推荐在bash shell中执行，可通过{int..int}指定多个插槽位 |
| FLUSHSLOTS                      | 删除当前节点中所有的插槽信息                                 |
| FORGET <node-id>                | 从集群中删除某一节点                                         |
| COUNT-FAILURE-REPORTS <node-id> | 返回当前集群节点的故障报告数量                               |
| COUNTKEYSINSLOT <slot>          | 返回某一插槽中的键的数量                                     |
| GETKEYSINSLOT <slot> <count>    | 返回当前节点存储在插槽中的key名称。                          |
| KEYSLOT <key>                   | 返回该key的哈希槽位                                          |
| SAVECONFIG                      | 保存当前集群配置，进行落盘操作                               |
| SLOTS                           | 返回该插槽的信息                                             |

# RedisCluster架构原理分析

## 基础架构（数据分片）

![image-20230414215403801](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414215403801.png)

## 集群分片原理

![image-20230414215902852](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414215902852.png)

## 启动集群原理

![image-20230414220624119](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414220624119.png)

## 集群通信原理

![image-20230414221225818](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230414221225818.png)