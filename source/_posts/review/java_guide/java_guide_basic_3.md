---
title: javaGuide基础3
description: javaGuide基础3
categories:
  - 学习
tags:
  - 复习
  - 复习-基础
date: 2022-10-08 15:23:15
updated: 2022-10-08 15:23:15
---

## 异常

- unchecked exceptions (运行时异常)  
  checked exceptions (非运行时异常，编译异常）  

- Java异常类层次结构图
  ![image-20221008163827798](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221008163827798.png)

- Exception和Error有什么区别

  - 除了RuntimeException及其子类以外，其他的Exception类极其子类都属于受检查异常

  - Exception : 程序本身可以处理的异常（可通过catch捕获）

    - Checked Exception ，受检查异常，必须处理(catch 或者 throws ，否则编译器通过不了)
      IOException，ClassNotFoundException，SQLException，FileNotFoundException 

    - Unchecked Exception ， 不受检查异常 ， 可以不处理
      ArithmeticException，ClassCastException，IllegalThreadStateException，IndexOutOfBoundsException

      NullPointerException，IllegalArgumentException，NumberFormatException，SecurityException，UnsupportedOperationException 


      ```illegal 英[ɪˈliːɡl] 非法的```  
      ```Arithmetic 英[əˈrɪθmətɪk] 算术```

  - Error： 程序无法处理的错误 ，不建议通过catch 捕获，已办错误发生时JVM会选择线程终止  
    OutOfMemoryError （堆，Java heap space），VirtualMachineError，StackOverFlowError，AssertionError （断言），IOError 

- Throwable类常用方法 

  - String getMessage() //简要描述
  - String toString()  //详细
  - String getLocalizedMessage()  //本地化信息，如果子类(Throwable的子类)没有覆盖该方法，则与gtMessage() 结果一样
  - void printStackTrace() //打印Throwable对象封装的异常信息

## 泛型

## 反射

## 注解

## SPI

## I/O

## 语法糖

