---
title: HashMap源码
description: HashMap源码
categories:
  - 学习
tags:
  - 复习
  - 复习--知识点
date: 2022-10-21 15:30:09
updated: 2022-10-21 15:30:09
---

## HashMap简介

- HashMap用来存放键值对，基于哈希表的Map接口实现，是非线程安全的
- 可以存储null的key和value，但null作为键只能有一个
- JDK8之前，HashMap由数组和链表组成，链表是为了解决哈希冲突而存在；JDK8之后，当链表大于阈值（默认8），则会选择转为红黑树（当数组长度大于64则进行转换，否则只是扩容），以减少搜索时间
- HashMap默认初始化大小为16，每次扩容为原容量2倍，且总是使用2的幂作为哈希表的大小

## 底层数据结构分析

- JDK8之前，HashMap底层是数组和链表，即**链表散列**；通过key的hashCode，经过扰动函数，获得hash值，然后再通过(n-1) & hash 判断当前元素存放位置（n指的是数组长度），如果当前位置存在元素，就判断元素与要存入的元素的hash值以及key是否相同，相同则覆盖，否则通过拉链法解决

  - 扰动函数，即hash(Object key)方法

    ```java
    //JDK1.8  
    static final int hash(Object key) {
          int h;
          // key.hashCode()：返回散列值也就是hashcode
          // ^ ：按位异或
          // >>>:无符号右移，忽略符号位，空位都以0补齐
          return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
      }
    ```

  - JDK1.7 

    ```java
    //JDK1.7 , 则扰动了4次，性能较差
    static int hash(int h) {
        // This function ensures that hashCodes that differ only by
        // constant multiples at each bit position have a bounded
        // number of collisions (approximately 8 at default load factor).
    
        h ^= (h >>> 20) ^ (h >>> 12);
        return h ^ (h >>> 7) ^ (h >>> 4);
    }
    ```

- JDK1.8，当大于阈值时（默认8），会调用treefyBin()，根据HashMap数组决定是否转换为红黑树，只有当数组长度大于或等于64才转换为红黑树，减少搜索时间，否则只是调用resize()方法扩容

- HashMap一些属性

  ```java
  public class HashMap<K,V> extends AbstractMap<K,V> implements Map<K,V>, Cloneable, Serializable {
      // 序列号
      private static final long serialVersionUID = 362498820763181265L;
      // 默认的初始容量是16
      static final int DEFAULT_INITIAL_CAPACITY = 1 << 4;
      // 最大容量
      static final int MAXIMUM_CAPACITY = 1 << 30;
      // 默认的填充因子
      static final float DEFAULT_LOAD_FACTOR = 0.75f;
      // 当桶(bucket)上的结点数大于这个值时会转成红黑树
      static final int TREEIFY_THRESHOLD = 8;
      // 当桶(bucket)上的结点数小于这个值时树转链表
      static final int UNTREEIFY_THRESHOLD = 6;
      // 桶中结构转化为红黑树对应的table的最小容量
      static final int MIN_TREEIFY_CAPACITY = 64;
      // 存储元素的数组，总是2的幂次倍
      transient Node<k,v>[] table;
      // 存放具体元素的集
      transient Set<map.entry<k,v>> entrySet;
      // 存放元素的个数，注意这个不等于数组的长度。
      transient int size;
      // 每次扩容和更改map结构的计数器
      transient int modCount;
      // 临界值(容量*填充因子) 当实际大小超过临界值时，会进行扩容
      int threshold;
      // 加载因子
      final float loadFactor;
  }
  ```

  - LoadFactory 加载因子
    控制数组存放数据的疏密程度，**趋于1，说明存放的数据越集中（即链表越长）**；**趋于0，数组中存放的数据少，即越稀疏**。即如果太大则导致元素效率低，太小则数组利用率低（这里的低指的是每个数组存放的元素太少）；默认为0.75
  - threshold   ```threshold 英[ˈθreʃhəʊld]```
    **threshold = capacity \* loadFactor**，即存放的元素Size 如果 > threshold ，即capacity * 0.75的时候，就要考虑扩容了

