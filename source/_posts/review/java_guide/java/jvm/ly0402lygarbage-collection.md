---
title: java垃圾回收
description: java垃圾回收
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-12 15:58:48
updated: 2022-12-16 09:53:48
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 前言

当**需要排查各种内存溢出问题**、当**垃圾收集**成为系统达到更高并发的瓶颈时，我们就需要对这些**“自动化”**的技术实施必要的**监控**和**调节**

# 堆空间的基本结构

- Java的**自动内存管理**主要是针对对象内存的**回收**和对象内存的**分配**。且Java自动内存管理最核心的功能是**堆**内存中的对象**分配**和**回收**

- Java堆是垃圾收集器管理的主要区域，因此也被称作**GC堆（Garbage Collected Heap）**
- 从**垃圾回收的角度**来说，由于现在收集器基本都采用**分代垃圾收集算法**，所以Java堆被划分为了几个不同的区域，这样我们就可以**根据各个区域的特点**选择**合适的垃圾收集算法**
- JDK7版本及JDK7版本之前，堆内存被通常分为下面三部分：
  1. 新生代内存（Young Generation）
  2. 老生代（Old Generation）
  3. 永久代（Permanent Generation）

![hotspot-heap-structure](https://javaguide.cn/assets/hotspot-heap-structure.41533631.png)

JDK8版本之后PermGen（永久）已被Metaspace（元空间）取代，且已经不在堆里面了，元空间使用的是**直接内存**。

# 内存分配和回收原则

## 对象优先在Eden区分配

- 多数情况下，对象在**新生代中Eden区**分配。当Eden区没有足够空间进行分配时，会触发一次MinorGC
  首先，先添加一下参数打印GC详情：```-XX:+PrintGCDetails```

  ```java
  public class GCTest {
  	public static void main(String[] args) {
  		byte[] allocation1, allocation2;
  		allocation1 = new byte[30900*1024];//会用掉3万多K
  	}
  } 
  ```

  运行后的结果（这里应该是配过xms和xmx了，即堆内存大小）
  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/28954286.jpg)
  如上，**Eden区内存几乎被分配完全**（即使程序什么都不做，新生代也会使用2000多K）

  > 注： PSYoungGen 为 38400K ，= 33280K + 5120K （Survivor区总会有一个是空的，所以只加了一个5120K ）

  假如我们再为allocation2分配内存会怎么样(不处理的话，年轻代会溢出)

  ```java
  allocation2 = new byte[900 * 1024];
  ```

  ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/28128785.jpg)
  在给allocation2分配内存之前，Eden区内存几乎已经被分配完。所以当**Eden区没有足够空间进行分配时**，虚拟机将发起一次MinorGC。GC期间虚拟机又发现**allocation1无法存入空间**，所以只好通过**分配担保机制**，把**新生代的对象**，**提前转移到老年代**去，老年代的空间足够存放allocation1，**所以不会出现Full GC（这里可能是之前的说法，可能只是要表达老年代的GC，而不是Full GC(整堆GC) ）**　　

  执行MinorGC后，**后面分配的对象如果能够存在Eden区**的话，还是会在Eden区分配内存  
执行如下代码验证：  
  
```java
  public class GCTest {
  
  	public static void main(String[] args) {
  		byte[] allocation1, allocation2,allocation3,allocation4,allocation5;
  		allocation1 = new byte[32000*1024];
  		allocation2 = new byte[1000*1024];
  		allocation3 = new byte[1000*1024];
  		allocation4 = new byte[1000*1024];
  		allocation5 = new byte[1000*1024];
  	}
  } 
```

  

## 大对象直接进入老年代

- 大对象就是需要连续空间的对象（**字符串**、**数组**等）
- 大对象直接进入老年代，主要是为了避免为**大对象分配内存时**，由于**分配担保机制(这好像跟分配担保机制没有太大关系)**带来的复制而**降低效率**。

