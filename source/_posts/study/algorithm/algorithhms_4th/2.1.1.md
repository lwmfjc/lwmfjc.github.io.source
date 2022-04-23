---
title: "算法红皮书 2.1.1"
description: '初级排序算法'
categories:
  - 学习
tags:
  - 算法红皮书(第四版)
date: 2022-04-13 22:43:21
updated: 2022-04-22 23:43:22
mathjax: true

---

# 排序

排序就是将一组对象按照某种逻辑顺序重新排序的过程  

- 对排序算法的分析有助于理解本书中比较算法性能的方法
- 类似技术能解决其他类型问题
- 排序算法常常是我们解决其他问题的第一步

## 初级排序算法

- 熟悉术语及技巧
- 某些情况下初级算法更有效
- 有助于改进复杂算法的效率

### 游戏规则

- 主要关注重新排序**数组元素**的算法，每个元素都会有一个**主键**

- 排序后索引较大的主键大于索引较小的主键

- 一般情况下排序算法通过两个方法操作数据，less()进行比较，exch()进行交换

- 排序算法类的模板

  ```java
  public class Example
  {
  	public static void sort(Comparable[] a)
  	{
  		/* 请见算法2.1、算法2.2、算法2.3、算法2.4、算法2.5或算法2.7*/
  	}
  	private static Boolean less(Comparable v, Comparable w)
  	{
  		return v.compareTo(w) < 0;
  	}
  	private static void exch(Comparable[] a, int i, int j)
  	{
  		Comparable t = a[i];
  		a[i] = a[j];
  		a[j] = t;
  	}
  	private static void show(Comparable[] a)
  	{
  		// 在单行中打印数组
  		for (int i = 0; i < a.length; i++)
  		StdOut.print(a[i] + " ");
  		StdOut.println();
  	}
  	public static Boolean isSorted(Comparable[] a)
  	{
  		// 测试数组元素是否有序
  		for (int i = 1; i < a.length; i++)
  		if (less(a[i], a[i-1])) return false;
  		return true;
  	}
  	public static void main(String[]
  	args)
  	{
  		// 从标准输入读取字符串，将它们排序并输出
  		String[] a = In.readStrings();
  		sort(a);
  		assert isSorted(a);
  		show(a);
  	}
  }
  ```

  - 使用

    ```shell
    % more tiny.txt
    S O R T E X A M P L E
    % java Example < tiny.txt
    A E E L M O P R S T X
    % more words3.txt
    bed bug dad yes zoo ... all bad yet
    % java Example < words.txt
    all bad bed bug dad ... yes yet zoo
    
    ```

- 使用assert验证

- 排序成本模型：在研究排序算法时，我们需要计算比较和交换的数量。对于不交换元素的算法，我们会比较访问数组的次数

- 额外内存开销和运行时间同等重要，排序算法分为

  - 除了函数调用需要的栈和固定数目的实例变量之外，无需额外内存的**原地排序算法**
  - 需要额外内存空间来存储另一份数组副本的**其他排序算法**

- 数据类型

  - 排序模板适用于任何实现了Comparable接口的数据类型

  - 对于自己的数据类型，实现Comparable接口即可

    ```java
    public class Date implements Comparable<Date>
    {
    	private final int day;
    	private final int month;
    	private final int year;
    	public Date(int d, int m, int y)
    	{
    		day = d;
    		month = m;
    		year = y;
    	}
    	public int day() {
    		return day;
    	}
    	public int month() {
    		return month;
    	}
    	public int year() {
    		return year;
    	}
    	public int compareTo(Date that)
    	{
    		if (this.year > that.year ) return +1;
    		if (this.year < that.year ) return -1;
    		if (this.month > that.month) return +1;
    		if (this.month < that.month) return -1;
    		if (this.day > that.day ) return +1;
    		if (this.day < that.day ) return -1;
    		return 0;
    	}
    	public String toString()
    	{
    		return month + "/" + day + "/" + year;
    	}
    }
    ```

    - compareTo()必须实现**全序关系**
      - 自反性，反对称性及传递性

- 经典算法，包括选择排序、插入排序、希尔排序、归并排序、快速排序和堆排序

- 



