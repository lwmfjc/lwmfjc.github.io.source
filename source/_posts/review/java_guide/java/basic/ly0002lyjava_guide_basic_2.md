---
title:  javaGuide基础2
description: javaGuide基础2
categories:
  - 学习
tags:
  - '复习'
  - '复习-javaGuide'
  - '复习-javaGuide-基础'
date: 2022-09-29 10:16:13
updated: 2022-09-29 10:16:13

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 面向对象基础

- 区别 

  - 面向**过程**把解决问题的**过程拆成一个个方法**，通过一个个方法的执行解决问题。
  - 面向对象会**先抽象出对象**，然后**用对象执行方法**的方式解决问题。
  - 面向对象编程 **易维护**、**易复用**、**易扩展**

- 对象实例与对象引用的不同  
  new 运算符，new 创建对象实例（**对象实例在堆**内存中），对象引用指向对象实例（**对象引用存放在栈**内存中）。

  一个对象引用可以指向 0 个或 1 个对象（一根绳子可以不系气球，也可以系一个气球）;一个对象可以有 n 个引用指向它（可以用 n 条绳子系住一个气球）。

- 对象的相等一般比较的是**内存中存放的内容**是否相等；引用相等一般比较的是他们指向的**内存地址是否相等**

- 如果一个类没有声明构造方法，该程序能正确执行吗?
如果我们自己添加了类的构造方法（无论是否有参），Java 就不会再添加默认的无参数的构造方法了
  
  - 构造方法特点：名字与类名相同；没有返回值但不能用void声明构造函数；生成类的对象时自动执行
  - 构造方法**不能重写**(override)，但**能重载** (overload)  
  
- 面向对象三大特征

  - 封装  
    把一个对象的状态信息(属性)**隐藏在对象内部**，**不允许直接访问**，但提供可以被外界访问的方法来操作属性

    ```java
    public class Student {
        private int id;//id属性私有化
        private String name;//name属性私有化
    
        //获取id的方法
        public int getId() {
            return id;
        }
    
        //设置id的方法
        public void setId(int id) {
            this.id = id;
        }
    
        //获取name的方法
        public String getName() {
            return name;
        }
    
        //设置name的方法
        public void setName(String name) {
            this.name = name;
        }
    }
    ```

  - 继承  
    不通类型的对象，相互之间有一定数量的共同点，同时每个对象定义了额外的特性使得他们与众不同。继承是**使用已存在的类的定义作为基础**建立新类的技术

    - **父类中的私有属性**和方法**子类无法访问**，只是拥有
    - 子类可以拥有自己的属性、方法，即对父类进行**拓展**
    - 子类可以用**自己的方式实现父类的方法（重写）**

  - 多态

    - **对象类型**和**引用类型**之间具有继承(类)/实现(接口)的关系
    - **引用类型变量**发出的**方法具体调用哪个类的方法**，只有**程序运行期间才能确定**
    - 多态不能调用“**只在子类存在而父类不存在**”的方法
    - 如果子类重写了父类的方法，**真正执行的是子类覆盖的方法**，如果子类没有覆盖父类的方法，执行的是父类的方法

- 接口和抽象类有什么共同点和区别

  - 共同：都不能被实例化；**都可以包含抽象方法**；都**可以有默认实现**的方法。
  - 区别
    - 接口主要用于对**类的行为**进行约束；抽象类主要用于**代码复用**（强调所属）
    - 类只能继承**一个类**，但能实现**多个接口**
    - 接口中的成员只能是```public static final```**不能被修改且具有初始值**；而抽象类中的成员变量默认为default,也可以被**public**,**protected**,**private**修饰,可以不用赋初值
- 关于访问权限控制
	- public：Java 访问限制最宽的修饰符，一般称之为“公共的”。被其修饰的类、属性以及方法不仅可以**跨类**访问，而且可以**跨包**访问。
	- protected：介于 **public 和 private 之间**的一种访问修饰符，一般称之为“保护访问权限”。被其修饰的属性以及方法只能**被类本身及其子类(即使子类在不同的包中)，以及同包的其他类**访问。外包的非子类不可以访问。
	- default：“默认访问权限“或“包访问权限”，即**不加任何访问修饰符**。只允许在**同包**访问，外包的所有类都不能访问。接口例外
	- private：Java 访问限制最窄的修饰符，一般称之为“私有的”。被其修饰的属性以及方法**只能被该类的对象访问**，其子类不能访问，更不允许跨包访问。
  
