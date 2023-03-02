---
title:  java-reflex
description: java-reflex
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 11:27:04
updated: 2022-10-10 11:27:04

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

### 何为反射

赋予了我们在**运行时分析类**以及**执行类中方法**的能力；运行中**获取任意一个类的所有属性**和**方法**，以及**调用这些方法**和**属性**

### 应用场景

Spring/Spring Boot 、MyBatis等框架都用了大量反射机制，以下为

- JDK动态代理

  - 接口及实现类 

      ```java
          package proxy;

          public interface Car {

              public void run();
          }
          //实现类
          package proxy;

          public class CarImpl implements Car{

              public void run() {
                  System.out.println("car running");
              }

          }
      ```

  - 代理类 及main方法使用
  ```[ˌɪnvəˈkeɪʃn] 祈祷```
    
    ```java
    package proxy;
    
      import java.lang.reflect.InvocationHandler;
      import java.lang.reflect.Method;
      //JDK动态代理代理类 
      public class CarHandler implements InvocationHandler{
          //真实类的对象
          private Object car;
          //构造方法赋值给真实的类
          public CarHandler(Object obj){
              this.car = obj;
          }
      //代理类执行方法时，调用的是这个方法
          public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
              System.out.println("before");
              Object res = method.invoke(car, args);
              System.out.println("after");
              return res;
          }
      }
      //main方法使用
    package proxy;
    
    import java.lang.reflect.Proxy;
    
    public class main {
    
          public static void main(String[] args) {
              CarImpl carImpl = new CarImpl();
              CarHandler carHandler = new CarHandler(carImpl);
              Car proxy = (Car)Proxy.newProxyInstance(
                      main.class.getClassLoader(), //第一个参数，获取ClassLoader
                      carImpl.getClass().getInterfaces(), //第二个参数，获取被代理类的接口
                      carHandler);//第三个参数，一个InvocationHandler对象，表示的是当我这个动态代理对象在调用方法的时候，会关联到哪一个InvocationHandler对象上
              proxy.run();
          }
      }
    //输出
    before
    car running
    after
    ```

- Cglib动态代理（没有实现接口的Car

  - 类  

    ```java
    package proxy;
    
    public class CarNoInterface {
    
        public void run() {
            System.out.println("car running");
        }
    }
    ```

  - cglib代理类
    ```[ˌɪntəˈseptə(r)]  interceptor 拦截```

    ```java
    package proxy;
    
    import java.lang.reflect.Method;
    
    import org.springframework.cglib.proxy.Enhancer;
    import org.springframework.cglib.proxy.MethodInterceptor;
    import org.springframework.cglib.proxy.MethodProxy;
    
    public class CglibProxy implements MethodInterceptor{
    
        private Object car;
        
        /** 
         * 创建代理对象 
         *  
         * @param target 
         * @return 
         */  
        public Object getInstance(Object object) {  
            this.car = object;  
            Enhancer enhancer = new Enhancer();  
            enhancer.setSuperclass(this.car.getClass());  
            // 回调方法  
            enhancer.setCallback(this);  
            // 创建代理对象  
            return enhancer.create();  
        }  
        
        @Override
        public Object intercept(Object obj, Method method, Object[] args,MethodProxy proxy) throws Throwable {
            System.out.println("事物开始");  
            proxy.invokeSuper(obj, args);  
            System.out.println("事物结束");  
            return null;  
        }
    
    }
    ```

  - 使用  

    ```java
    package proxy;
    
    import java.lang.reflect.Proxy;
    
    public class main {
    
        public static void main(String[] args) {    
            CglibProxy cglibProxy = new CglibProxy();
            CarNoInterface carNoInterface = (CarNoInterface)cglibProxy.getInstance(new CarNoInterface());
            carNoInterface.run();
        }
    }
    //输出
    事物开始
    car running
    事物结束
    ```

- 我们可以**基于反射分析**类，然后**获取到类/属性/方法/方法参数**上的注解，之后做进一步的处理

- 反射机制的优缺点

  - 优点  
    让代码更加灵活
  - 确定，增加安全问题，可以无视泛型参数的安全检查（泛型参数的安全检查发生在编译时，且性能较差）

- 反射实战

  - 获取Class对象的几种方式

    ```java
    Class alunbarClass = TargetObject.class;//第一种
    Class alunbarClass1 = Class.forName("cn.javaguide.TargetObject");//第二种
    TargetObject o = new TargetObject();
    Class alunbarClass2 = o.getClass(); //第三种
    ClassLoader.getSystemClassLoader().loadClass("cn.javaguide.TargetObject"); //第4种，通过类加载器获取Class对象不会进行初始化，意味着不进行包括初始化等一系列操作，静态代码块和静态对象不会得到执行
    ```

  - 反射的基本操作
    例子：

    ```java
    package cn.javaguide;
    
    public class TargetObject {
        private String value;
    
        public TargetObject() {
            value = "JavaGuide";
        }
    
        public void publicMethod(String s) {
            System.out.println("I love " + s);
        }
    
        private void privateMethod() {
            System.out.println("value is " + value);
        }
    }
    ```

  - 通过反射操作这个类的方法以及参数

    ```java
    package cn.javaguide;
    
    import java.lang.reflect.Field;
    import java.lang.reflect.InvocationTargetException;
    import java.lang.reflect.Method;
    
    public class Main {
        public static void main(String[] args) throws ClassNotFoundException, NoSuchMethodException, IllegalAccessException, InstantiationException, InvocationTargetException, NoSuchFieldException {
            /**
             * 获取 TargetObject 类的 Class 对象并且创建 TargetObject 类实例
             */
            Class<?> targetClass = Class.forName("cn.javaguide.TargetObject");
            TargetObject targetObject = (TargetObject) targetClass.newInstance();
            /**
             (Car)Proxy.newProxyInstance(
                      main.class.getClassLoader(), //第一个参数，获取ClassLoader
                      carImpl.getClass().getInterfaces(), //第二个参数，获取被代理类的接口
                      carHandler);
            **/
            /**
             * 获取 TargetObject 类中定义的所有方法
             */
            Method[] methods = targetClass.getDeclaredMethods();
            for (Method method : methods) {
                System.out.println(method.getName());
            }
    
            /**
             * 获取指定方法并调用
             */
            Method publicMethod = targetClass.getDeclaredMethod("publicMethod",
                    String.class);
    
            publicMethod.invoke(targetObject, "JavaGuide");
    
            /**
             * 获取指定参数并对参数进行修改
             */
            Field field = targetClass.getDeclaredField("value");
            //为了对类中的参数进行修改我们取消安全检查
            field.setAccessible(true);
            field.set(targetObject, "JavaGuide");
    
            /**
             * 调用 private 方法
             */
            Method privateMethod = targetClass.getDeclaredMethod("privateMethod");
            //为了调用private方法我们取消安全检查
            privateMethod.setAccessible(true);
            privateMethod.invoke(targetObject);
        }
    }
  //输出
    publicMethod
    privateMethod
    I love JavaGuide
    value is JavaGuide
    ```
  
  - 

