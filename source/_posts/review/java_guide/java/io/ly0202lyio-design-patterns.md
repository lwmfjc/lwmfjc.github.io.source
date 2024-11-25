---
title: io设计模式
description: io设计模式
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-io
date: 2022-10-24 23:40:53
updated: 2022-10-25 11:40:53

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 装饰器模式

​	类图：  
​	![image-20230202093047927](images/mypost/image-20230202093047927.png)

- 装饰器，Decorator，装饰器模式可以在**不改变原有对象的情况下拓展其功能**

- ★装饰器模式，**通过组合替代继承**来扩展原始类功能，在一些**继承关系较复杂**的场景（IO这一场景各种类的继承关系就比较复杂）下更加实用

- 对于字节流，**FilterInputStream（对应输入流）和FilterOutputStream（对应输出流）**是**装饰器模式的核心**，分别用于**增强（继承了）InputStream**和**OutputStream**子类对象的功能
  Filter （过滤的意思），中间（Closeable）下面这两条**虚线代表实现**；最下面的**实线代表继承**
  ![image-20221026092700367](images/mypost/image-20221026092700367.png)

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

  ![image-20221026093724390](images/mypost/image-20221026093724390.png)

- 装饰器模式重要的一点，就是**可以对原始类嵌套使用多个装饰器**，所以**装饰器**需要**跟原始类继承相同**的**抽象类**或**实现相同接口**，上面介绍的IO相关装饰器和原始类共同父类都是InputStream和OutputStream
  而对于字符流来说，BufferedReader用来增强Reader（字符输入流）子类功能，BufferWriter用来增加Writer（字符输出流）子类功能

  ```java
  BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName), "UTF-8"));
  ```

- **IO流中大量使用了装饰器模式**，不需要特意记忆

## 适配器模式

- 适配器（Adapter Pattern）模式：主要用于接口互不兼容的类的协调工作，你可以将其联想到我们日常使用的电源适配器

  - 其中被适配的对象/类称为适配者（Adaptee），作用于适配者的对象或者类称为适配器（Adapter）。**对象适配器**使用**组合**关系实现，**类适配器**使用**继承**关系实现

- IO中**字符流**和**字节流**接口不同，而他们能协调工作就是基于适配器模式来做的，具体的，是对象适配器：将**字节流对象适配成字符流对象**，然后通过**字节流对象**，**读取/写入字符**数据

-  **InputStreamReader**和**OutputStreamWriter**为两个适配器，也是**字节流和字符流**之间的**桥梁**

  - InputStreamReader使用**StreamDecode（流解码器）对字节进行解码**，实现**字节流**到**字符流**的转换

  - OutputStreamWriter使用**StreamEncoder（流编码器）对字符进行编码**，实现**字符**到**字节流**的转换

  - InputStream和OutputStream的子类是被适配者，InputStreamReader和OutputStreamWriter是适配器
    使用：  

    ```java
    // InputStreamReader 是适配器，FileInputStream 是被适配的类
    InputStreamReader isr = new InputStreamReader(new FileInputStream(fileName), "UTF-8");
    // BufferedReader 增强 InputStreamReader 的功能（装饰器模式）
    BufferedReader bufferedReader = new BufferedReader(isr);
    ```

    fileReader的源码：

    ```java
    public class FileReader extends InputStreamReader { 
        public FileReader(String fileName) throws FileNotFoundException {
            super(new FileInputStream(fileName));
        }
    }
    //其父类InputStreamReader
    public class InputStreamReader extends Reader {
    	//用于解码的对象
    	private final StreamDecoder sd;
        public InputStreamReader(InputStream in) {
            super(in);
            try {
                // 获取 StreamDecoder 对象
                sd = StreamDecoder.forInputStreamReader(in, this, (String)null);
            } catch (UnsupportedEncodingException e) {
                throw new Error(e);
            }
        }
        // 使用 StreamDecoder 对象做具体的读取工作
    	public int read() throws IOException {
            return sd.read();
        }
    }
    ```

    同理，java.io.OutputStreamWriter部分源码：  

    ```java
    public class OutputStreamWriter extends Writer {
        // 用于编码的对象
        private final StreamEncoder se;
        public OutputStreamWriter(OutputStream out) {
            super(out);
            try {
               // 获取 StreamEncoder 对象
                se = StreamEncoder.forOutputStreamWriter(out, this, (String)null);
            } catch (UnsupportedEncodingException e) {
                throw new Error(e);
            }
        }
        //
        使用 StreamEncoder 对象做具体的写入工作
        public void write(int c) throws IOException {
            se.write(c);
        }
    }
    ```

