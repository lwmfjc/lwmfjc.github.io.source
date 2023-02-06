---
title: ly0310lyThreadLocal详解
description: ThreadLocal详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-并发
date: 2022-12-05 17:31:52
updated: 2022-12-05 17:31:52
---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!
>
> 本文来自一枝花算不算浪漫投稿， 原文地址：[https://juejin.cn/post/6844904151567040519open in new window](https://juejin.cn/post/6844904151567040519)。 感谢作者!

思维导图  
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1.af0577dc.png)

# 目录

# ThreadLocal代码演示

简单使用

```java
public class ThreadLocalTest {
    private List<String> messages = Lists.newArrayList();

    public static final ThreadLocal<ThreadLocalTest> holder = ThreadLocal.withInitial(ThreadLocalTest::new);

    public static void add(String message) {
        holder.get().messages.add(message);
    }

    public static List<String> clear() {
        List<String> messages = holder.get().messages;
        holder.remove();

        System.out.println("size: " + holder.get().messages.size());
        return messages;
    }

    public static void main(String[] args) {
        ThreadLocalTest.add("一枝花算不算浪漫");
        System.out.println(holder.get().messages);
        ThreadLocalTest.clear();
    }
}
/* 结果 
[一枝花算不算浪漫]
size: 0
*/
```

**`ThreadLocal`**对象可以提供**线程局部变量**，**每个线程`Thread`拥有一份自己的副本变量**，多个线程互不干扰。

> 回顾之前的知识点  
>
> ```java
> public void set(T value) {
>     //获取当前请求的线程    
>     Thread t = Thread.currentThread();
>     //取出 Thread 类内部的 threadLocals 变量(哈希表结构)
>     ThreadLocalMap map = getMap(t);
>     if (map != null)
>         // 将需要存储的值放入到这个哈希表中
>         //★★实际使用的方法
>         map.set(this, value);
>     else
>         //★★实际使用的方法
>         createMap(t, value);
> }
> ThreadLocalMap getMap(Thread t) {
>     return t.threadLocals;
> }
> ```
>
> - 如上，实际存取都是从Thread的threadLocals （ThreadLocalMap类）中，并不是存在ThreadLocal上，ThreadLocal用来传递了变量值，只是ThreadLocalMap的封装
> - ThreadLocal类中通过Thread.currentThread()获取到当前线程对象后，直接通过getMap(Thread t) 可以访问到该线程的ThreadLocalMap对象
> - 每个Thread中具备一个ThreadLocalMap，而ThreadLocalMap可以存储以ThreadLocal为key，Object对象为value的键值对

# ThreadLocal的数据结构

由上面回顾的知识点可知，value实际上都是保存在**线程类(Thread类)中的某个属性(ThreadLocalMap类)**中
![image-20221206091635103](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206091635103.png)

`Thread`类有一个类型为**`ThreadLocal.ThreadLocalMap`**的实例变量`threadLocals`，也就是说每个线程有一个自己的`ThreadLocalMap`。
ThreadLocalMap是一个静态内部类

> 没有修饰符，为包可见。比如父类有一个protected修饰的方法f()，不同包下存在子类A和其他类X，在子类中可以访问方法f()，即使在其他类X创建子类A实例a1，也不能调用a1.f() 
>
> ![image-20221206092433827](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206092433827.png)

ThreadLocalMap有自己独立实现，简单地将它的**key视作ThreadLocal**，**value为代码中放入的值**，（看底层代码可知，实际key不是ThreadLocal本身，而是它的一个弱引用）

**★每个线程**在往`ThreadLocal`里放值的时候，都会往**自己的`ThreadLocalMap`**里存，读也是**以`ThreadLocal`作为引用，在自己的`map`里找对应的`key`**，从而实现了**线程隔离**。

`ThreadLocalMap`有点类似`HashMap`的结构，只是`HashMap`是由**数组+链表**实现的，而`ThreadLocalMap`中并没有**链表**结构。其中，还要注意`Entry`类， 它的`key`是`ThreadLocal<?> k` ，(Entry类)继承自`WeakReference`， 也就是我们常说的弱引用类型。

