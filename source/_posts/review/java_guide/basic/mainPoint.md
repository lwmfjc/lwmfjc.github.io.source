---
title: mainPoint
description: mainPoint
categories:
  - 学习
tags:
  - '复习'
  - '复习-javaGuide'
  - '复习-javaGuide-基础'
date: 2022-10-09 11:30:05
updated: 2022-10-09 11:30:05
---

## 为什么Java中只有值传递

- 形参&&实参

  - 形参(形式参数)，用于传递给函数/方法的参数，必须有确定的值

  - 实参(实际参数)，用于定义函数/方法，接收实参，不需要有确定的值

  - ```java
    String hello = "Hello!";
    // hello 为实参
    sayHello(hello);
    // str 为形参
    void sayHello(String str) {
        System.out.println(str);
    }
    ```

- 值传递&&引用传递

  - 程序设计将实参传递给方法的方式分为两种，值传递：方法接收实参值的拷贝，会创建副本；引用传递：方法接受的是实参所引用的对象在堆中的地址，不会创建副本，对形参的修改将影响到实参

- Java中只有值传递，原因：

  - 传递基本类型参数

    ```java
    public static void main(String[] args) {
        int num1 = 10;
        int num2 = 20;
        swap(num1, num2);
        System.out.println("num1 = " + num1);
        System.out.println("num2 = " + num2);
    }
    
    public static void swap(int a, int b) {
        int temp = a;
        a = b;
        b = temp;
        System.out.println("a = " + a);
        System.out.println("b = " + b);
    }
    //输出
    a = 20
    b = 10
    num1 = 10
    num2 = 20
    ```

  - 