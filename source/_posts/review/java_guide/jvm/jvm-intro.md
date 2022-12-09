---
title: jvm-intro
description: jvm-intro
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-09 08:48:22
updated: 2022-12-09 08:48:22
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!
>
> 原文地址： https://juejin.im/post/5e1505d0f265da5d5d744050#heading-28  

# JVM的基本介绍

- JVM，JavaVirtualMachine的缩写，虚拟出来的计算机，通过在实际的计算机上**仿真模拟**各类计算机功能实现
- JVM类似一台小电脑，运行在windows或者linux这些**真实操作系统环境下**，**直接**和操作系统交互，**与硬件不直接交互**，操作系统帮我们完成和硬件交互的工作

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/d947f91e44c44c6c80222b49c2dee859-new-image19a36451-d673-486e-9c8e-3c7d8ab66929.png)

## Java文件是如何运行的

场景假设：我们写了一个HelloWorld.java，这是一个文本文件。JVM不认识文本文件，所以**需要一个编译**，让其(xxx.java)成为一个**JVM会读的二进制文件---> HelloWorld.class**

1. 类加载器
   如果JVM想要执行这个.class文件，需要将其**(这里应该指的二进制文件)**装进**类加载器**中，它就像一个搬运工一样，会把所有的.class文件全部搬进JVM里面
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/81f1813f371c40ffa1c1f6d78bc49ed9-new-image28314ec8-066f-451e-8373-4517917d6bf7.png)

2. 方法区

   > 类加载器将.class文件搬过来，就是先丢到这一块上  

   方法区是用于**存放类似于元数据信息方面的数据**的，比如**类信息**、**常量**、**静态变量**、**编译后代码**...等

3. 堆
   堆主要放一些**存储的数据**，比如**对象实例**、**数组**...等，它和**方法区**都同属于**线程共享区域**，即它们都是**线程不安全**的

4. 栈

   线程独享  
   栈是我们**代码运行空间**，我们编写的**每一个方法**都会放到**栈**里面运行。  
   名词：**本地方法栈**或**本地方法接口**，不过我们基本不会涉及这两块内容，这**两底层使用C**进行工作，**和Java没有太大关系**

5. 程序计数器
   主要就是完成一个加载工作，类似于一个指针一样的，**指向下一行我们需要执行的代码**。和栈一样，都是**线程独享**的，就是**每一个线程都会自己对应的一块区域**而不会存在并发和多线程问题。

6. 小总结
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/897863ee5ecb4d92b9119d065f468262-new-imagef7287f0b-c9f0-4f22-9eb4-6968bbaa5a82.png)

   1. Java文件经过编译后编程.class字节码文件
   2. 字节码文件通过类加载器被搬运到 JVM虚拟机中
   3. 虚拟机主要的5大块：**方法区、堆** 都为**线程共享**区域，有线程安全问题；**栈**和**本地方法栈**和**计数器**都是**独享**区域，不存在线程安全问题，而JVM的调优主要就是围绕**堆**、**栈**两大块进行

## 简单的代码例子

一个简单的学生类及main方法:  

```java
public class Student {
    public String name;

    public Student(String name) {
        this.name = name;
    }

    public void sayName() {
        System.out.println("student's name is : " + name);
    }
}
```

main方法：  

```java
public class App {
    public static void main(String[] args) {
        Student student = new Student("tellUrDream");
        student.sayName();
    }
}
```

★★ 执行main方法的步骤如下  

1. 编译好App.java后得到App.class后，执行APP.class，**系统会启动一个JVM进程**，从**classpath类路径中找到一个名为APP.class的二进制文件**，将**APP的类信息加载到运行时数据区的方法区**内，这个过程叫做**APP类的加载**
2. JVM找到**APP的主程序入口**，**执行main**方法
3. 这个main的第一条语句**(指令)**为 ```Student student = new Student("tellUrDream")```，就是让JVM创建一个Student对象，但是这个时候方法区是没有Student类的信息的，所以JVM马上加载Student类，**把Student类的信息放到方法区中**
4. 加载完Student类后，**JVM在堆中为一个新的Student实例分配内存**，然后**调用构造函数初始化Student实例**，这个Student实例**(对象)**持有**指向方法区中的Student类的类型信息**的引用
5. 执行```student.sayName;```时，JVM根据student的引用**找到student对象**，然后根据student对象**持有的引用**定位到**方法区中student类的类型信息的方法表**，获得**sayName()的字节码地址**。
6. 执行sayName()

其实也不用管太多，只需要知道**对象实例初始化时**，会**去方法区中找到类信息**（没有的话先加载），完成后再到**栈那里去运行方法**

# 类加载器的介绍

**类加载器**负责**加载.class**文件，.class文件的开头会有**特定的文件标识**，将**class文件字节码内容**加载到内存中，并**将这些内容**转换成**方法区**中的**运行时数据结构**，并且ClassLoader只**负责class文件的加载**，而能否运行则由**Execution Engine**来决定

## 类加载器的流程

从**类被加载到虚拟机内存**中开始，到**释放内存**总共有7个步骤：  
**加载**，**验证**，**准备**，**解析**，**初始化**，**使用**，**卸载**。  
其中**验证**，**准备**，**解析**三个部分统称为**链接**

### 加载

1. 将class文件**加载到内存**
2. 将**静态数据结构**转化成**方法区中运行的数据结构**
3. 在**堆**中生成一个代表这个类的**java.lang.Class对象**作为数据访问的入口

### 链接

1. 验证：确保加载的类**符合JVM规范和安全**，保证**被校验类的方法**在运行时不会做出**危害虚拟机**的事件，其实就是一个**安全检查**
2. 准备：为**static变量**在**方法区分配内存空间**，**设置**变量的**初始值**，例如```static int = 3 ```（注意：准备阶段只设置**类中的静态变量**（**方法区**中），**不包括实例变量（堆内存中）**，实例变量是**对象初始化时赋值的**）
3. 解析：虚拟机将**常量池内的符号引用**，替换为**直接引用**的过程

### 初始化

### 卸载

## 类加载器的加载顺序

## 双亲委派机制

# 运行时数据区

## 本地方法栈和程序计数器

## 方法区

## 虚拟机栈和虚拟机堆

## 垃圾回收算法

## （了解）各种各样的垃圾回收器

## （了解） JVM的常用参数

# 关于JVM调优的一些方面

## 调整最大堆内存和最小堆内存

## 调整新生代和老年代的比值

## 调整Survivor区和Eden区的比值

## 设置年轻代和老年代的大小

## 小总结

## 永久区的设置

## JVM的栈参数调优

# finally