- Node类结点源码

  ```java
  // 继承自 Map.Entry<K,V>
  static class Node<K,V> implements Map.Entry<K,V> {
         final int hash;// 哈希值，存放元素到hashmap中时用来与其他元素hash值比较
         final K key;//键
         V value;//值
         // 指向下一个节点
         Node<K,V> next;
         Node(int hash, K key, V value, Node<K,V> next) {
              this.hash = hash;
              this.key = key;
              this.value = value;
              this.next = next;
          }
          public final K getKey()        { return key; }
          public final V getValue()      { return value; }
          public final String toString() { return key + "=" + value; }
          // 重写hashCode()方法
          public final int hashCode() {
              return Objects.hashCode(key) ^ Objects.hashCode(value);
          }
  
          public final V setValue(V newValue) {
              V oldValue = value;
              value = newValue;
              return oldValue;
          }
          // 重写 equals() 方法
          public final boolean equals(Object o) {
              if (o == this)
                  return true;
              if (o instanceof Map.Entry) {
                  Map.Entry<?,?> e = (Map.Entry<?,?>)o;
                  if (Objects.equals(key, e.getKey()) &&
                      Objects.equals(value, e.getValue()))
                      return true;
              }
              return false;
          }
  }
  ```

  树节点类源码

  ```java
  static final class TreeNode<K,V> extends LinkedHashMap.Entry<K,V> {
          TreeNode<K,V> parent;  // 父
          TreeNode<K,V> left;    // 左
          TreeNode<K,V> right;   // 右
          TreeNode<K,V> prev;    // needed to unlink next upon deletion
          boolean red;           // 判断颜色
          TreeNode(int hash, K key, V val, Node<K,V> next) {
              super(hash, key, val, next);
          }
          // 返回根节点
          final TreeNode<K,V> root() {
              for (TreeNode<K,V> r = this, p;;) {
                  if ((p = r.parent) == null)
                      return r;
                  r = p;
         }
  ```

  

## HashMap源码分析

- 构造方法(4个，空参/Map/指定容量大小/容量大小及加载因子)

  ```java
  // 默认构造函数。
      public HashMap() {
          this.loadFactor = DEFAULT_LOAD_FACTOR; // all   other fields defaulted
       }
  
       // 包含另一个“Map”的构造函数
       public HashMap(Map<? extends K, ? extends V> m) {
           this.loadFactor = DEFAULT_LOAD_FACTOR;
           putMapEntries(m, false);//下面会分析到这个方法
       }
  
       // 指定“容量大小”的构造函数
       public HashMap(int initialCapacity) {
           this(initialCapacity, DEFAULT_LOAD_FACTOR);
       }
  
       // 指定“容量大小”和“加载因子”的构造函数
       public HashMap(int initialCapacity, float loadFactor) {
           if (initialCapacity < 0)
               throw new IllegalArgumentException("Illegal initial capacity: " + initialCapacity);
           if (initialCapacity > MAXIMUM_CAPACITY)
               initialCapacity = MAXIMUM_CAPACITY;
           if (loadFactor <= 0 || Float.isNaN(loadFactor))
               throw new IllegalArgumentException("Illegal load factor: " + loadFactor);
           this.loadFactor = loadFactor;
           this.threshold = tableSizeFor(initialCapacity);
       }
  
  //putMapEntries方法
  final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict) {
      int s = m.size();
      if (s > 0) {
          // 判断table是否已经初始化
          if (table == null) { // pre-size
              // 未初始化，s为m的实际元素个数
              float ft = ((float)s / loadFactor) + 1.0F;
              int t = ((ft < (float)MAXIMUM_CAPACITY) ?
                      (int)ft : MAXIMUM_CAPACITY);
              // 计算得到的t大于阈值，则初始化阈值
              if (t > threshold)
                  threshold = tableSizeFor(t);
          }
          // 已初始化，并且m元素个数大于阈值，进行扩容处理
          else if (s > threshold)
              resize();
          // 将m中的所有元素添加至HashMap中
          for (Map.Entry<? extends K, ? extends V> e : m.entrySet()) {
              K key = e.getKey();
              V value = e.getValue();
              putVal(hash(key), key, value, false, evict);
          }
      }
  }
  ```