> - 假设大对象最后会晋升老年代，而新生代是基于复制算法来回收垃圾的，由两个Survivor区域配合完成复制算法，如果新生代中出现大对象且能屡次躲过GC，那这个对象就会在两个Survivor区域中来回复制，直至最后升入老年代，而大对象在内存里来回复制移动，就会消耗更多的时间。
>
> - 假设大对象最后不会晋升老年代，新生代空间是有限的，在新生代里的对象大部分都是朝生夕死的，如果让一个大对象占据了新生代空间，那么相比起**正常的对象被分配在新生代**，大对象无疑会**让新生代GC提早发**生，因为内**存空间会更快不够用**，如果这个大对象因为业务原因，并不会马上被GC回收，那么这个对象就会进入到Survivor区域，默认情况下，Survivor区域本来就不会被分配的很大，那此时被大对象占据了大部分空间，很可能会导致之后的新生代GC后，存活下来的对象，Survivor区域空间不够放不下，导致大部分对象进入老年代，这就加快了老年代GC发生的时间，而**老年代GC对系统性能的负面影响则远远大于新生代GC**了。 

## 长期存活的对象进入老年代

- 内存回收时必须能够识别，哪些对象放在新生代，哪些对象放在老年代---> 因此，虚拟机给每个对象一个**对象年龄（Age）**计数器

- <流程> : 大部分情况下，对象都会**首先在Eden区域**分配。如果对象在Eden出生并经过**第一次MinorGC后**仍然能够存活，并且**能**被Survivor容纳的话，将被移动到Survivor空间（S0或S1）中，并将对象年龄设为**1**(**Eden区 --> Survivor区后**对象初始年龄变为1 )

  - 后续，对象在**Survivor区**中每熬过一次MinorGC，**年龄就增加1岁**，当年龄增加到一定程序（**默认为15岁**），就会被晋升到老年代中。对象晋升到老年代的年龄**阈值**，可以通过参数**```-XX:MaxTenuringThreshold```**来设置
  - **★★修正：** “Hotspot 遍历所有对象时，按照年龄**从小到大**对其所**占用的大小进行累积**，当**累积的某个年龄大小超过了 survivor 区的 50%** 时（默认值是 50%，可以通过 `-XX:TargetSurvivorRatio=percent` 来设置，参见 [issue1199open in new window](https://github.com/Snailclimb/JavaGuide/issues/1199) ），取**这个年龄**和 **MaxTenuringThreshold 中更小的一个值**，作为新的晋升年龄阈值”。

  动态年龄计算的代码：  

  ```java
  uint ageTable::compute_tenuring_threshold(size_t survivor_capacity) {
  //survivor_capacity是survivor空间的大小
  size_t desired_survivor_size = (size_t)((((double)survivor_capacity)*TargetSurvivorRatio)/100);
  size_t total = 0;
  uint age = 1;
  while (age < table_size) {
  //sizes数组是每个年龄段对象大小
  total += sizes[age];
  if (total > desired_survivor_size) {
  break;
  }
  age++; //注意这里，age是递增的，最终是去某个值，而不是区间的值计算
  }
  uint result = age < MaxTenuringThreshold ? age : MaxTenuringThreshold;
  ...
  } 
  ```

  > 例子： 如**对象年龄5的占30%，年龄6的占36%，年龄7的占34%，加入某个年龄段（如例子中的年龄6）**后，总占用超过Survivor空间*TargetSurvivorRatio的时候，从该年龄段开始及大于的年龄对象就要进入老年代（即例子中的年龄6对象，就是年龄6和年龄7晋升到老年代），这时候无需等到MaxTenuringThreshold中要求的15
  >
  >  > **关于默认的晋升年龄是 15，这个说法的来源大部分都是《深入理解 Java 虚拟机》这本书。** 如果你去 Oracle 的官网阅读[相关的虚拟机参数open in new window](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html)，你会发现`-XX:MaxTenuringThreshold=threshold`这里有个说明
  >  >
  >  > **Sets the maximum tenuring threshold for use in adaptive GC sizing. The largest value is 15. The default value is 15 for the parallel (throughput) collector, and 6 for the CMS collector.默认晋升年龄并不都是 15，这个是要区分垃圾收集器的，CMS 就是 6.**


## 主要进行gc的区域

如图：（太长跳过了，直接看下面的总结）  
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/rf-hotspot-vm-gc.69291e6e.png)

