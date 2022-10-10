---
title: unsafe类
description: unsafe类
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 17:10:27
updated: 2022-10-10 17:10
---

```sun.misc.Unsafe```

提供执行低级别、不安全操作的方法，如直接访问系统内存资源、自主管理内存资源等，效率快，但由于有了操作内存空间的能力，会增加指针问题风险。且这些功能的实现依赖于本地方法，Java代码中只是声明方法头，具体实现规则交给贝蒂代码
![image-20221010172203732](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221010172203732.png)

### 为什么要使用本地方法

- 需要用到Java中不具备的依赖于操作系统的特性，跨平台的同时要实现对底层控制
- 对于其他语言已经完成的现成功能，可以使用Java调用
- 对时间敏感/性能要求非常高，有必要使用更为底层的语言