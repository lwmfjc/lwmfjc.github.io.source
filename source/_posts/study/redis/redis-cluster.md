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

> 转载自https://www.cnblogs.com/Yunya-Cnblogs/p/14608937.html（添加小部分笔记）感谢作者!
>
> 部分参考自 https://www.cnblogs.com/ysocean/p/12328088.html

# 基本准备
![1691117992.png](images/mypost/1691117992.png)

## 架构

采用Centos7，Redis版本为6.2，架构如下：  

![image-20230414104528632](images/mypost/image-20230414104528632.png)

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

![image-20230414144223428](images/mypost/image-20230414144223428.png)

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

![image-20230414163620369](images/mypost/image-20230414163620369.png)

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
![image-20230414163942512](images/mypost/image-20230414163942512.png)

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

# 集群搭建

## 手动搭建集群

### 加入集群

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

### 主从配置

上面发现的node-id  

| hostname | 节点               | node-id                                  |
| -------- | ------------------ | ---------------------------------------- |
| node1    | 192.168.1.101:6379 | e13c04818944108ee3b0690d836466b4c0eb69fd |
| node2    | 192.168.1.102:6379 | fbe66448ee1baefa6e9fbd55e778c1d09054b59a |
| node3    | 192.168.1.103:6379 | a20b6da956145cfa06ed55159456de8259d9f246 |

主从配置  
![image-20230414104528632](images/mypost/image-20230414104528632.png)

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

### 分配槽位

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

## 自动集群搭建

**假设所有的节点都已经重置过，没有主从状态，也未加入任何集群。**

> Redis5之前使用redis-trib.rb脚本搭建
>
> redis-trib.rb脚本使用ruby语言编写，所以想要运行次脚本，我们必须安装Ruby环境。安装命令如下：
>
> ```
> yum -y install centos-release-scl-rh
> yum -y install rh-ruby23  
> scl enable rh-ruby23 bash
> gem install redis
> ```
>
> 安装完成后，我们可以使用 ruby -v 查看版本信息。
>
> ![img](images/mypost/1120165-20200221181647318-2083171766.png)
>
> Ruby环境安装完成后。运行如下命令：
>
> ```redis-trib.rb create --replicas 1 192.168.14.101:6379 192.168.14.102:6380 192.168.14.103:6381 192.168.14.101:6382 192.168.14.102:6383 192.168.14.103:6384```

**前面我们就说过，redis5.0之后已经将redis-trib.rb 脚本的功能全部集成到redis-cli中了，所以我们直接使用如下命令即可：**

```redis-cli -h node3 -p 6379 cluster reset hard```

此时所有节点都是master且已经在运行中  
此时运行  