总结：  
针对HotSpotVM的实现，它里面的GC准确分类只有两大种：  

1. 部分收集（Partial GC）
   - 新生代收集（Minor GC/ Young GC ）：只对**新生代**进行垃圾收集
   - 老年代（Major GC / Old GC )：只对**老年代**进行垃圾收集。★★：注意，MajorGC在有的语境中也用于指代**整堆收集**
   - 混合收集（Mixed GC）：对**整个新生代**和**部分老年代**进行垃圾收集
2. 整堆收集（Full GC）：收集整个Java堆和方法区

## 空间分配担保

- 为了确保在**MinorGC**之前老年代本身还有容纳**新生代所有对象**的剩余空间

- 《深入理解Java虚拟机》第三章对于空间分配担保的描述如下：

  > JDK 6 Update 24 之前，在发生 Minor GC 之前，虚拟机必须先检查老年代最大可用的连续空间是否大于新生代所有对象总空间，如果这个条件成立，那这一次 Minor GC 可以确保是安全的。如果不成立，则虚拟机会先查看 -XX:HandlePromotionFailure 参数的设置值是否允许担保失败(Handle Promotion Failure);如果允许，那会继续检查老年代最大可用的连续空间是否大于历次晋升到老年代对象的平均大小，如果大于，将尝试进行一次 Minor GC，尽管这次 Minor GC 是有风险的;如果小于，或者 -XX: HandlePromotionFailure 设置不允许冒险，那这时就要改为进行一次 Full GC。
  >
  > **JDK6 Update24**之后，规则变为**只要老年代的连续空间**大于**新生代对象总大小**，或者**历次晋升的平均大小**，就会进行**MinorGC**，否则将进行**Full GC**


# 死亡对象判断方法

**堆**中**几乎放着所有的对象实例**，对堆垃圾回收前的第一步就是要**判断哪些对象已经死亡**（即不能再被**任何途径使用**的对象）

## 引用计数法

- 给对象中添加一个**引用计数器**

  - 每当有一个地方引用它，**计数器就加1**
  - 当引用失效，**计数器就减1**
  - 任何时候**计数器为0的对象**就是**不可能再被使用**的

-  这个方法实现**简单，效率高**，但是目前主流的虚拟机中并没有选择这个算法来管理内存，其最主要的原因是它**很难解决对象之间相互循环引用**的问题。 

  > 除了对象 `objA` 和 `objB` 相互引用着对方之外，这两个对象之间再无任何引用。但是他们因为互相引用对方，导致它们的引用计数器都不为 0，于是引用计数算法无法通知 GC 回收器回收他们

  ★其实我觉得只跟相互有关，跟是不是**循环**关系不会太大

  > ly 改：相互在**语言逻辑**上也可以理解成**“循环”**
  
  ```java
  public class ReferenceCountingGc {
      Object instance = null;
      public static void main(String[] args) {
          ReferenceCountingGc objA = new ReferenceCountingGc();
          ReferenceCountingGc objB = new ReferenceCountingGc();
          objA.instance = objB;
          objB.instance = objA;
          objA = null;
          objB = null;
      }
  } 
  ```

## 可达性分析算法

- 该算法的基本思想就是通过一系列称为**“GC Roots"**的对象作为起点，从这些节点开始**向下搜索**，节点所走过的**路径** 称为**引用链**，当一个对象到GC Roots**没有任何引用链**相连的话，证明该对象不可用，需要**被回收**
  下图中由于Object 6 ~ Object 10之间有引用关系，但它们到GC不可达，所以需要被回收
  ![可达性分析算法](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/jvm-gc-roots.d187e957.png)

- 哪些对象可以作为GC Roots呢

  1. 虚拟机栈（栈帧中的**本地变量表**）中引用的对象
  2. 本地方法栈（**Native方法**）中引用的对象
  3. 方法区中**类静态属性**引用的对象 （Class 的static变量）
  4. 方法区中**常量**引用的变量（Class 的final static变量）
  5. 所有被**同步锁持有的对象** （synchronized(**obj**))

