---
title:  语法糖
description: syntactic-sugar
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-12 17:36:26
updated: 2022-10-12 17:36:26

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!



## 简介

语法糖（Syntactic Sugar）也称**糖衣语法**，指的是在计算机语言中添加的某种语法，这种语法对语言的功能并没有影响，但是更方便程序员使用，简而言之，让程序更加**简洁**，有更高的**可读性**

## Java中有哪些语法糖

Java**虚拟机并不支持**这些语法糖，这些语法糖在**编译阶段就会被还原成简单的基础语法**结构，这个过程就是解语法糖

- ```javac```命令可以将后缀为```.java```的源文件编译为后缀名为```.class```的**可以运行于Java虚拟机的字节码**。其中，```com.sun.tools.javac.main.JavaCompiler```的源码中，```compile()```中有一个步骤就是调用```desugar()```，这个方法就是负责**解语法糖**的实现的
- Java中的语法糖，包括 **泛型**、**变长参数**、**条件编译**、**自动拆装箱**、**内部类**等

### switch支持String与枚举

switch本身原本只支持基本类型，如int、char  
![lyx-20241126133606021](attachments/img/lyx-20241126133606021.png)

int是比较数值，而char则是比较其ascii码，所以其实对于编译器来说，都是int类型(整型)，比如`byte`。`short`，`char`(ackii 码是整型)以及`int`。
![lyx-20241126133606686](attachments/img/lyx-20241126133606686.png)

![lyx-20241126133607111](attachments/img/lyx-20241126133607111.png)
而对于enum类型，  
![lyx-20241126133607538](attachments/img/lyx-20241126133607538.png)

对于switch中使用String，则：  

```java
public class switchDemoString {
    public static void main(String[] args) {
        String str = "world";
        switch (str) {
        case "hello":
            System.out.println("hello");
            break;
        case "world":
            System.out.println("world");
            break;
        default:
            break;
        }
    }
}
//反编译之后
public class switchDemoString
{
    public switchDemoString()
    {
    }
    public static void main(String args[])
    {
        String str = "world";
        String s;
        switch((s = str).hashCode())
        {
        default:
            break;
        case 99162322:
            if(s.equals("hello"))
                System.out.println("hello");
            break;
        case 113318802:
            if(s.equals("world"))
                System.out.println("world");
            break;
        }
    }
}
```

即switch判断是通过**equals()**和**hashCode()**方法来实现的

equals()检查是必要的，因为**有可能发生碰撞**，所以性能没有**直接使用枚举**进行switch或纯整数常量性能高

### 泛型

编译器处理泛型有两种方式：`Code specialization`和`Code sharing`。C++和 C#是使用`Code specialization`的处理机制，而 Java 使用的是`Code sharing`的机制

> Code sharing 方式**为每个泛型类型创建唯一的字节码**表示，并且将该泛型类型的实例都映射到这个唯一的字节码表示上。将多种泛型类形实例映射到唯一的字节码表示是通过**类型擦除（`type erasue`）**实现的。

- 对于 Java 虚拟机来说，他根本不**认识`Map<String, String> map`**这样的语法。需要在**编译阶段**通过**类型擦除**的方式进行解语法糖
- 类型擦除的主要过程如下： 1.将所有的**泛型参数用其最左边界（最顶级的父类型）**类型替换。 2.移除所有的**类型参数**。

两个例子  

- Map擦除

  ```java
  Map<String, String> map = new HashMap<String, String>();
  map.put("name", "hollis");
  map.put("wechat", "Hollis");
  map.put("blog", "www.hollischuang.com");
  //解语法糖之后
  Map map = new HashMap();
  map.put("name", "hollis");
  map.put("wechat", "Hollis");
  map.put("blog", "www.hollischuang.com");
  ```

- 其他擦除  

  ```java
  public static <A extends Comparable<A>> A max(Collection<A> xs) {
      Iterator<A> xi = xs.iterator();
      A w = xi.next();
      while (xi.hasNext()) {
          A x = xi.next();
          if (w.compareTo(x) < 0)
              w = x;
      }
      return w;
  }
  //擦除后变成
   public static Comparable max(Collection xs){
      Iterator xi = xs.iterator();
      Comparable w = (Comparable)xi.next();
      while(xi.hasNext())
      {
          Comparable x = (Comparable)xi.next();
          if(w.compareTo(x) < 0)
              w = x;
      }
      return w;
  }
  ```

- 小结

  - 虚拟机中并不存在泛型，**泛型类没有自己独有的Class类**对象，即不存在List<String>.class 或是 List<Integer>.class ，而只有List.class
  - 虚拟机中，只有普通类和普通方法，所有泛型类的**类型参数**，在**编译时都会被擦除**

