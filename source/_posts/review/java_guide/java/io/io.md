---
title: ly0201lyio基础
description: io基础
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-io
date: 2022-10-23 12:21:12
updated: 2022-10-24 23:39:12

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 简介

- IO，即Input/Output，输入和输出，输入就是**数据输入到计算机内存**；输出则是**输出到外部存储**（如**数据库**、**文件**、**远程主机**）

- 根据数据处理方式，又分为**字节流**和**字符流**
- 基类
  - 字节输入流 **InputStream**，字符输入流 **Reader**
  - 字节输出流 **OutputStream**, 字符输出流 **Writer** 

## 字节流

- 字节输入流 InputStream
  InputStream用于从源头（通常是文件）**读取数据（字节信息）到内存**中，java.io.InputStream抽象类是**所有字节输入流的父类**

  - 常用方法

    > - `read()` ：返回输入流中下一个字节的数据。返回的值介于 0 到 255 之间。如果未读取任何字节，则代码返回 `-1` ，表示文件结束。
    > - `read(byte b[ ])` : 从输入流中读取一些字节存储到数组 `b` 中。如果数组 `b` 的长度为零，则不读取。如果没有可用字节读取，返回 `-1`。如果有可用字节读取，则最多读取的字节数最多等于 `b.length` ， 返回读取的字节数。这个方法等价于 `read(b, 0, b.length)`。
    > - `read(byte b[], int off, int len)` ：在`read(byte b[ ])` 方法的基础上增加了 `off` 参数（偏移量）和 `len` 参数（要读取的最大字节数）。
    > - `skip(long n)` ：忽略输入流中的 n 个字节 ,返回实际忽略的字节数。
    > - `available()` ：返回输入流中可以读取的字节数。
    > - `close()` ：关闭输入流释放相关的系统资源。

  - Java9 新增了多个实用方法

    > - `readAllBytes()` ：读取输入流中的所有字节，返回字节数组。
    > - `readNBytes(byte[] b, int off, int len)` ：阻塞直到读取 `len` 个字节。
    > - `transferTo(OutputStream out)` ： 将所有字节**从一个输入流传递到一个输出流**。

  - FileInputStream --> **字节输入流**对象，可直接**指定文件路径**：用来读取单字节数据/或读取至字节数组中，示例如下：  
    input.txt中的字符为LLJavaGuide

    ```java
    try (InputStream fis = new FileInputStream("input.txt")) {
        System.out.println("Number of remaining bytes:"
                + fis.available());
        int content;
        long skip = fis.skip(2);
        System.out.println("The actual number of bytes skipped:" + skip);
        System.out.print("The content read from file:");
        while ((content = fis.read()) != -1) {
            System.out.print((char) content);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
    //输出
    /**Number of remaining bytes:11
    The actual number of bytes skipped:2
    The content read from file:JavaGuide
    **/
    ```

    一般不会单独使用FileInputStream，而是**配合BufferdInputStream(字节缓冲输入流)**，下面代码转为String 较为常见：  

    ```java
    // 新建一个 BufferedInputStream 对象
    BufferedInputStream bufferedInputStream = new BufferedInputStream(new FileInputStream("input.txt"));
    // 读取文件的内容并复制到 String 对象中
    String result = new String(bufferedInputStream.readAllBytes());
    System.out.println(result);
    ```

  - DataInputStream 用于**读取指定类型数据**，不能单独使用，必须结合FileInputStream 

    ```java
    FileInputStream fileInputStream = new FileInputStream("input.txt");
    //必须将fileInputStream作为构造参数才能使用
    DataInputStream dataInputStream = new DataInputStream(fileInputStream);
    //可以读取任意具体的类型数据
    dataInputStream.readBoolean();
    dataInputStream.readInt();
    dataInputStream.readUTF();
    ```

  - ObjectInputStream 用于从**输入流读取Java对象（一般是被反序列化到文件中，或者其他介质的数据）**，ObjectOutputStream用于**将对象写入到输出流**（[将对象]序列化）

    ```java
    ObjectInputStream input = new ObjectInputStream(new FileInputStream("object.data"));
    MyClass object = (MyClass) input.readObject();
    input.close();
    ```

    用于序列化和反序列化的类**必须实现Serializable**接口，不想被序列化的属性用**```transizent```**修饰

