---
title: 双主双从集群搭建
description: 双主双从集群搭建
tags:
  - rocketmq-hm
categories:
  - 学习
date: 2022-04-06 10:55:23
updated: 2022-04-06 10:55:23
---

>  学习来源 https://www.bilibili.com/video/BV1L4411y7mn（添加小部分笔记）感谢作者!

# 服务器信息修改

在.135和.138均进行下面的操作

## 解压

rocketmq解压到/usr/local/rocketmq目录下

## host添加

```shell
#添加host
vim /etc/hosts
##添加内容
192.168.1.135 rocketmq-nameserver1
192.168.1.138 rocketmq-nameserver2
192.168.1.135 rocketmq-master1
192.168.1.135 rocketmq-slave2
192.168.1.138 rocketmq-master2
192.168.1.138 rocketmq-slave1
## 保存后
systemctl restart network
```

## 防火墙

### 直接关闭

```shell
## 防火墙关闭
systemctl stop firewalld.service
## 防火墙状态查看
firewall-cmd --state
##禁止开机启动
systemctl disable firewalld.service
```

### 或者直接关闭对应端口即可

![image-20230406122046779](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230406122046779.png)

## 环境变量配置

为了执行rocketmq命令方便

```shell
#添加环境变量
vim /etc/profile
#添加
ROCKETMQ_HOME=/usr/local/rocketmq/rocketmq-all-4.4.0-bin-release
PATH=$PATH:$ROCKETMQ_HOME/bin
export ROCKETMQ_HOME PATH
#使配置生效
source /etc/profile
```

## 消息存储路径创建

### a

```shell
mkdir /usr/local/rocketmq/store-a
mkdir /usr/local/rocketmq/store-a/commitlog
mkdir /usr/local/rocketmq/store-a/consumequeue
mkdir /usr/local/rocketmq/store-a/index
```

### b

```shell
mkdir /usr/local/rocketmq/store-b
mkdir /usr/local/rocketmq/store-b/commitlog
mkdir /usr/local/rocketmq/store-b/consumequeue
mkdir /usr/local/rocketmq/store-b/index
```



# 双主双从配置文件的修改

## master-a

```shell
#所属集群名字
brokerClusterName=rocketmq-cluster
#broker名字，注意此处不同的配置文件填写的不一样
brokerName=broker-a
#0 表示 Master，>0 表示 Slave
brokerId=0
#nameServer地址，分号分割
namesrvAddr=rocketmq-nameserver1:9876;rocketmq-nameserver2:9876
#在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
defaultTopicQueueNums=4
#是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=true
#是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true
#Broker 对外服务的监听端口
listenPort=10911
#删除文件时间点，默认凌晨 4点
deleteWhen=04
#文件保留时间，默认 48 小时
fileReservedTime=120
#commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824
#ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
#检测物理文件磁盘空间
diskMaxUsedSpaceRatio=88
#存储路径
storePathRootDir=/usr/local/rocketmq/store-a
#commitLog 存储路径
storePathCommitLog=/usr/local/rocketmq/store-a/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/usr/local/rocketmq/store-a/consumequeue
#消息索引存储路径
storePathIndex=/usr/local/rocketmq/store-a/index
#checkpoint 文件存储路径
storeCheckpoint=/usr/local/rocketmq/store-a/checkpoint
#abort 文件存储路径
abortFile=/usr/local/rocketmq/store-a/abort
#限制的消息大小
maxMessageSize=65536
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#Broker 的角色
#- ASYNC_MASTER 异步复制Master
#- SYNC_MASTER 同步双写Master
#- SLAVE
brokerRole=SYNC_MASTER
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=SYNC_FLUSH
#checkTransactionMessageEnable=false
#发消息线程池数量
#sendMessageThreadPoolNums=128
#拉消息线程池数量
#pullMessageThreadPoolNums=128
```

## slave-b

