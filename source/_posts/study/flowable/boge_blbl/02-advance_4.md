---
title: boge-02-flowable进阶_4
description: '候选人、候选人组'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-15 13:10:43
updated: 2022-05-15 13:10:43
---

## 候选人

- 流程图设计

  - 总体
    ![lyx-20241126134141073](attachments/img/lyx-20241126134141073.png)
  - 具体
    ![lyx-20241126134141609](attachments/img/lyx-20241126134141609.png)

- 部署并启动流程

  ```java
  
      @Test
      public void deploy(){
          ProcessEngine processEngine= ProcessEngines.getDefaultProcessEngine();
          RepositoryService repositoryService = processEngine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment().name("ly画的请假流程-候选人")
                  .addClasspathResource("请假流程-候选人.bpmn20.xml")
                  .deploy();
  
      }
      @Test
      public void runProcess(){
          //设置候选人
          Map<String,Object> variables=new HashMap<>();
          variables.put("candidate1","张三");
          variables.put("candidate2","李四");
          variables.put("candidate3","王五");
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          //获取流程运行服务
          RuntimeService runtimeService = engine.getRuntimeService();
          //运行流程
          ProcessInstance processInstance = runtimeService.startProcessInstanceById(
                  "holiday-candidate:1:4",variables);
          System.out.println("processInstance--"+processInstance);
      }
  ```

- 查看数据库表数据

  - 处理人为空
    ![lyx-20241126134142021](attachments/img/lyx-20241126134142021.png)
  - 变量
    ![lyx-20241126134142453](attachments/img/lyx-20241126134142453.png)
  - 图解
    ![lyx-20241126134142955](attachments/img/lyx-20241126134142955.png)

- 实际，作为登录用户如果是张三/李四或者王五，那它可以查看它自己是候选人的任务

  ```java
  
      /**
       * 查询候选任务
       */
      @Test
      public void queryCandidate(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService=processEngine.getTaskService();
          List<Task> tasks = taskService.createTaskQuery()
                  .processInstanceId("5001")
                  .taskCandidateUser("张三")
                  .list();
          for(Task task:tasks){
              System.out.println("id--"+task.getId()+"--"+task.getName());
          }
      }
  ```

- 拾取任务

  ```java
      /**
       * 拾取任务
       */
      @Test
      public void claimTaskCandidate(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService=engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .processInstanceId("5001")
                  .taskCandidateUser("张三")
                  .singleResult();
          if(task != null ){
              //拾取任务
              taskService.claim(task.getId(),"张三");
              System.out.println("拾取任务成功");
          }
      }
  ```

  - 数据库数据
    ![lyx-20241126134143379](attachments/img/lyx-20241126134143379.png)
  - 此时查询李四候选任务，就查询不到了

- 归还任务

  ```java
  
      /**
       * 拾取任务
       */
      @Test
      public void unclaimTaskCandidate(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService=engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .processInstanceId("5001")
                  .taskAssignee("张三")
                  .singleResult();
          if(task != null ){
              //归还任务
              taskService.unclaim(task.getId());
              System.out.println("归还任务成功");
          }
      }
  ```

  - 数据库数据
    ![lyx-20241126134143780](attachments/img/lyx-20241126134143780.png)
  - 此时用李四，拾取成功
    ![lyx-20241126134144224](attachments/img/lyx-20241126134144224.png)

- 任务交接(委托)

  ```java
  
      /**
       * 任务交接(委托)
       */
      @Test
      public void taskCandidate(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService=engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .processInstanceId("5001")
                  .taskAssignee("李四")
                  .singleResult();
          if(task != null ){
              taskService.setAssignee(task.getId(),"赵六");
              System.out.println("任务交接给赵六");
          }
      }
  ```

  - 结果
    ![lyx-20241126134144646](attachments/img/lyx-20241126134144646.png)

- 完成任务

  ```java
  
      /**
       * 完成任务
       */
      @Test
      public void taskComplete(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .processInstanceId("5001")
                  .taskAssignee("赵六")
                  .singleResult();
          if(task!=null){
              taskService.complete(task.getId());
              System.out.println("完成任务");
          }
      }
  ```

