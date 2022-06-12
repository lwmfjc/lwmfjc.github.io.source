---
title: boge-02-flowable进阶_5
description: '网关'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-15 15:51:40
updated: 2022-05-15 15:51:40
---

## 网关

![image-20220515155359395](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515155359395.png)

### 排他网关

会按照所有出口顺序流定义的顺序对它们进行计算，选择第一个条件计算为true的顺序流（**当没有设置条件时，认为顺序流为true**）继续流程

![image-20220515155535107](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515155535107.png)

- 排他网关的绘制
  ![image-20220515161442209](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515161442209.png)
  xml文件

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="holiday-exclusive" name="请假流程-排他网关" isExecutable="true">
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-3D5ED4D4-97F5-4FFD-B160-F00566ECC55E" name="创建请假单" flowable:assignee="zhangsan" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-33A73370-751D-413F-9306-39DEAA674DB6" sourceRef="startEvent1" targetRef="sid-3D5ED4D4-97F5-4FFD-B160-F00566ECC55E"></sequenceFlow>
      <exclusiveGateway id="sid-5B2117E6-D341-49F2-85B2-336CA836C7D8"></exclusiveGateway>
      <sequenceFlow id="sid-D1B1F6E0-EA7F-4FF7-AD0C-5D43DBCEBFD2" sourceRef="sid-3D5ED4D4-97F5-4FFD-B160-F00566ECC55E" targetRef="sid-5B2117E6-D341-49F2-85B2-336CA836C7D8"></sequenceFlow>
      <userTask id="sid-08A6CB64-C9BB-4342-852D-444A75315BDE" name="总经理审批" flowable:assignee="wangwu" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <userTask id="sid-EA98D0C3-E41D-4DEB-8933-91A1B7301ABE" name="部门经理审批" flowable:assignee="lisi" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <userTask id="sid-24F73F7F-EB61-484F-A494-686E194D0118" name="人事审批" flowable:assignee="zhaoliu" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-8BA0B88C-BA4F-446D-B5E7-6BF0830B1DC8" sourceRef="sid-EA98D0C3-E41D-4DEB-8933-91A1B7301ABE" targetRef="sid-24F73F7F-EB61-484F-A494-686E194D0118"></sequenceFlow>
      <sequenceFlow id="sid-E748F81F-B0B2-4C34-B993-FBAA2BCD0995" sourceRef="sid-08A6CB64-C9BB-4342-852D-444A75315BDE" targetRef="sid-24F73F7F-EB61-484F-A494-686E194D0118"></sequenceFlow>
      <sequenceFlow id="sid-928C6C6F-57F1-40F2-BE0F-1A9FF3E6E9E4" sourceRef="sid-5B2117E6-D341-49F2-85B2-336CA836C7D8" targetRef="sid-08A6CB64-C9BB-4342-852D-444A75315BDE">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num>3}]]></conditionExpression>
      </sequenceFlow>
      <sequenceFlow id="sid-4DB25720-11C8-401E-BB4C-83BB25510B2E" sourceRef="sid-5B2117E6-D341-49F2-85B2-336CA836C7D8" targetRef="sid-EA98D0C3-E41D-4DEB-8933-91A1B7301ABE">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num<3}]]></conditionExpression>
      </sequenceFlow>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_holiday-exclusive">
      <bpmndi:BPMNPlane bpmnElement="holiday-exclusive" id="BPMNPlane_holiday-exclusive">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="30.0" y="163.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-3D5ED4D4-97F5-4FFD-B160-F00566ECC55E" id="BPMNShape_sid-3D5ED4D4-97F5-4FFD-B160-F00566ECC55E">
          <omgdc:Bounds height="80.0" width="100.0" x="150.0" y="135.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-5B2117E6-D341-49F2-85B2-336CA836C7D8" id="BPMNShape_sid-5B2117E6-D341-49F2-85B2-336CA836C7D8">
          <omgdc:Bounds height="40.0" width="40.0" x="315.0" y="155.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-08A6CB64-C9BB-4342-852D-444A75315BDE" id="BPMNShape_sid-08A6CB64-C9BB-4342-852D-444A75315BDE">
          <omgdc:Bounds height="80.0" width="100.0" x="420.0" y="225.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-EA98D0C3-E41D-4DEB-8933-91A1B7301ABE" id="BPMNShape_sid-EA98D0C3-E41D-4DEB-8933-91A1B7301ABE">
          <omgdc:Bounds height="80.0" width="100.0" x="405.0" y="30.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-24F73F7F-EB61-484F-A494-686E194D0118" id="BPMNShape_sid-24F73F7F-EB61-484F-A494-686E194D0118">
          <omgdc:Bounds height="80.0" width="100.0" x="630.0" y="225.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-8BA0B88C-BA4F-446D-B5E7-6BF0830B1DC8" id="BPMNEdge_sid-8BA0B88C-BA4F-446D-B5E7-6BF0830B1DC8" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="504.95000000000005" y="70.0"></omgdi:waypoint>
          <omgdi:waypoint x="680.0" y="70.0"></omgdi:waypoint>
          <omgdi:waypoint x="680.0" y="225.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-4DB25720-11C8-401E-BB4C-83BB25510B2E" id="BPMNEdge_sid-4DB25720-11C8-401E-BB4C-83BB25510B2E" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="335.5" y="155.5"></omgdi:waypoint>
          <omgdi:waypoint x="335.5" y="70.0"></omgdi:waypoint>
          <omgdi:waypoint x="404.99999999996083" y="70.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-33A73370-751D-413F-9306-39DEAA674DB6" id="BPMNEdge_sid-33A73370-751D-413F-9306-39DEAA674DB6" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="59.94725673598754" y="177.70973069236373"></omgdi:waypoint>
          <omgdi:waypoint x="150.0" y="175.96677419354836"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-D1B1F6E0-EA7F-4FF7-AD0C-5D43DBCEBFD2" id="BPMNEdge_sid-D1B1F6E0-EA7F-4FF7-AD0C-5D43DBCEBFD2" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.5" flowable:targetDockerY="20.5">
          <omgdi:waypoint x="249.95000000000002" y="175.18431734317343"></omgdi:waypoint>
          <omgdi:waypoint x="315.42592592592536" y="175.42592592592592"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-E748F81F-B0B2-4C34-B993-FBAA2BCD0995" id="BPMNEdge_sid-E748F81F-B0B2-4C34-B993-FBAA2BCD0995" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="519.95" y="265.0"></omgdi:waypoint>
          <omgdi:waypoint x="629.9999999998776" y="265.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-928C6C6F-57F1-40F2-BE0F-1A9FF3E6E9E4" id="BPMNEdge_sid-928C6C6F-57F1-40F2-BE0F-1A9FF3E6E9E4" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="335.5" y="194.43942522321433"></omgdi:waypoint>
          <omgdi:waypoint x="335.5" y="265.0"></omgdi:waypoint>
          <omgdi:waypoint x="420.0" y="265.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

  

