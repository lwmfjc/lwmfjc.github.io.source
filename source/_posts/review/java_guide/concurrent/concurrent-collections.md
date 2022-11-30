---
title: java常见并发容器
description: java常见并发容器
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-11-29 16:58:59
updated: 2022-11-29 16:58:59
---

> 转载自https://github.com/Snailclimb/JavaGuide

JDK提供的容器，大部分在java.util.concurrent包中

- ConcurrentHashMap：线程安全的**HashMap**
- CopuOnWriteArrayList：线程安全的**List**，在读多写少的场合性能非常好，远好于Vector
- **ConcurrentLinkedQueue**：高效的**并发队列**，使用**链表**实现，可以看作一个**线程安全的LinkedList**，是一个**非阻塞队列**
- **BlockingQueue**：这是一个接口，JDK内部通过链表、数组等方式实现了该接口。表示**阻塞队列**，非常适合用于作为数据共享的通道
- ConcorrentSkipListMap：**跳表**的实现，是一个Map，使用**跳表的数据结构进行快速查找**

# ConcurrentHashMap

- HashMap是线程不安全的，并发场景下要保证线程安全，可以使用Collections.synchronizedMap()方法来包装HashMap，但这是通过**使用一个全局的锁**来**同步不同线程间的并发访问**，因此会带来性能问题
- 建议使用ConcurrentHashMap，不论是读操作还是写操作都能保证高性能：读操作（几乎）不需要加锁，而写操作时通过锁分段技术，只对**所操作的段加锁**而不影响客户端对其他段的访问

# CopyOnWriteArrayList

```java
//源码
public class CopyOnWriteArrayList<E>
extends Object
implements List<E>, RandomAccess, Cloneable, Serializable
 
```

- 在很多应用场景中，**读操作可能会远远大于写操作**
- 我们应该允许多个线程同时访问List内部数据（针对读）
- 与ReentrantReadWriteLock读写锁思想非常类似，即**读读共享**、**写写互斥**、**读写互斥**、**写读互斥**
- 不一样的是，CopyOnWriteArrayList**读取时完全不需要加锁**，且**写入也不会阻塞读取操作**，只有**写入和写入之间需要同步等待**。

## CopyOnWriteArrayList是如何做到的

- `CopyOnWriteArrayList` 类的**所有可变操作（add，set 等等）都是通过创建底层数组的新副本**来实现的。当 List 需要被修改的时候，我并不修改原有内容，而是**对原有数据进行一次复制，将修改的内容写入副本。写完之后，再将修改完的副本替换原来的数据**，这样就可以保证写操作不会影响读操作了。
- 从 `CopyOnWriteArrayList` 的名字就能看出 `CopyOnWriteArrayList` 是满足 **`CopyOnWrite`** 的
- 在计算机，如果你想要对一块内存进行修改时，我们不在原有内存块中进行写操作，而是将内存拷贝一份，在新的内存中进行写操作，写完之后呢，就**将指向原来内存指针指向新的内存(注意，是指向，而不是重新拷贝)**，原来的内存就可以被回收掉了

## CopyOnWriteArrayList 读取和写入源码简单分析

- CopyOnWriteArrayList读取操作的实现
  读取操作没有任何同步控制和锁操作，理由就是内部数组array不会发生修改，只会**被另一个array替换**，因此可以保证数据安全

  ```java
    /** The array, accessed only via getArray/setArray. */
      private transient volatile Object[] array;
      public E get(int index) {
          return get(getArray(), index);
      }
      @SuppressWarnings("unchecked")
      private E get(Object[] a, int index) {
          return (E) a[index];
      }
      final Object[] getArray() {
          return array;
      }
  ```

  

- CopyOnWriteArrayList写入操作的实现
  在添加集合的时候加了锁，保证同步，**避免多线程写的时候会copy出多个副本**

  ```java
  /**
       * Appends the specified element to the end of this list.
       *
       * @param e element to be appended to this list
       * @return {@code true} (as specified by {@link Collection#add})
       */
      public boolean add(E e) {
          final ReentrantLock lock = this.lock;
          lock.lock();//加锁
          try {
              Object[] elements = getArray();
              int len = elements.length;
              Object[] newElements = Arrays.copyOf(elements, len + 1);//拷贝新数组
              newElements[len] = e;
              setArray(newElements);
              return true;
          } finally {
              lock.unlock();//释放锁
          }
      }
  ```

  