```shell
# redis-cli -a ${password} --cluster create 192.168.1.101:6379 192.168.1.102:6379 192.168.1.103:6379 192.168.1.103:6380 192.168.1.101:6380 192.168.1.102:6380  --cluster-replicas 1
# 如果有密码，一般情况下集群下的所有节点使用同样的密码
redis-cli --cluster create 192.168.1.101:6379 192.168.1.102:6379 192.168.1.103:6379 192.168.1.103:6380 192.168.1.101:6380 192.168.1.102:6380  --cluster-replicas 1
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.1.102:6380 to 192.168.1.101:6379
Adding replica 192.168.1.103:6380 to 192.168.1.102:6379
Adding replica 192.168.1.101:6380 to 192.168.1.103:6379
M: 24ea7569f0a433eb9706d991f21ae49ec21e48cf 192.168.1.101:6379
   slots:[0-5460] (5461 slots) master
M: 518fc32f556b10d4b8f83bda420d01aaeeb25f51 192.168.1.102:6379
   slots:[5461-10922] (5462 slots) master
M: c021bdbaf1c3a476616781c25dbc2b3042ed6f10 192.168.1.103:6379
   slots:[10923-16383] (5461 slots) master
S: 25e44d3ff2d94400b3c53d66993fc99332adffe4 192.168.1.103:6380
   replicates 518fc32f556b10d4b8f83bda420d01aaeeb25f51
S: a6159c5dda95017ba5433f597ea4d18780868dfc 192.168.1.101:6380
   replicates c021bdbaf1c3a476616781c25dbc2b3042ed6f10
S: a0e986c4cfb914f34efc8f6ea07cb9b72b615593 192.168.1.102:6380
   replicates 24ea7569f0a433eb9706d991f21ae49ec21e48cf
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
.
>>> Performing Cluster Check (using node 192.168.1.101:6379)
M: 24ea7569f0a433eb9706d991f21ae49ec21e48cf 192.168.1.101:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: a0e986c4cfb914f34efc8f6ea07cb9b72b615593 192.168.1.102:6380
   slots: (0 slots) slave
   replicates 24ea7569f0a433eb9706d991f21ae49ec21e48cf
S: 25e44d3ff2d94400b3c53d66993fc99332adffe4 192.168.1.103:6380
   slots: (0 slots) slave
   replicates 518fc32f556b10d4b8f83bda420d01aaeeb25f51
M: c021bdbaf1c3a476616781c25dbc2b3042ed6f10 192.168.1.103:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: a6159c5dda95017ba5433f597ea4d18780868dfc 192.168.1.101:6380
   slots: (0 slots) slave
   replicates c021bdbaf1c3a476616781c25dbc2b3042ed6f10
M: 518fc32f556b10d4b8f83bda420d01aaeeb25f51 192.168.1.102:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.  #所有槽位都分配成功
```

随便使用一个节点查询：  

```shell
redis-cli -h node1 -p 6380 cluster nodes                                                                                                                          
25e44d3ff2d94400b3c53d66993fc99332adffe4 192.168.1.103:6380@16380 slave 518fc32f556b10d4b8f83bda420d01aaeeb25f51 0 1681482908718 2 connected
518fc32f556b10d4b8f83bda420d01aaeeb25f51 192.168.1.102:6379@16379 master - 0 1681482906668 2 connected 5461-10922
24ea7569f0a433eb9706d991f21ae49ec21e48cf 192.168.1.101:6379@16379 master - 0 1681482908000 1 connected 0-5460
c021bdbaf1c3a476616781c25dbc2b3042ed6f10 192.168.1.103:6379@16379 master - 0 1681482907000 3 connected 10923-16383
a0e986c4cfb914f34efc8f6ea07cb9b72b615593 192.168.1.102:6380@16380 slave 24ea7569f0a433eb9706d991f21ae49ec21e48cf 0 1681482909743 1 connected
a6159c5dda95017ba5433f597ea4d18780868dfc 192.168.1.101:6380@16380 myself,slave c021bdbaf1c3a476616781c25dbc2b3042ed6f10 0 1681482908000 3 connected
```

如上，槽位都已经平均分配完，且主从关系也配置好了  
![image-20230414225420457](images/mypost/image-20230414225420457.png)

弊端：通过该方式创建的带有从节点的机器**不能够自己手动指定主节点**，所以如果需要指定的话，需要自己手动指定  