- 对象可以被回收，就代码一定会被回收吗
  即使在可达性分析法中不可达的对象，也并非是“非死不可”的，这时候它们**暂时处于“缓刑阶段”**，要真正宣告一个对象死亡，至少要经历两次标记过程：

  1. 可达性分析中**不可达的对象被第一次标记**并且进行**一次筛选**：筛选的条件是此对象是否有必要执行finalize方法（有必要则放入）  
     当对象**没有覆盖finalize**方法，或**finalize方法已经被虚拟机调用**过，则虚拟机将两种情况视为**没有必要**执行，该对象会被**直接回收**

  2. 如果这个对象被判定为**有必要执行finalize()**方法，那么这个对象将会被**放置在一个叫做F-Queue的队列**中，然后由Finalizer线程去执行。GC将会**对F-Queue中的对象进行第二次标记**，如果对象**在finalize()方法中重新与引用链上的任何一个对象建立关联**，那么在**第二次标记时将会被移除“即将回收”的集合**，否则该对象将会被回收。

     （比如：**把自己（this关键字）赋值给某个类变量(static修饰)或者对象的成员变量**(在finalize方法中) ）

  > `Object` 类中的 `finalize` 方法一直被认为是一个糟糕的设计，成为了 Java 语言的负担，影响了 Java 语言的安全和 GC 的性能。JDK9 版本及后续版本中各个类中的 `finalize` 方法会被逐渐弃用移除。忘掉它的存在吧！

## 引用类型总结

- 不论是通过**引用计数法**判断对象引用数量，还是通过**可达性分析法**判断对象的引用链是否可达，判定对象的存活都与**”引用“**有关
- JDK1.2 之前，Java中**引用**的定义很传统：如果**reference类型的数据存储**的数值代表的是**另一块内存的起始地址**，就称这块内存代表**一个引用**
- JDK1.2 之后，Java对引用的概念进行了扩充，将引用(具体)分为**强引用**、**软引用**、**弱引用**、**虚引用**四种（引用强度**逐渐减弱**）  
  1. **强引用**（Strong Reference）
     
     > - 大部分引用实际上是**强引用**。如果对象具有强引用，那么类似于生活中**必不可少**，垃圾回收器**绝不会回收**它
     > - 内存空间不足时，宁愿抛出**OutOfMemoryErro**错误，使程序异常终止，也不会回收**强引用**对象解决**对象内存不足**
     
  2. **软引用**（SoftReference）
  
     > - 如果对象**只**具有软引用，那就类似**可有可无**的生活用品。
     > - 内存够则不会回收；内存不足则回收这些对象。只要垃圾回收器没有回收，那么对象就可以**被程序使用**。
     > - 软引用可用来实现**内存敏感**的**高速缓存**
     > - 软引用可以和一个**引用队列（ReferenceQueue）**联合使用，如果软引用所引用的对象被垃圾回收，Java虚拟机就会把这个软引用加入到**与之关联**的引用队列中
  
  3. **弱引用**（WeakReference）
  
     > - 如果对象**只**具有弱引用，则类似于**可有可无**的生活用品
     > - 弱引用和软引用的区别：只具有弱引用的对象拥有**更短暂**的生命周期
     > - 垃圾回收器线程**扫描**它所管辖的内存区域的**过程中**，一旦发现只具有**弱引用**的对象，不管当前内存**足够与否**，都会回收它的内存。不过垃圾回收器是一个**优先级很低**的线程，因此不一定会很快发现那些**只具有弱引用**的对象
     > - 弱引用可以和一个**引用队列（ReferenceQueue）**联合使用，如果**弱引用所引用的对象**被垃圾回收，Java虚拟机就会把这个弱引用**加入到与之关联的引用队列**中
  
  4. **虚引用**（PhantomReference）
     ```[ˈfæntəm] 英```
  
     > 与其他引用不同，**虚引用并不会决定对象声明周期**。如果一个**仅持有**虚拟引用，那么它就跟**没有任何**引用一样，在任何时候都可能被垃圾回收
  
     虚引用主要用来**跟踪对象被垃圾回收的活动**
  
  5. 虚引用、软引用和弱引用的区别：**虚引用必须和引用队列（ReferenceQueue）联合使用**。
  
     - 当垃圾回收器**准备回收**一个对象时，如果发现它还有虚引用，就会在回收对象的内存**之前**，把这个虚引用加入到**与之关联**的引用队列。
     - 程序可以通过**判断引用队列是否加入虚引用**，来了解被引用的对象是否**将**被垃圾回收
     - 如果发现某个虚引用已经被加入到引用队列，那么就可以在所引用的对象**被回收之前**采取必要的行动
  
  6. 在程序设计中一般很少使用弱引用与虚引用，使用软引用的情况较多，这是因为**软引用可以加速 JVM 对垃圾内存的回收速度，可以维护系统的运行安全，防止内存溢出（OutOfMemory）等问题的产生**  
  
     > ThreadLocal中的key用到了弱引用  

