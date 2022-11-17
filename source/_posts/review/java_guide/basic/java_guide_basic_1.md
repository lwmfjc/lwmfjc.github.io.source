---
title: javaGuide基础1
description: javaGuide基础1
categories:
  - 学习
tags:
  - '复习'
  - '复习-javaGuide'
  - '复习-javaGuide-基础'
date: 2022-09-28 10:51:00
updated: 2022-09-28 10:51:00

---

> 转载自https://github.com/Snailclimb/JavaGuide

## 基础概念及常识

- Java语言特点

  - 面向对象（封装、继承、多态）
  - 平台无关性（Java虚拟机）
  - 等等

- JVM并非只有一种，只要满足JVM规范，可以开发自己专属JVM

- JDK与JRE

  - JDK，JavaDevelopmentKit，能够创建和编译程序，包含JRE。
  - JRE，Java运行时环境，包括Java虚拟机、Java类库，及Java命令等

- 字节码，采用字节码的好处

  - Java中，JVM可以理解的代码称为字节码（.class文件)，不面向任何处理器，只面向虚拟机
  - Java程序从源代码到运行的过程
    ![image-20220928110902410](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220928110902410.png)
    java代码必须先编译为字节码，之后呢，.class-->机器码，这里JVM类加载器先加载字节码文件，然后通过解释器进行解释执行（也就是字节码需要由Java解释器来解释执行）

- 编译与解释并存

  - 编译型：通过编译器将源代码一次性翻译成可被该平台执行的机器码，执行快、开发效率低
  - 解释型：通过解释器一句一句的将代码解释成机器代码后执行，执行慢，开发效率高
  - 如图
    ![image-20220928110844996](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220928110844996.png)

- Java与C++区别

  - 没学过C++，Java不提供指针直接访问内存
  - Java为单继承；但是Java支持继承多接口
  - Java有自动内存管理垃圾回收机制（GC），不需要程序员手动释放无用内存

- 注释分为 单行注释、多行注释、文档注释
  ![image-20220928111257144](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220928111257144.png)

- 标识符与关键字
  标识符即名字，关键字则是被赋予特殊含义的标识符

- 自增自减运算符
  当 `b = ++a` 时，先自增（自己增加 1），再赋值（赋值给 b）；当 `b = a++` 时，先赋值(赋值给 b)，再自增（自己增加 1）

- continue/break/return

  - `continue` ：指跳出当前的这一次循环，继续下一次循环。
  - `break` ：指跳出整个循环体，继续执行循环下面的语句。
  - `return` 用于跳出所在方法，结束该方法的运行。

- 变量

  - 成员变量和局部变量
    - 成员变量可以被 `public`,`private`,`static` 等修饰符所修饰，而局部变量不能被访问控制修饰符及 `static` 所修饰；但是，成员变量和局部变量都能被 `final` 所修饰
    - 从变量在内存中的存储方式来看,如果成员变量是使用 `static` 修饰的，那么这个成员变量是属于类的，如果没有使用 `static` 修饰，这个成员变量是属于实例的。而对象存在于堆内存，局部变量则存在于栈内存。
    - 从变量在内存中的生存时间上看，成员变量是对象的一部分，它随着对象的创建而存在，而局部变量随着方法的调用而自动生成，随着方法的调用结束而消亡（即方法栈弹出后消亡）。
    - final必须显示赋初始值，其他都自动以类型默认值赋值
  - 静态变量：被类所有实例共享

- 字符型常量与字符串常量区别

  - **形式** : 字符常量是单引号引起的一个字符，字符串常量是双引号引起的 0 个或若干个字符。
  - **含义** : 字符常量相当于一个整型值( ASCII 值),可以参加表达式运算; 字符串常量代表一个地址值(该字符串在内存中存放位置)。
  - **占内存大小** ： 字符常量只占 2 个字节; 字符串常量占若干个字节。

- 静态方法为什么不能调用非静态成员

  - 静态方法是属于类的，在类加载的时候就会分配内存，可以通过类名直接访问。而非静态成员属于实例对象，只有在对象实例化之后才存在，需要通过类的实例对象去访问。
  - 在类的非静态成员不存在的时候静态成员就已经存在了，此时调用在内存中还不存在的非静态成员，属于非法操作。

