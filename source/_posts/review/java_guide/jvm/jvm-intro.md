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
3. 解析：虚拟机将**常量池内的符号引用**，替换为**直接引用**的过程（符号引用比如我现在 ```import java.util.ArrayList``` 这就算**符号引用**，**直接引用就是指针或者对象地址**，注意**引用对象一定是在内存进行**）

### 初始化

- 初始化就是**执行类构造器方法的```<clinit>()```的过程**，而且要**保证执行前父类的```<clinit>()```方法已经执行完毕**。
- 这个方法由编译器**收集(也就是编译时产生)**，**顺序执行所有类变量**(static 修饰的成员变量) **显示初始化**和静**态代码块中**语句
- 此时准备阶段时的那个static int a 由默认初始化的0**变成了显示初始化的3**。由于执行顺序缘故，**初始化阶段类变量**如果在静态代码中**又**进行更改，则会覆盖类变量的**显式初始化**，最终**值**会为静态代码块中的**赋值**

> 1. 字节码文件中初始化方法有两种，**非静态资源初始化**的<init>和**静态资源初始化**的<clinit>
> 2. 类构造器方法<clinit>() **不同于**类的构造器，这些方法都是**字节码文件中**只能给**JVM**识别的特殊方法

### 卸载

**GC将无用对象从内存中卸载**

## 类加载器的加载顺序

加载一个Class类的顺序也是有优先级的**(加载，也可以称"查找")** ，**类加载器** **从最底层开始往上**的顺序：

1. BootStrap ClassLoader： rt.jar  **(lib/rt.jar)**
2. Extension ClassLoader: 加载扩展的jar包  **(lib/ext/xxx.jar)**
3. APP ClassLoader： 指定的classpath下面的jar包   
4. Custom ClassLoader： 自定义的类加载器

## 双亲委派机制

- 当一个类收到了加载请求时，它是**不会先自己去尝试加载**的，而是**委派给父类**去完成，比如我现在要 new 一个 Person，这个 Person 是我们自定义的类，如果我们要加载它，就会**先委派 App ClassLoader** ，只有**当父类加载器都反馈自己无法完成**这个请求（也就是**父类加载器都没有找到加载所需的 Class**）时，子类加载器才会自行尝试加载。

- 好处：加载**位于 rt.jar 包中的类**时**不管是哪个加载器加载**，**最终都会委托到 BootStrap ClassLoader** 进行加载，这样保证了**使用不同的类加载器得到的都是同一个结果**。

- 其实这起了一个隔离的作用，避免自己写的代码影响**JDK的代码**

  ```java
  package java.lang;
  public class String {
      public static void main(String[] args) {
          System.out.println();
      }
  } 
  ```

  > 尝试运行当前类的 `main` 函数的时候，我们的代码肯定会报错。这是因为在加载的时候其实是找到了 rt.jar 中的`java.lang.String`，然而发现这个里面并没有 `main` 方法。

# 运行时数据区

## 本地方法栈和程序计数器

- 比如说我们现在点开Thread类的源码，会看到它的start0方法带有一个native关键字修饰，而且**不存在方法体**，这种**用native修饰的方法**就是**本地方法**，这是使用C来实现的，然后一般这些方法都会放到一个叫做**本地方法栈**的区域。
- **程序计数器**其实就是**一个指针**，它**指向了我们程序中下一句需要执行的指令**，它也是**内存区域中唯一一个不会出现OutOfMemoryError**的区域，而且**占用内存空间小到基本可以忽略不计**。这个**内存仅代表当前线程所执行的字节码的行号指示器**，字节码解析器通过**改变这个计数器的值选取下一条需要执行的字节码指令**。
  - 如果执行的是native方法，那这个指针就不工作了

## 方法区

- 主要存放**类的元数据信息**、**常量**和**静态变量**...等。
- 存储过大时，会在无法满足内存分配时报错

## 虚拟机栈和虚拟机堆

- **栈管运行**，**堆管存储**
- 虚拟机栈负责运行代码，虚拟机堆负责存储数据

### 虚拟机栈的概念