## 如何判断一个常量是废弃常量

运行时常量池主要回收的是**废弃的常量**

> 1. JDK1.7 之前，**运行时常量池逻辑**，包括字符串常量池，存放在**方法区**，此时hotspot虚拟机对**方法区**的实现为**永久代**
> 2. JDK1.7字符串常量池（以及静态变量）被**从方法区**拿到了**堆**中，这里没有提到运行时常量池，也就是说**字符串常量池**被单独拿到堆，运行时常量池剩下的东西，**还在方法区**。即hotspot中的**永久代**
> 3. JDK1.8 hotspot移除了永久代，用**元空间Metaspace**取代之，这时候**字符串常量池**还在堆，**运行时常量池**还在方法区，只不过**方法区的实现**从永久代变成了**元空间Metaspace**

★★ 假如**字符串常量池**存在字符串“abc”，如果当前没有任何String对象**引用该字符串常量**的话，就说明常量“abc”是废弃常量。如果这时发生内存回收并且**有必要**的话，“abc”就会被系统**清理出**常量池

## 如何判断一个类是无用类

- **方法区**主要回收的是**无用的类**，判断一个类是否是**无用的类**相对苛刻，需要同时满足下面**条件**

  - 该类所有实例都已经被回收，即**Java堆中不存在该类的任何实例**
  - 加载该类的**ClassLoader**已经被回收
  - 该类对应的**java.lang.Class**对象没有在任何地方被引用，**无法**在任何地方**通过反射**访问该类方法

  Java虚拟机**可以**对**满足上述3个条件**的无用类进行回收，是**“可以”**，而**不是必然**

# 垃圾收集算法

## 标记-清除算法

该算法分为**“标记”**和**“清除”**阶段：  
标记出所有**不需要回收的对象**，在标记完成后**统一回收掉所有没有被标记**的对象

这是**最基础**的**收集算法**，后续的算法都是对其不足进行改进得到，有两个明显问题：

1. **效率问题**
2. **空间问题**（标记清除后会产生**大量不连续碎片**）

![image-20230311171414048](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230311171414048.png)

## 标记-复制算法

- 将内存分为**大小相同的两块**，每次**使用其中一块** 
- 当这块**内存使用完后**，就将还存活的对象**复制到另一块**去，然后再把**使用的空间一次清理掉**
- 这样每次内存**回收**都是对内存区间的一半**进行回收**

![复制算法](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/90984624.e8c186ae.png)

## 标记-整理算法

根据老年代特点提出的一种**标记算法**，**标记过程**仍然与**“标记-清除”**算法一样，但后续不是直接对可回收对象回收，而是让**所有存活对象向一端移动**，然后直接**清理掉端边界以外的内存**

![标记-整理算法 ](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/94057049.22c58294.png)

## 分代收集算法

- 当前虚拟机的垃圾收集都采用**分代收集算法**，没有新的思想，只是**根据对象存活周期的不同**将内存分为几块。

  > 对象存活周期，也就是有些对象活的时间短，有些对象活的时间长。
