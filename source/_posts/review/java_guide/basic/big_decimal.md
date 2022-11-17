---
title: big_decimal
description: big_decimal
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 14:56:26
updated: 2022-10-10 14:56:26
---

> 转载自https://github.com/Snailclimb/JavaGuide

### 精度的丢失

```java
float a = 2.0f - 1.9f;
float b = 1.8f - 1.7f;
System.out.println(a);// 0.100000024
System.out.println(b);// 0.099999905
System.out.println(a == b);// false
```

> 为什么会有精度丢失的风险 
>
> 这个和计算机保存浮点数的机制有很大关系。我们知道计算机是二进制的，而且计算机在表示一个数字时，宽度是有限的，无限循环的小数存储在计算机时，只能被截断，所以就会导致小数精度发生损失的情况。这也就是解释了为什么浮点数没有办法用二进制精确表示

使用BigDecimal来定义浮点数的值，然后再进行浮点数的运算操作即可

### BigDecimal常见方法

- 我们在使用 `BigDecimal` 时，为了防止精度丢失，推荐使用它的`BigDecimal(String val)`构造方法或者 `BigDecimal.valueOf(double val)` 静态方法来创建对象

- 加减乘除

  ```java
  BigDecimal a = new BigDecimal("1.0");
  BigDecimal b = new BigDecimal("0.9");
  System.out.println(a.add(b));// 1.9
  System.out.println(a.subtract(b));// 0.1
  System.out.println(a.multiply(b));// 0.90
  System.out.println(a.divide(b));// 无法除尽，抛出 ArithmeticException 异常
  System.out.println(a.divide(b, 2, RoundingMode.HALF_UP));// 1.11
  ```

  使用divide方法的时候，尽量使用3个参数版本（roundingMode.oldMode)

- 保留规则

  ```java
  public enum RoundingMode {
     // 2.5 -> 3 , 1.6 -> 2
     // -1.6 -> -2 , -2.5 -> -3
  			 UP(BigDecimal.ROUND_UP),
     // 2.5 -> 2 , 1.6 -> 1
     // -1.6 -> -1 , -2.5 -> -2
  			 DOWN(BigDecimal.ROUND_DOWN),
  			 // 2.5 -> 3 , 1.6 -> 2
     // -1.6 -> -1 , -2.5 -> -2
  			 CEILING(BigDecimal.ROUND_CEILING),
  			 // 2.5 -> 2 , 1.6 -> 1
     // -1.6 -> -2 , -2.5 -> -3
  			 FLOOR(BigDecimal.ROUND_FLOOR),
     	// 2.5 -> 3 , 1.6 -> 2
     // -1.6 -> -2 , -2.5 -> -3
  			 HALF_UP(BigDecimal.ROUND_HALF_UP),
     //......
  }
  ```

- 大小比较  
  使用compareTo 

  ```java
  BigDecimal a = new BigDecimal("1.0");
  BigDecimal b = new BigDecimal("0.9");
  System.out.println(a.compareTo(b));// 1
  ```

- 保留几位小数

  ```java
  BigDecimal m = new BigDecimal("1.255433");
  BigDecimal n = m.setScale(3,RoundingMode.HALF_DOWN);
  System.out.println(n);// 1.255
  ```

- 使用compareTo替换equals方法，equals不止会比较直，还会比较精度
  ![](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221010170727552.png)