### 自动装箱与拆箱

- 装箱过程，通过调用**包装器的valueOf**方法实现的，而拆箱过程，则是通过调用**包装器的xxxValue**方法实现的

- 自动装箱

  ```java
   public static void main(String[] args) {
      int i = 10;
      Integer n = i;
  }
  //反编译后的代码
  public static void main(String args[])
  {
      int i = 10;
      Integer n = Integer.valueOf(i);
  }
  ```

- 自动拆箱  

  ```java
  public static void main(String[] args) {
  
      Integer i = 10;
      int n = i;
  }
  //反编译后的代码
  public static void main(String args[])
  {
      Integer i = Integer.valueOf(10);
      int n = i.intValue(); //注意，是intValue，不是initValue
  }
  ```

  

### 可变长参数

variable arguments，是在Java 1.5中引入的一个特性，允许一个方法把任意数量的值作为参数，代码：  

```java
public static void main(String[] args)
    {
        print("Holis", "公众号:Hollis", "博客：www.hollischuang.com", "QQ：907607222");
    }

public static void print(String... strs)
{
    for (int i = 0; i < strs.length; i++)
    {
        System.out.println(strs[i]);
    }
}
//反编译后代码
 public static void main(String args[])
{
    print(new String[] {
        "Holis", "\u516C\u4F17\u53F7:Hollis", "\u535A\u5BA2\uFF1Awww.hollischuang.com", "QQ\uFF1A907607222"
    });
}

public static transient void print(String strs[])
{
    for(int i = 0; i < strs.length; i++)
        System.out.println(strs[i]);

}
```

如上，可变参数在被使用的时候，会**创建一个数组**，数组的长度，就是调用该方法的传递的实参的个数，然后再**把参数值全部放到这个数组**当中，最后把这个数组作为参数传递到被调用的方法中

### 枚举

关键字`enum`可以**将一组具名的值**的**有限集合**创建为一种新的类型，而这些具名的值可以作为常规的程序组件使用，这是一种非常有用的功能

写一个enum类进行测试

```java 
public enum T {
    SPRING,SUMMER;
}
//反编译之后
// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   T.java

package com.ly.review.base;


public final class T extends Enum
{

    /**
    下面这个和博客不太一样,博客里面是这样的
//    ENUM$VALUES是博客编译后的数组名
    public static T[] values()
    {
        T at[];
        int i;
        T at1[];
        System.arraycopy(at = ENUM$VALUES, 0, at1 = new T[i = at.length], 0, i);
        return at1;
    }
    
    */
    public static T[] values()
    {
        return (T[])$VALUES.clone();
    }
    

    public static T valueOf(String s)
    {
        return (T)Enum.valueOf(com/ly/review/base/T, s);
    }

    private T(String s, int i)
    {
        super(s, i);
    }

    public static final T Spring;
    public static final T SUMMER;
    private static final T $VALUES[];

    static 
    {
        Spring = new T("Spring", 0);
        SUMMER = new T("SUMMER", 1);
        $VALUES = (new T[] {
            Spring, SUMMER
        });
    }
}

```

重要代码：  

1. ```public final class T extends Enum```
   说明**该类不可继承**

2. ```java
       public static final T Spring;
       public static final T SUMMER;
   ```

   说明枚举类型**不可修改**

### 内部类

内部类又称为嵌套类，可以把内部类理解成外部类的一个普通成员
**内部类之所以也是语法糖，是因为它仅仅是一个编译时的概念，`outer.java`里面定义了一个内部类`inner`，一旦编译成功，就会生成两个完全不同的`.class`文件了，分别是`outer.class`和`outer$inner.class`。所以内部类的名字完全可以和它的外部类名字相同。**

代码如下：  

```java
public class OutterClass {
    private String userName;

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public static void main(String[] args) {

    }

    class InnerClass{
        private String name;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}
```

编译之后，会生成两个class文件OutterClass.class和OutterClass$InnerClass.class。所以内部类是可以跟外部类完全一样的名字的
如果要对OutterClass.class进行反编译，那么他会把OutterClass$InnerClass.class也一起进行反编译

```java
public class OutterClass
{
    class InnerClass
    {
        public String getName()
        {
            return name;
        }
        public void setName(String name)
        {
            this.name = name;
        }
        private String name;
        final OutterClass this$0;

        InnerClass()
        {
            this.this$0 = OutterClass.this;
            super();
        }
    }

    public OutterClass()
    {
    }
    public String getUserName()
    {
        return userName;
    }
    public void setUserName(String userName){
        this.userName = userName;
    }
    public static void main(String args1[])
    {
    }
    private String userName;
}
```

### 条件编译

