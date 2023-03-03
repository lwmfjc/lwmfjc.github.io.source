---
title:  Java代理模式
description: proxy_pattern
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 14:30:02
updated: 2022-10-10 14:30:02

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

### 代理模式

使用代理对象来代替对真实对象的访问，就可以在**不修改原目标对象的前提下提供额外的功能操作**，**扩展目标对象的功能**，即在目标对象的**某个方法执行前后可以增加一些自定义的操作**

### 静态代理

> **静态代理中，我们对目标对象的每个方法的增强都是手动完成的（\*后面会具体演示代码\*），非常不灵活（\*比如接口一旦新增加方法，目标对象和代理对象都要进行修改\*）且麻烦(\*需要对每个目标类都单独写一个代理类\*）。** 实际应用场景非常非常少，日常开发几乎看不到使用静态代理的场景。
>
> 上面我们是从实现和应用角度来说的静态代理，从 JVM 层面来说， **静态代理在编译时就将接口、实现类、代理类这些都变成了一个个实际的 class 文件。**

1. 定义一个接口及其实现类；
2. 创建一个代理类同样实现这个接口
3. 将目标对象注入进代理类，然后在代理类的对应方法调用目标类中的对应方法。这样的话，我们就可以通过代理类屏蔽对目标对象的访问，并且可以在目标方法执行前后做一些自己想做的事情。

代码:  

```java
//定义发送短信的接口
public interface SmsService {
    String send(String message);
}
//实现发送短信的接口
public class SmsServiceImpl implements SmsService {
    public String send(String message) {
        System.out.println("send message:" + message);
        return message;
    }
}
//创建代理类并同样实现发送短信的接口
public class SmsProxy implements SmsService {

    private final SmsService smsService;

    public SmsProxy(SmsService smsService) {
        this.smsService = smsService;
    }

    @Override
    public String send(String message) {
        //调用方法之前，我们可以添加自己的操作
        System.out.println("before method send()");
        smsService.send(message);
        //调用方法之后，我们同样可以添加自己的操作
        System.out.println("after method send()");
        return null;
    }
}
//实际使用
public class Main {
    public static void main(String[] args) {
        SmsService smsService = new SmsServiceImpl();
        SmsProxy smsProxy = new SmsProxy(smsService);
        smsProxy.send("java");
    }
}
//打印结果
before method send()
send message:java
after method send()
```

### 动态代理

从JVM角度来说，动态代理是在**运行时动态生成类字节码**，并**加载到JVM中的**。  SpringAOP和RPC等框架都实现了动态代理

#### JDK动态代理

```java
//定义并发送短信的接口
public interface SmsService {
    String send(String message);
}
public class SmsServiceImpl implements SmsService {
    public String send(String message) {
        System.out.println("send message:" + message);
        return message;
    }
}
//JDK动态代理类
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * @author shuang.kou
 * @createTime 2020年05月11日 11:23:00
 */
public class DebugInvocationHandler implements InvocationHandler {
    /**
     * 代理类中的真实对象
     */
    private final Object target;

    public DebugInvocationHandler(Object target) {
        this.target = target;
    }、


    public Object invoke(Object proxy, Method method, Object[] args) throws InvocationTargetException, IllegalAccessException {
        //调用方法之前，我们可以添加自己的操作
        System.out.println("before method " + method.getName());
        Object result = method.invoke(target, args);
        //调用方法之后，我们同样可以添加自己的操作
        System.out.println("after method " + method.getName());
        return result;
    }
}

```

当我们的动态代理对象调用原方法时，实际上调用的invoke()，然后invoke代替我们调用了被代理对象的原生方法

```java
//工厂类及实际使用
public class JdkProxyFactory {
    public static Object getProxy(Object target) {
        return Proxy.newProxyInstance(
                target.getClass().getClassLoader(), // 目标类的类加载器
                target.getClass().getInterfaces(),  // 代理需要实现的接口，可指定多个
                new DebugInvocationHandler(target)   // 代理对象对应的自定义 InvocationHandler
        );
    }
}
//实际使用
SmsService smsService = (SmsService) JdkProxyFactory.getProxy(new SmsServiceImpl());
smsService.send("java");
//输出
before method send
send message:java
after method send
```



#### CGLIB动态代理机制

JDK动态代理问题：只能代理实现了接口的类Spring 的AOP中，如果使用了接口，则使用JDK动态代理；否则采用CGLB

继承

核心是Enhancer类及MethodInterceptor接口

```java
public interface MethodInterceptor
extends Callback{
    // 拦截被代理类中的方法
    public Object intercept(Object obj, java.lang.reflect.Method method, Object[] args,MethodProxy proxy) throws Throwable;
}
```

对象，被拦截方法，参数，调用原始方法

- 实例

  ```java
  //定义一个类，及方法拦截器
  package github.javaguide.dynamicProxy.cglibDynamicProxy;
  
  public class AliSmsSer
      pvice {
      public String send(String message) {
          System.out.println("send message:" + message);
          return message;
      }
  }
  //MethodInterceptor （方法拦截器）
  import net.sf.cglib.proxy.MethodInterceptor;
  import net.sf.cglib.proxy.MethodProxy;
  
  import java.lang.reflect.Method;
  
  /**
   * 自定义MethodInterceptor
   */
  public class DebugMethodInterceptor implements MethodInterceptor {
  
  
      /**
       * @param o           代理对象（增强的对象）
       * @param method      被拦截的方法（需要增强的方法）
       * @param args        方法入参
       * @param methodProxy 用于调用原始方法
       */
      @Override
      public Object intercept(Object o, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
          //调用方法之前，我们可以添加自己的操作
          System.out.println("before method " + method.getName());
          Object object = methodProxy.invokeSuper(o, args);
          //调用方法之后，我们同样可以添加自己的操作
          System.out.println("after method " + method.getName());
          return object;
      }
  
  }
  ```
```java
 // 获取代理类 
  import net.sf.cglib.proxy.Enhancer;
  
  public class CglibProxyFactory {
  
      public static Object getProxy(Class<?> clazz) {
          // 创建动态代理增强类
          Enhancer enhancer = new Enhancer();
          // 设置类加载器
          enhancer.setClassLoader(clazz.getClassLoader());
          // 设置被代理类
          enhancer.setSuperclass(clazz);
          // 设置方法拦截器
          enhancer.setCallback(new DebugMethodInterceptor());
          // 创建代理类
          return enhancer.create();
      }
  }
  //实际使用
  AliSmsService aliSmsService = (AliSmsService) CglibProxyFactory.getProxy(AliSmsService.class);
  aliSmsService.send("java");
```


### 对比

1. 灵活性：动态代理更为灵活，且**不需要实现接口**，可以**直接代理实现类**，并且不需要针对每个对象都创建代理类；一旦添加方法，动态代理类不需要修改；
2. JVM层面：**静态代理在编译时就将接口、实现类变成实际的class文件**，而动态代理是在**运行时生成动态类字节码**，并**加载到JVM**中