- BigDecimal工具类分享
  (用来操作double算术)

  ```java
  import java.math.BigDecimal;
  import java.math.RoundingMode;
  
  /**
   * 简化BigDecimal计算的小工具类
   */
  public class BigDecimalUtil {
  
      /**
       * 默认除法运算精度
       */
      private static final int DEF_DIV_SCALE = 10;
  
      private BigDecimalUtil() {
      }
  
      /**
       * 提供精确的加法运算。
       *
       * @param v1 被加数
       * @param v2 加数
       * @return 两个参数的和
       */
      public static double add(double v1, double v2) {
          BigDecimal b1 = BigDecimal.valueOf(v1);
          BigDecimal b2 = BigDecimal.valueOf(v2);
          return b1.add(b2).doubleValue();
      }
  
      /**
       * 提供精确的减法运算。
       *
       * @param v1 被减数
       * @param v2 减数
       * @return 两个参数的差
       */
      public static double subtract(double v1, double v2) {
          BigDecimal b1 = BigDecimal.valueOf(v1);
          BigDecimal b2 = BigDecimal.valueOf(v2);
          return b1.subtract(b2).doubleValue();
      }
  
      /**
       * 提供精确的乘法运算。
       *
       * @param v1 被乘数
       * @param v2 乘数
       * @return 两个参数的积
       */
      public static double multiply(double v1, double v2) {
          BigDecimal b1 = BigDecimal.valueOf(v1);
          BigDecimal b2 = BigDecimal.valueOf(v2);
          return b1.multiply(b2).doubleValue();
      }
  
      /**
       * 提供（相对）精确的除法运算，当发生除不尽的情况时，精确到
       * 小数点以后10位，以后的数字四舍五入。
       *
       * @param v1 被除数
       * @param v2 除数
       * @return 两个参数的商
       */
      public static double divide(double v1, double v2) {
          return divide(v1, v2, DEF_DIV_SCALE);
      }
  
      /**
       * 提供（相对）精确的除法运算。当发生除不尽的情况时，由scale参数指
       * 定精度，以后的数字四舍五入。
       *
       * @param v1    被除数
       * @param v2    除数
       * @param scale 表示表示需要精确到小数点以后几位。
       * @return 两个参数的商
       */
      public static double divide(double v1, double v2, int scale) {
          if (scale < 0) {
              throw new IllegalArgumentException(
                      "The scale must be a positive integer or zero");
          }
          BigDecimal b1 = BigDecimal.valueOf(v1);
          BigDecimal b2 = BigDecimal.valueOf(v2);
          return b1.divide(b2, scale, RoundingMode.HALF_UP).doubleValue();
      }
  
      /**
       * 提供精确的小数位四舍五入处理。
       *
       * @param v     需要四舍五入的数字
       * @param scale 小数点后保留几位
       * @return 四舍五入后的结果
       */
      public static double round(double v, int scale) {
          if (scale < 0) {
              throw new IllegalArgumentException(
                      "The scale must be a positive integer or zero");
          }
          BigDecimal b = BigDecimal.valueOf(v);
          BigDecimal one = new BigDecimal("1");
          return b.divide(one, scale, RoundingMode.HALF_UP).doubleValue();
      }
  
      /**
       * 提供精确的类型转换(Float)
       *
       * @param v 需要被转换的数字
       * @return 返回转换结果
       */
      public static float convertToFloat(double v) {
          BigDecimal b = new BigDecimal(v);
          return b.floatValue();
      }
  
      /**
       * 提供精确的类型转换(Int)不进行四舍五入
       *
       * @param v 需要被转换的数字
       * @return 返回转换结果
       */
      public static int convertsToInt(double v) {
          BigDecimal b = new BigDecimal(v);
          return b.intValue();
      }
  
      /**
       * 提供精确的类型转换(Long)
       *
       * @param v 需要被转换的数字
       * @return 返回转换结果
       */
      public static long convertsToLong(double v) {
          BigDecimal b = new BigDecimal(v);
          return b.longValue();
      }
  
      /**
       * 返回两个数中大的一个值
       *
       * @param v1 需要被对比的第一个数
       * @param v2 需要被对比的第二个数
       * @return 返回两个数中大的一个值
       */
      public static double returnMax(double v1, double v2) {
          BigDecimal b1 = new BigDecimal(v1);
          BigDecimal b2 = new BigDecimal(v2);
          return b1.max(b2).doubleValue();
      }
  
      /**
       * 返回两个数中小的一个值
       *
       * @param v1 需要被对比的第一个数
       * @param v2 需要被对比的第二个数
       * @return 返回两个数中小的一个值
       */
      public static double returnMin(double v1, double v2) {
          BigDecimal b1 = new BigDecimal(v1);
          BigDecimal b2 = new BigDecimal(v2);
          return b1.min(b2).doubleValue();
      }
  
      /**
       * 精确对比两个数字
       *
       * @param v1 需要被对比的第一个数
       * @param v2 需要被对比的第二个数
       * @return 如果两个数一样则返回0，如果第一个数比第二个数大则返回1，反之返回-1
       */
      public static int compareTo(double v1, double v2) {
          BigDecimal b1 = BigDecimal.valueOf(v1);
          BigDecimal b2 = BigDecimal.valueOf(v2);
          return b1.compareTo(b2);
      }
  
  }
  ```

  