—般情况下，程序中的每一行代码都要参加编译。但有时候出于**对程序代码优化的考虑**，希望**只对其中一部分内容进行编译**，此时就需要在程**序中加上条件**，让编译器只对满足条件的代码进行编译，将不满足条件的代码舍弃，这就是条件编译。

```java
public class ConditionalCompilation {
    public static void main(String[] args) {
        final boolean DEBUG = true;
        if(DEBUG) {
            System.out.println("Hello, DEBUG!");
        }

        final boolean ONLINE = false;

        if(ONLINE){
            System.out.println("Hello, ONLINE!");
        }
    }
}
//反编译之后如下
public class ConditionalCompilation
{

    public ConditionalCompilation()
    {
    }

    public static void main(String args[])
    {
        boolean DEBUG = true;
        System.out.println("Hello, DEBUG!");
        boolean ONLINE = false;
    }
}
```

**Java 语法的条件编译，是通过判断条件为常量的 if 语句实现的。其原理也是 Java 语言的语法糖。根据 if 判断条件的真假，编译器直接把分支为 false 的代码块消除。通过该方式实现的条件编译，必须在方法体内实现，而无法在正整个 Java 类的结构或者类的属性上进行条件编译**

### 断言

Java 在执行的时候**默认是不启动断言**检查的（这个时候，所有的断言语句都将忽略！），如果要**开启断言检查**，则需要用开关`-enableassertions`或`-ea`来开启

代码如下：  

```java
public class AssertTest {
    public static void main(String args[]) {
        int a = 1;
        int b = 1;
        assert a == b;
        System.out.println("公众号：Hollis");
        assert a != b : "Hollis";
        System.out.println("博客：www.hollischuang.com");
    }
}
//反编译之后代码如下
public class AssertTest {
   public AssertTest()
    {
    }
    public static void main(String args[])
{
    int a = 1;
    int b = 1;
    if(!$assertionsDisabled && a != b)
        throw new AssertionError();
    System.out.println("\u516C\u4F17\u53F7\uFF1AHollis");
    if(!$assertionsDisabled && a == b)
    {
        throw new AssertionError("Hollis");
    } else
    {
        System.out.println("\u535A\u5BA2\uFF1Awww.hollischuang.com");
        return;
    }
}

static final boolean $assertionsDisabled = !com/hollis/suguar/AssertTest.desiredAssertionStatus();

}
```

- **断言的底层是if**语言，如果断言为true，则什么都不做；如果**断言为false**，则**程序抛出AssertError**来打断程序执行
- -enableassertions会设置$assertionsDisabled字段的值

### 数值字面量

java7中，字面量允许在**数字之间插入任意多个下划线**，不会对字面值产生影响，可以方便阅读

源代码：  

```java
public class Test {
    public static void main(String... args) {
        int i = 10_000;
        System.out.println(i);
    }
}
//反编译后
public class Test
{
  public static void main(String[] args)
  {
    int i = 10000;
    System.out.println(i);
  }
}
```



### for-each

源代码：  

```java
public static void main(String... args) {
    String[] strs = {"Hollis", "公众号：Hollis", "博客：www.hollischuang.com"};
    for (String s : strs) {
        System.out.println(s);
    }
    List<String> strList = ImmutableList.of("Hollis", "公众号：Hollis", "博客：www.hollischuang.com");
    for (String s : strList) {
        System.out.println(s);
    }
}
//反编译之后
public static transient void main(String args[])
{
    String strs[] = {
        "Hollis", "\u516C\u4F17\u53F7\uFF1AHollis", "\u535A\u5BA2\uFF1Awww.hollischuang.com"
    };
    String args1[] = strs;
    int i = args1.length;
    for(int j = 0; j < i; j++)
    {
        String s = args1[j];
        System.out.println(s);
    }

    List strList = ImmutableList.of("Hollis", "\u516C\u4F17\u53F7\uFF1AHollis", "\u535A\u5BA2\uFF1Awww.hollischuang.com");
    String s;
    for(Iterator iterator = strList.iterator(); iterator.hasNext(); System.out.println(s))
        s = (String)iterator.next();

}
```

**会改成普通的for语句循环**，或者**使用迭代器**

### try-with-resource

关闭资源的方式，就是再finally块里释放，即调用close方法

```java
//正常使用
public static void main(String[] args) {
    BufferedReader br = null;
    try {
        String line;
        br = new BufferedReader(new FileReader("d:\\hollischuang.xml"));
        while ((line = br.readLine()) != null) {
            System.out.println(line);
        }
    } catch (IOException e) {
        // handle exception
    } finally {
        try {
            if (br != null) {
                br.close();
            }
        } catch (IOException ex) {
            // handle exception
        }
    }
}
```

