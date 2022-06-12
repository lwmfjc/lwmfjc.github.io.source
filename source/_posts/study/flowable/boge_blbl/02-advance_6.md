---
title: boge-02-flowable进阶_6
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

### 内置表单

- 绘制
  ![image-20220515173247794](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515173247794.png)

  - xml

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:flowable="http://flowable.org/bpmn" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:omgdc="http://www.omg.org/spec/DD/20100524/DC" xmlns:omgdi="http://www.omg.org/spec/DD/20100524/DI" typeLanguage="http://www.w3.org/2001/XMLSchema" expressionLanguage="http://www.w3.org/1999/XPath" targetNamespace="http://www.flowable.org/processdef" exporter="Flowable Open Source Modeler" exporterVersion="6.7.2">
      <process id="form1-test-key" name="form1-test-name" isExecutable="true">
        <documentation>form1-test-desc</documentation>
        <startEvent id="startEvent1" flowable:formFieldValidation="true">
          <extensionElements>
            <flowable:formProperty id="days" name="天数" type="long" default="5"></flowable:formProperty>
            <flowable:formProperty id="start_time" name="开始时间" type="date" datePattern="MM-dd-yyyy"></flowable:formProperty>
            <flowable:formProperty id="reason" name="原因" type="string"></flowable:formProperty>
          </extensionElements>
        </startEvent>
        <userTask id="sid-4C9C8571-1423-4137-93FC-6A138D504E24" name="用户申请" flowable:formFieldValidation="true">
          <extensionElements>
            <flowable:formProperty id="days" name="天数" type="long"></flowable:formProperty>
            <flowable:formProperty id="start_time" name="开始时间" type="date" datePattern="MM-dd-yyyy"></flowable:formProperty>
            <flowable:formProperty id="reason" name="原因" type="string"></flowable:formProperty>
          </extensionElements>
        </userTask>
        <sequenceFlow id="sid-8944FE04-D27B-435F-A8A8-4E545AB3D6C0" sourceRef="startEvent1" targetRef="sid-4C9C8571-1423-4137-93FC-6A138D504E24"></sequenceFlow>
        <exclusiveGateway id="sid-35DD948A-C095-486E-98E0-4A0EEC4D9FBC"></exclusiveGateway>
        <sequenceFlow id="sid-0EA36B83-6115-414F-BC7D-9CB338B03F22" sourceRef="sid-4C9C8571-1423-4137-93FC-6A138D504E24" targetRef="sid-35DD948A-C095-486E-98E0-4A0EEC4D9FBC"></sequenceFlow>
        <userTask id="sid-4B6496FE-B5FE-41AC-83F8-4B7224B09FBD" name="总监审批" flowable:formFieldValidation="true"></userTask>
        <userTask id="sid-8DE5EA05-89D5-48B0-9359-F8ABFB3A3500" name="部门经理审批" flowable:formFieldValidation="true"></userTask>
        <exclusiveGateway id="sid-0EC09183-F41B-4785-83E7-423BB86EB013"></exclusiveGateway>
        <sequenceFlow id="sid-562C26B5-B634-4771-BF54-C311D56A5317" sourceRef="sid-4B6496FE-B5FE-41AC-83F8-4B7224B09FBD" targetRef="sid-0EC09183-F41B-4785-83E7-423BB86EB013"></sequenceFlow>
        <sequenceFlow id="sid-9AC3E009-D4D6-4D8B-883C-701E044715E9" sourceRef="sid-8DE5EA05-89D5-48B0-9359-F8ABFB3A3500" targetRef="sid-0EC09183-F41B-4785-83E7-423BB86EB013"></sequenceFlow>
        <endEvent id="sid-9CD52D35-7874-42F4-B392-466F71316BFE"></endEvent>
        <sequenceFlow id="sid-FABB64D1-0182-41D8-90FE-53FE7FE3F024" sourceRef="sid-0EC09183-F41B-4785-83E7-423BB86EB013" targetRef="sid-9CD52D35-7874-42F4-B392-466F71316BFE"></sequenceFlow>
        <sequenceFlow id="sid-E4DB6764-3EA3-427B-AD00-4D812E404FD6" sourceRef="sid-35DD948A-C095-486E-98E0-4A0EEC4D9FBC" targetRef="sid-4B6496FE-B5FE-41AC-83F8-4B7224B09FBD">
          <conditionExpression xsi:type="tFormalExpression"><![CDATA[${day > 3}]]></conditionExpression>
        </sequenceFlow>
        <sequenceFlow id="sid-585C37CB-61FE-4518-B3B6-5722A90A854F" sourceRef="sid-35DD948A-C095-486E-98E0-4A0EEC4D9FBC" targetRef="sid-8DE5EA05-89D5-48B0-9359-F8ABFB3A3500">
          <conditionExpression xsi:type="tFormalExpression"><![CDATA[${day <= 3}]]></conditionExpression>
        </sequenceFlow>
      </process>
      <bpmndi:BPMNDiagram id="BPMNDiagram_form1-test-key">
        <bpmndi:BPMNPlane bpmnElement="form1-test-key" id="BPMNPlane_form1-test-key">
          <bpmndi:BPMNShape bpmnElement="startEvent1" id="BPMNShape_startEvent1">
            <omgdc:Bounds height="30.0" width="30.0" x="100.0" y="163.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-4C9C8571-1423-4137-93FC-6A138D504E24" id="BPMNShape_sid-4C9C8571-1423-4137-93FC-6A138D504E24">
            <omgdc:Bounds height="80.0" width="100.0" x="175.0" y="138.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-35DD948A-C095-486E-98E0-4A0EEC4D9FBC" id="BPMNShape_sid-35DD948A-C095-486E-98E0-4A0EEC4D9FBC">
            <omgdc:Bounds height="40.0" width="40.0" x="315.0" y="150.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-4B6496FE-B5FE-41AC-83F8-4B7224B09FBD" id="BPMNShape_sid-4B6496FE-B5FE-41AC-83F8-4B7224B09FBD">
            <omgdc:Bounds height="80.0" width="100.0" x="405.0" y="30.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-8DE5EA05-89D5-48B0-9359-F8ABFB3A3500" id="BPMNShape_sid-8DE5EA05-89D5-48B0-9359-F8ABFB3A3500">
            <omgdc:Bounds height="80.0" width="100.0" x="405.0" y="225.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-0EC09183-F41B-4785-83E7-423BB86EB013" id="BPMNShape_sid-0EC09183-F41B-4785-83E7-423BB86EB013">
            <omgdc:Bounds height="40.0" width="40.0" x="585.0" y="165.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNShape bpmnElement="sid-9CD52D35-7874-42F4-B392-466F71316BFE" id="BPMNShape_sid-9CD52D35-7874-42F4-B392-466F71316BFE">
            <omgdc:Bounds height="28.0" width="28.0" x="670.0" y="171.0"></omgdc:Bounds>
          </bpmndi:BPMNShape>
          <bpmndi:BPMNEdge bpmnElement="sid-585C37CB-61FE-4518-B3B6-5722A90A854F" id="BPMNEdge_sid-585C37CB-61FE-4518-B3B6-5722A90A854F" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
            <omgdi:waypoint x="335.5" y="189.43998414376327"></omgdi:waypoint>
            <omgdi:waypoint x="335.5" y="265.0"></omgdi:waypoint>
            <omgdi:waypoint x="405.0" y="265.0"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
          <bpmndi:BPMNEdge bpmnElement="sid-E4DB6764-3EA3-427B-AD00-4D812E404FD6" id="BPMNEdge_sid-E4DB6764-3EA3-427B-AD00-4D812E404FD6" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
            <omgdi:waypoint x="336.66824324324324" y="151.67117117117118"></omgdi:waypoint>
            <omgdi:waypoint x="342.0" y="66.0"></omgdi:waypoint>
            <omgdi:waypoint x="404.9999999999999" y="68.23008849557522"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
          <bpmndi:BPMNEdge bpmnElement="sid-0EA36B83-6115-414F-BC7D-9CB338B03F22" id="BPMNEdge_sid-0EA36B83-6115-414F-BC7D-9CB338B03F22" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.5" flowable:targetDockerY="20.5">
            <omgdi:waypoint x="274.95000000000005" y="174.60633484162895"></omgdi:waypoint>
            <omgdi:waypoint x="316.77118644067775" y="171.76800847457628"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
          <bpmndi:BPMNEdge bpmnElement="sid-8944FE04-D27B-435F-A8A8-4E545AB3D6C0" id="BPMNEdge_sid-8944FE04-D27B-435F-A8A8-4E545AB3D6C0" flowable:sourceDockerX="15.0" flowable:sourceDockerY="15.0" flowable:targetDockerX="50.0" flowable:targetDockerY="40.0">
            <omgdi:waypoint x="129.9499984899576" y="178.0"></omgdi:waypoint>
            <omgdi:waypoint x="174.9999999999917" y="178.0"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
          <bpmndi:BPMNEdge bpmnElement="sid-FABB64D1-0182-41D8-90FE-53FE7FE3F024" id="BPMNEdge_sid-FABB64D1-0182-41D8-90FE-53FE7FE3F024" flowable:sourceDockerX="20.5" flowable:sourceDockerY="20.5" flowable:targetDockerX="14.0" flowable:targetDockerY="14.0">
            <omgdi:waypoint x="624.5591869398207" y="185.37820512820514"></omgdi:waypoint>
            <omgdi:waypoint x="670.0002755524882" y="185.08885188426405"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
          <bpmndi:BPMNEdge bpmnElement="sid-9AC3E009-D4D6-4D8B-883C-701E044715E9" id="BPMNEdge_sid-9AC3E009-D4D6-4D8B-883C-701E044715E9" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.0" flowable:targetDockerY="20.0">
            <omgdi:waypoint x="504.95000000000005" y="238.33333333333334"></omgdi:waypoint>
            <omgdi:waypoint x="591.9565217391304" y="191.93913043478258"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
          <bpmndi:BPMNEdge bpmnElement="sid-562C26B5-B634-4771-BF54-C311D56A5317" id="BPMNEdge_sid-562C26B5-B634-4771-BF54-C311D56A5317" flowable:sourceDockerX="50.0" flowable:sourceDockerY="40.0" flowable:targetDockerX="20.5" flowable:targetDockerY="20.5">
            <omgdi:waypoint x="504.95000000000005" y="70.0"></omgdi:waypoint>
            <omgdi:waypoint x="605.5" y="70.0"></omgdi:waypoint>
            <omgdi:waypoint x="605.5" y="165.5"></omgdi:waypoint>
          </bpmndi:BPMNEdge>
        </bpmndi:BPMNPlane>
      </bpmndi:BPMNDiagram>
    </definitions>
    ```

  - 将流程定义部署

    ```xml
    
        @Test
        public void deploy() {
            ProcessEngine engine = ProcessEngines.getDefaultProcessEngine();
            RepositoryService repositoryService = engine.getRepositoryService();
            Deployment deploy = repositoryService.createDeployment()
                    .addClasspathResource("form1-test-name.bpmn20.xml")
                    .deploy();
            System.out.println("部署成功:" + deploy.getId());
        }
    ```

  - 查看部署的流程内置的表单

    ```java
    
        @Test
        public void getStartForm(){
            ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
            FormService formService = engine.getFormService();
            StartFormData startFormData = formService.getStartFormData("form1-test-key:1:17504");
            List<FormProperty> formProperties =
                    startFormData.getFormProperties();
            for (FormProperty property:formProperties){
                System.out.println("id==>"+property.getId());
                System.out.println("name==>"+property.getName());
                System.out.println("value==>"+property.getValue());
            }
        }
    
    ```

    - ![image-20220515173832080](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515173832080.png)

  - 第一种启动方式，通过map
    ![image-20220515174011517](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515174011517.png)

  - 第二种启动方式

  - ```java
    @Test
    public void startProcess2(){
        ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
        FormService formService = engine.getFormService();
        Map<String,String> map=new HashMap<>();
        map.put("days","2");
        map.put("startTime","22020405");
        map.put("reason","想玩");
        formService.submitStartFormData("form1-test-key:1:17504",map);
    }
    ```

    - 注意查看act_ru_variable变量表
      ![image-20220515174247320](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515174247320.png)

  - 查看任务中的表单数据

    ```java
    
        /**
         * 查看对应的表单数据
         */
        @Test
        public void getTaskFormData(){
            ProcessEngine engine=ProcessEngines.getDefaultProcessEngine();
            FormService formService = engine.getFormService();
            TaskFormData taskFormData = formService.getTaskFormData("20012");
            List<FormProperty> formProperties = taskFormData.getFormProperties();
    
            for (FormProperty property:formProperties){
                System.out.println("id==>"+property.getId());
                System.out.println("name==>"+property.getName());
                System.out.println("value==>"+property.getValue());
            }
            //这里做一个测试，设置处理人
             /*TaskService taskService = engine.getTaskService();
           taskService.setAssignee("20012","lalala");*/
    
        }
    ```

  - 查看完成的任务【主要】//有点问题，不管
    ![image-20220515175944504](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515175944504.png)

### 外置表单

-  [flowable-ui中没找到，不知道是不是eclipse独有的]

- 
