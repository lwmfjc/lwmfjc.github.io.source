---
title: unsafe类
description: unsafe类
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 17:10:27
updated: 2022-10-10 17:10

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

```sun.misc.Unsafe```

提供**执行低级别**、**不安全操作**的方法，如**直接访问系统内存资源**、**自主管理内存资源**等，效率快，但由于有了操作内存空间的能力，会**增加指针问题风险**。且这些功能的实现依赖于本地方法，Java代码中只是声明方法头，具体实现规则交给本地代码
![image-20221010172203732](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221010172203732.png)

### 为什么要使用本地方法

- 需要用到Java中不具备的依赖于操作系统的特性，跨平台的同时要实现对底层控制
- 对于其他语言已经完成的现成功能，可以使用Java调用
- 对时间敏感/性能要求非常高，有必要使用更为底层的语言

对于同一本地方法，不同的操作系统可能通过不同的方式来实现的

### Unsafe创建

sun.misc.Unsafe部分源码

```java
public final class Unsafe {
  // 单例对象
  private static final Unsafe theUnsafe;
  ......
  private Unsafe() {
  }
    
  //Sensitive : 敏感的 英[ˈsensətɪv]
  @CallerSensitive
  public static Unsafe getUnsafe() {
    Class var0 = Reflection.getCallerClass();
    // 仅在引导类加载器`BootstrapClassLoader`加载时才合法
    if(!VM.isSystemDomainLoader(var0.getClassLoader())) {
      throw new SecurityException("Unsafe");
    } else {
      return theUnsafe;
    }
  }
}
```

会先判断当前类是否由Bootstrap classloader加载。即只有启动类加载器加载的类才能够调用Unsafe类中的方法

如何使用```Unsafe```这个类  

1. 利用反射获得Unsafe类中已经实例化完成的单例对象```theUnsafe```

   ```java
   private static Unsafe reflectGetUnsafe() {
       try {
         Field field = Unsafe.class.getDeclaredField("theUnsafe");
         field.setAccessible(true);
         return (Unsafe) field.get(null);
       } catch (Exception e) {
         log.error(e.getMessage(), e);
         return null;
       }
   }
   ```

2. 通过Java命令行命令```-Xbootclasspath/a```把调用Unsafe相关方法的类A所在jar包路径追加到默认的bootstrap路径中，使得A被引导类加载器加载

   ```java
   java -Xbootclasspath/a:${path}   // 其中path为调用Unsafe相关方法的类所在jar包路径
   ```

### Unsafe功能

内存操作、内存屏障、对象操作、数据操作、CAS操作、线程调度、Class操作、系统信息

#### 内存操作

相关方法:  

```java
//分配新的本地空间
public native long allocateMemory(long bytes);
//重新调整内存空间的大小
public native long reallocateMemory(long address, long bytes);
//将内存设置为指定值
public native void setMemory(Object o, long offset, long bytes, byte value);
//内存拷贝
public native void copyMemory(Object srcBase, long srcOffset,Object destBase, long destOffset,long bytes);
//清除内存
public native void freeMemory(long address);
```

测试：  

```java
private void memoryTest() {
    int size = 4;
    long addr = unsafe.allocateMemory(size);
    long addr3 = unsafe.reallocateMemory(addr, size * 2);
    System.out.println("addr: "+addr);
    System.out.println("addr3: "+addr3);
    try {
        //向每个字节，写入1 首先使用allocateMemory方法申请 4 字节长度的内存空间，在循环中调用setMemory方法向每个字节写入内容为byte类型的 1
        unsafe.setMemory(null,addr ,size,(byte)1);
        for (int i = 0; i < 2; i++) {
            unsafe.copyMemory(null,addr,null,addr3+size*i,4);
        }
        System.out.println(unsafe.getInt(addr));
        System.out.println(unsafe.getLong(addr3));
    }finally {
        unsafe.freeMemory(addr);
        unsafe.freeMemory(addr3);
    }
}
//结果
addr: 2433733895744
addr3: 2433733894944
16843009
72340172838076673
```