- 一般将Java堆分为**新生代**和**老年代**，这样就可以**根据各个年代的特点**，选择合适的**垃圾收集算法**
  - **新生代**中，每次收集都会有大量对象死去，所以可以选择**“标记-复制”**算法，只需要付出少量**对象的复制成本**就可以完成**每次垃圾收集**
  - **老年代**对象存活几率是比较高的，而且**没有额外的空间对它进行分配担保**，所以必须选择**标记-清除**或者**“标记-整理”**算法进行垃圾收集

# 垃圾收集器

- **收集算法**是内存回收的**方法论**，而**垃圾收集器**则是内存回收的**具体实现**
- 没有**最好的**垃圾收集器，也没有**万能的**，应该**根据具体应用场景**，选择适合自己的**垃圾收集器**

## 汇总

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/11e9dcd0f1ee4f25836e6f1c47104c51-new-image69e1c56a-1d40-493a-9901-6efc647a01f3.png)

> - 新生代的垃圾回收器：Serial（串行--标记复制），ParNew（并行--标记复制），ParallelScavenge（并行--标记复制）
> - 老年代的垃圾回收器：SerialOld（串行--标记整理），ParallelOld（并行--标记整理），CMS（并发--标记清除）
> - 只有CMS和G1是并发，且CMS只作用于老年代，而G1都有
> - JDK8为止，默认垃圾回收器是Parallel Scavenge和Parallel Old【**并行--复制**和**并行--标记整理**】
> - JDK9开始，G1收集器成为默认的垃圾收集器，目前来看，G1回收期停顿时间最短且没有明显缺点，偏适合Web应用
>
> > jdk8中测试Web应用，堆内存6G中新生代4.5G的情况下
> >
> > - ParallelScavenge回收新生代停顿长达1.5秒。
> > - G1回收器回收同样大小的新生代只停顿0.2秒

## Serial 收集器

- Serial 串行 收集器是**最基本**、**历史最悠久**的垃圾收集器

- 这是一个**单线程收集器**，它的**单线程**意义不仅意味着它只会使用**一条垃圾收集线程**去完成垃圾收集工作，更重要的是它在**进行垃圾收集工作时**必须暂停其他所有的工作线程**（”Stop The World“）**，直到它**收集结束**。

  - 新生代采用**标记-复制**算法，老年代采用**标记-整理**算法
    ![ Serial 收集器 ](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/46873026.3a9311ec.png)
  - StopTheWorld会带来**不良用户体验**，所以在后续垃圾收集器设计中**停顿时间不断缩短**。（仍然有停顿，垃圾收集器的过程仍然在继续）
  - 优点：**简单而高效**（与其他收集器的单线程相比）  
    1. 且由于其**没有线程交互**的开销，自然可以获得**很高的单线程收集效率**
    2. Serial收集器对于**运行在Client模式**下的虚拟机来说是个不错的选择

- ```shell
  -XX:+UseSerialGC  #虚拟机运行在Client模式下的默认值，Serial+Serial Old。
  ```

## ParNew 收集器

- **ParNew**收集器其实就是**Serial收集器**的**多线程版本**，除了使用**多线程**进行垃圾收集外，其余行为（**控制参数**、**收集算法**、**回收策略**等等）和**Serial收集器**完全一样

- **新生代**采用**标记-复制**算法，**老年代**采用**标记-整理**算法

  ![ParNew 收集器 ](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/22018368.df835851.png)
  ★★★  这是许多运行在Server模式下的虚拟机的首要选择，除了**Serial收集器**外，只有它能与**CMS收集器**（真正意义上的**并发**收集器）配合工作（**ParNew是并行**）

- **并行和并发**概念补充

  - **并行（Parallel）**：指**多条垃圾收集线程**并行工作，但此时用户线程仍然处于**等待**状态
  - **并发（Concurrent）**：指**用户线程**与**垃圾收集线程** **同时**执行（不一定并行，可能会交替执行），**用户程序在继续执行**，而**收集收集器**运行在另一个CPU上

