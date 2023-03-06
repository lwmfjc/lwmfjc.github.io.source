---
title: 类加载器详解
description: 类加载器详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-17 22:39:21
updated: 2022-12-18 08:23:215
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 回顾一下类加载过程

- 类加载过程：**加载**->**连接**->**初始化**，连接又分为**验证** - > **准备** -> **解析**
  ![image-20221217225702126](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221217225702126.png)
- 一个**非数组类的加载阶段**（加载阶段**获取类的二进制字节流**的动作）是可控性最强的阶段，这一步我们可以去**自定义类加载器**去**控制字节流的获取方式**（**重写一个类加载器的 `loadClass()` 方法**）
- **数组类型不通过类加载器创建**，它**由 Java 虚拟机直接创建**。
- 所有的类都**由类加载器**加载，加载的作用就是将 **`.class`文件加载到内存**。

# 类加载器总结

JVM 中内置了**三个重要的 ClassLoader**，除了 **BootstrapClassLoader** ，**其他类加载器均由 Java 实现**且全部**继承自`java.lang.ClassLoader`**：

1. **BootstrapClassLoader(启动类加载器)** ：最顶层的加载类，由 C++实现，负责加载 **`%JAVA_HOME%/lib`**目录下的 jar 包和类或者被 **`-Xbootclasspath`**参数指定的路径中的所有类。
2. **ExtensionClassLoader(扩展类加载器)** ：主要负责加载 **`%JRE_HOME%/lib/ext`** 目录下的 jar 包和类，或被 **`java.ext.dirs` 系统变量**所指定的路径下的 jar 包
3. **AppClassLoader(应用程序类加载器)** ：面向我们用户的加载器，负责加载**当前应用 classpath** 下的**所有 jar 包和类**。

#  双亲委派模型

## 双亲委派模型介绍

- **每个类**都有一个对应它的类加载器。**系统中**的Class Loader在协同工作的时候，会默认使用**双亲委派模型**。

  1. 在类加载的时候（之前），系统会判断当前类**是否被加载过**，**已经被加载**的类会**直接返回**，否则才会尝试加载
  2. 加载的时候，首先会把该请求**委派给父类加载器**的loadClass()处理，因此所有的请求**最终**都应该传送到顶层的**启动类加载器BootstrapClassLoader**中。  
     - 当**父类加载器无法处理**时，才由自己来处理。  
     - 当父类加载器为null时，会启动**类加载器BootstrapClassLoader**作为父类加载器

  ![image-20221218080551631](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221218080551631.png)

- 每个类加载，**都有一个父类加载器**，使用例子验证

  ```java
  public class ClassLoaderDemo {
      public static void main(String[] args) {
          System.out.println("ClassLodarDemo's ClassLoader is " + ClassLoaderDemo.class.getClassLoader());
          System.out.println("The Parent of ClassLodarDemo's ClassLoader is " + ClassLoaderDemo.class.getClassLoader().getParent());
          System.out.println("The GrandParent of ClassLodarDemo's ClassLoader is " + ClassLoaderDemo.class.getClassLoader().getParent().getParent());
      }
  }
  /*--Output--
  ClassLodarDemo's ClassLoader is sun.misc.Launcher$AppClassLoader@18b4aac2
  The Parent of ClassLodarDemo's ClassLoader is sun.misc.Launcher$ExtClassLoader@1b6d3586
  The GrandParent of ClassLodarDemo's ClassLoader is null 
  */
  ```

  **AppClassloader的父类加载器**为**ExtClassloader**，**ExtClassloader的父类加载器**为**null**，**null不代表ExtClassLoader没有父类加载器**，而是**BootstrapClassloader**。

- 其实这个双亲翻译的容易让别人误解，我们一般理解的双亲都是父母，**这里的双亲更多地表达的是“父母这一辈”的人而已**，并不是说真的有一个 Mother ClassLoader 和一个 Father ClassLoader 。另外，**类加载器之间的“父子”关系**也**不是通过继承**来**体现(定义)**的，**是由“优先级”**来决定。官方 API 文档对这部分的描述如下:

  > The Java platform uses a delegation model for loading classes. **The basic idea is that every class loader has a "parent" class loader.** When loading a class, a class loader **first "delegates" the search for the class to its parent class loader before attempting to find the class itself(优先级)**.

## 双亲委派模型实现源码分析

双亲委派模型的逻辑清晰，代码简单，集中在```java.lang.ClassLoader```的loadClass()中  

```java
private final ClassLoader parent;
protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
    {
        synchronized (getClassLoadingLock(name)) {
            // 首先，检查请求的类是否已经被加载过
            Class<?> c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                try {
                    if (parent != null) {//父加载器不为空，调用父加载器loadClass()方法处理
                        //注意，这里是一层层抛上去，有点类似把方法放进栈，然后如果BootstrapClassLoader加载不了，就会抛异常，由自己加载（如果自己加载不了，还是会抛异常，然后再次加载权回到子类）
                        c = parent.loadClass(name, false);
                    } else {//父加载器为空，使用启动类加载器 BootstrapClassLoader 加载
                        c = findBootstrapClassOrNull(name);
                    }
                } catch (ClassNotFoundException e) {
                   //抛出异常说明父类加载器无法完成加载请求
                }

                if (c == null) {
                    long t1 = System.nanoTime();
                    //自己尝试加载
                    c = findClass(name);

                    // this is the defining class loader; record the stats
                    sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                    sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                    sun.misc.PerfCounter.getFindClasses().increment();
                }
            }
            if (resolve) {
                resolveClass(c);
            }
            return c;
        }
    } 
```



## 双亲委派模型的好处

1. 双亲委派模型保证了 Java 程序的稳定运行，可以**避免类的重复加载**（**JVM 区分不同类的方式不仅仅根据类名，相同的类文件被不同的类加载器加载产生的是两个不同的类**），也**保证了 Java 的核心 API** 不被篡改。  
2. **如果没有**使用双亲委派模型，而是每个类加载器加载自己的话就会出现一些问题，比如我们**编写一个称为 `java.lang.Object` 类**的话，那么程序运行的时候，系统就会出现多个不同的 `Object` 类

## 如果我们不想用双清委派模型

**自定义加载器**的话，需要**继承 `ClassLoader`** 。

1. 如果我们不想打破双亲委派模型，就**重写 `ClassLoader` 类中的 `findClass()`** 方法即可，无法被父类加载器加载的类最终会通过这个方法被加载。

2. 但是，如果想**打破双亲委派模型**则需要**重写 `loadClass()`** 方法

   > 也就是上面"双亲委派模型实现源码分析"中的源码

# 自定义类加载器

除了 `BootstrapClassLoader` 其他类加载器均由 Java 实现且全部继承自`java.lang.ClassLoader`。如果我们要自定义自己的类加载器，很明显需要**继承 `ClassLoader`**。

# 推荐阅读