- 适配器模式和装饰器模式区别

  - 装饰器模式更侧重于**动态增强原始类**的功能，（为了**嵌套**）**装饰器类需要跟原始类继承相同抽象类**/或**实现相同接口**。装饰器模式支持对原始类嵌套

  - 适配器模式侧重于**让接口不兼容而不能交互的类一起工作**，当调用适配器方法时，适配器**内部会调用适配者类或者和适配者类相关类**的方法，这个过程透明的。就比如说 `StreamDecoder` （流解码器）和`StreamEncoder`（流编码器）就是分别基于 `InputStream` 和 `OutputStream` 来获取 `FileChannel`对象并调用对应的 `read` 方法和 `write` 方法进行字节数据的读取和写入。

    ```java
    StreamDecoder(InputStream in, Object lock, CharsetDecoder dec) {
        // 省略大部分代码
      // 根据 InputStream 对象获取 FileChannel 对象
        ch = getChannel((FileInputStream)in);
    }
    ```
  
    - **适配器和适配者（注意，这里说的都是适配器模式）**两者**不需要继承相同抽象类**/**不需要实现相同接口**
  
  - FutureTask使用了适配器模式
    直接调用(构造器)
    
      ```java
    public FutureTask(Runnable runnable, V result) {
          // 调用 Executors 类的 callable 方法
          this.callable = Executors.callable(runnable, result);
          this.state = NEW;
    }
      ```
  
      间接：  
  
      ```java
    // 实际调用的是 Executors 的内部类 RunnableAdapter 的构造方法
      public static <T> Callable<T> callable(Runnable task, T result) {
          if (task == null)
              throw new NullPointerException();
          return new RunnableAdapter<T>(task, result);
      }
      // 适配器
      static final class RunnableAdapter<T> implements Callable<T> {
          final Runnable task;
          final T result;
          RunnableAdapter(Runnable task, T result) {
              this.task = task;
              this.result = result;
          }
          public T call() {
              task.run();
              return result;
          }
    }
      ```
    
      

## 工厂模式

NIO中大量出现，例如Files类的newInputStream，Paths类中的get方法，ZipFileSystem类中的getPath

```java 
InputStream is = Files.newInputStream(Paths.get(generatorLogoPath))
```

## 观察者模式

- 比如NIO中的文件目录**监听**服务
  该服务**基于WatchService接口**（观察者）和**Watchable接口**（被观察者）

- Watchable接口其中有一个register方法，用于将对象注册到WatchService（监控服务）并绑定监听事件的方法

- 例子

  ```java
  // 创建 WatchService 对象
  WatchService watchService = FileSystems.getDefault().newWatchService();
  
  // 初始化一个被监控文件夹的 Path 类:
  Path path = Paths.get("workingDirectory");
  // 将这个 path 对象注册到 WatchService（监控服务） 中去
  WatchKey watchKey = path.register(
  watchService, StandardWatchEventKinds...);
  ```

- 可以通过WatchKey对象获取事件具体信息

  ```java
  WatchKey key;
  while ((key = watchService.take()) != null) {
      for (WatchEvent<?> event : key.pollEvents()) {
        // 可以调用 WatchEvent 对象的方法做一些事情比如输出事件的具体上下文信息
      }
      key.reset();
  }
  ```

  完整的代码应该是如下  

  ```java
      @Test
      public void myTest() throws IOException, InterruptedException {
          // 创建 WatchService 对象
          WatchService watchService = FileSystems.getDefault().newWatchService();
  
  // 初始化一个被监控文件夹的 Path 类:
          Path path = Paths.get("F:\\java_test\\git\\hexo\\review_demo\\src\\com\\hp");
  // 将这个 path 对象注册到 WatchService（监控服务） 中去
          WatchKey key = path.register(
                  watchService, StandardWatchEventKinds.ENTRY_CREATE,StandardWatchEventKinds.ENTRY_DELETE
                  ,StandardWatchEventKinds.ENTRY_MODIFY);
  
          while ((key = watchService.take()) != null) {
              System.out.println("检测到了事件--start--");
              for (WatchEvent<?> event : key.pollEvents()) {
                  // 可以调用 WatchEvent 对象的方法做一些事情比如输出事件的具体上下文信息
                  System.out.println("event.kind().name()"+event.kind().name());
              }
              key.reset();
              System.out.println("检测到了事件--end--");
          }
  
      }
  ```

  

- 

  ```java
  public interface Path
      extends Comparable<Path>, Iterable<Path>, Watchable{
  }
  
  public interface Watchable {
      WatchKey register(WatchService watcher,
                        WatchEvent.Kind<?>[] events,
                        WatchEvent.Modifier... modifiers)
          throws IOException;
      //events，需要监听的事件，包括创建、删除、修改。
      @Override
      WatchKey register(WatchService watcher,
                        WatchEvent.Kind<?>... events)
          throws IOException;
  }
  ```

  其中events包括下面3种:  

  - `StandardWatchEventKinds.ENTRY_CREATE` ：文件创建。
  - `StandardWatchEventKinds.ENTRY_DELETE` : 文件删除。
  - `StandardWatchEventKinds.ENTRY_MODIFY` : 文件修改。

- WatchService内部通过一个daemon thread （守护线程），采用定期轮询的方式检测文件变化

  ```java
  class PollingWatchService
      extends AbstractWatchService
  {
      // 定义一个 daemon thread（守护线程）轮询检测文件变化
      private final ScheduledExecutorService scheduledExecutor;
  
      PollingWatchService() {
          scheduledExecutor = Executors
              .newSingleThreadScheduledExecutor(new ThreadFactory() {
                   @Override
                   public Thread newThread(Runnable r) {
                       Thread t = new Thread(r);
                       t.setDaemon(true);
                       return t;
                   }});
      }
  
    void enable(Set<? extends WatchEvent.Kind<?>> events, long period) {
      synchronized (this) {
        // 更新监听事件
        this.events = events;
  
          // 开启定期轮询
        Runnable thunk = new Runnable() { public void run() { poll(); }};
        this.poller = scheduledExecutor
          .scheduleAtFixedRate(thunk, period, period, TimeUnit.SECONDS);
      }
    }
  }
  ```

