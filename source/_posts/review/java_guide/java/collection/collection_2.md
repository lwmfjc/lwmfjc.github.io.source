---
title: ly0002ly集合_2
description: 集合_2
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-集合
date: 2022-10-18 08:54:49
updated: 2022-10-18 08:54:49

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!



## Map

- HashMap和Hashtable的区别
  - **HashMap是非线程安全**的，**Hashtable是线程安全**的，因为Hashtable内部方法**都经过synchronized**修饰（不过要保证线程安全**一般用ConcurrentHashMap**）
  
  - 由于加了synchronized修饰，HashTable**效率**没有HashMap高
  
  - HashMap**可以存储null的key和value**，但**null作为键**只能有一个**；**HashTable**不允许有null键和null值**
  
  - 初始容量及每次扩容
    - **Hashtable默认初始大小11**，之后**扩容为2n+1**;HashMap**初始大小16**，之后**扩容变为原来的2倍**
    - 如果指定初始大小，HashTable直接使用初始大小  
      而`HashMap` 会将其**扩充为 2 的幂次方**大小（`HashMap` 中的**`tableSizeFor()`**方法保证，下面给出了源代码）。也就是说 `HashMap` 总是使用 2 的幂作为哈希表的大小,后面会介绍到为什么是 2 的幂次方
    
  - 底层数据结构
    
    - JDK1.8之后**HashMap**解决哈希冲突时，当**链表大于阈值（默认8）**时，将链表**转为红黑树**（转换**前**判断，如果当前**数组长度小于64**，则**先进行数组扩容**，而不转成红黑树），以减少搜索时间。
    - Hashtable**没有**上面的机制
    
    ```java
    /**
    HashMap 中带有初始容量的构造函数：
    */
    public HashMap(int initialCapacity, float loadFactor) {
            if (initialCapacity < 0)
                throw new IllegalArgumentException("Illegal initial capacity: " +
                                                   initialCapacity);
            if (initialCapacity > MAXIMUM_CAPACITY)
                initialCapacity = MAXIMUM_CAPACITY;
            if (loadFactor <= 0 || Float.isNaN(loadFactor))
                throw new IllegalArgumentException("Illegal load factor: " +
                                                   loadFactor);
            this.loadFactor = loadFactor;
            this.threshold = tableSizeFor(initialCapacity);
        }
         public HashMap(int initialCapacity) {
            this(initialCapacity, DEFAULT_LOAD_FACTOR);
        } 
    
    /*下面这个方法保证了 HashMap 总是使用 2 的幂作为哈希表的大小。*/
    /**
         * Returns a power of two size for the given target capacity.
         */
        static final int tableSizeFor(int cap) {
            int n = cap - 1;
            n |= n >>> 1;
            n |= n >>> 2;
            n |= n >>> 4;
            n |= n >>> 8;
            n |= n >>> 16;
            return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
        } 
    ```
  
- HashMap和hashSet区别

  > 如果你看过 `HashSet` 源码的话就应该知道：`HashSet` 底层就是基于 `HashMap` 实现的。（`HashSet` 的源码非常非常少，因为除了 `clone()`、`writeObject()`、`readObject()`是 `HashSet` 自己不得不实现之外，其他方法都是直接调用 `HashMap` 中的方法

  - HashSet底层就`HashMap` 会将其扩充为 2 的幂次方大小（`HashMap` 中的`tableSizeFor()`方法保证，下面给出了源代码）。也就是说 `HashMap` 总是使用 2 的幂作为哈希表的大小,后面会介绍到为什么是 2 的幂次方是HashMap实现的
  - HashMap：实现了Map接口；存储**键值对**；调用put()向map中添加元素；**HashMap使用键（key）计算hashcode**
  - HashSet：实现Set接口；仅**存储对象**；调用add()方法向Set中添加元素；HashSet使用**成员对象**计算hashCode，对于不相等两个对象来说 **hashcode也可能相同**，所以**还要再借助equals()**方法判断对象相等性

- HashMap和TreeMap
  navigable 英[ˈnævɪɡəbl] 通航的，可航行的  
  HashMap和TreeMap都继承自AbstractMap  
  TreeMap还实现了NavigableMap （**对集合内元素搜索**）和SortedMap（对集合内元素**根据键排序**，默认key升序，可指定排序的比较器）接口  
  
