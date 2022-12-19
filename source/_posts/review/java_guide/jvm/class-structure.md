---
title: 类文件结构
description: 类文件结构
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-18 08:24:36
updated: 2022-12-18 09:03:36
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 概述

- Java中，JVM可以理解的代码就叫做**字节码**（即扩展名为.class的文件），它不面向任何特定的处理器，只**面向虚拟机**
- Java语言通过**字节码**的方式，在一定程度上解决了**传统解释型语言执行效率低**的问题，同时又保留了**解释型语言**可移植的特点。所以Java程序运行时**效率极高**，且由于字节码并不针对一种特定的**机器**。因此，Java程序无需重新编译便可在**多种不通操作系统的计算机**运行
- Clojure（Lisp 语言的一种方言）、Groovy、Scala 等语言都是运行在 Java 虚拟机之上。下图展示了**不同的语言被不同的编译器**编译**成`.class`**文件**最终运行在 Java 虚拟机**之上。**`.class`文件的二进制格式**可以使用 [WinHexopen in new window](https://www.x-ways.net/winhex/) 查看。

![image-20221218224536987](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221218224536987.png)

.class文件是不同语言在**Java虚拟机**之间的重要桥梁，同时也是**支持Java跨平台**很重要的一个原因

# Class文件结构总结

根据Java虚拟机规范，Class文件通过**ClassFile**定义，有点类似C语言的**结构体**

ClassFile的结构如下：  

```java
ClassFile {
    u4             magic; //Class 文件的标志
    u2             minor_version;//Class 的小版本号
    u2             major_version;//Class 的大版本号
    u2             constant_pool_count;//常量池的数量
    cp_info        constant_pool[constant_pool_count-1];//常量池
    u2             access_flags;//Class 的访问标记
    u2             this_class;//当前类
    u2             super_class;//父类
    u2             interfaces_count;//接口
    u2             interfaces[interfaces_count];//一个类可以实现多个接口
    u2             fields_count;//Class 文件的字段属性
    field_info     fields[fields_count];//一个类可以有多个字段
    u2             methods_count;//Class 文件的方法数量
    method_info    methods[methods_count];//一个类可以有个多个方法
    u2             attributes_count;//此类的属性表中的属性数
    attribute_info attributes[attributes_count];//属性表集合
} 
```

![image-20221218230117020](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221218230117020.png)

通过IDEA插件jclasslib查看，可以直观看到```Class 文件结构```

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20210401170711475.png)

使用jclasslib不光能直观地查看某个类对应的字节码文件，还可以查看**类的基本信息**、**常量池**、**接口**、**属性**、**函数**等信息  
下面介绍一下Class文件结构涉及到的一些组件

## 魔数（Magic Number）

```java
    u4             magic; //Class 文件的标志
```

每个Class文件的**头4个字节**称为**魔数（Magic Number）**，它的唯一作用是确定这个文件**是否为一个能被虚拟机接收的Class文件**  

> 程序设计者很多时候都喜欢用一些**特殊的数字**表示**固定的文件类型**或者**其它特殊的含义**。  
>
> 这里前两个字节是```cafe 英[ˈkæfeɪ]```，后两个字节 ```babe 英[beɪb]```

JAVA为 CA FE BA BE，十六进制(一个英文代表4位，即2个英文字母为1字节）

## Class文件版本号（Minor&Major Version）

```java
    u2             minor_version;//Class 的小版本号
    u2             major_version;//Class 的大版本号
```

前4个字节存储**Class 文件的版本号**：**第5位**和**第6位**是**次版本号**，**第7位**和**第8位**是**主版本号**。
比如Java1.8 为```00 00 00 34 ```  

```java
JDK1.8 = 52
JDK1.7 = 51
JDK1.6 = 50
JDK1.5 = 49
JDK1.4 = 48
```

如图，下图是在java8中编译的，使用```javap -v ```查看
每当Java发布大版本（比如Java8 ，Java9 ）的时候，主版本号都会+1

![image-20221219103843623](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219103843623.png)

> 注：**高版本**的 Java 虚拟机**可以执行低版本编译器**生成的 Class 文件，但是**低版本**的 Java 虚拟机**不能执行高版本编译器**生成的 Class 文件。所以，我们在实际开发的时候要**确保开发的的 JDK 版本和生产环境的 JDK 版本保持一致**

## 常量池（Constant Pool）

```java
    u2             constant_pool_count;//常量池的数量
    cp_info        constant_pool[constant_pool_count-1];//常量池 
```

主次版本号之后的是**常量池**，常量池数量为```constant_pool_count -1 ```

> （**常量池计数器是从 1 开始计数的，将第 0 项常量空出来是有特殊考虑的，索引值为 0 代表“不引用任何一个常量池项”**）

常量池主要包括**两大常量**：**字面量**和**符号引用**。

1. 字面量比较接近于Java语言层面的**常量概念**，如**文本字符串**、**声明为final的常量值**等

   > 注意，**非常量**是不会在这里的，
   > ![image-20221219105146588](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219105146588.png)
   >
   > 没有找到3 

2. 符号引用则属于**编译原理**方面的概念，包括下面三类**常量**

   1. **类和接口**的全限定名
   2. **字段**的名称和描述符
   3. **方法**的名称和描述符

常量池中的**每一项常量都是一个表**，这14种表有一个共同特点：**开始第一位**是一个**u1类型的标志位 -tag **来标识常量的类型，代表当前这个常量**属于哪种常量类型**

![image-20221219105523632](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219105523632.png)

`.class` 文件可以通过`javap -v class类名` 指令来看一下其常量池中的信息(`javap -v class类名-> temp.txt` ：将结果输出到 temp.txt 文件)。

## 访问标志（Access Flag）

常量池结束后，紧接着**两个字节**代表访问标志，这个标志用于识别一些**类**或者**接口** **层次**的访问信息，包括  
这个Class是**类**还是**接口**，是否为**public**或者**abstract**类型，如果是类的话是否声明为**final**等等

**类访问和属性**修饰符  
![image-20221219111039047](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221219111039047.png)

> ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1090617-20190409135129522-1831389208.jpg)
>
> 上图转自： https://www.cnblogs.com/qdhxhz/p/10676337.html 

其实是所有值相加，所以对于 ```public interface A ```，是0x601 ，即 ```0x200 + 0x400 + 0x001```

对于 ```public final class MyEntity extends MyInterface```即```0x31```：```0x0001 + 0x0010 + 0x0020```

再举个例子：  

```java
package top.snailclimb.bean;
public class Employee {
   ...
}

```

通过 ```javap -v class类名```指令来看一下类的访问标志  
![查看类的访问标志](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/%25E6%259F%25A5%25E7%259C%258B%25E7%25B1%25BB%25E7%259A%2584%25E8%25AE%25BF%25E9%2597%25AE%25E6%25A0%2587%25E5%25BF%2597.png)

## 当前类（This Class）、父类（Super Class）、接口（Interfaces）索引集合



## 字段表集合 （Fields）

## 方法表集合（Methods）

## 属性表集合（Attributes）