- 此时任务给wz了
  ![lyx-20241126134145087](attachments/img/lyx-20241126134145087.png)

## 候选人组

- 当候选人很多的情况下，可以分组。（先创建组，然后将用户放到组中）

- 维护用户和组

  ```java
  
      /**
       * 创建用户
       */
      @Test
      public void createUser(){
          ProcessEngine engine= ProcessEngines.getDefaultProcessEngine();
          IdentityService identityService = engine.getIdentityService();
          User user1 = identityService.newUser("李飞");
          user1.setFirstName("li");
          user1.setLastName("fei");
          identityService.saveUser(user1);
          User user2 = identityService.newUser("灯标");
          user2.setFirstName("deng");
          user2.setLastName("biao");
          identityService.saveUser(user2);
          User user3 = identityService.newUser("田家");
          user3.setFirstName("tian");
          user3.setLastName("jia");
          identityService.saveUser(user3);
  
      }
  
      /**
       * 创建组
       */
      @Test
      public void createGroup(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          IdentityService identityService = engine.getIdentityService();
          Group group1 = identityService.newGroup("group1");
          group1.setName("销售部");
          group1.setType("typ1");
          identityService.saveGroup(group1);
          Group group2 = identityService.newGroup("group2");
          group2.setName("开发部");
          group2.setType("typ2");
          identityService.saveGroup(group2);
      }
  
      /**
       * 分配
       */
      @Test
      public void userGroup(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          IdentityService identityService = engine.getIdentityService();
          //找到组
          Group group1 = identityService.createGroupQuery().groupId("group1")
                  .singleResult();
          //找到所有用户
          List<User> list = identityService.createUserQuery().list();
          for(User user:list){
              identityService.createMembership(user.getId(),group1.getId());
  
              System.out.println(user.getId());
          }
      }
  ```

  - 表结构

    ![lyx-20241126134145503](attachments/img/lyx-20241126134145503.png)

    ![lyx-20241126134145932](attachments/img/lyx-20241126134145932.png)
    ![lyx-20241126134146381](attachments/img/lyx-20241126134146381.png)

- 应用，创建流程图
  ![lyx-20241126134146972](attachments/img/lyx-20241126134146972.png)
  ![lyx-20241126134147428](attachments/img/lyx-20241126134147428.png)

- xml文件

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="holiday-group" name="请求流程-候选人组" isExecutable="true">
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-B4CAA6EE-47C0-4C51-AB0F-7A347AA88CF9" name="创建请假单" flowable:candidateGroups="${g1}" flowable:formFieldValidation="true"></userTask>
      <sequenceFlow id="sid-FAA16FF3-BFC5-49AA-8BB5-7DF1918F67FF" sourceRef="startEvent1" targetRef="sid-B4CAA6EE-47C0-4C51-AB0F-7A347AA88CF9"></sequenceFlow>
      <userTask id="sid-C3C15BE2-2D50-4178-AD36-D6BAC5C47526" name="总经理审批" flowable:assignee="wz" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-9821E7E5-DB4A-4BE5-95C7-2721E98D6BD6" sourceRef="sid-B4CAA6EE-47C0-4C51-AB0F-7A347AA88CF9" targetRef="sid-C3C15BE2-2D50-4178-AD36-D6BAC5C47526"></sequenceFlow>
      <endEvent id="sid-BF42EC91-584D-4C19-8EC0-9658CD948CDE"></endEvent>
      <sequenceFlow id="sid-6F5E54EF-5767-4E22-8AC7-322C7E332B6B" sourceRef="sid-C3C15BE2-2D50-4178-AD36-D6BAC5C47526" targetRef="sid-BF42EC91-584D-4C19-8EC0-9658CD948CDE"></sequenceFlow>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_holiday-group">
      <bpmndi:BPMNPlane bpmnElement="holiday-group" id="BPMNPlane_holiday-group">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="163.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-B4CAA6EE-47C0-4C51-AB0F-7A347AA88CF9" id="BPMNShape_sid-B4CAA6EE-47C0-4C51-AB0F-7A347AA88CF9">
          <omgdc:Bounds height="80.0" width="100.0" x="165.0" y="135.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-C3C15BE2-2D50-4178-AD36-D6BAC5C47526" id="BPMNShape_sid-C3C15BE2-2D50-4178-AD36-D6BAC5C47526">
          <omgdc:Bounds height="80.0" width="100.0" x="330.0" y="135.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-BF42EC91-584D-4C19-8EC0-9658CD948CDE" id="BPMNShape_sid-BF42EC91-584D-4C19-8EC0-9658CD948CDE">
          <omgdc:Bounds height="28.0" width="28.0" x="510.0" y="164.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-9821E7E5-DB4A-4BE5-95C7-2721E98D6BD6" id="BPMNEdge_sid-9821E7E5-DB4A-4BE5-95C7-2721E98D6BD6" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="264.94999999998356" y="175.0"></omgdi:waypoint>
          <omgdi:waypoint x="330.0" y="175.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-FAA16FF3-BFC5-49AA-8BB5-7DF1918F67FF" id="BPMNEdge_sid-FAA16FF3-BFC5-49AA-8BB5-7DF1918F67FF" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="129.94340692927761" y="177.55019845363262"></omgdi:waypoint>
          <omgdi:waypoint x="164.99999999999906" y="176.4985"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-6F5E54EF-5767-4E22-8AC7-322C7E332B6B" id="BPMNEdge_sid-6F5E54EF-5767-4E22-8AC7-322C7E332B6B" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="429.9499999999989" y="176.04062499999998"></omgdi:waypoint>
          <omgdi:waypoint x="510.0021426561354" y="177.70839534661596"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