> 1.  a: 先使用```redis-cli --cluster create 192.168.163.132:6379 192.168.163.132:6380 192.168.163.132:6381```  
>    b:或```redis-cli --cluster add-node 192.168.163.132:6382 192.168.163.132:6379    
>    **说明：b:为一个指定集群添加节点，需要先连到该集群的任意一个节点IP（192.168.163.132:6379），再把新节点加入。该2个参数的顺序有要求：新加入的节点放前面**
> 2. 通过```redis-cli --cluster add-node 192.168.163.132:6382 192.168.163.132:6379 --cluster-slave --cluster-master-id 117457eab5071954faab5e81c3170600d5192270```来处理。    
>    **说明：把6382节点加入到6379节点的集群中，并且当做node_id为 117457eab5071954faab5e81c3170600d5192270 的从节点。如果不指定 --cluster-master-id 会随机分配到任意一个主节点。**
> 3. 总结：也就是先创建主节点，再创建从节点就是了



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

# 集群扩容

## 当前集群状态

```shell
▶ redis-cli -h node1 -p 6379 cluster nodes
f635a8cdaa48e04f2531d28c103bea9dc2d8f48d 192.168.1.102:6380@16380 slave f9d707317348314a7306fdaf91da2d153590140e 0 1681527313557 5 connected
f49300c718a7e0baf6d3e8ba4bf7e9915e8051cc 192.168.1.101:6380@16380 slave 9e9613cec2fdd48000509e9c3723d157263edd87 0 1681527313000 4 connected
9ea59136c61207347657503fd7a78349f57e919e 192.168.1.103:6380@16380 slave fff7298fa77799434bc8ef6c74c974c21ebc47b4 0 1681527314000 0 connected
fff7298fa77799434bc8ef6c74c974c21ebc47b4 192.168.1.101:6379@16379 myself,master - 0 1681527313000 0 connected 0-5461
9e9613cec2fdd48000509e9c3723d157263edd87 192.168.1.102:6379@16379 master - 0 1681527314579 4 connected 5462-10922
f9d707317348314a7306fdaf91da2d153590140e 192.168.1.103:6379@16379 master - 0 1681527312000 5 connected 10923-16383

```

## 新增节点配置并启动

### 准备

假设在node3新增两个端口{6390,6391}，作为新节点   
**且 node3:6391 replicate node3:6390**

步骤：通过```mkdir -p /usr/local/redis_cluster/redis_63{91,90}/{conf,pid,logs}```创建文件夹，然后再conf目录下配置集群配置文件  

```shell
# 守护进行模式启动
daemonize yes

# 设置数据库数量，默认数据库为0
databases 16

# 绑定地址，需要修改
bind node3

# 绑定端口，需要修改
port 6390

# pid文件存储位置，文件名需要修改
pidfile /usr/local/redis_cluster/redis_6390/pid/redis_6390.pid

# log文件存储位置，文件名需要修改
logfile /usr/local/redis_cluster/redis_6390/logs/redis_6390.log

# RDB快照备份文件名，文件名需要修改
dbfilename redis_6390.rdb

# 本地数据库存储目录，需要修改
dir /usr/local/redis_cluster/redis_6390

# 集群相关配置
# 是否以集群模式启动
cluster-enabled yes

# 集群节点回应最长时间，超过该时间被认为下线
cluster-node-timeout 15000

# 生成的集群节点配置文件名，文件名需要修改
cluster-config-file nodes_6390.conf

```

目录结构  

```shell
root@centos7103:/usr/local/redis_cluster                                                                                                                                                 
▶ ls
redis6  redis_6379  redis_6380  redis_6390  redis_6391

▶ tree *90
redis_6390
├── conf
│   └── redis.conf
├── logs
└── pid

3 directories, 1 file
```

启动节点  

```shell
# 两个孤儿节点
root@centos7103:/usr/local/redis_cluster                                                                                                                                                ⍉
▶ redis-server /usr/local/redis_cluster/redis_6390/conf/redis.conf

root@centos7103:/usr/local/redis_cluster                                                                                                                                                 
▶ redis-server /usr/local/redis_cluster/redis_6391/conf/redis.conf