- put方法（对外只提供put，没有putVal)
  putVal方法添加元素分析

  - 如果定位到的数组位置没有元素直接插入

  - 如果有，则比较key，如果key相同则覆盖，不同则判断是否时树节点，如果是，使用putTreeVal插入；如果不是，则遍历链表插入(链表尾部)
    ![image-20221022181648277](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221022181648277.png)

    - 注意事项1：直接覆盖则return，不会有后续操作

    - 当链表长度大于8且HashMap数组长度大于64才会执行链表转红黑树，否则只是对数组扩容

      ```java
      //源码
      public V put(K key, V value) {
          return putVal(hash(key), key, value, false, true);
      }
      
      final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                         boolean evict) {
          Node<K,V>[] tab; Node<K,V> p; int n, i;
          // table未初始化或者长度为0，进行扩容
          if ((tab = table) == null || (n = tab.length) == 0)
              n = (tab = resize()).length;
          // (n - 1) & hash 确定元素存放在哪个桶中，桶为空，新生成结点放入桶中(此时，这个结点是放在数组中)
          if ((p = tab[i = (n - 1) & hash]) == null)
              tab[i] = newNode(hash, key, value, null);
          // 桶中已经存在元素（处理hash冲突）
          else {
              Node<K,V> e; K k;
              // 判断table[i]中的元素是否与插入的key一样，若相同那就直接使用插入的值p替换掉旧的值e。
              if (p.hash == hash &&
                  ((k = p.key) == key || (key != null && key.equals(k))))
                      e = p;
              // 判断插入的是否是红黑树节点
              else if (p instanceof TreeNode)
                  // 放入树中
                  e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
              // 不是红黑树节点则说明为链表结点
              else {
                  // 在链表最末插入结点
                  for (int binCount = 0; ; ++binCount) {
                      // 到达链表的尾部
                      if ((e = p.next) == null) {
                          // 在尾部插入新结点
                          p.next = newNode(hash, key, value, null);
                          // 结点数量达到阈值(默认为 8 )，执行 treeifyBin 方法
                          // 这个方法会根据 HashMap 数组来决定是否转换为红黑树。
                          // 只有当数组长度大于或者等于 64 的情况下，才会执行转换红黑树操作，以减少搜索时间。否则，就是只是对数组扩容。
                          if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                              treeifyBin(tab, hash);
                          // 跳出循环
                          break;
                      }
                      // 判断链表中结点的key值与插入的元素的key值是否相等
                      if (e.hash == hash &&
                          ((k = e.key) == key || (key != null && key.equals(k))))
                          // 相等，跳出循环
                          break;
                      // 用于遍历桶中的链表，与前面的e = p.next组合，可以遍历链表
                      p = e;
                  }
              }
              // 表示在桶中找到key值、hash值与插入元素相等的结点
              if (e != null) {
                  // 记录e的value
                  V oldValue = e.value;
                  // onlyIfAbsent为false或者旧值为null
                  if (!onlyIfAbsent || oldValue == null)
                      //用新值替换旧值
                      e.value = value;
                  // 访问后回调
                  afterNodeAccess(e);
                  // 返回旧值
                  return oldValue;
              }
          }
          // 结构性修改
          ++modCount;
          // 实际大小大于阈值则扩容
          if (++size > threshold)
              resize();
          // 插入后回调
          afterNodeInsertion(evict);
          return null;
      }
      ```

  - 1.7中的put方法

    - ① 如果定位到的数组位置没有元素 就直接插入。

    - ② 如果定位到的数组位置有元素，遍历**以这个元素为头结点的链表**，依次和插入的 key 比较，如果 key 相同就直接覆盖，不同就**采用头插法插入元素**。

      ```java
      //源码
      public V put(K key, V value)
          if (table == EMPTY_TABLE) {
          inflateTable(threshold);
      }
          if (key == null)
              return putForNullKey(value);
          int hash = hash(key);
          int i = indexFor(hash, table.length);
          for (Entry<K,V> e = table[i]; e != null; e = e.next) { // 先遍历
              Object k;
              if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
                  V oldValue = e.value;
                  e.value = value;
                  e.recordAccess(this);
                  return oldValue;
              }
          }
      
          modCount++;
          addEntry(hash, key, value, i);  // 再插入
          return null;
      }
      ```

  - get方法
    //先算hash值，然后算出key在数组中的index下标，然后就要在数组中取值了（先判断第一个结点(链表/树))。如果相等，则返回，如果不相等则分两种情况：在树中get或者 **链表中get（需要遍历）**

    ```java
    public V get(Object key) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? null : e.value;
    }
    
    final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (first = tab[(n - 1) & hash]) != null) {
            // 数组元素相等
            if (first.hash == hash && // always check first node
                ((k = first.key) == key || (key != null && key.equals(k))))
                return first;
            // 桶中不止一个节点
            if ((e = first.next) != null) {
                // 在树中get
                if (first instanceof TreeNode)
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                // 在链表中get
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);
            }
        }
        return null;
    }
    ```

  - resize方法
    每次扩容，都会进行一次重新hash分配，且会遍历所有元素（非常耗时）

    ```java
    final Node<K,V>[] resize() {
        Node<K,V>[] oldTab = table;
        int oldCap = (oldTab == null) ? 0 : oldTab.length;
        int oldThr = threshold;
        int newCap, newThr = 0;
        if (oldCap > 0) {
            // 超过最大值就不再扩充了，就只好随你碰撞去吧
            if (oldCap >= MAXIMUM_CAPACITY) {
                threshold = Integer.MAX_VALUE;
                return oldTab;
            }
            // 没超过最大值，就扩充为原来的2倍
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY && oldCap >= DEFAULT_INITIAL_CAPACITY)
                newThr = oldThr << 1; // double threshold
        }
        else if (oldThr > 0) // initial capacity was placed in threshold
            newCap = oldThr;
        else {
            // signifies using defaults
            newCap = DEFAULT_INITIAL_CAPACITY;
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
        }
        // 计算新的resize上限
        if (newThr == 0) {
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ? (int)ft : Integer.MAX_VALUE);
        }
        threshold = newThr;
        @SuppressWarnings({"rawtypes","unchecked"})
            Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
        if (oldTab != null) {
            // 把每个bucket都移动到新的buckets中
            for (int j = 0; j < oldCap; ++j) {
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {
                    oldTab[j] = null;
                    if (e.next == null)
                        newTab[e.hash & (newCap - 1)] = e;
                    else if (e instanceof TreeNode)
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    else {
                        Node<K,V> loHead = null, loTail = null;
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
                        do {
                            next = e.next;
                            // 原索引
                            if ((e.hash & oldCap) == 0) {
                                if (loTail == null)
                                    loHead = e;
                                else
                                    loTail.next = e;
                                loTail = e;
                            }
                            // 原索引+oldCap
                            else {
                                if (hiTail == null)
                                    hiHead = e;
                                else
                                    hiTail.next = e;
                                hiTail = e;
                            }
                        } while ((e = next) != null);
                        // 原索引放到bucket里
                        if (loTail != null) {
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        // 原索引+oldCap放到bucket里
                        if (hiTail != null) {
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
    ```

    

