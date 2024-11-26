---
title: 单例设计模式
description: 单例设计模式
categories:
  - 学习
tags:
  - 复习
  - 复习-基础
date: 2022-09-21 14:22:44
updated: 2022-09-21 14:22:44
---

## 特点

- 该类只有一个实例
  - 构造器私有化
- 该类内部自行创建该实例
  - 使用静态变量保存
- 能向外部提供这个实例
  - 直接暴露
  - 使用静态变量的get方法获取

##  几大方法

### 饿汉式

随着类的加载进行初始化，不管是否需要都会直接创建实例对象

```java
public class Singleton1 {
	public static final Singleton1 INSTANCE=new Singleton1();
	private Singleton1() {
	}

}
```

### 枚举

枚举类表示该类型的对象是有限的几个

```java
public enum  Singleton2 {
	 INSTANCE
}
```

### 使用静态代码块

随着类的加载进行初始化

```java
public class Singleton2 {
	public static final Singleton2 INSTANCE;

	static {
		INSTANCE = new Singleton2();
	}

	private Singleton2() {
	}

}
```

如图，当初始化实例时需要进行复杂取值操作时，可以取代第一种方法
![lyx-20241126133414983](images/mypost/lyx-20241126133414983.png)

### 懒汉式

- 延迟创建对象

  ```java
  public class Singleton4 {
  	//为了防止重排序，需要添加volatile关键字
  	private static volatile Singleton4 INSTANCE;
  
  	private Singleton4() {
  	}
  
  	/**
  	 * double check
  	 * @return
  	 */
  	public static Singleton4 getInstance() {
  		//2 先判断一次,对于后面的操作(此时已经创建了对象)能减少加锁次数
  		if (INSTANCE == null) {
  			//如果这里不加锁会导致线程安全问题，可能刚进了判断语句之后，执行权被剥夺了又创建好了对象，
  			//所以判断及创建对象必须是原子操作
  			synchronized (Singleton4.class) {
  				if (INSTANCE == null) {
  					//用来模拟多线程被剥夺执行权
  					try {
  						Thread.sleep(1000);
  					} catch (InterruptedException e) {
  						e.printStackTrace();
  					}
  					//如果这个地方不加volatile,会出现的问题是,指令重排 1,2,3是正常的,
  					//会重排成1,3,2 然后别的线程去拿的时候，判断为非空，但是实际上运行的时候，发现里面的数据是空的
  
  					//1 memory = allocate();//分配对象空间
  					//2 instance(memory); //初始化对象
  					//3 instance = memory; //设置instance指向刚刚分配的位置
  					INSTANCE = new Singleton4();
  				}
  			}
  		}
  		return INSTANCE;
  	}
  }
  ```


### 使用静态内部类

```java
public class Singleton6 {
    private Singleton6(){

    }
    private static class Inner{
        private static final Singleton6 INSTANCE=new Singleton6();
    }
    public static Singleton6 getInstance(){
        return Inner.INSTANCE;
    }
}
```

- 只有当内部类被加载和初始化的时候，才会创建INSTANCE实例对象
- 静态内部类不会自动随着外部类的加载和初始化而初始化，他需要单独去加载和初始化
- 又由于他是在内部类加载和初始化时，创建的，属于类加载器处理的，所以是线程安全的