> 如下，有个数组存放Entry(弱引用类，且有属性value)，且
>
> ![image-20221206094304751](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206094304751.png)
>
> ---
>
> ```java
> static class ThreadLocalMap { 
>         static class Entry extends WeakReference<ThreadLocal<?>> {
>             /** The value associated with this ThreadLocal. */
>             Object value;
> 
>             Entry(ThreadLocal<?> k, Object v) {
>                 super(k);
>                 value = v;
>             }
>         }
>     //.....
> }
> ```

# 为上面的知识点总结一张图

![image-20221206095002176](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206095002176.png)

# GC之后key是否为null

> WeakReference的使用 
>
> ```java  
> WeakReference<Car> weakCar = new WeakReference(Car)(car); 
> weakCar.get();  //如果值为null表示已经被回收了
> ```

问题：  ThreadLocal的key为弱引用，那么在ThreadLocal.get()的时候，发生GC之后，key是否为null

- Java的四种引用类型
  - 强引用：通常情况new出来的为强引用，只要强引用存在，垃圾回收器**永远不会**回收被引用的对象（即使内存不足）
  - 软引用：使用SoftReference修饰的对象称软引用，软引用指向的对象在**内存要溢出的时候**被回收
  - 弱引用：使用WeakReference修饰的对象称为弱引用，只要发生垃圾回收，如果这个对象只被弱引用指向，那么就会被回收
  - 虚引用：虚引用是最弱的引用，用PhantomReference定义。唯一的作用就是**用队列接收对象即将死亡的通知**

使用反射方式查看GC后ThreadLocal中的数据情况

```java
/*
t.join()方法阻塞调用此方法的线程(calling thread)进入 TIMED_WAITING 状态，直到线程t完成，此线程再继续
*/
public class ThreadLocalDemo {

    public static void main(String[] args) throws NoSuchFieldException, IllegalAccessException, InterruptedException {
        Thread t = new Thread(()->test("abc",false));
        t.start();
        t.join();
        System.out.println("--gc后--");
        Thread t2 = new Thread(() -> test("def", true));
        t2.start();
        t2.join();
    }

    private static void test(String s,boolean isGC)  {
        try {
            new ThreadLocal<>().set(s);
            if (isGC) {
                System.gc();
            }
            Thread t = Thread.currentThread();
            Class<? extends Thread> clz = t.getClass();
            Field field = clz.getDeclaredField("threadLocals");
            field.setAccessible(true);
            Object ThreadLocalMap = field.get(t);
            Class<?> tlmClass = ThreadLocalMap.getClass();
            Field tableField = tlmClass.getDeclaredField("table");
            tableField.setAccessible(true);
            Object[] arr = (Object[]) tableField.get(ThreadLocalMap);
            for (Object o : arr) {
                if (o != null) {
                    Class<?> entryClass = o.getClass();
                    Field valueField = entryClass.getDeclaredField("value");
                    Field referenceField = entryClass.getSuperclass().getSuperclass().getDeclaredField("referent");
                    valueField.setAccessible(true);
                    referenceField.setAccessible(true);
                    System.out.println(String.format("弱引用key:%s,值:%s", referenceField.get(o), valueField.get(o)));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
/* 结果如下
弱引用key:java.lang.ThreadLocal@433619b6,值:abc
弱引用key:java.lang.ThreadLocal@418a15e3,值:java.lang.ref.SoftReference@bf97a12
--gc后--
弱引用key:null,值:def 
*/

```

gc之后的图：  
![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/3.a63c3de1.png)
```new ThreadLocal<>().set(s);```  GC之后，key就会被回收，我们看到上面的debug中referent=null 

如果这里修改代码，

```
ThreadLocal<Object> threadLocal=new ThreadLocal<>();
threadLocal.set(s);
```

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/4.c4285c13.png)

