---
title: 01-xxx_git_尚硅谷
description: '01-xxx_git_尚硅谷'
categories:
  - 学习
tags:
  - git_尚硅谷
date: 2022-07-20 21:57:18
updated: 2022-07-20 21:57:18
---

# 概述

## 课程介绍
   1.  Git
      - git介绍--分布式版本控制+集中式版本控制
      - git安装--基于官网，2.31.1  windows
      - 基于开发案例 详细讲解常用命令
      - git分支---特性、创建、转换、合并、代码合并冲突解决
      - idea集成git
   2. Github
      - 如何创建远程库
      - 推送 push
      - 拉取 pull
      - 克隆 clone
      - ssh免密登录
      - idea github集成
   3. Gitee码云
      - 码云创建远程库
      - Idea集成Gitee
   4. Gitlab
      - gitlab服务器的搭建和部署
      - idea集成gitlab
   5.  课程目标：五个小时，熟练掌握git、github、gitee

## 官网介绍
   1. git是免费的开源的分布式版本控制系统 
   2. 廉价的本地库
   3. 分支功能
      ![image-20220721213708758](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220721213708758.png)
   4. Everything is local

## 版本控制介绍
   1. 记录文件内容变化，以便将来查阅特定版本修订记录的系统
   2. 如果没有git
      ![image-20220721213950707](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220721213950707.png)
   3. 为什么需要版本控制（从个人开发过渡到团队合作）
      ![image-20220721214338521](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220721214338521.png)

## 分布式版本控制VS集中式版本控制
1.  SVN，单一的集中管理的服务器，保存所有文件的修订版本。其他人都先连到这个中央服务器上获取最新处理是否冲突
   ![image-20220721231138140](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220721231138140.png)
   - 缺点，单点故障，如果某段时间内故障了，那么就没法提交
2. Git，每台电脑都是代码库
   ![image-20220721231509683](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220721231509683.png)
   - 如果远程库挂了，本地还是可以做版本控制的，只不过不能做代码推送而已
   - 每个客户端保存的都是完整的项目（包括历史记录）

## 发展历史  

1. linux系统版本控制历史
   - 1991-2002 手动合并
   - 2002 BitKeeper授权Linux社区免费使用（版本控制系统）
     - 社区将其破解
   - 2005 用C语言开发了一个分布式版本控制系统：Git
     两周开发时间
   - 2008年 GitHub上线

## 工作机制和代码托管中心

![image-20220721232308526](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220721232308526.png)

1. 如果git commit ，那么这里的历史版本是删不掉的
2. 如果只是在工作区，或者添加到了暂存区，那么是可以恢复的

# 安装

1. git安装、客户端使用

# 命令

1. 命令-设置用户签名
2. 初始化本地库
3. 查看本地库状态
4. 添加暂存区
5. 提交本地库
6. 修改命令
7. 版本穿梭

# 分支

1. 概述和优点
2. 查看&创建&切换
3. 合并分支（正常合并）
4. 合并分支（冲突合并） 
