---
title: spring 常见面试题总结
description: spring 常见面试题总结
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-framwork
date: 2023-02-07 16:48:03
updated: 2023-02-07 16:48:03
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

这篇文章主要是想通过一些问题，加深大家对于 Spring 的理解，所以不会涉及太多的代码！

下面的很多问题我自己在使用 Spring 的过程中也并没有注意，自己也是临时查阅了很多资料和书籍补上的。网上也有一些很多关于 Spring 常见问题/面试题整理的文章，我感觉大部分都是互相 copy，而且很多问题也不是很好，有些回答也存在问题。所以，自己花了一周的业余时间整理了一下，希望对大家有帮助。

## Spring 基础

### 什么是 Spring 框架?

Spring 是一款**开源**的**轻量级 Java 开发框架**，旨在提高开发人员的**开发效率**以及系统的**可维护性**。

我们一般说 Spring 框架指的都是 Spring Framework，它是很**多模块的集合**，使用这些模块可以很方便地协助我们进行开发，比如说 Spring 支持 **IoC**（**Inversion of Control:控制反转**） 和 **AOP**(**Aspect-Oriented Programming:面向切面编程**)、可以很方便地**对数据库进行访问**、可以很**方便地集成第三方组件**（**电子邮件**，**任务**，**调度**，缓存等等）、对**单元测试**支持比较好、支持 **RESTful Java 应用程序**的开发。

