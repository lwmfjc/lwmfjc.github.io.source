---
title: 类、实例初始化
description: 类、实例初始化
categories:
  - 学习
tags:
  - 复习
  - 复习-基础
date: 2022-09-22 08:50:23
updated: 2022-09-22 11:50:44
---

## 代码

```java
 public class Son extends Father{
	private int i=test();
	private static int j=method();
	static {
		System.out.print("(6)");
	}
	Son(){
		System.out.print("(7)");
	}
	{
		System.out.print("(8)");
	}
	public int test(){
		System.out.print("(9)");
		return 1;
	}

	public static int method(){
		System.out.print("(10)");
		return 1;
	}

	public static void main(String[] args) {
		Son s1=new Son();
		System.out.println();
		Son s2=new Son();
	}


}

```

```java
 public class Father {
	private int i=test();
	private static int j=method();
	static {
		System.out.print("(1)");
	}
	Father(){
		System.out.print("(2)");
	}
	{
		System.out.print("(3)");
	}

	public int test() {
		System.out.print("(4)");
		return 1;
	}

	public static int method() {
		System.out.print("(5)");
		return 1;
	}
}

```

输出：

```shell
(5)(1)(10)(6)(9)(3)(2)(9)(8)(7)
(9)(3)(2)(9)(8)(7)
```

## 分析

- 类初始化过程

  - 当实例化了一个对象/或main所在类会导致类初始化
  - 子类初始化前会先初始化父类
  - 类初始化执行的是<clinit >方法，编译查看字节码可得知
    ![lyx-20241126133406187](attachments/img/lyx-20241126133406187.png)
  - <clinit >由静态类变量显示赋值语句 以及 静态代码块组成(由上到下顺序)，且只执行一次  
    如下  
    ![lyx-20241126133406673](attachments/img/lyx-20241126133406673.png)

- 实例初始化过程

  - 执行的是<init>方法
    由非静态实例变量显示赋值语句 以及 非静态代码块  [从上到下顺序]
    以及对应构造器代码[最后执行] 组成 
    其中，子类构造器一定会调用super() [最前面]
    1） super() 【最前】 2）i = test() 3）子类的非静态代码块 【2，3按顺序】
    4) 子类的无参构造(最后)  
    ![lyx-20241126133407112](attachments/img/lyx-20241126133407112.png)

- 重写的问题
   如上所示，初始化Son对象的时候，会先调用super()方法，即初始化父类，然后会先调用父类的 非静态变量赋值以及非静态代码块，最后才是父类的构造器代码块  

  调用父类非静态变量赋值的时候，如果调用了非静态方法，就会涉及到重写问题，比如这里的 

  ```java
  public class Father{
   private int i= test();
  }
  ```

  这里会调用子类(当前正在初始化的对象)的test()方法，而不是父类的test()

  - 哪些方法不可被重写
    final方法、静态方法、父类中的private等修饰使得子类不可见的方法

  

  