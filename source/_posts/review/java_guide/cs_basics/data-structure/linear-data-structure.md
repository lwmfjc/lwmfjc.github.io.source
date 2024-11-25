---
title: 线性数据结构
description: 线性数据结构:数组、链表、栈、队列
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-data-structure
date: 2022-12-20 13:34:59
updated: 2022-12-20 13:34:59
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 数组

- 数组（Array）是一种常见数据结构，由**相同类型的元素（element）**组成，并且是使用一块**连续的内存**来存储
- 直接可以利用元素的**索引（index）**可以计算出该元素对应的存储地址
- 数组的特点是：提供**随机访问**并且**容量有限**

> 假设数组长度为n：  
> 访问：O(1)  //访问特定位置的元素
>
> 插入：O(n)  //最坏的情况插入在数组的**首部**并需要**移动所有元素**时
>
> 删除：O(n)  //最坏的情况发生在删除数组的**开头**并需要移动**第一元素**后面所有的元素时

![image-20221220143941212](images/mypost/image-20221220143941212.png)

# 链表

## 链表简介

- 链表（LinkedList）虽然是一种**线性表**，但是并**不会按线性**的顺序**存储**数据，使用的**不是**连续的内存空间来**存储数据**

- 链表的**插入**和**删除**操作的复杂度为O(1)，只需要直到目标位置元素的**上一个元素**即可。但是，在**查找一个节点**或者**访问特定位置**的节点的时候复杂度为**O(n)**

- 使用链表结构可以**克服数组需要预先知道数据大小**的缺点，链表结构可以充分利用**计算机内存空间**，实现灵活的**内存动态管理**

  > 但链表**不会节省空间**，相比于数组会**占用**更多空间，因为链表中**每个节点**存放的还有**指向其他节点**的指针。除此之外，链表不具有**数组随机读取**的优点

## 链表分类

**单链表**、**双向链表**、**循环链表**、**双向循环链表**  

> 假设链表中有**n个元素**  
> 访问：O(n) //访问特地给位置的元素
>
> 插入删除：O(1) //必须要知道插入元素的位置

### 单链表

- **单链表**只有一个方向，结点**只有一个后继指针next**指向后面的节点。因此，链表这种数据结构通常在**物理内存**上是**不连续**的
- 我们习惯性地把**第一个结点**叫做**头结点**，链表通常有一个**不保存任何值的head节点**（头结点），通过头结点我们可以**遍历整个链表**，尾结点通常**指向null**
- 如下图
  ![image-20221220164125131](images/mypost/image-20221220164125131.png)

### 循环链表

- 循环链表是一种**特殊的单链表**，和单链表不同的是**循环链表的尾结点**不是指向null，而是**指向链表的头结点**
- 如图
  ![image-20221220164334567](images/mypost/image-20221220164334567.png)

### 双向链表

- 双向链表包含**两个指针**，一个**prev**指向**前一个节点**，另一个**next**指向
- 如图
  ![image-20221220164450954](images/mypost/image-20221220164450954.png)

### 双向循环链表

双向循环链表的**最后一个节点的next**指向head，而head的**prev**指向最后一个节点，构成一个环

![image-20221220164602604](images/mypost/image-20221220164602604.png)

## 应用场景

- 如果需要支持**随机访问**的话，链表无法做到
- 如果需要**存储的数据元素个数不确定**，并且需要经常**添加**和**删除**数据的话，使用**链表**比较合适
- 如果需要**存储的数据元素**的个数确定，并且不需要**经常添加**和**删除**数据的话，使用数组比较合适

## 数组 vs 链表

- 数组支持**随机访问**，链表不支持
- 数组使用的是**连续内存空间** **对CPU缓存机制**友好，链表则**相反**
- 数组的**大小固定**，而链表则**天然支持动态扩容**。如果生命的数组过小，需要另外申请一个**更大的内存空间**存放数组元素，然后将**原数组拷贝进去**，这个操作比较耗时

# 栈

## 栈简介

- 栈（stack）只允许在**有序的线性数据集合**的**一端**（称为栈顶top）进行**加入数据（push）**和**移除数据（pop）**。因而按照**后进先出（LIFO，Last In First Out）**的原理运作。
- 栈中，**push**和**pop**的操作都发生在栈顶
- 栈常用**一维数组**或**链表**来实现，用数组实现的叫**顺序栈**，用链表实现的叫做**链式栈**

> 假设堆栈中有n个元素。
> 访问：O（n）//最坏情况
> 插入删除：O（1）//顶端插入和删除元素

如图：  
![image-20221220165405830](images/mypost/image-20221220165405830.png)

## 栈的常见应用场景

当我们要处理的数据，只涉及在一端**插入**和**删除**数据，并且满足**后进先出（LIFO，LastInFirstOut）**的特性时，我们就可以使用**栈**这个数据结构。