对于setMemory的解释 [来源](https://www.cnblogs.com/throwable/p/9139947.html)

```java
public native void setMemory(Object o, long offset, long bytes, byte value); 将给定内存块中的所有字节设置为固定值(通常是0)。内存块的地址由对象引用o和偏移地址共同决定，如果对象引用o为null，offset就是绝对地址。第三个参数就是内存块的大小，如果使用allocateMemory进行内存开辟的话，这里的值应该和allocateMemory的参数一致。value就是设置的固定值，一般为0(这里可以参考netty的DirectByteBuffer)。一般而言，o为null，所有有个重载方法是public native void setMemory(long offset, long bytes, byte value);，等效于setMemory(null, long offset, long bytes, byte value);。
```



分析：

> 分析一下运行结果，首先使用`allocateMemory`方法申请 4 字节长度的内存空间，在循环中调用`setMemory`方法向每个字节写入内容为`byte`类型的 1，当使用 Unsafe 调用`getInt`方法时，因为一个`int`型变量占 4 个字节，会一次性读取 4 个字节，组成一个`int`的值，对应的十进制结果为 16843009。

![image-20221011114456296](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221011114456296.png)

对于reallocateMemory方法：  

>在代码中调用`reallocateMemory`方法重新分配了一块 8 字节长度的内存空间，通过比较`addr`和`addr3`可以看到和之前申请的内存地址是不同的。在代码中的第二个 for 循环里，调用`copyMemory`方法进行了两次内存的拷贝，每次拷贝内存地址`addr`开始的 4 个字节，分别拷贝到以`addr3`和`addr3+4`开始的内存空间上：
>
>拷贝完成后，使用```getLong```方法一次性读取8个字节，得到long类型的值
>
>这种分配属于堆外内存，无法进行垃圾回收，需要我们把这些内存当作资源去手动调用freeMemory方法进行释放，否则会产生内存泄漏。通常是try-finally进行内存释放

![image-20221011141135430](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221011141135430.png)

- 为什么使用堆外内存

  - 对垃圾回收停顿的改善，堆外内存直接受操作系统管理而不是JVM
  - 提升程序I/O操作的性能。通常I/O通信过程中，存在堆内内存到堆外内存的数据拷贝操作，对于需要频繁进行内存间的数据拷贝且生命周期较短的暂存数据，建议都存储到堆外内存

- 典型应用
  DirectByteBuffer，Java用于实现堆外内存的重要类，对于堆外内存的创建、使用、销毁等逻辑均由Unsafe提供的堆外内存API来实现

  ```java
  //DirectByteBuffer类源
  DirectByteBuffer(int cap) {                   // package-private
  
      super(-1, 0, cap, cap);
      boolean pa = VM.isDirectMemoryPageAligned();
      int ps = Bits.pageSize();
      long size = Math.max(1L, (long)cap + (pa ? ps : 0));
      Bits.reserveMemory(size, cap);
  
      long base = 0;
      try {
          // 分配内存并返回基地址
          base = unsafe.allocateMemory(size);
      } catch (OutOfMemoryError x) {
          Bits.unreserveMemory(size, cap);
          throw x;
      }
      // 内存初始化
      unsafe.setMemory(base, size, (byte) 0);
      if (pa && (base % ps != 0)) {
          // Round up to page boundary
          address = base + ps - (base & (ps - 1));
      } else {
          address = base;
      }
      // 跟踪 DirectByteBuffer 对象的垃圾回收，以实现堆外内存释放
      cleaner = Cleaner.create(this, new Deallocator(base, size, cap));
      att = null;
  }
  ```

  

#### 内存屏障

- 介绍

  - 编译器和 CPU 会在保证程序输出结果一致的情况下，会对代码进行重排序，从指令优化角度提升性能
  - 后果是，导致 CPU 的高速缓存和内存中数据的不一致
  - 内存屏障（`Memory Barrier`）就是通过阻止屏障两边的指令重排序从而避免编译器和硬件的不正确优化情况

- Unsafe提供了三个内存屏障相关方法

  ```java
  //内存屏障，禁止load操作重排序。屏障前的load操作不能被重排序到屏障后，屏障后的load操作不能被重排序到屏障前
  public native void loadFence();
  //内存屏障，禁止store操作重排序。屏障前的store操作不能被重排序到屏障后，屏障后的store操作不能被重排序到屏障前
  public native void storeFence();
  //内存屏障，禁止load、store操作重排序
  public native void fullFence();
  ```

- 以loadFence方法为例，会禁止读操作重排序，保证在这个屏障之前的所有读操作都已经完成，并且将缓存数据设为无效，重新从主存中进行加载
  在某个线程修改Runnable中的flag

  ```java
  @Getter
  class ChangeThread implements Runnable{
      /**volatile**/ boolean flag=false;
      @Override
      public void run() {
          try {
              Thread.sleep(3000);
          } catch (InterruptedException e) {
              e.printStackTrace();
          }
          System.out.println("subThread change flag to:" + flag);
          flag = true;
      }
  }
  ```

  在主线程的while循环中，加入内存屏障，测试是否能感知到flag的修改变化

  ```java
  public static void main(String[] args){
      ChangeThread changeThread = new ChangeThread();
      new Thread(changeThread).start();
      while (true) {
          boolean flag = changeThread.isFlag();
          unsafe.loadFence(); //加入读内存屏障
          if (flag){
              System.out.println("detected flag changed");
              break;
          }
      }
      System.out.println("main thread end");
  }
  //运行结果
  subThread change flag to:false
  detected flag changed
  main thread end
  ```

- 如果删除上面的loadFence()方法，就会出现下面的情况，主线程无法感知flag发生的变化，会一直在while中循环
  ![image-20221011163035365](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221011163035365.png)

- 典型应用
  Java8新引入的锁---```StampedLock```，乐观锁，类似于无锁的操作，完全不会阻塞写线程获取写锁，从而缓解读多写少的”饥饿“现象。由于StampedLock提供的乐观读锁不阻塞写线程获取读锁，当线程共享变量从主内存load到线程工作内存时，存在数据不一致的问题

  ```java
  public boolean validate(long stamp) {
     U.loadFence();
     return (stamp & SBITS) == (state & SBITS);
  }
  ```

  

#### 对象操作

- 对象属性

  ```java
  //在对象的指定偏移地址获取一个对象引用
  public native Object getObject(Object o, long offset);
  //在对象指定偏移地址写入一个对象引用
  public native void putObject(Object o, long offset, Object x);
  ```

  

- 对象实例化
  类：

  ```java
  @Data
  public class A {
      private int b;
      public A(){
          this.b =1;
      }
  }
  ```

  对象实例化

  ```java
  public void objTest() throws Exception{
      A a1=new A();
      System.out.println(a1.getB());
      A a2 = A.class.newInstance();
      System.out.println(a2.getB());
      A a3= (A) unsafe.allocateInstance(A.class);
      System.out.println(a3.getB());
  }
  //结果
  1 1 0
  ```

  > 打印结果分别为 1、1、0，说明通过`allocateInstance`方法创建对象过程中，不会调用类的构造方法。使用这种方式创建对象时，只用到了`Class`对象，所以说如果想要跳过对象的初始化阶段或者跳过构造器的安全检查，就可以使用这种方法。在上面的例子中，如果将 A 类的构造函数改为`private`类型，将无法通过构造函数和反射创建对象，但`allocateInstance`方法仍然有效。

- 典型应用

  - 常规对象实例化方式，从本质上来说，都是通过new机制来实现对象的创建
  - 非常规的实例化方式：Unsafe中提供allocateInstance方法，仅通过Class对象就可以创建此类的实例对象

#### 数组操作

- 介绍

  ```java
  //下面两个方法配置使用，即可定位数组中每个元素在内存中的位置
  //返回数组中第一个元素的偏移地址
  public native int arrayBaseOffset(Class<?> arrayClass);
  //返回数组中一个元素占用的大小
  public native int arrayIndexScale(Class<?> arrayClass);
  ```

- 典型应用
  

#### CAS操作

- 相关操作

  ```java
  /**
  	*  CAS
    * @param o         包含要修改field的对象
    * @param offset    对象中某field的偏移量
    * @param expected  期望值
    * @param update    更新值
    * @return          true | false
    */
  public final native boolean compareAndSwapObject(Object o, long offset,  Object expected, Object update);
  
  public final native boolean compareAndSwapInt(Object o, long offset, int expected,int update);
  
  public final native boolean compareAndSwapLong(Object o, long offset, long expected, long update);
  ```

- CAS，AS 即比较并替换（Compare And Swap)，是实现并发算法时常用到的一种技术。CAS 操作包含三个操作数——内存位置、预期原值及新值。执行 CAS 操作的时候，将内存位置的值与预期原值比较，如果相匹配，那么处理器会自动将该位置值更新为新值，否则，处理器不做任何操作。我们都知道，CAS 是一条 CPU 的原子指令（cmpxchg 指令），不会造成所谓的数据不一致问题，`Unsafe` 提供的 CAS 方法（如 `compareAndSwapXXX`）底层实现即为 CPU 指令 `cmpxchg`