- 虚拟机栈是Java**方法执行的内存模型**
- 对**局部变量**、**动态链表**、**方法出口**、**栈的操作(入栈和出栈)**进行**存储**，且**线程独享**。
- 如果我们听到**局部变量表**，就是在说**虚拟机栈**

```java
public class Person{
    int a = 1;
    
    public void doSomething(){
        int b = 2;
    }
}
```

### 虚拟机栈存在的异常

- 如果线程请求的栈的深度，**大于虚拟机栈的最大深度**，就会报**StackOverflowError**(比如递归)
- Java虚拟机也可以**动态扩展**，但**随着扩展会不断地申请内存**，当无法申请足够内存时就会报错 **OutOfMemoryError** 

### 虚拟机栈的生命周期

- 栈**不存在垃圾回收**，只要程序运行结束，栈的空间自然释放
- 栈的**生命周期和所处的线程**一致
- **8种基本类型的变量+对象的引用变量+实例方法**，都是在栈里面分配内存

### 虚拟机栈的执行

- **栈帧**数据，在JVM中叫**栈帧**，Java中叫**方法**，它也是放在栈中
- 栈中的数据以**栈帧**的格式存在，它是一个**关于方法**和**运行期数据**的数据集

> 比如我们执行一个方法a，就会对应产生一个栈帧A1，然后A1会被压入栈中。同理方法b会有一个B1，方法c会有一个C1，等到这个线程执行完毕后，栈会先弹出C1，后B1,A1。它是一个先进后出，后进先出原则。

### 局部变量的复用

- 用于**存放方法参数**和**方法内部所定义的局部变量**

- 容量以**Slot**为最小单位，一个slot可以存放32以内的数据类型。

  > 在局部变量表里，**32位以内的类型只占用一个slot**（包括returnAddress类型），**64位的类型（long和double）占两个slot**。

- 虚拟机通过索引方式使用局部变量表，范围为 **[ 0 , 局部变量表的slot的数量 ]**。方法中的**参数**就会**按一定顺序排列**在这个局部变量表中 

- 为了节省栈帧空间，这些**slot**是可以复用的。当方法**执行位置超过了某个变量（这里意思应该是用过了这个变量）**，那么**这个变量的slot可以被其它变量复用**。当然如果需要复用，那我们的**垃圾回收自然就不会去动这些内存**

### 虚拟机堆的概念

- JVM内存会划分为**堆内存**和**非堆内存**，**堆内存**也会划分为**年轻代**和**老年代**，而**非堆内存**则为**永久代**。

- 年轻代又分为**Eden**和**Survivor**区，Survivor还分为**FromPlace**和**ToPlace**，toPlace的survivor区域是空的

- **Eden：FromPlace：ToPlace**的默认占比是8：1：1，当然这个东西也可以通过一个```-XX:+UsePSAdaptiveSurvivorSizePolicy```参数来**根据生成对象的速率动态调整**  
  （因为存活的对象相对较少）

- 堆内存中**存放的是对象**，垃圾收集就是**收集这些对象然后交给GC算法进行回收**。非堆内存其实我们已经说过了，就是**方法区**。在**1.8中已经移除永久代**，替代品是一个**元空间(MetaSpace)**，最大区别是**metaSpace是不存在于JVM**中的，它**使用的是本地内存**。并有两个参数：

  ```shell
  MetaspaceSize：初始化元空间大小，控制发生GC
  MaxMetaspaceSize：限制元空间大小上限，防止占用过多物理内存。
  ```

- 移除的原因  
  融合**HotSpot JVM和JRockit VM**而做出的改变，因为**JRockit是没有永久代**的，不过这也**间接性地解决了永久代的OOM**问题。

### Eden年轻代的介绍

- 当new一个对象后，会放到**Eden划分出来的一块作为存储空间的内存**，由于堆内存共享，所以**可能出现两个对象共用一个内存的情况**。

  > JVM的处理：**为每个内存**都**预先申请**好一块连续的内存空间并**规定对象存放的位置**，如果空间不足会再申请多块内存空间。这个操作称为TLAB

