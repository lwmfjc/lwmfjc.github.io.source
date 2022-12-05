---
title: 为什么Java中只有值传递
description: 为什么Java中只有值传递
categories:
  - 学习
tags:
  - '复习'
  - '复习-javaGuide'
  - '复习-javaGuide-基础'
date: 2022-10-09 11:30:05
updated: 2022-10-09 11:30:05

---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

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

  - 传递引用类型参数 1
  
    ```java
    public static void main(String[] args) {
          int[] arr = { 1, 2, 3, 4, 5 };
          System.out.println(arr[0]); //1
          change(arr);
          System.out.println(arr[0]);//0
    }
    
    public static void change(int[] array) {
        // 将数组的第一个元素变为0
        array[0] = 0;
    }
    ```
  
    change方法的参数，拷贝的是arr(实参)的地址，所以array和arr指向的是同一个数组对象
    ![image-20221010103143086](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221010103143086.png)
  
  - 传递引用类型参数2  
  
    ```java
    public class Person {
        private String name;
       // 省略构造函数、Getter&Setter方法
    }
    
    public static void main(String[] args) {
        Person xiaoZhang = new Person("小张");
        Person xiaoLi = new Person("小李");
        swap(xiaoZhang, xiaoLi);
        System.out.println("xiaoZhang:" + xiaoZhang.getName());
        System.out.println("xiaoLi:" + xiaoLi.getName());
    }
    
    public static void swap(Person person1, Person person2) {
        Person temp = person1;
        person1 = person2;
        person2 = temp;
        System.out.println("person1:" + person1.getName());
        System.out.println("person2:" + person2.getName());
    }
    //结果
    person1:小李
    person2:小张
    xiaoZhang:小张
    xiaoLi:小李
    ```
  
    这里并不会交换xiaoZhang和xiaoLi，只会交换swap方法栈里的person1和person2   
  
    ![image-20221010103522823](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221010103522823.png)
  
- 小结  Java 中将实参传递给方法（或函数）的方式是 **值传递** ：

  - 如果参数是基本类型的话，很简单，传递的就是基本类型的字面量值的拷贝，会创建副本。
  - 如果参数是引用类型，传递的就是实参所引用的对象在堆中地址值的拷贝，同样也会创建副本。

