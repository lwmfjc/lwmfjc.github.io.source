---
title:  java_spi
description: java_spi
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-12 10:12:52
updated: 2022-10-12 10:12:52

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

### 简介

为了实现在**模块装配**的时候**不用再程序里面动态指明**，这就需要一种**服务发现**机制。JavaSPI就是提供了这样的一个机制：**为某个接口寻找服务实现**的机制。有点类似IoC的思想，将装配的控制权交到了程序之外

### SPI介绍

SPI，ServiceProviderInterface
使用SPI：Spring框架、数据库加载驱动、日志接口、以及Dubbo的扩展实现

![image-20221012105156504](images/mypost/image-20221012105156504.png)

感觉下面这个图不太对，被调用方应该
一般**模块之间**都是**通过接口**进行通讯，

> 当**实现方**提供了**接口和实现**，我们可以通过**调用实现方的接口**从而拥有**实现方给我们提供的能力**，这就是 API ，这种**接口和实现**都是放在实现方的。
>
> 当接口存在于**调用方**这边时，就是 SPI ，由接口调用方确定接口规则，然后由不同的厂商去根据这个规则对这个接口进行实现，从而提供服务。[**可以理解成业务方，或者说使用方。它使用了这个接口，而且制定了接口规范，但是具体实现，由被调用方实现**]
>
> 我的理解：被调用方（提供接口的人），调用方（使用接口的人），但是其实这里只把调用方-->使用接口的人 这个关系是对的。
>
> 也就是说，正常情况下由被调用方自己提供接口和实现，即API。而现在，由调用方（这里的调用方其实可以理解成上面的被调用方），提供了接口还使用了接口，而由被调用方进行接口实现

### 实战演示

SLF4J只是一个日志门面（接口），但是SLF4J的具体实现可以有多种，如：Logback/Log4j/Log4j2等等

![image-20221012160549090](images/mypost/image-20221012160549090.png)

#### 简易版本

- ServiceProviderInterface

- 目录结构

  ```
  │  service-provider-interface.iml
  │
  ├─.idea
  │  │  .gitignore
  │  │  misc.xml
  │  │  modules.xml
  │  └─ workspace.xml
  │
  └─src
      └─edu
          └─jiangxuan
              └─up
                  └─spi
                          Logger.java
                          LoggerService.java
                          Main.class
  ```

  - Logger接口，即SPI 服务提供者接口，后面的服务提供者要针对这个接口进行实现

    ```java
    package edu.jiangxuan.up.spi;
    
    public interface Logger {
        void info(String msg);
        void debug(String msg);
    }
    
    ```

  - LoggerService类，主要是为服务使用者（调用方）提供特定功能，这个类是实现JavaSPI机制的关键所在

    ```java
    package edu.jiangxuan.up.spi;
    
    import java.util.ArrayList;
    import java.util.List;
    import java.util.ServiceLoader;
    
    public class LoggerService {
        private static final LoggerService SERVICE = new LoggerService();
    
        private final Logger logger;
    
        private final List<Logger> loggerList;
    
        private LoggerService() {
            ServiceLoader<Logger> loader = ServiceLoader.load(Logger.class);
            List<Logger> list = new ArrayList<>();
            for (Logger log : loader) {
                list.add(log);
            }
            // LoggerList 是所有 ServiceProvider
            loggerList = list;
            if (!list.isEmpty()) {
                // Logger 只取一个
                logger = list.get(0);
            } else {
                logger = null;
            }
        }
    
        //简单单例
        public static LoggerService getService() {
            return SERVICE;
        }
    
        public void info(String msg) {
            if (logger == null) {
                System.out.println("info 中没有发现 Logger 服务提供者");
            } else {
                logger.info(msg);
            }
        }
    
        public void debug(String msg) {
            if (loggerList.isEmpty()) {
                System.out.println("debug 中没有发现 Logger 服务提供者");
            }
            loggerList.forEach(log -> log.debug(msg));
        }
    }
    ```

  - Main类（服务使用者，调用方）

    ```java
    package org.spi.service;
    
    public class Main {
        public static void main(String[] args) {
            LoggerService service = LoggerService.getService();
    
            service.info("Hello SPI");
            service.debug("Hello SPI");
        }
    }
    /**
     结果
    info 中没有发现 Logger 服务提供者 debug 中没有发现 Logger 服务提供者
    
    
    */
    ```

- 新的项目，来实现Logger接口  
  项目结构

  ```java
  │  service-provider.iml
  │
  ├─.idea
  │  │  .gitignore
  │  │  misc.xml
  │  │  modules.xml
  │  └─ workspace.xml
  │
  ├─lib
  │      service-provider-interface.jar
  |
  └─src
      ├─edu
      │  └─jiangxuan
      │      └─up
      │          └─spi
      │              └─service
      │                      Logback.java
      │
      └─META-INF
          └─services
                  edu.jiangxuan.up.spi.Logger
  ```

  - 首先需要有一个实现类

    ```java
    package edu.jiangxuan.up.spi.service;
    
    import edu.jiangxuan.up.spi.Logger;
    
    public class Logback implements Logger {
        @Override
        public void info(String s) {
            System.out.println("Logback info 打印日志：" + s);
        }
    
        @Override
        public void debug(String s) {
            System.out.println("Logback debug 打印日志：" + s);
        }
    }
    ```

  - 将之前项目打包的jar导入项目中

  - 之后要`src` 目录下新建 `META-INF/services` 文件夹，然后新建文件 `edu.jiangxuan.up.spi.Logger` （SPI 的全类名，接口名），文件里面的内容是：`edu.jiangxuan.up.spi.service.Logback` （Logback 的全类名，即 SPI 的**实现类**的包名 + 类名）

