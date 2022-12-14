---
title: java垃圾回收器
description: java垃圾回收器
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-jvm
date: 2022-12-12 15:58:48
updated: 2022-12-12 15:58:48
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
> - 假设大对象最后不会晋升老年代，新生代空间是有限的，在新生代里的对象大部分都是朝生夕死的，如果让一个大对象占据了新生代空间，那么相比起正常的对象被分配在新生代，大对象无疑会让新生代GC提早发生，因为内存空间会更快不够用，如果这个大对象因为业务原因，并不会马上被GC回收，那么这个对象就会进入到Survivor区域，默认情况下，Survivor区域本来就不会被分配的很大，那此时被大对象占据了大部分空间，很可能会导致之后的新生代GC后，存活下来的对象，Survivor区域空间不够放不下，导致大部分对象进入老年代，这就加快了老年代GC发生的时间，而老年代GC对系统性能的负面影响则远远大于新生代GC了。 

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
  3. 方法区中**类静态属性**引用的对象
  4. 方法区中**常量**引用的变量
  5. 所有被**同步锁持有的对象**

- 对象可以被回收，就代码一定会被回收吗
  即使在可达性分析法中不可达的对象，也并非是“非死不可”的，这时候它们**暂时处于“缓刑阶段”**，要真正宣告一个对象死亡，至少要经历两次标记过程：

  1. 可达性分析中**不可达的对象被第一次标记**并且进行**一次筛选**：筛选的条件是此对象是否有必要执行finalize方法（有必要则放入）  
     当对象**没有覆盖finalize**方法，或**finalize方法已经被虚拟机调用**过，则虚拟机将两种情况视为**没有必要**执行，该对象会被**直接回收**

  2. 如果这个对象被判定为**有必要执行finalize()**方法，那么这个对象将会被**放置在一个叫做F-Queue的队列**中，然后由Finalizer线程去执行。GC将会**对F-Queue中的对象进行第二次标记**，如果对象**在finalize()方法中重新与引用链上的任何一个对象建立关联**，那么在**第二次标记时将会被移除“即将回收”的集合**，否则该对象将会被回收。

     （比如：把自己（this关键字）赋值给某个类变量(static修饰)或者对象的成员变量）

  > `Object` 类中的 `finalize` 方法一直被认为是一个糟糕的设计，成为了 Java 语言的负担，影响了 Java 语言的安全和 GC 的性能。JDK9 版本及后续版本中各个类中的 `finalize` 方法会被逐渐弃用移除。忘掉它的存在吧！

## 引用类型总结

- 不论是通过**引用计数法**判断对象引用数量，还是通过**可达性分析法**判断对象的引用链是否可达，判定对象的存活都与**”引用“**有关
- JDK1.2 之前，Java中**引用**的定义很传统：如果**reference类型的数据存储**的数值代表的是**另一块内存的起始地址**，就称这块内存代表**一个引用**
- JDK1.2 之后，Java对引用的概念进行了扩充，将引用(具体)分为**强引用**、**软引用**、**弱引用**、**虚引用**四种（引用强度**逐渐减弱**）  
  1. **强引用**（Strong Reference）
     
  2. **软引用**（SoftReference）
  3. **弱引用**（WeakReference）
  4. **虚引用**（PhantomReference）

## 如何判断一个常量是废弃常量

## 如何判断一个类是无用类

# 垃圾收集算法

## 标记-清除算法

## 标记-复制算法

## 标记-整理算法

## 分代收集算法

# 垃圾收集器