- 输出

  ```java
  private volatile int a;
  public static void main(String[] args){
      CasTest casTest=new CasTest();
      new Thread(()->{
          for (int i = 1; i < 5; i++) {
              casTest.increment(i);
              System.out.print(casTest.a+" ");
          }
      }).start();
      new Thread(()->{
          for (int i = 5 ; i <10 ; i++) {
              casTest.increment(i);
              System.out.print(casTest.a+" ");
          }
      }).start();
  }
  
  private void increment(int x){
      while (true){
          try {
              long fieldOffset = unsafe.objectFieldOffset(CasTest.class.getDeclaredField("a"));
              if (unsafe.compareAndSwapInt(this,fieldOffset,x-1,x))
                  break;
          } catch (NoSuchFieldException e) {
              e.printStackTrace();
          }
      }
  }
  //结果
1 2 3 4 5 6 7 8 9
  ```
  
  使用两个线程去修改int型属性a的值，并且只有在a的值等于传入的参数x减一时，才会将a的值变为x，也就是实现对a的加一的操作
  ![image-20221011184828760](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221011184828760.png)

#### 线程调度(多线程问题)

```java
//Unsafe类提供的相关方法
//取消阻塞线程
public native void unpark(Object thread);
//阻塞线程
public native void park(boolean isAbsolute, long time);
//获得对象锁（可重入锁）
@Deprecated
public native void monitorEnter(Object o);
//释放对象锁
@Deprecated
public native void monitorExit(Object o);
//尝试获取对象锁
@Deprecated
public native boolean tryMonitorEnter(Object o);
```

