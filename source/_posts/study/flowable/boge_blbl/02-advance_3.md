---
title: boge-02-flowable进阶_3
description: '02-flowable进阶_3'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-15 10:04:08
updated: 2022-05-15 10:04:08
---

## 任务分配-uel表达式

通过变量指定来进行分配

- 首先绘制流程图（定义）
  ![image-20220515100239983](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515100239983.png)

  - 变量处理
    ![image-20220515100603738](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515100603738.png)
    ![image-20220515100629221](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515100629221.png)

- 之后将xml文件导出

  ```java
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="holiday-new" name="新请假流程" isExecutable="true">
      <documentation>new-description</documentation>
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-8D901410-5BD7-4EED-B988-5E40D12298C7" name="创建请假流程" flowable:assignee="${assignee0}" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <userTask id="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE" name="审批请假流程" flowable:assignee="${assignee1}" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-631EFFB0-795A-4777-B49E-CF7D015BFF15" sourceRef="sid-8D901410-5BD7-4EED-B988-5E40D12298C7" targetRef="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE"></sequenceFlow>
      <endEvent id="sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B"></endEvent>
      <sequenceFlow id="sid-001CA567-6169-4F8A-A0E5-010721D52508" sourceRef="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE" targetRef="sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B"></sequenceFlow>
      <sequenceFlow id="sid-0A4A52F2-ECF6-44B2-AA41-F926AA7F5932" sourceRef="startEvent1" targetRef="sid-8D901410-5BD7-4EED-B988-5E40D12298C7"></sequenceFlow>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_holiday-new">
      <bpmndi:BPMNPlane bpmnElement="holiday-new" id="BPMNPlane_holiday-new">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="145.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-8D901410-5BD7-4EED-B988-5E40D12298C7" id="BPMNShape_sid-8D901410-5BD7-4EED-B988-5E40D12298C7">
          <omgdc:Bounds height="80.0" width="100.0" x="225.0" y="120.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE" id="BPMNShape_sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE">
          <omgdc:Bounds height="80.0" width="100.0" x="370.0" y="120.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B" id="BPMNShape_sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B">
          <omgdc:Bounds height="28.0" width="28.0" x="555.0" y="146.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-001CA567-6169-4F8A-A0E5-010721D52508" id="BPMNEdge_sid-001CA567-6169-4F8A-A0E5-010721D52508" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="469.94999999997356" y="160.0"></omgdi:waypoint>
          <omgdi:waypoint x="555.0" y="160.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-0A4A52F2-ECF6-44B2-AA41-F926AA7F5932" id="BPMNEdge_sid-0A4A52F2-ECF6-44B2-AA41-F926AA7F5932" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="129.94999928606217" y="160.0"></omgdi:waypoint>
          <omgdi:waypoint x="224.99999999995185" y="160.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-631EFFB0-795A-4777-B49E-CF7D015BFF15" id="BPMNEdge_sid-631EFFB0-795A-4777-B49E-CF7D015BFF15" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="324.9499999999907" y="160.0"></omgdi:waypoint>
          <omgdi:waypoint x="369.9999999999807" y="160.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

- 流程定义的部署

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
          Deployment deploy = repositoryService.createDeployment()
                  .addClasspathResource("新请假流程.bpmn20.xml")
                  .name("请求流程") //流程名
                  .deploy();
          System.out.println("部署id" + deploy.getId());
          System.out.println("部署名" + deploy.getName());
  
      }
  ```

- 流程的启动（在流程启动时就已经处理好了各个节点的处理人）

  ```java
  
      /**
       * 流程实例的启动
       */
      @Test
      public void testRunProcess2(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          RuntimeService runtimeService = engine.getRuntimeService();
          //启动流程时，发起人就已经设置好了
          Map<String,Object> variables=new HashMap<>();
          variables.put("assignee0","张三");
          variables.put("assignee1","李四");
          ProcessInstance processInstance = runtimeService.startProcessInstanceById("holiday-new:1:4",variables);
          System.out.println(processInstance);
      }
  ```

  - 查看数据库表数据

    - act_ru_variable


      ![image-20220515101806631](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515101806631.png)![image-20220515101906703](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515101906703.png)
    
    - act_ru_task
      ![image-20220515101840975](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515101840975.png)

  - 让张三完成处理

    ```java
        @Test
        public void testComplete(){
            ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
            TaskService taskService = processEngine.getTaskService();
            Task task = taskService.createTaskQuery().taskAssignee("张三")
                    .processInstanceId("2501")
                    .singleResult();
            taskService.complete(task.getId());
        }
    ```

  - 此时观察task和identity这两张表

    任务变成了李四，而identity多了张三的记录![image-20220515102508734](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515102508734.png)

