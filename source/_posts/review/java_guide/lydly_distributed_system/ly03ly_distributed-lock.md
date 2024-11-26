---
title: 分布式锁
description: 分布式锁
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-distributed_system
date: 2023-02-11 13:24:32
updated: 2023-02-11 13:24:32
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

网上有很多分布式锁相关的文章，写了一个相对简洁易懂的版本，针对面试和工作应该够用了。

## 什么是分布式锁？

对于单机多线程来说，在 Java 中，我们通常使用 `ReetrantLock` 类、`synchronized` 关键字这类 JDK 自带的 **本地锁** 来控制**一个 JVM 进程**内的**多个线程**对**本地共享资源**的访问。

下面是我对本地锁画的一张示意图。

 ![lyx-20241126133910713](attachments/img/lyx-20241126133910713.png)

从图中可以看出，这些线程访问共享资源是互斥的，同一时刻只有一个线程可以获取到本地锁访问共享资源。

**分布式系统**下，**不同的服务/客户端**通常**运行在独立的 JVM 进程**上。如果**多个 JVM 进程共享同一份资源**的话，使用**本地锁就没办法实现**资源的互斥访问了。于是，**分布式锁** 就诞生了。

举个例子：系统的订单服务一共部署了 3 份，都对外提供服务。用户下订单之前需要检查库存，为了防止超卖，这里需要加锁以实现对检查库存操作的同步访问。由于订单服务位于不同的 JVM 进程中，本地锁在这种情况下就没办法正常工作了。我们需要用到分布式锁，这样的话，即使多个线程**不在同一个 JVM 进程**中也能**获取到同一把锁**，进而实现**共享资源的互斥访问**。

下面是我对分布式锁画的一张示意图。