方法 `park`、`unpark` 即可实现线程的挂起与恢复，将一个线程进行挂起是通过 `park` 方法实现的，调用 `park` 方法后，线程将一直阻塞直到超时或者中断等条件出现；`unpark` 可以终止一个挂起的线程，使其恢复正常。

<<<<<<< HEAD
此外，`Unsafe` 源码中`monitor`相关的三个方法已经被标记为`deprecated`，不建议被使用：
=======
Unsafe源码中monitor相关的方法被标记为deprecated
>>>>>>> 01db5084445cfa1dd668fb907ec8e453c9136e03

```java
//获得对象锁
@Deprecated
public native void monitorEnter(Object var1);
//释放对象锁
@Deprecated
public native void monitorExit(Object var1);
//尝试获得对象锁
@Deprecated
public native boolean tryMonitorEnter(Object var1);
```

`monitorEnter`方法用于获得对象锁，`monitorExit`用于释放对象锁，如果对一个没有被`monitorEnter`加锁的对象执行此方法，会抛出`IllegalMonitorStateException`异常。`tryMonitorEnter`方法尝试获取对象锁，如果成功则返回`true`，反之返回`false`。
<<<<<<< HEAD

#### Class操作


=======

代码应用：  

```java
public static void main(String[] args) {
    Thread mainThread = Thread.currentThread();
    new Thread(()->{
        try {
            TimeUnit.SECONDS.sleep(5);
            System.out.println("subThread try to unpark mainThread");
            unsafe.unpark(mainThread);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }).start();

    System.out.println("park main mainThread");
    unsafe.park(false,0L);
    System.out.println("unpark mainThread success");
}
//输出
park main mainThread
subThread try to unpark mainThread
unpark mainThread success
```