## 任务分配-监听器分配

- 首先，java代码中，自定义一个监听器
  【注意，这里给任务分配assignee是在create中分配才是有用的】

  ```java
  package org.flowable.listener;
  
  import org.flowable.engine.delegate.TaskListener;
  import org.flowable.task.service.delegate.DelegateTask;
  
  public class MyTaskListener implements TaskListener {
      /**
       * 监听器触发的方法
       * @param delegateTask
       */
      @Override
      public void notify(DelegateTask delegateTask) {
  
          System.out.println("MyTaskListener触发："+delegateTask
                  .getName());
          if("创建请假流程".equals(delegateTask.getName())
          &&"create".equals(delegateTask.getEventName())){
              delegateTask.setAssignee("小明");
          }else {
              delegateTask.setAssignee("小李");
          }
      }
  }
  
  ```

  两个节点走的是同一个监听器

- xml定义中任务监听器的配置(两个节点都配置了)
  ![image-20220515103504436](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515103504436.png)

  ```java
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="holiday-new" name="新请假流程" isExecutable="true">
      <documentation>new-description</documentation>
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-8D901410-5BD7-4EED-B988-5E40D12298C7" name="创建请假流程" flowable:formFieldValidation="true">
        <extensionElements>
          <flowable:taskListener event="create" class="org.flowable.listener.MyTaskListener"></flowable:taskListener>
        </extensionElements>
      </userTask>
      <userTask id="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE" name="审批请假流程" flowable:formFieldValidation="true">
        <extensionElements>
          <flowable:taskListener event="create" class="org.flowable.listener.MyTaskListener"></flowable:taskListener>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-631EFFB0-795A-4777-B49E-CF7D015BFF15" sourceRef="sid-8D901410-5BD7-4EED-B988-5E40D12298C7" targetRef="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE"></sequenceFlow>
      <sequenceFlow id="sid-001CA567-6169-4F8A-A0E5-010721D52508" sourceRef="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE" targetRef="sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B"></sequenceFlow>
      <sequenceFlow id="sid-0A4A52F2-ECF6-44B2-AA41-F926AA7F5932" sourceRef="startEvent1" targetRef="sid-8D901410-5BD7-4EED-B988-5E40D12298C7"></sequenceFlow>
      <endEvent id="sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B"></endEvent>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_holiday-new">
      <bpmndi:BPMNPlane bpmnElement="holiday-new" id="BPMNPlane_holiday-new">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="115.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-8D901410-5BD7-4EED-B988-5E40D12298C7" id="BPMNShape_sid-8D901410-5BD7-4EED-B988-5E40D12298C7">
          <omgdc:Bounds height="80.0" width="100.0" x="195.0" y="90.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE" id="BPMNShape_sid-5EB8F68B-7876-42AF-98E1-FCA27F99D8CE">
          <omgdc:Bounds height="80.0" width="100.0" x="370.0" y="90.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B" id="BPMNShape_sid-15CAD0D3-7F8B-404C-9346-A8D2A456D47B">
          <omgdc:Bounds height="28.0" width="28.0" x="570.0" y="116.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-001CA567-6169-4F8A-A0E5-010721D52508" id="BPMNEdge_sid-001CA567-6169-4F8A-A0E5-010721D52508" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="469.9499999999809" y="130.0"></omgdi:waypoint>
          <omgdi:waypoint x="570.0" y="130.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-0A4A52F2-ECF6-44B2-AA41-F926AA7F5932" id="BPMNEdge_sid-0A4A52F2-ECF6-44B2-AA41-F926AA7F5932" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="129.94999891869114" y="130.0"></omgdi:waypoint>
          <omgdi:waypoint x="195.0" y="130.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-631EFFB0-795A-4777-B49E-CF7D015BFF15" id="BPMNEdge_sid-631EFFB0-795A-4777-B49E-CF7D015BFF15" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="294.95000000000005" y="130.0"></omgdi:waypoint>
          <omgdi:waypoint x="369.99999999993753" y="130.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

- 之后将流程再重新部署一遍

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
          Deployment deploy = repositoryService.createDeployment()
                  .addClasspathResource("新请假流程.bpmn20.xml")
                  .name("请求流程") //流程名
                  .deploy();
          System.out.println("部署id" + deploy.getId());
          System.out.println("部署名" + deploy.getName());
  
      }
  ```