root@centos7103:/usr/local/redis_cluster                                                                                                                                                 
▶ netstat -lntup |grep redis
tcp        0      0 192.168.1.103:6379      0.0.0.0:*               LISTEN      3484/redis-server n 
tcp        0      0 192.168.1.103:6380      0.0.0.0:*               LISTEN      3507/redis-server n 
tcp        0      0 192.168.1.103:6390      0.0.0.0:*               LISTEN      5590/redis-server n 
tcp        0      0 192.168.1.103:6391      0.0.0.0:*               LISTEN      5616/redis-server n 
tcp        0      0 192.168.1.103:16379     0.0.0.0:*               LISTEN      3484/redis-server n 
tcp        0      0 192.168.1.103:16380     0.0.0.0:*               LISTEN      3507/redis-server n 
tcp        0      0 192.168.1.103:16390     0.0.0.0:*               LISTEN      5590/redis-server n 
tcp        0      0 192.168.1.103:16391     0.0.0.0:*               LISTEN      5616/redis-server n 
```

### 添加主节点

将新节点加入到node1:6379 [0,5460]所在的集群中  
加入前  

```shell
redis-cli -h node3 -p 6390
node3:6390> cluster nodes
b014cfbeff6f9668ec9592cbc8aa874bda2d8d6b :6390@16390 myself,master - 0 0 0 connected
```

加入  

```shell
# 在node1客户端操作，将103:6390添加到101:6379所在的集群中
redis-cli -h node1 -p 6379 --cluster add-node 192.168.1.103:6390 192.168.1.101:6379
>>> Adding node 192.168.1.103:6390 to cluster 192.168.1.101:6379
>>> Performing Cluster Check (using node 192.168.1.101:6379)
M: fff7298fa77799434bc8ef6c74c974c21ebc47b4 192.168.1.101:6379
   slots:[0-5461] (5462 slots) master
   1 additional replica(s)
S: f635a8cdaa48e04f2531d28c103bea9dc2d8f48d 192.168.1.102:6380
   slots: (0 slots) slave
   replicates f9d707317348314a7306fdaf91da2d153590140e
S: f49300c718a7e0baf6d3e8ba4bf7e9915e8051cc 192.168.1.101:6380
   slots: (0 slots) slave
   replicates 9e9613cec2fdd48000509e9c3723d157263edd87
S: 9ea59136c61207347657503fd7a78349f57e919e 192.168.1.103:6380
   slots: (0 slots) slave
   replicates fff7298fa77799434bc8ef6c74c974c21ebc47b4
M: 9e9613cec2fdd48000509e9c3723d157263edd87 192.168.1.102:6379
   slots:[5462-10922] (5461 slots) master
   1 additional replica(s)
M: f9d707317348314a7306fdaf91da2d153590140e 192.168.1.103:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.1.103:6390 to make it join the cluster.
[OK] New node added correctly.
```

加入后  

```shell
▶ redis-cli -h node1 -p 6379 cluster nodes                                           
b014cfbeff6f9668ec9592cbc8aa874bda2d8d6b 192.168.1.103:6390@16390 master - 0 1681527533967 6 connected
f635a8cdaa48e04f2531d28c103bea9dc2d8f48d 192.168.1.102:6380@16380 slave f9d707317348314a7306fdaf91da2d153590140e 0 1681527534990 5 connected
f49300c718a7e0baf6d3e8ba4bf7e9915e8051cc 192.168.1.101:6380@16380 slave 9e9613cec2fdd48000509e9c3723d157263edd87 0 1681527533000 4 connected
9ea59136c61207347657503fd7a78349f57e919e 192.168.1.103:6380@16380 slave fff7298fa77799434bc8ef6c74c974c21ebc47b4 0 1681527533000 0 connected
fff7298fa77799434bc8ef6c74c974c21ebc47b4 192.168.1.101:6379@16379 myself,master - 0 1681527529000 0 connected 0-5461
9e9613cec2fdd48000509e9c3723d157263edd87 192.168.1.102:6379@16379 master - 0 1681527534000 4 connected 5462-10922
f9d707317348314a7306fdaf91da2d153590140e 192.168.1.103:6379@16379 master - 0 1681527533000 5 connected 10923-16383
```

为他分配槽位  

```shell
# 最后一个参数，表示原来集群中任意一个节点，这里会将源节点所在集群的一部分分给新增节点
redis-cli -h node1 -p 6379 --cluster reshard 192.168.1.101:6379
##过程
#后面的2000表示分配2000个槽位给新增节点
How many slots do you want to move (from 1 to 16384)? 2000 #输入
#表示接受节点的NodeId,填新增节点6390的
What is the receiving node ID? b014cfbeff6f9668ec9592cbc8aa874bda2d8d6b #输入
#这里填槽的来源，要么填all，表示所有master节点都拿出一部分槽位分配给新增节点；
#要么填某个原有NodeId，表示这个节点拿出一部分槽位给新增节点
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1: 7e900adc7f977cfcccef12d48c7a29b64c4344c2
Source node #2: done
# 这里把node1:6379 拿出了2000个槽位给新节点

