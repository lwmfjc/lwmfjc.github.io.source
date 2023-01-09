---
title: 堆
description: 堆
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-data-structure
date: 2023-01-06 10:46:19
updated: 2023-01-06 10:46:19
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 什么是堆

- 堆是**满足以下条件**的树
  堆中每一个节点值都**大于等于（或小于等于）子树中所有节点**。或者说，任意一个节点的值**都大于等于（或小于等于）**所有子节点的值

  > 大家可以把堆(最大堆)理解为一个公司,这个公司很公平,谁能力强谁就当老大,不存在弱的人当老大,老大手底下的人一定不会比他强。这样有助于理解后续堆的操作。

  - **堆不一定是完全二叉树**，为了方便**存储**和**索引**，我们通常用完全二叉树的形式来表示堆  
    广为人知的**斐波那契堆**和**二项堆**就不是完全二叉树，它们甚至都**不是二叉树**
  -  (二叉)堆是一个数组，它可以被看成是一个**近似的完全二叉树**
  
- 下面给出的图是否是堆（通过定义）

  1，2是。
  3不是。
  ![image-20230108214044120](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230108214044120.png)

# 堆的用途

- 当我们**只关心**所有数据中的**最大值**或者**最小值**，存在**多次获取最大值**或者**最小值**，多次插入或删除数据时，就可以使用堆。

  > 有小伙伴可能会想到用**有序数组**，初始化一个有序数组时间复杂度是 `O(nlog(n))`**[也就是将一堆数字乱序排序，最快是O(nlog(n))]**，查找最大值或者最小值时间复杂度都是 `O(1)`，但是，涉及到更新（插入或删除）数据时，时间复杂度为 `O(n)`，即使是使用复杂度为 `O(log(n))` 的二分法找到要插入或者删除的数据，在移动数据时也需要 `O(n)` 的时间复杂度。

- 相对于有序数组而言，堆的主要优势在于更新数据效率较高

  - 堆的**初始化时间复杂度**为O(nlog(n))，堆可以做到**O(1)**的时间复杂度取出**最大值**或者**最小值**，**O(log(n))**的时间复杂度**插入或者删除**数据

# 堆的分类

- 堆分为**最大堆**和**最小堆**，二者的区别在于节点的**排序方式**
  - 最大堆：堆中的每一个节点的值**都大于**子树中**所有节点**的值
  - 最小堆：堆中的每一个节点的值**都小于**子树中**所有节点**的值
- 如图，图1是最大堆，图2是最小堆
  ![image-20230108221541796](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230108221541796.png)

# 堆的存储

- 由于**完全二叉树的优秀性质**，**利用数组存储二叉树**即节省空间，又**方便索引**（若根结点的序号为1，那么对于树中任意节点i，其左子节点序号为 `2*i`，右子节点序号为 `2*i+1`）。
- 为了**方便存储**和**索引**，**（二叉）堆**可以用**完全二叉树**的形式进行存储。存储的方式如下图所示
  ![image-20230108222619449](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230108222619449.png)

# 堆的操作

- 堆的更新操作主要包括两种：**插入元素**和**删除堆顶元素**

  > 堆是一个公平的公司，**有能力的人**自然会走到与他能力所匹配的位置

## 插入元素

1. 将要插入的元素放到**最后**
   ![image-20230109103135560](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109103135560.png)
2. 从底向上，如果**父节点**比**该元素小**，则该节点和父节点交换（其实就是一棵树有3个（最多）节点，与树上最大的节点比较）
   直到无法交换（已经与根节点比较过）
   ![image-20230109103340370](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109103340370.png)
   ![image-20230109103354015](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109103354015.png)

## 删除堆顶元素

- 根据堆的性质可知，**最大堆**的堆盯元素为所有元素中最大的，**最小堆**的堆顶元素是所有元素中最小的

- 当我们需要多次查找**最大元素**或者**最小元素**的时候，可以利用堆来实现

- 删除堆顶元素后，为了保持**堆的性质**，需要对堆的结构进行调整，我们可以将这个过程称之为**堆化**

  1. **自底向上**的堆化，上述的**插入元素**所使用的，就是自顶向上的**堆化**，元素从最底部向上移动
  2. **自顶向下**的堆化，元素由**顶部向下**移动。在讲解删除堆顶元素的方法时，我将阐述这**两种操作的过程**