- Eden空间满了之后，会触发**MinorGC（发生在年轻代的GC）**操作，**存活下来的对象**移动到**Survivor0区**。**Survivor0满后会触发MInorGC**，将**存活对象（这里应该包括Eden的存活对象?）移动到Survivor1区**，此时还会**把from和to两个指针交换**，这样**保证**一段时间内**总有一个survivor区为空且所指向的survivor区为空**。

- 经过**多次的MinorGC后仍然存活的对象**(这里存活判断是15次，对应的虚拟机参数为`-XX:MaxTenuringThreshold` 。HotSpot会在对象中的**标记字段**里记录年龄，分配到的空间**仅有4位**，所以**最多记录到15**)会移动到老年代。

- 老年代是存储长期存活对象的，**占满**时就会触发我们常说的FullGC，期间会**停止所有线程**等待GC的完成。所以对于**响应要求高**的应用，应该尽量去**减少**发生FullGC从而避免响应超时的问题

- 当老年区**执行full gc周仍然无法进行对象保存**操作，就会产生**OOM**。这时候就是虚拟机中堆内存不足，**原因可能会是**堆内存设置大小过小，可以通过参数**-Xms、-Xmx**来调整。也可能是**代码中创建对象大且多**，而且它们**一直在被引用**从而**长时间垃圾收集无法收集**它们

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/c02ecba3c33f43429a765987b928e423-new-image93b46f3d-33f9-46f9-a825-ec7129b004f6.png)

> 关于-XX:TargetSurvivorRatio参数的问题。其实也不一定是要满足-XX:MaxTenuringThreshold才移动到老年代。可以举个例子：如**对象年龄5的占30%，年龄6的占36%，年龄7的占34%，加入某个年龄段（如例子中的年龄6）**后，总占用超过Survivor空间*TargetSurvivorRatio的时候，从该年龄段开始及大于的年龄对象就要进入老年代（即例子中的年龄6对象，就是年龄6和年龄7晋升到老年代），这时候无需等到MaxTenuringThreshold中要求的15

### 如何判断一个对象需要被干掉

首先看一下对象的虚拟机的一些流程  

图例有点问题，**橙色是线程共享，青绿色是线程独享**
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1c1d85b5fb8b47239af2a5c0436eb2d7-new-image0cd10827-2f96-433c-9b16-93d4fe491d88.png)

- 图中**程序计数器**、**虚拟机栈**、**本地方法栈**，3个区域随着线程生存而生存。**内存分配**和**回收**都是确定的，**随着线程的结束**内存自然就被回收了，因此不需要考虑垃圾回收问题。

- **Java堆和方法区**则不一样，各线程共享，内存的分配和回收都是动态的，垃圾收集器所关注的就是**堆**和**方法区**这部分内存

- 垃圾回收前，判断**哪些对象还存活**，**哪些已经死去**。下面介绍连个基础计算方法：  

  1. **引用计数器**计算：给对象添加一个**引用计数器**，每次**引用这个对象时计数器加一**，**引用失效时减一**，**计数器等于0**就是不会再次使用的。不过有一种情况，就是 出现**对象的循环引用时GC没法回收**（我觉得不是非得循环，如果一个对象a中有属性引用另一个对象b，而a指向null，那么按这种方式，b就没有办法被回收）。

  2. 可达性分析计算：一种类似**二叉树**的实现，将一系列的**GC ROOTS作为起始的存活对象集**，从这个结点往下搜索，**搜索所走过的路径成为引用链**，把**能被该集合引用到的对象加入该集合**中。

     > **当一个对象到GC Roots没有使用任何引用链**时，则说明**该对象是不可用的**。Java，C#都是用这个方法判断对象是否存活

     Java语言汇总作为GCRoots的对象分为以下几种：

     1. **虚拟机栈**（栈帧中的**本地方法表**）中引用的对象（局部变量）

     2. **方法区中静态变量**所引用的对象（静态变量）

     3. **方法区中常量**引用的变量

     4. 本地方法栈（即native修饰的方法）中JNI引用的对象

        > （JNI是Java虚拟机调用对应的C函数的方式，通过JNI函数也可以创建新的Java对象。且JNI对于对象的局部引用或者全局引用都会把它们指向的对象都标记为不可回收）

     5. 已启动的且未终止的Java线程【这个描述好像是有问题的(不全)，应该是**用作同步监视器的对象**】

     这种方法的优点是，**能够解决循环引用**的问题，可它的实现**耗费大量资源**和时间，也需要GC(**分析过程引用关系不能发生变化**，所以需要停止所有进程)