- 部署

  ```java
  
      @Test
      public void deploy(){
          ProcessEngine engine= ProcessEngines.getDefaultProcessEngine();
          RepositoryService repositoryService = engine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment()
                  .addClasspathResource("请假流程-排他网关.bpmn20.xml")
                  .deploy();
          System.out.println("部署成功:"+deploy);
      }
  ```

- 运行

  ```java
  
      @Test
      public void run() {
          ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
          RuntimeService runtimeService = engine.getRuntimeService();
          Map<String, Object> variables = new HashMap<>();
          variables.put("num", 2);
          runtimeService.startProcessInstanceById
                  ("holiday-exclusive:1:4", variables);
      }
  ```

  - 数据库
    ![image-20220515161800379](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515161800379.png)

- 张三完成任务

  ```java
  
      @Test
      public void taskComplete(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .taskAssignee("zhangsan")
                  .processInstanceId("2501")
                  .singleResult();
          taskService.complete(task.getId());
      }
  ```

  //接下来会走到部门经理审批

- 此时再ran一个num为4的实例，然后张三完成，此时会走到总经理审批

  - 
    ![image-20220515162344557](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515162344557.png)

- 注意，如果这里num设置为3，则会报错
  ![image-20220515162412014](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515162412014.png)

- 两者区别
  ![image-20220515162512860](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515162512860.png)
  如果上面的分支都不满足条件，那么会直接异常结束
  //如果使用排他网关，如果条件都不满足，流程和任务都还在，只是代码抛异常
  //如果两个都满足，那么会找出先定义的线走

