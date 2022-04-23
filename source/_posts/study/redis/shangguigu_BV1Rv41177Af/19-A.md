---
title: "redis_尚硅谷_19-A"
date: 2022-01-19 16:52:19 
description: 首先需要一个MyRedis单例类 
draft: false
updated: 2022-01-20 16:52:19 
tags: 
 - "redis_尚硅谷"
categories:
 - "学习"

---

## 验证码模拟
* 首先需要一个MyRedis单例类
```java
/**
 * MyRedis单例类
 */
public class MyJedis {
    private static Jedis myJedis;

    public static Jedis getInstance() {
        //如果是空则进行初始化
        if (myJedis == null) {
            //由于synchronized同步是在条件判断内，所以同步
            //并不会一直都执行，增加了效率
            synchronized (MyJedis.class) {
                if (myJedis == null) {
                    //设置密码
                    DefaultJedisClientConfig.Builder builder = DefaultJedisClientConfig.builder()
                            .password("hello.lwm");
                    DefaultJedisClientConfig config = builder.build();

                    Jedis jedis = new redis.clients.jedis.Jedis("192.168.200.200", 6379, config);

                    return jedis;
                }
            }

        }
        return myJedis;
    }
}
```