### 如何宣告一个对象的真正死亡

- 首先，需要提到finalize()方法，是Object类的一个方法，一个**对象的finalize()**方法**只会被**系统**自动调用一次**，**经过finalize()方法逃脱死亡的对象(比如在方法中，其他变量又一次引用了该对象)**，第二次不会再被调用

  > 并不提倡在程序中调用finalize()来进行自救。建议忘掉Java程序中该方法的存在。因为它执行的时间不确定，甚至是否被执行也不确定（Java程序的不正常退出），而且运行代价高昂，无法保证各个对象的调用顺序（甚至有不同线程中调用）。在Java9中已经被标记为 **deprecated** ，且 `java.lang.ref.Cleaner`（也就是强、软、弱、幻象引用的那一套）中已经逐步替换掉它，会比 `finalize` 来  
  > ```deprecated英[ˈdeprəkeɪtɪd]美[ˈdeprəkeɪtɪd]```

- 判断一个对象的死亡至少需要两次标记

  1. 如果对象可达性分析之后没发现**与GC Roots相连的引用链**，那它将会被第一次标记并且进行一次筛选，**判断条件是**是决定**这个对象是否有必要执行finalize()**方法。如果对象有必要执行finalize()，则被放入F-Queue队列
  2. GC堆F-Queue队列中的对象**进行二次标记**。如果对象在finalize()方法中**重新与引用链上的任何一个对象建立了关联**，那么二**次标记时则会将它移出“即将回收”集合**。**如果**此时对象**还没成功逃脱**，那么**只能被回收**了。

## 垃圾回收算法

确定对象已经死亡，此刻需要回收这些垃圾。常用的有**标记清除**、**复制**、**标记整理**、和**分代收集算法**。

### 标记清除算法

- 标记清除算法就是分为**”标记“**和**”清除“**两个阶段。标记出所有需要回收的对象，标记结束后统一回收。**后续算法都根据这个基础来加以改进**
- 即：把已死亡的对象标记为空闲内存，然后记录在空闲列表中，当我们需要new一个对象时，内存管理模块会从空闲列表中寻找空闲的内存来分给新的对象
  - 不足方面：标记和清除**效率比较低**，且这种做法让**内存中碎片非常多**  。导致如果我们需要使用较大内存卡时，无法分配到足够的连续内存
- 如图，可使用的内存都是零零散散的，导致大内存对象问题
  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/01605d96d85f4daab9bfa5e7000f0d31-new-image78e03b85-fbef-4df9-b41e-2b63d78d119f.png)

### 复制算法

- 为了解决效率问题，出现了**复制**算法。将内存**按容量**划分成两等份，每次只使用其中的一块，**和survivor一样**用from和to两个指针。fromPlace存满了，就把存活对象copy到另一块toPlace上，然后交换指针内容，就解决了碎片问题

  - 代价：内存缩水，即堆内存的**使用效率**变低了

  > 默认情况Eden和Survivor 为 8: 2 （Eden : S0 : S1 = 8：1：1）
  
  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/fc349fbb9b204495a5321febe27818d4-new-image45920a9a-552c-4656-94d6-e3ca45ff9b76.png)

### 标记整理

- 复制算法在**对象存活率高**的时候，仍然有效率问题（要复制的多）。
- 标记整理--> 标记过程与**标记-清除**一样，但后续**不是直接对可回收对象进行清理**，而是让所有**存活对象都向一端移动**，然后直接**清理掉边界以外**内存

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/2599e9f722074d34a3f7fd9f0076f121-new-imagec76192ec-b63a-43e3-a6d6-cf01f749953f.png)

