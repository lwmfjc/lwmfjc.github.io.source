---
title: 作用域及事务
description: 作用域及事务
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

## 事务

### 事务是什么

逻辑上的一组操作，要么都执行，要么都不执行

### 事务的特性

ACID

- Atomicity ```/ˌætəˈmɪsəti/```原子性 , 要么全部成功，要么全部失败
- Consistency ```/kənˈsɪstənsi/``` 一致性 , 数据库的完整性
- Isolation ```/ˌaɪsəˈleɪʃn/``` 隔离性 , 数据库允许多个并发事务同时对其数据进行读写和修改的能力，隔离性可以防止多个事务并发执行时由于交叉执行而导致数据的不一致 , 这里涉及到事务隔离级别
- Durability ```/ˌdjʊərəˈbɪləti/``` 持久性 , 事务处理结束后，对数据的修改就是永久的，即便系统故障也不会丢失

### Spring支持两种方式的事务管理

- 编程式事务管理
  ```/ˈeksɪkjuːt/``` execute  
  使用transactionTemplate

  ```java
  @Autowired
  private TransactionTemplate transactionTemplate;
  public void testTransaction() {
  
          transactionTemplate.execute(new TransactionCallbackWithoutResult() {
              @Override
              protected void doInTransactionWithoutResult(TransactionStatus transactionStatus) {
  
                  try {
  
                      // ....  业务代码
                  } catch (Exception e){
                      //回滚
                      transactionStatus.setRollbackOnly();
                  }
  
              }
          });
  }
  ```

  使用transactionManager

  ```java
  @Autowired
  private PlatformTransactionManager transactionManager;
  
  public void testTransaction() {
  
    TransactionStatus status = transactionManager.getTransaction(new DefaultTransactionDefinition());
            try {
                 // ....  业务代码
                transactionManager.commit(status);
            } catch (Exception e) {
                transactionManager.rollback(status);
            }
  }
  ```

  声明式事务管理

  ```java
  @Transactional(propagation = Propagation.REQUIRED)
  public void aMethod {
    //do something
    B b = new B();
    C c = new C();
    b.bMethod();
    c.cMethod();
  }
  ```

  

###  事务传播行为

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
  如果外部方法没有开启事务，则内部方法创建一个新的事务，即内外两个方法的事务互相独立；如果外部方法存在事务，则内部方法加入该事务，即内外两个方法使用同一个事务

- **`TransactionDefinition.PROPAGATION_REQUIRES_NEW`**
  如果外部方法存在事务，则会挂起当前的事务，并且开启一个新事务，当外部方法抛出异常时，内部方法不会回滚；而当内部方法抛出异常时，外部方法会检测到并进行回滚。
  如果外部方法不存在事务，则也会开启一个新事务

- **`TransactionDefinition.PROPAGATION_NESTED`**:
  如果外部方法开启事务，则在内部再开启一个事务，作为嵌套事务存在；如果外部方法无事务，则单独开启一个事务

  > **在外围方法开启事务的情况下`Propagation.NESTED`修饰的内部方法属于外部事务的子事务，外围主事务回滚，子事务一定回滚，而内部子事务可以单独回滚而不影响外围主事务和其他子事务，也就是和上面的PROPAGATION_REQUIRES_NEW相反**

- **`TransactionDefinition.PROPAGATION_MANDATORY`**
  如果当前存在事务，则加入该事务；如果当前没有事务，则抛出异常
  mandatory ```/ˈmændətəri/``` 强制的

- 下面三个比较不常用

  - **`TransactionDefinition.PROPAGATION_SUPPORTS`**: 如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
  - **`TransactionDefinition.PROPAGATION_NOT_SUPPORTED`**: 以非事务方式运行，如果当前存在事务，则把当前事务挂起。
  - **`TransactionDefinition.PROPAGATION_NEVER`**: 以非事务方式运行，如果当前存在事务，则抛出异常。

###  事务隔离级别

- **`TransactionDefinition.ISOLATION_DEFAULT`**
- **`TransactionDefinition.ISOLATION_READ_UNCOMMITTED`**
  读未提交，级别最低，允许读取尚未提交的数据，可能会导致脏读、幻读或不可重复读
- **`TransactionDefinition.ISOLATION_READ_COMMITTED`**
  读已提交，对同一字段的多次读取结果都是一致的。可以阻止脏读，但幻读或不可重复读仍会发生
- **`TransactionDefinition.ISOLATION_SERIALIZABLE`**
  串行化，可以防止脏读、幻读及不可重复读，所有事务依次逐个执行，完全服从ACID，但严重影响性能