- 深拷贝和浅拷贝的区别？什么是引用拷贝

  - 浅拷贝：浅拷贝会在堆上创建新对象，但是如果原对象内部的属性是引用类型的话，**浅拷贝会复制内部对象的引用地址**，即**拷贝对象和原对象共用**一个内部对象

  - 深拷贝，会完全复制整个对象，包括对象内包含的内部对象

  - 例子

    - 浅拷贝

      ```java
      public class Address implements Cloneable{
          private String name;
          // 省略构造函数、Getter&Setter方法
          @Override
          public Address clone() {
              try {
                  return (Address) super.clone();
              } catch (CloneNotSupportedException e) {
                  throw new AssertionError();
              }
          }
      }
      
      public class Person implements Cloneable {
          private Address address;
          // 省略构造函数、Getter&Setter方法
          @Override
          public Person clone() {
              try {
                  Person person = (Person) super.clone();
                  return person;
              } catch (CloneNotSupportedException e) {
                  throw new AssertionError();
              }
          }
      }
      //------------------测试--------------------
      Person person1 = new Person(new Address("武汉"));
      Person person1Copy = person1.clone();
      // true
      System.out.println(person1.getAddress() == person1Copy.getAddress());
      ```

    - 深拷贝

      ```java
      //修改了Person类的clone()方法进行修改
      @Override
      public Person clone() {
          try {
              Person person = (Person) super.clone();
              person.setAddress(person.getAddress().clone());
              return person;
          } catch (CloneNotSupportedException e) {
              throw new AssertionError();
          }
      }
      //--------------测试-------
      Person person1 = new Person(new Address("武汉"));
      Person person1Copy = person1.clone();
      // false
      System.out.println(person1.getAddress() == person1Copy.getAddress());
      ```

  - 引用拷贝，即两个不同的引用指向同一个对象

  - 如图  
    ![image-20221006140951954](images/mypost/image-20221006140951954.png)


## Java常见类

### Object

- 常见方法  

  ```java
  /**
   * native 方法，用于返回当前运行时对象的 Class 对象，使用了 final 关键字修饰，故不允许子类重写。
   */
  public final native Class<?> getClass()
  /**
   * native 方法，用于返回对象的哈希码，主要使用在哈希表中，比如 JDK 中的HashMap。
   */
  public native int hashCode()
  /**
   * 用于比较 2 个对象的内存地址是否相等，String 类对该方法进行了重写以用于比较字符串的值是否相等。
   */
  public boolean equals(Object obj)
  /**
   * naitive 方法，用于创建并返回当前对象的一份拷贝。
   */
  protected native Object clone() throws CloneNotSupportedException
  /**
   * 返回类的名字实例的哈希码的 16 进制的字符串。建议 Object 所有的子类都重写这个方法。
   */
  public String toString()
  /**
   * native 方法，并且不能重写。唤醒一个在此对象监视器上等待的线程(监视器相当于就是锁的概念)。如果有多个线程在等待只会任意唤醒一个。
   */
  public final native void notify()
  /**
   * native 方法，并且不能重写。跟 notify 一样，唯一的区别就是会唤醒在此对象监视器上等待的所有线程，而不是一个线程。
   */
  public final native void notifyAll()
  /**
   * native方法，并且不能重写。暂停线程的执行。注意：sleep 方法没有释放锁，而 wait 方法释放了锁 ，timeout 是等待时间。
   */
  public final native void wait(long timeout) throws InterruptedException
  /**
   * 多了 nanos 参数，这个参数表示额外时间（以毫微秒为单位，范围是 0-999999）。 所以超时的时间还需要加上 nanos 毫秒。。
   */
  public final void wait(long timeout, int nanos) throws InterruptedException
  /**
   * 跟之前的2个wait方法一样，只不过该方法一直等待，没有超时时间这个概念
   */
  public final void wait() throws InterruptedException
  /**
   * 实例被垃圾回收器回收的时候触发的操作
   */
  protected void finalize() throws Throwable { }
  ```

