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

    - Checked Exception ，受检查异常，必须处理(**catch 或者 throws ，否则编译器通过不了**)
      IOException，ClassNotFoundException，SQLException，FileNotFoundException 

    - Unchecked Exception ， 不受检查异常 ， 可以不处理
      
（算数异常，类型转换异常，不合法的线程状态异常，下标超出异常，空指针异常，参数类型异常，数字格式异常，不支持操作异常）
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
  
- try-catch-finally如何使用
  try后面必须要有catch或者finally；无论是否捕获异常，finally都会执行；当在 `try` 块或 `catch` 块中遇到 `return` 语句时，`finally` 语句块将在方法返回之前被执行。

  - **不要在 finally 语句块中使用 return!** 当 try 语句和 finally 语句中都有 return 语句时，try 语句块中的 return 语句会被忽略。这是因为 try 语句中的 return 返回值会先被暂存在一个本地变量中，当执行到 finally 语句中的 return 之后，这个本地变量的值就变为了 finally 语句中的 return 返回值。

    ```java
    不要在 finally 语句块中使用 return! 当 try 语句和 finally 语句中都有 return 语句时，try 语句块中的 return 语句会被忽略。这是因为 try 语句中的 return 返回值会先被暂存在一个本地变量中，当执行到 finally 语句中的 return 之后，这个本地变量的值就变为了 finally 语句中的 return 返回值。
    ```

- finally中的代码不一定执行（如果finally之前虚拟机就已经被终止了）

## 泛型

## 反射

## 注解

## SPI

## I/O

## 语法糖