1. 实现 `NavigableMap` 接口让 `TreeMap` 有了**对集合内元素的搜索**的能力。
  
  2. 实现`SortedMap`接口让 `TreeMap` 有了对**集合中的元素根据键排序**的能力。默认是按 key 的升序排序，不过我们也可以指定排序的比较器。示例代码如下： 
  
     ```java
     /**
      * @author shuang.kou
      * @createTime 2020年06月15日 17:02:00
      */
     public class Person {
         private Integer age;
     
         public Person(Integer age) {
             this.age = age;
         }
     
         public Integer getAge() {
             return age;
         }
     
     
         public static void main(String[] args) {
             TreeMap<Person, String> treeMap = new TreeMap<>(new Comparator<Person>() {
                 @Override
                 public int compare(Person person1, Person person2) {
                     int num = person1.getAge() - person2.getAge();
                     return Integer.compare(num, 0);
                 }
             });
             treeMap.put(new Person(3), "person1");
             treeMap.put(new Person(18), "person2");
             treeMap.put(new Person(35), "person3");
             treeMap.put(new Person(16), "person4");
             treeMap.entrySet().stream().forEach(personStringEntry -> {
                 System.out.println(personStringEntry.getValue());
             });
         }
     }
     //输出
     /**person1
     person4
     person2
      person3
     **/
     ```

- HashSet如何检查重复

  - 当在HashSet加入对象时，**先计算对象hashcode值**判断加入位置，同时与其他加入对象的hashcode值比较，如果没有相同的，会假设对象没有重复出现；如果发现有**相同的hashcode值**的对象，则**调用equals()方法**检查hashcode相等的对象是否真的相等，如果相等则不会加入

  - JDK1.8中，**HashSet的add()方法调用了HashMap的put()方法**，并判断是否有重复元素（返回值是否null)

    ```java
    // Returns: true if this set did not already contain the specified element
    // 返回值：当 set 中没有包含 add 的元素时返回真
    public boolean add(E e) {
            return map.put(e, PRESENT)==null;
    }
    //下面为HashMap的源代码
    
    // Returns : previous value, or null if none
    // 返回值：如果插入位置没有元素返回null，否则返回上一个元素
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                       boolean evict) {
    ...
    }
    ```

- HashMap底层实现

  - JDK1.8之前，底层是**数组和链表**结合在一起使用，即**链表散列**。通过**key的hashcode** **经过扰动函数处理后得到hash**值，并通过 **(n-1) & hash** 判断当前元素存放的位置 （n为数组长度），如果当前位置存在元素的话，就判断该元素与要存入的元素的hash值以及key是否相同，**如果相同则覆盖，不同则通过拉链法解决冲突**
    扰动函数指的是HashMap的hash方法，是为了**防止一些实现比较差的hashCode方法**，减少碰撞
    JDK1.8的hash：如果**key为null则返回空**，否则使用 (**key的hash值**) 与 (**hash值右移16位**) 做**异或**操作

    ```java
        static final int hash(Object key) {
          int h;
          // key.hashCode()：返回散列值也就是hashcode
          // ^ ：按位异或
          // >>>:无符号右移，忽略符号位，空位都以0补齐
          return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
      }
    ```

    JDK1.7扰动次数更多 

    ```java
    static int hash(int h) {
        // This function ensures that hashCodes that differ only by
        // constant multiples at each bit position have a bounded
        // number of collisions (approximately 8 at default load factor).
    
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }
    ```

    拉链法即**链表和数组**结合，也就是创建一个链表数组，**数组每一格为一个链表**，如果**发生哈希冲突**，就将**冲突的值添加到链表**中即可

    ![image-20221019143906992](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019143906992.png)

  - JDK8之后，解决冲突发生了较大变化，当链表长度大于阈值（默认是8）（如果数组小于64，则只会进行扩容；如果不是，才转成红黑树）时，将链表转换成红黑树，以减少搜索时间
    ![image-20221019144049952](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019144049952.png)
    **二叉查找树**，在某些情况下会**退化成线性**结构，时间复杂度为n ，而**红黑树趋于log n** 。TreeMap、TreeSet以及1.8之后的HashMap都用到了红黑树

  - 代码

    ```java
    //当链表长度大于8时，执行treeifyBin（转换红黑树）
    // 遍历链表
    for (int binCount = 0; ; ++binCount) {
        // 遍历到链表最后一个节点
        if ((e = p.next) == null) {
            p.next = newNode(hash, key, value, null);
            // 如果链表元素个数大于等于TREEIFY_THRESHOLD（8）
            if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                // 红黑树转换（并不会直接转换成红黑树）
                treeifyBin(tab, hash);
            break;
        }
        if (e.hash == hash &&
            ((k = e.key) == key || (key != null && key.equals(k))))
            break;
        p = e;
    }
    
    //判断是否会转成红黑树
    final void treeifyBin(Node<K,V>[] tab, int hash) {
        int n, index; Node<K,V> e;
        // 判断当前数组的长度是否小于 64
        if (tab == null || (n = tab.length) < MIN_TREEIFY_CAPACITY)
            // 如果当前数组的长度小于 64，那么会选择先进行数组扩容
            resize();
        else if ((e = tab[index = (n - 1) & hash]) != null) {
            // 否则才将列表转换为红黑树
    
            TreeNode<K,V> hd = null, tl = null;
            do {
                TreeNode<K,V> p = replacementTreeNode(e, null);
                if (tl == null)
                    hd = p;
                else {
                    p.prev = tl;
                    tl.next = p;
                }
                tl = p;
            } while ((e = e.next) != null);
            if ((tab[index] = hd) != null)
                hd.treeify(tab);
        }
    }
    ```

