---
title: 语法糖
description: syntactic-sugar
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-12 17:36:26
updated: 2022-10-12 17:36:26
---



## 简介

语法糖（Syntactic Sugar）也称糖衣语法，指的是在计算机语言中添加的某种语法，这种语法对语言的功能并没有影响，但是更方便程序员使用，简而言之，让程序更加简洁，有更高的可读性

## Java中有哪些语法糖

Java虚拟机并不支持这些语法糖，这些语法糖在编译阶段就会被还原成简单的基础语法结构，这个过程就是解语法糖

- ```javac```命令可以将后缀为```.java```的源文件编译为后缀名为```.class```的可以运行于Java虚拟机的字节码。其中，```com.sun.tools.javac.main.JavaCompiler```的源码中，```compile()```中有一个步骤就是调用```desugar()```，这个方法就是负责解语法糖的实现的
- Java中的语法糖，包括 泛型、变长参数、条件编译、自动拆装箱、内部类等

### switch支持String与枚举

switch本身原本只支持基本类型，如char、byte、short、int及其封装类，以及String、enum 
![image-20221013110105262](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221013110105262.png)

int是数值，而char转ascii码，所以其实对于编译器来说，都是int类型(整型)
![image-20221013111130070](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221013111130070.png)

![image-20221013111255889](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221013111255889.png)
而对于enum类型，  
![image-20221013111642816](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221013111642816.png)

对于switch中使用String，则：  

```java
public class switchDemoString {
    public static void main(String[] args) {
        String str = "world";
        switch (str) {
        case "hello":
            System.out.println("hello");
            break;
        case "world":
            System.out.println("world");
            break;
        default:
            break;
        }
    }
}
//反编译之后
public class switchDemoString
{
    public switchDemoString()
    {
    }
    public static void main(String args[])
    {
        String str = "world";
        String s;
        switch((s = str).hashCode())
        {
        default:
            break;
        case 99162322:
            if(s.equals("hello"))
                System.out.println("hello");
            break;
        case 113318802:
            if(s.equals("world"))
                System.out.println("world");
            break;
        }
    }
}
```

即switch判断是通过equals()和hashCode()方法来实现的

equals()检查是必要的，因为有可能发生碰撞，所以性能没有直接使用枚举进行switch或纯整数常量性能高

### 泛型

编译器处理泛型有两种方式：`Code specialization`和`Code sharing`。C++和 C#是使用`Code specialization`的处理机制，而 Java 使用的是`Code sharing`的机制

> Code sharing 方式为每个泛型类型创建唯一的字节码表示，并且将该泛型类型的实例都映射到这个唯一的字节码表示上。将多种泛型类形实例映射到唯一的字节码表示是通过类型擦除（`type erasue`）实现的。

两个例子  

- Map擦除

  ```java
  Map<String, String> map = new HashMap<String, String>();
  map.put("name", "hollis");
  map.put("wechat", "Hollis");
  map.put("blog", "www.hollischuang.com");
  //解语法糖之后
  Map map = new HashMap();
  map.put("name", "hollis");
  map.put("wechat", "Hollis");
  map.put("blog", "www.hollischuang.com");
  ```

- 其他擦除  

  ```java
  public static <A extends Comparable<A>> A max(Collection<A> xs) {
      Iterator<A> xi = xs.iterator();
      A w = xi.next();
      while (xi.hasNext()) {
          A x = xi.next();
          if (w.compareTo(x) < 0)
              w = x;
      }
      return w;
  }
  //擦除后变成
   public static Comparable max(Collection xs){
      Iterator xi = xs.iterator();
      Comparable w = (Comparable)xi.next();
      while(xi.hasNext())
      {
          Comparable x = (Comparable)xi.next();
          if(w.compareTo(x) < 0)
              w = x;
      }
      return w;
  }
  ```

- 小结

  - 虚拟机中并不存在泛型，泛型类没有自己独有的Class类对象，即不存在List<String>.class 或是 List<Integer>.class ，而只有List.class
  - 虚拟机中，只有普通类和普通方法，所有泛型类的类型参数，在编译时都会被擦除

### 自动装箱与拆箱

- 装箱过程，通过调用**包装器的valueOf**方法实现的，而拆箱过程，则是通过调用**包装器的xxxValue**方法实现的

- 自动装箱

  ```java
   public static void main(String[] args) {
      int i = 10;
      Integer n = i;
  }
  //反编译后的代码
  public static void main(String args[])
  {
      int i = 10;
      Integer n = Integer.valueOf(i);
  }
  ```

- 自动拆箱  

  ```java
  public static void main(String[] args) {
  
      Integer i = 10;
      int n = i;
  }
  //反编译后的代码
  public static void main(String args[])
  {
      Integer i = Integer.valueOf(10);
      int n = i.intValue(); //注意，是intValue，不是initValue
  }
  ```

  

### 可变长参数



### 枚举

### 内部类

### 条件编译

### 断言

### 数值字面量

### for-each

### try-with-resource

### Lambda表达式

## 可能遇到的坑

### 泛型

### 自动装箱与拆箱

### 增强for循环

