---
title: "git使用ssh连不上"
date: 2022-04-22
draft: false
updated: 2022-04-23
description: 处理方法
categories:
 - "问题"
tags:
 - "git问题"
 
---

- 处理方式
  在系统的host文件中，添加ip指定

  ```tex
  199.232.69.194 github.global.ssl.fastly.net
  140.82.114.4 github.com
  ```

- 