### 实现浏览器的回退和前进功能

我们只需要使用**两个栈(Stack1 和 Stack2)**和就能实现这个功能。比如你按顺序查看了 1,2,3,4 这四个页面，我们**依次把 1,2,3,4 这四个页面压入 Stack1** 中。当你**想回头看 2** 这个页面的时候，你点击回退按钮，我们**依次把 4,3 这两个页面从 Stack1 弹出**，然后**压入 Stack2** 中。假如你又想**回到页面 3**，你点击前进按钮，我们**将 3 页面从 Stack2 弹出**，然后**压入到 Stack1** 中。示例图如下  
![image-20221220170624867](images/mypost/image-20221220170624867.png)

### 检查符号是否承兑出现

> 给定一个**只**包括 `'('`，`')'`，`'{'`，`'}'`，`'['`，`']'` 的字符串，判断**该字符串是否有效**。
>
> 有效字符串需满足：
>
> 1. **左括号必须用相同类型的右括号**闭合。
> 2. **左括号必须以正确的顺序闭合**。
>
> 比如 "()"、"()[]{}"、"{[]}" 都是有效字符串，而 "(]" 、"([)]" 则不是。

这个问题实际是 Leetcode 的一道题目，我们可以**利用栈 `Stack`** 来解决这个问题。

1. 首先我们将**括号间的对应规则存放在 `Map`** 中，这一点应该毋容置疑；
2. 创建一个栈。遍历字符串，如果字符是**左括号就直接加入`stack`**中，否则**将`stack` 的栈顶元素**与**这个括号**做比较，如果不相等就直接返回 false。遍历结束，如果`stack`为空，返回 `true`。

```java
public boolean isValid(String s){
    // 括号之间的对应规则
    HashMap<Character, Character> mappings = new HashMap<Character, Character>();
    mappings.put(')', '(');
    mappings.put('}', '{');
    mappings.put(']', '[');
    Stack<Character> stack = new Stack<Character>();
    char[] chars = s.toCharArray();
    for (int i = 0; i < chars.length; i++) {
        if (mappings.containsKey(chars[i])) {
            char topElement = stack.empty() ? '#' : stack.pop();
            if (topElement != mappings.get(chars[i])) {
                return false;
            }
        } else {
            stack.push(chars[i]);
        }
    }
    return stack.isEmpty();
}

```

### 反转字符串

将字符串中的每个字符**先入栈再出栈**就可以了。

### 维护函数调用

**最后一个被调用**的函数**必须先完成执行**，符合栈的 **后进先出（LIFO, Last In First Out）** 特性。

## 栈的实现

- 栈既可以通过**数组**实现，也可以通过**链表**实现。两种情况下，**入栈**、**出栈**的时间复杂度均为O(1)

- 下面使用**数组**下实现栈，具有**push()**、**pop()** （返回栈顶元素并出栈）、**peek()** （返回栈顶元素不出栈）、**isEmpty()** 、**size()** 这些基本的方法

  > 每次入栈前先判断**栈容量是否够用**，如果不够用就用Arrays.copyOf() 进行扩容

  ```java
  public class MyStack {
      private int[] storage;//存放栈中元素的数组
      private int capacity;//栈的容量
      private int count;//栈中元素数量
      private static final int GROW_FACTOR = 2;
  
      //不带初始容量的构造方法。默认容量为8
      public MyStack() {
          this.capacity = 8;
          this.storage=new int[8];
          this.count = 0;
      }
  
      //带初始容量的构造方法
      public MyStack(int initialCapacity) {
          if (initialCapacity < 1)
              throw new IllegalArgumentException("Capacity too small.");
  
          this.capacity = initialCapacity;
          this.storage = new int[initialCapacity];
          this.count = 0;
      }
  
      //入栈
      public void push(int value) {
          if (count == capacity) {
              ensureCapacity();
          }
          storage[count++] = value;
      }
  
      //确保容量大小
      private void ensureCapacity() {
          int newCapacity = capacity * GROW_FACTOR;
          storage = Arrays.copyOf(storage, newCapacity);
          capacity = newCapacity;
      }
  
      //返回栈顶元素并出栈
      private int pop() {
          if (count == 0)
              throw new IllegalArgumentException("Stack is empty.");
          count--;
          return storage[count];
      }
  
      //返回栈顶元素不出栈
      private int peek() {
          if (count == 0){
              throw new IllegalArgumentException("Stack is empty.");
          }else {
              return storage[count-1];
          }
      }
  
      //判断栈是否为空
      private boolean isEmpty() {
          return count == 0;
      }
  
      //返回栈中元素的个数
      private int size() {
          return count;
      }
  
  }
  /*----
  MyStack myStack = new MyStack(3);
  myStack.push(1);
  myStack.push(2);
  myStack.push(3);
  myStack.push(4);
  myStack.push(5);
  myStack.push(6);
  myStack.push(7);
  myStack.push(8);
  System.out.println(myStack.peek());//8
  System.out.println(myStack.size());//8
  for (int i = 0; i < 8; i++) {
      System.out.println(myStack.pop());
  }
  System.out.println(myStack.isEmpty());//true
  myStack.pop();//报错：java.lang.IllegalArgumentException: Stack is empty. 
  */
  ```