使用弱引用+垃圾回收

**如上，垃圾回收前，ThreadLoal是存在强引用的，因此如果如上修改代码，则key不为null**  

**当不存在强引用时，key会被回收**，即出现**value没被回收，key被回收，导致key永远存在，内存泄漏**

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/5.deed12c8.png)



# ThreadLocal.set()方法源码详解

如图所示  
![image-20221206134817533](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206134817533.png)

ThreadLocal中的set()方法原理如上，先取出线程Thread中的threadLocals，判断是否存在，然后使用ThreadLocal中的set方法进行数据处理

```java
public void set(T value) {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null)
        map.set(this, value);
    else
        createMap(t, value);
}

void createMap(Thread t, T firstValue) {
    t.threadLocals = new ThreadLocalMap(this, firstValue);
} 
```

# ThreadLocalMap Hash算法

ThreadLocalMap实现了自己的hash算法来解决**散列表数组冲突**问题：  

```java
//i为当前key在散列表中对应的数组下标位置
int i = key.threadLocalHashCode & (len-1);
```

threadLocalHashCode值的计算，ThreadLocal中有一个**属性为HASH_INCREMENT = 0x61c88647**  

0x61c88647，又称为**斐波那契数**也叫**黄金分割数**，hash增量为这个数，好处是**hash 分布非常均匀**

```java
public class ThreadLocal<T> {
    private final int threadLocalHashCode = nextHashCode();

    private static AtomicInteger nextHashCode = new AtomicInteger();

    private static final int HASH_INCREMENT = 0x61c88647;

    //hashCode增加
    private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }

    static class ThreadLocalMap {
        ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
            table = new Entry[INITIAL_CAPACITY];
            int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);

            table[i] = new Entry(firstKey, firstValue);
            size = 1;
            setThreshold(INITIAL_CAPACITY);
        }
    }
} 
```

例子如下，产生的哈希码分布十分均匀  
![image-20221206135759498](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221206135759498.png)



★★  说明，下面的所有示例图中，**绿色块Entry**代表为**正常数据**，**灰色块**代表Entry的**key为null**，已被垃圾回收。白色块代表Entry为null（或者说数组那个位置为null(没有指向)）

# ThreadLocalMap Hash冲突

- ThreadLocalMap 中使用**黄金分割数**作为**hash计算因子**，大大减少Hash冲突的概率
- HashMap中解决冲突的方法，是在数组上构造一个**链表**结构，冲突的数据**挂载**到链表上，如果链表长度超过一定数量则会**转化为红黑树**
- ThreadLocalMap中没有链表结构（使用**线性向后查找**）
  - 如图
    ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/7.5b9136ff.png)
  - 假设需要插入value = 27 的数据，hash后应该落入槽位4，而槽位已经有了Entry数据
  - 此时**线性向后查找**，一直找到Entry为null的操作才会停止查找，将当前元素放入该槽位中
  - 线性向后查找**迭代**中，会遇到**Entry不为null且key值相等**，以及**Entry中的key为null（图中Entry 为 2）**的情况，处理方式不同
    - set过程中如果遇到了**key过期(key为null)的Entry数据**，实际上会进行一轮**探测式清理**操作

# ThreadLocalMap.set() 详解

ThreadLocalMap.set() 原理图解

往ThreadLocalMap中set数据（新增或更新数据）分为好几种

1. 通过**hash计算后**的槽位对应的**Entry数据为空**
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/9.3269651c.png)
   直接将数据放到该槽位即可

2. 槽位数据不为空，**key值与当前ThreadLocal通过hash**计算获取的**key值一致**
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/10.706954d1.png)
   直接更新该槽位的数据

3. 槽位数据不为空，往后**遍历**过程中，在找到Entry为null的槽位之前，**没有遇到过期的Entry**
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/11.bb4e1504.png)
   遍历散列数组的过程中，线性往后查找，如果找到Entry为null的槽位则将数据放入槽位中；或者往后遍历过程中遇到key值相等的数据则更新

