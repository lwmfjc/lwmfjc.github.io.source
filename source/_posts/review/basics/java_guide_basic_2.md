---
title: javaGuide基础2
description: javaGuide基础2
categories:
  - 学习
tags:
  - 复习
  - 复习-SSM
date: 2022-09-29 10:16:13
updated: 2022-09-29 10:16:13
---

## 面向对象基础

- 区别 

  - 面向过程把解决问题的过程拆成一个个方法，通过一个个方法的执行解决问题。
  - 面向对象会先抽象出对象，然后用对象执行方法的方式解决问题。
  - 面向对象编程 易维护、易复用、易扩展

- 对象实体与对象引用的不同new 运算符，new 创建对象实例（对象实例在堆内存中），对象引用指向对象实例（对象引用存放在栈内存中）。

  一个对象引用可以指向 0 个或 1 个对象（一根绳子可以不系气球，也可以系一个气球）;一个对象可以有 n 个引用指向它（可以用 n 条绳子系住一个气球）。

- 对象的相等一般比较的是内存中存放的内容是否相等；引用相等一般比较的是他们指向的内存地址是否相等

- 关于构造方法：如果我们自己添加了类的构造方法（无论是否有参），Java 就不会再添加默认的无参数的构造方法了

  - 构造方法特点：名字与类名相同；没有返回值但不能用void生命构造函数；生成类的对象时自动执行
  - 构造方法不能重写override，但能重载 overload
  
- 面向对象三大特征

  - 封装  
    把一个对象的状态信息(属性)隐藏在对象内部，但提供可以被外界访问的方法来操作属性

    ```java
    public class Student {
        private int id;//id属性私有化
        private String name;//name属性私有化
    
        //获取id的方法
        public int getId() {
            return id;
        }
    
        //设置id的方法
        public void setId(int id) {
            this.id = id;
        }
    
        //获取name的方法
        public String getName() {
            return name;
        }
    
        //设置name的方法
        public void setName(String name) {
            this.name = name;
        }
    }
    ```

  - 继承  
    不通类型的对象，相互之间有一定数量的共同点，同时每个对象定义了额外的特性使得他们与众不同。继承是使用已存在的类的定义作为基础建立新类的技术

    - 父类中的私有属性和方法子类无法访问，只是拥有
    - 子类可以拥有自己的属性、方法，即对父类进行拓展
    - 子类可以用自己的方式实现父类的方法（重写）

  - 多态

    - 对象类型和引用类型之间具有继承(类)/实现(接口)的关系
    - 引用类型变量发出的方法具体调用哪个类的方法，只有程序运行期间才能确定
    - 多态不能调用“只在子类存在而父类不存在”的方法
    - 如果子类重写了父类的方法，真正执行的是子类覆盖的方法，如果子类没有覆盖父类的方法，执行的是父类的方法

- 接口和抽象类有什么共同点和区别

  - 共同：都不能被实例化；都可以包含抽象方法；都可以有默认实现的方法。
  - 区别
    - 接口主要用于对类的行为进行约束；抽象类主要用于代码复用（强调所属）
    - 类只能继承一个类，但能实现多个接口
    - 接口中的成员只能是```public static final```不能被修改且具有初始值；而抽象类的成员变量默认default ，可在子类重新定义或重新赋值
  
- 深拷贝和浅拷贝的区别？什么是引用拷贝

  - 深拷贝：浅拷贝会在堆上创建新对象，但是如果原对象内部的属性是引用类型的话，浅拷贝会复制内部对象的引用地址，即拷贝对象和原对象共用一个内部对象

  - 浅拷贝，会完全复制整个对象，包括对象内包含的内部对象

  - 例子

    - 浅拷贝

      ```java
      public class Address implements Cloneable{
          private String name;
          // 省略构造函数、Getter&Setter方法
          @Override
          public Address clone() {
              try {
                  return (Address) super.clone();
              } catch (CloneNotSupportedException e) {
                  throw new AssertionError();
              }
          }
      }
      
      public class Person implements Cloneable {
          private Address address;
          // 省略构造函数、Getter&Setter方法
          @Override
          public Person clone() {
              try {
                  Person person = (Person) super.clone();
                  return person;
              } catch (CloneNotSupportedException e) {
                  throw new AssertionError();
              }
          }
      }
      //------------------测试--------------------
      Person person1 = new Person(new Address("武汉"));
      Person person1Copy = person1.clone();
      // true
      System.out.println(person1.getAddress() == person1Copy.getAddress());
      ```

    - 深拷贝

      ```java
      //修改了Person类的clone()方法进行修改
      @Override
      public Person clone() {
          try {
              Person person = (Person) super.clone();
              person.setAddress(person.getAddress().clone());
              return person;
          } catch (CloneNotSupportedException e) {
              throw new AssertionError();
          }
      }
      //--------------测试-------
      Person person1 = new Person(new Address("武汉"));
      Person person1Copy = person1.clone();
      // false
      System.out.println(person1.getAddress() == person1Copy.getAddress());
      ```

  - 引用拷贝，即两个不同的引用指向同一个对象

  - 如图  
    ![image-20221006140951954](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221006140951954.png)

## Java常见类

- 