- **自底向上堆化**

  > 在堆这个公司中，会出现老大离职的现象，老大离职之后，它的位置就空出来了

  1. 首先删除堆顶元素，使得数组中下标为1的位置空出
     ![image-20230109111425216](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109111425216.png)

     > 那么他的位置由谁来接替呢，当然是他的直接下属了，谁能力强就让谁上

  2. 比较**根节点（当前节点）**的**左子节点**和**右子节点**，也就是下标为 2 ，3 的数组元素，将较大的元素填充到**根节点（下标为1）（当前遍历节点）**的位置
     ![image-20230109112005680](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109112005680.png)

     > 此时又空出一个位置了，老规矩，谁有能力谁上

  3. 一直循环比较**空出位置**的**左右子节点**，并将较大者移至空位，直到堆的最底部
     ![image-20230109112121358](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109112121358.png)

     > 此时已经完成**自顶向上**的堆化，没有元素可以填补空缺。但会发现数组中出现了”气泡”，导致存户空间的浪费。
     >
     > 解决办法：自顶向下堆化

- 自顶向下堆化
  自顶向下的堆化用一个词形容就是“石沉大海”

  1. 第一件事情，就是把石头抬起来，从海面扔下去。这个石头就是**堆的最后一个元素**，我们**将最后一个元素移动到堆顶**。
     ![image-20230109112439473](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109112439473.png)
  2. 将这个石头沉入海底，不停的与**左右子节点**的值进行比较，和**较大的子节点**交换位置，直到**无法交换位置**
     ![image-20230109112535327](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109112535327.png)
  3. 结果
     ![image-20230109112624540](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109112624540.png)

## 堆的操作总结

- **插入元素**：先将元素放置数组末尾，再**自底向上**堆化，将**末尾元素上浮**

- **删除堆顶元素**：删除堆顶元素，**将末尾元素放置堆顶**，再**自顶向下**堆化，将**堆顶元素下沉**。

  > 也可以自底向上堆化，但是会产生**气泡**，浪费存储空间。不建议

# 堆排序

堆排序的过程分两步

1. 建堆，将一个**无序的数组**，**建立成堆** 
2. 排序，[ 将**堆顶元素取出**，然后对**剩下的元素堆化** ]。
   - **反复迭代**，直到所有元素被取出

## 建堆

- 也就是对**所有非叶子结点**进行自顶向下

  如图，红色区域分别是堆的情况下。对于T，如果只**自顶向下**到P、L这层，被换到了这层的那个元素是不一定就比其他树大的，所以还是要依次自顶向下

  ![image-20230109140309966](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109140309966.png)
  这个构建堆操作的时间复杂度为O(n)
  ![image-20230109141141591](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109141141591.png)

- 首先要了解哪些是非叶节点，**最后一个结点的父节点及它（这个父节点）之前的元素**，都是非叶节点。也就是说，如果**节点个数为n**，那么我们需要对**n/2到1的节点进行自顶向下（沉底）堆化**

- 如图
  ![image-20230109143927351](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109143927351.png)

  1. 首先将初始的无序数组抽象为一棵树，图中的节点个数为6，所以4，5，6是叶子节点，1，2，3节点为非叶节点  
  2. 对1，2，3节点进行**自顶向下（沉底）**堆化，注意，顺序是从后往前堆化，从3号开始，一直到1号节点。
     - 3号节点堆化结果  
       ![image-20230109153344935](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109153344935.png)
     - 2号节点堆化结果
       ![image-20230109153422766](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109153422766.png)
     - 1号节点堆化结果
       ![image-20230109153456496](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109153456496.png)

## 排序

- 方法：由于堆顶元素是所有元素中最大的，所以我们**重复取出堆顶元素**，将这个最大的堆顶元素**放至数组末尾**，并**对剩下的元素进行堆化**即可
- 现在思考两个问题：
  - 删除堆顶元素后需要执行**自顶向下（沉底）**堆化还是**自底向上（上浮）**堆化？
  - 取出的堆顶元素存在哪，新建一个数组存？
- 答案
  1. 需要使用**自顶向下（沉底）**堆化，这个堆化一开始要**将末尾元素移动至堆顶**。由于这个时候末尾的位置已经空出来了由于堆中元素已经减小，这个位置不会再被使用，所以我们可以将**取出的元素放在末尾**。
  2. 其实是做了一次**交换**操作，将**堆顶和末尾元素调换**位置，从而将**取出堆顶元素**和**堆化的第一步(将末尾元素放至根结点位置)**进行合并
- 步骤
  1. 取出第一个元素并堆化
     ![image-20230109154808329](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109154808329.png)
  2. 取出第2个元素并堆化
     ![image-20230109154830946](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109154830946.png)
  3. 取出第3个元素并堆化
     ![](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109154851849.png)
  4. 取出第4个元素并堆化
     ![image-20230109155008000](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109155008000.png)
  5. 取出第5个元素并堆化
     ![image-20230109155104829](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109155104829.png)
  6. 取出第6个元素并堆化
     ![image-20230109155116813](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230109155116813.png)
  7. 排序完成