---
title: boge-03-其他
description: '其他'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-19 16:13:44
updated: 2022-05-19 16:13:44
---

## 会签

- 流程图绘制
  ![image-20220519172038904](images/mypost/image-20220519172038904.png)

  - 注意上面几个参数

    - 多实例类型用来判断串行并行
    - 基数（有几个用户处理）
    - 元素变量
    - 集合（集合变量）
    - 完成条件--这里填的是 ${nrOfCompletedInstances > 1 }

  - 在任务监听器
    ![image-20220519171545786](images/mypost/image-20220519171545786.png)

    ```java
    package org.flowable.listener;
    
    import org.flowable.engine.ProcessEngine;
    import org.flowable.engine.ProcessEngines;
    import org.flowable.engine.TaskService;
    import org.flowable.engine.delegate.TaskListener;
    import org.flowable.task.api.Task;
    import org.flowable.task.service.delegate.DelegateTask;
    
    public class MultiInstanceTaskListener implements TaskListener {
    
        @Override
        public void notify(DelegateTask delegateTask) {
            System.out.println("处理aaaa");
            if(delegateTask.getEventName().equals("create")) {
                System.out.println("任务id" + delegateTask.getId());
                System.out.println("哪些人需要会签" + delegateTask.getVariable("persons"));
                System.out.println("任务处理人" + delegateTask.getVariable("person"));
                ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
                TaskService taskService = engine.getTaskService();
                Task task = taskService.createTaskQuery().taskId(delegateTask.getId()).singleResult();
                task.setAssignee(delegateTask.getVariable("person").toString());
                taskService.saveTask(task);
            }
        }
    }
    
    ```

  - 

  - xml

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
      <process id="join-key" name="会签测试1" isExecutable="true">
        <documentation>join-desc</documentation>
        <startEvent id="startEvent1" name="申请人" flowable:formFieldValidation="true"></startEvent>
        <userTask id="sid-477F728E-2F63-43BF-A278-76FBCF58B475" name="会签人员" flowable:formFieldValidation="true">
          <extensionElements>
            <flowable:taskListener event="create" class="org.flowable.listener.MultiInstanceTaskListener"></flowable:taskListener>
          </extensionElements>
          <multiInstanceLoopCharacteristics isSequential="false" flowable:collection="persons" flowable:elementVariable="person">
            <extensionElements></extensionElements>
            <loopCardinality>3</loopCardinality>
            <completionCondition>${nrOfCompletedInstances > 1 }</completionCondition>
          </multiInstanceLoopCharacteristics>
        </userTask>
        <sequenceFlow id="sid-B5F81E26-E53B-4D10-8328-C5B3C35E0DD5" sourceRef="startEvent1" targetRef="sid-477F728E-2F63-43BF-A278-76FBCF58B475"></sequenceFlow>
        <endEvent id="sid-3448D902-AE89-467D-8945-805BDEDE7BCA"></endEvent>
        <sequenceFlow id="sid-598B2F86-A13B-48BE-88AF-6B61CDA24EA7" sourceRef="sid-477F728E-2F63-43BF-A278-76FBCF58B475" targetRef="sid-3448D902-AE89-467D-8945-805BDEDE7BCA"></sequenceFlow>
      </process>
      <bpmndi:BPMNDiagram id="BPMNDiagram_join-key">
        <bpmndi:BPMNPlane bpmnElement="join-key" id="BPMNPlane_join-key">
          <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
            <omgdc:Bounds height="30.0" width="30.0" x="105.0" y="100.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-477F728E-2F63-43BF-A278-76FBCF58B475" id="BPMNShape_sid-477F728E-2F63-43BF-A278-76FBCF58B475">
            <omgdc:Bounds height="80.0" width="100.0" x="330.0" y="60.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-3448D902-AE89-467D-8945-805BDEDE7BCA" id="BPMNShape_sid-3448D902-AE89-467D-8945-805BDEDE7BCA">
            <omgdc:Bounds height="28.0" width="28.0" x="600.0" y="106.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNEdge bpmnElement="sid-B5F81E26-E53B-4D10-8328-C5B3C35E0DD5" id="BPMNEdge_sid-B5F81E26-E53B-4D10-8328-C5B3C35E0DD5" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
            <omgdi:waypoint x="134.94999855629513" y="115.0"></omgdi:waypoint>
            <omgdi:waypoint x="232.5" y="115.0"></omgdi:waypoint>
            <omgdi:waypoint x="232.5" y="100.0"></omgdi:waypoint>
            <omgdi:waypoint x="330.0" y="100.0"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
          <bpmndi:BPMNEdge bpmnElement="sid-598B2F86-A13B-48BE-88AF-6B61CDA24EA7" id="BPMNEdge_sid-598B2F86-A13B-48BE-88AF-6B61CDA24EA7" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
            <omgdi:waypoint x="429.95000000000005" y="100.0"></omgdi:waypoint>
            <omgdi:waypoint x="515.0" y="100.0"></omgdi:waypoint>
            <omgdi:waypoint x="515.0" y="120.0"></omgdi:waypoint>
            <omgdi:waypoint x="600.0" y="120.0"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
        </bpmndi:BPMNPlane>
      </bpmndi:BPMNDiagram>
    </definitions>
    ```

  - 

- 将流程部署

  ```java
  
      @Test
      public void deploy() {
          deleteAll();
          ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
          RepositoryService repositoryService = engine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment()
                  .addClasspathResource("会签测试1.bpmn20.xml")
                  .deploy();
          System.out.println("部署成功:" + deploy.getId());
      }
  ```

- 运行流程

  ```xml
  
      @Test
      public void run(){
          ProcessEngine defaultProcessEngine = ProcessEngines.getDefaultProcessEngine();
          RuntimeService runtimeService = defaultProcessEngine.getRuntimeService();
          HashMap<String,Object> map=new HashMap<>();
          ArrayList<String> persons=new ArrayList<>();
          persons.add("张三");
          persons.add("李四");
          persons.add("王五");
  
          map.put("persons",persons);
          ProcessInstance processInstance = runtimeService.startProcessInstanceById("join-key:1:17504",map);
      }
  ```

- 此时数据库会有三个任务
  ![image-20220519171653406](images/mypost/image-20220519171653406.png)

- 完成第一个任务

  ```java
  
      @Test
      public void completeTask(){
          //15020
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = engine.getTaskService();
          taskService.complete("20020");
      }
  ```

- 再完成一个任务后，流程会直接结束

  ```java
  
      @Test
      public void completeTask(){
          //15020
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = engine.getTaskService();
          taskService.complete("20028");
      }
  ```

- 流程结束

- 