- == 和 equals() 区别

  - 对于基本类型来说，== 比较的是值
  - 对于引用类型，== 比较的是对象的内存地址
  - **Java是值传递**，所以本质上比较的都是值，只是**引用类型变量存的值是对象地址**

- equals不能用于判断基本数据类型的变量，且只存在于Object类中，而Object类是所有类的直接或间接父类  
  **equals默认实现**：

  ```java
  public boolean equals(Object obj) {
       return (this == obj);
  }
  ```

  - 如果类没有重写该方法，则如上

  - 如果重写了，则**一般**都是重写equals方法来比较对象中的属性是否相等

    >  关于String 和 new String 的区别：
    > String  a = "xxx"  始终返回的是**常量池中的引用**；而new String 始终返回的是**堆中的引用**
    >
    > - 对于String a = "xxx" ，先到常量池中查找是否存在值为"xxx"的字符串，如果存在，直接将常量池中该值对应的引用返回，如果不存在，则在常量池中创建该对象，并返回引用。
    >
    > - 对于new String("xxx")，先到常量池中查找是否存在值为"xxx"的字符串，如果存在，则直接在堆中创建对象，并返回堆中的索引；如果不存在，则先在常量池中创建对象(值为xxx)，然后再在堆中创建对象，并返回堆中该对象的引用地址
    >
    > > 来自  https://blog.csdn.net/weixin_44844089/article/details/103648448

    例子：  

    ```java
    String a = new String("ab"); // a 为一个引用
    String b = new String("ab"); // b为另一个引用,对象的内容一样
    String aa = "ab"; // 放在常量池中
    String bb = "ab"; // 从常量池中查找
    System.out.println(aa == bb);// true
    System.out.println(a == b);// false
    System.out.println(a.equals(b));// true
    System.out.println(42 == 42.0);// true
    ```

- String 类重写了equals()方法

  ```java
  public boolean equals(Object anObject) {
      if (this == anObject) {
          return true;
      }
      if (anObject instanceof String) {
          String anotherString = (String)anObject;
          int n = value.length;
          if (n == anotherString.value.length) {
              char v1[] = value;
              char v2[] = anotherString.value;
              int i = 0;
              while (n-- != 0) {
                  if (v1[i] != v2[i])
                      return false;
                  i++;
              }
              return true;
          }
      }
      return false;
  }
  ```

- hashCode()有什么用  
  hashCode()的作用是**获取哈希码(int整数)**，也称为**散列码**，作用是确定**该对象在哈希表中的索引位置**。函数定义在Object类中，且为本地方法，通常用来**将对象的内存地址转换为整数之后返回**；散列表存储的是键值对(key-value)，**根据“键”快速检索出“值”**，其中利用了散列码

- 为什么需要hashCode

  > 当你把对象加入 `HashSet` 时，`HashSet` 会先计算对象的 **`hashCode` 值来判断对象加入的位置**，同时也会**与其他已经加入的对象的 `hashCode` 值作比较**，如果没有相符的 `hashCode`，`HashSet` 会假设对象没有重复出现。但是如果发现有相同 `hashCode` 值的对象，这时会调用 `equals()` 方法来检查 `hashCode` 相等的对象是否真的相同。如果两者相同，`HashSet` 就不会让其加入操作成功。如果不同的话，就会重新散列到其他位置【注意，我觉得这里应该是使用拉链法，说成散列到其他位置貌似有点不对】。这样我们就大大**减少了 `equals` 的次数**，相应就大大提高了执行速度。

- hashCode()和equals()都用于比较两个对象是否相等，为什么要同时提供两个方法（因为在一些容器中，如**HashMap、HashSet**中，判断元素是否在容器中**效率更高**)

  - 两个对象的hashCode值相等并不代表两个对象就相等
  - 因为hashCode所使用的哈希算法也许会让多个对象传回相同哈希值，取决于哈希算法