4. 槽位数据不为空，在找到Entry为null的槽位之前，遇到了过期的Entry，如下图
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/12.7f276023.png)
   此时会执行replaceStableEntry()方法，该方法含义是**替换过期数据的逻辑**

   > ... 以下省略，太复杂 

   替换完成后也是进行过期元素清理工作，清理工作主要是有两个方法：`expungeStaleEntry()`和`cleanSomeSlots()`

   **经过迭代处理后，有过`Hash`冲突数据的`Entry`位置会更靠近正确位置，这样的话，查询的时候 效率才会更高。**

# `ThreadLocalMap`过期 key 的探测式清理流程(略过)

# ThreadLocalMap扩容机制

在`ThreadLocalMap.set()`方法的最后，如果执行完启发式清理工作后，未清理到任何数据，且当前散列数组中`Entry`的数量已经达到了**列表的扩容阈值`(len*2/3)`**，就开始执行`rehash()`逻辑：

```java
if (!cleanSomeSlots(i, sz) && sz >= threshold)
    rehash();
```

rehash()的具体实现  

```java
private void rehash() {
    expungeStaleEntries();

    if (size >= threshold - threshold / 4)
        resize();
}

private void expungeStaleEntries() {
    Entry[] tab = table;
    int len = tab.length;
    for (int j = 0; j < len; j++) {
        Entry e = tab[j];
        if (e != null && e.get() == null)
            expungeStaleEntry(j);
    }
} 
```

注意：  

1. threshold ```[ˈθreʃhəʊld], 门槛```  = length * 2/3

2. rehash之前进行一次容量判断( 是否 > threshold , 是则rehash)

3. rehash时先进行expungeStaleEntries() （探索式清理，从table起始为止）

   > 这里首先是会进行探测式清理工作，从`table`的起始位置往后清理，上面有分析清理的详细流程。清理完成之后，`table`中可能有一些`key`为`null`的`Entry`数据被清理掉，所以此时通过判断`size >= threshold - threshold / 4` 也就是`size >= threshold * 3/4` 来决定是否扩容。

4. 清理后如果大于 threshold 的3/4 ，则进行扩容
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/24.ec7f7610.png)

5. 具体的resize()方法
   以oldTab .len = 8

   1. 容后的`tab`的大小为`oldLen * 2` =16

   2. 遍历老的散列表，重新计算`hash`位置，然后放到新的`tab`数组中，如果出现`hash`冲突则往后寻找最近的`entry`为`null`的槽位

   3. 遍历完成之后，`oldTab`中所有的`entry`数据都已经放入到新的`tab`中了。重新计算`tab`下次扩容的**阈值**
      代码如下

      ```java
      private void resize() {
          Entry[] oldTab = table;
          int oldLen = oldTab.length;
          int newLen = oldLen * 2;
          Entry[] newTab = new Entry[newLen];
          int count = 0;
      
          for (int j = 0; j < oldLen; ++j) {
              Entry e = oldTab[j];
              if (e != null) {
                  ThreadLocal<?> k = e.get();
                  if (k == null) {
                      e.value = null;
                  } else {
                      int h = k.threadLocalHashCode & (newLen - 1);
                      while (newTab[h] != null)
                          h = nextIndex(h, newLen);
                      newTab[h] = e;
                      count++;
                  }
              }
          }
      
          setThreshold(newLen);
          size = count;
          table = newTab;
      } 
      ```

# ThreadLocalMap.get() 详解

1.  通过查找`key`值计算出散列表中`slot`位置，然后该`slot`位置中的`Entry.key`和查找的`key`一致，则直接返回
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/26.ff0553de.png)

