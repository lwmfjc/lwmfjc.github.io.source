---
title: 02-flowable进阶_6
description: '任务回退和自定义表单'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-15 16:57:08
updated: 2022-05-15 16:57:08
---

## 任务回退-串行回退

- 流程图绘制
  ![image-20220515170035810](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515170035810.png)

- xml

  ```java
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
    <process id="reback-key" name="回退处理" isExecutable="true">
      <documentation>reback-desc</documentation>
      <startEvent id="startEvent1" flowable:formFieldValidation="true"></startEvent>
      <userTask id="sid-D380E41A-48EE-4C08-AD01-1D509C512543" name="用户1" flowable:assignee="user1" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-E2423FC5-F954-43D3-B57C-8460057CB7D6" sourceRef="startEvent1" targetRef="sid-D380E41A-48EE-4C08-AD01-1D509C512543"></sequenceFlow>
      <userTask id="sid-AF50E3D0-2014-4308-A717-D76586837D70" name="用户2" flowable:assignee="user2" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-7C8750DC-E1C1-4AB2-B18C-2C103B61A5E5" sourceRef="sid-D380E41A-48EE-4C08-AD01-1D509C512543" targetRef="sid-AF50E3D0-2014-4308-A717-D76586837D70"></sequenceFlow>
      <userTask id="sid-F4CE7565-5977-4B9C-A603-AB3B817B8C8C" name="用户3" flowable:assignee="user3" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-F91582FE-D110-48C9-9407-605E503E42B2" sourceRef="sid-AF50E3D0-2014-4308-A717-D76586837D70" targetRef="sid-F4CE7565-5977-4B9C-A603-AB3B817B8C8C"></sequenceFlow>
      <userTask id="sid-727C1235-F9C1-4CC5-BC6C-E56ABCA105B0" name="用户4" flowable:assignee="user4" flowable:formFieldValidation="true">
        <extensionElements>
          <modeler:initiator-can-complete xmlns:modeler="http://flowable.org/modeler"><![CDATA[false]]></modeler:initiator-can-complete>
        </extensionElements>
      </userTask>
      <sequenceFlow id="sid-6D998C20-2A97-44B5-92D0-118E5CB05795" sourceRef="sid-F4CE7565-5977-4B9C-A603-AB3B817B8C8C" targetRef="sid-727C1235-F9C1-4CC5-BC6C-E56ABCA105B0"></sequenceFlow>
      <endEvent id="sid-6E5F5037-1979-4150-8408-D0BFD0315BCA"></endEvent>
      <sequenceFlow id="sid-3ECF3E34-6C07-4AE6-997B-583BF8868AC8" sourceRef="sid-727C1235-F9C1-4CC5-BC6C-E56ABCA105B0" targetRef="sid-6E5F5037-1979-4150-8408-D0BFD0315BCA"></sequenceFlow>
    </process>
    <bpmndi:BPMNDiagram id="BPMNDiagram_reback-key">
      <bpmndi:BPMNPlane bpmnElement="reback-key" id="BPMNPlane_reback-key">
        <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
          <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="163.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-D380E41A-48EE-4C08-AD01-1D509C512543" id="BPMNShape_sid-D380E41A-48EE-4C08-AD01-1D509C512543">
          <omgdc:Bounds height="80.0" width="100.0" x="165.0" y="135.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-AF50E3D0-2014-4308-A717-D76586837D70" id="BPMNShape_sid-AF50E3D0-2014-4308-A717-D76586837D70">
          <omgdc:Bounds height="80.0" width="100.0" x="320.0" y="138.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-F4CE7565-5977-4B9C-A603-AB3B817B8C8C" id="BPMNShape_sid-F4CE7565-5977-4B9C-A603-AB3B817B8C8C">
          <omgdc:Bounds height="80.0" width="100.0" x="465.0" y="138.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-727C1235-F9C1-4CC5-BC6C-E56ABCA105B0" id="BPMNShape_sid-727C1235-F9C1-4CC5-BC6C-E56ABCA105B0">
          <omgdc:Bounds height="80.0" width="100.0" x="610.0" y="138.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNShape bpmnElement="sid-6E5F5037-1979-4150-8408-D0BFD0315BCA" id="BPMNShape_sid-6E5F5037-1979-4150-8408-D0BFD0315BCA">
          <omgdc:Bounds height="28.0" width="28.0" x="755.0" y="164.0"></omgdc:Bounds>
        </bpmndi:BPMNShape>
        <bpmndi:BPMNEdge bpmnElement="sid-6D998C20-2A97-44B5-92D0-118E5CB05795" id="BPMNEdge_sid-6D998C20-2A97-44B5-92D0-118E5CB05795" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="564.9499999999907" y="178.0"></omgdi:waypoint>
          <omgdi:waypoint x="609.9999999999807" y="178.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-7C8750DC-E1C1-4AB2-B18C-2C103B61A5E5" id="BPMNEdge_sid-7C8750DC-E1C1-4AB2-B18C-2C103B61A5E5" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="264.9499999999882" y="175.0"></omgdi:waypoint>
          <omgdi:waypoint x="292.5" y="175.0"></omgdi:waypoint>
          <omgdi:waypoint x="292.5" y="178.0"></omgdi:waypoint>
          <omgdi:waypoint x="319.9999999999603" y="178.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-3ECF3E34-6C07-4AE6-997B-583BF8868AC8" id="BPMNEdge_sid-3ECF3E34-6C07-4AE6-997B-583BF8868AC8" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
          <omgdi:waypoint x="709.9499999999999" y="178.0"></omgdi:waypoint>
          <omgdi:waypoint x="755.0" y="178.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-E2423FC5-F954-43D3-B57C-8460057CB7D6" id="BPMNEdge_sid-E2423FC5-F954-43D3-B57C-8460057CB7D6" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="129.94340692927761" y="177.55019845363262"></omgdi:waypoint>
          <omgdi:waypoint x="164.99999999999906" y="176.4985"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
        <bpmndi:BPMNEdge bpmnElement="sid-F91582FE-D110-48C9-9407-605E503E42B2" id="BPMNEdge_sid-F91582FE-D110-48C9-9407-605E503E42B2" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
          <omgdi:waypoint x="419.94999999999067" y="178.0"></omgdi:waypoint>
          <omgdi:waypoint x="464.9999999999807" y="178.0"></omgdi:waypoint>
        </bpmndi:BPMNEdge>
      </bpmndi:BPMNPlane>
    </bpmndi:BPMNDiagram>
  </definitions>
  ```

- 部署并运行

- 依次完成1，2，3

  - 从任意节点跳转到任意节点

    ```java
    @Test
        public void backProcess(){
    
            ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
            RuntimeService runtimeService = engine.getRuntimeService();
            //从当前流程跳转到任意节点
            runtimeService.createChangeActivityStateBuilder()
                    .processInstanceId("2501")
                    //4-->3 ，活动id
                    .moveActivityIdTo("sid-727C1235-F9C1-4CC5-BC6C-E56ABCA105B0",
                            "sid-F4CE7565-5977-4B9C-A603-AB3B817B8C8C")
                    .changeState();
        }
    ```

  - 可以在这个表里让用户选择回退节点
    ![image-20220515170856822](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515170856822.png)

  - 此时让user3再完成任务

  - 注：用下面的方法，不关心当前节点，只写明要跳转的结点即可
    ![image-20220515171133458](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515171133458.png)

## 自定义表单
