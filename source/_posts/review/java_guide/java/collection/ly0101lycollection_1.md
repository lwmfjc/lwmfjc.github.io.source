---
title:  集合_1
description: 集合_1
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-集合
date: 2022-10-17 08:55:24
updated: 2022-10-17 08:55:24

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 集合包括`Collection`和```Map```，Collection 存放单一元素。Map 存放键值对
![image-20221017103340847](images/mypost/image-20221017103340847.png)

## List，Set，Queue，Map区别

- `List`(对付顺序的好帮手): 存储的元素是有序的、可重复的。
- `Set`(注重独一无二的性质): 存储的元素是无序的、不可重复的。
- `Queue`(实现排队功能的叫号机): 按特定的排队规则来确定先后顺序，存储的元素是有序的、可重复的。
- `Map`(用 key 来搜索的专家): 使用键值对（key-value）存储，类似于数学上的函数 y=f(x)，"x" 代表 key，"y" 代表 value，key 是无序的、不可重复的，value 是无序的、可重复的，每个键最多映射到一个值。
## 各种集合框架--底层数据结构
  - List
    - ArrayList、Vector  ---->  Object[] 数组
    - LinkedList  双向链表 (jdk 1.6 之前为循环链表, 1.7 取消了循环)
  - Set
    - HashSet （无序，唯一），且**基于HashMap**
    - LinkedHashSet  是HashSet的子类，基于**LinkedHashMap**
      (LinkedHashMap内部基于HashMap实现)
    - TreeSet(有序，唯一) ：红黑树（自平衡的排序二叉树）
  - Queue (队列)
    - PriorityQueue：Object[] 数组来实现二叉堆
    - ArrayQueue：Object[] 数组+ 双指针
  - Map 
    - `HashMap`： JDK1.8 之前 `HashMap` 由**数组+链表**组成的，数组是 `HashMap` 的主体，链表则是主要为了解决哈希冲突而存在的（“拉链法”解决冲突）。JDK1.8 以后在解决哈希冲突时有了较大的变化，当**链表长度大于阈值**（**默认为 8**）（将**链表转换成红黑树前**会判断，如果**当前数组的长度小于 64**，那么会选择**先进行数组扩容**，而不是转换为红黑树）时，将链表转化为红黑树，以减少搜索时间
    - `LinkedHashMap`： `LinkedHashMap` 继承自 `HashMap`，所以它的底层仍然是基于拉链式散列结构 即由**数组和链表或红黑树**组成。另外，`LinkedHashMap` 在上面结构的基础上，增加了一条双向链表，使得上面的结构可以**保持键值对的插入顺序**。同时通过对链表进行相应的操作，实现了**访问顺序**相关逻辑。   
    
      > ![img](images/mypost/15166338955699.jpg)
      >
      > 上图中，淡蓝色的箭头表示前驱引用，红色箭头表示后继引用。每当有新键值对节点插入，新节点最终会接在 **tail 引用指向的节点后面（感觉这句话有问题，应该是head引用指向旧结点上）**。而 tail 引用则会移动到新的节点上，这样一个双向链表就建立起来了。
      > 作者：田小波
      > 链接：https://www.imooc.com/article/22931 
    - `Hashtable`： 数组+链表组成的，数组是 `Hashtable` 的主体，链表则是主要为了解决哈希冲突而存在的
    - `TreeMap`： 红黑树（自平衡的排序二叉树）

## 如何选用集合

  - 当我们只需要存放元素值时，就选择实现`Collection` 接口的集合，需要保证**元素唯一**时选择实现 `Set` 接口的集合比如 `TreeSet` 或 `HashSet`，不需要就选择实现 `List` 接口的比如 `ArrayList` 或 `LinkedList`，然后再根据实现这些接口的集合的特点来选用
  - 需要根据**键值获取到元素值**时就选用 `Map` 接口下的集合，**需要排序**时选择 `TreeMap`,不需要排序时就选择 `HashMap`,需要保证**线程安全**就选用 **`ConcurrentHashMap`**。

