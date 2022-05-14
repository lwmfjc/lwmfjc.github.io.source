---
title: 01-flowable基础
description: '01-flowable基础'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-14 07:29:14
updated: 2022-05-14 07:29:14
---

## Flowable介绍

- flowable的历史

  ![image-20220514094153736](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514094153736.png)

- flowable是BPNM的一个基于java的软件实现，不仅包括BPMN，还有DMN决策表和CMMNCase管理引擎，并且有自己的用户管理、微服务API等

## 获取Engine对象

- maven依赖

  ```xml
  
      <dependencies>
          <dependency>
              <groupId>mysql</groupId>
              <artifactId>mysql-connector-java</artifactId>
              <version>8.0.29</version>
          </dependency>
          <!-- https://mvnrepository.com/artifact/org.flowable/flowable-engine -->
          <dependency>
              <groupId>org.flowable</groupId>
              <artifactId>flowable-engine</artifactId>
              <version>6.7.2</version>
          </dependency>
          <!-- https://mvnrepository.com/artifact/junit/junit -->
          <dependency>
              <groupId>junit</groupId>
              <artifactId>junit</artifactId>
              <version>4.13.2</version>
              <scope>test</scope>
          </dependency>
      </dependencies>
  ```

- 配置并获取ProcessEngine

  ```java
  ProcessEngineConfiguration configuration=
                  new StandaloneProcessEngineConfiguration();
          //配置
          configuration.setJdbcDriver("com.mysql.cj.jdbc.Driver");
          configuration.setJdbcUsername("root");
          configuration.setJdbcPassword("123456");
          //nullCatalogMeansCurrent=true 设置为只查当前连接的schema库
          configuration.setJdbcUrl("jdbc:mysql://localhost:3306/flowable-learn?" +
                  "useUnicode=true&characterEncoding=utf-8" +
                  "&allowMultiQueries=true" +
                  "&nullCatalogMeansCurrent=true");
          //如果数据库中表结构不存在则新建
          configuration.setDatabaseSchemaUpdate(ProcessEngineConfiguration.DB_SCHEMA_UPDATE_TRUE);
          //构建ProcessEngine
          ProcessEngine processEngine=configuration.buildProcessEngine();
  ```

## 日志和表结构介绍

- 添加slf4j依赖

  ```xml
   <!-- https://mvnrepository.com/artifact/org.slf4j/slf4j-reload4j -->
          <dependency>
              <groupId>org.slf4j</groupId>
              <artifactId>slf4j-reload4j</artifactId>
              <version>1.7.36</version>
              <scope>test</scope>
          </dependency>
          <!-- https://mvnrepository.com/artifact/org.apache.logging.log4j/log4j-api -->
          <dependency>
              <groupId>org.apache.logging.log4j</groupId>
              <artifactId>log4j-api</artifactId>
              <version>2.17.2</version>
          </dependency>
  ```

- 添加log配置文件

  ```properties
  log4j.rootLogger = DEBUG, CA
  log4j.appender.CA = org.apache.log4j.ConsoleAppender
  log4j.appender.CA.layout = org.apache.log4j.PatternLayout
  log4j.appender.CA.layout.ConversionPattern = %d{hh:mm:ss,SSS} {%t} %-5p %c %x - %m%n
  ```

  - 此时再次启动就会看到一堆日志

- 表
  ![image-20220514102041305](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514102041305.png)

## 流程定义文件解析

- 先通过流程绘制器绘制流程