[![分布式锁](attachments/img/lyx-20241126133911324.png)](https://github.com/Snailclimb/JavaGuide/blob/main/docs/distributed-system/images/distributed-lock/distributed-lock.png)

从图中可以看出，这些独立的进程中的线程访问共享资源是互斥的，**同一时刻只有一个线程可以获取到分布式锁访问共享资源**。

一个最基本的分布式锁需要满足：

- **互斥** ：任意一个时刻，锁只能被一个线程持有；
- **高可用** ：锁服务是高**可用**的。并且，**即使客户端的释放锁的代码逻辑出现问题(这里说的是异常，不是说代码写的有问题)**，锁最终**一定还是会被释放**，**不会影响其他线程**对共享资源的访问。
- **可重入**：**(同)一个节点**获取了锁之后，还可以**再次**获取锁。

通常情况下，我们一般会选择基于 **Redis** 或者 **ZooKeeper** 实现分布式锁，Redis 用的要更多一点，我这里也以 Redis 为例介绍分布式锁的实现。

## 基于 Redis 实现分布式锁

### 如何基于 Redis 实现一个最简易的分布式锁？

不论是实现**锁(本地)**还是**分布式锁**，核心都在于**“互斥”**。

在 Redis 中， `SETNX` 命令是可以帮助我们实现互斥。`SETNX` 即 **SET** if **N**ot e**X**ists (对应 Java 中的 `setIfAbsent` 方法)，如果 key 不存在的话，才会设置 key 的值。如果 key 已经存在， `SETNX` 啥也不做。

```shell
> SETNX lockKey uniqueValue
(integer) 1
> SETNX lockKey uniqueValue
(integer) 0 
#如上成功为1，失败为0
```

释放锁的话，直接通过 `DEL` 命令删除对应的 key 即可。

```shell
> DEL lockKey
(integer) 1 # 成功为1
```

为了**误删到其他的锁**，这里我们建议使用 Lua 脚本通过 key 对应的 value（唯一值）来判断。

选用 Lua 脚本是为了**保证解锁操作的原子性**。因为 Redis 在执行 Lua 脚本时，可以**以原子性的方式执行**，从而保证了锁释放操作的原子性。

```shell
// 释放锁时，先比较锁对应的 value 值是否相等，避免锁的误释放
if redis.call("get",KEYS[1]) == ARGV[1] then
    return redis.call("del",KEYS[1])
else
    return 0
end
```

 ![lyx-20241126133911735](attachments/img/lyx-20241126133911735.png)

这是一种最简易的 Redis 分布式锁实现，实现方式比较简单，性能也很高效。不过，这种方式实现分布式锁**存在一些问题**。就比如应用程序遇到一些问题比如**释放锁的逻辑突然挂掉，可能会导致锁无法被释放**，进而造成**共享资源无法再被其他线程/进程访问**。

### 为什么要给锁设置一个过期时间？

为了避免锁无法被释放，我们可以想到的一个解决办法就是： **给这个 key（也就是锁） 设置一个过期时间** 。

```
127.0.0.1:6379> SET lockKey uniqueValue EX 3 NX
OK
```

- **lockKey** ：加锁的锁名；
- **uniqueValue** ：能够唯一标示锁的随机字符串；
- **NX** ：只有当 lockKey 对应的 key 值不存在的时候才能 SET 成功；
- **EX** ：过期时间设置（秒为单位）EX 3 标示这个锁有一个 3 秒的自动过期时间。与 EX 对应的是 PX（毫秒为单位），这两个都是过期时间设置。

**一定要保证设置指定 key 的值和过期时间是一个原子操作！！！** 不然的话，依然可能会出现锁无法被释放的问题。

这样确实可以解决问题，不过，这种解决办法同样存在漏洞：**如果操作共享资源的时间大于过期时间，就会出现锁提前过期的问题，进而导致分布式锁直接失效。如果锁的超时时间设置过长，又会影响到性能。**

你或许在想： **如果操作共享资源的操作还未完成，锁过期时间能够自己续期就好了！**

### 如何实现锁的优雅续期？

对于 Java 开发的小伙伴来说，已经有了现成的解决方案：**[Redisson](https://github.com/redisson/redisson)** 。其他语言的解决方案，可以在 Redis 官方文档中找到，地址：https://redis.io/topics/distlock 。

 ![Distributed locks with Redis](attachments/img/lyx-20241126133912270.jpg) 

Redisson 是一个开源的 Java 语言 Redis 客户端，提供了很多开箱即用的功能，不仅仅包括多种分布式锁的实现。并且，Redisson 还支持 Redis 单机、Redis Sentinel 、Redis Cluster 等多种部署架构。

Redisson 中的**分布式锁自带自动续期机制**，使用起来非常简单，原理也比较简单，其**提**供了一个专门用来**监控**和**续期锁**的 **Watch Dog（ 看门狗）**，**如果操作共享资源的线程还未执行完成**的话，**Watch Dog 会不断地延长锁的过期时间**，进而保证锁不会因为超时而被释放。  

> 如图，续期之前也是要检测**是否为持锁线程**

 ![lyx-20241126133912703](attachments/img/lyx-20241126133912703.png)

看门狗名字的由来于 `getLockWatchdogTimeout()` 方法，这个方法返回的是看门狗**给锁续期的过期时间，默认为 30 秒**（[redisson-3.17.6](https://github.com/redisson/redisson/releases/tag/redisson-3.17.6)）。

```java
//默认 30秒，支持修改
private long lockWatchdogTimeout = 30 * 1000;

public Config setLockWatchdogTimeout(long lockWatchdogTimeout) {
    this.lockWatchdogTimeout = lockWatchdogTimeout;
    return this;
}
public long getLockWatchdogTimeout() {
  	return lockWatchdogTimeout;
}
```

`renewExpiration()` 方法包含了看门狗的主要逻辑：

```java
private void renewExpiration() {
         //......
        Timeout task = commandExecutor.getConnectionManager().newTimeout(new TimerTask() {
            @Override
            public void run(Timeout timeout) throws Exception {
                //......
                // 异步续期，基于 Lua 脚本(ly:我觉得是为了保证原子性所以用了Lua脚本)
                CompletionStage<Boolean> future = renewExpirationAsync(threadId);
                future.whenComplete((res, e) -> {
                    if (e != null) {
                        // 无法续期
                        log.error("Can't update lock " + getRawName() + " expiration", e);
                        EXPIRATION_RENEWAL_MAP.remove(getEntryName());
                        return;
                    }

                    if (res) {
                        // 递归调用实现续期
                        renewExpiration();
                    } else {
                        // 取消续期
                        cancelExpirationRenewal(null);
                    }
                });
            }
         // 延迟 internalLockLeaseTime/3（默认 10s，也就是 30/3） 再调用
        }, internalLockLeaseTime / 3, TimeUnit.MILLISECONDS);

        ee.setTimeout(task);
    }
```

默认情况下，每过 10 秒，看门狗就会执行续期操作，**将锁的超时时间设置为 30 秒**。看门狗续期前也会先**判断是否需要执行续期操作**，需要才会执行续期，否则取消续期操作。

Watch Dog 通过调用 `renewExpirationAsync()` 方法实现锁的**异步续期**：

```java
protected CompletionStage<Boolean> renewExpirationAsync(long threadId) {
    return evalWriteAsync(getRawName(), LongCodec.INSTANCE, RedisCommands.EVAL_BOOLEAN,
            // 判断是否为持锁线程，如果是就执行续期操作，就锁的过期时间设置为 30s（默认）
            "if (redis.call('hexists', KEYS[1], ARGV[2]) == 1) then " +
                    "redis.call('pexpire', KEYS[1], ARGV[1]); " +
                    "return 1; " +
                    "end; " +
                    "return 0;",
            Collections.singletonList(getRawName()),
            internalLockLeaseTime, getLockName(threadId));
}
```

可以看出， `renewExpirationAsync` 方法其实是调用 Lua 脚本实现的续期，这样做主要是为了**保证续期操作的原子性**。

我这里以 Redisson 的分布式可重入锁 `RLock` 为例来说明如何使用 Redisson 实现分布式锁：

```java
// 1.获取指定的分布式锁对象
RLock lock = redisson.getLock("lock");
// 2.拿锁且不设置锁超时时间，具备 Watch Dog 自动续期机制
lock.lock();
// 3.执行业务
...
// 4.释放锁
lock.unlock();
```

只有未指定锁超时时间，才会使用到 Watch Dog 自动续期机制。

```java
// 手动给锁设置过期时间，不具备 Watch Dog 自动续期机制
lock.lock(10, TimeUnit.SECONDS);
```

如果使用 Redis 来实现分布式锁的话，还是比较推荐直接基于 Redisson 来做的。

### 如何实现可重入锁？

所谓可重入锁指的是**在一个线程中可以多次获取同一把锁**，比如**一个线程**在**执行一个带锁的方法**，**该方法中**又调用了另一个需要**相同锁**的方法，则该线程可以直接执行调用的方法即可重入 ，而无需重新获得锁。像 Java 中的 `synchronized` 和 `ReentrantLock` 都属于可重入锁。

**不可重入的分布式锁基本可以满足绝大部分业务场景了，一些特殊的场景可能会需要使用可重入的分布式锁。**

可重入分布式锁的实现核心思路是线程在获取锁的时候判断是否为自己的锁，**如果是的话，就不用再重新获取了**。为此，我们可以**为每个锁关联一个可重入计数器**和**一个占有它的线程**。当**可重入计数器大于 0** 时，则**锁被占有**，需要判断**占有该锁的线程**和**请求获取锁的线程**是否为同一个。

实际项目中，我们不需要自己手动实现，推荐使用我们上面提到的 **Redisson** ，其内置了多种类型的锁比如**可重入锁（Reentrant Lock）**、**自旋锁（Spin Lock）**、**公平锁（Fair Lock）**、**多重锁（MultiLock）**、 **红锁（RedLock）**、 **读写锁（ReadWriteLock）**。

 ![lyx-20241126133913308](attachments/img/lyx-20241126133913308.png)

### Redis 如何解决集群情况下分布式锁的可靠性？

为了**避免单点故障（也就是只部署在一台机器，导致一台机器挂了服务就无法运行并提供功能）**，生产环境下的 Redis 服务通常是集群化部署的。

Redis 集群下，上面介绍到的分布式锁的实现会存在一些问题。由于 **Redis 集群数据同步到各个节点时是异步的**，如果在 Redis 主节点获取到锁后，在没有同步到其他节点时，Redis 主节点宕机了，此时**新的 Redis 主节点依然可以获取锁**，所以多个应用服务就可以**同时**获取到锁。

  ![lyx-20241126133913736](attachments/img/lyx-20241126133913736.png)

针对这个问题，Redis 之父 antirez 设计了 [Redlock 算法](https://redis.io/topics/distlock) 来解决。

 ![lyx-20241126133914161](attachments/img/lyx-20241126133914161.png)

Redlock 算法的思想是让**客户端**向 Redis 集群中的**多个独立的 Redis 实例** **依次请求申请加锁**，如果客户端能够**和半数以上**的实例成功地**完成加锁**操作，那么我们就认为，客户端**成功地获得**分布式锁，否则加锁失败。

即使部分 Redis 节点出现问题，只要**保证 Redis 集群中有半数以上的 Redis 节点**可用，分布式锁服务就是正常的。

Redlock 是**直接操作 Redis 节点**的，并**不是通过 Redis 集群**操作的，这样才可以**避免 Redis 集群主从切换导致的锁丢失**问题。  

> 注意，**不是通过Redis集群**做的哦

Redlock 实现比较复杂，性能比较差，发生时钟变迁的情况下还存在安全性隐患。《数据密集型应用系统设计》一书的作者 Martin Kleppmann 曾经专门发文（[How to do distributed locking - Martin Kleppmann - 2016](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html)）怼过 Redlock，他认为这是一个很差的分布式锁实现。感兴趣的朋友可以看看[Redis 锁从面试连环炮聊到神仙打架](https://mp.weixin.qq.com/s?__biz=Mzg3NjU3NTkwMQ==&mid=2247505097&idx=1&sn=5c03cb769c4458350f4d4a321ad51f5a&source=41#wechat_redirect)这篇文章，有详细介绍到 antirez 和 Martin Kleppmann 关于 Redlock 的激烈辩论。

实际项目中**不建议使用 Redlock 算法**，成本和收益不成正比。

**如果不是非要实现绝对可靠的分布式锁**的话，其实**单机版 Redis** 就完全够了，实现简单，性能也非常高。如果你必须要实现一个**绝对可靠**的分布式锁的话，可以**基于 Zookeeper** 来做，只是**性能会差一些**。