## 为什么需要集合

  - 当需要保存一组类型相同的数据时，需要容器来保存，即**数组**，但实际中**存储的类型多样**， 而数组一旦声明则**不可变长**，同时数组**数据类型也确定**、**数组有序可重复**
  - 集合可以**存储不同类型不同数量**的对象，还可以保存具有**映射关系**的数据

## Collection 子接口

### List

- ArrayList和Vector区别：ArrayList是List主要实现类，底层使用Object[]存储线程不安全；Vector是List古老实现类，底层使用Object[]存储，线程安全 （**synchronized**关键字）

- ArrayList与LinkedList：

  - 都是线程不安全
  - ArrayList底层使用**Object数组**，LinkedList底层使用**双向链表**结构（JDK7以后非循环链表）
  - ArrayList采用数组存储，所以**插入和删除**元素的时间复杂度受位置影响；LinkedList采用**链表**，所以在**头尾插入或者删除**元素不受元素位置影响，而如果需要**插入或者删除中间**指定位置，则时间复杂度为**O(n) [主要是因为要遍历]**
  - LinkedList不支持**高效的随机元素**访问，而ArrayList支持（即通过元素的序号快速获取元素对象）
  - 内存空间占用：ArrayList的空间浪费主要体现在**List结尾会预留一定的容量**空间（**不是申请的所有容量都会用上**），而LinkedList的空间花费则体现在它的**每一个元素都需要消耗比ArrayList更多**的空间（存放直接后继、直接前驱及数据）

- 实际项目中不怎么使用LinkedList，因为ArrayList性能通常会更好，LinkedList**仅仅在头尾插入或者删除元素**的时间复杂度**近似O(1)**

- 双向链表与双向循环链表

  - 双向链表，包含两个指针，一个 prev 指向前一个节点，一个 next 指向后一个节点。
    ![image-20221017145140450](images/mypost/image-20221017145140450.png)
  - 双向循环链表，**首尾相连**（头节点的前驱=尾结点，尾结点的后继=头节点）

- 补充：RandomAccess接口，这个接口只是用来**标识**：**实现这个接口的类，具有随机访问功能**，但并不是说因为实现了该接口才具有的快速随机访问机制

  - Collections里面有这样一段代码  

    > 在 `binarySearch（)` 方法中，它要判断传入的 list 是否 `RandomAccess` 的实例，如果是，调用`indexedBinarySearch()`方法，如果不是，那么调用`iteratorBinarySearch()`方法
  
    ```java
        public static <T>
        int binarySearch(List<? extends Comparable<? super T>> list, T key) {
            if (list instanceof RandomAccess || list.size()<BINARYSEARCH_THRESHOLD)
                return Collections.indexedBinarySearch(list, key);
            else
                return Collections.iteratorBinarySearch(list, key);
      }
    ```
  
  - ArrayList实现了RandomAccess方法，而LinkedList没有。是由于ArrayList底层是数组，支持**快速随机访问**，时间复杂度为**O(1)**，而LinkedList底层是链表，不支持快速随机访问，时间复杂度为**O(n)**

### Set

- Coparable和Comparator的区别

  - Comparable实际出自```java.lang```包，有一个compareTo(Object obj)方法用来排序
  - Comparator实际出自```java.util```包，有一个compare(Object obj1,Object obj2)方法用来排序

- ``` Collections.sort(List<T> list, Comparator<? super T> c) ```默认是正序，T必须实现了Comparable，且```Arrays.sort()```方法中的部分代码如下：

  ```java
  //使用插入排序
          if (length < INSERTIONSORT_THRESHOLD) {
              for (int i=low; i<high; i++)
                  for (int j=i; j>low && c.compare(dest[j-1], dest[j])>0; j--) //如果前一个数跟后面的数相比大于零，则进行交换，即大的排后面
                      swap(dest, j, j-1);
              return;
          }
  //当比较结果>0时，调换数组前后两个元素的值，也就是后面的一定要比前面的大，即
      public int compareTo(Person o) {
          if (this.age > o.getAge()) {
              return 1;
          }
          if (this.age < o.getAge()) {
              return -1;
          }
          return 0;
      }
  //下面这段代码，按照年龄降序（默认是升序）
          Collections.sort(arrayList, new Comparator<Integer>() {
  
              @Override
              public int compare(Integer o1, Integer o2) {
                  //如果结果大于0，则两个数对调
                  //如果返回o2.compareTo(o1)，就是当o2>01时，两个结果对换，也就是降序
                  //如果返回o1.compareTo(o2)，就是当o1>o2时，两个结果对换，也就是升序   也就是当和参数顺序一致时，是升序；反之，则是降序
                  return o2.compareTo(o1); 
                  
              }
          });
  //上面这段代码，标识
  ```