```

![image-20230415115032010](images/mypost/image-20230415115032010.png)

结果：  

```shell
? redis-cli -h node1 -p 6380 cluster nodes                       
259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 192.168.1.103:6379@16379 master - 0 1681530641000 2 connected 10923-16383
429ed631dbf09ba846a5371b707defe17b9f8c8e 192.168.1.101:6380@16380 myself,slave 9355d72df6e9dc2643ac1c819cd2e496fb1aed60 0 1681530643000 4 connected
9355d72df6e9dc2643ac1c819cd2e496fb1aed60 192.168.1.102:6379@16379 master - 0 1681530641000 4 connected 5462-10922
81e1e03230ed7700028fa56155e9531b48791164 192.168.1.103:6390@16390 master - 0 1681530644122 6 connected 0-1999
a04347e1af8930324dab7ae85f912449475a487f 192.168.1.102:6380@16380 slave 259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 0 1681530643093 2 connected
92a9d6b988dcf8a219de0247975d8e341072134d 192.168.1.103:6380@16380 slave 7e900adc7f977cfcccef12d48c7a29b64c4344c2 0 1681530643000 1 connected
7e900adc7f977cfcccef12d48c7a29b64c4344c2 192.168.1.101:6379@16379 master - 0 1681530642063 1 connected 2000-5461
```

### 添加从节点

将节点添加到集群中  

```shell
▶ redis-cli -h node1 -p 6379 --cluster add-node 192.168.1.103:6391 192.168.1.101:6379
>>> Adding node 192.168.1.103:6391 to cluster 192.168.1.101:6379
>>> Performing Cluster Check (using node 192.168.1.101:6379)
M: 7e900adc7f977cfcccef12d48c7a29b64c4344c2 192.168.1.101:6379
   slots:[2000-5461] (3462 slots) master
   1 additional replica(s)
M: 9355d72df6e9dc2643ac1c819cd2e496fb1aed60 192.168.1.102:6379
   slots:[5462-10922] (5461 slots) master
   1 additional replica(s)
S: a04347e1af8930324dab7ae85f912449475a487f 192.168.1.102:6380
   slots: (0 slots) slave
   replicates 259b65d7f3d1eac2716f7ae00cc6c1db27a55b27
M: 259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 192.168.1.103:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: 81e1e03230ed7700028fa56155e9531b48791164 192.168.1.103:6390
   slots:[0-1999] (2000 slots) master
S: 429ed631dbf09ba846a5371b707defe17b9f8c8e 192.168.1.101:6380
   slots: (0 slots) slave
   replicates 9355d72df6e9dc2643ac1c819cd2e496fb1aed60
