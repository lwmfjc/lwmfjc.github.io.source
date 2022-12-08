---
title: memory-area
description: memory-area
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-12-07 13:49:39
updated: 2022-12-07 13:49:39
---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!
>
> 如果没有特殊说明，针对的都是HotSpot虚拟机

# 前言

- 对于Java程序员，虚拟机自动管理机制，不需要像C/C++程序员为每一个new 操作去写对应的delete/free 操作，不容易出现**内存泄漏** 和 **内存溢出**问题
- 但由于内存控制权交给Java虚拟机，一旦出现内存泄漏和溢出方面问题，如果不了解虚拟机是怎么样使用内存，那么很难**排查任务**

# 运行时数据区域

**Java虚拟机**在执行Java程序的过程中，会把它管理的内存，**划分成若干个**不同的数据区域

JDK1.8之前：

1. 线程共享
   堆，方法区【永久代】(包括运行时常量池)
2. 线程私有
   虚拟机栈、本地方法栈、程序计数器
3. 本地内存(包括直接内存)

![image-20221208144045407](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221208144045407.png)

JDK1.8之后：  
![Java 运行时数据区域（JDK1.8 之后）](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/java-runtime-data-areas-jdk1.8.png)
1.8之后整个永久代改名叫"元空间"，且移到了本地内存中



规范（概括）：  
**线程私有**：程序计数器，虚拟机栈，本地方法栈

**线程共享**：堆，方法区，直接内存（非运行时数据区的一部分）

> Java虚拟机规范对于运行时数据区域的规定是相当宽松的，以堆为例：
>
> 1. 堆可以是连续，也可以不连续
> 2. 大小可以固定，也可以运行时按需扩展
> 3. 虚拟机实现者可以使用任何**垃圾回收算法管理堆**，设置不进行垃圾收集

## 程序计数器

- 是一块较小内存空间，看作是**当前线程所执行的字节码**的**行号指示器**

- 字节码解释器，工作时通过**改变这个计数器的值**来选取下一条需要执行的**字节码指令**

  > 分支、循环、跳转、异常处理、线程恢复等功能都需要依赖这个计数器

- 而且，为了**线程切换后恢复到正确执行位置**，每条线程需要一个独立程序计数器，各线程计数器互不影响，独立存储，我们称这类内存区域为**"线程私有"**的内存

- 总结，**程序计数器**的作用

  - 字节码解释器通过**改变程序计数器来依次读取指令**，从而实现代码的流程控制
  - 多线程情况下，**程序计数器用于记录当前线程执行的位置**，从而当线程被切回来的时候能够知道该线程上次运行到哪

  > 程序计数器是唯一一个不会出现OutOfMemoryError的内存区域，它的生命周期随线程创建而创建，线程结束而死亡

## Java虚拟机栈

- Java虚拟机栈，**简称"栈"**，也是线程私有的，生命周期和线程相同，随线程创建而创建，线程死亡而死亡
- 除了**Native方法**调用的是**通过本地方法栈实现**的，其他所有的Java方法调用都是通过**栈**来实现的（需要和其他运行时数据区域比如**程序计数器**配合）
- **方法调用的数据**需要通过栈进行**传递**，**每一次方法调用**都会有一个对应的**栈帧被压入栈**，每一个**方法调用结束后**，都会有一个**栈帧被弹出**。
- 栈由一个个栈帧组成，每个栈帧包括**局部变量表**、**操作数栈**、**动态链接**、**方法返回地址**。
  栈为**先进后出**，且只支持**出栈**和**入栈**

![Java 虚拟机栈](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/stack-area.png)

- 局部变量表：存放**编译器可知**的各种**数据类型**(boolean、byte、char、short、int、float、long、double)、对象引用(reference 类型，不同于对象本身，可能是一个指向对象起始地址的引用指针，也可能是一个**指向一个代表对象的句柄或其他与此对象相关的位置**)
  ![局部变量表](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/local-variables-table.png)

- 操作数栈  作为方法调用的**中转站**使用，用于存放方法执行过程中产生的**中间计算结果**。计算过程中产生的临时变量也放在操作数栈中

- 动态链接  主要服务**一个方法需要调用其他方法**的场景。

  > 在 Java 源文件被编译成字节码文件时，所有的变量和方法引用都作为符号引用（Symbilic Reference）保存在 Class 文件的常量池里。当一个方法要调用其他方法，需要将常量池中指向方法的符号引用转化为其在内存地址中的直接引用。动态链接的作用就是为了将符号引用转换为调用方法的直接引用。

  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/jvmimage-20220331175738692.png)