- ```shell
  -XX:+UseParNewGC  #ParNew+Serial Old，在JDK1.8被废弃，在JDK1.7还可以使用。
  ```

## ParallelScavenge 收集器

- 它也是**标记-复制**算法的多线程收集器，看上去几乎和**ParNew**一样，**区别**

  - 部分**参数** (有点争议，先以下面为准)

      ```shell
      -XX:+UseParallelGC  # 虚拟机运行在Server模式下的默认值(1.8) 新生代使用ParallelGC，老年代使用回收器 ; ★★ JDK1.7之后，能达到UseParallelOldGC 的效果 
      ## 参考自 https://zhuanlan.zhihu.com/p/353458348 
      
      
      -XX:+UseParallelOldGC # 新生代使用ParallelGC，老年代使用ParallelOldGC
    ```
  
  - **Parallel Scavenge**收集器关注点是**吞吐量（高效率利用CPU）**，**CMS**等垃圾收集器关注点是用户的**停顿时间**（提高用户体验）

    > 所谓**吞吐量**就是CPU中用于**运行用户代码的时间**与**CPU**总消耗时间的**比值** 
    > （也就是**希望**消耗少量CPU就能**运行更多代码**）
  
  -  Parallel Scavenge 收集器提供了很多参数供用户找到**最合适的停顿时间**或**最大吞吐量**，如果对于收集器运作不太了解，手工优化存在困难的时候，使用 **Parallel Scavenge 收集器**配合**自适应调节策略**，把**内存管理优化**交给虚拟机去完成也是一个不错的选择。
  
  - 新生代采用**标记-复制**，老年代采用**标记-整理**算法
      ![image-20221215170900774](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221215170900774.png)
  
- 这是JDK1.8 的默认收集器
  使用 java -XX:+PrintCommandLineFlags -version 命令查看
  如下，两种情况：

  ```shell
  #默认
  λ java -XX:+PrintCommandLineFlags -version
  -XX:InitialHeapSize=531924800 -XX:MaxHeapSize=8510796800 -XX:+PrintCommandLineFlags -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:-UseLargePagesIndividualAllocation -XX:+UseParallelGC
  java version "1.8.0_202"
  Java(TM) SE Runtime Environment (build 1.8.0_202-b08)
  Java HotSpot(TM) 64-Bit Server VM (build 25.202-b08, mixed mode)
  ```

  第二种情况：(注意：```-XX:-UseParallelOldGC```)

  ```shell
  λ java -XX:-UseParallelOldGC -XX:+PrintCommandLineFlags -version
  -XX:InitialHeapSize=531924800 -XX:MaxHeapSize=8510796800 -XX:+PrintCommandLineFlags -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:-UseLargePagesIndividualAllocation -XX:+UseParallelGC -XX:-UseParallelOldGC
  
  java version "1.8.0_202"
  Java(TM) SE Runtime Environment (build 1.8.0_202-b08)
  Java HotSpot(TM) 64-Bit Server VM (build 25.202-b08, mixed mode)
  ```

## SerialOld 收集器

- Serial收集器的**老年代版本**，是一个**单线程**收集器
  1. 在JDK1.5以及以前的版本中，**与Parallel Scavenge收集器搭配**时候
  2. 作为CMS收集器的**后备方案**

## ParallelOld 收集器

- Parallel Scavenge收集器的老年代版本，使用**多线程**和**标记-整理**算法
  1. 在注重**吞吐量**以及**CPU资源**的场合，都可以考虑**ParallelScavenge**和**ParallelOld**收集器

## CMS 收集器

- CMS，Concurrent Mark Sweep，是一种以**获取最短回收停顿时间**为目标的收集器，非常符合**注重用户体验**的引用上使用

- CMS收集器是HotSpot虚拟机上**第一款**真正意义上的**并发**收集器，第一次实现了**让垃圾收集线程**与**用户线程**（基本上）同时工作

