---
title: 自增变量
description: 自增变量
categories:
  - 学习
tags:
  - 复习
  - 复习-基础
date: 2022-09-21 10:04:34
updated: 2022-09-21 10:04:34
---

## 题目

```java
		int i=1;
		i=i++;
		int j=i++;
		int k = i+ ++i * i++;
		System.out.println("i="+i);
		System.out.println("j="+j);
		System.out.println("k="+k);
```



## 讲解

### 对于操作数栈和局部变量表的理解

- 对于下面的代码

  ```java
  		int i=10;
  		int j=9;
  		j=i;
  ```

  反编译之后，查看字节码

  ```java
  0 bipush 10
  2 istore_1
  3 bipush 9
  5 istore_2
  6 iload_1
  7 istore_2
  8 return
  ```

  如下图，这三行代码，是依次把10，9先放到局部变量表的1，2位置。  
  之后呢，再把局部变量表中1位置的值，放入操作数栈中  
  最后，将操作数栈弹出一个数(10)，将数值赋给局部变量表中的位置2  

  ![lyx-20241126133413265](attachments/img/lyx-20241126133413265.png)
  ![lyx-20241126133413711](attachments/img/lyx-20241126133413711.png)
  如上图，当方法为静态方法时，局部变量表0位置存储的是实参第1个数
  
  (当方法为非静态方法时，局部变量表0位置存储的是this引用)
  
- 对于下面这段代码

  ```java
  		int i=10;
  		int j=20;
  		i=i++;
  		j=++j;
  		System.out.println(i);
  		System.out.println(j);
  ```

  编译后的字节码  

  ```java
   0 bipush 10
   2 istore_1
   3 bipush 20
   5 istore_2
   6 iload_1
   7 iinc 1 by 1
  10 istore_1
  11 iinc 2 by 1
  14 iload_2
  15 istore_2
  16 getstatic #5 <java/lang/System.out : Ljava/io/PrintStream;>
  19 iload_1
  20 invokevirtual #6 <java/io/PrintStream.println : (I)V>
  23 getstatic #5 <java/lang/System.out : Ljava/io/PrintStream;>
  26 iload_2
  27 invokevirtual #6 <java/io/PrintStream.println : (I)V>
  30 return
  ```

  如上对于j = ++j ;是  

  ```java
  11 iinc 2 by 1
  14 iload_2
  15 istore_2
  ```

  先对局部变量表2中的 值 加1，然后将结果 放入操作数栈中，之后再将操作数栈弹出一个数并赋值给 位置2

### 对于题目的解释

```java
		int i=1;
		i=i++;
		int j=i++;
		int k = i+ ++i * i++;
		System.out.println("i="+i);
		System.out.println("j="+j);
		System.out.println("k="+k);
```

编译后的字节码

```java
 0 iconst_1
 1 istore_1
 2 iload_1
 3 iinc 1 by 1
 6 istore_1
 7 iload_1
 8 iinc 1 by 1
11 istore_2
12 iload_1
13 iinc 1 by 1
16 iload_1
17 iload_1
18 iinc 1 by 1
21 imul
22 iadd
23 istore_3
```

对于 int j = i++ 

```java
 7 iload_1
 8 iinc 1 by 1
11 istore_2
```

先将i的值放进栈中，然后将局部变量表中的i + 1，之后将栈中的值赋值给j
![lyx-20241126133414141](attachments/img/lyx-20241126133414141.png)

到这步骤的时候，i = 2 ，j = 1 

最后一步   int k = i+ ++i * i++ 

```java
12 iload_1
13 iinc 1 by 1
16 iload_1
17 iload_1
18 iinc 1 by 1
21 imul
22 iadd
23 istore_3
```

如字节码所示，先将i load进操作数栈中(2)，然后将局部变量表中的i 自增 (3)，之后将自增后的结果(3)放入操作数栈中，第二次将局部变量表中的i放入操作数栈中。然后此时操作数栈中存在 3 3 2 (由栈顶到栈底) ，依次进行乘法加法 （3*3+2） =11 ，放入局部变量表3 中。
所以结果为 2， 1，11

### 小结

![](attachments/img/lyx-20241126133414555.png)

​    