```shell
#所属集群名字
brokerClusterName=rocketmq-cluster
#broker名字，注意此处不同的配置文件填写的不一样
brokerName=broker-b
#0 表示 Master，>0 表示 Slave
brokerId=1
#nameServer地址，分号分割
namesrvAddr=rocketmq-nameserver1:9876;rocketmq-nameserver2:9876
#在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
defaultTopicQueueNums=4
#是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=true
#是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true
#Broker 对外服务的监听端口
listenPort=11011
#删除文件时间点，默认凌晨 4点
deleteWhen=04
#文件保留时间，默认 48 小时
fileReservedTime=120
#commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824
#ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
#检测物理文件磁盘空间
diskMaxUsedSpaceRatio=88
#存储路径
storePathRootDir=/usr/local/rocketmq/store-b
#commitLog 存储路径
storePathCommitLog=/usr/local/rocketmq/store-b/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/usr/local/rocketmq/store-b/consumequeue
#消息索引存储路径
storePathIndex=/usr/local/rocketmq/store-b/index
#checkpoint 文件存储路径
storeCheckpoint=/usr/local/rocketmq/store-b/checkpoint
#abort 文件存储路径
abortFile=/usr/local/rocketmq/store-b/abort
#限制的消息大小
maxMessageSize=65536
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#Broker 的角色
#- ASYNC_MASTER 异步复制Master
#- SYNC_MASTER 同步双写Master
#- SLAVE
brokerRole=SLAVE
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=ASYNC_FLUSH
#checkTransactionMessageEnable=false
#发消息线程池数量
#sendMessageThreadPoolNums=128
#拉消息线程池数量
#pullMessageThreadPoolNums=128
```

## master-b

```shell
#所属集群名字
brokerClusterName=rocketmq-cluster
#broker名字，注意此处不同的配置文件填写的不一样
brokerName=broker-b
#0 表示 Master，>0 表示 Slave
brokerId=0
#nameServer地址，分号分割
namesrvAddr=rocketmq-nameserver1:9876;rocketmq-nameserver2:9876
#在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
defaultTopicQueueNums=4
#是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=true
#是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true
#Broker 对外服务的监听端口
listenPort=10911
#删除文件时间点，默认凌晨 4点
deleteWhen=04
#文件保留时间，默认 48 小时
fileReservedTime=120
#commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824
#ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
#检测物理文件磁盘空间
diskMaxUsedSpaceRatio=88
#存储路径
storePathRootDir=/usr/local/rocketmq/store-b
#commitLog 存储路径
storePathCommitLog=/usr/local/rocketmq/store-b/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/usr/local/rocketmq/store-b/consumequeue
#消息索引存储路径
storePathIndex=/usr/local/rocketmq/store-b/index
#checkpoint 文件存储路径
storeCheckpoint=/usr/local/rocketmq/store-b/checkpoint
#abort 文件存储路径
abortFile=/usr/local/rocketmq/store-b/abort
#限制的消息大小
maxMessageSize=65536
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#Broker 的角色
#- ASYNC_MASTER 异步复制Master
#- SYNC_MASTER 同步双写Master
#- SLAVE
brokerRole=SYNC_MASTER
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=SYNC_FLUSH
#checkTransactionMessageEnable=false
#发消息线程池数量
#sendMessageThreadPoolNums=128
#拉消息线程池数量
#pullMessageThreadPoolNums=128
```

## slave-a

