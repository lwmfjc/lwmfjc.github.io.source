---
title: io设计模式
description: io设计模式
categories:
  - 学习
tags:
  - 复习
  - 复习--知识点
date: 2022-10-24 23:40:53
updated: 2022-10-25 11:40:53
---

## 装饰器模式

- 装饰器，Decorator，装饰器模式可以在不改变原有对象的情况下拓展其功能

- ★装饰器模式，通过组合替代继承来扩展原始类功能，在一些继承关系较复杂的场景（IO这一场景各种类的继承关系就比较复杂）下更加实用

- 对于字节流，**FilterInputStream（对应输入流）和FilterOutputStream（对应输出流）**是装饰器模式的核心，分别用于增强（继承了）InputStream和OutputStream子类对象的功能
  Filter （过滤的意思）
  ![image-20221026092700367](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026092700367.png)

- 其中BufferedInputStream（字节缓冲输入流）、DataInputStream等等都是FilterInputStream的子类，对应的BufferedOutputStream和DataOutputStream都是FilterOutputStream的子类

- 例子，使用BufferedInputStream（字节缓冲输入流）来增强FileInputStream功能

  - BufferedInputStream源码（构造函数）

      ```java
      private static int DEFAULT_BUFFER_SIZE = 8192;
      public BufferedInputStream(InputStream in) {
          this(in, DEFAULT_BUFFER_SIZE);
      }

      public BufferedInputStream(InputStream in, int size) {
          super(in);
          if (size <= 0) {
              throw new IllegalArgumentException("Buffer size <= 0");
          }
          buf = new byte[size];
      }
      ```
    
  - 使用
  
      ```java
      try (BufferedInputStream bis = new BufferedInputStream(new FileInputStream("input.txt"))) {
          int content;
          long skip = bis.skip(2);
          while ((content = bis.read()) != -1) {
              System.out.print((char) content);
          }
      } catch (IOException e) {
          e.printStackTrace();
      }
      ```
  
- ZipInputStream和ZipOutputStream还可以用来增强BufferedInputStream和BufferedOutputStream的能力

  ```java
  //使用
  BufferedInputStream bis = new BufferedInputStream(new FileInputStream(fileName));
  ZipInputStream zis = new ZipInputStream(bis);
  
  BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(fileName));
  ZipOutputStream zipOut = new ZipOutputStream(bos);
  ```

  ![image-20221026093724390](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221026093724390.png)

- 装饰器模式重要的一点，就是可以对原始类嵌套使用多个装饰器，所以装饰器需要跟原始类继承相同的抽象类或实现相同接口，上面介绍的IO相关装饰器和原始类共同父类都是InputStream和OutputStream
  而对于字符流来说，BufferedReader用来增强Reader（字符输入流）子类功能，BufferWriter用来增加Writer（字符输出流）子类功能

  ```java
  BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName), "UTF-8"));
  ```

- IO流中大量使用了装饰器模式，不需要特意记忆

## 适配器模式



## 工厂模式

## 观察者模式