JDK7之后提供的关闭资源的方式：  

```java
public static void main(String... args) {
    try (BufferedReader br = new BufferedReader(new FileReader("d:\\ hollischuang.xml"))) {
        String line;
        while ((line = br.readLine()) != null) {
            System.out.println(line);
        }
    } catch (IOException e) {
        // handle exception
    }
}
```

编译后：  

```java
public static transient void main(String args[])
    {
        BufferedReader br;
        Throwable throwable;
        br = new BufferedReader(new FileReader("d:\\ hollischuang.xml"));
        throwable = null;
        String line;
        try
        {
            while((line = br.readLine()) != null)
                System.out.println(line);
        }
        catch(Throwable throwable2)
        {
            throwable = throwable2;
            throw throwable2;
        }
        if(br != null)
            if(throwable != null)
                try
                {
                    br.close();
                }
                catch(Throwable throwable1)
                {
                    throwable.addSuppressed(throwable1);
                }
            else
                br.close();
            break MISSING_BLOCK_LABEL_113;
            Exception exception;
            exception;
            if(br != null)
                if(throwable != null)
                    try
                    {
                        br.close();
                    }
                    catch(Throwable throwable3)
                      {
                        throwable.addSuppressed(throwable3);
                    }
                else
                    br.close();
        throw exception;
        IOException ioexception;
        ioexception;
    }
}
```

也就是我们没有做关闭的操作，编译器都帮我们做了

### Lambda表达

- 使用lambda表达式便利list

  ```java
  public static void main(String... args) {
      List<String> strList = ImmutableList.of("Hollis", "公众号：Hollis", "博客：www.hollischuang.com");
  
      strList.forEach( s -> { System.out.println(s); } );
  }
  ```

  反编译之后

  ```java
  public static /* varargs */ void main(String ... args) {
      ImmutableList strList = ImmutableList.of((Object)"Hollis", (Object)"\u516c\u4f17\u53f7\uff1aHollis", (Object)"\u535a\u5ba2\uff1awww.hollischuang.com");
      strList.forEach((Consumer<String>)LambdaMetafactory.metafactory(null, null, null, (Ljava/lang/Object;)V, lambda$main$0(java.lang.String ), (Ljava/lang/String;)V)());
  }
  
  private static /* synthetic */ void lambda$main$0(String s) {
      System.out.println(s);
  }
  ```

- lambda表达式的实现其实是**依赖了一些底层的api**，在编译阶段，会把lambda表达式进行解糖，转换成**调用内部api**的方式

## 可能遇到的坑

### 泛型

- 泛型遇到重载

  ```java
  public class GenericTypes {
  
      public static void method(List<String> list) {
          System.out.println("invoke method(List<String> list)");
      }
  
      public static void method(List<Integer> list) {
          System.out.println("invoke method(List<Integer> list)");
      }
  } 
  ```

  这种方法是编译不过去的，因为参数List<Integer> 和List<String>编译之后都被擦出了，变成了一样的原生类型List，擦除动作导致这两个方法的**特征签名变得一模一样**。

- 泛型的类型参数不能用在 Java 异常处理的 catch 语句中。因为异常处理是由 JVM 在运行时刻来进行的。由于类型信息被擦除，JVM 是无法区分两个异常类型`MyException<String>`和`MyException<Integer>`的

- 泛型类的所有静态变量是共享的

  ```java
  public class StaticTest{
      public static void main(String[] args){
          GT<Integer> gti = new GT<Integer>();
          gti.var=1;
          GT<String> gts = new GT<String>();
          gts.var=2;
          System.out.println(gti.var);
      }
  }
  class GT<T>{
      public static int var=0;
      public void nothing(T x){}
  }
  ```

  以上代码输出结果为：2！
  
  由于经过类型擦除，所有的**泛型类实例都关联到同一份字节码**上，**泛型类的所有静态变量**是共享的。

### 自动装箱与拆箱

对于自动装箱，整形对象通过使用相同的缓存和重用，适用于整数值区间 [ -128，+127 ] 

```java
public static void main(String[] args) {
    Integer a = 1000;
    Integer b = 1000;
    Integer c = 100;
    Integer d = 100;
    System.out.println("a == b is " + (a == b));
    System.out.println(("c == d is " + (c == d)));
}
//结果
a == b is false
c == d is true
```

### 增强for循环

遍历时不要使用list的remove方法：

```java
for (Student stu : students) {
    if (stu.getId() == 2)
        students.remove(stu);
}
//会报ConcurrentModificationException异常，Iterator在工作的时候不允许被迭代的对象被改变，但可以使用Iterator本身的remove()来删除对象，会在删除当前对象的同时，维护索引的一致性
```