```shell
#所属集群名字
brokerClusterName=rocketmq-cluster
#broker名字，注意此处不同的配置文件填写的不一样
brokerName=broker-a
#0 表示 Master，>0 表示 Slave
brokerId=1
#nameServer地址，分号分割
namesrvAddr=rocketmq-nameserver1:9876;rocketmq-nameserver2:9876
#在发送消息时，自动创建服务器不存在的topic，默认创建的队列数
defaultTopicQueueNums=4
#是否允许 Broker 自动创建Topic，建议线下开启，线上关闭
autoCreateTopicEnable=true
#是否允许 Broker 自动创建订阅组，建议线下开启，线上关闭
autoCreateSubscriptionGroup=true
#Broker 对外服务的监听端口
listenPort=11011
#删除文件时间点，默认凌晨 4点
deleteWhen=04
#文件保留时间，默认 48 小时
fileReservedTime=120
#commitLog每个文件的大小默认1G
mapedFileSizeCommitLog=1073741824
#ConsumeQueue每个文件默认存30W条，根据业务情况调整
mapedFileSizeConsumeQueue=300000
#destroyMapedFileIntervalForcibly=120000
#redeleteHangedFileInterval=120000
#检测物理文件磁盘空间
diskMaxUsedSpaceRatio=88
#存储路径
storePathRootDir=/usr/local/rocketmq/store-a
#commitLog 存储路径
storePathCommitLog=/usr/local/rocketmq/store-a/commitlog
#消费队列存储路径存储路径
storePathConsumeQueue=/usr/local/rocketmq/store-a/consumequeue
#消息索引存储路径
storePathIndex=/usr/local/rocketmq/store-a/index
#checkpoint 文件存储路径
storeCheckpoint=/usr/local/rocketmq/store-a/checkpoint
#abort 文件存储路径
abortFile=/usr/local/rocketmq/store-a/abort
#限制的消息大小
maxMessageSize=65536
#flushCommitLogLeastPages=4
#flushConsumeQueueLeastPages=2
#flushCommitLogThoroughInterval=10000
#flushConsumeQueueThoroughInterval=60000
#Broker 的角色
#- ASYNC_MASTER 异步复制Master
#- SYNC_MASTER 同步双写Master
#- SLAVE
brokerRole=SLAVE
#刷盘方式
#- ASYNC_FLUSH 异步刷盘
#- SYNC_FLUSH 同步刷盘
flushDiskType=ASYNC_FLUSH
#checkTransactionMessageEnable=false
#发消息线程池数量
#sendMessageThreadPoolNums=128
#拉消息线程池数量
#pullMessageThreadPoolNums=128
```

# 修改两台主机的runserver.sh及runbroker.sh修改

## 修改runbroker.sh

```shell
JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m"
```

## 修改runserver.sh

```shell
JAVA_OPT="${JAVA_OPT} -server -Xms256m -Xmx256m -Xmn128m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
```

# 两台主机分别启动nameserver和Brocker

```shell
## 在两台主机分别启动nameserver 
nohup sh mqnamesrv &
```

```shell
#135启动master1
nohup sh mqbroker -c /usr/local/rocketmq/rocketmq-all-4.4.0-bin-release/conf/2m-2s-sync/broker-a.properties &
#135启动slave2
nohup sh mqbroker -c /usr/local/rocketmq/rocketmq-all-4.4.0-bin-release/conf/2m-2s-sync/broker-b-s.properties &
#查看
jps
3478 Jps
3366 BrokerStartup
3446 BrokerStartup
3334 NamesrvStartup
```

```shell
#138启动master2
nohup sh mqbroker -c /usr/local/rocketmq/rocketmq-all-4.4.0-bin-release/conf/2m-2s-sync/broker-b.properties &
#135启动slave1
nohup sh mqbroker -c /usr/local/rocketmq/rocketmq-all-4.4.0-bin-release/conf/2m-2s-sync/broker-a-s.properties &
#查看
jps
3376 Jps
3360 BrokerStartup
3251 NamesrvStartup
3295 BrokerStartup
```

**双主双从集群搭建完毕！**

# 集群管理工具

## mqadmin

```cd bin``` 进入bin目录：mqadmin，对下面的信息进行操作  
topic、集群、Broker、消息、消费者组、生产者组、连接相关、namesrv相关、其他

## rocket-console

//已经弃用，现在改用rocketmq-dashboard

https://github.com/apache/rocketmq-dashboard