流程图如下：  
![image-20221012090743240](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221012090743240.png)

#### Class操作

Unsafe对class的相关操作主要包括类加载和静态变量的操作方法

- 静态属性读取相关的方法

  ```java
  //获取静态属性的偏移量
  public native long staticFieldOffset(Field f);
  //获取静态属性的对象指针---另一说,获取静态变量所属的类在方法区的首地址
  public native Object staticFieldBase(Field f);
  //判断类是否需要实例化（用于获取类的静态属性前进行检测）
  public native boolean shouldBeInitialized(Class<?> c);
  ```

- 测试

  ```java
  @Data
  public class User {
      public static String name="Hydra";
      int age;
  }
  private void staticTest() throws Exception {
      User user=new User();
      System.out.println(unsafe.shouldBeInitialized(User.class));
      Field sexField = User.class.getDeclaredField("name");
      long fieldOffset = unsafe.staticFieldOffset(sexField);
      Object fieldBase = unsafe.staticFieldBase(sexField);
      Object object = unsafe.getObject(fieldBase, fieldOffset);
      System.out.println(object);
  }
  /**
   运行结果:falseHydra
  */
  ```

  在 `Unsafe` 的对象操作中，我们学习了通过`objectFieldOffset`方法获取对象属性偏移量并基于它对变量的值进行存取，但是它不适用于类中的静态属性，这时候就需要使用`staticFieldOffset`方法。在上面的代码中，只有在获取`Field`对象的过程中依赖到了`Class`，而获取静态变量的属性时不再依赖于`Class`。

  在上面的代码中首先创建一个`User`对象，这是因为如果一个类没有被实例化，那么它的静态属性也不会被初始化，最后获取的字段属性将是`null`。所以在获取静态属性前，需要调用`shouldBeInitialized`方法，判断在获取前是否需要初始化这个类。如果删除创建 User 对象的语句，运行结果会变为：```truenull```

- ```defineClass```方法允许程序在运行时动态创建一个类

  ```java
  public native Class<?> defineClass(String name, byte[] b, int off, int len, ClassLoader loader,ProtectionDomain protectionDomain);
  
  ```

  利用class类字节码文件，动态创建一个类

  ```java
  private static void defineTest() {
      String fileName="F:\\workspace\\unsafe-test\\target\\classes\\com\\cn\\model\\User.class";
      File file = new File(fileName);
      try(FileInputStream fis = new FileInputStream(file)) {
          byte[] content=new byte[(int)file.length()];
          fis.read(content);
          Class clazz = unsafe.defineClass(null, content, 0, content.length, null, null);
          Object o = clazz.newInstance();
          Object age = clazz.getMethod("getAge").invoke(o, null);
          System.out.println(age);
      } catch (Exception e) {
          e.printStackTrace();
      }
  }
  ```

#### 系统信息

```java 
//获取系统相关信息 
//返回系统指针的大小。返回值为4（32位系统）或 8（64位系统）。
public native int addressSize();
//内存页的大小，此值为2的幂次方。
public native int pageSize();
```

