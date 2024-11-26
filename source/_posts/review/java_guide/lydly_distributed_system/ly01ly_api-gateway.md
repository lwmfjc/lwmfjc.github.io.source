---
title: api网关
description: api网关
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-distributed_system
date: 2023-02-10 22:26:59
updated: 2023-02-10 22:26:59
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

## 什么是网关？有什么用？

微服务背景下，一个系统被**拆分为多个服务**，但是像**安全认证**，**流量控制**，**日志**，**监控**等功能是每个服务都需要的，没有网关的话，我们就需要在**每个服务**中单独实现，这使得我们做了很多重复的事情并且没有一个**全局的视图来统一管理**这些功能。

![lyx-20241126133902103.png](attachments/img/lyx-20241126133902103.png)


一般情况下，网关可以为我们提供**请求转发**、**安全认证（身份/权限认证）**、**流量控制**、**负载均衡**、**降级熔断**、**日志**、**监控**等功能。

上面介绍了这么多功能，实际上，网关主要做了一件事情：**请求过滤** 。

## 有哪些常见的网关系统？

### Netflix Zuul

Zuul 是 Netflix 开发的一款提供**动态路由**、**监控**、**弹性**、**安全**的网关服务。

Zuul 主要通过**过滤器（类似于 AOP）来过滤请求**，从而实现网关必备的各种功能。

![Zuul架构](attachments/img/lyx-20241126133902651.jpg)

我们可以自定义过滤器来处理请求，并且，Zuul 生态本身就有很多现成的过滤器供我们使用。就比如限流可以直接用国外朋友写的 [spring-cloud-zuul-ratelimit](https://github.com/marcosbarbero/spring-cloud-zuul-ratelimit) (这里只是举例说明，一般是配合 hystrix 来做限流)：

```
<dependency>
  <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
</dependency>
<dependency>
    <groupId>com.marcosbarbero.cloud</groupId>
    <artifactId>spring-cloud-zuul-ratelimit</artifactId>
    <version>2.2.0.RELEASE</version>
</dependency>
```

Zuul 1.x **基于同步 IO，性能较差**。Zuul 2.x **基于 Netty 实现了异步 IO**，性能得到了大幅改进。

- Github 地址 ： https://github.com/Netflix/zuul
- 官方 Wiki ： https://github.com/Netflix/zuul/wiki

### Spring Cloud Gateway

SpringCloud Gateway 属于 Spring Cloud 生态系统中的网关，其诞生的目标是为了替代老牌网关 **Zuul **。准确点来说，应该是 **Zuul 1.x**。SpringCloud Gateway 起步要比 Zuul 2.x 更早。

为了提升网关的性能，SpringCloud Gateway **基于 Spring WebFlux** 。Spring WebFlux 使用 Reactor 库来实现**响应式编程模型**，**底层基于 Netty 实现异步 IO**。

Spring Cloud Gateway 的目标，不仅**提供统一的路由**方式，并且基于 Filter 链的方式提供了网关基本的功能，例如：**安全**，**监控/指标**，和**限流**。

Spring Cloud Gateway 和 Zuul 2.x 的差别不大，也是**通过过滤器**来处理请求。不过，目前更加推荐使用 Spring Cloud Gateway 而非 Zuul，**Spring Cloud 生态对其支持更加友好**。

- Github 地址 ： https://github.com/spring-cloud/spring-cloud-gateway
- 官网 ： https://spring.io/projects/spring-cloud-gateway

### Kong

Kong 是一款基于 [OpenResty](https://github.com/openresty/) 的高性能、云原生、可扩展的网关系统。

> OpenResty 是一个基于 Nginx 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

Kong 提供了插件机制来扩展其功能。比如、在服务上启用 Zipkin 插件

```
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=zipkin"  \
    --data "config.http_endpoint=http://your.zipkin.collector:9411/api/v2/spans" \
    --data "config.sample_ratio=0.001"
```

- Github 地址： https://github.com/Kong/kong
- 官网地址 ： https://konghq.com/kong

### APISIX

APISIX 是一款**基于 Nginx 和 etcd** 的高性能、云原生、可扩展的网关系统。

> *etcd*是使用 **Go 语言**开发的一个开源的、高可用的分布式 key-value 存储系统，使用 Raft 协议做分布式共识。

与传统 API 网关相比，APISIX 具有**动态路由**和**插件热加载**，特别适合微服务系统下的 API 管理。并且，APISIX 与 SkyWalking（分布式链路追踪系统）、Zipkin（分布式链路追踪系统）、Prometheus（监控系统） 等 DevOps 生态工具对接都十分方便。

![apisix架构图](attachments/img/lyx-20241126133903100.jpg)

作为 NGINX 和 Kong 的替代项目，APISIX 目前已经是 Apache 顶级开源项目，并且是最快毕业的国产开源项目。国内目前已经有很多知名企业（比如金山、有赞、爱奇艺、腾讯、贝壳）使用 APISIX 处理核心的业务流量。

根据官网介绍：“APISIX 已经生产可用，功能、性能、架构全面优于 Kong”。

- Github 地址 ：https://github.com/apache/apisix
- 官网地址： https://apisix.apache.org/zh/

相关阅读：

- [有了 NGINX 和 Kong，为什么还需要 Apache APISIX](https://www.apiseven.com/zh/blog/why-we-need-Apache-APISIX)
- [APISIX 技术博客](https://www.apiseven.com/zh/blog)
- [APISIX 用户案例](https://www.apiseven.com/zh/usercases)

### Shenyu

Shenyu 是一款**基于 WebFlux 的可扩展、高性能、响应式网关**，**Apache 顶级开源项目**。

![Shenyu架构](attachments/img/lyx-20241126133903538.jpg)

Shenyu 通过插件扩展功能，**插件**是 ShenYu 的灵魂，并且插件也是可扩展和热插拔的。不同的插件实现不同的功能。Shenyu 自带了诸如**限流、熔断、转发 、重写、重定向、和路由监控**等插件。

- Github 地址： https://github.com/apache/incubator-shenyu
- 官网地址 ： https://shenyu.apache.org/