- HashMap的长度为为什么是2的幂次方

  1. 为了能让 HashMap 存取高效，尽量较少碰撞，也就是要**尽量把数据分配均匀**。我们上面也讲到了过了，Hash 值的范围值-2147483648 到 2147483647，前后加起来大概 40 亿的映射空间，只要**哈希函数映射得比较均匀松散**，一般应用是**很难出现碰撞**的。但问题是一个 40 亿长度的数组，内存是放不下的。所以这个**散列值是不能直接拿来用**的（也就是这个数组**不能直接拿来用**）。

  2. 用之前还要先**做对数组的长度取模**运算，**得到的余数**才能用来要存放的位置也就是对应的数组下标。这个数组下标的计算方法是“ `(n - 1) & hash`”。（n 代表数组长度）。这也就解释了 HashMap 的长度为什么是 2 的幂次方。

  **这个算法应该如何设计呢？**

  我们首先可能会想到采用%取余的操作来实现。但是，重点来了：**“取余(%)操作中如果除数是 2 的幂次则等价于与其除数减一的与(&)操作（也就是说 hash%length==hash&(length-1)的前提是 length 是 2 的 n 次方；）。”** 并且 **采用二进制位操作 &，相对于%能够提高运算效率，这就解释了 HashMap 的长度为什么是 2 的幂次方。**

- HashMap多线程操作导致死循环问题
  多线程下不建议使用HashMap，**1.8之前并发下进行Rehash会造成元素之间形成循环链表**，但是1.8之后还有其他问题（**数据丢失**），建议使用concurrentHashMap

- HashMap有哪几种常见的遍历方式

  > https://mp.weixin.qq.com/s/zQBN3UvJDhRTKP6SzcZFKw

- ConcurrentHashMap和Hashtable

  - 主要体现在，实现线程安全的方式上不同

  - 底层数据结构

    - ConcurrentHashMap：JDK1.7 底层采用**分段数组+链表**，JDK1.8 则是**数组+链表/红黑二叉树（红黑树是1.8之后才出现的）**
    - HashTable采用 数组 (应该不是分段数组) + 链表 

  - 实现线程安全的方式

    - ConcurrentHashMap  **JDK1.7 时对整个桶数进行分割分段**(Segment，分段锁)，**每一把锁只锁容器其中一部分数据**，当访问不同数据段的数据就不会存在锁竞争
    - ConcurrentHashMap JDK1.8摒弃Segment概念，直接用Node数组+链表+红黑树，并发控制使用**synchronized和CAS**操作
    - 而Hashtable则是同一把锁，使用synchronized保证线程安全，效率低下。问题：当一个线程访问同步方式时，其他线程也访问同步方法，则可能进入**阻塞/轮询**状态，即如使用put添加元素另一个线程不能使用put和get

  - 底层数据结构图

    - HashTable：数组+链表
      ![image-20221019162845607](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019162845607.png)

    - JDK1.7 的 ConcurrentHashMap（Segment数组，HashEntry数组，链表）

      Segment是用来加锁的
      ![image-20221019163009141](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019163009141.png)
      JDK1.8 的ConcurrentHashMap则是Node数组+链表/红黑树，不过红黑树时，不用Node，而是用TreeNode  

    - TreeNode，存储红黑树节点，被TreeBin包装

      ```java
      /**
      root 维护红黑树根节点；waiter维护当前使用这颗红黑树的线程，防止其他线程进入
      **/
      static final class TreeBin<K,V> extends Node<K,V> {
              TreeNode<K,V> root;
              volatile TreeNode<K,V> first;
              volatile Thread waiter;
              volatile int lockState;
              // values for lockState
              static final int WRITER = 1; // set while holding write lock
              static final int WAITER = 2; // set when waiting for write lock
              static final int READER = 4; // increment value for setting read lock
      ...
      }
      ```

