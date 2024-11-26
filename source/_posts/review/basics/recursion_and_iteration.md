---
title: 递归与迭代
description: 递归与迭代
categories:
  - 学习
tags:
  - 复习
  - 复习-基础
date: 2022-09-22 21:20:07
updated: 2022-09-22 21:20:07
---

## 编程题

有n步台阶，一次只能上1步或2步，共有多少种走法  

### 分析

- 分析  
  n = 1，1步    f(1) = 1  
  n = 2,   两个1步,2步    f(2) = 2  
  n = 3,  分两种情况： 最后1步是2级台阶/最后1步是1级台阶，
  即 f(3) = f(1)+f(2)
  n = 4, 分两种情况： 最后1步是2级台阶/最后1步是1级台阶，
  即f(4) = f(2)+f(3)

  也就是说，不管有几(n)个台阶，总要分成两种情况：最后1步是2级台阶/最后1步是1级台阶，即 f(n)= f(n-2) + f(n-1) 
  
### 递归

```java
      public static int f(int n){
            if(n==1 || n==2){
                return n;
            }
            return f(n-2)+f(n-1);
      }
  
        public static void main(String[] args) {
            System.out.println(f(1)); //1
            System.out.println(f(2)); //2
            System.out.println(f(3)); //3
            System.out.println(f(4)); //5
            System.out.println(f(5)); //8
        }
```

- debug调试
  方法栈 
  f(4)---->分解成f(2)+f(3)
  f(2)---返回-
  f(3)---f(2)返回---f(1)返回 【f(3)分解成f(2)和f(1)】
  方法栈的个数：
  ![lyx-20241126133412365](images/mypost/lyx-20241126133412365.png)

### 使用循环

```java
    public static int loop(int n){

        if (n < 1) {
            throw new IllegalArgumentException(n + "不能小于1");
        }
        if (n == 1 || n == 2) {
            return n;
        }
        int one=2;//最后只走1步，会有2种走法
        int two=1;//最后走2步，会有1种走法
        int sum=0;
        for(int i=3;i<=n;i++){
            //最后跨两级台阶+最后跨一级台阶的走法
            sum=two+one;
            two=one;
            one=sum;
        }
        return sum;
    }
```



![lyx-20241126133412803](images/mypost/lyx-20241126133412803.png)

### 小结

- 方法调用自身称为递归，利用变量的原值推出新值称为迭代(while循环)
- 递归  
  优点：大问题转换为小问题，代码精简  
  缺点：浪费空间（栈空间），可能会照成栈的溢出
- 迭代  
  优点：效率高，时间只受循环次数限制，不受出栈入栈时间  
  缺点：不如递归精简，可读性稍差