## HashMap常用方法测试

```java
package map;

import java.util.Collection;
import java.util.HashMap;
import java.util.Set;

public class HashMapDemo {

    public static void main(String[] args) {
        HashMap<String, String> map = new HashMap<String, String>();
        // 键不能重复，值可以重复
        map.put("san", "张三");
        map.put("si", "李四");
        map.put("wu", "王五");
        map.put("wang", "老王");
        map.put("wang", "老王2");// 老王被覆盖
        map.put("lao", "老王");
        System.out.println("-------直接输出hashmap:-------");
        System.out.println(map);
        /**
         * 遍历HashMap
         */
        // 1.获取Map中的所有键
        System.out.println("-------foreach获取Map中所有的键:------");
        Set<String> keys = map.keySet();
        for (String key : keys) {
            System.out.print(key+"  ");
        }
        System.out.println();//换行
        // 2.获取Map中所有值
        System.out.println("-------foreach获取Map中所有的值:------");
        Collection<String> values = map.values();
        for (String value : values) {
            System.out.print(value+"  ");
        }
        System.out.println();//换行
        // 3.得到key的值的同时得到key所对应的值
        System.out.println("-------得到key的值的同时得到key所对应的值:-------");
        Set<String> keys2 = map.keySet();
        for (String key : keys2) {
            System.out.print(key + "：" + map.get(key)+"   ");

        }
        /**
         * 如果既要遍历key又要value，那么建议这种方式，因为如果先获取keySet然后再执行map.get(key)，map内部会执行两次遍历。
         * 一次是在获取keySet的时候，一次是在遍历所有key的时候。
         */
        // 当我调用put(key,value)方法的时候，首先会把key和value封装到
        // Entry这个静态内部类对象中，把Entry对象再添加到数组中，所以我们想获取
        // map中的所有键值对，我们只要获取数组中的所有Entry对象，接下来
        // 调用Entry对象中的getKey()和getValue()方法就能获取键值对了
        Set<java.util.Map.Entry<String, String>> entrys = map.entrySet();
        for (java.util.Map.Entry<String, String> entry : entrys) {
            System.out.println(entry.getKey() + "--" + entry.getValue());
        }

        /**
         * HashMap其他常用方法
         */
        System.out.println("after map.size()："+map.size());
        System.out.println("after map.isEmpty()："+map.isEmpty());
        System.out.println(map.remove("san"));
        System.out.println("after map.remove()："+map);
        System.out.println("after map.get(si)："+map.get("si"));
        System.out.println("after map.containsKey(si)："+map.containsKey("si"));
        System.out.println("after containsValue(李四)："+map.containsValue("李四"));
        System.out.println(map.replace("si", "李四2"));
        System.out.println("after map.replace(si, 李四2):"+map);
    }

}
```

> 大部分转自https://github.com/Snailclimb/JavaGuide