- 流程运行

  ```java
  
      /**
       * 流程实例的启动
       */
      @Test
      public void testRunProcess3() {
          ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
          RuntimeService runtimeService = engine.getRuntimeService();
          ProcessInstance processInstance = runtimeService.startProcessInstanceById(
                  "holiday-new:1:4");
          System.out.println(processInstance);
      }
  ```

- 控制台查看
  ![image-20220515104113169](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515104113169.png)

- 数据库查看
  ![image-20220515104240526](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515104240526.png)
  ![image-20220515104248454](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515104248454.png)

- 让小明处理任务

  ```java
  
      @Test
      public void testComplete(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery().taskAssignee("小明")
                  .processInstanceId("2501")
                  .singleResult();
          taskService.complete(task.getId());
      }
  ```

- 数据库查看
  ![image-20220515104524706](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515104524706.png)

## 流程变量

- 全局变量（跟流程有关）和局部变量（跟task有关）

- 一个流程定义，可以运行多个流程实例；
  ![image-20220515105403272](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515105403272.png)
  ![image-20220515105511486](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515105511486.png)
  当用到子流程时，就会出现一对多的关系
  ![image-20220515105549313](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515105549313.png)

- 全局变量被重复赋值时后面会覆盖前面

- 流程图的创建
  ![image-20220515110130347](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515110130347.png)
  这里还设置了条件，详见xm文件 sequenceFlow.conditionExpression 属性

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="evection" name="出差申请单" isExecutable="true">
      <documentation>出差申请单</documentation>
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-BFB6D699-D3B5-4C6C-A0F2-00584EAAF207" name="创建出差申请单" flowable:assignee="${assignee0}" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-EE410204-0433-4FE6-A958-48585A2A7B4B" sourceRef="startEvent1" targetRef="sid-BFB6D699-D3B5-4C6C-A0F2-00584EAAF207"></sequenceFlow>
      <userTask id="sid-D10C4F45-B429-4E24-B474-5354F1661645" name="部门经理审批" flowable:assignee="${assignee1}" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-752CE2F2-40EC-4140-AF60-BEACD06D43A7" sourceRef="sid-BFB6D699-D3B5-4C6C-A0F2-00584EAAF207" targetRef="sid-D10C4F45-B429-4E24-B474-5354F1661645"></sequenceFlow>
      <userTask id="sid-35AB278B-E16D-4CEC-98B1-FBB139FB5AC1" name="总经理审批" flowable:assignee="${assignee2}" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <userTask id="sid-4C26DA5C-A4CC-48A5-ABA9-853E82FC2413" name="财务审批
  " flowable:assignee="${assignee3}" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-BE043A23-0F38-4ED9-A0D1-F4C2F7908A50" sourceRef="sid-35AB278B-E16D-4CEC-98B1-FBB139FB5AC1" targetRef="sid-4C26DA5C-A4CC-48A5-ABA9-853E82FC2413"></sequenceFlow>
      <endEvent id="sid-B3A1D5D4-E1FD-4599-A482-762C7C617844"></endEvent>
      <sequenceFlow id="sid-6C0130A8-E078-486B-9B6E-D8C14BBCD8EF" sourceRef="sid-4C26DA5C-A4CC-48A5-ABA9-853E82FC2413" targetRef="sid-B3A1D5D4-E1FD-4599-A482-762C7C617844"></sequenceFlow>
      <sequenceFlow id="sid-F85B2D44-1B42-4748-AB35-123C7CCD2F75" sourceRef="sid-D10C4F45-B429-4E24-B474-5354F1661645" targetRef="sid-35AB278B-E16D-4CEC-98B1-FBB139FB5AC1">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num >= 3}]]></conditionExpression>
      </sequenceFlow>
      <sequenceFlow id="sid-B12793A8-FC65-408C-81AD-EC81FEEF6E46" sourceRef="sid-D10C4F45-B429-4E24-B474-5354F1661645" targetRef="sid-4C26DA5C-A4CC-48A5-ABA9-853E82FC2413">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num < 3}]]></conditionExpression>
      </sequenceFlow>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_evection">
      <bpmndi:BPMNPlane bpmnElement="evection" id="BPMNPlane_evection">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="75.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-BFB6D699-D3B5-4C6C-A0F2-00584EAAF207" id="BPMNShape_sid-BFB6D699-D3B5-4C6C-A0F2-00584EAAF207">
          <omgdc:Bounds height="80.0" width="100.0" x="175.0" y="50.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-D10C4F45-B429-4E24-B474-5354F1661645" id="BPMNShape_sid-D10C4F45-B429-4E24-B474-5354F1661645">
          <omgdc:Bounds height="80.0" width="100.0" x="320.0" y="50.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-35AB278B-E16D-4CEC-98B1-FBB139FB5AC1" id="BPMNShape_sid-35AB278B-E16D-4CEC-98B1-FBB139FB5AC1">
          <omgdc:Bounds height="80.0" width="100.0" x="555.0" y="50.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-4C26DA5C-A4CC-48A5-ABA9-853E82FC2413" id="BPMNShape_sid-4C26DA5C-A4CC-48A5-ABA9-853E82FC2413">
          <omgdc:Bounds height="80.0" width="100.0" x="555.0" y="210.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-B3A1D5D4-E1FD-4599-A482-762C7C617844" id="BPMNShape_sid-B3A1D5D4-E1FD-4599-A482-762C7C617844">
          <omgdc:Bounds height="28.0" width="28.0" x="750.0" y="236.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-EE410204-0433-4FE6-A958-48585A2A7B4B" id="BPMNEdge_sid-EE410204-0433-4FE6-A958-48585A2A7B4B" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="129.9499984899576" y="90.0"></omgdi:waypoint>
          <omgdi:waypoint x="175.0" y="90.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-752CE2F2-40EC-4140-AF60-BEACD06D43A7" id="BPMNEdge_sid-752CE2F2-40EC-4140-AF60-BEACD06D43A7" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="274.95000000000005" y="90.0"></omgdi:waypoint>
          <omgdi:waypoint x="320.0" y="90.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-B12793A8-FC65-408C-81AD-EC81FEEF6E46" id="BPMNEdge_sid-B12793A8-FC65-408C-81AD-EC81FEEF6E46" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="419.95000000000005" y="124.0085106382979"></omgdi:waypoint>
          <omgdi:waypoint x="555.0" y="215.95744680851067"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-6C0130A8-E078-486B-9B6E-D8C14BBCD8EF" id="BPMNEdge_sid-6C0130A8-E078-486B-9B6E-D8C14BBCD8EF" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="654.9499999998701" y="250.0"></omgdi:waypoint>
          <omgdi:waypoint x="750.0" y="250.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-BE043A23-0F38-4ED9-A0D1-F4C2F7908A50" id="BPMNEdge_sid-BE043A23-0F38-4ED9-A0D1-F4C2F7908A50" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="605.0" y="129.95"></omgdi:waypoint>
          <omgdi:waypoint x="605.0" y="210.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-F85B2D44-1B42-4748-AB35-123C7CCD2F75" id="BPMNEdge_sid-F85B2D44-1B42-4748-AB35-123C7CCD2F75" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="419.95000000000005" y="90.0"></omgdi:waypoint>
          <omgdi:waypoint x="555.0" y="90.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