2. `slot`位置中的`Entry.key`和要查找的`key`不一致，之后**清理**+**遍历**
   ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/27.9c78c2a2.png)

   > 我们以`get(ThreadLocal1)`为例，通过`hash`计算后，正确的`slot`位置应该是 4，而`index=4`的槽位已经有了数据，且`key`值不等于`ThreadLocal1`，所以需要继续往后迭代查找。
   >
   > 迭代到`index=5`的数据时，此时`Entry.key=null`，触发一次探测式数据回收操作，执行`expungeStaleEntry()`方法，执行完后，`index 5,8`的数据都会被回收，而`index 6,7`的数据都会前移。`index 6,7`前移之后，继续从 `index=5` 往后迭代，于是就在 `index=5` 找到了`key`值相等的`Entry`数据，如下图所示：
   > ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/28.ea7d5196.png)

3. `ThreadLocalMap.get()`源码详解

   ```java
   private Entry getEntry(ThreadLocal<?> key) {
       int i = key.threadLocalHashCode & (table.length - 1);
       Entry e = table[i];
       if (e != null && e.get() == key)
           return e;
       else
           return getEntryAfterMiss(key, i, e);
   }
   
   private Entry getEntryAfterMiss(ThreadLocal<?> key, int i, Entry e) {
       Entry[] tab = table;
       int len = tab.length;
   
       while (e != null) {
           ThreadLocal<?> k = e.get();
           if (k == key)
               return e;
           if (k == null)
               expungeStaleEntry(i);
           else
               i = nextIndex(i, len);
           e = tab[i];
       }
       return null;
   } 
   ```

   

# ThreadLocalMap过期key的启发式清理流程(略过，跟移位运算符有关)

> 上面多次提及到`ThreadLocalMap`过期key的两种清理方式：**探测式清理(expungeStaleEntry())**、**启发式清理(cleanSomeSlots())**
>
> 探测式清理是以当前`Entry` 往后清理，遇到值为`null`则结束清理，属于**线性探测清理**。
>
> 而启发式清理被作者定义为：**Heuristically scan some cells looking for stale entries**.

# Inheritable ThreadLocal

使用`ThreadLocal`的时候，在异步场景下是无法给子线程共享父线程中创建的线程副本数据的。JDK中存在InheritableThreadLocal类可以解决处理这个问题  

> 原理： 子线程是通过在父线程中通过new Thread()方法创建子线程，Thread#init 方法在Thread的构造方法中被调用，**init**方法中拷贝父线程数据到子线程中  
>
> ```java
> private void init(ThreadGroup g, Runnable target, String name,
>                       long stackSize, AccessControlContext acc,
>                       boolean inheritThreadLocals) {
>     if (name == null) {
>         throw new NullPointerException("name cannot be null");
>     }
> 
>     if (inheritThreadLocals && parent.inheritableThreadLocals != null)
>         this.inheritableThreadLocals =
>             ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
>     this.stackSize = stackSize;
>     tid = nextThreadID();
> } 
> ```

```java
public class InheritableThreadLocalDemo {
    public static void main(String[] args) {
        ThreadLocal<String> ThreadLocal = new ThreadLocal<>();
        ThreadLocal<String> inheritableThreadLocal = new InheritableThreadLocal<>();
        ThreadLocal.set("父类数据:threadLocal");
        inheritableThreadLocal.set("父类数据:inheritableThreadLocal");

        new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("子线程获取父类ThreadLocal数据：" + ThreadLocal.get());
                System.out.println("子线程获取父类inheritableThreadLocal数据：" + inheritableThreadLocal.get());
            }
        }).start();
    }
}
/*结果
子线程获取父类ThreadLocal数据：null
子线程获取父类inheritableThreadLocal数据：父类数据:inheritableThreadLocal
*/
```

但是如果不是直接new()，也就是实际中我们都是通过使用线程池来获取新线程的，那么可以使用阿里开源的一个组件解决这个问题 `TransmittableThreadLocal`

# ThreadLocal项目中使用实战

**这里涉及到requestId，没用过，不是很懂，略过**

## ThreadLocal使用场景

## Feign远程调用解决方案

## 线程池异步调用,requestId 传递
## 使用MQ发送消息给第三方系统