[![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f696d672d626c6f672e6373646e696d672e636e2f33386566313232313232646534333735616263643237633364653866363062342e706e67)

Spring 最核心的思想就是不重新造轮子，**开箱即用**，提高开发效率。

Spring 翻译过来就是春天的意思，可见其目标和使命就是为 Java 程序员带来春天啊！感动！

🤐 多提一嘴 ： **语言的流行通常需要一个杀手级的应用，Spring 就是 Java 生态的一个杀手级的应用框架。**

Spring 提供的核心功能主要是 **IoC** 和 **AOP**。学习 Spring ，一定要把 IoC 和 AOP 的核心思想搞懂！

- Spring 官网：https://spring.io/
- Github 地址： https://github.com/spring-projects/spring-framework

### Spring 包含的模块有哪些？

**Spring4.x 版本** ：

![image-20230207165448412](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230207165448412.png)

**Spring5.x 版本** ：

[![Spring5.x主要模块](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6769746875622f6a61766167756964652f73797374656d2d64657369676e2f6672616d65776f726b2f737072696e672f32303230303833313137353730382e706e67)](https://camo.githubusercontent.com/29c4744c19142975a5205c977bc6b322591549d3b80ca429655bc9cae073cc05/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6769746875622f6a61766167756964652f73797374656d2d64657369676e2f6672616d65776f726b2f737072696e672f32303230303833313137353730382e706e67)

Spring5.x 版本中 Web 模块的 Sertlet (**应该是Servlet 吧**)组件已经被废弃掉，同时增加了用于异步响应式处理的 WebFlux 组件。

Spring 各个模块的依赖关系如下： ![image-20230207165524155](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230207165524155.png)

#### Core Container

Spring 框架的核心模块，也可以说是**基础模块**，主要提供 **IoC 依赖注入**功能的支持。Spring 其他所有的功能基本都需要依赖于该模块，我们从上面那张 Spring 各个模块的依赖关系图就可以看出来。

- **spring-core** ：Spring 框架**基本的核心工具**类。
- **spring-beans** ：提供对 **bean 的创建**、**配置**和**管理**等功能的支持。
- **spring-context** ：提供对**国际化**、事件传播、资源加载等功能的支持。
- **spring-expression** ：提供对**表达式语言（Spring Expression Language） SpEL** 的支持，只依赖于 core 模块，不依赖于其他模块，可以单独使用。

#### AOP

- **spring-aspects** ：该模块为**与 AspectJ 的集成**提供支持。
- **spring-aop** ：提供了**面向切面**的编程实现。
- **spring-instrument** ：提供了为 JVM 添加代理（agent）的功能。 具体来讲，它为 Tomcat 提供了一个织入代理，能够为 Tomcat 传递类文 件，就像这些文件是被类加载器加载的一样。没有理解也没关系，这个模块的使用场景非常有限。

#### Data Access/Integration

- **spring-jdbc** ：提供了**对数据库访问的抽象 JDBC**。不同的数据库都有自己独立的 API 用于操作数据库，而 **Java 程序只需要和 JDBC API 交互**，这样就屏蔽了数据库的影响。
- **spring-tx** ：提供对**事务**的支持。
- **spring-orm** ： 提供对 **Hibernate**、**JPA** 、**iBatis** 等 ORM 框架的支持。
- **spring-oxm** ：提供一个抽象层支撑 OXM(Object-to-XML-Mapping)，例如：JAXB、Castor、XMLBeans、JiBX 和 XStream 等。
- **spring-jms** : **消息**服务。自 Spring Framework 4.1 以后，它还提供了对 spring-messaging 模块的继承。

#### Spring Web

- **spring-web** ：对 Web 功能的实现提供一些最基础的支持。
- **spring-webmvc** ： 提供对 **Spring MVC** 的实现。
- **spring-websocket** ： 提供了对 **WebSocket** 的支持，WebSocket 可以让客户端和服务端进行双向通信。
- **spring-webflux** ：提供对 WebFlux 的支持。WebFlux 是 Spring Framework 5.0 中引入的新的响应式框架。与 Spring MVC 不同，它不需要 Servlet API，是完全异步。

#### Messaging

**spring-messaging** 是从 Spring4.0 开始新加入的一个模块，主要职责是为 Spring 框架集成一些**基础的报文传送**应用。

#### Spring Test

Spring 团队提倡**测试驱动开发**（TDD）。有了控制反转 (IoC)的帮助，**单元测试**和**集成测试**变得更简单。

Spring 的测试模块对 JUnit（单元测试框架）、TestNG（类似 JUnit）、Mockito（主要用来 Mock 对象）、PowerMock（解决 Mockito 的问题比如无法模拟 final, static， private 方法）等等**常用的测试框架**支持的都比较好。

### Spring,Spring MVC,Spring Boot 之间什么关系?

很多人对 Spring,Spring MVC,Spring Boot 这三者傻傻分不清楚！这里简单介绍一下这三者，其实很简单，没有什么高深的东西。

Spring 包含了多个功能模块（上面刚刚提到过），其中最重要的是 **Spring-Core（主要提供 IoC 依赖注入功能的支持）** 模块， Spring 中的其他模块（比如 **Spring MVC**）的功能实现基本都需要依赖于该模块。

下图对应的是 Spring4.x 版本。目前最新的 5.x 版本中 Web 模块的 Portlet 组件已经被废弃掉，同时增加了用于异步响应式处理的 WebFlux 组件。

![Spring主要模块](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6769746875622f6a61766167756964652f6a766d65306336306234363036373131666334613062366661663033323330323437612e706e67) 

Spring MVC 是 Spring 中的一个很重要的模块，主要赋予 **Spring 快速构建 MVC 架构的 Web 程序的能力**。MVC 是**模型(Model)**、**视图(View)**、**控制器(Controller)**的简写，其核心思想是通过将**业务逻辑**、**数据**、**显示**分离来组织代码。

  

使用 Spring 进行开发各种**配置过于麻烦**比如开启某些 Spring 特性时，需要用 **XML** 或 **Java** 进行显式配置。于是，Spring Boot 诞生了！

Spring 旨在**简化 J2EE 企业应用程序**开发。Spring Boot 旨在**简化 Spring 开发**（**减少配置文件**，开箱即用！）。

Spring Boot 只是**简化了配置**，如果你需要构建 MVC 架构的 Web 程序，你**还是需要使用 Spring MVC** 作为 MVC 框架，只是说 Spring Boot 帮你**简化了 Spring MVC 的很多配置**，真正做到开箱即用！

## Spring IoC

### 谈谈自己对于 Spring IoC 的了解

**IoC（Inversion of Control:控制反转）** 是一种**设计**思想，而不是一个具体的技术实现。IoC 的思想就是将**原本在程序中手动创建对象**的控制权，**交由 Spring 框架**来管理。不过， IoC 并非 Spring 特有，在其他语言中也有应用。

**为什么叫控制反转？**

- **控制** ：指的是**对象创建（实例化、管理）的权力**
- **反转** ：**控制权交给外部环境**（**Spring 框架**、**IoC 容器**）

 ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6a6176612d67756964652d626c6f672f6672632d33363566616365623536393766303466333133393939333763303539633136322e706e67) 

将**对象之间的相互依赖关系交给 IoC 容器**来管理，并**由 IoC 容器完成对象的注入**。这样可以很大程度上**简化**应用的开发，把应用**从复杂的依赖关系中解放**出来。 IoC 容器就像是一个工厂一样，当我们需要创建一个对象的时候，只需要**配置好配置文件/注解**即可，完全**不用考虑**对象是**如何被创建**出来的。

在实际项目中一个 Service 类可能依赖了很多其他的类，假如我们需要实例化这个 Service，你可能要每次都要搞清这个 Service 所有底层类的构造函数，这可能会把人逼疯。如果利用 IoC 的话，你**只需要配置**好，然后**在需要的地方引用**就行了，这大大增加了项目的可维护性且降低了开发难度。

在 Spring 中， **IoC 容器**是 **Spring 用来实现 IoC 的载体**， IoC 容器**实际上就是个 Map（key，value）**，Map 中**存放的是各种对象**。

Spring 时代我们**一般通过 XML** 文件来**配置 Bean**，后来开发人员觉得 XML 文件来配置不太好，于是 **SpringBoot 注解配置**就慢慢开始流行起来。

相关阅读：

- [IoC 源码阅读](https://javadoop.com/post/spring-ioc)
- [面试被问了几百遍的 IoC 和 AOP ，还在傻傻搞不清楚？](https://mp.weixin.qq.com/s?__biz=Mzg2OTA0Njk0OA==&mid=2247486938&idx=1&sn=c99ef0233f39a5ffc1b98c81e02dfcd4&chksm=cea24211f9d5cb07fa901183ba4d96187820713a72387788408040822ffb2ed575d28e953ce7&token=1736772241&lang=zh_CN#rd)

### 什么是 Spring Bean？

简单来说，Bean 代指的就是**那些被 IoC 容器所管理的对象**。

我们需要告诉 IoC 容器帮助我们管理哪些对象，这个是**通过配置元数据**来定义的。配置元数据可以是 **XML 文件**、**注解**或者 **Java 配置类**。

```
<!-- Constructor-arg with 'value' attribute -->
<bean id="..." class="...">
   <constructor-arg value="..."/>
</bean>
```

下图简单地展示了 IoC 容器如何使用**配置元数据**来管理对象。

  

`org.springframework.beans`和 `org.springframework.context` 这两个包是 IoC 实现的基础，如果想要研究 IoC 相关的源码的话，可以去看看

### 将一个类声明为 Bean 的注解有哪些?

- `@Component` ：**通用**的注解，可标注任意类为 `Spring` 组件。如果一个 Bean 不知道属于哪个层，可以使用`@Component` 注解标注。
- `@Repository` : 对应持久层即 Dao 层，主要用于**数据库**相关操作。
- `@Service` : 对应服务层，主要**涉及一些复杂的逻辑**，需要用到 Dao 层。
- `@Controller` : 对应 **Spring MVC 控制层**，主要用户**接受用户请求**并**调用 Service 层返回数据**给前端页面。

### @Component 和 @Bean 的区别是什么？

- `@Component` 注解作用于**类**，而`@Bean`注解作用于**方法**。
- `@Component`通常是**通过类路径扫描**来**自动侦测**以及**自动装配到 Spring 容器**中（我们可以使用 **`@ComponentScan`** 注解**定义要扫描的路径**从中找出标识了需要装配的类自动装配到 Spring 的 bean 容器中）。`@Bean` 注解通常是我们在**标有该注解的方法中定义产生这个 bean**,`@Bean`**告诉了 Spring 这是某个类的实例**，当我需要用它的时候还给我。
- `@Bean` 注解比 `@Component` 注解的自定义性更强，而且**很多地方我们只能通过 `@Bean` 注解来注册 bean**。比如当我们**引用第三方库**中的类需要装配到 `Spring`容器时，则只能通过 `@Bean`来实现。

`@Bean`注解使用示例：

```
@Configuration
public class AppConfig {
    @Bean
    public TransferService transferService() {
        return new TransferServiceImpl();
    }

}
```

上面的代码相当于下面的 xml 配置

```
<beans>
    <bean id="transferService" class="com.acme.TransferServiceImpl"/>
</beans>
```

下面这个例子是通过 **`@Component` 无法实现**的。（**带有逻辑**）

```
@Bean
public OneService getService(status) {
    case (status)  {
        when 1:
                return new serviceImpl1();
        when 2:
                return new serviceImpl2();
        when 3:
                return new serviceImpl3();
    }
}
```

### 注入 Bean 的注解有哪些？

Spring 内置的 `@Autowired` 以及 JDK 内置的 `@Resource` 和 `@Inject` 都可以用于注入 Bean。

| Annotaion    | Package                            | Source       |
| ------------ | ---------------------------------- | ------------ |
| `@Autowired` | `org.springframework.bean.factory` | Spring 2.5+  |
| `@Resource`  | `javax.annotation`                 | Java JSR-250 |
| `@Inject`    | `javax.inject`                     | Java JSR-330 |

`@Autowired` 和`@Resource`使用的比较多一些。

### @Autowired 和 @Resource 的区别是什么？

`Autowired` 属于 Spring 内置的注解，默认的注入方式为`byType`（根据类型进行匹配），也就是说会优先根据接口类型去匹配并注入 Bean （接口的实现类）。

**这会有什么问题呢？** 当一个接口存在多个实现类的话，`byType`这种方式就无法正确注入对象了，因为这个时候 Spring 会同时找到多个满足条件的选择，默认情况下它自己不知道选择哪一个。

这种情况下，注入方式会变为 `byName`（根据名称进行匹配），这个名称通常就是类名（首字母小写）。就比如说下面代码中的 `smsService` 就是我这里所说的名称，这样应该比较好理解了吧。

```
// smsService 就是我们上面所说的名称
@Autowired
private SmsService smsService;
```

举个例子，`SmsService` 接口有两个实现类: `SmsServiceImpl1`和 `SmsServiceImpl2`，且它们都已经被 Spring 容器所管理。

```
// 报错，byName 和 byType 都无法匹配到 bean
@Autowired
private SmsService smsService;
// 正确注入 SmsServiceImpl1 对象对应的 bean
@Autowired
private SmsService smsServiceImpl1;
// 正确注入  SmsServiceImpl1 对象对应的 bean
// smsServiceImpl1 就是我们上面所说的名称
@Autowired
@Qualifier(value = "smsServiceImpl1")
private SmsService smsService;
```

我们还是**建议通过 `@Qualifier` 注解来显式指定名称**而**不是依赖变量的名称**。

**`@Resource`属于 JDK 提供的注解**，默认注入方式为 `byName`。如果无法通过名称匹配到对应的 Bean 的话，注入方式会变为`byType`。

`@Resource` 有两个比较重要且日常开发常用的属性：`name`（名称）、`type`（类型）。

```
public @interface Resource {
    String name() default "";
    Class<?> type() default Object.class;
}
```

如果仅指定 `name` 属性则注入方式为`byName`，如果仅指定`type`属性则注入方式为`byType`，如果同时指定`name` 和`type`属性（不建议这么做）则注入方式为`byType`+`byName`。

```
// 报错，byName 和 byType 都无法匹配到 bean
@Resource
private SmsService smsService;
// 正确注入 SmsServiceImpl1 对象对应的 bean
@Resource
private SmsService smsServiceImpl1;
// 正确注入 SmsServiceImpl1 对象对应的 bean（比较推荐这种方式）
@Resource(name = "smsServiceImpl1")
private SmsService smsService;
```

简单总结一下：

- `@Autowired` 是 Spring 提供的注解，`@Resource` 是 JDK 提供的注解。
- `Autowired` **默认**的注入方式为**`byType`（根据类型进行匹配）**，`@Resource`**默认**注入方式为 **`byName`（根据名称进行匹配）**。
- 当一个接口存在多个实现类的情况下，`@Autowired` 和`@Resource`都**需要通过名称**才能正确匹配到对应的 Bean。**`Autowired` 可以通过 `@Qualifier` 注解来显式指定名称**，**`@Resource`可以通过 `name` 属性来显式指定名称**。

### Bean 的作用域有哪些?

Spring 中 Bean 的作用域通常有下面几种：

- **singleton** : IoC 容器中只有**唯一**的 bean 实例。Spring 中的 bean 默认都是单例的，是对单例设计模式的应用。
- **prototype** : **每次获取都会创建一个新的** bean 实例。也就是说，连续 `getBean()` 两次，得到的是不同的 Bean 实例。
- **request** （仅 Web 应用可用）: **每一次 HTTP 请求**都会产生一个新的 bean（请求 bean），该 bean 仅在当前 HTTP request 内有效。
- **session** （仅 Web 应用可用） : **每一次来自新 session 的 HTTP 请求**都会产生一个新的 bean（会话 bean），该 bean 仅在当前 HTTP session 内有效。
- **application/global-session** （仅 Web 应用可用）： **每个 Web 应用在启动时**创建一个 Bean（应用 Bean），该 bean 仅在当前应用启动时间内有效。
- **websocket** （仅 Web 应用可用）：**每一次 WebSocket 会话**产生一个新的 bean。

**如何配置 bean 的作用域呢？**

xml 方式：

```
<bean id="..." class="..." scope="singleton"></bean>
```

注解方式：

```
@Bean
@Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public Person personPrototype() {
    return new Person();
}
```

### 单例 Bean 的线程安全问题了解吗？

大部分时候我们并没有在项目中使用多线程，所以很少有人会关注这个问题。单例 Bean 存在线程问题，主要是因为当**多个线程操作同一个对象**的时候是存在资源竞争的。

常见的有两种解决办法：

1. 在 Bean 中**尽量避免定义可变的成员变量**。
2. 在类中定义一个 **`ThreadLocal` 成员变量**，将需要的可变成员变量保存在 `ThreadLocal` 中（推荐的一种方式）。

不过，**大部分 Bean 实际都是无状态**（**没有实例变量**）的（比如 Dao、Service），这种情况下， Bean 是**线程安全**的。

### Bean 的生命周期了解么?

> 下面的内容整理自：https://yemengying.com/2016/07/14/spring-bean-life-cycle/ ，除了这篇文章，再推荐一篇很不错的文章 ：https://www.cnblogs.com/zrtqsk/p/3735273.html 。

- Bean 容器**找到配置文件**中 Spring Bean 的**定义**。
- Bean 容器**利用 Java Reflection API** 创建一个 Bean 的实例。【**反射**】
- 如果涉及到一些属性值 **利用 `set()`方法设置**一些属性值。

> ```aware 英[əˈweə(r)] adj. 意识到的,发觉,发现```

- 如果 Bean 实现了 **`BeanNameAware`** 接口，调用 `setBeanName()`方法，传入 **Bean 的名字**。
- 如果 Bean 实现了 **`BeanClassLoaderAware`** 接口，调用 `setBeanClassLoader()`方法，传入 **`ClassLoader`对象的实例**。
- 如果 Bean 实现了 **`BeanFactoryAware`** 接口，调用 `setBeanFactory()`方法，传入 **`BeanFactory`对象的实例**。
- 与上面的类似，如果实现了其他 `*.Aware`接口，就调用相应的方法。
- 如果有和加载这个 Bean 的 Spring 容器相关的 **`BeanPostProcessor`** 对象，执行`postProcessBeforeInitialization()` 方法
- 如果 Bean 实现了**`InitializingBean`**接口，执行**`afterPropertiesSet()`**方法。
- 如果 Bean 在配置文件中的定义包含 **init-method** 属性，执行指定的方法。
- 如果有和加载这个 Bean 的 Spring 容器相关的 **`BeanPostProcessor`** 对象，执行`postProcessAfterInitialization()` 方法
- 当要销毁 Bean 的时候，如果 Bean 实现了 **`DisposableBean`** 接口，执行 **`destroy()`** 方法。
- 当要销毁 Bean 的时候，如果 Bean 在配置文件中的定义包含 **destroy-method** 属性，执行指定的方法。

图示：

[![Spring Bean 生命周期](https://camo.githubusercontent.com/70ba44111686c9f9a4fcac62d8ae01fd23e3e707d91fbce4af1205856dcd458f/68747470733a2f2f696d616765732e7869616f7a6875616e6c616e2e636f6d2f70686f746f2f323031392f32346263326261643363653238313434643630643965306132656466366337662e6a7067)](https://camo.githubusercontent.com/70ba44111686c9f9a4fcac62d8ae01fd23e3e707d91fbce4af1205856dcd458f/68747470733a2f2f696d616765732e7869616f7a6875616e6c616e2e636f6d2f70686f746f2f323031392f32346263326261643363653238313434643630643965306132656466366337662e6a7067)

与之比较类似的中文版本:

[![Spring Bean 生命周期](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f696d616765732e7869616f7a6875616e6c616e2e636f6d2f70686f746f2f323031392f62356432363435363536353761353339356332373831303831613734383365312e6a7067)](https://camo.githubusercontent.com/9efd4a1a6c11ebb15c61a022e93bb20934a85a72d95194cf59402421c09191a9/68747470733a2f2f696d616765732e7869616f7a6875616e6c616e2e636f6d2f70686f746f2f323031392f62356432363435363536353761353339356332373831303831613734383365312e6a7067)

## Spring AoP

### 谈谈自己对于 AOP 的了解

> ```aspect  英[ˈæspekt] 方位 n.``` 
>
> ```oriented  英[ˈɔːrientɪd] 朝向 v.```

AOP(**Aspect-Oriented Programming:面向切面编程**)能够将那些与业务无关，却为业务模块所**共同调用**的逻辑或责任（例如**事务处理**、**日志管理**、**权限控制**等）封装起来，便于**减少系统的重复代码**，降低模块间的耦合度，并有利于未来的可拓展性和可维护性。

Spring AOP 就是**基于动态代理**的，如果要代理的对象，实现了某个接口，那么 Spring AOP 会使用 **JDK Proxy**，去**创建代理对象**，而对于没有实现接口的对象，就无法使用 JDK Proxy 去进行代理了，这时候 Spring AOP 会使用 **Cglib** 生成一个**被代理对象的子类**来作为代理，如下图所示：

  ![image-20230208093647267](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230208093647267.png)

当然你也可以使用 **AspectJ** ！Spring AOP 已经集成了 AspectJ ，**AspectJ** 应该算的上是 **Java 生态系统中最完整的 AOP 框架**了。

AOP 切面编程设计到的一些专业术语：

| 术语              | 含义                                                         |
| ----------------- | ------------------------------------------------------------ |
| 目标(**Target**)  | **被通知的对象**                                             |
| 代理(**Proxy**)   | 向目标对象应用通知之后创建的**代理对象**                     |
| 连接点(JoinPoint) | **目标对象的所属类**中，定义的**所有方法**均为连接点         |
| 切入点(Pointcut)  | 被切面拦截 / 增强的连接点（**切入点一定是连接点，连接点不一定是切入点**） |
| 通知(Advice)      | 增强的**逻辑** / **代码**，也即拦截到目标对象的连接点之后要做的事情 |
| 切面(Aspect)      | **切入点(Pointcut)+通知(Advice)**                            |
| Weaving(织入)     | 将**通知应用**到目标对象，进而生成代理对象的**过程动作**     |

### Spring AOP 和 AspectJ AOP 有什么区别？

**Spring AOP 属于运行时增强，而 AspectJ 是编译时增强。** Spring AOP 基于**代理**(Proxying)，而 AspectJ 基于**字节码**操作(Bytecode Manipulation)。

Spring AOP 已经集成了 AspectJ ，AspectJ 应该算的上是 Java 生态系统中最完整的 AOP 框架了。AspectJ 相比于 Spring AOP 功能更加强大，但是 Spring AOP 相对来说更简单，

如果我们的切面比较少，那么两者性能差异不大。但是，当**切面太多**的话，最好选择 **AspectJ** ，它比 Spring AOP 快很多。

### AspectJ 定义的通知类型有哪些？

- **Before**（前置通知）：目标对象的方法调用之前触发
- **After** （后置通知）：目标对象的方法调用之后触发
- **AfterReturning**（返回通知）：目标对象的方法调用完成，在返回结果值之后触发
- **AfterThrowing**（异常通知） ：目标对象的方法运行中抛出 / 触发异常后触发。AfterReturning 和 AfterThrowing 两者互斥。如果方法调用成功无异常，则会有返回值；如果方法抛出了异常，则不会有返回值。
- **Around** （环绕通知）：编程式控制目标对象的方法调用。环绕通知是所有通知类型中可操作范围最大的一种，因为它可以直接拿到目标对象，以及要执行的方法，所以环绕通知可以任意的在目标对象的方法调用前后搞事，甚至不调用目标对象的方法

### 多个切面的执行顺序如何控制？

1、通常使用**`@Order` 注解**直接定义切面顺序

```
// 值越小优先级越高
@Order(3)
@Component
@Aspect
public class LoggingAspect implements Ordered {
```

**2、实现`Ordered` 接口重写 `getOrder` 方法。**

```
@Component
@Aspect
public class LoggingAspect implements Ordered {

    // ....

    @Override
    public int getOrder() {
        // 返回值越小优先级越高
        return 1;
    }
}
```

## Spring MVC

### 说说自己对于 Spring MVC 了解?

MVC 是**模型(Model)**、**视图(View)**、**控制器(Controller)**的简写，其核心思想是通过将**业务逻辑**、**数据**、**显示**分离来组织代码。

 ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6a6176612d67756964652d626c6f672f696d6167652d32303231303830393138313435323432312e706e67) 

网上有很多人说 MVC 不是设计模式，只是软件设计规范，我个人更倾向于 **MVC 同样是众多设计模式中的一种**。**[java-design-patterns](https://github.com/iluwatar/java-design-patterns)** 项目中就有关于 MVC 的相关介绍。

 ![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f696d672d626c6f672e6373646e696d672e636e2f31353962336433653730646434356536616661383162663036643039323634652e706e67) 

想要真正理解 Spring MVC，我们先来看看 Model 1 和 Model 2 这两个没有 Spring MVC 的时代。

**Model 1 时代**

很多学 Java 后端比较晚的朋友可能并没有接触过 Model 1 时代下的 JavaWeb 应用开发。在 Model1 模式下，整个 Web 应用几**乎全部用 JSP 页面**组成，**只用少量的 JavaBean** 来**处理数据库连接**、**访问**等操作。

这个模式下 **JSP** 即是**控制层（Controller）**又是**表现层（View）**。显而易见，这种模式存在很多问题。比如**控制逻辑**和**表现逻辑**混杂在一起，导致代码重用率极低；再比如前端和后端相互依赖，难以进行测试维护并且开发效率极低。

  

**Model 2 时代**

学过 Servlet 并做过相关 Demo 的朋友应该了解“**Java Bean(Model)**+ **JSP（View）**+**Servlet（Controller）** ”这种开发模式，这就是早期的 JavaWeb MVC 开发模式。

- Model:系统涉及的数据，也就是 **dao** 和 **bean**。
- View：**展示模型中的数据**，只是用来展示。
- Controller：**处理用户请求**都发送给 **Servlet**，返回数据给 JSP 并展示给用户。

[![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6a6176612d67756964652d626c6f672f6d76632d6d6f64656c322e706e67)](https://camo.githubusercontent.com/b36a90d56dae552146126cf76f8de218f5d545d9df9d65a7eb84283157f46475/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6a6176612d67756964652d626c6f672f6d76632d6d6f64656c322e706e67)

Model2 模式下还存在很多问题，**Model2 的抽象**和**封装程度**还远远不够，使用 Model2 进行开发时不可避免地会**重复造轮子**，这就大大降低了程序的**可维护性**和**复用性**。

于是，很多 JavaWeb 开发相关的 MVC 框架应运而生比如 **Struts2**，但是 Struts2 比较笨重。

**Spring MVC 时代**

随着 Spring 轻量级开发框架的流行，Spring 生态圈出现了 Spring MVC 框架， Spring MVC 是当前最优秀的 MVC 框架。相比于 Struts2 ， Spring MVC 使用更加简单和方便，开发效率更高，并且 Spring MVC 运行速度更快。

MVC 是一种设计模式，Spring MVC 是一款很优秀的 MVC 框架。Spring MVC 可以帮助我们进行更简洁的 Web 层的开发，并且它天生与 Spring 框架集成。Spring MVC 下我们一般把后端项目分为 **Service 层（处理业务）**、**Dao 层（数据库操作）**、**Entity 层（实体类）**、**Controller 层(控制层**，返回数据给前台页面)。

### Spring MVC 的核心组件有哪些？

记住了下面这些组件，也就记住了 SpringMVC 的工作原理。

- **`DispatcherServlet`** ：**核心的中央处理器**，负责接收请求、分发，并给予客户端响应。
- **`HandlerMapping`** ：**处理器映射器**，根据 uri 去匹配查找能处理的 `Handler` ，并会将请求涉及到的拦截器和 `Handler` 一起封装。
- **`HandlerAdapter`** ：**处理器适配器**，根据 `HandlerMapping` 找到的 `Handler` ，适配执行对应的 `Handler`；
- **`Handler`** ：**请求处理器**，处理实际请求的处理器。
- **`ViewResolver`** ：**视图解析器**，根据 `Handler` 返回的逻辑视图 / 视图，解析并渲染真正的视图，并传递给 `DispatcherServlet` 响应客户端

### SpringMVC 工作原理了解吗?

**Spring MVC 原理如下图所示：**

> SpringMVC 工作原理的图解我没有自己画，直接图省事在网上找了一个非常清晰直观的，原出处不明。

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f696d672d626c6f672e6373646e696d672e636e2f696d675f636f6e766572742f64653664326232313366313132323937323938663365323233626630386632382e706e67) 

**流程说明（重要）：**

1. 客户端（浏览器）发送请求， **`DispatcherServlet`拦截**请求。
2. `DispatcherServlet` 根据请求信息调用 **`HandlerMapping`** 。**`HandlerMapping` 根据 uri 去匹配**查找能处理的 `Handler`（也就是我们平常说的 `Controller` 控制器） ，并会将请求涉及到的拦截器和 `Handler` 一起封装。
3. `DispatcherServlet` 调用 **`HandlerAdapter`**适配执行 `Handler` 。
4. `Handler` 完成对用户请求的处理后，会**返回一个 `ModelAndView`** 对象给`DispatcherServlet`，`ModelAndView` 顾名思义，包含了**数据模型**以及**相应的视图的信息**。`Model` 是返回的数据对象，`View` 是个逻辑上的 `View`。
5. `ViewResolver` 会**根据逻辑 `View` 查找实际的 `View`**。
6. `DispaterServlet` 把**返回的 `Model` 传给 `View`（视图渲染**）。
7. 把 **`View` 返回**给请求者（浏览器）

### 统一异常处理怎么做？

推荐使用注解的方式统一异常处理，具体会使用到 `@ControllerAdvice` + `@ExceptionHandler` 这两个注解 。

```
@ControllerAdvice
@ResponseBody
public class GlobalExceptionHandler {

    @ExceptionHandler(BaseException.class)
    public ResponseEntity<?> handleAppException(BaseException ex, HttpServletRequest request) {
      //......
    }

    @ExceptionHandler(value = ResourceNotFoundException.class)
    public ResponseEntity<ErrorReponse> handleResourceNotFoundException(ResourceNotFoundException ex, HttpServletRequest request) {
      //......
    }
}
```

这种异常处理方式下，会给**所有**或者**指定**的 `Controller` **织入异常处理的逻辑**（AOP），当 `Controller` 中的方法抛出异常的时候，由被`@ExceptionHandler` 注解修饰的方法进行处理。

`ExceptionHandlerMethodResolver` 中 `getMappedMethod` 方法**决定了异常具体被哪个**被 `@ExceptionHandler` 注解修饰的方法处理异常。【**这个是框架里的源码，不是自己写的**】

```
@Nullable
	private Method getMappedMethod(Class<? extends Throwable> exceptionType) {
		List<Class<? extends Throwable>> matches = new ArrayList<>();
    //找到可以处理的所有异常信息。mappedMethods 中存放了异常和处理异常的方法的对应关系
		for (Class<? extends Throwable> mappedException : this.mappedMethods.keySet()) {
			if (mappedException.isAssignableFrom(exceptionType)) {
				matches.add(mappedException);
			}
		}
    // 不为空说明有方法处理异常
		if (!matches.isEmpty()) {
      // 按照匹配程度从小到大排序
			matches.sort(new ExceptionDepthComparator(exceptionType));
      // 返回处理异常的方法
			return this.mappedMethods.get(matches.get(0));
		}
		else {
			return null;
		}
	}
```

从源代码看出： **`getMappedMethod()`会首先找到可以匹配处理异常的所有方法信息，然后对其进行从小到大的排序，最后取最小的那一个匹配的方法(即匹配度最高的那个)。**

## Spring 框架中用到了哪些设计模式？

> 关于下面这些设计模式的详细介绍，可以看我写的 [Spring 中的设计模式详解](https://javaguide.cn/system-design/framework/spring/spring-design-patterns-summary.html) 这篇文章。

- **工厂设计模式** : Spring 使用工厂模式通过 **`BeanFactory`**、**`ApplicationContext`** 创建 bean 对象。
- **代理设计模式** : Spring **AOP** 功能的实现。
- **单例设计模式** : Spring 中的 **Bean 默认都是单例**的。
- **模板方法模式** : Spring 中 **`jdbcTemplate`**、**`hibernateTemplate`** 等以 Template 结尾的对数据库操作的类，它们就使用到了模板模式。
- **包装器设计模式** : 我们的项目需要连接多个数据库，而且不同的客户在每次访问中根据需要会去访问不同的数据库。这种模式让我们可以根据客户的需求能够**动态切换不同的数据源**。
- **观察者模式:** Spring **事件驱动**模型就是**观察者模式**很经典的一个应用。
- **适配器模式** : Spring AOP 的**增强或通知(Advice)**使用到了适配器模式、spring MVC 中也是用到了适配器模式**适配`Controller`**。
- ......

## Spring 事务

关于 Spring 事务的详细介绍，可以看我写的 [Spring 事务详解](https://javaguide.cn/system-design/framework/spring/spring-transaction.html) 这篇文章。

### Spring 管理事务的方式有几种？

- **编程式事务** ： 在代码中硬编码(不推荐使用) : 通过 **`TransactionTemplate`**或者 **`TransactionManager`** **手动管理**事务，实际应用中很少使用，但是对于你理解 Spring 事务管理原理有帮助。
- **声明式事务** ： 在 **XML 配置文件中配置**或者**直接基于注解**（推荐使用） : 实际是通过 AOP 实现（基于`@**Transactional`** 的全注解方式使用最多）

### Spring事务失效的几种情况（非javaguide）

#### 1.spring事务实现方式及原理

Spring 事务的本质其实就是数据库对事务的支持，没有数据库的事务支持，spring 是无法提供事务功能的。真正的数据库层的事务提交和回滚是在binlog提交之后进行提交的 通过 redo log 来重做， undo log来回滚。

一般我们在程序里面使用的都是在方法上面加`@Transactional ` 注解，这种属于**声明式事务**。

**声明式事务本质是通过 AOP 功能**，**对方法前后进行拦截**，将事务处理的功能**编织**到拦截的**方法中**，也就是**在目标方法开始之前加入一个事务**，在**执行完目标方法之后根据执行情况提交**或者**回滚**事务。

#### 2.数据库本身不支持事务

这里以 MySQL 为例，其 MyISAM 引擎是不支持事务操作的，InnoDB 才是支持事务的引擎，一般要支持事务都会使用 InnoDB

#### 3.当前类的调用

```java
@Service
public class UserServiceImpl implements UserService {

    public void update(User user) {
        updateUser(user);
    }
    
    @Transactional(rollbackFor = Exception.class)
    public void updateUser(User user) {
        // update user
    }
    
}
复制代码
```

上面的这种情况下是不会有事务管理操作的。

通过看声明式事务的原理可知，spring使用的是AOP切面的方式，本质上使用的是动态代理来达到事务管理的目的，当前类调用的方法上面加`@Transactional` 这个是没有任何作用的，因为调用这个方法的是`this`.

OK， 我们在看下面的一种例子。

```java
@Service
public class UserServiceImpl implements UserService {

    @Transactional(rollbackFor = Exception.class)
    public void update(User user) {
        updateUser(user);
    }
    
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void updateUser(User user) {
        // update user
    }
    
}
复制代码
```

这次在 update 方法上加了 `@Transactional`，updateUser 加了 `REQUIRES_NEW` 新开启一个事务，那么新开的事务管用么？

答案是：不管用！

因为它们**发生了自身调用**，就**调该类自己的方法**，而**没有经过 Spring 的代理类**，默认**只有在外部调用事务才会生效**，这也是老生常谈的经典问题了。

#### 4.方法不是public的

```java
@Service
public class UserServiceImpl implements UserService {

    @Transactional(rollbackFor = Exception.class)
    private void updateUser(User user) {
        // update user
    }
    
}
复制代码
```

**`private` 方法是不会被spring代理**的，因此是不会有事务产生的，这种做法是无效的。

#### 5.没有被spring管理

```java
//@Service
public class UserServiceImpl implements UserService {

    @Transactional(rollbackFor = Exception.class)
    public void updateUser(User user) {
        // update user
    }
    
}
复制代码
```

没有被spring管理的bean， spring连代理对象都无法生成，当然无效咯。

#### 6.配置的事务传播性有问题

```java
@Service
public class UserServiceImpl implements UserService {

    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void update(User user) {
        // update user
    }    
}
复制代码
```

回顾一下spring的事务传播行为

Spring 事务的传播行为说的是，当多个事务同时存在的时候， Spring 如何处理这些事务的行为。

1. PROPAGATION_REQUIRED：如果当前没有事务，就创建一个新事务，如果当前存在事务，就加入该事务，该设置是最常用的设置。
2. PROPAGATION_SUPPORTS：支持当前事务，如果当前存在事务，就加入该事务，如果当前不存在事务，就以非事务执行
3. PROPAGATION_MANDATORY：支持当前事务，如果当前存在事务，就加入该事务，如果当前不存在事务，就抛出异常。
4. PROPAGATION_REQUIRES_NEW：创建新事务，无论当前存不存在事务，都创建新事务。
5. PROPAGATION_NOT_SUPPORTED：以非事务方式执行操作，如果当前存在事务，就把当前事务挂起。
6. PROPAGATION_NEVER： 以非事务方式执行，如果当前存在事务，则抛出异常。
7. PROPAGATION_NESTED：如果当前存在事务，则在嵌套事务内执行。如果当前没有事务，则按 REQUIRED 属性执行

当传播行为设置了PROPAGATION_NOT_SUPPORTED，PROPAGATION_NEVER，PROPAGATION_SUPPORTS这三种时，就有可能存在事务不生效

#### 7.异常被你 "抓住"了

```java
@Service
public class UserServiceImpl implements UserService {

    @Transactional(rollbackFor = Exception.class)
    public void update(User user) {
        
      try{
        // update user
      }catch(Execption e){
         log.error("异常",e)
      }
    }    
}
复制代码
```

异常被抓了，这样子代理类就没办法知道你到底有没有错误，需不需要回滚，所以这种情况也是没办法回滚的哦。

#### 8.接口层声明式事务使用cglib代理

> 注意，这是个前后关系，说的是：如果在接口层使用了**声明式事务**，结果用的是cglib代理，那么事务就不会生效

```java
public interface UserService   {

    @Transactional(rollbackFor = Exception.class)
    public void update(User user)  
}
复制代码
@Service
public class UserServiceImpl implements UserService {

    
    public void update(User user) {
        // update user
    }    
}
复制代码
```

通过元素的 "proxy-target-class" 属性值来控制是基于接口的还是基于类的代理被创建。如果 "proxy-target-class" 属值被设置为 "true"，那么**基于类的代理**将起作用（这时需要CGLIB库cglib.jar在CLASSPATH中）。如果 "proxy-target-class" 属值被设置为 "false" 或者这个属性被省略，那么**标准的JDK基于接口**的代理将起作用

注解@Transactional cglib与java动态代理最大区别是**代理目标对象不用实现接口**,那么注解要是写到接口方法上，要是使用cglib代理，这时注解事务就失效了，为了保持兼容注解最好**都写到实现类方法**上。

#### 9.rollbackFor异常指定错误

```java
@Service
public class UserServiceImpl implements UserService {

    @Transactional
    public void update(User user) {
        // update user
    }    
}
复制代码
```

上面这种没有指定回滚异常，这个时候默认的回滚异常是`RuntimeException` ，如果出现其他异常那么就不会回滚事务 

### Spring 事务中哪几种事务传播行为?

**事务传播行为是为了解决业务层方法之间互相调用的事务问题**。

当事务方法被另一个事务方法调用时，必须指定事务应该如何传播。例如：方法可能继续在现有事务中运行，也可能开启一个新事务，并在自己的事务中运行。  

> 注意几点，下面这个值都是**内方法**上的注解的值，且两个方法必须属于不同类  
>
> ```java
> @Service
> public class MyClassServiceImpl extends ServiceImpl<MyClassMapper, MyClass> implements MyClassService {
>     @Autowired
>     private UserService userService;
> 
>     //外方法 
>     @Override
>     public void methodOuter() throws Exception {
>         //新增一条记录
>         MyClass myClass=new MyClass();
>         myClass.setName("class_name");
>         this.saveOrUpdate(myClass);
> 
>         //调用内方法
>         userService.methodInner();
>         //抛出异常
>         //throw new Exception("hello");
>     }
> }
> ```
>
> ```java
> @Service
> public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
> 
>     //内方法
>     @Transactional(
>             rollbackFor = Exception.class
>             ,propagation = Propagation.REQUIRED
>     )
>     @Override
>     public void methodInner() throws Exception {
>         //新增一条记录
>         User user = new User();
>         user.setName("outer_name");
>         this.saveOrUpdate(user);
>         //抛出异常
>         //throw new Exception("hello");
>     }
> }
> ```

正确的事务传播行为可能的值如下:  

> 注：**如果外方法不存在事务，则内外方法完全独立，自己(方法内)抛异常不影响另一方法**

**1.`TransactionDefinition.PROPAGATION_REQUIRED`**

使用的最多的一个事务传播行为，我们平时经常使用的`@Transactional`注解**默认**使用就是这个事务传播行为。如果当前存在事务，则加入该事务；如果当前没有事务，则创建一个新的事务。  

> 如果外方法存在事务，则不论 外方法或内方法抛出异常，都会导致外内所在事务（同一个）回滚

**`2.TransactionDefinition.PROPAGATION_REQUIRES_NEW`**

创建一个新的事务，如果当前存在事务，则把当前事务挂起。也就是说不管外部方法是否开启事务，`Propagation.REQUIRES_NEW`修饰的内部方法会新开启自己的事务，且开启的事务相互独立，互不干扰。  

> 如果外方法存在事务，如果仅内方法抛异常，会导致外方法回滚；如果仅外方法抛异常，则不会回滚内方法

**3.`TransactionDefinition.PROPAGATION_NESTED`**

如果当前存在事务，则创建一个事务作为当前事务的嵌套事务来运行；如果当前没有事务，则该取值等价于`TransactionDefinition.PROPAGATION_REQUIRED`。  

> 如果外方法存在事务，**（效果和1一样）**， 不论 外方法或内方法抛出异常，都会导致外内所在事务（**和1唯一不同的是，他们是不同事务**）回滚
>

**4.`TransactionDefinition.PROPAGATION_MANDATORY`**

如果当前存在事务，则加入该事务；如果当前没有事务，则抛出异常。（mandatory：强制性）

这个使用的很少。    

> 如果外方法存在事务，**（效果和1一样）**， 不论 外方法或内方法抛出异常，都会导致外内所在事务（**和1唯一不同的是，如果外方法不存在事务，调用该方法前就直接抛异常**）回滚

若是错误的配置以下 3 种事务传播行为，事务将不会发生回滚：

- **`TransactionDefinition.PROPAGATION_SUPPORTS`**: 如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
- **`TransactionDefinition.PROPAGATION_NOT_SUPPORTED`**: 以非事务方式运行，如果当前存在事务，则把当前事务挂起。
- **`TransactionDefinition.PROPAGATION_NEVER`**: 以非事务方式运行，如果当前存在事务，则抛出异常。

### Spring 事务中的隔离级别有哪几种?

和事务传播行为这块一样，为了方便使用，Spring 也相应地定义了一个枚举类：`Isolation`

```
public enum Isolation {

    DEFAULT(TransactionDefinition.ISOLATION_DEFAULT),

    READ_UNCOMMITTED(TransactionDefinition.ISOLATION_READ_UNCOMMITTED),

    READ_COMMITTED(TransactionDefinition.ISOLATION_READ_COMMITTED),

    REPEATABLE_READ(TransactionDefinition.ISOLATION_REPEATABLE_READ),

    SERIALIZABLE(TransactionDefinition.ISOLATION_SERIALIZABLE);

    private final int value;

    Isolation(int value) {
        this.value = value;
    }

    public int value() {
        return this.value;
    }

}
```

下面我依次对每一种事务隔离级别进行介绍：

- **`TransactionDefinition.ISOLATION_DEFAULT`** :使用后端数据库默认的隔离级别，MySQL 默认采用的 `REPEATABLE_READ` 隔离级别 Oracle 默认采用的 `READ_COMMITTED` 隔离级别.
- **`TransactionDefinition.ISOLATION_READ_UNCOMMITTED`** :最低的隔离级别，使用这个隔离级别很少，因为它允许读取尚未提交的数据变更，**可能会导致脏读、幻读或不可重复读**
- **`TransactionDefinition.ISOLATION_READ_COMMITTED`** : 允许读取并发事务已经提交的数据，**可以阻止脏读，但是幻读或不可重复读仍有可能发生**
- **`TransactionDefinition.ISOLATION_REPEATABLE_READ`** : 对同一字段的多次读取结果都是一致的，除非数据是被本身事务自己所修改，**可以阻止脏读和不可重复读，但幻读仍有可能发生。**
- **`TransactionDefinition.ISOLATION_SERIALIZABLE`** : 最高的隔离级别，完全服从 ACID 的隔离级别。所有的事务依次逐个执行，这样事务之间就完全不可能产生干扰，也就是说，**该级别可以防止脏读、不可重复读以及幻读**。但是这将严重影响程序的性能。通常情况下也不会用到该级别。

### @Transactional(rollbackFor = Exception.class)注解了解吗？

`Exception` 分为运行时异常 `RuntimeException` 和非运行时异常。事务管理对于企业应用来说是至关重要的，即使出现异常情况，它也可以保证数据的一致性。

当 `@Transactional` 注解作用于类上时，该类的所有 public 方法将都具有该类型的事务属性，同时，我们也可以在方法级别使用该标注来覆盖类级别的定义。如果类或者方法加了这个注解，那么这个类里面的方法抛出异常，就会回滚，数据库里面的数据也会回滚。

在 `@Transactional` 注解中如果不配置`rollbackFor`属性,那么事务只会在遇到`RuntimeException`的时候才会回滚，加上 `rollbackFor=Exception.class`,可以让事务在遇到非运行时异常时也回滚。

## Spring Data JPA

JPA 重要的是实战，这里仅对小部分知识点进行总结。

### 如何使用 JPA 在数据库中非持久化一个字段？

假如我们有下面一个类：

```
@Entity(name="USER")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "ID")
    private Long id;

    @Column(name="USER_NAME")
    private String userName;

    @Column(name="PASSWORD")
    private String password;

    private String secrect;

}
```

如果我们想让`secrect` 这个字段不被持久化，也就是不被数据库存储怎么办？我们可以采用下面几种方法：

```
static String transient1; // not persistent because of static
final String transient2 = "Satish"; // not persistent because of final
transient String transient3; // not persistent because of transient
@Transient
String transient4; // not persistent because of @Transient
```

一般使用后面两种方式比较多，我个人使用注解的方式比较多。

### JPA 的审计功能是做什么的？有什么用？

审计功能主要是帮助我们记录数据库操作的具体行为比如某条记录是谁创建的、什么时间创建的、最后修改人是谁、最后修改时间是什么时候。

```
@Data
@AllArgsConstructor
@NoArgsConstructor
@MappedSuperclass
@EntityListeners(value = AuditingEntityListener.class)
public abstract class AbstractAuditBase {

    @CreatedDate
    @Column(updatable = false)
    @JsonIgnore
    private Instant createdAt;

    @LastModifiedDate
    @JsonIgnore
    private Instant updatedAt;

    @CreatedBy
    @Column(updatable = false)
    @JsonIgnore
    private String createdBy;

    @LastModifiedBy
    @JsonIgnore
    private String updatedBy;
}
```

- `@CreatedDate`: 表示该字段为创建时间字段，在这个实体被 insert 的时候，会设置值

- `@CreatedBy` :表示该字段为创建人，在这个实体被 insert 的时候，会设置值

  `@LastModifiedDate`、`@LastModifiedBy`同理。

### 实体之间的关联关系注解有哪些？

- `@OneToOne ` : 一对一。
- `@ManyToMany` ：多对多。
- `@OneToMany` : 一对多。
- `@ManyToOne` ：多对一。

利用 `@ManyToOne` 和 `@OneToMany` 也可以表达多对多的关联关系。

## Spring Security

Spring Security 重要的是实战，这里仅对小部分知识点进行总结。

### 有哪些控制请求访问权限的方法？

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6769746875622f6a61766167756964652f73797374656d2d64657369676e2f6672616d65776f726b2f737072696e672f696d6167652d32303232303732383230313835343634312e706e67) 

- `permitAll()` ：无条件允许任何形式访问，不管你登录还是没有登录。
- `anonymous()` ：允许匿名访问，也就是没有登录才可以访问。
- `denyAll()` ：无条件决绝任何形式的访问。
- `authenticated()`：只允许已认证的用户访问。
- `fullyAuthenticated()` ：只允许已经登录或者通过 remember-me 登录的用户访问。
- `hasRole(String)` : 只允许指定的角色访问。
- `hasAnyRole(String)	` : 指定一个或者多个角色，满足其一的用户即可访问。
- `hasAuthority(String)` ：只允许具有指定权限的用户访问
- `hasAnyAuthority(String)` ：指定一个或者多个权限，满足其一的用户即可访问。
- `hasIpAddress(String)` : 只允许指定 ip 的用户访问。

### hasRole 和 hasAuthority 有区别吗？

可以看看松哥的这篇文章：[Spring Security 中的 hasRole 和 hasAuthority 有区别吗？](https://mp.weixin.qq.com/s/GTNOa2k9_n_H0w24upClRw)，介绍的比较详细。

### 如何对密码进行加密？

如果我们需要保存密码这类敏感数据到数据库的话，需要先加密再保存。

Spring Security 提供了多种加密算法的实现，开箱即用，非常方便。这些加密算法实现类的父类是 `PasswordEncoder` ，如果你想要自己实现一个加密算法的话，也需要继承 `PasswordEncoder`。

`PasswordEncoder` 接口一共也就 3 个必须实现的方法。

```
public interface PasswordEncoder {
    // 加密也就是对原始密码进行编码
    String encode(CharSequence var1);
    // 比对原始密码和数据库中保存的密码
    boolean matches(CharSequence var1, String var2);
    // 判断加密密码是否需要再次进行加密，默认返回 false
    default boolean upgradeEncoding(String encodedPassword) {
        return false;
    }
}
```

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/68747470733a2f2f67756964652d626c6f672d696d616765732e6f73732d636e2d7368656e7a68656e2e616c6979756e63732e636f6d2f6769746875622f6a61766167756964652f73797374656d2d64657369676e2f6672616d65776f726b2f737072696e672f696d6167652d32303232303732383138333534303935342e706e67)

官方推荐使用基于 bcrypt 强哈希函数的加密算法实现类。

### 如何优雅更换系统使用的加密算法？

如果我们在开发过程中，突然发现现有的加密算法无法满足我们的需求，需要更换成另外一个加密算法，这个时候应该怎么办呢？

推荐的做法是通过 `DelegatingPasswordEncoder` 兼容多种不同的密码加密方案，以适应不同的业务需求。

从名字也能看出来，`DelegatingPasswordEncoder` 其实就是一个代理类，并非是一种全新的加密算法，它做的事情就是代理上面提到的加密算法实现类。在 Spring Security 5.0之后，默认就是基于 `DelegatingPasswordEncoder` 进行密码加密的。

## 参考

- 《Spring 技术内幕》
- 《从零开始深入学习 Spring》：https://juejin.cn/book/6857911863016390663
- http://www.cnblogs.com/wmyskxz/p/8820371.html
- https://www.journaldev.com/2696/spring-interview-questions-and-answers
- https://www.edureka.co/blog/interview-questions/spring-interview-questions/
- https://www.cnblogs.com/clwydjgs/p/9317849.html
- https://howtodoinjava.com/interview-questions/top-spring-interview-questions-with-answers/
- http://www.tomaszezula.com/2014/02/09/spring-series-part-5-component-vs-bean/
- https://stackoverflow.com/questions/34172888/difference-between-bean-and-autowired