- 流程进行部署

  ```java
  
      /**
       * 流程的部署
       */
      @Test
      public void testDeploy() {
          //获取ProcessEngine对象
          ProcessEngine processEngine = ProcessEngines.getDefaultProcessEngine();
          //获取服务(repository，流程定义)
          RepositoryService repositoryService = processEngine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment()
                  .addClasspathResource("出差申请单.bpmn20.xml")
                  .name("请假流程") //流程名
                  .deploy();
          System.out.println("部署id" + deploy.getId());
          System.out.println("部署名" + deploy.getName());
  
      }
  ```

- 流程运行

  ```java
  
      /**
       * 流程实例的定义
       */
      @Test
      public void runProcess(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          RuntimeService runtimeService = processEngine.getRuntimeService();
          Map<String,Object> variables=new HashMap<>();
          variables.put("assignee0","张三");
          variables.put("assignee1","李四");
          variables.put("assignee2","王五");
          variables.put("assignee3","赵财务");
          ProcessInstance processInstance = runtimeService.
                  startProcessInstanceById("evection:1:4", variables);
  
  
  
      }
  ```

- //这时候节点走到张三了，让张三处理

  ```java
  
      /**
       * 任务完成
       */
      @Test
      public void taskComplete(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .processInstanceId("2501")
                  .taskAssignee("张三")
                  .singleResult();
          Map<String,Object> processVariables=task.getProcessVariables();
          processVariables.put("num",3);
          taskService.complete(task.getId(),processVariables);
      }
  ```

