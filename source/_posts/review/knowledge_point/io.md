---
title: io基础
description: io基础
categories:
  - 学习
tags:
  - 复习
  - 复习--知识点
date: 2022-10-23 12:21:12
updated: 2022-10-23 12:21:12
---

## 简介

- IO，即Input/Output，输入和输出，输入就是数据输入到计算机内存；输出则是输出到外部存储（如数据库、文件、远程主机）

- 根据数据处理方式，又分为字节流和字符流
- 基类
  - 字节输入流 InputStream，字符输入流 Reader
  - 字节输出流 OutputStream, 字符输出流 Writer 

## 字节流

- 字节输入流 InputStream
  InputStream用于从源头（通常是文件）读取数据（字节信息）到内存中，java.io.InputStream抽象类是所有字节输入流的父类

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
    > - `transferTo(OutputStream out)` ： 将所有字节从一个输入流传递到一个输出流。

  - FileInputStream --> 字节输入流对象，可直接指定文件路径：用来读取单字节数据/或读取至字节数组中，示例如下：  
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

    一般不会单独使用FileInputStream，而是配合BufferdInputStream(字节缓冲输入流)，下面代码转为String 较为常见：  

    ```java
    // 新建一个 BufferedInputStream 对象
    BufferedInputStream bufferedInputStream = new BufferedInputStream(new FileInputStream("input.txt"));
    // 读取文件的内容并复制到 String 对象中
    String result = new String(bufferedInputStream.readAllBytes());
    System.out.println(result);
    ```

  - DataInputStream 用于读取指定类型数据，不能单独使用，必须结合FileInputStream 

    ```java
    FileInputStream fileInputStream = new FileInputStream("input.txt");
    //必须将fileInputStream作为构造参数才能使用
    DataInputStream dataInputStream = new DataInputStream(fileInputStream);
    //可以读取任意具体的类型数据
    dataInputStream.readBoolean();
    dataInputStream.readInt();
    dataInputStream.readUTF();
    ```

  - ObjectInputStream 用于从输入流读取Java对象（一般是被反序列化到文件中，或者其他介质的数据），ObjectOutputStream用于将对象写入到输出流（[将对象]序列化）

    ```java
    ObjectInputStream input = new ObjectInputStream(new FileInputStream("object.data"));
    MyClass object = (MyClass) input.readObject();
    input.close();
    ```

    用于序列化和反序列化的类必须实现Serializable接口，不想被序列化的属性用```transizent```修饰

- 字节输出流 OutputStream

  - OutputStream用于将字节数据（字节信息）写入到目的地（通常是文件），java.io.OutputStream抽象类是所有字节输出流的父类

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
  FileOutputStream一般也是配合BufferedOutputStream （字节缓冲输出流）： 

  ```java
  FileOutputStream fileOutputStream = new FileOutputStream("output.txt");
    BufferedOutputStream bos = new BufferedOutputStream(fileOutputStream)
  ```
  
- DataOutputStream用于写入指定类型数据，不能单独使用，必须结合FileOutputStream

  ```java
  // 输出流
  FileOutputStream fileOutputStream = new FileOutputStream("out.txt");
  DataOutputStream dataOutputStream = new DataOutputStream(fileOutputStream);
  // 输出任意数据类型
  dataOutputStream.writeBoolean(true);
  dataOutputStream.writeByte(1);
  ```

  - ObjectInputStream用于从输入流中读取**Java对象**（ObjectInputStream，反序列化）；ObjectOutputStream用于将对象写入到输出流（ObjectOutputStream，序列化）

    ```java
    ObjectOutputStream output = new ObjectOutputStream(new FileOutputStream("file.txt")
    Person person = new Person("Guide哥", "JavaGuide作者");
    output.writeObject(person);
    ```

## 字符流

## 字节缓冲流

## 字符缓冲流

## 打印流

## 随记访问流