S: 92a9d6b988dcf8a219de0247975d8e341072134d 192.168.1.103:6380
   slots: (0 slots) slave
   replicates 7e900adc7f977cfcccef12d48c7a29b64c4344c2
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 192.168.1.103:6391 to make it join the cluster.
[OK] New node added correctly.
```

建立主从关系  

```shell
▶ redis-cli -h node1 -p 6380 cluster nodes                                           
9babc7adc86da25ba501bd5bc007300dc04743a9 192.168.1.103:6391@16391 master - 0 1681530812000 0 connected
259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 192.168.1.103:6379@16379 master - 0 1681530808000 2 connected 10923-16383
429ed631dbf09ba846a5371b707defe17b9f8c8e 192.168.1.101:6380@16380 myself,slave 9355d72df6e9dc2643ac1c819cd2e496fb1aed60 0 1681530811000 4 connected
9355d72df6e9dc2643ac1c819cd2e496fb1aed60 192.168.1.102:6379@16379 master - 0 1681530810000 4 connected 5462-10922
81e1e03230ed7700028fa56155e9531b48791164 192.168.1.103:6390@16390 master - 0 1681530810000 6 connected 0-1999
a04347e1af8930324dab7ae85f912449475a487f 192.168.1.102:6380@16380 slave 259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 0 1681530811246 2 connected
92a9d6b988dcf8a219de0247975d8e341072134d 192.168.1.103:6380@16380 slave 7e900adc7f977cfcccef12d48c7a29b64c4344c2 0 1681530812275 1 connected
7e900adc7f977cfcccef12d48c7a29b64c4344c2 192.168.1.101:6379@16379 master - 0 1681530809182 1 connected 2000-5461

root@centos7101:/usr/local/redis_cluster                                                                                                                                
▶ redis-cli -h node3 -p 6391 cluster replicate 81e1e03230ed7700028fa56155e9531b48791164
OK

root@centos7101:/usr/local/redis_cluster                                                                     # 验证                                                           
▶ redis-cli -h node1 -p 6380 cluster nodes                                             
9babc7adc86da25ba501bd5bc007300dc04743a9 192.168.1.103:6391@16391 slave 81e1e03230ed7700028fa56155e9531b48791164 0 1681530870000 6 connected
259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 192.168.1.103:6379@16379 master - 0 1681530868642 2 connected 10923-16383
429ed631dbf09ba846a5371b707defe17b9f8c8e 192.168.1.101:6380@16380 myself,slave 9355d72df6e9dc2643ac1c819cd2e496fb1aed60 0 1681530867000 4 connected
9355d72df6e9dc2643ac1c819cd2e496fb1aed60 192.168.1.102:6379@16379 master - 0 1681530871715 4 connected 5462-10922
81e1e03230ed7700028fa56155e9531b48791164 192.168.1.103:6390@16390 master - 0 1681530868000 6 connected 0-1999
a04347e1af8930324dab7ae85f912449475a487f 192.168.1.102:6380@16380 slave 259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 0 1681530869000 2 connected
92a9d6b988dcf8a219de0247975d8e341072134d 192.168.1.103:6380@16380 slave 7e900adc7f977cfcccef12d48c7a29b64c4344c2 0 1681530870000 1 connected
7e900adc7f977cfcccef12d48c7a29b64c4344c2 192.168.1.101:6379@16379 master - 0 1681530870693 1 connected 2000-5461
```

测试  

```shell
node1:6380> set 18 a
-> Redirected to slot [511] located at 192.168.1.103:6390
OK
192.168.1.103:6390> get 18
"a"
#在node3:6391上尝试->说明从机上是有数据的
▶ redis-cli -h node3 -p 6391    
node3:6391> get 18
(error) MOVED 511 192.168.1.103:6390
node3:6391> readonly 
OK
node3:6391> get 18
"a"
node3:6391> keys *
1) "18"
```

### 集群收缩

#### 迁移待移除节点的槽位

```shell
#当前节点信息
429ed631dbf09ba846a5371b707defe17b9f8c8e 192.168.1.101:6380@16380 slave 9355d72df6e9dc2643ac1c819cd2e496fb1aed60 0 1681531264142 4 connected
7e900adc7f977cfcccef12d48c7a29b64c4344c2 192.168.1.101:6379@16379 master - 0 1681531260000 1 connected 2000-5461
9355d72df6e9dc2643ac1c819cd2e496fb1aed60 192.168.1.102:6379@16379 myself,master - 0 1681531261000 4 connected 5462-10922
259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 192.168.1.103:6379@16379 master - 0 1681531262088 2 connected 10923-16383
9babc7adc86da25ba501bd5bc007300dc04743a9 192.168.1.103:6391@16391 slave 81e1e03230ed7700028fa56155e9531b48791164 0 1681531265170 6 connected
81e1e03230ed7700028fa56155e9531b48791164 192.168.1.103:6390@16390 master - 0 1681531264000 6 connected 0-1999
92a9d6b988dcf8a219de0247975d8e341072134d 192.168.1.103:6380@16380 slave 7e900adc7f977cfcccef12d48c7a29b64c4344c2 0 1681531263115 1 connected
a04347e1af8930324dab7ae85f912449475a487f 192.168.1.102:6380@16380 slave 259b65d7f3d1eac2716f7ae00cc6c1db27a55b27 0 1681531260038 2 connected
```

移除并将槽位分配给其他节点  

```shell
redis-cli -p 6379 -h node1 --cluster reshard --cluster-from bee9c03b1c4592119695a17472847736128c8603 --cluster-to 644b722eb996aeb392a8190b29cfdbe95536af9a --cluster-slots 2000 192.168.1.101:6379
# 用哪个客户端，最后的ip:host->对该ip host所在集群的from和to操作，进行转移
# 结果
 redis-cli -h node1 -p 6380 cluster nodes