- 总结
  - 如果两个对象的`hashCode` 值相等，那这两个对象不一定相等（哈希碰撞）。
  - 如果两个对象的`hashCode` 值相等并且`equals()`方法也返回 `true`，我们才认为这两个对象相等。
  - 如果两个对象的**`hashCode` 值不相等**，我们就可以**直接认为这两个对象不相等**。

### String

- String、StringBuffer，StringBuilder区别
  String是不可变的，StringBuffer和StringBuilder都继承自AbstractStringBuilder类，是可变的（提供了**修改字符串**的方法）

- String中的变量**不可变，所以是线程安全**的，而StringBuffer对方法加了**同步锁**，所以是线程安全的；而S**tringBuilder是线程不安全**的

- 三者使用建议

  - 操作少量的数据: 适用 `String`
  - 单线程操作字符串缓冲区下操作大量数据: 适用 `StringBuilder`
  - 多线程操作字符串缓冲区下操作大量数据: 适用 `StringBuffer`

- String 为什么是不可变的

  - 代码  

    ```java
    public final class String implements java.io.Serializable, Comparable<String>, CharSequence {
        private final char value[];
    	//...
    }
    ```

    - 如上，保存字符串的数组被**final**修饰且为**私有**，并且String类**没有提供暴露修改该字符串**的方法
    - String类被修饰为final修饰导致不能被继承，避免子类破坏

  - Java9  

    ```java
    public final class String implements java.io.Serializable,Comparable<String>, CharSequence {
        // @Stable 注解表示变量最多被修改一次，称为“稳定的”。
        @Stable
        private final byte[] value;
    }
    
    abstract class AbstractStringBuilder implements Appendable, CharSequence {
        byte[] value;
    
    }
    ```

    - > Java9为何String底层实现由**char[] 改成了 byte[]** 新版的 String 其实支持两个编码方案： **Latin-1** 和 **UTF-16**。如果字符串中包含的**汉字没有超过 Latin-1** 可表示范围内的字符，那就会使用 **Latin-1** 作为编码方案。Latin-1 编码方案下，`byte` 占一个字节(8 位)，`char` 占用 2 个字节（16），**`byte` 相较 `char` 节省一半的内存空间**。
      >
      > JDK 官方就说了绝大部分字符串对象只包含 Latin-1 可表示的字符。    
      > ```[ˈlætɪn] ```

- 字符串使用“+” 还是 Stringbuilder 
  Java本身不支持运算符重载，但 “ + ” 和 “+=” 是专门为String重载过的运算符，Java中仅有的两个  

  ```java
  String str1 = "he";
  String str2 = "llo";
  String str3 = "world";
  String str4 = str1 + str2 + str3;
  ```

  对应的字节码：  
  ![image-20221008114449075](images/mypost/image-20221008114449075.png)
  
  字符串对象通过“+”的字符串拼接方式，实际上是通过 `StringBuilder` 调用 `append()` 方法实现的，拼接完成之后调用 `toString()` 得到一个 `String` 对象。因此这里就会产生问题，如下代码，会**产生过多的StringBuilder对象**
  
  ```java
  String[] arr = {"he", "llo", "world"};
  String s = "";
  for (int i = 0; i < arr.length; i++) {
      s += arr[i];
  }
  System.out.println(s);
  
  ```
  
  会**循环创建StringBuilder**对象，建议自己创建一个新的StringBuilder并使用：  
  
  ```java
  String[] arr = {"he", "llo", "world"};
  StringBuilder s = new StringBuilder();
  for (String value : arr) {
      s.append(value);
  }
  System.out.println(s);
  ```
  
- String#equals()和Object#equals()有何区别
  String的equals被重写过，比较的是**字符串的值是否相等**，而**Object的equals**比较的是**对象的内存地址**

