---
title: 成员变量与局部变量
description: 成员变量与局部变量
categories:
  - 学习
tags:
  - 复习
  - 复习-基础
date: 2022-09-23 10:31:44
updated: 2022-09-23 10:31:44
---

## 代码

```java
   static int s;
    int i;
    int j;

    {
        int i = 1;
        i++;
        j++;
        s++;
    }

    public void test(int j) {
        j++;
        i++;
        s++;
    }

    public static void main(String[] args) {
        Exam5 obj1 = new Exam5();
        Exam5 obj2 = new Exam5();
        obj1.test(10);
        obj1.test(20);
        obj2.test(30);

        System.out.println(obj1.i + "," + obj1.j + "," + obj1.s);
        System.out.println(obj2.i + "," + obj2.j + "," + obj2.s);
    }
```

## 运行结果

```shell
2,1,5
1,1,5
```

## 分析

### 就近原则

代码中有很多修改变量的语句，下面是用就近原则+作用域分析的图
![lyx-20241126133407538](attachments/img/lyx-20241126133407538.png)

### 局部变量和类变量

- 局部变量包括方法体{}，形参，以及代码块  

  带static为类变量，不带的为实例变量  
  代码中的变量分类
  ![lyx-20241126133408096](attachments/img/lyx-20241126133408096.png)

- 修饰符 --局部变量只有final
               -- 实例变量 public , protected , private , final , static  , volatile transient

- 存储位置  

  局部变量：栈  
  实例变量：堆  
  类变量：方法区（类信息、常量、静态变量）  
  ![lyx-20241126133408581](attachments/img/lyx-20241126133408581.png)

- 作用域
  局部变量：从声明处开始，到所属的 } 结束
  ![lyx-20241126133408984](attachments/img/lyx-20241126133408984.png)

- this
  ![lyx-20241126133409438](attachments/img/lyx-20241126133409438.png)

- 题中的s既可以用成员变量访问，也可以用类名访问

- 生命周期

  - 局部变量：每一个线程，每一次调用执行都是新的生命周期
  - 实例变量：随着对象的创建而初始化，随着对象被回收而消亡（垃圾回收器），每一个对象的实例变量是独立的
  - 类变量：随着类的初始化而初始化，随着类的卸载而消亡，该类的所有对象的类变量是共享的

### 代码的执行，jvm中

Exam5 obj1=new Exam5();

![lyx-20241126133409988](attachments/img/lyx-20241126133409988.png)



obj1.test(10)

非静态代码块或者进入方法，都会在栈中开辟空间存储局部变量
![lyx-20241126133410521](attachments/img/lyx-20241126133410521.png)

注意：静态代码块定义的变量，只会存在于静态代码块中。不是类变量，也不属于成员变量