### 并行网关

- 绘制流程图
  ![image-20220515163112903](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515163112903.png)

- xml文件

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="holiday-parr-key" name="请假流程-并行网关" isExecutable="true">
      <documentation>holiday-parr-descr</documentation>
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-47EAD72A-932E-4850-9218-08A7335CEEDD" name="创建请假单" flowable:assignee="zhangsan" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-8B72154F-6D29-47F8-A81C-A070F82B95F9" sourceRef="startEvent1" targetRef="sid-47EAD72A-932E-4850-9218-08A7335CEEDD"></sequenceFlow>
      <parallelGateway id="sid-8B323A3D-F6DA-4D38-9CAE-D4CDA1031343"></parallelGateway>
      <sequenceFlow id="sid-5F0BF3BD-BC7C-4AA0-AF87-F679C8EEB40B" sourceRef="sid-47EAD72A-932E-4850-9218-08A7335CEEDD" targetRef="sid-8B323A3D-F6DA-4D38-9CAE-D4CDA1031343"></sequenceFlow>
      <userTask id="sid-AEFBD42F-2A10-4630-8E56-EDBD35CC95B1" name="技术经理" flowable:assignee="lisi" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-49DBB929-7488-471A-B79C-6BBFF4C810E0" sourceRef="sid-8B323A3D-F6DA-4D38-9CAE-D4CDA1031343" targetRef="sid-AEFBD42F-2A10-4630-8E56-EDBD35CC95B1"></sequenceFlow>
      <userTask id="sid-8FB84D20-C946-4988-B4C4-16FFD899AF63" name="项目经理" flowable:assignee="wangwu" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-DCF940BC-05D4-4260-8C50-A4C6E291DEA3" sourceRef="sid-8B323A3D-F6DA-4D38-9CAE-D4CDA1031343" targetRef="sid-8FB84D20-C946-4988-B4C4-16FFD899AF63"></sequenceFlow>
      <parallelGateway id="sid-B25B9926-873F-46F5-9D62-D155462C1665"></parallelGateway>
      <sequenceFlow id="sid-18DF81F2-2B7F-4CC7-AD70-8A878FC7B125" sourceRef="sid-AEFBD42F-2A10-4630-8E56-EDBD35CC95B1" targetRef="sid-B25B9926-873F-46F5-9D62-D155462C1665"></sequenceFlow>
      <sequenceFlow id="sid-B00C2DDD-8A30-4BA0-A2F8-69185D8506F5" sourceRef="sid-8FB84D20-C946-4988-B4C4-16FFD899AF63" targetRef="sid-B25B9926-873F-46F5-9D62-D155462C1665"></sequenceFlow>
      <userTask id="sid-143837B7-0687-4268-B381-BA2442E39097" name="总经理" flowable:assignee="zjl" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <endEvent id="sid-5ACFE3BE-E094-43A9-85C5-7D438EFE5A97"></endEvent>
      <sequenceFlow id="sid-4255A9F7-39A1-46D3-AF14-DBEFF17AE911" sourceRef="sid-143837B7-0687-4268-B381-BA2442E39097" targetRef="sid-5ACFE3BE-E094-43A9-85C5-7D438EFE5A97"></sequenceFlow>
      <sequenceFlow id="sid-2F49B59A-6860-4101-8156-84780094E6FE" sourceRef="sid-B25B9926-873F-46F5-9D62-D155462C1665" targetRef="sid-5ACFE3BE-E094-43A9-85C5-7D438EFE5A97">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num <= 3}]]></conditionExpression>
      </sequenceFlow>
      <sequenceFlow id="sid-A5253FCB-3D23-483F-A511-197811F656D6" sourceRef="sid-B25B9926-873F-46F5-9D62-D155462C1665" targetRef="sid-143837B7-0687-4268-B381-BA2442E39097">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num > 3}]]></conditionExpression>
      </sequenceFlow>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_holiday-parr-key">
      <bpmndi:BPMNPlane bpmnElement="holiday-parr-key" id="BPMNPlane_holiday-parr-key">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="163.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-47EAD72A-932E-4850-9218-08A7335CEEDD" id="BPMNShape_sid-47EAD72A-932E-4850-9218-08A7335CEEDD">
          <omgdc:Bounds height="80.0" width="100.0" x="175.0" y="138.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-8B323A3D-F6DA-4D38-9CAE-D4CDA1031343" id="BPMNShape_sid-8B323A3D-F6DA-4D38-9CAE-D4CDA1031343">
          <omgdc:Bounds height="40.0" width="40.0" x="387.0" y="143.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-AEFBD42F-2A10-4630-8E56-EDBD35CC95B1" id="BPMNShape_sid-AEFBD42F-2A10-4630-8E56-EDBD35CC95B1">
          <omgdc:Bounds height="80.0" width="100.0" x="495.0" y="45.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-8FB84D20-C946-4988-B4C4-16FFD899AF63" id="BPMNShape_sid-8FB84D20-C946-4988-B4C4-16FFD899AF63">
          <omgdc:Bounds height="80.0" width="100.0" x="495.0" y="225.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-B25B9926-873F-46F5-9D62-D155462C1665" id="BPMNShape_sid-B25B9926-873F-46F5-9D62-D155462C1665">
          <omgdc:Bounds height="40.0" width="40.0" x="695.0" y="143.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-143837B7-0687-4268-B381-BA2442E39097" id="BPMNShape_sid-143837B7-0687-4268-B381-BA2442E39097">
          <omgdc:Bounds height="80.0" width="100.0" x="795.0" y="60.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-5ACFE3BE-E094-43A9-85C5-7D438EFE5A97" id="BPMNShape_sid-5ACFE3BE-E094-43A9-85C5-7D438EFE5A97">
          <omgdc:Bounds height="28.0" width="28.0" x="840.0" y="225.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-4255A9F7-39A1-46D3-AF14-DBEFF17AE911" id="BPMNEdge_sid-4255A9F7-39A1-46D3-AF14-DBEFF17AE911" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="847.586690647482" y="139.95"></omgdi:waypoint>
          <omgdi:waypoint x="853.095383523332" y="225.02614923910227"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-8B72154F-6D29-47F8-A81C-A070F82B95F9" id="BPMNEdge_sid-8B72154F-6D29-47F8-A81C-A070F82B95F9" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="129.9499984899576" y="178.0"></omgdi:waypoint>
          <omgdi:waypoint x="174.9999999999917" y="178.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-49DBB929-7488-471A-B79C-6BBFF4C810E0" id="BPMNEdge_sid-49DBB929-7488-471A-B79C-6BBFF4C810E0" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="404.70744680851067" y="145.2843450479233"></omgdi:waypoint>
          <omgdi:waypoint x="395.0" y="82.0"></omgdi:waypoint>
          <omgdi:waypoint x="494.9999999999998" y="84.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-2F49B59A-6860-4101-8156-84780094E6FE" id="BPMNEdge_sid-2F49B59A-6860-4101-8156-84780094E6FE" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="715.5" y="182.43746693121696"></omgdi:waypoint>
          <omgdi:waypoint x="715.5" y="239.0"></omgdi:waypoint>
          <omgdi:waypoint x="840.0" y="239.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-DCF940BC-05D4-4260-8C50-A4C6E291DEA3" id="BPMNEdge_sid-DCF940BC-05D4-4260-8C50-A4C6E291DEA3" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="407.5" y="182.44067421259845"></omgdi:waypoint>
          <omgdi:waypoint x="407.5" y="265.0"></omgdi:waypoint>
          <omgdi:waypoint x="494.9999999999674" y="265.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-A5253FCB-3D23-483F-A511-197811F656D6" id="BPMNEdge_sid-A5253FCB-3D23-483F-A511-197811F656D6" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="715.5" y="143.5"></omgdi:waypoint>
          <omgdi:waypoint x="715.5" y="90.0"></omgdi:waypoint>
          <omgdi:waypoint x="795.0" y="96.13899613899613"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-5F0BF3BD-BC7C-4AA0-AF87-F679C8EEB40B" id="BPMNEdge_sid-5F0BF3BD-BC7C-4AA0-AF87-F679C8EEB40B" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.0" flowable:targetDockerY="20.0">
          <omgdi:waypoint x="274.9499999999998" y="173.87912087912088"></omgdi:waypoint>
          <omgdi:waypoint x="388.52284263959393" y="164.5190355329949"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-18DF81F2-2B7F-4CC7-AD70-8A878FC7B125" id="BPMNEdge_sid-18DF81F2-2B7F-4CC7-AD70-8A878FC7B125" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.0" flowable:targetDockerY="20.0">
          <omgdi:waypoint x="594.95" y="107.91823529411766"></omgdi:waypoint>
          <omgdi:waypoint x="701.273276904474" y="156.70967741935485"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-B00C2DDD-8A30-4BA0-A2F8-69185D8506F5" id="BPMNEdge_sid-B00C2DDD-8A30-4BA0-A2F8-69185D8506F5" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.5" flowable:targetDockerY="20.5">
          <omgdi:waypoint x="594.95" y="235.23460410557183"></omgdi:waypoint>
          <omgdi:waypoint x="702.9632352941177" y="170.94457720588235"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