# 队列

## 队列简介

- 队列是**先进先出（FIFO，First In，First Out）**的线性表

- 通常用**链表**或**数组**来实现，用数组实现的队列叫做**顺序队列**，用**链表**实现的队列叫做**链式队列**。

- 队列只允许在**后端（rear）**进行插入操作也就是**入队enqueue**，在**前端（front）**进行删除操作也就是**出队 dequeue**

- 队列的操作方式和堆栈类似，唯一的区别在于**队列**只允许**新数据在后端**进行添加（不允许在后端删除）

  > 假设队列中有n个元素。
  > 访问：O（n）//最坏情况
  > 插入删除：O（1）//后端插入前端删除元素
  >
  > ![队列](images/mypost/%25E9%2598%259F%25E5%2588%2597.png)

## 队列分类

### 单队列

这是**常见**的队列，每次添加元素时，都是添加到**队尾**。单队列又分为**顺序队列（数组实现）**和**链式队列（链表实现）**

> **顺序队列**存在**假溢出**：即明明有位置却不能添加

假设下图是一个顺序队列，我们将前两个元素 1,2 出队，并入队两个元素 7,8。当进行入队、出队操作的时候，front 和 rear 都会持续往后移动，当 rear 移动到最后的时候,我们无法再往队列中添加数据，即使数组中还有空余空间，这种现象就是 **”假溢出“** 。除了假溢出问题之外，如下图所示，当添加元素 8 的时候，rear 指针移动到数组之外（越界）  
![image-20221225185308791](images/mypost/image-20221225185308791.png)

> 为了避免当只有一个元素的时候，队头和队尾重合使处理变得麻烦，所以引入两个指针，**front 指针指向对头元素（不是头结点）**，rear 指针指向**队列最后一个元素的下一个位置**，这样当 **front 等于 rear** 时，此队列不是还剩一个元素，而是空队列。——From 《大话数据结构》  
> **（当只有一个元素时，front 指向0，rear指向1）**

### 循环队列

循环队列可以解决顺序队列的假溢出和越界问题。解决办法就是：**从头开始**，这样也就会形成**头尾相接的循环**，这也就是循环队列名字的由来。
![image-20221225185743723](images/mypost/image-20221225185743723.png)
（超出的时候，将rear指向0下标）。之后再添加时，向后移动即可

- 顺序队列中，我们说 `front==rear` 的时候队列为空，循环队列中则不一样，也可能为满，如上图所示。解决办法有两种：
  1. 可以设置一个标志变量 `flag`,当 `front==rear` 并且 `flag=0` 的时候队列为空，当`front==rear` 并且 `flag=1` 的时候队列为满。
  2. 队列为空的时候就是 `front==rear` ，**队列满的时候，我们保证数组还有一个空闲的位置**，rear 就指向这个空闲位置，如下图所示，那么现在判断队列是否为满的条件就是： `(rear+1) % QueueSize= front` 。
     ![image-20221225185923759](images/mypost/image-20221225185923759.png)
     其实也就是换一个定义罢了

## 常见应用场景

当我们需要**按照一定顺序**来处理数据的时候可以考虑使用队列这个数据结构

- 阻塞队列： 阻塞队列可以看成在**队列基础上加了阻塞**操作的队列。当**队列为空**的时候，**出队操作阻塞**，当**队列满**的时候，**入队操作阻塞**。使用阻塞队列我们可以很容易**实现“生产者 - 消费者“**模型
- **线程池中的请求/任务队列：** **线程池**中**没有空闲线程**时，**新的任务请求线程资源**时，线程池该如何处理呢？答案是**将这些请求放在队列**中，当**有空闲线程的时候，会循环中反复从队列中获取任务来执行**。队列分为**无界队列(基于链表)和有界队列(基于数组)**。无界队列的特点就是可以一直入列，除非系统资源耗尽，比如 ：**`FixedThreadPool`** 使用无界队列 **`LinkedBlockingQueue`**。但是有界队列就不一样了，当队列满的话后面再有任务/请求就会拒绝，在 Java 中的体现就是会抛出**`java.util.concurrent.RejectedExecutionException`** 异常。
- Linux 内核进程队列（按优先级排队）
- 现实生活中的派对，播放器上的播放列表;
- 消息队列
- 等等......