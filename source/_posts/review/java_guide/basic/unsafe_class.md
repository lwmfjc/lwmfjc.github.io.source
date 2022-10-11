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

相关方法:  

```java
//分配新的本地空间
public native long allocateMemory(long bytes);
//重新调整内存空间的大小
public native long reallocateMemory(long address, long bytes);
//将内存设置为指定值
public native void setMemory(Object o, long offset, long bytes, byte value);
//内存拷贝
public native void copyMemory(Object srcBase, long srcOffset,Object destBase, long destOffset,long bytes);
//清除内存
public native void freeMemory(long address);
```

测试：  

```java
private void memoryTest() {
    int size = 4;
    long addr = unsafe.allocateMemory(size);
    long addr3 = unsafe.reallocateMemory(addr, size * 2);
    System.out.println("addr: "+addr);
    System.out.println("addr3: "+addr3);
    try {
        //向每个字节，写入1 首先使用allocateMemory方法申请 4 字节长度的内存空间，在循环中调用setMemory方法向每个字节写入内容为byte类型的 1
        unsafe.setMemory(null,addr ,size,(byte)1);
        for (int i = 0; i < 2; i++) {
            unsafe.copyMemory(null,addr,null,addr3+size*i,4);
        }
        System.out.println(unsafe.getInt(addr));
        System.out.println(unsafe.getLong(addr3));
    }finally {
        unsafe.freeMemory(addr);
        unsafe.freeMemory(addr3);
    }
}
//结果
addr: 2433733895744
addr3: 2433733894944
16843009
72340172838076673
```

对于setMemory的解释 [来源](https://www.cnblogs.com/throwable/p/9139947.html)

```java
public native void setMemory(Object o, long offset, long bytes, byte value); 将给定内存块中的所有字节设置为固定值(通常是0)。内存块的地址由对象引用o和偏移地址共同决定，如果对象引用o为null，offset就是绝对地址。第三个参数就是内存块的大小，如果使用allocateMemory进行内存开辟的话，这里的值应该和allocateMemory的参数一致。value就是设置的固定值，一般为0(这里可以参考netty的DirectByteBuffer)。一般而言，o为null，所有有个重载方法是public native void setMemory(long offset, long bytes, byte value);，等效于setMemory(null, long offset, long bytes, byte value);。
```



分析：

> 分析一下运行结果，首先使用`allocateMemory`方法申请 4 字节长度的内存空间，在循环中调用`setMemory`方法向每个字节写入内容为`byte`类型的 1，当使用 Unsafe 调用`getInt`方法时，因为一个`int`型变量占 4 个字节，会一次性读取 4 个字节，组成一个`int`的值，对应的十进制结果为 16843009。

#### 内存屏障

#### 对象操作

#### 数据操作

#### CAS操作

#### 线程调度

#### Class操作

#### 系统信息