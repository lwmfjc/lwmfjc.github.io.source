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