- 如果函数调用陷入**无限循环**，会导致栈中被压入太多栈帧而占用太多空间，导致**栈空间过深**。当**线程请求栈的深度超过当前Java虚拟机栈的最大深度**时，就会抛出**StackOverError**错误

- Java 方法有两种返回方式，一种是 return 语句正常返回，一种是抛出异常。不管哪种返回方式，都会导致栈帧被弹出。也就是说， **栈帧随着方法调用而创建，随着方法结束而销毁。无论方法正常完成还是异常完成都算作方法结束。**

- 除了 `StackOverFlowError` 错误之外，栈还可能会出现`OutOfMemoryError`错误，这是因为如果**栈的内存大小可以动态扩展**， 如果虚拟机在**动态扩展栈时无法申请到足够的内存空间**，则抛出**`OutOfMemoryError`**异常。

- 总结，程序运行中栈可能出现的两种错误

  - **StackOverFlowError**：若**栈的内存大小不允许动态扩展**，那么当**线程请求栈的深度超过当前 Java 虚拟机栈的最大深度**的时候，就抛出 `StackOverFlowError` 错误。
  - **`OutOfMemoryError`：** 如果栈的内存大小**可以动态扩展**， 如果虚拟机在**动态扩展栈时无法申请到足够的内存空间**，则抛出`OutOfMemoryError`异常。

  > ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/%25E3%2580%258A%25E6%25B7%25B1%25E5%2585%25A5%25E7%2590%2586%25E8%25A7%25A3%25E8%2599%259A%25E6%258B%259F%25E6%259C%25BA%25E3%2580%258B%25E7%25AC%25AC%25E4%25B8%2589%25E7%2589%2588%25E7%259A%2584%25E7%25AC%25AC2%25E7%25AB%25A0-%25E8%2599%259A%25E6%258B%259F%25E6%259C%25BA%25E6%25A0%2588.f4f863a2.png)

## 本地方法栈

`和虚拟机栈作用相似`，区别：**虚拟机栈为虚拟机执行Java方法（字节码）服务，本地方法栈则为虚拟机使用到的Native方法服务**。HotSpot虚拟机中和Java虚拟机栈合二为一

> 同上，本地方法被执行时，本地方法栈会创建一个栈帧，用于存放本地方法的局部变量表、操作数栈、动态链接、出口信息
>
> 方法执行完毕后相应的栈帧也会出栈并释放内存空间，也会出现StackOverFlowError和OutOfMemoryError两种错误

## 堆

- Java虚拟机所管理的内存中最大的一块，Java堆是**所有线程共享**的一块区域，在虚拟机启动时创建

- 此内存区域唯一目的是**存放对象实例**，**几乎**所有的**对象实例及数组**，都在这里分配内存

  > “几乎”，因为随着**JIT**编译器的发展与逃逸分析技术逐渐成熟，**栈上分配**、**标量替换**导致微妙变化。从JDK1.7开始已经默认**逃逸分析**，如果某些方法的对象引用**没有被返回或者未被外面使用（未逃逸出去）**，那么对象可以**直接在栈上分配内存**。

- Java堆是**垃圾收集器**管理的主要区域，因此也称GC堆（Garbage Collected Heap）

- 现在收集器基本都采用**分代垃圾收集算法**，从垃圾回收的角度，Java堆还细分为：新生代和老年代。再细致：Eden，Survivor，Old等空间。> 目的是更好的回收内存，或更快地分配内存

- JDK7及JDK7之前，堆内存被分为三部分

  1. 新生代内存(Young Generation)，包括Eden区、两个Survivor区S0和S1【8:1:1】
  2. 老生代(Old Generation) 【新生代 : 老年代= 1: 2】
  3. 永久代(Permanent Generation)

  ![hotspot-heap-structure](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/hotspot-heap-structure.41533631.png)

- JDK8之后**PermGen（永久）**已被**Metaspace（元空间）**取代，且**元空间**使用直接内存