- 案例（官网，请假流程）
  ![image-20220514102241579](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514102241579.png)

  - 设计好流程之后，流程数据保存在holiday-request.bpmn20.xml文件中

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"
      xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC"
      xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI"
      xmlns:flowable="http://flowable.org/bpmn"
      typeLanguage="http://www.w3.org/2001/XMLSchema"
      expressionLanguage="http://www.w3.org/1999/XPath"
      targetNamespace="http://www.flowable.org/processdef">
    
      <!--id process key-->
      <process id="holidayRequest" name="请假流程" isExecutable="true">
    
        <startEvent id="startEvent"/>
        <!--sequenceFlow表示的是线条箭头-->
        <sequenceFlow sourceRef="startEvent" targetRef="approveTask"/>
    
        <userTask id="approveTask" name="同意或者拒绝请假"/>
        <sequenceFlow sourceRef="approveTask" targetRef="decision"/>
    
        <!--网关-->
        <exclusiveGateway id="decision"/>
        <sequenceFlow sourceRef="decision" targetRef="externalSystemCall">
          <!--条件-->
          <conditionExpression xsi:type="tFormalExpression">
            <![CDATA[
              ${approved}
            ]]>
          </conditionExpression>
        </sequenceFlow>
        <sequenceFlow  sourceRef="decision" targetRef="sendRejectionMail">
          <!--条件-->
          <conditionExpression xsi:type="tFormalExpression">
            <![CDATA[
              ${!approved}
            ]]>
          </conditionExpression>
        </sequenceFlow>
    
        <serviceTask id="externalSystemCall" name="Enter holidays in external system"
            flowable:class="org.flowable.CallExternalSystemDelegate"/>
        <sequenceFlow sourceRef="externalSystemCall" targetRef="holidayApprovedTask"/>
    
        <userTask id="holidayApprovedTask" name="Holiday approved"/>
        <sequenceFlow sourceRef="holidayApprovedTask" targetRef="approveEnd"/>
    
        <!--发送一个邮件-->
        <serviceTask id="sendRejectionMail" name="Send out rejection email"
            flowable:class="org.flowable.SendRejectionMail"/>
        <sequenceFlow sourceRef="sendRejectionMail" targetRef="rejectEnd"/>
    
        <endEvent id="approveEnd"/>
    
        <endEvent id="rejectEnd"/>
    
      </process>
    
    </definitions>
    ```

    

## 部署流程-代码实现

- 使用@bofore 处理测试中繁琐的配置操作

  ```java
  
      ProcessEngineConfiguration configuration = null;
  
      @Before
      public void before() {
          configuration =
                  new StandaloneProcessEngineConfiguration();
          //配置
          configuration.setJdbcDriver("com.mysql.cj.jdbc.Driver");
          configuration.setJdbcUsername("root");
          configuration.setJdbcPassword("123456");
          //nullCatalogMeansCurrent=true 设置为只查当前连接的schema库
          configuration.setJdbcUrl("jdbc:mysql://localhost:3306/flowable-learn?" +
                  "useUnicode=true&characterEncoding=utf-8" +
                  "&allowMultiQueries=true" +
                  "&nullCatalogMeansCurrent=true");
          //如果数据库中表结构不存在则新建
          configuration.setDatabaseSchemaUpdate(ProcessEngineConfiguration.DB_SCHEMA_UPDATE_TRUE);
      }
  ```

- ProcessEngine提供的几个服务
  ![image-20220514103435244](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514103435244.png)

- 流程部署

  ```java
  
      /**
       * 流程的部署
       */
      @Test
      public void testDeploy() {
          //获取ProcessEngine对象
          ProcessEngine processEngine = configuration.buildProcessEngine();
          //获取服务(repository，流程定义)
          RepositoryService repositoryService = processEngine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment().addClasspathResource("holiday-request.bpmn20.xml")
                  .name("请求流程") //流程名
                  .deploy(); 
          System.out.println("部署id" + deploy.getId()); 
          System.out.println("部署名" + deploy.getName());
  
      }
  ```

- 表结构
  ![image-20220514104106140](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514104106140.png)

## 查询和删除操作

- 查询已经部署的流程定义

  ```java
  
      /**
       * 流程定义及部署的查询
       */
      @Test
      public void testDeployQuery(){
          ProcessEngine processEngine=configuration.buildProcessEngine();
          RepositoryService repositoryService=processEngine.getRepositoryService();
          //流程部署查询
          //这里只部署了一个流程定义
          Deployment deployment = repositoryService.createDeploymentQuery()
                  .deploymentId("1").singleResult();
          System.out.println("部署时的名称:"+deployment.getName());
          //流程定义查询器
          ProcessDefinitionQuery processDefinitionQuery = repositoryService.createProcessDefinitionQuery();
          //查询到的流程定义
          ProcessDefinition processDefinition = processDefinitionQuery.deploymentId("1").singleResult();
  
          System.out.println("部署id:"+processDefinition.getDeploymentId());
          System.out.println("定义名:"+processDefinition.getName());
          System.out.println("描述:"+processDefinition.getDescription());
          System.out.println("定义id:"+processDefinition.getId());
      }
  ```

- 删除流程定义

  - 代码

    ```java
    /**
         * 流程删除
         */
        @Test
        public void testDeleteDeploy(){
            ProcessEngine processEngine=configuration.buildProcessEngine();
            RepositoryService repositoryService=processEngine.
                    getRepositoryService();
            //注意：第一个参数时部署id
            //后面那个参数表示级联删除，如果流程启动了会同时删除任务。
            repositoryService.deleteDeployment("2501",true);
        }
    ```

    

  - 下面三个表的数据都会被删除
    ![image-20220514105321078](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514105321078.png)

## 启动流程实例

- 由于刚才将部署删除了，所以这里再运行testDeploy()重新部署上

- 这里通过流程定义key（xml中的id）启动流程

  ```java
  
      /**
       * 流程运行
       */
      @Test
      public void testRunProcess(){
          ProcessEngine processEngine=configuration.buildProcessEngine();
          RuntimeService runtimeService = processEngine.getRuntimeService();
          //这边模拟表单数据(表单数据有多种处理方式，这只是其中一种)
          Map<String,Object> map=new HashMap<>();
          map.put("employee","张三");
          map.put("nrOfHolidays",3);
          map.put("description","工作累了想出去玩");
          ProcessInstance holidayRequest = runtimeService.startProcessInstanceByKey("holidayRequest", map);
          System.out.println("流程定义的id:"+holidayRequest.getProcessDefinitionId());
          System.out.println("当前活跃id:"+holidayRequest.getActivityId());
          System.out.println("流程运行id:"+holidayRequest.getId());
      }
  ```

- 三个表
  act_ru_variable  act_ru_task  arc_ru_execution

  ![image-20220514111442166](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514111442166.png)

  

## 查询任务

- 这里先指定一下每个任务的候选人，修改xml文件中userTask的节点属性

  - 修改前先删除一下之前部署的流程图(还是上面的代码)

    ```java
    /**
         * 流程删除
         */
        @Test
        public void testDeleteDeploy(){
            ProcessEngine processEngine=configuration.buildProcessEngine();
            RepositoryService repositoryService=processEngine.
                    getRepositoryService();
            //注意：第一个参数时部署id
            //后面那个参数表示级联删除，true表示如果流程启动了会同时删除任务。
            repositoryService.deleteDeployment("2501",false);
        }
    ```

    这里用false参数测试，会提示失败，运行中的流程不允许删除。将第二个参数改为true即可级联删除  
    删除后可以发现下面几个表数据全部清空了
    ![image-20220514112055940](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514112055940.png)

  - 然后修改xml定义文件并运行testDeploy()重新部署

    - 定义修改

      ```xml
      <userTask id="approveTask" name="同意或者拒绝请假" flowable:assignee="zhangsan"/>
      <!--这里增加了assignee属性值-->        
      ```

  - 运行流程 testRunProcess()

    - 运行后节点会跳到给zhangsan的那个任务，查看数据库表
      ![image-20220514112605263](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514112605263.png)
    - 流程变量
      ![image-20220514112655133](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514112655133.png)

  - 查询任务

    ```java
    
        /**
         * 测试任务查询
         */
        @Test
        public void testQueryTask(){
            ProcessEngine processEngine=configuration.buildProcessEngine();
            TaskService taskService = processEngine.getTaskService();
            //通过流程定义查询任务
            List<Task> list = taskService.createTaskQuery().processDefinitionKey("holidayRequest")
                    .taskAssignee("zhangsan")
                    .list();
            for (Task task:list){
                System.out.println("任务对应的流程定义id"+task.getProcessDefinitionId());
                System.out.println("任务名"+task.getName());
                System.out.println("任务处理人"+task.getAssignee());
                System.out.println("任务描述"+task.getDescription());
                System.out.println("任务id"+task.getId());
            }
        }
    ```

    

## 处理任务

- 流程图定义的分析
  任务A处理后，根据处理结果（这里是拒绝），会走向任务D，然后任务D是一个Service，且通过java的委托对象，自动实现操作

  ![image-20220514115334229](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514115334229.png)

- 到了D那个节点，这里指定了一个自定义的java类处理
  ![image-20220514115513100](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514115513100.png)

  - 代码配置，注意类名和xml中的一致

    ```java
    package org.flowable;
    
    import org.flowable.engine.delegate.DelegateExecution;
    import org.flowable.engine.delegate.JavaDelegate;
    
    public class SendRejectionMail implements JavaDelegate {
        /**
         * 这是一个flowable中的触发器
         *
         * @param delegateExecution
         */
        @Override
        public void execute(DelegateExecution delegateExecution) {
            //触发执行的逻辑 按照我们在流程中的定义给被拒绝的员工发送通知邮件
            System.out.println("不好意思，你的请假申请被拒绝了");
        }
    }
    ```

- 任务的完成

  ```java
  @Test
      public void testCompleteTask() {
          ProcessEngine engine = configuration.buildProcessEngine();
          TaskService taskService = engine.getTaskService();
          //查找出张三在这个流程定义中的任务
          Task task = taskService.createTaskQuery().processDefinitionKey("holidayRequest")
                  .taskAssignee("zhangsan")
                  .singleResult();
          //创建流程变量
          HashMap<String, Object> map = new HashMap<>();
          map.put("approved", false);
          //完成任务
          taskService.complete(task.getId(), map);
      }
  ```

  - 控制台
    ![image-20220514120154300](C:\Users\ly\AppData\Roaming\Typora\typora-user-images\image-20220514120154300.png)
  - 数据库
    下面几个表的数据都被清空了
    ![image-20220514120320988](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514120320988.png)

## 历史任务的完成

- Flowable流程引擎可以自动存储所有流程实例的审计数据或历史数据

- 先查看一下刚才用的流程定义的id
  ![image-20220514120756973](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514120756973.png)

- 历史信息查询

  ```java
  
      @Test
      public void testHistory(){
          ProcessEngine processEngine=configuration.buildProcessEngine();
          HistoryService historyService=processEngine.getHistoryService();
          List<HistoricActivityInstance> list = historyService.createHistoricActivityInstanceQuery()
                  .processDefinitionId("holidayRequest:1:7503")
                  .finished() //查询已经完成的
                  .orderByHistoricActivityInstanceEndTime().asc() //指定排序字段和升降序
                  .list();
          for(HistoricActivityInstance history:list){
              //注意,和视频不一样的地方，history表还记录了流程箭头流向的那个节点
              //_flow_
              System.out.println(
                      "活动名--"+history.getActivityName()+
                              "处理人--"+history.getAssignee()+
                              "活动id--"+history.getActivityId()+
                      "处理时长--"+history.getDurationInMillis()+"毫秒");
          }
  ```

- 不一样的地方，在旧版本时没有的
  ![image-20220514121509725](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514121509725.png)

## 流程设计器

- 有eclipse流程设计器，和flowable流程设计器

- 使用eclipse的设计，会生成一个bar文件，代码稍微有点不同
  接收一个ZipInputStream

  ![image-20220514122035548](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514122035548.png)
  

## FlowableUI

- 使用flowable官方提供的包，里面有一个war，直接用命令 java -jar xx.war启动即可
- 这个应用分成四个模块
  ![image-20220514121818052](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514121818052.png)
- 流程图的绘制及用户分配
  ![image-20220514121906621](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514121906621.png)
- 





