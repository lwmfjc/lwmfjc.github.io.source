---
title: 02-flowable进阶_2
description: '02-flowable进阶_2'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-14 23:31:13
updated: 2022-05-14 23:31:13
---

## Service服务接口

![image-20220514233449225](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514233449225.png)

- 各个Service类
  RepositoryService 资源管理类，流程定义、部署、文件
  RuntimeService 流程运行管理类，运行过程中（执行）
  TaskService 任务管理类
  HistoryService 历史管理类
  ManagerService 引擎管理类

## Flowable图标

BPMN2.0定义的一些图标

- 时间

![image-20220514233856102](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514233856102.png)

- 活动
  ![image-20220514234008644](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514234008644.png)
- 网关
  ![image-20220514234018899](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514234018899.png)
- 



## 流程部署深入解析

- 使用eclipse打包部署(没有eclipse环境，所以这里只有截图)
  将两个流程，打包为bar文件，然后放到项目resources文件夹中
  ![image-20220514235033874](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514235033874.png)![image-20220514235051403](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514235051403.png)

- 这里是为了测试一次部署多个流程（定义，图）
  代码如下
  ![image-20220514235134845](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514235134845.png)

- 部署完成后查看表结构

  - act_re_procdef

    部署id一样
    ![image-20220514235300573](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514235300573.png)

  - act_re_deployment
    ![image-20220514235344635](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514235344635.png)

  - 结论：部署和定义是1对多的关系

- 每次部署所涉及到的资源文件
  ![image-20220514235449058](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514235449058.png)

- 涉及到的三张表 

  - act_ge_bytearray
    ![image-20220514235610659](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220514235610659.png)

  - act_re_procdef
    category-->xml中的namespace
    name-->定义时起的名称
    key_--->xml中定义的id
    resource_name--->xml文件名称
    dgrm_resource_name-->生成图片名称
    suspension_state --> 是否被挂起

    tenant_id -- >谁部署的流程

  - act_re_deployment
    name_部署名

- 代码
  ![image-20220515000033931](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515000033931.png)

- 主要源码
  DeployCmd.class
  ![image-20220515000146834](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515000146834.png)

- DeploymentEntityManagerImpl.java
  ![image-20220515000232452](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515000232452.png)

- insert()方法
  插入并执行资源
  ![image-20220515000308747](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515000308747.png)
  点开里面的insert方法
  ![image-20220515000330794](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515000330794.png)

- AbstractDataManger.insert()
  ![image-20220515000405402](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220515000405402.png)

- 回到test类，deploy()方法最终就是完成了表结构的数据的操作（通过Mybatis）

## 流程的挂起和激活



## 启动流程的原理

## 处理流程的原理

## 流程结束的原理

## 任务分配

## 流程变量

## 候选人

## 候选人组

## 网关