### 分代收集算法

- 这种算法并没有什么新的思想，只是**根据对象存活周期的不同将内存划分为几块**
- 一般是将**Java堆分为新生代和老年代**，即可根据各个年代特点采用最适当的收集算法
  - **新生代**中，每次垃圾收集时会有大批对象死去，**只有少量存活**，就采用复制算法，只需要付出**少量存活对象的复制成本**即可完成收集
  - **老年代**中，因为存活对象存活率高，也没有**额外空间**对它进行分配担保（```新生代如果不够可以放老年代，而老年代清理失败就会OutOfMemory，不像新生代可以移动到老年代```），所以必须使用**“标记-清理”**或者**“标记-整理”**来进行回收
- 即：具体问题具体分析

## （了解）各种各样的垃圾回收器

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/11e9dcd0f1ee4f25836e6f1c47104c51-new-image69e1c56a-1d40-493a-9901-6efc647a01f3.png)

- 新生代的垃圾回收器：Serial（串行--复制），ParNew（并行--复制），ParallelScavenge（并行--复制）
- 老年代的垃圾回收器：SerialOld（串行--标记整理），ParallelOld（并行--标记整理），CMS（并发--标记清除）

- 只有CMS和G1是并发，且CMS只作用于老年代，而G1都有
- JDK8为止，默认垃圾回收器是Parallel Scavenge和Parallel Old【**并行--复制**和**并行--标记整理**】
- JDK9开始，**G1收集器成为默认的垃圾收集器**，目前来看，**G1回收期停顿时间最短**且没有明显缺点，偏适合Web应用

> jdk8中测试Web应用，堆内存6G中新生代4.5G的情况下
>
> - ParallelScavenge回收新生代停顿长达1.5秒。
> - G1回收器回收同样大小的新生代只停顿0.2秒

## （了解） JVM的常用参数
JVM的参数非常之多，这里只列举比较重要的几个，通过各种各样的搜索引擎也可以得知这些信息。

| 参数名称 | 含义 | 默认值 | 说明 |
|------|------------|------------|------|
| -Xms  | 初始堆大小          | 物理内存的1/64(<1GB)         |默认(MinHeapFreeRatio参数可以调整)空余堆内存小于40%时，JVM就会增大堆直到-Xmx的最大限制.
| -Xmx  | 最大堆大小        | 物理内存的1/4(<1GB)        | 默认(MaxHeapFreeRatio参数可以调整)空余堆内存大于70%时，JVM会减少堆直到 -Xms的最小限制
| -Xmn  | 年轻代大小(1.4or later)       |        |注意：此处的大小是（eden+ 2 survivor space).与jmap -heap中显示的New gen是不同的。整个堆大小=年轻代大小 + 老年代大小 + 持久代（永久代）大小.增大年轻代后,将会减小年老代大小.此值对系统性能影响较大,Sun官方推荐配置为整个堆的3/8
| -XX:NewSize  | 设置年轻代大小(for 1.3/1.4)          |          |
| -XX:MaxNewSize  | 年轻代最大值(for 1.3/1.4)        |         |
| -XX:PermSize  | 设置持久代(perm gen)初始值     | 物理内存的1/64       |
| -XX:MaxPermSize  | 设置持久代最大值          | 物理内存的1/4         |
| -Xss  | 每个线程的堆栈大小        |         | JDK5.0以后每个线程堆栈大小为1M,以前每个线程堆栈大小为256K.根据应用的线程所需内存大小进行 调整.在相同物理内存下,减小这个值能生成更多的线程.但是操作系统对一个进程内的线程数还是有限制的,不能无限生成,经验值在3000~5000左右一般小的应用， 如果栈不是很深， 应该是128k够用的 大的应用建议使用256k。这个选项对性能影响比较大，需要严格的测试。（校长）和threadstacksize选项解释很类似,官方文档似乎没有解释,在论坛中有这样一句话:-Xss is translated in a VM flag named ThreadStackSize”一般设置这个值就可以了
| -XX:NewRatio  | 年轻代(包括Eden和两个Survivor区)与年老代的比值(除去持久代)       |        |-XX:NewRatio=4表示年轻代与年老代所占比值为1:4,年轻代占整个堆栈的1/5Xms=Xmx并且设置了Xmn的情况下，该参数不需要进行设置。
| -XX:SurvivorRatio  | Eden区与Survivor区的大小比值          |          |设置为8,则两个Survivor区与一个Eden区的比值为2:8,一个Survivor区占整个年轻代的1/10
| -XX:+DisableExplicitGC  | 关闭System.gc()        |         |这个参数需要严格的测试
| -XX:PretenureSizeThreshold  | 对象超过多大是直接在旧生代分配       | 0      |单位字节 新生代采用Parallel ScavengeGC时无效另一种直接在旧生代分配的情况是大的数组对象,且数组中无外部引用对象.
| -XX:ParallelGCThreads  | 并行收集器的线程数         |          |此值最好配置与处理器数目相等 同样适用于CMS
| -XX:MaxGCPauseMillis  | 每次年轻代垃圾回收的最长时间(最大暂停时间)        |         |如果无法满足此时间,JVM会自动调整年轻代大小,以满足此值.