bee9c03b1c4592119695a17472847736128c8603 192.168.1.103:6390@16390 master - 0 1681532501000 6 connected
f525c38c1a78e997a96315ca982f969c51500e86 192.168.1.102:6379@16379 master - 0 1681532501000 0 connected 5462-10922
2b905b7e2480d80bb7c7aa47940e9636697a7d4c 192.168.1.103:6379@16379 master - 0 1681532503071 2 connected 10923-16383
644b722eb996aeb392a8190b29cfdbe95536af9a 192.168.1.101:6379@16379 master - 0 1681532502000 8 connected 0-5461
180113f8ceeba0b17b4a122caa62d36e99141225 192.168.1.103:6391@16391 slave 644b722eb996aeb392a8190b29cfdbe95536af9a 0 1681532503000 8 connected
576e15ed8ac1f4632e5f0917c43d41f7e26dc1e0 192.168.1.101:6380@16380 myself,slave f525c38c1a78e997a96315ca982f969c51500e86 0 1681532500000 0 connected
7ff6ce4b934027c1cdb8720169873f8e97474885 192.168.1.102:6380@16380 slave 2b905b7e2480d80bb7c7aa47940e9636697a7d4c 0 1681532504083 2 connected
75f8df2756a83c121b5637e3a381fa8ebfb9204d 192.168.1.103:6380@16380 slave 644b722eb996aeb392a8190b29cfdbe95536af9a 0 1681532501053 8 connected
## 查看
▶ redis-cli -h node1 -p 6379              
node1:6379> get 18
"a"
node1:6379> keys *
1) "18"
node1:6379> exit
## 看看还在不在103:6390上
redis-cli -h node3 -p 6390       
node3:6390> keys *
(empty array)
node3:6390> get 18
(error) MOVED 511 192.168.1.101:6379
```

槽位调整成功

> 注意，node3:6391原本replicate node3:6390，但是node3:6390没有槽位了，所以他就跟到槽位所在的node上了，即：  
>
> ```shell
> 644b722eb996aeb392a8190b29cfdbe95536af9a 192.168.1.101:6379@16379 master - 0 1681532502000 8 connected 0-5461
> 180113f8ceeba0b17b4a122caa62d36e99141225 192.168.1.103:6391@16391 slave 644b722eb996aeb392a8190b29cfdbe95536af9a 0 1681532503000 8 connected
> ```

#### 移除待删除的主从节点

先移除从节点，再移除主节点，防止触发集群故障转移(如上，这里可能并不会，因为已经没有节点replicate node3:6390了)

```shell
redis-cli -p 6379 -h node1 --cluster del-node 192.168.1.102:6380 180113f8ceeba0b17b4a122caa62d36e99141225
#ip+port :哪个节点所在的集群
#nodeId
>>> Removing node 180113f8ceeba0b17b4a122caa62d36e99141225 from cluster 192.168.1.102:6380
>>> Sending CLUSTER FORGET messages to the cluster...
>>> Sending CLUSTER RESET SOFT to the deleted node.
```

移除主节点

```shell
redis-cli -p 6379 -h node1 --cluster del-node 192.168.1.102:6380 bee9c03b1c4592119695a17472847736128c8603
>>> Removing node bee9c03b1c4592119695a17472847736128c8603 from cluster 192.168.1.102:6380
>>> Sending CLUSTER FORGET messages to the cluster...
>>> Sending CLUSTER RESET SOFT to the deleted node.
```

查看状态（移除成功）  

```shell
▶ redis-cli -h node1 -p 6379 cluster nodes                                                                 
644b722eb996aeb392a8190b29cfdbe95536af9a 192.168.1.101:6379@16379 myself,master - 0 1681533116000 8 connected 0-5461
75f8df2756a83c121b5637e3a381fa8ebfb9204d 192.168.1.103:6380@16380 slave 644b722eb996aeb392a8190b29cfdbe95536af9a 0 1681533119000 8 connected
f525c38c1a78e997a96315ca982f969c51500e86 192.168.1.102:6379@16379 master - 0 1681533120514 0 connected 5462-10922
2b905b7e2480d80bb7c7aa47940e9636697a7d4c 192.168.1.103:6379@16379 master - 0 1681533119492 2 connected 10923-16383
576e15ed8ac1f4632e5f0917c43d41f7e26dc1e0 192.168.1.101:6380@16380 slave f525c38c1a78e997a96315ca982f969c51500e86 0 1681533118463 0 connected
7ff6ce4b934027c1cdb8720169873f8e97474885 192.168.1.102:6380@16380 slave 2b905b7e2480d80bb7c7aa47940e9636697a7d4c 0 1681533118000 2 connected

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

