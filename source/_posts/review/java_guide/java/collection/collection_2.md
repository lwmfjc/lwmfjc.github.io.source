---
title: 集合_2
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
  - HashMap是非线程安全的，Hashtable是线程安全的，因为Hashtable内部方法都经过synchronized修饰（不过要保证线程安全一般用ConcurrentHashMap）
  - 由于加了synchronized修饰，HashTable效率没有HashMap高
  - HashMap可以存储null的key和value，但null作为key的键只能由一个；HashTable不允许有null键和null值
  - 初始容量及每次扩容
    - Hashtable默认初始大小11，之后扩容为2n+1;HashMap初始大小16，之后扩容2n
    - 如果指定初始大小，HashTable直接使用初始大小  
      而HashMap使用2的幂作为哈希表的大小（我猜是大于初始大小的最小2的n次方）**Returns a power of two size for the given target capacity.**
  - 底层数据结构
    - JDK1.8之后HashMap解决哈希冲突时，当链表大于阈值（默认8）时，将链表转为红黑树（转换前判断，如果当前数组长度小于64，则先进行数组扩容，而不转成红黑树），以减少搜索时间
  
- HashMap和hashSet区别

  - HashSet底层就是HashMap实现的
  - HashMap：实现了Map接口；存储键值对；调用put()向map中添加元素；**HashMap使用键（key）计算**
  - HashSet：实现Set接口；仅存储对象；调用add()方法向Set中添加元素；HashSet使用成员对象计算hashCode，对于不相等两个对象来说 hashcode也可能相同，所以还要再借助equals()方法判断对象相等性

- HashMap和TreeMap
  navigable 英[ˈnævɪɡəbl] 通航的，可航行的  
  HashMap和TreeMap都继承自AbstractMap  
  TreeMap还实现了NavigableMap （**对集合内元素搜索**）和SortedMap（对集合内元素**根据键排序**，默认key升序，可指定排序的比较器）接口  
  示例：

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

  - 当在HashSet加入对象时，先计算对象hashcode值判断加入位置，同时与其他加入对象的hashcode值比较，如果没有相同的，会假设对象没有重复出现；如果发现有相同的hashcode值的对象，则调用equals()方法检查hashcode相等的对象是否真的相等，如果相等则不会加入

  - JDK1.8中，HashSet的add()方法调用了HashMap的put()方法，并判断是否有重复元素（返回值是否null)

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

  - JDK1.8之前，底层是数组和链表结合在一起使用，即链表散列。通过key的hashcode经过扰动函数处理后得到hash值，并通过 (n-1) & hash 判断当前元素存放的位置 （n为数组长度），如果当前位置存在元素的话，就判断该元素与要存入的元素的hash值以及key是否相同，**如果相同则覆盖，不同则通过拉链法解决冲突**
    扰动函数指的是HashMap的hash方法，是为了防止一些实现比较差的hashCode方法，减少碰撞
    JDK1.8的hash：如果key为null则返回空，否则使用 (key的hash值) 与 (hash值右移16位) 做异或操作

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

    拉链法即链表和数组结合，也就是创建一个链表数组，数组每一格为一个链表，如果发生哈希冲突，就将冲突的值添加到链表中即可

    ![image-20221019143906992](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019143906992.png)

  - JDK8之后，解决冲突发生了较大变化，当链表长度大于阈值（默认是8）（如果数组小于64，则只会进行扩容；如果不是，才转成红黑树）时，将链表转换成红黑树，以减少搜索时间
    ![image-20221019144049952](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019144049952.png)
    二叉查找树，在某些情况下会退化成线性结构，时间复杂度为n ，而红黑树趋于log n 。TreeMap、TreeSet以及1.8之后的HashMap都用到了红黑树

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

  - Hash值范围是-2147483648 到 2147483647 ，大概是40亿映射空间，如果哈希函数映射均匀则很难发生碰撞，但一个40亿长度的数组内存放不下，所以用之前得对数组长度进行取模，然后得到的余数存放的位置才是对应的数组下标，下标计算方法 (n-1) && hash
    为什么不是取余数，因为 hash & (length -1) 比 hash%length效率高，当length为2的n次方时两侧相等，而 使用二进制位操作& 能够提高效率

- HashMap多线程操作导致死循环问题
  多线程下不建议使用HashMap，1.8之前并发下进行Rehash会造成元素之间形成循环链表，1.8之后还有其他问题（数据丢失），建议使用concurrentHashMap

- HashMap有哪几种常见的遍历方式

  > https://mp.weixin.qq.com/s/zQBN3UvJDhRTKP6SzcZFKw

- ConcurrentHashMap和Hashtable

  - 主要体现在，实现线程安全的方式上不同

  - 底层数据结构

    - ConcurrentHashMap：JDK1.7 底层采用**分段数组+链表**，JDK1.8 则是**数组+链表/红黑二叉树（红黑树是1.8之后才出现的）**
    - HashTable采用 数组 (应该不是分段数组) + 链表 

  - 实现线程安全的方式

    - ConcurrentHashMap  JDK1.7 时对整个桶数进行分割分段(Segment，分段锁)，每一把锁只锁容器其中一部分数据，当访问不同数据段的数据就不会存在锁竞争
    - ConcurrentHashMap JDK1.8摒弃Segment概念，直接用Node数组+链表+红黑树，并发控制使用synchronized和CAS操作
    - 而Hashtable则是同一把锁，使用synchronized保证线程安全，效率低下。问题：当一个线程访问同步方式时，其他线程也访问同步方法，则可能进入阻塞/轮询状态，即如使用put添加元素另一个线程不能使用put和get

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
    `Segment` 的结构和 `HashMap` 类似，是一种数组和链表结构，一个 `Segment` 包含一个 `HashEntry` 数组，每个 `HashEntry` 是一个链表结构的元素，每个 `Segment` 守护着一个 `HashEntry` 数组里的元素，当对 `HashEntry` 数组的数据进行修改时，必须首先获得对应的 `Segment` 的锁。也就是说，对同一 `Segment` 的并发写入会被阻塞，不同 `Segment` 的写入是可以并发执行的。

  - JDK 1.8 之后
    ![image-20221019165516462](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221019165516462.png)
    使用Node数组+链表/红黑树，几乎重写了ConcurrentHashMap，使用```Node+CAS+Synchronized```保证并发安全，数据结构跟HashMap1.8类似，超过一定阈值（默认8）将链表【O(N)】转成红黑树【O(log (N) )】
    JDK8中，只锁定当前链表/红黑二叉树的首节点，这样只要hash不冲突就不会产生并发，不影响其他Node的读写，提高效率 

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

  

> 大部分转自https://github.com/Snailclimb/JavaGuide