- 无序性和不可重复性

  - 无序性，指存储的数据，在底层数据结构中，**并非按照数组索引的顺序**添加（而是**根据数据的哈希值**决定）
  - 不可重复性：指添加的元素**按照equals()判断时，返回false**。需**同时**重写**equals()**方法和**hashCode()** 方法

- 比较HashSet、LinkedHashSet和TreeSet三者异同

  - 都是Set实现类，保证**元素唯一**，且**非线程安全**
  - 三者底层数据结构不同，HashSet底层为**哈希表（HashMap）**; LinkedHashSet底层为**链表+哈希表** ，元素的插入和取出顺序满足**FIFO**。TreeSet底层为红黑树，元素**有序**，排序方式有**自然排序**和**定制排序**
    ![image-20221017170434986](images/mypost/image-20221017170434986.png)

## Queue

### Queue和Deque的区别

![image-20221017170659204](images/mypost/image-20221017170659204.png)

- Queue
  - Queue为单端队列，只能**从一端插入**元素，**另一端删除**元素，实现上一般遵循**先进先出（FIFO）**规则【Dequeue为双端队列，在队列两端均可**插入或删除**元素】
  - Queue扩展了Collection接口，根据**因容量问题而导致操作失败后的处理方式不同**分两类，操作失败后**抛异常**或**返回特殊值**
    ![image-20221017172811954](images/mypost/image-20221017172811954.png)
  - Dequeue，双端队列，在队列**两端均可插入**或**删除**元素，也会根据失败后处理方式分两类
    Deque还有push()和pop()等其他方法，可用于模拟栈
    ![image-20221017173058398](images/mypost/image-20221017173058398.png)

### ArrayDeque与LinkedList区别

- ArrayDeque和LinkedList**都实现了Deque**接口，两者**都具有队列**功能
- ArrayDeque**基于可变长的数组**和**双指针**来实现，而**LinkedList则通过链表**来实现
- ArrayDeque**不支持存储NULL**数据，但**LinkedList支持**
- ArrayDeque是后面（JDK1.6)引入的，而LinkedList在JDK1.2就存在
- `ArrayDeque` 插入时可能存在扩容过程, 不过**均摊后的插入操作依然为 O(1)**。虽然 `LinkedList` 不需要扩容，但是**每次插入数据时均需要申请新的堆空间**，均摊性能相比更慢。

总的来说，ArrayDeque来实现队列要比LinkedList更好，此外，ArrayDeque也可以用于实现栈

### 说一说PriorityQueue

`PriorityQueue` 是在 JDK1.5 中被引入的, 其与 `Queue` 的区别在于**元素出队顺序**是**与优先级相关**的，即总是**优先级最高的元素先出队**。

这里列举其相关的一些要点：

- `PriorityQueue` 利用了**二叉堆**的数据结构来实现的，底层使用**可变长的数组**来存储数据
- `PriorityQueue` 通过堆元素的**上浮**和**下沉**，实现了在 **O(logn) 的时间复杂度内插入**元素和**删除**堆顶元素。
- `PriorityQueue` 是**非线程安全**的，且不支持存储 `NULL` 和 `non-comparable` 的对象。
- `PriorityQueue` **默认是小顶堆**，但**可以接收一个 `Comparator`** 作为构造参数，从而来自定义元素优先级的先后。
