---
title: 图
description: 图
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-data-structure
date: 2022-12-26 08:47:25
updated: 2022-12-26 08:47:25
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

- 图是一种较为复杂的**非线性**结构
- **线性**数据结构的元素满足唯一的线性关系，**每个元素**（除第一个和最后一个外）只有一个**直接前驱**和一个**直接后继**
- **树形**数据结构的元素之间有着明显的**层级关系**
- **图形**结构的元素之间的关系是任意的
  - 图就是由**顶点**的**有穷非空集合**和顶点之间的**边**组成的集合，通常表示为：**G（V，E）**，其中，G表示一个图，V表示顶点的集合，E表示边的集合
  - 下面显示的即**图**这种数据结构，而且还是一张**有向图**
    ![image-20221226215910568](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221226215910568.png)

# 图的基本概念

## 顶点

- 图中的**数据元素**，我们称之为**顶点**，图至少有一个**顶点**（**有穷非空**集合）
- 对应到好友关系图，**每一个用户**就代表**一个顶点**

## 边

- 顶点之间的**关系**用**边**表示
- 对应到好友关系图，两个用户是好友的话，那两者之间就存在一条**边**

## 度

- 度表示一个顶点包含多少条边
- 有向图中，分为**出度**和**入度**，出度表示**从该顶点出去的边**的条数，入度表示**从进入该顶点的边**的条数
- 对应到好友关系图，度就代表了某个人的**好友数量**

## 无向图和有向图

边表示的是顶点之间的关系，有的关系是双向的，比如同学关系，A是B的同学，那么B也肯定是A的同学，那么在表示A和B的关系时，就不用关注方向，用**不带箭头的边**表示，这样的图就是**无向图**。

有的关系是有方向的，比如父子关系，师生关系，微博的关注关系，A是B的爸爸，但B肯定不是A的爸爸，A关注B，B不一定关注A。在这种情况下，我们就用**带箭头的边**表示二者的关系，这样的图就是**有向图**。

## 无权图和带权图

对于一个关系，如果我们只关心关系的有无，而**不关心关系有多强**，那么就可以用**无权图**表示二者的关系。

对于一个关系，如果我们既**关心关系的有无**，也关心**关系的强度**，比如描述地图上**两个城市的关系**，需要用到**距离**，那么就用**带权图**来表示，**带权图中的每一条边一个数值表示权值**，代表**关系的强度**。

下图就是一个**带权有向图**。

![image-20230102162130607](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230102162130607.png)

# 图的存储

## 邻接矩阵存储

- 邻接矩阵将图用**二维矩阵**存储，是一种比较**直观**的表示方式
- 如果第i个顶点和第j个顶点**有关系**，且**关系权值**为n，则A[i] [j] = n
- 在无向图中，我们只关心关系的有无，所以当**顶点i**和**顶点j**有关系时，A[i] [j]=1 ; 当顶点i和顶点j没有关系时，A[i] [j] = 0 ，如下图所示  
  ![image-20230102165052250](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230102165052250.png)
  无向图的邻接矩阵是一个**对称**矩阵，因为在无向图中，**顶点i**和**顶点j**有关系，则**顶点j**和**顶点i**必有关系
- 有向图的邻接矩阵存储
  ![image-20230105105331809](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105105331809.png)
  邻接矩阵存储的方式优点是**简单直接（直接使用一个二维数组即可）**，并且在获取两个顶点之间的关系的时候也非常高效*直接获取指定位置的**数组**元素。但是这种存储方式的确定啊也比较明显**即 比较浪费空间**

## 邻接表存储

- 针对上面邻接矩阵比较浪费内存空间的问题，诞生了图的另一种存储方法--**邻接表**

- 邻接链表使用一个**链表**来存储某个顶点的**所有后继相邻顶点**。对于图中每个顶点Vi ，把所有邻接于Vi 的顶点Vj 链接成一个**单链表**

  - 无向图的邻接表存储
    ![image-20230105111343599](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105111343599.png)
  - 有向图的邻接表存储
    ![image-20230105111409045](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105111409045.png)

- 邻接表中存储的元素的个数（顶点数）以及图中**边的条数**

  - 无向图中，**邻接表**的元素个数等于**边的条数**的两倍，如下图
    7条边，邻接表存储的元素个数为14 （即**每条边存储了两次**）

    ![image-20230105111343599](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105111343599.png)

  - 有向图中，邻接表元素个数等于边的条数，如图所示的有向图中，边的条数为8，邻接表
    ![image-20230105111409045](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105111409045.png)

# 图的搜索

## 广度优先搜索

- 广度优先搜索：像水面上的波纹一样，一层一层向外扩展，如图
  ![image-20230105112011060](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105112011060.png)

- 具体实现方式，用到了**队列**，过程如下

  1. **初始状态**：将要搜索的源顶点放入队列
     ![image-20230105112201827](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105112201827.png)

  2. 取出**队首节点**，输出0，将0的**后继顶点（全部）（未访问过的）放入队列**
     ![image-20230105112302751](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105112302751.png)

  3. 取出**队首节点**，输出1，将1的后继顶点（所有）（未访问过的）放入队列
     ![image-20230105112423589](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105112423589.png)

     截止到第3步就很清楚了，就是输出**最近的一个结点**的**全部关系节点**

  4. 取出队首节点，输出4，将4的后继顶点（未访问过的）放入队列
     ![image-20230105112601860](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105112601860.png)

  5. 取出队首节点，输出2，将2的后继顶点（未访问过的）放入队列
     ![image-20230105112650410](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105112650410.png)

  6. 取出队首节点，输出3，将3的后继顶点（未访问过的）放入队列，队列为空，结束
     ![image-20230105112735397](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230105112735397.png)

  7. 总结
     先初始化首结点，之后不断**从队列取出**并将这个结点的有关系的**结点** 依次**放入队列**

## 深度优先搜索

- 深度优先，即一条路走到黑。从**源顶点**开始，一直走到**后继节点**，才**回溯**到上一顶点，然后继续**一条路走到黑**
- 和广度优先搜索类似，深度优先搜索的具体实现，用到了另一种线性数据结构---**栈**

1. 初始状态，将要搜索的**源顶点**放入栈中
   ![image-20230106103852981](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230106103852981.png)

2. **取出栈顶元素，输出0**，将0的**后继顶点（未访问过的）放入栈**中
   ![image-20230106103958425](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230106103958425.png)

3. 取出栈顶元素，输出4（因为后进先出），将4的后继顶点（未访问过的）放入栈中
   ![](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230106104122419.png)

4. 取出栈顶元素，输出3，将3的后继顶点（未访问过的）放入栈中
   ![image-20230106104217788](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230106104217788.png)

   ----------

   其实到这部就非常明显了，即 **前面元素的关系元素**，大多都是被一直**压在栈底**的，会一直走走到 **源顶点**的**直系关系**顶点没有了，再往回走

5. 取出栈顶元素，输出2，将2的后继顶点（为访问过的）放入栈中
   ![image-20230106104458532](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230106104458532.png)

6. 取出栈顶元素，输出1，将1的后继顶点（未访问过的）放入栈中，栈为空，结束
   ![image-20230106104538533](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230106104538533.png)