- 并行网关的条件会被忽略
  ![image-20220515163308541](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515163308541.png)

- 代码测试

  ```java
  //部署并运行
  
      @Test
      public void deploy() {
          ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
          RepositoryService repositoryService = engine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment()
                  .addClasspathResource("请假流程-并行网关.bpmn20.xml")
                  .deploy();
          System.out.println("部署成功:" + deploy.getId());
      }
  
      @Test
      public void run() {
          ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
          RuntimeService runtimeService = engine.getRuntimeService();
          Map<String, Object> variables = new HashMap<>();
          variables.put("num", 4);
          runtimeService.startProcessInstanceById
                  ("holiday-parr-key:1:12504", variables);
      }
  ```

- 此时任务停留在zhangsan
  ![image-20220515163545652](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515163545652.png)

- 让zhangsan完成任务

  ```java
  
      @Test
      public void taskComplete(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .taskAssignee("zhangsan")
                  .processInstanceId("15001")
                  .singleResult();
          taskService.complete(task.getId());
      }
  ```

- 查看表数据(一个任务包含多个执行实例)
  ![image-20220515163747247](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515163747247.png)

- 让王五和李四进行审批
  查看数据库，wangwu审批后，act_ru_task就少了一条记录
  ![image-20220515164011925](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515164011925.png)