- ConcurrentHashMap线程安全的**具体实现方式/底层具体实现**

  - JDK1.8之前的ConcurrentHashMap

    ![image-20221019164531847](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019164531847.png)`Segment` 继承了 `ReentrantLock`,所以 `Segment` 是一种可重入锁，扮演锁的角色。`HashEntry` 用于存储键值对数据。

    ```java
    static class Segment<K,V> extends ReentrantLock implements Serializable {
    }
    ```

    一个 `ConcurrentHashMap` 里包含一个 `Segment` 数组，`Segment` 的个数一旦**初始化就不能改变**。 `Segment` 数组的大小默认是 16，也就是说默认可以同时支持 16 个线程并发写。
    `Segment` 的结构和 `HashMap` 类似，是一种数组和链表结构，一个 `Segment` 包含一个 `HashEntry` 数组，每个 `HashEntry` 是一个链表结构的元素，**每个 `Segment` 守护着一个 `HashEntry` 数组**里的元素，当对 `HashEntry` 数组的数据进行修改时，必须**首先获得对应的 `Segment` 的锁**。也就是说，对同一 `Segment` 的并发写入会被阻塞，不同 `Segment` 的写入是可以并发执行的。

  - JDK 1.8 之后
    ![image-20221019165516462](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019165516462.png)
    使用Node数组+链表/红黑树，几乎重写了ConcurrentHashMap，使用```Node+CAS+Synchronized```保证并发安全，数据结构跟HashMap1.8类似，超过一定阈值（默认8）将链表【O(N)】转成红黑树【O(log (N) )】
    JDK8中，**只锁定当前链表/红黑二叉树的首节点**，这样**只要hash不冲突就不会产生并发**，不影响其他Node的读写，提高效率 

## Collections工具类（不重要）

包括 排序/查找/替换

- 排序

  ```java
  void reverse(List list)//反转
  void shuffle(List list)//随机排序
  void sort(List list)//按自然排序的升序排序
  void sort(List list, Comparator c)//定制排序，由Comparator控制排序逻辑
  void swap(List list, int i , int j)//交换两个索引位置的元素
  void rotate(List list, int distance)//旋转。当distance为正数时，将list后distance个元素整体移到前面。当distance为负数时，将 list的前distance个元素整体移到后面
  ```

- 查找/替换

  ```java
  int binarySearch(List list, Object key)//对List进行二分查找，返回索引，注意List必须是有序的
  int max(Collection coll)//根据元素的自然顺序，返回最大的元素。 类比int min(Collection coll)
  int max(Collection coll, Comparator c)//根据定制排序，返回最大元素，排序规则由Comparatator类控制。类比int min(Collection coll, Comparator c)
  void fill(List list, Object obj)//用指定的元素代替指定list中的所有元素
  int frequency(Collection c, Object o)//统计元素出现次数
  int indexOfSubList(List list, List target)//统计target在list中第一次出现的索引，找不到则返回-1，类比int lastIndexOfSubList(List source, list target)
  boolean replaceAll(List list, Object oldVal, Object newVal)//用新元素替换旧元素
  ```

- 同步控制，Collections提供了多个synchronizedXxx()方法，该方法可以将指定集合包装成线程同步的集合，从而解决并发问题。
  其中，**HashSet、TreeSet、ArrayList、LinkedList、HashMap、TreeMap**都是线程不安全的

  ```java
  //不推荐，因为效率极低 建议使用JUC包下的并发集合
  synchronizedCollection(Collection<T>  c) //返回指定 collection 支持
  的同步（线程安全的）collection。
  synchronizedList(List<T> list)//返回指定列表支持的同步（线程安全的）List。
  synchronizedMap(Map<K,V> m) //返回由指定映射支持的同步（线程安全的）Map。
  synchronizedSet(Set<T> s) //返回指定 set 支持的同步（线程安全的）set。
  ```

  
