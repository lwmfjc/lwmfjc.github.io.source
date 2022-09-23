---
title: 一些spring试题
description: 一些spring试题
categories:
  - 学习
tags:
  - 复习
  - 复习-SSM
date: 2022-09-23 13:37:38
updated: 2022-09-23 13:37:38
---

## 四种作用域

- singleton：默认值，当IOC容器一创建就会创建bean实例，而且是单例的，每次得到的是同一个
- prototype：原型的，IOC容器创建时不再创建bean实例。每次调用getBean方法时再实例化该bean（每次都会进行实例化）
- request：每次请求会实例化一个bean
- session：在一次会话中共享一个bean

## 事务传播行为

Definition ```/ˌdefɪˈnɪʃ(ə)n/``` 定义

Propagation ```/ˌprɒpəˈɡeɪʃn/``` 传播
假设有代码如下：

```java
@Service
Class A {
    @Autowired
    B b;
    @Transactional(propagation = Propagation.REQUIRED)
    public void aMethod {
        //do something
        b.bMethod();
    }
}
@Service
Class B {
    @Transactional(propagation = Propagation.XXXXXX)
    public void bMethod {
       //do something
    }
}
```

共7种，其中主要有4种如下

- **`TransactionDefinition.PROPAGATION_REQUIRED`**
  

- 