- 此时走到总经理节点
  ![image-20220515164102982](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515164102982.png)

- 图解
  ![image-20220515164127110](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515164127110.png)

### 包容网关

- 包容网关可以选择多于一条顺序流。即固定几条必走，其他几条走条件

- 流程图
  ![image-20220515164830895](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515164830895.png)
  xml

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="holiday-inclusive" name="holiday-inclusive-name" isExecutable="true">
      <documentation>holiday-inclusive-desc</documentation>
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-6C2C29AA-C1D2-4B09-A542-ED194A13F5F2" name="创建请假单" flowable:assignee="i0" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-CAD92170-984F-49E0-BB6D-589B11F7FB8B" sourceRef="startEvent1" targetRef="sid-6C2C29AA-C1D2-4B09-A542-ED194A13F5F2"></sequenceFlow>
      <inclusiveGateway id="sid-46FAF12A-7430-4AFA-AABB-99B2D875C9CD"></inclusiveGateway>
      <sequenceFlow id="sid-CCD38C3B-C06F-4646-B979-F65C0CA26321" sourceRef="sid-6C2C29AA-C1D2-4B09-A542-ED194A13F5F2" targetRef="sid-46FAF12A-7430-4AFA-AABB-99B2D875C9CD"></sequenceFlow>
      <userTask id="sid-9AD9C288-F114-4AC6-9366-A09A786B068E" name="项目经理" flowable:assignee="i1" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <userTask id="sid-764DC717-439D-425E-83FF-D81BD08A2562" name="人事" flowable:assignee="i2" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-B8DE143C-4636-4F2C-99C9-8949E23B0042" sourceRef="sid-46FAF12A-7430-4AFA-AABB-99B2D875C9CD" targetRef="sid-764DC717-439D-425E-83FF-D81BD08A2562"></sequenceFlow>
      <userTask id="sid-AC8D2717-5BCD-4C5B-81BB-2FF66CFFC615" name="技术经理" flowable:assignee="i3" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <inclusiveGateway id="sid-6449A9C8-B7A3-44EE-BEDF-154AF323B1A8"></inclusiveGateway>
      <sequenceFlow id="sid-A52331B4-3769-46D8-AAC1-C34214C729BD" sourceRef="sid-9AD9C288-F114-4AC6-9366-A09A786B068E" targetRef="sid-6449A9C8-B7A3-44EE-BEDF-154AF323B1A8"></sequenceFlow>
      <sequenceFlow id="sid-681E9C5D-AD4B-45DD-BF12-E2CD5304ADFB" sourceRef="sid-764DC717-439D-425E-83FF-D81BD08A2562" targetRef="sid-6449A9C8-B7A3-44EE-BEDF-154AF323B1A8"></sequenceFlow>
      <sequenceFlow id="sid-78E79754-E64A-4ADE-A9BB-F9B224D3A5A0" sourceRef="sid-AC8D2717-5BCD-4C5B-81BB-2FF66CFFC615" targetRef="sid-6449A9C8-B7A3-44EE-BEDF-154AF323B1A8"></sequenceFlow>
      <exclusiveGateway id="sid-65D4D76B-AD2B-4AE9-8E78-7B8C33BD9E55"></exclusiveGateway>
      <sequenceFlow id="sid-422FC4A8-B667-4271-9CB3-A1D2CFEFC5E1" sourceRef="sid-6449A9C8-B7A3-44EE-BEDF-154AF323B1A8" targetRef="sid-65D4D76B-AD2B-4AE9-8E78-7B8C33BD9E55"></sequenceFlow>
      <userTask id="sid-4B834200-7995-453B-BC08-AF93C9F29FCF" name="总经理" flowable:assignee="wz" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <endEvent id="sid-7296D067-FF72-49F9-B416-2452640A0FBC"></endEvent>
      <sequenceFlow id="sid-AD0571E9-839D-4F1F-89ED-05BE60F841FD" sourceRef="sid-4B834200-7995-453B-BC08-AF93C9F29FCF" targetRef="sid-7296D067-FF72-49F9-B416-2452640A0FBC"></sequenceFlow>
      <sequenceFlow id="sid-E808AF78-E258-4997-B4FE-C393D8EBA3B9" sourceRef="sid-46FAF12A-7430-4AFA-AABB-99B2D875C9CD" targetRef="sid-9AD9C288-F114-4AC6-9366-A09A786B068E">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num>3}]]></conditionExpression>
      </sequenceFlow>
      <sequenceFlow id="sid-E4AD02E7-A69A-4684-9A00-DE9B11711348" sourceRef="sid-46FAF12A-7430-4AFA-AABB-99B2D875C9CD" targetRef="sid-AC8D2717-5BCD-4C5B-81BB-2FF66CFFC615">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num <= 3}]]></conditionExpression>
      </sequenceFlow>
      <sequenceFlow id="sid-A6760B6A-B74F-4D35-93C2-6653751F8873" sourceRef="sid-65D4D76B-AD2B-4AE9-8E78-7B8C33BD9E55" targetRef="sid-4B834200-7995-453B-BC08-AF93C9F29FCF">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num > 3}]]></conditionExpression>
      </sequenceFlow>
      <sequenceFlow id="sid-97A0DAB9-564D-4A62-92A4-26C7056CD347" sourceRef="sid-65D4D76B-AD2B-4AE9-8E78-7B8C33BD9E55" targetRef="sid-7296D067-FF72-49F9-B416-2452640A0FBC">
        <conditionExpression xsi:type="tFormalExpression"><![CDATA[${num<=3 }]]></conditionExpression>
      </sequenceFlow>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_holiday-inclusive">
      <bpmndi:BPMNPlane bpmnElement="holiday-inclusive" id="BPMNPlane_holiday-inclusive">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="163.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-6C2C29AA-C1D2-4B09-A542-ED194A13F5F2" id="BPMNShape_sid-6C2C29AA-C1D2-4B09-A542-ED194A13F5F2">
          <omgdc:Bounds height="80.0" width="100.0" x="195.0" y="135.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-46FAF12A-7430-4AFA-AABB-99B2D875C9CD" id="BPMNShape_sid-46FAF12A-7430-4AFA-AABB-99B2D875C9CD">
          <omgdc:Bounds height="40.0" width="40.0" x="366.0" y="145.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-9AD9C288-F114-4AC6-9366-A09A786B068E" id="BPMNShape_sid-9AD9C288-F114-4AC6-9366-A09A786B068E">
          <omgdc:Bounds height="80.0" width="100.0" x="451.0" y="30.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-764DC717-439D-425E-83FF-D81BD08A2562" id="BPMNShape_sid-764DC717-439D-425E-83FF-D81BD08A2562">
          <omgdc:Bounds height="80.0" width="100.0" x="450.0" y="120.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-AC8D2717-5BCD-4C5B-81BB-2FF66CFFC615" id="BPMNShape_sid-AC8D2717-5BCD-4C5B-81BB-2FF66CFFC615">
          <omgdc:Bounds height="80.0" width="100.0" x="465.0" y="255.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-6449A9C8-B7A3-44EE-BEDF-154AF323B1A8" id="BPMNShape_sid-6449A9C8-B7A3-44EE-BEDF-154AF323B1A8">
          <omgdc:Bounds height="40.0" width="40.0" x="656.0" y="137.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-65D4D76B-AD2B-4AE9-8E78-7B8C33BD9E55" id="BPMNShape_sid-65D4D76B-AD2B-4AE9-8E78-7B8C33BD9E55">
          <omgdc:Bounds height="40.0" width="40.0" x="750.0" y="137.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-4B834200-7995-453B-BC08-AF93C9F29FCF" id="BPMNShape_sid-4B834200-7995-453B-BC08-AF93C9F29FCF">
          <omgdc:Bounds height="80.0" width="100.0" x="855.0" y="60.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-7296D067-FF72-49F9-B416-2452640A0FBC" id="BPMNShape_sid-7296D067-FF72-49F9-B416-2452640A0FBC">
          <omgdc:Bounds height="28.0" width="28.0" x="900.0" y="240.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-681E9C5D-AD4B-45DD-BF12-E2CD5304ADFB" id="BPMNEdge_sid-681E9C5D-AD4B-45DD-BF12-E2CD5304ADFB" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.0" flowable:targetDockerY="20.0">
          <omgdi:waypoint x="549.9499999999988" y="159.14772727272728"></omgdi:waypoint>
          <omgdi:waypoint x="656.3351955307262" y="157.33435754189946"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-CCD38C3B-C06F-4646-B979-F65C0CA26321" id="BPMNEdge_sid-CCD38C3B-C06F-4646-B979-F65C0CA26321" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.0" flowable:targetDockerY="20.0">
          <omgdi:waypoint x="294.94999999999993" y="171.45390070921985"></omgdi:waypoint>
          <omgdi:waypoint x="367.32450331125824" y="166.32119205298014"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-AD0571E9-839D-4F1F-89ED-05BE60F841FD" id="BPMNEdge_sid-AD0571E9-839D-4F1F-89ED-05BE60F841FD" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="907.3347402597402" y="139.95"></omgdi:waypoint>
          <omgdi:waypoint x="913.1831773972388" y="240.02104379436742"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-A6760B6A-B74F-4D35-93C2-6653751F8873" id="BPMNEdge_sid-A6760B6A-B74F-4D35-93C2-6653751F8873" flowable:sourceDockerX="22.5" flowable:sourceDockerY="7.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="775.8406515580737" y="142.87818696883852"></omgdi:waypoint>
          <omgdi:waypoint x="855.0" y="116.58716981132078"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-B8DE143C-4636-4F2C-99C9-8949E23B0042" id="BPMNEdge_sid-B8DE143C-4636-4F2C-99C9-8949E23B0042" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="405.4272235576724" y="165.5"></omgdi:waypoint>
          <omgdi:waypoint x="428.0" y="165.5"></omgdi:waypoint>
          <omgdi:waypoint x="428.0" y="160.0"></omgdi:waypoint>
          <omgdi:waypoint x="449.99999999999346" y="160.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-422FC4A8-B667-4271-9CB3-A1D2CFEFC5E1" id="BPMNEdge_sid-422FC4A8-B667-4271-9CB3-A1D2CFEFC5E1" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="20.5" flowable:targetDockerY="20.5">
          <omgdi:waypoint x="695.4399309245483" y="157.5"></omgdi:waypoint>
          <omgdi:waypoint x="750.5" y="157.5"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-97A0DAB9-564D-4A62-92A4-26C7056CD347" id="BPMNEdge_sid-97A0DAB9-564D-4A62-92A4-26C7056CD347" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="770.5" y="176.44111163227018"></omgdi:waypoint>
          <omgdi:waypoint x="770.5" y="264.0"></omgdi:waypoint>
          <omgdi:waypoint x="900.033302364888" y="254.96981315483313"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-A52331B4-3769-46D8-AAC1-C34214C729BD" id="BPMNEdge_sid-A52331B4-3769-46D8-AAC1-C34214C729BD" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.0" flowable:targetDockerY="20.0">
          <omgdi:waypoint x="550.95" y="94.83228571428573"></omgdi:waypoint>
          <omgdi:waypoint x="662.6257153758107" y="150.3587786259542"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-E808AF78-E258-4997-B4FE-C393D8EBA3B9" id="BPMNEdge_sid-E808AF78-E258-4997-B4FE-C393D8EBA3B9" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="386.5" y="145.5"></omgdi:waypoint>
          <omgdi:waypoint x="386.5" y="70.0"></omgdi:waypoint>
          <omgdi:waypoint x="451.0" y="70.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-CAD92170-984F-49E0-BB6D-589B11F7FB8B" id="BPMNEdge_sid-CAD92170-984F-49E0-BB6D-589B11F7FB8B" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="129.94999191137833" y="178.0"></omgdi:waypoint>
          <omgdi:waypoint x="162.5" y="178.0"></omgdi:waypoint>
          <omgdi:waypoint x="162.5" y="175.0"></omgdi:waypoint>
          <omgdi:waypoint x="194.99999999998522" y="175.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-E4AD02E7-A69A-4684-9A00-DE9B11711348" id="BPMNEdge_sid-E4AD02E7-A69A-4684-9A00-DE9B11711348" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="386.5" y="184.4426890432099"></omgdi:waypoint>
          <omgdi:waypoint x="386.5" y="295.0"></omgdi:waypoint>
          <omgdi:waypoint x="465.0" y="295.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-78E79754-E64A-4ADE-A9BB-F9B224D3A5A0" id="BPMNEdge_sid-78E79754-E64A-4ADE-A9BB-F9B224D3A5A0" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.0" flowable:targetDockerY="20.0">
          <omgdi:waypoint x="561.6083333333333" y="255.0"></omgdi:waypoint>
          <omgdi:waypoint x="665.2307692307692" y="166.20769230769233"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

