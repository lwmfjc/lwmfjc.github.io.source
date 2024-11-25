---
title: 方法的参数传递机制
description: 方法的参数传递机制
categories:
  - 学习
tags:
  - 复习
  - 复习-基础
date: 2022-09-22 10:24:36
updated: 2022-09-22 10:24:36
---

##  代码

```java
public class Exam4 {
    public static void main(String[] args) {
        int i = 1;
        String str = "hello";
        Integer num = 2;
        int[] arr = {1, 2, 3, 4, 5};
        MyData my = new MyData();

        change(i, str, num, arr, my);
        System.out.println("i = " + i);
        System.out.println("str = " + str);
        System.out.println("num = " + num);
        System.out.println("arr = " + Arrays.toString(arr));
        System.out.println("my.a = " + my.a); 
    }

    public static void change(int j, String s, Integer n, int[] a,
                              MyData m) {
        j+=1;
        s+="world";
        n+=1;
        a[0]+=1;
        m.a+=1;
    }

}
```

结果

```shell
i = 1
str = hello
num = 2
arr = [2, 2, 3, 4, 5]
my.a = 11
```

## 知识点

- 方法的参数传递机制
- String、包装类等对象的不可变性

## 分析

- 对于包装类，如果是使用new，那么一定是开辟新的空间；如果是直接赋值，那么-128-127之间会有缓存池(堆中)

  ```java
          //当使用new的时候，一定在堆中新开辟的空间
          Integer a1= new Integer(12);
          Integer b1= new Integer(12);
          System.out.println(a1 == b1);//false
          Integer a2= -128;
          Integer b2= -128;
          System.out.println(a2 == b2);//true
          Integer a21= -129;
          Integer b21= -129;
          System.out.println(a21 == b21);//false
          Integer a3=  127;
          Integer b3=  127;
          System.out.println(a3 == b3);//true
          Integer a4=  22;
          Integer b4=  22;
          System.out.println(a4 == b4);//true
          Integer a31=  128;
          Integer b31=  128;
          System.out.println(a31 == b31);//false
  ```

- 对于String类 

  ```java
          //先查找常量池中是否有"abc"，如果有直接返回在常量池中的引用,
          //如果没有，则在常量池中创建"abc",然后返回该引用
          String a="abc";
  
          //先查找常量池中是否有"abc"，如果有则在堆内存中创建对象，然后返回堆内存中的地址
          //如果没有，则先在常量池中创建字符串对象，然后再在堆内存中创建对象，最后返回堆内存中的地址
          String ab=new String("abc");
          System.out.println(a==ab);//true
  
          //intern() //判断常量池中是否有ab对象的字符串，如果存在"abc"则返回"abc"在
          //常量池中的引用，如果不存在则在常量池中创建,
          //并返回"abc"在常量池中的引用
          System.out.println(a==ab.intern());//true
  ```

- change方法调用之前，jvm中的结构
  ![image-20220922113056133](images/mypost/image-20220922113056133.png)
  
- 方法栈帧中的数据
  执行change方法后，实参给形参赋值：
  基本数据类型：数据值
  引用数据类型：地址值

  ![image-20220922211437515](images/mypost/image-20220922211437515.png)

  当实参是特殊的类型时：比如String、包装类等对象，不可变，即
  ```s+="world";```
  会导致创建两个对象，如图（ Integer也是）
  ![image-20220922211733044](images/mypost/image-20220922211733044.png)



数组和对象，则是找到堆内存中的地址，直接更改