其实还有一些打印及CMS方面的参数，这里就不以一一列举了

# 关于JVM调优的一些方面

- 默认
  - 年轻代：老年代 = 1: 2 
  - 年轻代中 Eden : S0 : S 1 = 8 : 1 ：1

- 根据刚刚涉及的jvm知识点，可以尝试对JVM进行调优，**主要是堆内存**那块
- **所有线程共享数据区大小**=**新生代大小**+**老年代大小**+**持久代大小** （即 堆 + 方法区）
- 持久代一般固定大小为64m，
- java堆中增大年轻代后，会减少老年代大小（因为老年代的清理使用fullgc，所以老年代过小的话反而会增多fullgc）。 年轻代 `-Xmn`的值推荐配置为**java堆的3/8** 

## 调整最大堆内存和最小堆内存

- -Xmx -Xms：指定java堆最大值（默认 物理内存的1/4 (<1 GB ) ) 和 初始java堆最小值（默认值是物理内存的1/64 (<1GB) ）

- 默认(MinHeapFreeRatio参数可以调整)空余堆内存小于40%时，JVM就会增大堆直到-Xmx的最大限制.，默认(MaxHeapFreeRatio参数可以调整)空余堆内存大于70%时，JVM会减少堆直到 -Xms的最小限制。

  > 简单点来说，你不停地往堆内存里面丢数据，等它剩余大小小于40%了，JVM就会动态申请内存空间不过会小于-Xmx，如果剩余大小大于70%，又会动态缩小不过不会小于–Xms。就这么简单

- 开发过程中，通常会将 -Xms 与 Xmx 两个参数设置成相同的值

  > 为的是能够在java垃圾回收机制清理完堆区后，**不需要重新分隔计算堆区的大小而浪费资源（向系统请求/释放内存资源）**

- 代码  

  ```java
  public class App {
      public static void main(String[] args) {
  
          System.out.println("Xmx=" + Runtime.getRuntime().maxMemory() / 1024.0   + "KB");    //系统的最大空间-Xmx--运行几次都不变
          System.out.println("free mem=" + Runtime.getRuntime().freeMemory() / 1024.0   + "KB");  //系统的空闲空间--每次运行都变
          System.out.println("total mem=" + Runtime.getRuntime().totalMemory() / 1024.0   + "KB");  //当前可用的总空间 与Xms有关--运行几次都不变
  
      }
  }
  /* -----
  Xmx=7389184.0KB
  free mem=493486.0546875KB
  total mem=498688.0KB
  */
  ```

  > 1. maxMemory()这个方法返回的是java虚拟机(这个进程)能构从操纵系统那里挖到的最大的内存
  > 2. freeMemory：挖过来而又没有用上的内存，实际上就是 freeMemory()，所以freeMemory()的值一般情况下都是很小的(totalMemory一般比需要用得多一点，剩下的一点就是freeMemory)
  > 3. totalMemory：程序运行的过程中，内存总是慢慢的从操纵系统那里挖的，基本上是用多少挖多少，直 挖到maxMemory()为止，所以totalMemory()是慢慢增大的
  >    原文链接：https://blog.csdn.net/weixin_35671171/article/details/114189796