- 部署并启动流程

  ```java
  
      @Test
      public void deploy(){
          ProcessEngine processEngine= ProcessEngines.getDefaultProcessEngine();
          RepositoryService repositoryService = processEngine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment().name("ly画的请假流程-候选人")
                  .addClasspathResource("请求流程-候选人组.bpmn20.xml")
                  .deploy();
  
      }
      @Test
      public void runProcess(){
  
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          //实际开发，应该按下面代码让用户选
          IdentityService identityService = engine.getIdentityService();
          List<Group> list = identityService.createGroupQuery().list();
  
  
          //获取流程运行服务
          RuntimeService runtimeService = engine.getRuntimeService();
  
          //设置候选人
          Map<String,Object> variables=new HashMap<>();
          variables.put("g1","group1");
          //运行流程
          ProcessInstance processInstance = runtimeService.
                  startProcessInstanceById(
                  "holiday-group:1:25004",variables);
          System.out.println("processInstance--"+processInstance);
      }
  ```

- 表
  ![lyx-20241126134147822](attachments/img/lyx-20241126134147822.png)
  variables
  ![lyx-20241126134148436](attachments/img/lyx-20241126134148436.png)

- 查找当前用户所在组的任务，并拾取

  ```java
  
      /**
       * 查询候选组任务
       */
      @Test
      public void queryCandidateGroup(){
          String userId="灯标";
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          IdentityService identityService = processEngine.getIdentityService();
          Group group = identityService.createGroupQuery().
                  groupMember(userId)
                  .singleResult();
          System.out.println("灯标组id"+group.getId());
  
          TaskService taskService=processEngine.getTaskService();
          List<Task> tasks = taskService.createTaskQuery()
                  .processInstanceId("27501")
                  .taskCandidateGroup(group.getId())
                  .list();
          for(Task task:tasks){
              System.out.println("id--"+task.getId()+"--"+task.getName());
          }
          Task task = taskService.createTaskQuery()
                  .processInstanceId("27501")
                  .taskCandidateGroup(group.getId())
                  .singleResult();
          if(task!=null){
              System.out.println("拾取任务--"+task.getId()
              +"任务名--"+task.getName());
              taskService.claim(task.getId(),userId);
          }
  
      }
  ```

  - 数据库数据
    ![lyx-20241126134148862](attachments/img/lyx-20241126134148862.png)

- 完成任务

  ```java
  
      /**
       * 完成任务
       */
      @Test
      public void taskComplete(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .processInstanceId("27501")
                  .taskAssignee("灯标")
                  .singleResult();
          if(task!=null){
              taskService.complete(task.getId());
              System.out.println("完成任务");
          }
      }
  ```

## 