- 下面修改num的值，修改之前
  ![image-20220515113105628](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515113105628.png)

  - 全局变量的查询

    ```java
        @Test
        public void getVariables(){
            ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine(); 
            TaskService taskService = processEngine.getTaskService();
            Task task = taskService.createTaskQuery()
                    .includeProcessVariables() //注意，这个一定要加的不然获取不到全局变量
                    .processInstanceId("2501")
                    .taskAssignee("张三")
                    .singleResult();
            //这里只能获取到任务的局部变量
            Map<String, Object> processVariables = task.getProcessVariables();
            System.out.println("当前流程变量--start");
            Set<String> keySet1 = processVariables.keySet();
            for(String key:keySet1){
                System.out.println("key--"+key+"value--"+processVariables.get(key));
            }
            System.out.println("当前流程变量--end");
        }
    ```

    

  - 修改

    ```java
    
        @Test
        public void updateVariables(){
            ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
            TaskService taskService = processEngine.getTaskService();
            Task task = taskService.createTaskQuery()
                    .includeProcessVariables() //注意，这个一定要加的不然获取不到全局变量
                    .processInstanceId("2501")
                    .taskAssignee("李四")
                    .singleResult();
            Map<String, Object> processVariables = task.getProcessVariables();
            System.out.println("当前流程变量--start");
            Set<String> keySet = processVariables.keySet();
            for(String key:keySet){
                System.out.println("key--"+key+"value--"+processVariables.get(key));
            }
            System.out.println("当前流程变量--end");
            processVariables.put("num",5);
            taskService.setVariablesLocal(task.getId(),processVariables);
        }
    ```

    

  - 结果

    按照视频的说法，这里错了，应该是会多了5条记录
    ![image-20220515120415965](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515120415965.png)

- 局部变量的再次测试

  ```java
  
      @Test
      public void updateVariables(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("张三")
                  .singleResult();
          //流程还没开始运行的情况下，取到的是全局变量
          Map<String, Object> processVariables = task.getProcessVariables();
          System.out.println("当前流程变量--start");
          Set<String> keySet = processVariables.keySet();
          for(String key:keySet){
              System.out.println("key--"+key+"value--"+processVariables.get(key));
          }
          System.out.println("当前流程变量--end");
  
          Map<String,Object> varLocalInsert=new HashMap<>();
          varLocalInsert.put("num",5);
          Map<String,Object> varUpdate=new HashMap<>();
          varUpdate.put("a","嘿嘿");
          //这里测试会不会把全局变量全部覆盖
          taskService.setVariables(task.getId(),varUpdate);
          taskService.setVariablesLocal(task.getId(),varLocalInsert);
      }
  ```

  - 修改前
    ![image-20220515120817587](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515120817587.png)
  - 修改后
    ![image-20220515121223413](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515121223413.png)
    - 结果表明这是批量增加/修改，而不是覆盖

- 当前数据库的数据 1个局部变量num，5个全局变量
  ![image-20220515121439233](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515121439233.png)

- 接下来在张三节点设置一个局部变量

  ```java
  
      /**
       * 任务完成
       */
      @Test
      public void taskComplete(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .processInstanceId("2501")
                  .taskAssignee("张三")
                  .singleResult();
          Map<String,Object> processVariables=task.getProcessVariables();
          processVariables.put("num",2);
          taskService.complete(task.getId(),processVariables);
      }
  ```

  - 查看数据库表，发现num已经被修改成2

- 这时李四设置了一个局部变量num=6

  ```java
  
      @Test
      public void updateVariables2(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("李四")
                  .singleResult(); 
  
          Map<String,Object> varLocalInsert=new HashMap<>();
          varLocalInsert.put("num",6);
          Map<String,Object> varUpdate=new HashMap<>();
          varUpdate.put("a","嘿嘿");
          //这里测试会不会把全局变量全部覆盖
          //taskService.setVariables(task.getId(),varUpdate);
          taskService.setVariablesLocal(task.getId(),varLocalInsert);
      }
  ```

  仅仅多了一条记录
  ![image-20220515122216621](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515122216621.png)

- 修改全局变量

  ```java
  
      @Test
      public void updateVariables3(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("李四")
                  .singleResult();
  
          Map<String,Object> varLocalInsert=new HashMap<>();
          varLocalInsert.put("num",18);
          varLocalInsert.put("a","a被修改了");
          //这里测试会不会把全局变量全部覆盖
          //taskService.setVariables(task.getId(),varUpdate);
          taskService.setVariables(task.getId(),varLocalInsert);
      }
  ```