- 编辑VM options参数后再看效果：  
  ```-Xmx20m -Xms5m -XX:+PrintGCDetails```，堆最大以及堆初始值  20m和5m

    ```java
    /* 效果
     [GC (Allocation Failure) [PSYoungGen: 1024K->488K(1536K)] 1024K->608K(5632K), 0.0007606 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
    Xmx=18432.0KB
    free mem=4249.90625KB
    total mem=5632.0KB
    Heap
     PSYoungGen      total 1536K, used 1326K [0x00000000ff980000, 0x00000000ffb80000, 0x0000000100000000)
      eden space 1024K, 81% used [0x00000000ff980000,0x00000000ffa51ad0,0x00000000ffa80000)
      from space 512K, 95% used [0x00000000ffa80000,0x00000000ffafa020,0x00000000ffb00000)
      to   space 512K, 0% used [0x00000000ffb00000,0x00000000ffb00000,0x00000000ffb80000)
     ParOldGen       total 4096K, used 120K [0x00000000fec00000, 0x00000000ff000000, 0x00000000ff980000)
      object space 4096K, 2% used [0x00000000fec00000,0x00000000fec1e010,0x00000000ff000000)
     Metaspace       used 3164K, capacity 4496K, committed 4864K, reserved 1056768K
      class space    used 344K, capacity 388K, committed 512K, reserved 1048576K
    */
    ```
  
  1. 如上， **Allocation Failure** 因为分配失败导致YoungGen 
  2. total mem (此时申请到的总内存)：  
     PSYoungGen + ParOldGen = 1536 + 4096 = 5632 KB 
  3. freeMemory (申请后没有使用的内存)  
     1324 + 120 = 1444 KB 
     5632 - 4249 = 1383 KB  差不多
  
- 使用1M后  

  ```java
  public class App {
      public static void main(String[] args) {
  
          System.out.println("Xmx=" + Runtime.getRuntime().maxMemory() / 1024.0   + "KB");    //系统的最大空间-Xmx--运行几次都不变
          System.out.println("free mem=" + Runtime.getRuntime().freeMemory() / 1024.0   + "KB");  //系统的空闲空间--每次运行都变
          System.out.println("total mem=" + Runtime.getRuntime().totalMemory() / 1024.0   + "KB");  //当前可用的总空间 与Xms有关--运行几次都不变
          byte[] b = new byte[1 * 1024 * 1024];
          System.out.println("分配了1M空间给数组");
          System.out.println("Xmx=" + Runtime.getRuntime().maxMemory() / 1024.0 / 1024 + "M");  //系统的最大空间
          System.out.println("free mem=" + Runtime.getRuntime().freeMemory() / 1024.0 / 1024 + "M");  //系统的空闲空间
          System.out.println("total mem=" + Runtime.getRuntime().totalMemory() / 1024.0 / 1024 + "M");
      }
  }
  /**
   [GC (Allocation Failure) [PSYoungGen: 1024K->488K(1536K)] 1024K->608K(5632K), 0.0007069 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
  Xmx=18432.0KB
  free mem=4270.15625KB
  total mem=5632.0KB
  分配了1M空间给数组
  Xmx=18.0M
  free mem=3.1700592041015625M  //少了1M
  total mem=5.5M
  Heap
   PSYoungGen      total 1536K, used 1270K [0x00000000ff980000, 0x00000000ffb80000, 0x0000000100000000)
    eden space 1024K, 76% used [0x00000000ff980000,0x00000000ffa43aa0,0x00000000ffa80000)
    from space 512K, 95% used [0x00000000ffa80000,0x00000000ffafa020,0x00000000ffb00000)
    to   space 512K, 0% used [0x00000000ffb00000,0x00000000ffb00000,0x00000000ffb80000)
   ParOldGen       total 4096K, used 1144K [0x00000000fec00000, 0x00000000ff000000, 0x00000000ff980000)
    object space 4096K, 27% used [0x00000000fec00000,0x00000000fed1e020,0x00000000ff000000)
   Metaspace       used 3155K, capacity 4496K, committed 4864K, reserved 1056768K
    class space    used 344K, capacity 388K, committed 512K, reserved 1048576K
  */
  ```

  此时free memory就又缩水了，不过**total memory是没有变化**的。Java会尽可能将**total mem的值维持在最小堆内存大小**