- 部署并运行

  ```java
  
      @Test
      public void deploy() {
          ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
          RepositoryService repositoryService = engine.getRepositoryService();
          Deployment deploy = repositoryService.createDeployment()
                  .addClasspathResource("holiday-inclusive-name.bpmn20.xml")
                  .deploy();
          System.out.println("部署成功:" + deploy.getId());
      }
  
      @Test
      public void run() {
          ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
          RuntimeService runtimeService = engine.getRuntimeService();
          Map<String, Object> variables = new HashMap<>();
          variables.put("num", 4);
          runtimeService.startProcessInstanceById
                  ("holiday-inclusive:1:4", variables);
      }
  ```

- i0完成任务

  ```java
  
  
      @Test
      public void taskComplete(){
          ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
          TaskService taskService = engine.getTaskService();
          Task task = taskService.createTaskQuery()
                  .taskAssignee("i0")
                  .processInstanceId("2501")
                  .singleResult();
          taskService.complete(task.getId());
      }
  ```

- 看数据，默认走人事和项目经理
  ![image-20220515165318571](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515165318571.png)

- i1,i2所在任务执行完后，会发现走总经理
  i1走完之后
  ![image-20220515165402581](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515165402581.png)

  - i2走的时候，把num设为1，直接结束

    ```java
    
        @Test
        public void taskComplete(){
            ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
            TaskService taskService = engine.getTaskService();
            Task task = taskService.createTaskQuery()
                    .taskAssignee("i2")
                    .processInstanceId("2501")
                    .singleResult();
            taskService.setVariable(task.getId(),
                    "num",1);
            taskService.complete(task.getId());
        }
    ```

- 

### 事件网关

![image-20220515165548361](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515165548361.png)

