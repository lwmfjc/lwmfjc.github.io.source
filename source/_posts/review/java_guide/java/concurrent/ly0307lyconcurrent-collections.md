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

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

JDK提供的容器，大部分在java.util.concurrent包中

- ConcurrentHashMap：线程安全的**HashMap**
- CopyOnWriteArrayList：线程安全的**List**，在读多写少的场合性能非常好，远好于Vector
- **ConcurrentLinkedQueue**：高效的**并发队列**，使用**链表**实现，可以看作一个**线程安全的LinkedList**，是一个**非阻塞队列**
- **BlockingQueue**：这是一个接口，JDK内部通过链表、数组等方式实现了该接口。表示**阻塞队列**，非常适合用于作为数据共享的通道
- ConcorrentSkipListMap：**跳表**的实现，是一个Map，使用**跳表的数据结构进行快速查找**

# ConcurrentHashMap

- HashMap是线程不安全的，并发场景下要保证线程安全，可以使用Collections.synchronizedMap()方法来包装HashMap，但这是通过**使用一个全局的锁**来**同步不同线程间的并发访问**，因此会带来性能问题
- 建议使用ConcurrentHashMap，**不论是读操作还是写操作**都能保证高性能：读操作（几乎）不需要加锁，而写操作时通过**锁分段(这里说的是JDK1.7？)**技术，只对**所操作的段加锁**而不影响客户端对其他段的访问

# CopyOnWriteArrayList

```java
//源码
public class CopyOnWriteArrayList<E>
extends Object
implements List<E>, RandomAccess, Cloneable, Serializable
 
```

- 在很多应用场景中，**读操作可能会远远大于写操作**
- 我们应该允许**多个线程同时访问List内部数据**（针对读）
- 与ReentrantReadWriteLock读写锁思想非常类似，即**读读共享**、**写写互斥**、**读写互斥**、**写读互斥**
- 不一样的是，CopyOnWriteArrayList**读取时完全不需要加锁**，且**写入也不会阻塞读取操作**，只有**写入和写入之间需要同步等待**。

## CopyOnWriteArrayList是如何做到的

- `CopyOnWriteArrayList` 类的**所有可变操作（add，set 等等）都是通过创建底层数组的新副本**来实现的。当 List 需要被修改的时候，并不修改原有内容，而是**对原有数据进行一次复制，将修改的内容写入副本。写完之后，再将修改完的副本替换原来的数据**，这样就可以保证写操作不会影响读操作了。
- 从 `CopyOnWriteArrayList` 的名字就能看出 `CopyOnWriteArrayList` 是满足 **`CopyOnWrite`** 的
- 在计算机，如果你想要对一块内存进行修改时，我们不在原有内存块中进行写操作，而是将内存拷贝一份，在新的内存中进行写操作，写完之后呢，就**将指向原来内存指针指向新的内存(注意，是指向，而不是重新拷贝★重要★)**，原来的内存就可以被回收掉了

## CopyOnWriteArrayList 读取和写入源码简单分析

- CopyOnWriteArrayList读取操作的实现
  **读取操作没有任何同步控制**和**锁**操作，理由就是内部数组array不会发生修改，只会**被另一个array替换**，因此可以保证数据安全

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
- `ConcurrentLinkedQueue` 适合在**对性能要求相对较高**，**同时对队列的读写存在多个线程同时进行**的场景，即如果**对队列加锁的成本较高**则适合**使用无锁的 `ConcurrentLinkedQueue`，即CAS** 来替代

# BlockingQueue

阻塞队列（`BlockingQueue`）被广泛使用在“**生产者-消费者**”问题中，其原因是 `BlockingQueue` 提供了**可阻塞的插入和移除**的方法。当**队列容器已满，生产者线程会被阻塞，直到队列未满**；当**队列容器为空时，消费者线程会被阻塞，直至队列非空**时为止

BlockingQueue是一个接口，继承自**Queue**，而**Queue**又继承自Collection接口，下面是BlockingQueue的**相关实现类**：  
![lyx-20241126133647966](attachments/img/lyx-20241126133647966.png)

代码例子（主要是**put()**和**take()**两个方法）：  

```java
public class TestBlockingQueue {
    public static void main(String[] args) {
        BlockingQueue<String> blockingQueue
                = new ArrayBlockingQueue<>(2);
        for (int i = 10; i < 20; i++) {
            int finalI = i;
            new Thread(() -> {
                try {
                    TimeUnit.SECONDS.sleep(finalI);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                try {
                    blockingQueue.put(finalI + "");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(Thread.currentThread()
                        .getName() + "放入了元素[" + finalI + "");
            }, "线程" + i).start();
        }
        for (int i = 20; i < 30; i++) {
            int finalI = i;
            new Thread(() -> {
                try {
                    TimeUnit.SECONDS.sleep(finalI);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                String remove = null;
                try {
                    remove = blockingQueue.take();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(Thread.currentThread()
                        .getName() + "取出了元素[" + remove + "");
            }, "线程" + i).start();
        }
    }
}
/* 由下可以知道，放入了两个元素之后，需要等待取出后，才能继续放入
线程10放入了元素[10
线程11放入了元素[11                 ----> 之后这里发生了停顿
线程20取出了元素[10
线程12放入了元素[12
线程21取出了元素[11
线程13放入了元素[13
线程22取出了元素[12
线程14放入了元素[14
线程23取出了元素[13
线程15放入了元素[15
线程24取出了元素[14
线程16放入了元素[16
线程25取出了元素[15
线程17放入了元素[17
线程26取出了元素[16
线程18放入了元素[18
线程27取出了元素[17
线程19放入了元素[19
线程28取出了元素[18
线程29取出了元素[19

Process finished with exit code 0

*/
```



