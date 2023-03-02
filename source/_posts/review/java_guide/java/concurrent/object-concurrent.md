---
title: ly03121ly对象内存布局和对象头
description: 对象内存布局和对象头
categories:
  - 学习
tags:
  - '复习'
  - '复习-javaGuide'
  - '复习-javaGuide-并发'
date: 2022-10-30 16:56:16
updated: 2022-10-30 18:56:16
---



## 对象布局

- **heap** （**where**）: **new (eden ,s0 ,s1) ,old, metaspace**

- 对象的构成元素（what）
  HotSpot虚拟机里，对象在**堆内存中的存储布局**分为三个部分
  ![image-20221030175640211](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030175640211.png)
  - 对象头（Header）
    - **对象标记 MarkWord**
    - **类元信息**（类型指针 Class Pointer，指向方法区的地址）
    - 对象头多大 **length**（数组才有）
  - 实例数据（Instance Data）
  - 对其填充（Padding，保证整个对象大小，是8个字节的倍数）

### 对象头

- 对象标记 
    > 1. Object o= new Object(); //new一个对象，占内存多少 
    > 2. o.hashCode() //hashCode存在对象哪个地方
    > 3. synchronized(o){ }  //对象被锁了多少次（可重入锁）
    > 4. System.gc(); //躲过了几次gc（次数）

    上面这些，**哈希码**、**gc标记**、**gc次数**、**同步锁标记**、**偏向锁持有者**，都保存在**对象标记**里面
    ![image-20221030175315204](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030175315204.png)

    1. 如果在64位系统中，对象头中，**mark word（对象标记）**占用8个字节（64位）；**class pointer（类元信息）**占用8个字节，总共16字节（忽略压缩指针）
    2. 无锁的时候，
       ![image-20221030172439113](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030172439113.png)

- 类型指针
    注意下图，指向方法区中（模板）的地址
    ![image-20221030173518629](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030173518629.png)

### 实例数据和对齐填充

- 实例数据
  
- 用来存放类的属性（Filed）数据信息，包括父类的属性信息
  
- 对齐填充
  
- 填充到长度为8字节，因为虚拟机要求**对象起始地址必须是8字节的整数倍**（对齐填充不一定存在）
  
- 示例

  ```java
  class Customer{
      int id;//4字节
      boolean flag=false; //1字节
  }
  //Customer customer=new Customer();
  //该对象大小：对象头（对象标记8+类型指针8）+实例数据（4+1）=21字节 ===> 为了对齐填充，则为24字节
  ```


### 源码查看

![image-20221030175807777](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030175807777.png)

## 具体的（64位虚拟机为主）

![image-20221030180026580](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030180026580.png)

1. 无锁和偏向锁的锁标志位(最后2位)都是01
   - 无锁的倒数第3位，为0，表示非偏向锁
   - 偏向锁的倒数第3位，为1，表示偏向锁
2. 轻量级锁的锁标志位（最后2位）是00
3. 重量级锁的锁标志位（最后2位）是10
4. GC标志（最后2位）是11

如上所示，对象**分代年龄4位**，即**最大值为15**（十进制）

源码中  
![image-20221030180821194](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030180821194.png)

## 使用代码演示上述理论（JOL)

```xml
<!--引入依赖，用来分析对象在JVM中的大小和分布-->
<dependency>
    <groupId>org.openjdk.jol</groupId>
    <artifactId>jol-core</artifactId>
    <version>0.16</version>
</dependency>
```

//使用

```java
//VM的细节详细情况
System.out.println(VM.current().details());
//所有对象分配字节都是8的整数倍
System.out.println(VM.current().objectAlignment());
/* 输出：
# Running 64-bit HotSpot VM.
# Using compressed oop with 3-bit shift.
# Using compressed klass with 3-bit shift.
# Objects are 8 bytes aligned.
# Field sizes by type: 4, 1, 1, 2, 2, 4, 4, 8, 8 [bytes]
# Array element sizes: 4, 1, 1, 2, 2, 4, 4, 8, 8 [bytes]

8
*/
```

- 简单的情形
  注意，下面的**8   4        (object header: class)    0xf80001e5**，由于开启了类型指针压缩，只用了4个字节

  ```java
  public class Hello4 {
      public static void main(String[] args) throws InterruptedException {
          Object o = new Object();
          System.out.println(ClassLayout.parseInstance(o).toPrintable()); //16字节
          Customer customer = new Customer();
          System.out.println(ClassLayout.parseInstance(customer).toPrintable()); //16字节
      }
  }
  class Customer{ }
  /*输出
  java.lang.Object object internals:
  OFF  SZ   TYPE DESCRIPTION               VALUE
    0   8        (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
    8   4        (object header: class)    0xf80001e5
   12   4        (object alignment gap)    
  Instance size: 16 bytes
  Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
  
  com.ly.Customer object internals:
  OFF  SZ   TYPE DESCRIPTION               VALUE
    0   8        (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
    8   4        (object header: class)    0xf800cc94
   12   4        (object alignment gap)    
  Instance size: 16 bytes
  Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
  
  
  Process finished with exit code 0
  
  */
  ```

- 带有实例数据

  ```java
  public class Hello4 {
      public static void main(String[] args) throws InterruptedException { 
          Customer customer = new Customer();
          System.out.println(ClassLayout.parseInstance(customer).toPrintable()); //16字节
      }
  }
  class Customer{
      private int a;
      private boolean b;
  }
  /*输出
  com.ly.Customer object internals:
  OFF  SZ      TYPE DESCRIPTION               VALUE
    0   8           (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
    8   4           (object header: class)    0xf800cc94
   12   4       int Customer.a                0
   16   1   boolean Customer.b                false
   17   7           (object alignment gap)    
  Instance size: 24 bytes
  Space losses: 0 bytes internal + 7 bytes external = 7 bytes total
  */
  ```

- java 运行中添加参数 -XX:MaxTenuringThreshold = 16 ，则会出现下面错误，即分代gc最大年龄为15
  ![image-20221030184043505](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030184043505.png)

- 压缩指针的相关说明

  - 使用 java -XX:+PrintComandLineFlags -version ，打印参数

    ![image-20221030184523659](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221030184523659.png)
    其中有一个, **-XX:+UseCompressedClassPointers** ，即开启了**类型指针压缩**，只需要**4字节**

  - 当使用了**类型指针压缩**（默认）时，一个无任何属性对象是 **8字节(markWord)** + **4字节（classPointer)** + **4字节(对齐填充)** = **16字节**

  - 下面代码，使用了 ```-XX:-UseCompressedClassPointers```进行关闭压缩指针
    一个无任何属性对象是 8字节(markWord) + 8字节（classPointer) = 16字节

    ```java
    public class Hello4 {
        public static void main(String[] args) throws InterruptedException {
            Object o = new Object();
            System.out.println(ClassLayout.parseInstance(o).toPrintable()); //16字节 //16字节
        }
    }
    /*输出
    java.lang.Object object internals:
    OFF  SZ   TYPE DESCRIPTION               VALUE
      0   8        (object header: mark)     0x0000000000000001 (non-biasable; age: 0)
      8   8        (object header: class)    0x000000001dab1c00
    Instance size: 16 bytes
    Space losses: 0 bytes internal + 0 bytes external = 0 bytes total
    */
    ```