- 调用方式

  - 使用类名.方法名 调用静态方法，或者对象.方法名 （不建议）
    调用静态方法可以无需创建对象

- 重载

  - 同一个类中（或者父类与子类之间），方法名相同，参数类型不同、个数不同、顺序不同、方法返回值和访问修饰符可以不同  
    不允许存在（只有返回值不同的两个方法(方法名和参数个数及类型相同))
  - 重载就是同一个类中多个同名方法根据不同的传参来执行不同的逻辑处理。

- 重写

  - 发生在运行期，子类对父类的允许访问的方法实现过程进行重新编写
    - 方法名、参数列表必须相同，**子类方法返回值类型应比父类方法返回值类型更小或相等，抛出的异常范围小于等于父类，访问修饰符范围大于等于父类。【注意，这里只针对方法，类属性则没有这个限制】**
    - 如果父类方法访问修饰符为 `private/final/static` 则子类就不能重写该方法，但是被 `static` 修饰的方法能够被再次声明。
    - 构造方法无法被重写

- 可变长参数

  - 代码
    可变参数只能作为函数的最后一个参数

    ```java
    public static void method2(String arg1, String... args) {
       //......
    }
    ```

  - **遇到方法重载的情况怎么办呢？会优先匹配固定参数还是可变参数的方法呢？**

    答案是会优先匹配固定参数的方法

    Java 的可变参数编译后实际会被转换成一个数组，我们看编译后生成的 `class`文件就可以看出来了。

  - Java 的可变参数编译后实际会被转换成一个数组，我们看编译后生成的 `class`文件就可以看出来了。

- 基本数据类型，8种

  - 6种数字类型，1种字符类型，1种布尔值
    - byte,short,int,long ;  float,double ;  
    - char
    - boolean 
  - 1个字节8位，其中
    - byte 1字节，short 2字节，int 4字节 ，long 8字节
    - float 4字节，double 8 字节
    - char 2字节，boolean 1位

- 基本数据类型和包装类型的区别

  - 包装类型可用于泛型，而基本类型不可以
  - 对于基本数据类型，局部变量会存放在Java虚拟机栈中的局部变量表中，成员变量（未被static修饰）存放在Java虚拟机堆中。  
    包装类型属于对象类型，几乎所有对象实例都存在于堆中
  - 相比对象类型，基本数据类型占用空间非常小
  - "基本数据类型存放在栈中" 这句话是错的，基本数据类型的成员变量如果没有被static修饰的话（不建议这么用，应该使用基本数据类型对应的包装类型），就存放在堆中。