- Mark-Sweep，是一种“**标记-清除**”算法，运作过程相比前面几种垃圾收集器来说更加复杂，步骤：

  1. 初始标记：暂停所有其他线程，**记录直接与root相连的对象**，速度很快

  2. 并发标记：**同时** 开启GC和用户线程 ，用一个**闭包结构记录可达对象**。但这个阶段结束，这个闭包结构并**不能保证包含当前所有的可达对象**。

     > 因为用户线程会不断更新引用域，所以GC线程**无法保证可达性分析的实时性**

     所以这个算法里会**跟踪记录**这些发生引用更新的地方

  3. 重新标记：目的是**修正并发标记期间**因为用户程序继续运行而**导致标记产生变动**的那一部分对象的**标记记录**。

     > 这个阶段**停顿时间**一般会被初始标记阶段**时间稍长**，远远比**并发标记阶段**时间短

  4. 并发清除：**开启用户线程**，同时**GC线程**开始对未扫描的区域做清扫

  ![CMS 垃圾收集器 ](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/CMS%25E6%2594%25B6%25E9%259B%2586%25E5%2599%25A8.8a4d0487.png)

- 从名字可以看出这是一款优秀的收集器：**并发收集**、**低停顿**。但有三个明显缺点

  1. **对CPU资源敏感**

  2. 无法处理浮动垃圾

     > 浮动垃圾的解释：就是之前被gc 标记为 可达对象，也就是 存活对象，在两次gc线程之间被业务线程删除了引用，那么颜色不会更改，还是之前的颜色（黑色or灰色），但是其实是白色，所以这一次gc 无法对其回收，需要等下一次gc初始标记启动才会被刷成白色
     > ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/13864094-053f50032b4cdfad.png)
     >
     > 作者：Yellowtail
     > 链接：https://www.jianshu.com/p/6590aaad82f7
     > 来源：简书 

  3. 它使用的收集算法**“标记-清除”**算法会导致收集结束时会有**大量空间碎片产生**

## G1 收集器

G1(Garbage-First)，是一款**面向服务器**的垃圾收集器，主要针对**配备多颗处理器**以及**大容量内存**的极其，以**极高概率**满足GC停顿时间要求的同时，还具备**高吞吐量性能**特征

- **JDK1.7**中HotSpot虚拟机的一个**重要进化特征**，具备特点：

  1. 并行与并发：

     > G1 能充分利用 CPU、多核环境下的硬件优势，**使用多个 CPU（CPU 或者 CPU 核心）来缩短 Stop-The-World 停顿时间**。部分其他收集器原本需要停顿 Java 线程执行的 GC 动作，G1 收集器仍然可以通过并发的方式让 java 程序继续执行

  2. 分代收集：

     > 虽然 G1 可以**不需要其他收集器配合**就能独立管理整个 GC 堆，但是还是保留了分代的概念。

  3. 空间整合：

     > 与 CMS 的“标记-清理”算法不同，G1 **从整体来看**是基于**“标记-整理”**算法实现的收集器；从**局部**上来看是基于**“标记-复制”**算法实现的。

  4. 可预测的停顿：

     > 这是 G1 相对于 CMS 的另一个大优势，降低停顿时间是 G1 和 CMS 共同的关注点，但 G1 除了追求低停顿外，还能建立可预测的停顿时间模型，能**让使用者明确指定在一个长度为 M 毫秒的时间片段**内。

- G1 收集器的运作大致分为以下几个步骤

  1. **初始标记**
  2. **并发标记**
  3. **最终标记**
  4. **筛选回收**

- G1 收集器在后台**维护了一个优先列表**，每次**根据允许的收集时间**，**优先选择回收价值最大的 Region**(这也就是它的名字 **Garbage-First 的由来**) 。这种**使用 Region 划分内存空间**以及**有优先级的区域回收方式**，，保证了 G1 收集器在**有限时间内**可以尽可能高的收集效率（**把内存化整为零**）

## ZGC 收集器

```The Z Garbage Collector```

**与 CMS 中的 ParNew 和 G1 类似，ZGC 也采用标记-复制算法**，不过 ZGC 对该算法做了重大改进。

在 ZGC 中出现 Stop The World 的情况会更少！

JDK11，相关文章 https://tech.meituan.com/2020/08/06/new-zgc-practice-in-meituan.html