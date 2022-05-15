---
title: 02-flowable进阶_3
description: '02-flowable进阶_3'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-15 10:04:08
updated: 2022-05-15 10:04:08
---

## 任务分配

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

  - 

## 流程变量

## 候选人

## 候选人组

## 网关
