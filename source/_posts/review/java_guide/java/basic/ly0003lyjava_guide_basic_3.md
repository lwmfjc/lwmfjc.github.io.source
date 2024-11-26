---
title:  javaGuide基础3
description: javaGuide基础3
categories:
  - 学习
tags:
  - '复习'
  - '复习-javaGuide'
  - '复习-javaGuide-基础'
date: 2022-10-08 15:23:15
updated: 2022-10-08 15:23:15

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 异常

- unchecked exceptions (运行时异常)  
  checked exceptions (非运行时异常，编译异常）  

- Java异常类层次结构图
  ![lyx-20241126133556644](attachments/img/lyx-20241126133556644.png)

  ![lyx-20241126133557180](attachments/img/lyx-20241126133557180.png)
  
- Exception和Error有什么区别

  - 除了RuntimeException及其子类以外，其他的Exception类及其子类都属于受检查异常

  - Exception : 程序本身可以处理的异常（可通过catch捕获）

    - Checked Exception ，受检查异常，必须处理(**catch 或者 throws ，否则编译器通过不了**)
      IOException，ClassNotFoundException，SQLException，FileNotFoundException 

    - Unchecked Exception ， 不受检查异常 ， 可以不处理
      

（算数异常，类型转换异常，不合法的线程状态异常，下标超出异常，空指针异常，参数类型异常，数字格式异常，不支持操作异常）
      ArithmeticException，ClassCastException，IllegalThreadStateException，IndexOutOfBoundsException
      
      NullPointerException，IllegalArgumentException，NumberFormatException，SecurityException，UnsupportedOperationException 


      ```illegal 英[ɪˈliːɡl] 非法的```  
      ```Arithmetic 英[əˈrɪθmətɪk] 算术```

  - Error： **程序无法处理**的错误 ，不建议通过catch 捕获，已办错误发生时JVM会选择线程终止  
    OutOfMemoryError （堆，Java heap space），VirtualMachineError，StackOverFlowError，AssertionError （断言），IOError 

- Throwable类常用方法 

  - String getMessage() //简要描述
  - String toString()  //详细
  - String getLocalizedMessage()  //本地化信息，如果子类(Throwable的子类)没有覆盖该方法，则与gtMessage() 结果一样
  - void printStackTrace() //打印Throwable对象封装的异常信息
  
- try-catch-finally如何使用
  try后面必须要有catch或者finally；无论是否捕获异常，finally都会执行；当在 `try` 块或 `catch` 块中遇到 `return` 语句时，`finally` 语句块将在方法返回之前被执行。

  - **不要在 finally 语句块中使用 return!** 当 try 语句和 finally 语句中都有 return 语句时，**try 语句块中的 return 语句会被忽略**。这是因为 try 语句中的 return 返回值会先被暂存在一个本地变量中，当执行到 finally 语句中的 return 之后，这个本地变量的值就变为了 finally 语句中的 return 返回值。

    ```java
    public static void main(String[] args) {
        System.out.println(f(2));
  }
    
    public static int f(int value) {
        try {
            return value * value;
        } finally {
            if (value == 2) {
                return 0;
            }
        }
    }
    /*  
     0
    */
    ```
  
- finally中的代码不一定执行（如果finally之前虚拟机就已经被终止了）

  - 另外两种情况，程序所在的线程死亡；关闭CPU；都会导致代码不执行

- 使用try-with-resources代替try-catch-finally

  - 适用范围：任何实现```java.lang.AutoCloseable```或者```java.io.Closeable```的对象【比如InputStream、OutputStream、Scanner、PrintWriter等需要调用close()方法的资源】

  - 在try-with-resources中，任何**catch或finally块在声明的资源关闭后运行**

  - 例子

    ```java
    //读取文本文件的内容
    Scanner scanner = null;
    try {
        scanner = new Scanner(new File("D://read.txt"));
        while (scanner.hasNext()) {
            System.out.println(scanner.nextLine());
        }
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } finally {
        if (scanner != null) {
            scanner.close();
        }
    }
    
    ```

    改造后：  

    ```
    try (Scanner scanner = new Scanner(new File("test.txt"))) {
        while (scanner.hasNext()) {
            System.out.println(scanner.nextLine());
        }
    } catch (FileNotFoundException fnfe) {
        fnfe.printStackTrace();
    }
    
    ```

    可以使用分隔符来分割  

    ```java
    try (BufferedInputStream bin = new BufferedInputStream(new FileInputStream(new File("test.txt")));
         BufferedOutputStream bout = new BufferedOutputStream(new FileOutputStream(new File("out.txt")))) {
        int b;
        while ((b = bin.read()) != -1) {
            bout.write(b);
        }
    }
    catch (IOException e) {
        e.printStackTrace();
    }
    
    ```

- 需要注意的地方  

  - 不要把异常定义为静态变量，因为这样会导致**异常栈信息错乱**。每次手动抛出异常，我们都需要**手动 new 一个异常对象抛出**。
  - 抛出的**异常信息一定要有意义**。
  - 建议抛出**更加具体的异常**比如字符串转换为数字格式错误的时候应该抛出`NumberFormatException`而不是其父类`IllegalArgumentException`。
  - 使用日志打印异常之后就不要再抛出异常了（两者不要同时存在一段代码逻辑中）。

## 泛型

- 什么是泛型？有什么作用
  Java泛型（Generics）JDK5中引入的一个新特性，使用泛型参数，可以**增强代码的可读性**以及**稳定性**

- 编译器可以**对泛型参数进行检测，并通过泛型参数可以指定传入的对象类型**，比如```ArrayList<Person> persons=new ArrayList<Person>()```这行代码指明该ArrayList对象只能传入Person对象，若传入其他类型的对象则会报错

  - 原生List返回类型为Object，需要手动转换类型才能使用，**使用泛型后编译器自动转换**

- 泛型使用方式  

  - 泛型类

    ```java
    //此处T可以随便写为任意标识，常见的如T、E、K、V等形式的参数常用于表示泛型
    //在实例化泛型类时，必须指定T的具体类型
    public class Generic<T>{
    
        private T key;
    
        public Generic(T key) {
            this.key = key;
        }
    
        public T getKey(){
            return key;
        }
    }
    // 使用
    Generic<Integer> genericInteger = new Generic<Integer>(123456);
    ```

  - 泛型接口

    ```java
    public interface Generator<T> {
        public T method();
    }
    ```

    - 不指定类型使用  

      ```java
      class GeneratorImpl<T> implements Generator<T>{
          @Override
          public T method() {
              return null;
          }
      }
      
      ```

    - 指定类型使用

      ```java
      class GeneratorImpl<T> implements Generator<String>{
          @Override
          public String method() {
              return "hello";
          }
      }
      
      ```

  - 泛型方法  

    ```java
       public static < E > void printArray( E[] inputArray )
       {
             for ( E element : inputArray ){
                System.out.printf( "%s ", element );
             }
             System.out.println();
        }
    //使用
    // 创建不同类型数组： Integer, Double 和 Character
    Integer[] intArray = { 1, 2, 3 };
    String[] stringArray = { "Hello", "World" };
    printArray( intArray  );
    printArray( stringArray  );
    
    ```

    上面称为静态方法，Java中泛型只是一个占位符，必须在传递类型后才能使用，类在实例化时才能传递类型参数，而类型方法的加载优先于类的实例化，静态泛型方法是**没有办法使用类上声明的泛型（即上面的第二点中类名旁边的T）**的，只能使用自己声明的<E> 
    
  - 也可以是非静态的  
  
    ```java
    class A{
            private String name;
            private int age;
    
            public <E> int  geA(E e){
                System.out.println(e.toString());
                return 1;
            }
        }
        //使用,其中 <Object> 可以省略
        a.<Object>geA(new Object()); 
    ```

## 反射

- 反射赋予了我们在**运行时分析类**以及**执行类中方法**的能力，通过反射可以**获取任意一个类的所有属性和方法**

- 反射**增加（导致）了安全问题**，可以**无视泛型参数的安全检查**（**泛型参数的安全检查发生在编译期**），不过其对于框架来说实际是影响不大的

- 应用场景  
  一般用于框架中，框架中大量使用了**动态代理**，而**动态代理的实现也依赖于反射**

  ```java
  //JDK动态代理
  interface ILy {
      String say(String word);
  }
  
  class LyImpl implements ILy{
  
      @Override
      public String say(String word) {
          return "hello ,"+word;
      }
  }
  
  @Slf4j
  class MyInvocationHandler implements InvocationHandler {
      private final Object target;
  
      public MyInvocationHandler(Object target) {
          this.target = target;
    }
  
      @Override
      public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
          log.info("调用前");
          Object result = method.invoke(target, args);
          log.info("结果是:"+result);
          log.info("调用后");
          return result;
      }
  }
  
  public class Test {
      String a;
  
      public static void main(String[] args) {
          LyImpl target = new LyImpl();
          ILy targetProxy = (ILy)Proxy.newProxyInstance(Test.class.getClassLoader(),
                  target.getClass().getInterfaces(), new MyInvocationHandler(target));
          targetProxy.say("dxs");
      }
  }
  ```
  
  ```java
  //cglib动态代理 
  @Slf4j
  class MyCglibProxyInterceptor implements MethodInterceptor{
  
      @Override
      public Object intercept(Object o, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
          log.info("调用前");
          //注意，这里是invokeSuper，如果是invoke就会调用自己，导致死循环(递归)
          Object result = methodProxy.invokeSuper(o, args);
          //上面这个写法有问题，应该是
          //Object result = method.invoke(o, args);
          log.info("调用结果"+result);
          log.info("调用后");
          return result;
      }
  }
  
  public class Test {
      String a;
  
      public static void main(String[] args) {
          Enhancer enhancer=new Enhancer();
          enhancer.setClassLoader(Test.class.getClassLoader());
          enhancer.setSuperclass(LyImpl.class);
          enhancer.setCallback(new MyCglibProxyInterceptor());
          //方法一(通过)
          ILy o = (ILy)enhancer.create();
          //方法二(通过)
          //LyImpl o = (LyImpl)enhancer.create();
          o.say("lyly"); 
      }
  }
  ```
  
  
  
  注解也使用到了反射，比如Spring上的@Component注解。
  可以**基于反射分析类**，然后**获取到类/属性/方法/方法的参数上的注解**，**获取注解后，做进一步的处理**

## 注解

- 注解，Java5引入，用于修饰类、方法或者变量，提供某些信息供程序在编译或者运行时使用

  ```java
  @Target(ElementType.METHOD)
  @Retention(RetentionPolicy.SOURCE)
  public @interface Override {
  
  }
  //注解本质上是一个继承了Annotation的特殊接口
  public interface Override extends Annotation{
  
  }
  ```

- 注解只有被解析后才会生效

  - **编译期直接扫描** ：编译器在编译 Java 代码的时候扫描对应的注解并处理，比如某个方法使用`@Override` 注解，编译器在编译的时候就会检测当前的方法是否重写了父类对应的方法。
  - **运行期通过反射处理** ：像框架中自带的注解(比如 Spring 框架的 `@Value` 、`@Component`)都是通过反射来进行处理的。(创建类的时候使用反射分析类，获取注解，对创建的对象进一步处理)

## SPI 

- 介绍
  - Service Provider Interface ，服务提供者的接口 ， 专门**提供给服务提供者**或者**扩展框架功能的开发者**去使用的一个接口
  - SPI 将**服务接口**和**具体的服务实现**分离开来，将**服务调用方**和**服务实现者**解耦，能够提升程序的扩展性、可维护性。修改或者替换服务实现并不需要修改调用方。
  - 很多框架都使用了 Java 的 SPI 机制，比如：Spring 框架、数据库加载驱动、日志接口、以及 Dubbo 的扩展实现等等。
  - SPI扩展实现
    ![lyx-20241126133557582](attachments/img/lyx-20241126133557582.png)
- API和SPI区别
  ![lyx-20241126133558068](attachments/img/lyx-20241126133558068.png)
  - 模块之间通过接口进行通讯，在服务调用方和服务实现方(服务提供者)之间引入一个“接口”
    - 当接口和实现，都是放在实现方的时候，这就是API
    - 当接口存在于调用方，由**接口调用方确定接口规则**，然后由**不同的厂商去根据这个规则对这个接口进行实现**，从而提供服务，即SPI
    
      > 举个通俗易懂的例子：公司 H 是一家科技公司，新设计了一款芯片，然后现在需要量产了，而市面上有好几家芯片制造业公司，这个时候，只要 H 公司指定好了这芯片生产的标准（定义好了接口标准），那么这些合作的芯片公司（服务提供者）就按照标准交付自家特色的芯片（提供不同方案的实现，但是给出来的结果是一样的）
      >
      > 
- 通过 SPI 机制提供了**接口设计的灵活性**，缺点：  
  - 需要**遍历加载所有的实现类**，不能做到按需加载，效率较低
  - 当**多个ServiceLoader同时load**时，会有并发问题

## I/O

- 序列化和反序列化

  - 序列化：将数据结构或对象换成二级制字节流的过程
  - 反序列化：将在序列化过程中所生成的二进制字节流转换成数据结构或者对象的过程
  - 对于Java，序列化的都是对象（Object），即实例化后的类（Class）

- 维基

  > **序列化**（serialization）在计算机科学的数据处理中，是指将数据结构或对象状态转换成可取用格式（例如存成文件，存于缓冲，或经由网络中发送），以留待后续在相同或另一台计算机环境中，能恢复原先状态的过程。依照序列化格式重新获取字节的结果时，可以利用它来产生与原始对象相同语义的副本。对于许多对象，像是使用大量引用的复杂对象，这种序列化重建的过程并不容易。面向对象中的对象序列化，并不概括之前原始对象所关系的函数。这种过程也称为对象编组（marshalling）。从一系列字节提取数据结构的反向操作，是反序列化（也称为解编组、deserialization、unmarshalling）。

- 序列化的目的，通过网络传输对象，或者说是将对象存储到文件系统、数据库、内存中
  ![lyx-20241126133558485](attachments/img/lyx-20241126133558485.png)

- 被```transient```修饰的变量，不进行序列化：即当对象被反序列化时，被```transient```修饰的变量值不会被持久化和恢复  ```transient 英[ˈtrænziənt]```

  - `transient` 只能修饰变量，不能修饰类和方法。
  - `transient` 修饰的变量，在反序列化后变量值将会被置成类型的默认值。例如，如果是修饰 `int` 类型，那么反序列后结果就是 `0`。
  - **`static` 变量因为不属于任何对象(Object)**，所以无论有没有 `transient` 关键字修饰，均不会被序列化。

- Java IO流

  > IO 即 `Input/Output`，输入和输出。**数据输入到计算机内存**的过程即输入，反之**输出到外部存储**（比如数据库，文件，远程主机）的过程即输出。数据传输过程类似于水流，因此称为 IO 流。IO 流在 Java 中分为**输入流**和**输出流**，而根据数据的**处理方式**又分为**字节流**和**字符流**。

- JavaIO流的类都是从如下4个抽象类基类中派生出来的

  - `InputStream`/`Reader`: 所有的输入流的基类，前者是字节输入流，后者是字符输入流。
  - `OutputStream`/`Writer`: 所有输出流的基类，前者是字节输出流，后者是字符输出流。

- 不管是文件读写还是网络发送接收，信息的**最小存储单元都是字节**，那为什么I/O流操作要分为字节流操作和字符流操作

  - 字符流由Java虚拟机将字节转换得到，过程较为耗时
  - 如果**不知道编码**类型的过，使用**字节流的过程中很容易出现乱码**

## 语法糖

```syntactic 英[sɪnˈtæktɪk]``` 句法的

指的是为了方便程序员开发程序而设计的一种特殊语法，对编程语言的功能并没有影响，语法糖写出来的代码往往更简单简洁且容易阅读，比如```for-each```，原理：基于普通的for循环和迭代器

```java
String[] strs = {"JavaGuide", "公众号：JavaGuide", "博客：https://javaguide.cn/"};
for (String s : strs) {
  	System.out.println(s);
}
```

> JVM 其实并不能识别语法糖，Java 语法糖要想被正确执行，需要先通过编译器进行解糖，也就是在程序编译阶段将其转换成 JVM 认识的基本语法。这也侧面说明，Java 中真正支持语法糖的是 Java 编译器而不是 JVM。如果你去看`com.sun.tools.javac.main.JavaCompiler`的源码，你会发现在`compile()`中有一个步骤就是调用`desugar()`，这个方法就是负责解语法糖的实现的。

Java中常见的语法糖：  
**泛型**、**自动拆装箱**、**变长参数**、**枚举**、**内部类**、**增强 for 循环**、**try-with-resources 语法**、**lambda 表达式**等