- 这时候我们创建了一个10M的字节数据，这时候最小堆内存是顶不住的。我们会发现现在的total memory已经变成了15M，这就是已经申请了一次内存的结果。

  ```java
  public class App {
      public static void main(String[] args) {
  
          System.out.println("Xmx=" + Runtime.getRuntime().maxMemory() / 1024.0   + "KB");    //系统的最大空间-Xmx--运行几次都不变
          System.out.println("free mem=" + Runtime.getRuntime().freeMemory() / 1024.0   + "KB");  //系统的空闲空间--每次运行都变
          System.out.println("total mem=" + Runtime.getRuntime().totalMemory() / 1024.0   + "KB");  //当前可用的总空间 与Xms有关--运行几次都不变
          byte[] b = new byte[1 * 1024 * 1024];
          System.out.println("分配了1M空间给数组");
          System.out.println("Xmx=" + Runtime.getRuntime().maxMemory() / 1024.0 / 1024 + "M");  //系统的最大空间
          System.out.println("free mem=" + Runtime.getRuntime().freeMemory() / 1024.0 / 1024 + "M");  //系统的空闲空间
          System.out.println("total mem=" + Runtime.getRuntime().totalMemory() / 1024.0 / 1024 + "M");
  
          byte[] c = new byte[10 * 1024 * 1024];
          System.out.println("分配了10M空间给数组");
          System.out.println("Xmx=" + Runtime.getRuntime().maxMemory() / 1024.0 / 1024 + "M");  //系统的最大空间
          System.out.println("free mem=" + Runtime.getRuntime().freeMemory() / 1024.0 / 1024 + "M");  //系统的空闲空间
          System.out.println("total mem=" + Runtime.getRuntime().totalMemory() / 1024.0 / 1024 + "M");  //当前可用的总空间
  
      }
  }
  /**  ----
  [GC (Allocation Failure) [PSYoungGen: 1024K->488K(1536K)] 1024K->600K(5632K), 0.0006681 secs] [Times: user=0.00 sys=0.00, real=0.00 secs] 
  Xmx=18432.0KB
  free mem=4257.953125KB
  total mem=5632.0KB
  分配了1M空间给数组
  Xmx=18.0M
  free mem=3.1153564453125M
  total mem=5.5M
  分配了10M空间给数组
  Xmx=18.0M
  free mem=2.579681396484375M
  total mem=15.0M
  Heap
   PSYoungGen      total 1536K, used 1363K [0x00000000ff980000, 0x00000000ffb80000, 0x0000000100000000)
    eden space 1024K, 85% used [0x00000000ff980000,0x00000000ffa5acc0,0x00000000ffa80000)
    from space 512K, 95% used [0x00000000ffa80000,0x00000000ffafa020,0x00000000ffb00000)
    to   space 512K, 0% used [0x00000000ffb00000,0x00000000ffb00000,0x00000000ffb80000)
   ParOldGen       total 13824K, used 11376K [0x00000000fec00000, 0x00000000ff980000, 0x00000000ff980000)
    object space 13824K, 82% used [0x00000000fec00000,0x00000000ff71c020,0x00000000ff980000)
   Metaspace       used 3242K, capacity 4500K, committed 4864K, reserved 1056768K
    class space    used 351K, capacity 388K, committed 512K, reserved 1048576K
  */
  ```

  此时我们再跑一下这个代码 

  

## 调整新生代和老年代的比值

## 调整Survivor区和Eden区的比值

## 设置年轻代和老年代的大小

## 小总结

## 永久区的设置

## JVM的栈参数调优

# finally