- 大部分情况，对象都会首先在 Eden 区域分配，在一次新生代垃圾回收后，如果对象还存活，则会进入 S0 或者 S1，并且对象的年龄还会加 1(Eden 区->Survivor 区后对象的初始年龄变为 1)，当它的年龄增加到一定程度（默认为 15 岁），就会被晋升到老年代中。

  > 对象晋升到老年代的年龄阈值，可以通过参数 `-XX:MaxTenuringThreshold` 来设置。 
  >
  >  **修正（参见：[issue552open in new window](https://github.com/Snailclimb/JavaGuide/issues/552)）** ：“Hotspot 遍历所有对象时，按照**年龄从小到大对其所占用的大小进行累积**，当**累积的某个年龄大小超过了 survivor 区的一半**时，**取这个年龄和 MaxTenuringThreshold 中更小的一个值**，作为新的晋升年龄阈值”。图解：  
  > ![image-20221208105755268](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221208105755268.png)
  >
  > ---
  >
  > 代码如下：  
  >
  > ```java
  > uint ageTable::compute_tenuring_threshold(size_t survivor_capacity) {
  > 	//survivor_capacity是survivor空间的大小
  > size_t desired_survivor_size = (size_t)((((double) survivor_capacity)*TargetSurvivorRatio)/100);
  > size_t total = 0;
  > uint age = 1;
  > while (age < table_size) {
  > total += sizes[age];//sizes数组是每个年龄段对象大小
  > if (total > desired_survivor_size) break;
  > age++;
  > }
  > uint result = age < MaxTenuringThreshold ? age : MaxTenuringThreshold;
  > 	...
  > } 
  > ```

- 堆里最容易出现OutOfMemoryError错误，出现这个错误之后的表现形式：

  1. **`java.lang.OutOfMemoryError: GC Overhead Limit Exceeded`** ： 当 JVM **花太多时间执行垃圾回收并且只能回收很少的堆空间**时，就会发生此错误。

  2. **`java.lang.OutOfMemoryError: Java heap space`** :假如在**创建新的对象**时, **堆内存中的空间不足以存放新创建的对象**, 就会引发此错误。

     > (和配置的最大堆内存有关，且受制于物理内存大小。最大堆内存可通过`-Xmx`参数配置，若没有特别配置，将会使用默认值，详见：[Default Java 8 max heap sizeopen in new window](https://stackoverflow.com/questions/28272923/default-xmxsize-in-java-8-max-heap-size))

  3. ...

## 方法区

- 方法区属于**JVM运行时数据区域**的一块**逻辑区域**，是各线程共享的内存区域

  > “逻辑”，《Java虚拟机规范》规定了有方法区这么个概念和它的作用，方法区如何实现是虚拟机的事。即，不同虚拟机实现上，方法区的实现是不同的

- 当虚拟机要使用一个类时，它需要**读取并解析Class文件获取相关信息**，再将**信息存入方法区**。方法区会存储已被虚拟机加载的**类信息、字段信息、方法信息、常量、静态变量、即时编译器编译后的代码缓存**等数据

- **方法区和永久代以及元空间有什么关系呢？**

  1. 方法区和永久代以及元空间的关系很像Java中接口和类的关系，类实现了接口，这里的类就可以看作是**永久代**和**元空间**，接口则看作是**方法区**
  2. 永久代及元空间，是HotSpot虚拟机对虚拟机规范中方法区的**两种实现方式**
  3. 永久代是JDK1.8之前的方法区实现，元空间是JDK1.8及之后方法区的实现

  ![HotSpot 虚拟机方法区的两种实现](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/method-area-implementation.png)

- 为什么将永久代（PermGen）替换成元空间（MetaSpace）呢

  > 下图来自《深入理解Java虚拟机》第3版 
  >
  > ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/20210425134508117.png)

  1. 整个永久代有一个**JVM本身设置的固定大小上限（也就是参数指定）**，无法进行调整，而元空间使用的是**直接内存**，受本机可用内存的限制。`虽然元空间仍旧可能溢出，但比原来出现的机率会更小`

     > 元空间溢出将得到错误： java.lang.OutOfMemoryError: MetaSpace

     - `-XX: MaxMetaspaceSize`设置最大元空间大小，默认为unlimited，即只受系统内存限制
     - `-XX: MetaspaceSize`调整标志定义元空间的**初始大小**，如果未指定此标志，则Metaspace将**根据运行时应用程序需求，动态地重新调整大小**。

  2. 元空间里存放的是**类的元数据**，这样加载多少**类的元数据就不由MaxPermSize控制**了，而**由系统的实际可用空间控制**，这样加载的类就更多了

  3. 在 JDK8，合并 HotSpot 和 JRockit 的代码时, JRockit 从来没有一个叫永久代的东西, 合并之后就没有必要额外的设置这么一个永久代的地方了

- 方法区常用参数有哪些
  JDK1.8之前永久代还没有被彻底移除时通过下面参数调节方法区大小  

  ```java
  -XX:PermSize=N//方法区 (永久代) 初始大小
  
  -XX:MaxPermSize=N//方法区 (永久代) 最大大小,超过这个值将会抛出 OutOfMemoryError 异常:java.lang.OutOfMemoryError: PermGen
  ```

  > 相对而言，垃圾收集行为在这个区域是比较少出现的，但**并非数据进入方法区后就“永久存在”**了。

  JDK1.7方法区(HotSpot的永久代)被移除一部分，JDK1.8时方法区被彻底移除，取而代之的是**元空间**，元空间使用直接内存，下面是常用参数  

  ```java
  -XX:MetaspaceSize=N //设置 Metaspace 的初始（和最小大小）
  -XX:MaxMetaspaceSize=N //设置 Metaspace 的最大大小
  ```

  与永久代不同，如果不指定大小，随着更多类的创建，**虚拟机会耗尽所有可用的系统内存**。

## 运行时常量池

- Class文件中除了有**类的版本**、**字段**、**方法**、**接口**等描述信息外，还有用于存放编译器期生成的**各种字面量（Literal）**和**符号引用（Symbolic Reference）**的**常量池表**
- **字面量**是源代码中的**固定值表示法**，即通过字面我们就知道其值的含义。字面量包括**整数**、**浮点数**和**字符串字面量**；**符号引用**包括**类符号引用**、**字段符号引用**、**方法符号引用**和**接口方法符号引用**。
- **常量池表**会在类加载后存放到**方法区**的**运行时常量池**中
- 运行时常量池的功能类似于传统编程语言的**符号表(但是包含了比典型符号表更广泛的数据)**
- 运行时常量池是方法区的一部分，所以**受到方法区内存的限制**，当常量池无法再申请到内存时会抛出**OutOfMemoryError**的错误

## 字符串常量池

**字符串常量池**是JVM为了**提升性能和减少内存消耗针对字符串(String类)专门**开辟的一块区域，主要目的是为了避免字符串得重复创建

```java
// 在堆中创建字符串对象”ab“
// 将字符串对象”ab“的引用保存在字符串常量池中
String aa = "ab";
// 直接返回字符串常量池中字符串对象”ab“的引用
String bb = "ab";
System.out.println(aa==bb);// true 
```

> HotSpot 虚拟机中字符串常量池的实现是 `src/hotspot/share/classfile/stringTable.cpp` ,`StringTable` 本质上就是一个`HashSet<String>` ,容量为 `StringTableSize`（可以通过 `-XX:StringTableSize` 参数来设置）。
>
> `StringTable` 中保存的是**字符串对象的引用**，字符串对象的引用**指向堆中的字符串对象**。

JDK1.7之前，**运行时常量池(字符串常量池、静态变量)**存放在**永久代**。JDK1.7**字符串常量池和静态变量**从永久代移动到了Java堆中
![method-area-jdk1.6](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/method-area-jdk1.6.png)

![method-area-jdk1.7](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/method-area-jdk1.7.png)

**JDK1.7为什么要将字符串常量池移动到堆中**

- 因为**永久代（方法区实现）的GC回收效率太低**，只有在整堆收集（Full GC）的时候才会被执行GC。Java程序中通常有**大量的被创建的字符串等待回收**，将字符串常量池放到堆中，能够高效及时地回收字符串内存。

- JVM常量池中存储的是对象还是引用

  > 如果您说的确实是runtime constant pool（而不是interned string pool / StringTable之类的其他东西）的话，其中的引用类型常量（例如CONSTANT_String、CONSTANT_Class、CONSTANT_MethodHandle、CONSTANT_MethodType之类）都存的是引用，实际的对象还是存在Java heap上的。

- > **运行时常量池、方法区、字符串常量池这些都是不随虚拟机实现而改变的逻辑概念，是公共且抽象的，Metaspace、Heap 是与具体某种虚拟机实现相关的物理概念，是私有且具体的。**

## 总结

![image-20221208170002491](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221208170002491.png)

![image-20221208170040924](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221208170040924.png)

![image-20221208170112628](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221208170112628.png)

## 直接内存

- 直接内存并**不是虚拟机运行时数据区**的一部分，也**不是虚拟机规范中定义的内存**区域，但是这部分内存也被频繁使用，也可能导致OutOfMemoryError错误出现
- JDK1.4中新加入的NIO(New Input/Output)类，引入一种基于**通道（Channel）**与**缓冲区（Buffer）**的I/O方式，它可以直接使用**Native函数库直接分配堆外内存**，然后通过一个**存储在Java堆中的DirectByteBuffer对象作为这块内存的引用**进行操作。这样就能在一些场景中**显著提高性能**，因为避免了在**Java堆和Native堆**之间来回复制数据
- 本机直接内存的分配不会受到Java堆的限制，但是，既然是内存就会**受到本机总内存大小**以及**处理器寻址空间**的限制

# HotSpot虚拟机对象探秘

**了解一下HotSport虚拟机**在Java堆中对象分配、布局和访问的全过程

## 对象的创建



## 对象的内存布局

## 对象的访问定位