- 字符串常量池  
  是JVM为了提升性能和减少内存消耗针对字符串（String类）专门开辟的一块区域，主要目的是为了**避免字符串的重复创建**

  ```java
  // 在堆中创建字符串对象”ab“ (这里也可以说是在常量池中创建对象)
  // 将字符串对象”ab“的引用(常量池中的饮用)保存在字符串常量池中
  String aa = "ab";
  // 直接返回字符串常量池中字符串对象”ab“的引用
  String bb = "ab";
  System.out.println(aa==bb);// true
  ```

  - ####  String s1 = new String("abc");这句话创建了几个字符串对象？

    会创建 1 或 2 个字符串对象。
    如果常量池中存在值为"abc"的对象，则直接在堆中创建一个对象，并且返回该对象的引用；如果不存在，则先在常量池中创建该对象，然后再在堆中创建该对象，并且返回该对象（堆中）的引用

    下面这个解释，说明**常量池存储的是引用**（堆中某一块区域的）![image-20221008144055351](images/mypost/image-20221008144055351.png)

    ```java
    // 字符串常量池中已存在字符串对象“abc”的引用
    String s1 = "abc";
    // 下面这段代码只会在堆中创建 1 个字符串对象“abc”
    String s2 = new String("abc");
    ```

  - intern方法的作用，是一个native方法，作用是将指定的**字符串对象的引用**保存在**字符串常量池**中

    ```java
    // 在堆中创建字符串对象”Java“
    // 将字符串对象”Java“的引用保存在字符串常量池中
    String s1 = "Java";
    // 直接返回字符串常量池中字符串对象”Java“对应的引用
    String s2 = s1.intern();
    // 会在堆中在单独创建一个字符串对象
    String s3 = new String("Java");
    // 直接返回字符串常量池中字符串对象”Java“对应的引用
    String s4 = s3.intern();
    // s1 和 s2 指向的是堆中的同一个对象
    System.out.println(s1 == s2); // true
    // s3 和 s4 指向的是堆中不同的对象
    System.out.println(s3 == s4); // false
    // s1 和 s4 指向的是堆中的同一个对象
    System.out.println(s1 == s4); //true
    
    ```

- 问题：String 类型的变量和常量做“+”运算时发生了什么

  ```java
  String str1 = "str";
  String str2 = "ing";
  String str3 = "str" + "ing";
  String str4 = str1 + str2;
  String str5 = "string";
  System.out.println(str3 == str4);//false
  System.out.println(str3 == str5);//true
  System.out.println(str4 == str5);//false
  ```

  - 常量折叠  
    对于 `String str3 = "str" + "ing";` 编译器会给你优化成 `String str3 = "string";` 。

    并不是所有的常量都会进行折叠，只有**编译器在程序编译期就可以确定值**的常量才可以：

    - 基本数据类型( `byte`、`boolean`、`short`、`char`、`int`、`float`、`long`、`double`)以及字符串常量。
    - `final` 修饰的基本数据类型和字符串变量
    - 字符串通过 “+”拼接得到的字符串、基本数据类型之间算数运算（加减乘除）、基本数据类型的位运算（<<、>>、>>> ）

- 引用的值在程序编译期间是无法确认的，无法对其优化

- 对象引用和“+”的字符串拼接方式，实际上是通过 `StringBuilder` 调用 `append()` 方法实现的，拼接完成之后调用 `toString()` 得到一个 `String` 对象 。
  如上面代码```String str4 = str1 + str2;```
  但是如果使用了final关键字声明之后，就可以让编译器当作常量来处理

  ```java
  final String str1 = "str";
  final String str2 = "ing";
  // 下面两个表达式其实是等价的
  String c = "str" + "ing";// 常量池中的对象
  String d = str1 + str2; // 常量池中的对象
  System.out.println(c == d);// true
  
  ```

  但是如果编译器在**运行时才能知道**其确切值的话，就无法对其优化

  ```java
  final String str1 = "str";
  final String str2 = getStr();  //str2只有在运行时才能确定其值
  String c = "str" + "ing";// 常量池中的对象
  String d = str1 + str2; // 在堆上创建的新的对象
  System.out.println(c == d);// false
  public static String getStr() {
        return "ing";
  }
  
  ```

  