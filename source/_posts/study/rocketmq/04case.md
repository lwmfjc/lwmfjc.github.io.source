---
title: 案例
description: 案例
tags:
  - rocketmq-hm
categories:
  - 学习
date: 2023-04-08 11:00:03
updated: 2023-04-08 11:00:03
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!

# 基本架构

## 架构

![image-20230408110058117](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230408110058117.png)

## 流程图

### 下单流程

![image-20230408110159464](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230408110159464.png)

### 支付流程

![image-20230408110224334](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230408110224334.png)

# SpringBoot整合RocketMQ

## 依赖包

```xml
	   <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-spring-boot-starter</artifactId>
        </dependency>

```

## 生产者

### yaml

```yaml
rocketmq:
  name-server: 192.168.1.135:9876;192.168.1.138:9876
  producer:
    group: my-group
```

### 使用

```java
    @Autowired
    private RocketMQTemplate template;

    @RequestMapping("rocketmq")
    public String rocketmq(){
        log.info("我被调用了-rocketmq");
        //主题+内容
        template.convertAndSend("mytopic-ly","hello1231");
        return "hello world"+serverPort;
    }
```

## 消费者

### yaml

```yaml
rocketmq:
  name-server: 192.168.1.135:9876;192.168.1.138:9876
  consumer:
    group: my-group2
```

### 使用

创建监听器

```java
@RocketMQMessageListener(topic = "mytopic-ly",
        consumeMode = ConsumeMode.CONCURRENTLY,consumerGroup = "${rocketmq.producer.group}")
@Slf4j
@Component
public class Consumer implements RocketMQListener<String> {

    @Override
    public void onMessage(String s) {
        log.info("消费了"+s);
    }
}
```