# SpringBoot+RedisCluster

依赖  

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
```

配置文件yml  

```yml
spring:
  redis:
    # 如果是redis-cluster 不能用这种形式，否则会报错,只适合单机
    #Error in execution; nested exception is io.lettuce.core.
    #RedisCommandExecutionException: MOVED 15307 192.168.1.103:6379
    #host: 192.168.1.102
    #port: 6380

    # 下面的配置,nodes写一个或者多个都行
    cluster:
      nodes:
#        - 192.168.1.101:6379
#        - 192.168.1.102:6379
#        - 192.168.1.101:6380
        - 192.168.1.102:6380
#        - 192.168.1.103:6379
#        - 192.168.1.103:6380
```

序列化处理 

```java
@Configuration
public class RedisConfig {
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory redisConnectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        RedisSerializer<String> redisSerializer = new StringRedisSerializer();
        template.setConnectionFactory(redisConnectionFactory);
        //key序列化方式
        template.setKeySerializer(redisSerializer);
        //value序列化
        template.setValueSerializer(redisSerializer);
        //value hashmap序列化
        template.setHashValueSerializer(redisSerializer);
        //key haspmap序列化
        template.setHashKeySerializer(redisSerializer);
        //
        return template;
    }
}
```

使用  

```java
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @RequestMapping("/redisTest")
    public String redisTest(){
        redisTemplate.opsForValue().set("190","hello,world"+new Date().getTime());
        Object hello = redisTemplate.opsForValue().get("190");
        return hello.toString();
    }
```



# RedisCluster架构原理分析

## 基础架构（数据分片）

![image-20230414215403801](images/mypost/image-20230414215403801.png)

## 集群分片原理

如果有任意1个槽位没有被分配，则集群创建不成功。

![image-20230414215902852](images/mypost/image-20230414215902852.png)

## 启动集群原理

![image-20230414220624119](images/mypost/image-20230414220624119.png)

## 集群通信原理

![image-20230414221225818](images/mypost/image-20230414221225818.png)