---
title: Flowable-04-spring
description: '04-spring'
categories:
  - 学习
tags:
  - 'flowable官方'
date: 2022-04-29 14:57:32
updated: 2022-04-29 14:57:32
---

### ProcessEngineFactoryBean

- 将ProcessEngine配置为常规的SpringBean

  ```xml
  <bean id="processEngineConfiguration" class="org.flowable.spring.SpringProcessEngineConfiguration">
      ...
  </bean>
  
  <bean id="processEngine" class="org.flowable.spring.ProcessEngineFactoryBean">
    <property name="processEngineConfiguration" ref="processEngineConfiguration" />
  </bean>
  ```

- 使用transaction

  ```xml
  <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:context="http://www.springframework.org/schema/context"
         xmlns:tx="http://www.springframework.org/schema/tx"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.springframework.org/schema/beans
                               http://www.springframework.org/schema/beans/spring-beans.xsd
                             http://www.springframework.org/schema/context
                               http://www.springframework.org/schema/context/spring-context-2.5.xsd
                             http://www.springframework.org/schema/tx
                               http://www.springframework.org/schema/tx/spring-tx-3.0.xsd">
  
    <bean id="dataSource" class="org.springframework.jdbc.datasource.SimpleDriverDataSource">
      <property name="driverClass" value="org.h2.Driver" />
      <property name="url" value="jdbc:h2:mem:flowable;DB_CLOSE_DELAY=1000" />
      <property name="username" value="sa" />
      <property name="password" value="" />
    </bean>
  
    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
      <property name="dataSource" ref="dataSource" />
    </bean>
  
    <bean id="processEngineConfiguration" class="org.flowable.spring.SpringProcessEngineConfiguration">
      <property name="dataSource" ref="dataSource" />
      <property name="transactionManager" ref="transactionManager" />
      <property name="databaseSchemaUpdate" value="true" />
      <property name="asyncExecutorActivate" value="false" />
    </bean>
  
    <bean id="processEngine" class="org.flowable.spring.ProcessEngineFactoryBean">
      <property name="processEngineConfiguration" ref="processEngineConfiguration" />
    </bean>
  
    <bean id="repositoryService" factory-bean="processEngine" factory-method="getRepositoryService" />
    <bean id="runtimeService" factory-bean="processEngine" factory-method="getRuntimeService" />
    <bean id="taskService" factory-bean="processEngine" factory-method="getTaskService" />
    <bean id="historyService" factory-bean="processEngine" factory-method="getHistoryService" />
    <bean id="managementService" factory-bean="processEngine" factory-method="getManagementService" />
  
  ...
  ```

- 还包括了其他的一些bean

  ```java
  <beans>
    ...
    <tx:annotation-driven transaction-manager="transactionManager"/>
  
    <bean id="userBean" class="org.flowable.spring.test.UserBean">
      <property name="runtimeService" ref="runtimeService" />
    </bean>
  
    <bean id="printer" class="org.flowable.spring.test.Printer" />
  
  </beans>
  ```

- 使用

  - 使用XML资源方式类配置Spring应用程序上下文

    ```java
    ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext(
        "org/flowable/examples/spring/SpringTransactionIntegrationTest-context.xml");
    ```

    - 或者添加注解

    	```java
	    @ContextConfiguration(
      "classpath:org/flowable/spring/test/transaction/SpringTransactionIntegrationTest-context.xml")
      ```
      
      
  
  - 获取服务bean并进行部署流程
  
    ```java
    RepositoryService repositoryService =
      (RepositoryService) applicationContext.getBean("repositoryService");
    String deploymentId = repositoryService
      .createDeployment()
      .addClasspathResource("org/flowable/spring/test/hello.bpmn20.xml")
      .deploy()
      .getId();
    ```
  
  - 下面看userBean类，使用了Transaction事务
  
    ```java
    public class UserBean {
    
      /** injected by Spring */
      private RuntimeService runtimeService;
    
      @Transactional
      public void hello() {
        // here you can do transactional stuff in your domain model
        // and it will be combined in the same transaction as
        // the startProcessInstanceByKey to the Flowable RuntimeService
        runtimeService.startProcessInstanceByKey("helloProcess");
      }
    
      public void setRuntimeService(RuntimeService runtimeService) {
        this.runtimeService = runtimeService;
      }
    }
    ```
  
  - 使用userBean
  
    ```java
    UserBean userBean = (UserBean) applicationContext.getBean("userBean");
    userBean.hello();
    ```

### 表达式

- BPMN 流程中的所有[表达式](https://www.flowable.com/open-source/docs/bpmn/ch04-API#expressions)也将默认“看到”所有 Spring bean

- **要完全不暴露任何 bean，只需将一个空列表作为 SpringProcessEngineConfiguration 上的“beans”属性传递。当没有设置 'beans' 属性时，上下文中的所有 Spring beans 都将可用**

- 如下，可以设置暴露的bean

  ```xml
  <bean id="processEngineConfiguration" class="org.flowable.spring.SpringProcessEngineConfiguration">
    ...
    <property name="beans">
      <map>
        <entry key="printer" value-ref="printer" />
      </map>
    </property>
  </bean>
  
  <bean id="printer" class="org.flowable.examples.spring.Printer" />
  ```

- 现在的bean进行公开了，在.bpmn20.xml中可以使用

  ```xml
  <definitions id="definitions">
  
    <process id="helloProcess">
  
      <startEvent id="start" />
      <sequenceFlow id="flow1" sourceRef="start" targetRef="print" />
  
      <serviceTask id="print" flowable:expression="#{printer.printMessage()}" />
      <sequenceFlow id="flow2" sourceRef="print" targetRef="end" />
  
      <endEvent id="end" />
  
    </process>
  
  </definitions>
  ```

- Print类

  ```java
  public class Printer {
  
    public void printMessage() {
      System.out.println("hello world");
    }
  }
  ```

- spring配置bean

  ```xml
  <beans>
    ...
  
    <bean id="printer" class="org.flowable.examples.spring.Printer" />
  
  </beans>
  ```

### 自动资源部署

```xml
<bean id="processEngineConfiguration" class="org.flowable.spring.SpringProcessEngineConfiguration">
  ...
  <property name="deploymentResources"
    value="classpath*:/org/flowable/spring/test/autodeployment/autodeploy.*.bpmn20.xml" />
</bean>

<bean id="processEngine" class="org.flowable.spring.ProcessEngineFactoryBean">
  <property name="processEngineConfiguration" ref="processEngineConfiguration" />
</bean>
```



### 单元测试

```java
@ExtendWith(FlowableSpringExtension.class)
@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = SpringJunitJupiterTest.TestConfiguration.class)
public class MyBusinessProcessTest {

  @Autowired
  private RuntimeService runtimeService;

  @Autowired
  private TaskService taskService;

  @Test
  @Deployment
  void simpleProcessTest() {
    runtimeService.startProcessInstanceByKey("simpleProcess");
    Task task = taskService.createTaskQuery().singleResult();
    assertEquals("My Task", task.getName());

    taskService.complete(task.getId());
    assertEquals(0, runtimeService.createProcessInstanceQuery().count());

  }
}
```