- 包装类型的缓存机制
  Byte，Short，Integer，Long这4中包装类默认创建了数值[-128,127]的相应类型的缓存数据，Character创建了数值在[0,127]范围的缓存数据，Boolean直接返回True or False
  
  - Integer缓存代码
    
    ```java
    public static Integer valueOf(int i) {
        if (i >= IntegerCache.low && i <= IntegerCache.high)
            return IntegerCache.cache[i + (-IntegerCache.low)];
        return new Integer(i);
    }
    private static class IntegerCache {
        static final int low = -128;
        static final int high;
        static {
            // high value may be configured by property
            int h = 127;
        }
    }
    ```
    
  - Character缓存代码
  
    ```java
    public static Character valueOf(char c) {
        if (c <= 127) { // must cache
          return CharacterCache.cache[(int)c];
        }
        return new Character(c);
    }
    
    private static class CharacterCache {
        private CharacterCache(){}
        static final Character cache[] = new Character[127 + 1];
        static {
            for (int i = 0; i < cache.length; i++)
                cache[i] = new Character((char)i);
        }
    
    }
    ```
  
  - Boolean缓存代码
  
    ```java
    public static Boolean valueOf(boolean b) {
        return (b ? TRUE : FALSE);
    }
    ```
  
  - 注意Float和Double没有使用缓存机制，且 只有调用valueOf才会使用缓存，当使用new的时候是直接创建新对象
  
    ```java
        public Integer(int value) {
            this.value = value;
        }
    ```
  
  - 举例
  
    ```java
            Boolean t=new Boolean(true);
            Boolean f=new Boolean(true);
            System.out.println(t==f); //false
            System.out.println(t.equals(f)); //true
    
            Boolean t1=Boolean.valueOf(true);
            Boolean f1=Boolean.valueOf(true);
            System.out.println(t1==f1); //true
    
            System.out.println(Boolean.TRUE==Boolean.TRUE); //true
            //============================================//
    		Integer i1 = 33; //这里发生了自动装箱，相当于Integer.valueOf(30)
            Integer i2 = 33;
            System.out.println(i1 == i2);// 输出 true
    
            Float i11 = 333f;
            Float i22 = 333f;
            System.out.println(i11 == i22);// 输出 false
    
            Double i3 = 1.2;
            Double i4 = 1.2;
            System.out.println(i3 == i4);// 输出 false
    
            //===========================================//
    		Integer i1 = 40;
            Integer i2 = new Integer(40);
            System.out.println(i1==i2);
    ```
  
  - 如上，所有整型包装类对象之间值的比较，应该全部使用equals方法比较
    ![image-20220929092643596](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220929092643596.png)
  
  - 什么是自动装箱和拆箱
  
    - **装箱**：将基本类型用它们对应的引用类型包装起来；
    - **拆箱**：将包装类型转换为基本数据类型；
  
  - 举例说明
  
    ```java
    Integer i = 10 ;//装箱
    int n = i ;//拆箱
    ```
  
    对应的字节码
  
    ```
       L1
    
        LINENUMBER 8 L1
    
        ALOAD 0
    
        BIPUSH 10
    
        INVOKESTATIC java/lang/Integer.valueOf (I)Ljava/lang/Integer;
    
        PUTFIELD AutoBoxTest.i : Ljava/lang/Integer;
    
       L2
    
        LINENUMBER 9 L2
    
        ALOAD 0
    
        ALOAD 0
    
        GETFIELD AutoBoxTest.i : Ljava/lang/Integer;
    
        INVOKEVIRTUAL java/lang/Integer.intValue ()I
    
        PUTFIELD AutoBoxTest.n : I
    
        RETURN
    ```
  
    如图，Integer i = 10 等价于Integer i = Integer.valueOf(10)  
  
    int n= i 等价于 int n= i.intValue();
  
    频繁拆装箱会严重影响系统行呢个
  
  - 浮点数运算的时候会有精度丢失的风险
  
    > 这个和计算机保存浮点数的机制有很大关系。我们知道计算机是二进制的，而且计算机在表示一个数字时，宽度是有限的，无限循环的小数存储在计算机时，只能被截断，所以就会导致小数精度发生损失的情况。这也就是解释了为什么浮点数没有办法用二进制精确表示。
  
    十进制下的0.2无法精确转换成二进制小数
  
    ```
    // 0.2 转换为二进制数的过程为，不断乘以 2，直到不存在小数为止，
    // 在这个计算过程中，得到的整数部分从上到下排列就是二进制的结果。
    0.2 * 2 = 0.4 -> 0
    0.4 * 2 = 0.8 -> 0
    0.8 * 2 = 1.6 -> 1
    0.6 * 2 = 1.2 -> 1
    0.2 * 2 = 0.4 -> 0（发生循环）
    ```
  
  - 使用BigDecimal解决上面的问题
  
    ```java
    BigDecimal a = new BigDecimal("1.0");
    BigDecimal b = new BigDecimal("0.9");
    BigDecimal c = new BigDecimal("0.8");
    
    BigDecimal x = a.subtract(b);
    BigDecimal y = b.subtract(c);
    
    System.out.println(x); /* 0.1 */
    System.out.println(y); /* 0.1 */
    System.out.println(Objects.equals(x, y)); /* true */
    ```
  
  - 超过long整形的数据，使用BigInteger
  
    Java中，64位long整型是最大的整数类型
  
    ```java
    long l = Long.MAX_VALUE;
    System.out.println(l + 1); // -9223372036854775808
    System.out.println(l + 1 == Long.MIN_VALUE); // true
    //BigInteger内部使用int[] 数组来存储任意大小的整型数据
    //对于常规整数类型，使用BigInteger运算的效率会降低
    ```
  
    ![image-20220929093558353](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220929093558353.png)