# ConcurrentLinkedQueue

- Java提供的**线程安全的Queue**分为**阻塞队列**和**非阻塞队列**
- 阻塞队列的典型例子是**BlockingQueue**，**非阻塞队列的典型例子是ConcurrentLinkedQueue**
- **阻塞队列通过锁**来实现，**非阻塞队列通过CAS**实现
- ConcurrentLinkedQueue使用**链表**作为数据结构，是高并发环境中性能最好的队列
- `ConcurrentLinkedQueue` 适合在对性能要求相对较高，同时对队列的读写存在多个线程同时进行的场景，即如果对队列加锁的成本较高则适合**使用无锁的 `ConcurrentLinkedQueue`，即CAS** 来替代

# BlockingQueue

阻塞队列（`BlockingQueue`）被广泛使用在“**生产者-消费者**”问题中，其原因是 `BlockingQueue` 提供了**可阻塞的插入和移除**的方法。当**队列容器已满，生产者线程会被阻塞，直到队列未满**；当**队列容器为空时，消费者线程会被阻塞，直至队列非空**时为止

BlockingQueue是一个接口，继承自**Queue**，而**Queue**又继承自Collection接口，下面是BlockingQueue的**相关实现类**：  
![image-20221130112118211](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221130112118211.png)

## ArrayBockingQueue

- ArrayBlockingQueue是**BlockingQueue**接口的**有界队列实现类**，底层采用**数组**来实现

  ```java
  public class ArrayBlockingQueue<E>
  extends AbstractQueue<E>
  implements BlockingQueue<E>, Serializable{}
  ```

  

- `ArrayBlockingQueue` 一旦创建，容量不能改变。其并发控制采用可重入锁 `ReentrantLock` ，不管是插入操作还是读取操作，都需要获取到锁才能进行操作。当队列容量满时，尝试将元素放入队列将导致操作阻塞;尝试从一个空队列中取一个元素也会同样阻塞。

- `ArrayBlockingQueue` **默认情况下不能保证线程访问队列的公平性**，所谓**公平性是指严格按照线程等待的绝对时间顺序，即最先等待的线程能够最先访问到 `ArrayBlockingQueue`**。而非公平性则是指访问 `ArrayBlockingQueue` 的顺序不是遵守严格的时间顺序，有可能存在，当 `ArrayBlockingQueue` 可以被访问时，长时间阻塞的线程依然无法访问到 `ArrayBlockingQueue`。如果保证公平性，通常会降低吞吐量。如果需要获得公平性的 `ArrayBlockingQueue`，可采用如下代码

  ```java
  private static ArrayBlockingQueue<Integer> blockingQueue = new ArrayBlockingQueue<Integer>(10,true);
  ```

## LinkedBockingQueue

- 底层基于**单向链表**实现阻塞队列，可以当作无界队列也可以当作有界队列

- 满足FIFO特性，与ArrayBlockingQueue相比有更高吞吐量，为防止LinkedBlockingQueue容量迅速增加，损耗大量内存，一般创建LinkedBlockingQueue对象时会指定大小**；如果未指定则容量等于Integer.MAX_VALUE**

- 相关构造方法

  ```java
  /**
       *某种意义上的无界队列
       * Creates a {@code LinkedBlockingQueue} with a capacity of
       * {@link Integer#MAX_VALUE}.
       */
      public LinkedBlockingQueue() {
          this(Integer.MAX_VALUE);
      }
  
      /**
       *有界队列
       * Creates a {@code LinkedBlockingQueue} with the given (fixed) capacity.
       *
       * @param capacity the capacity of this queue
       * @throws IllegalArgumentException if {@code capacity} is not greater
       *         than zero
       */
      public LinkedBlockingQueue(int capacity) {
          if (capacity <= 0) throw new IllegalArgumentException();
          this.capacity = capacity;
          last = head = new Node<E>(null);
      }
  ```

## PriorityBlockingQueue



# ConcurrentSkipListMap

