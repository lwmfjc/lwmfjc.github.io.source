---
title: unsafe类
description: unsafe类
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 17:10:27
updated: 2022-10-10 17:10
---

```sun.misc.Unsafe```

提供执行低级别、不安全操作的方法，如直接访问系统内存资源、自主管理内存资源等，效率快，但由于有了操作内存空间的能力，会增加指针问题风险。且这些功能的实现依赖于本地方法，Java代码中只是声明方法头，具体实现规则交给本地代码
![image-20221010172203732](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221010172203732.png)

### 为什么要使用本地方法

- 需要用到Java中不具备的依赖于操作系统的特性，跨平台的同时要实现对底层控制
- 对于其他语言已经完成的现成功能，可以使用Java调用
- 对时间敏感/性能要求非常高，有必要使用更为底层的语言

对于同一本地方法，不同的操作系统可能通过不同的方式来实现的

### Unsafe创建

sun.misc.Unsafe部分源码

```java
public final class Unsafe {
  // 单例对象
  private static final Unsafe theUnsafe;
  ......
  private Unsafe() {
  }
    
  //Sensitive : 敏感的 英[ˈsensətɪv]
  @CallerSensitive
  public static Unsafe getUnsafe() {
    Class var0 = Reflection.getCallerClass();
    // 仅在引导类加载器`BootstrapClassLoader`加载时才合法
    if(!VM.isSystemDomainLoader(var0.getClassLoader())) {
      throw new SecurityException("Unsafe");
    } else {
      return theUnsafe;
    }
  }
}
```

会先判断当前类是否由Bootstrap classloader加载。即只有启动类加载器加载的类才能够调用Unsafe类中的方法

如何使用```Unsafe```这个类  

1. 利用反射获得Unsafe类中已经实例化完成的单例对象```theUnsafe```

   ```java
   private static Unsafe reflectGetUnsafe() {
       try {
         Field field = Unsafe.class.getDeclaredField("theUnsafe");
         field.setAccessible(true);
         return (Unsafe) field.get(null);
       } catch (Exception e) {
         log.error(e.getMessage(), e);
         return null;
       }
   }
   ```

2. 通过Java命令行命令```-Xbootclasspath/a```把调用Unsafe相关方法的类A所在jar包路径追加到默认的bootstrap路径中，使得A被引导类加载器加载

   ```java
   java -Xbootclasspath/a: ${path}   // 其中path为调用Unsafe相关方法的类所在jar包路径
   ```

### Unsafe功能

内存操作、内存屏障、对象操作、数据操作、CAS操作、线程调度、Class操作、系统信息

#### 内存操作

#### 内存屏障

#### 对象操作

#### 数据操作

#### CAS操作

#### 线程调度

#### Class操作

#### 系统信息