- 字节输出流 OutputStream

  - OutputStream用于将字节数据（字节信息）写入到目的地（通常是文件），java.io.OutputStream抽象类是**所有字节输出流的父类**

      > //常用方法
      >
      > - `write(int b)` ：将特定字节写入输出流。
      > - `write(byte b[ ])` : 将数组`b` 写入到输出流，等价于 `write(b, 0, b.length)` 。
      > - `write(byte[] b, int off, int len)` : 在`write(byte b[ ])` 方法的基础上增加了 `off` 参数（偏移量）和 `len` 参数（要读取的最大字节数）。
      > - `flush()` ：刷新此输出流并强制写出所有缓冲的输出字节。 //相比输入流多出的方法
      > - `close()` ：关闭输出流释放相关的系统资源。
  
- 示例代码：  
  ```java
  try (FileOutputStream output = new FileOutputStream("output.txt")) {
      byte[] array = "JavaGuide".getBytes();
      output.write(array);
  } catch (IOException e) {
      e.printStackTrace();
  }
  //结果
  /**output.txt文件中内容为:
  JavaGuide
  **/
  ```
```
  FileOutputStream一般也是配合BufferedOutputStream （字节缓冲输出流）： 

  ```java
  FileOutputStream fileOutputStream = new FileOutputStream("output.txt");
    BufferedOutputStream bos = new BufferedOutputStream(fileOutputStream)