## ArrayBockingQueue

- ArrayBlockingQueue是**BlockingQueue**接口的**有界队列实现类**，底层采用**数组**来实现

  ```java
  public class ArrayBlockingQueue<E>
  extends AbstractQueue<E>
  implements BlockingQueue<E>, Serializable{}
  ```

  

- `ArrayBlockingQueue` 一旦创建，容量不能改变。其并发控制采用**可重入锁 `ReentrantLock`** ，不管是插入操作还是读取操作，都需要获取到锁才能进行操作。当**队列容量满**时，**尝试将元素放入队列**将导致操作**阻塞**;**尝试从一个空队列中取**一个元素也会**同样阻塞**。

- `ArrayBlockingQueue` **默认情况下不能保证线程访问队列的公平性**，所谓**公平性是指严格按照线程等待的绝对时间顺序，即最先等待的线程能够最先访问到 `ArrayBlockingQueue`**。而非公平性则是指访问 `ArrayBlockingQueue` 的顺序不是遵守严格的时间顺序，有可能存在，当 `ArrayBlockingQueue` 可以被访问时，长时间阻塞的线程依然无法访问到 `ArrayBlockingQueue`。如果**保证公平性**，通常会**降低吞吐量**。如果需要**获得公平性的 `ArrayBlockingQueue`**，可采用如下代码(**主要是第二个参数**)

  ```java
  private static ArrayBlockingQueue<Integer> blockingQueue = new ArrayBlockingQueue<Integer>(10,true);
  ```

## LinkedBlockingQueue

- 底层基于**单向链表**实现阻塞队列，可以当作**无界队列**也可以当作**有界队列**

- 满足FIFO特性，与ArrayBlockingQueue相比有更高吞吐量，为防止LinkedBlockingQueue容量迅速增加，损耗大量内存，一般创建LinkedBlockingQueue对象时会**指定大小****；如果未指定则容量等于Integer.MAX_VALUE**

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

- **支持优先级的无界阻塞队列**，默认情况元素采用**自然顺序**进行排序，或通过自定义类实现compareTo()方法指定元素排序，或初始化时通过**构造器参数Comparator**来指定排序规则
- `PriorityBlockingQueue` 并发控制采用的是**可重入锁 `ReentrantLock`**，**队列为无界队列**（`ArrayBlockingQueue` 是有界队列，`LinkedBlockingQueue` 也可以通过在构造函数中传入 `capacity` 指定队列最大的容量，但是 **`PriorityBlockingQueue` 只能指定初始的队列大小，后面插入元素的时候，如果空间不够的话会自动扩容**）
- 它就是 **`PriorityQueue` 的线程安全版本**。**不可以插入 null 值，同时，插入队列的对象必须是可比较大小的（comparable），否则报 `ClassCastException` 异常**。它的插入操作 put 方法不会 block(**是block 阻塞，不是lock 锁**)，因为它是无界队列（take 方法在队列为空的时候会阻塞）

# ConcurrentSkipListMap

> 对于一个单链表，即使**链表是有序**的，如果我们想要在其中查找某个数据，也只能**从头到尾遍历链表**，这样效率自然就会很低，跳表就不一样了。**跳表是一种可以用来快速查找的数据结构，有点类似于平衡树**。它们都可以**对元素进行快速的查找**。但一个重要的区别是：对**平衡树的插入和删除**往往很可能**导致平衡树进行一次全局的调整**。而对**跳表的插入和删除**只需要**对整个数据结构的局部进行操作**即可。这样带来的好处是：**在高并发的情况下，你会需要一个全局锁来保证整个平衡树的线程安全**。而对于**跳表，你只需要部分锁**即可。这样，在高并发环境下，你就可以拥有更好的性能。而就查询的性能而言，**跳表的时间复杂度也是 O(logn)** 所以在并发数据结构中，JDK 使用跳表来实现一个 Map。

跳表的本质是**维护多个链表**，且**链表是分层**的
![lyx-20241126133648504](attachments/img/lyx-20241126133648504.png)

- **最低层**的链表维护**跳表内所有元素**，每**上面一层**链表都**是下面一层的子集**
- 跳表内所有链表的元素都是**排序**的
- 查找时，可以**从顶级链表开始找**。一旦发现**被查找的元素大于当前链表中的取值（这里应该加上一句，小于前一个节点，比如下面如果是查找3，那么就从1跳下去），就会转入下一层链表继续找**。这也就是说在查找过程中，搜索是跳跃式的。如上图所示，在跳表中查找元素 18。

![lyx-20241126133648938](attachments/img/lyx-20241126133648938.png)
查找 18 的时候原来需要遍历 18 次，现在只需要 7 次即可。针对链表长度比较大的时候，构建索引查找效率的提升就会非常明显 （**这里好像不太对，原来也不需要遍历18次,反正大概率是说效率高就是了**）

使用**跳表**实现 `Map` 和使用**哈希**算法实现 `Map` 的另外一个不同之处是：**哈希并不会保存元素的顺序，而跳表内所有的元素都是排序的**。因此在对跳表进行遍历时，你会得到一个有序的结果。所以，如果你的应用**需要有序性，那么跳表就是你不二的选择**。JDK 中实现这一数据结构的类是 **`ConcurrentSkipListMap`**。