- **这是 JDK SPI 机制 ServiceLoader 约定好的标准。**

  > Java 中的 SPI 机制就是在**每次类加载的时候**会先去找到 **class 相对目录下的 `META-INF` 文件夹下的 services 文件夹下的文件**，将这个文件夹下面的所有文件先加载到内存中，然后**根据这些文件的文件名**和里面的**文件内容**找到相应接口的具体实现类，找到实现类后就可以**通过反射去生成对应的对象**，保存在一个 list 列表里面，所以可以通过迭代或者遍历的方式拿到对应的实例对象，生成不同的实现。
  >
  > 即：文件名一定要是接口的全类名，然后里面的内容一定要是实现类的全类名，实现类可以有多个，直接换行就好了，多个实现类的时候，会一个一个的迭代加载。

  - 接下来同样将 `service-provider` 项目打包成 jar 包，这个 jar 包就是服务提供方的实现。通常我们导入 maven 的 pom 依赖就有点类似这种，只不过我们现在没有将这个 jar 包发布到 maven 公共仓库中，所以在需要使用的地方只能手动的添加到项目中

- 效果展示
  ![image-20221012171251890](images/mypost/image-20221012171251890.png)

  ```java
  package edu.jiangxuan.up.service;
  
  import edu.jiangxuan.up.spi.LoggerService;
  
  public class TestJavaSPI {
      public static void main(String[] args) {
          LoggerService loggerService = LoggerService.getService();
          loggerService.info("你好");
          loggerService.debug("测试Java SPI 机制");
      }
  }
  ```

- 通过使用 SPI 机制，可以看出服务（`LoggerService`）和 服务提供者两者之间的耦合度非常低，如果说我们想要换一种实现，那么其实只需要修改 `service-provider` 项目中针对 `Logger` 接口的具体实现就可以了，只需要换一个 jar 包即可，也可以有在一个项目里面有多个实现，这不就是 SLF4J 原理吗？

### ServiceLoader

JDK 官方给的注释：**一种加载服务实现的工具。**

#### 具体实现

#### 自己实现

//个人简易版

```java
package edu.jiangxuan.up.service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Constructor;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;

public class MyServiceLoader<S> {

    // 对应的接口 Class 模板
    private final Class<S> service;

    // 对应实现类的 可以有多个，用 List 进行封装
    private final List<S> providers = new ArrayList<>();

    // 类加载器
    private final ClassLoader classLoader;

    // 暴露给外部使用的方法，通过调用这个方法可以开始加载自己定制的实现流程。
    public static <S> MyServiceLoader<S> load(Class<S> service) {
        return new MyServiceLoader<>(service);
    }

    // 构造方法私有化
    private MyServiceLoader(Class<S> service) {
        this.service = service;
        this.classLoader = Thread.currentThread().getContextClassLoader();
        doLoad();
    }

    // 关键方法，加载具体实现类的逻辑
    private void doLoad() {
        try {
            // 读取所有 jar 包里面 META-INF/services 包下面的文件，这个文件名就是接口名，然后文件里面的内容就是具体的实现类的路径加全类名
            Enumeration<URL> urls = classLoader.getResources("META-INF/services/" + service.getName());
            // 挨个遍历取到的文件
            while (urls.hasMoreElements()) {
                // 取出当前的文件
                URL url = urls.nextElement();
                System.out.println("File = " + url.getPath());
                // 建立链接
                URLConnection urlConnection = url.openConnection();
                urlConnection.setUseCaches(false);
                // 获取文件输入流
                InputStream inputStream = urlConnection.getInputStream();
                // 从文件输入流获取缓存
                BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
                // 从文件内容里面得到实现类的全类名
                String className = bufferedReader.readLine();

                while (className != null) {
                    // ★★【重点】  通过反射拿到实现类的实例
                    Class<?> clazz = Class.forName(className, false, classLoader);
                    // 如果声明的接口跟这个具体的实现类是属于同一类型，（可以理解为Java的一种多态，接口跟实现类、父类和子类等等这种关系。）则构造实例
                    if (service.isAssignableFrom(clazz)) {
                        Constructor<? extends S> constructor = (Constructor<? extends S>) clazz.getConstructor();
                        S instance = constructor.newInstance();
                        // 把当前构造的实例对象添加到 Provider的列表里面
                        providers.add(instance);
                    }
                    // 继续读取下一行的实现类，可以有多个实现类，只需要换行就可以了。
                    className = bufferedReader.readLine();
                }
            }
        } catch (Exception e) {
            System.out.println("读取文件异常。。。");
        }
    }

    // 返回spi接口对应的具体实现类列表
    public List<S> getProviders() {
        return providers;
    }
}
```

基本流程：  

```
通过 URL 工具类从 jar 包的 /META-INF/services 目录下面找到对应的文件，
读取这个文件的名称找到对应的 spi 接口，
通过 InputStream 流将文件里面的具体实现类的全类名读取出来，
根据获取到的全类名，先判断跟 spi 接口是否为同一类型，如果是的，那么就通过反射的机制构造对应的实例对象，
将构造出来的实例对象添加到 Providers 的列表中。
```