```

- DataOutputStream用于**写入指定类型**数据，不能单独使用，必须**结合FileOutputStream**

  ```java
  // 输出流
  FileOutputStream fileOutputStream = new FileOutputStream("out.txt");
  DataOutputStream dataOutputStream = new DataOutputStream(fileOutputStream);
  // 输出任意数据类型
  dataOutputStream.writeBoolean(true);
  dataOutputStream.writeByte(1);
  ```

  - ObjectInputStream用于从输入流中读取**Java对象**（ObjectInputStream，反序列化）；ObjectOutputStream用于**将对象写入到输出流**（ObjectOutputStream，序列化）

    ```java
    ObjectOutputStream output = new ObjectOutputStream(new FileOutputStream("file.txt")
    Person person = new Person("Guide哥", "JavaGuide作者");
    output.writeObject(person);
    ```

## 字符流

- 简介
  文件读写或者网络发送接收，信息的最小存储单元都是字节，**为什么**I/O流操作要分为**字节流**操作和**字符流**操作呢

  - 字符流是由**Java虚拟机将字节转换得到**的，过程相对耗时

  - **如果不知道编码类型，容易出现乱码**
    如上面的代码，将文件内容改为 ： 你好，我是Guide

    ```java
    try (InputStream fis = new FileInputStream("input.txt")) {
        System.out.println("Number of remaining bytes:"
                + fis.available());
        int content;
        long skip = fis.skip(2);
        System.out.println("The actual number of bytes skipped:" + skip);
        System.out.print("The content read from file:");
        while ((content = fis.read()) != -1) {
            System.out.print((char) content);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
    //输出
    /**Number of remaining bytes:9
    The actual number of bytes skipped:2
    The content read from file:§å®¶å¥½
    **/
    ```

    为了解决乱码问题，I/O流提供了一个**直接操作字符的接口**，方便对字符进行流操作；但如果音频文件、图片等媒体文件用字节流比较好，涉及字符的话使用字符流

    > ★ 重要：
    >
    > 字符流默认采用的是 `Unicode` 编码，我们可以通过构造方法自定义编码。顺便分享一下之前遇到的笔试题：常用字符编码所占字节数？  
  > `utf8` :英文占 1 字节，中文占 3 字节，  
    > `unicode`：任何字符都占 2 个字节，  
    > `gbk`：英文占 1 字节，中文占 2 字节。
  
- Reader（字符输入流）

  - 用于从源头（通常是文件）读取数据（字符信息）到内存中，java.io.Reader抽象类是**所有字符输入流的父类**

    注意：InputStream和Reader都是类，再往上就是接口了；Reader用于读取文本，InputStream用于读取原始字节
    ![image-20221024095605757](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221024095605757.png)

    > 常用方法：
    >
    > - `read()` : 从输入流读取一个字符。
    > - `read(char[] cbuf)` : 从输入流中读取一些字符，并将它们存储到字符数组 `cbuf`中，等价于 `read(cbuf, 0, cbuf.length)` 。
    > - `read(char[] cbuf, int off, int len)` ：在`read(char[] cbuf)` 方法的基础上增加了 `off` 参数（偏移量）和 `len` 参数（要读取的最大字节数）。
    > - `skip(long n)` ：忽略输入流中的 n 个字符 ,返回实际忽略的字符数。
    > - `close()` : 关闭输入流并释放相关的系统资源。

  - InputStreamReader是**字节流转换为字符流**的桥梁，子类FileReader基于该基础上的封装，可以**直接操作**字符文件

    ```java
    // 字节流转换为字符流的桥梁
    public class InputStreamReader extends Reader {
    }
    // 用于读取字符文件
    public class FileReader extends InputStreamReader {
    }
    ```

    示例：input.txt中内容为"你好，我是Guide"

    ```java
    try (FileReader fileReader = new FileReader("input.txt");) {
        int content;
        long skip = fileReader.skip(3);
        System.out.println("The actual number of bytes skipped:" + skip);
        System.out.print("The content read from file:");
        while ((content = fileReader.read()) != -1) {
            System.out.print((char) content);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
    /*输出
    The actual number of bytes skipped:3
    The content read from file:我是Guide。
    */
    ```

- Write（字符输出流）
  用于将数据（字符信息）写到目的地（通常是文件），java.io.Writer抽象类是**所有字节输出流**的父类

  > - `write(int c)` : 写入单个字符。
  > - `write(char[] cbuf)` ：写入字符数组 `cbuf`，等价于`write(cbuf, 0, cbuf.length)`。
  > - `write(char[] cbuf, int off, int len)` ：在`write(char[] cbuf)` 方法的基础上增加了 `off` 参数（偏移量）和 `len` 参数（要读取的最大字节数）。
  > - `write(String str)` ：写入字符串，等价于 `write(str, 0, str.length())` 。
  > - `write(String str, int off, int len)` ：在`write(String str)` 方法的基础上增加了 `off` 参数（偏移量）和 `len` 参数（要读取的最大字节数）。
  > - `append(CharSequence csq)` ：将指定的字符序列附加到指定的 `Writer` 对象并返回该 `Writer` 对象。
  > - `append(char c)` ：将指定的字符附加到指定的 `Writer` 对象并返回该 `Writer` 对象。
  > - `flush()` ：刷新此输出流并强制写出所有缓冲的输出字符。//相对于Reader增加的
  > - `close()`:关闭输出流释放相关的系统资源。

  - OutputStreamWriter是**字符流转换为字节流**的桥梁（注意，这里没有错），其子类**FileWriter是基于该基础上的封装**，可以直接将字符写入到文件

    ```java
    // 字符流转换为字节流的桥梁
    public class OutputStreamWriter extends Writer {
    }
    // 用于写入字符到文件
    public class FileWriter extends OutputStreamWriter {
    }
    ```

    FileWriter代码示例：  

    ```java
    try (Writer output = new FileWriter("output.txt")) {
        output.write("你好，我是Guide。"); //字符流，转为字节流
    } catch (IOException e) {
        e.printStackTrace();
    }
    /*结果：output.txt中
    你好，我是Guide
    */
    ```

- InputStreamWriter和OutputStreamWriter 比较

  - 前者InputStreamWriter，是需要**从文件中读数据出来（读到内存中）**，而文件是通过二进制（字节）保存的，所以InputStreamWriter是**将（看不懂的）字节流转换为（看得懂的）字符流**
  - 后者OutputStreamWriter，是需要**将（看得懂的）字符流转换为（看不懂的）字节流（然后从内存读出）**并保存到介质中

## 字节缓冲流

- 简介  

  - IO操作是很消耗性能的，缓冲流**将数据加载至缓冲区**，一次性读取/写入多个字节，从而避免频繁的IO操作，提高流的效率

  - 采用装饰器模式来增强InputStream和OutputStream子类对象的功能

  - 例子：

    ```java
    // 新建一个 BufferedInputStream 对象
    BufferedInputStream bufferedInputStream = new BufferedInputStream(new FileInputStream("input.txt"));
    ```

  - **字节流**和**字节缓冲流**的性能差别主要体现在：当使用两者时都调用的是write(int b)和read() 这两个一次只读取一个字节的方法的时候，由于**字节缓冲流内部有缓冲区（字节数组）**，因此字节缓冲流会**将读取到的字节存放在缓存区**，大幅减少IO次数，提高读取效率 

    > 对比：复制524.9mb文件，缓冲流15s，普通字节流2555s(30min)
    >
    > 测试代码  
    >
    > ```java
    > @Test
    > void copy_pdf_to_another_pdf_buffer_stream() {
    >     // 记录开始时间
    >     long start = System.currentTimeMillis();
    >     try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream("深入理解计算机操作系统.pdf"));
    >          BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("深入理解计算机操作系统-副本.pdf"))) {
    >         int content;
    >         while ((content = bis.read()) != -1) {
    >             bos.write(content);
    >         }
    >     } catch (IOException e) {
    >         e.printStackTrace();
    >     }
    >     // 记录结束时间
    >     long end = System.currentTimeMillis();
    >     System.out.println("使用缓冲流复制PDF文件总耗时:" + (end - start) + " 毫秒");
    > }
    > 
    > @Test
    > void copy_pdf_to_another_pdf_stream() {
    >     // 记录开始时间
    >     long start = System.currentTimeMillis();
    >     try (FileInputStream fis = new FileInputStream("深入理解计算机操作系统.pdf");
    >          FileOutputStream fos = new FileOutputStream("深入理解计算机操作系统-副本.pdf")) {
    >         int content;
    >         while ((content = fis.read()) != -1) {
    >             fos.write(content);
    >         }
    >     } catch (IOException e) {
    >         e.printStackTrace();
    >     }
    >     // 记录结束时间
    >     long end = System.currentTimeMillis();
    >     System.out.println("使用普通流复制PDF文件总耗时:" + (end - start) + " 毫秒");
    > }
    > ```

    - 但是如果是使用普通字节流的 **read(byte b[] )**和**write(byte b[] , int off, int len)** 这两个写入一个字节数组的方法的话，只要字节数组大小合适，差距性能不大
      同理，使用read(byte b[]) 和write(byte b[] ,int off, int len)方法(字节流及缓冲字节流)，分别复制524mb文件，缓冲流需要0.7s , 普通字节流需要1s
      代码如下：  

      ```java
      @Test
      void copy_pdf_to_another_pdf_with_byte_array_buffer_stream() {
          // 记录开始时间
          long start = System.currentTimeMillis();
          try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream("深入理解计算机操作系统.pdf"));
               BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("深入理解计算机操作系统-副本.pdf"))) {
              int len;
              byte[] bytes = new byte[4 * 1024];
              while ((len = bis.read(bytes)) != -1) {
                  bos.write(bytes, 0, len);
              }
          } catch (IOException e) {
              e.printStackTrace();
          }
          // 记录结束时间
          long end = System.currentTimeMillis();
          System.out.println("使用缓冲流复制PDF文件总耗时:" + (end - start) + " 毫秒");
      }
      
      @Test
      void copy_pdf_to_another_pdf_with_byte_array_stream() {
          // 记录开始时间
          long start = System.currentTimeMillis();
          try (FileInputStream fis = new FileInputStream("深入理解计算机操作系统.pdf");
               FileOutputStream fos = new FileOutputStream("深入理解计算机操作系统-副本.pdf")) {
              int len;
              byte[] bytes = new byte[4 * 1024];
              while ((len = fis.read(bytes)) != -1) {
                  fos.write(bytes, 0, len);
              }
          } catch (IOException e) {
              e.printStackTrace();
          }
          // 记录结束时间
          long end = System.currentTimeMillis();
          System.out.println("使用普通流复制PDF文件总耗时:" + (end - start) + " 毫秒");
      }
      ```

      

- 字节缓冲输入流 BufferedInputStream

  - `BufferedInputStream` 从源头（通常是文件）读取数据（字节信息）到内存的过程中**不会一个字节一个字节的读取**，而是会先**将读取到的字节存放在缓存区**，并从内部缓冲区中单独读取字节。这样大幅减少了 IO 次数，提高了读取效率。

    `BufferedInputStream` **内部维护了一个缓冲区**，这个**缓冲区实际就是一个字节数组**，通过阅读 `BufferedInputStream` 源码即可得到这个结论。

  - 源码  

    ```java
    public
    class BufferedInputStream extends FilterInputStream {
        // 内部缓冲区数组
        protected volatile byte buf[];
        // 缓冲区的默认大小
        private static int DEFAULT_BUFFER_SIZE = 8192;
        // 使用默认的缓冲区大小
        public BufferedInputStream(InputStream in) {
            this(in, DEFAULT_BUFFER_SIZE);
        }
        // 自定义缓冲区大小
        public BufferedInputStream(InputStream in, int size) {
            super(in);
            if (size <= 0) {
                throw new IllegalArgumentException("Buffer size <= 0");
            }
            buf = new byte[size];
        }
    }
    ```

    

- **字节缓冲输出流** BufferedOutputStream
  `BufferedOutputStream` 将数据（字节信息）写入到目的地（通常是文件）的过程中不会**一个字节一个字节的写入**，而是会**先将要写入的字节存放在缓存区**，并**从内部缓冲区中单独写入字节**。这样大幅**减少了 IO 次数**，**提高了读取效率**
  使用  

  ```java
  try (BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream("output.txt"))) {
      byte[] array = "JavaGuide".getBytes();
      bos.write(array);
  } catch (IOException e) {
      e.printStackTrace();
  }
  ```

## 字符缓冲流

**`BufferedReader` （字符缓冲输入流）和 `BufferedWriter`（字符缓冲输出流）**类似于 `BufferedInputStream`（字节缓冲输入流）和`BufferedOutputStream`（字节缓冲输入流），内部都维护了一个**字节数组**作为缓冲区。不过，前者主要是用来操作字符信息。

> 这里**表述好像不太对，应该是维护了字符数组**：  
>
> ```java
> public class BufferedReader extends Reader {
> 
>     private Reader in;
> 
>     private char cb[];
> }
> ```

## 打印流

- PrintStream属于字节打印流，对应的是PrintWriter（字符打印流）

- System.out 实际上获取了一个PrintStream，print方法调用的是PrintStream的write方法

- `PrintStream` 是 `OutputStream` 的子类，`PrintWriter` 是 `Writer` 的子类。

- ```java
  public class PrintStream extends FilterOutputStream
      implements Appendable, Closeable {
  }
  public class PrintWriter extends Writer {
  }
  ```

## 随机访问流 RandomAccessFile

- 指的是支持随意跳转到文件的任意位置进行读写的RandomAccessFile
  构造方法如下，可以指定mode (读写模式)

  ```java
  // openAndDelete 参数默认为 false 表示打开文件并且这个文件不会被删除
  public RandomAccessFile(File file, String mode)
      throws FileNotFoundException {
      this(file, mode, false);
  }
  // 私有方法
  private RandomAccessFile(File file, String mode, boolean openAndDelete)  throws FileNotFoundException{
    // 省略大部分代码
  }
  ```

  读写模式主要有以下四种：  

  - r : 只读；rw：读写

  - rws :相对于rw，rws同步更新对"文件内容"或元数据的修改到外部存储设备

  - rwd:相对于rw,rwd同步更新对"文件内容"的修改到外部存储设备

  - 解释：

    > - 文件内容指实际保存的数据，元数据则描述属性例如文件大小信息、创建和修改时间
    > - 默认情形下(rw模式下),是使用buffer的,只有cache满的或者使用RandomAccessFile.close()关闭流的时候儿才真正的写到文件。
    >   1. 调试麻烦的...------------------使用write方法修改byte的时候儿,只修改到个内存兰,还没到个文件,闪的调试麻烦的,不能使用notepad++工具立即看见修改效果..
    >   2. 当系统halt的时候儿,不能写到文件...安全性稍微差点儿...
    > - rws：就是同步（synchronized）模式,每write修改一个byte,立马写到磁盘..当然中间性能走差点儿,适合小的文件...and debug模式...或者安全性高的需要的时候儿
    > - rwd： 只对“文件的内容”同步更新到磁盘...不对metadata同步更新
    > - rwd介于rw和rws之间

- RandomAccessFile：文件指针表示下一个将要被写入或读取的字节所处位置

  - 通过seek(long pos)方法设置文件指针偏移量（距离开头pos个字节处，从0开始）

  - 使用getFilePointer()方法获取文件指针当前位置

    ```java
    RandomAccessFile randomAccessFile = new RandomAccessFile(new File("input.txt"), "rw");
    System.out.println("读取之前的偏移量：" + randomAccessFile.getFilePointer() + ",当前读取到的字符" + (char) randomAccessFile.read() + "，读取之后的偏移量：" + randomAccessFile.getFilePointer());
    // 指针当前偏移量为 6
    randomAccessFile.seek(6);
    System.out.println("读取之前的偏移量：" + randomAccessFile.getFilePointer() + ",当前读取到的字符" + (char) randomAccessFile.read() + "，读取之后的偏移量：" + randomAccessFile.getFilePointer());
    // 从偏移量 7 的位置开始往后写入字节数据
    randomAccessFile.write(new byte[]{'H', 'I', 'J', 'K'});
    // 指针当前偏移量为 0，回到起始位置
    randomAccessFile.seek(0);
    System.out.println("读取之前的偏移量：" + randomAccessFile.getFilePointer() + ",当前读取到的字符" + (char) randomAccessFile.read() + "，读取之后的偏移量：" + randomAccessFile.getFilePointer());
    ```

    - input.txt文件内容： ABCDEFG

    - 输出

      ```
      读取之前的偏移量：0,当前读取到的字符A，读取之后的偏移量：1
      读取之前的偏移量：6,当前读取到的字符G，读取之后的偏移量：7
      读取之前的偏移量：0,当前读取到的字符A，读取之后的偏移量：1
      ```

      文件内容： ABCDEFGHIJK

  - write方法在写入对象时如果对应位置已有数据，会将其覆盖

    ```java
    RandomAccessFile randomAccessFile = new RandomAccessFile(new File("input.txt"), "rw");
    randomAccessFile.write(new byte[]{'H', 'I', 'J', 'K'});
    //如果程序之前input.txt内容为ABCD，则运行后变为HIJK
    ```

  - 常见应用：**解决断点续传**：上传文件中途暂停或失败（网络问题），之后不需要重新上传，只需**上传未成功上传的文件分片**即可 分片（先将文件切分成多个文件分片）上传是断点续传的基础。
    **使用RandomAccessFile帮助我们合并文件分片**（但是下面代码好像不是必须的，因为他是单线程连续写入？？，这里附上另一篇文章的另一段话：）

    > 但是**由于 RandomAccessFile 可以自由访问文件的任意**位置，**所以如果需要访问文件的部分内容，而不是把文件从头读到尾，因此 RandomAccessFile 的一个重要使用场景就是网络请求中的多线程下载及断点续传。** https://blog.csdn.net/li1669852599/article/details/122214104

    ![image-20221024233326047](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221024233326047.png)
  
  > **ly: 个人感觉，mysql数据库的写入可能也是依赖类似的规则，才能在某个位置读写**