- 结果如下，**当局部变量和全局变量的名称一样时，只能修改局部变量**
  ![image-20220515122635345](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515122635345.png)

- 让李四完成审批
  这里存在局部变量num=18，且完成时设置了局部变量20

  ```java
  
      @Test
      public void taskComplete4(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("李四")
                  .singleResult();
          //
          System.out.println("taskId"+task.getId());
          Map<String,Object> map=new HashMap<>();
          map.put("num",20);
          taskService.complete(task.getId(),map);
      }
  ```

- 注意，这里全局变量被改成20了，局部变量被删除了
  ![image-20220515123339736](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515123339736.png)
  走到了总经理审批

- 再测试
  将数据清空，重新部署并运行流程

  现在在赵四节点，局部变量为
  ![image-20220515124117180](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515124117180.png)


  ```java
  
      @Test
      public void taskComplete4(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("李四")
                  .singleResult();
          //
          System.out.println("taskId"+task.getId());
          Map<String,Object> map=new HashMap<>();
          map.put("num",20);
          taskService.setVariablesLocal(task.getId(),map);
          taskService.complete(task.getId());
      }
  ```

  运行完之后，局部变量变成20了，但是流程走不下去
  稍作更改，添加一个全局变量(但是由于存在局部变量a，所以这里全局变量没设置成功)

  ```java
  
      @Test
      public void taskComplete4(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("李四")
                  .singleResult();
          //
          System.out.println("taskId"+task.getId());
          Map<String,Object> map=new HashMap<>();
          map.put("num",20);
          taskService.setVariablesLocal(task.getId(),map);
          Map<String,Object> map1=new HashMap<>();
          map1.put("num",1);
          taskService.setVariables(task.getId(),map1);
          taskService.complete(task.getId());
      }
  ```

- 现在只能通过在complete中设置，来使得全局变量生效

  ```java
  
      @Test
      public void taskComplete4(){
          ProcessEngine processEngine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("李四")
                  .singleResult();
          //
          System.out.println("taskId"+task.getId());
          Map<String,Object> map=new HashMap<>();
          map.put("num",null);
          taskService.setVariablesLocal(task.getId(),map);
  
          Map<String,Object> map1=new HashMap<>();
          map1.put("num",1);
          //taskService.setVariables(task.getId(),map1);
          taskService.complete(task.getId(),map1);
      }
  ```

  - 结果，全局变量设置成功，且任务流转到了财务那
    ![image-20220515124802205](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515124802205.png)

- 再测试

  - 在存在局部变量num=2的情况下执行下面代码

  	```java
  	
      @Test
      public void taskComplete5() {
          ProcessEngine processEngine = ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = processEngine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .includeProcessVariables()
                  .processInstanceId("2501")
                  .taskAssignee("李四")
                  .singleResult();
          //
          System.out.println("taskId" + task.getId());
          Map<String, Object> map = new HashMap<>();
          map.put("num", 15);
          taskService.setVariables(task.getId(), map);
          taskService.complete(task.getId());
          /*Map<String,Object> map1=new HashMap<>();
          map1.put("num",1);
          taskService.complete(task.getId(),map1);*/
      }
  	```
  	
  	会提示报错，Unknown property used in expression: ${num >= 3}
  	
  	//说明线条中查找的是全局变量
  	
  - 在不存在局部变量num的情况下执行上面代码，会走总经理审批（num>3)
  
  - 在complete中加上map参数，验证明线条查找的是全局变量的值，complete带上variables会设置全局变量
  
    ```java
    
        @Test
        public void taskComplete5() {
            ProcessEngine processEngine = ProcessEngines.getDefaultProcessEngine();
            TaskService taskService = processEngine.getTaskService();
            Task task = taskService.createTaskQuery()
                    .includeProcessVariables()
                    .processInstanceId("2501")
                    .taskAssignee("李四")
                    .singleResult();
            //
            System.out.println("taskId" + task.getId());
            Map<String, Object> map = new HashMap<>();
            map.put("num", 15);
           // taskService.setVariables(task.getId(), map);
            taskService.complete(task.getId(),map);
            /*Map<String,Object> map1=new HashMap<>();
            map1.put("num",1);
            taskService.complete(task.getId(),map1);*/
        }
    ```
  
    - 数据库表
      ![image-20220515130825823](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515130825823.png)
  
  - act_hi_varinst 里面看得到局部变量
  
- 
