---
title: 收发消息
description: 收发消息
tags:
  - rocketmq-hm
categories:
  - 学习
date: 2022-04-07 14:31:59
updated: 2022-04-07 14:31:59
---

> 学习来源 https://www.bilibili.com/video/BV1L4411y7mn（添加小部分笔记）感谢作者!前提

## 依赖包

```xml
		<dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-client</artifactId>
            <version>4.4.0</version>
        </dependency>
```

## 消息生产者步骤

创建生产者，生产者组名-->指定nameserver地址-->启动producer-->

创建消息对象(Topic、Tag、消息体)

发送消息、关闭生产者producer

## 消息消费者步骤

创建消费者，制定消费者组名-->指定nameserver地址

订阅Topic和Tag，设置回调函数处理消息

启动消费者consumer

# 消息发送

## 同步消息

发送消息后客户端会进行阻塞，直到得到结果后，客户端才会继续执行

```java
    public static void main(String[] args) throws MQClientException, MQBrokerException, RemotingException, InterruptedException {
        //创建Producer，并指定生产者组
        DefaultMQProducer producer = new DefaultMQProducer("group1");
        producer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");
        producer.start();
        for (int i = 0; i < 10; i++) {
            Message msg = new Message();
            msg.setTopic("base");
            msg.setTags("Tag1");
            msg.setBody(("hello world" + i).getBytes());
            //发送消息
            SendResult result = producer.send(msg);
            //发送状态
            SendStatus sendStatus = result.getSendStatus();
            //消息id
            String msgId = result.getMsgId();
            //消息接收队列id
            MessageQueue messageQueue = result.getMessageQueue();
            int queueId = messageQueue.getQueueId();
            log.info(result.toString());
            log.info(messageQueue.toString());
            log.info("status:" + sendStatus +
                    "msgId:" + msgId + "queueId" + queueId);
            TimeUnit.SECONDS.sleep(1);
        }
        log.info("发送结束===================");
        producer.shutdown();
    }
```



## 异步消息

发送消息后不会导致阻塞，当broker返回结果时，会调用回调函数进行处理

```java
    public static void main(String[] args) throws MQClientException, MQBrokerException, RemotingException, InterruptedException {
        //创建Producer，并指定生产者组
        DefaultMQProducer producer = new DefaultMQProducer("group1");
        producer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");
        producer.start();
        for (int i = 0; i < 10; i++) {
            Message msg = new Message();
            msg.setTopic("base");
            msg.setTags("Tag1");
            msg.setBody(("hello world" + i).getBytes());
            //发送消息
            producer.send(msg, new SendCallback() {
                @Override
                public void onSuccess(SendResult result) {
                    //发送状态
                    SendStatus sendStatus = result.getSendStatus();
                    //消息id
                    String msgId = result.getMsgId();
                    //消息接收队列id
                    MessageQueue messageQueue = result.getMessageQueue();
                    int queueId = messageQueue.getQueueId();
                    log.info(result.toString());
                    log.info(messageQueue.toString());
                    log.info("status:" + sendStatus +
                            "msgId:" + msgId + "queueId" + queueId);
                }

                @Override
                public void onException(Throwable throwable) {
                    log.error("发送异常" + throwable);
                }
            });

            //TimeUnit.SECONDS.sleep(1);
        }
        log.info("发送结束===================");
        TimeUnit.SECONDS.sleep(3);
    }
```

## 单向消息

**不关心发送结果**

```java
    public static void main(String[] args) throws MQClientException, MQBrokerException, RemotingException, InterruptedException {
        //创建Producer，并指定生产者组
        DefaultMQProducer producer = new DefaultMQProducer("group1");
        producer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");
        producer.start();
        for (int i = 0; i < 10; i++) {
            Message msg = new Message();
            msg.setTopic("base");
            msg.setTags("Tag3");
            msg.setBody(("hello world danxiang" + i).getBytes());
            //发送消息
            producer.sendOneway(msg);

            //TimeUnit.SECONDS.sleep(1);
        }
        log.info("发送结束===================");
        TimeUnit.SECONDS.sleep(3);
    }
```

# 消费消息

```java
   public static void main(String[] args) throws MQClientException {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("group1");
        consumer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");
        consumer.subscribe("base", "Tag3");
        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
                for (MessageExt messageExt : list) {
                    log.info(messageExt.toString());
                    String s = new String(messageExt.getBody());
                    log.info(s);
                }
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });
        consumer.start();
    }
```

## 消费模式

![image-20230407171826975](images/mypost/image-20230407171826975.png)

## 注意事项

1. 如果一个消息在广播消费模式下被消费过，之后再启动一个消费者，那么它可以在集群消费模式下再被消费一次。或者：  
   如果一个消息在集群消费模式下被消费过，之后再启动一个消费者，那么它可以在广播消费模式下再被消费一次
2. 如果一个消息在广播消费模式下被消费过，之后再启动一个消费者，那么它不能在广播模式下再被消费。或者  
   如果一个消息在集群消费模式下被消费过，之后再启动一个消费者，那么它不能在集群模式下再被消费。

## 顺序消息

### 消息实体

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class OrderStep {
    private int orderId;
    private String desc;

    public static List<OrderStep> getData(){
        List<OrderStep> orderSteps=new ArrayList<>();
        OrderStep orderStep=new OrderStep(123,"创建");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(125,"创建");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(123,"付款");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(125,"付款");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(123,"推送");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(124,"创建");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(124,"付款");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(124,"推送");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(123,"完成");
        orderSteps.add(orderStep);
        orderStep=new OrderStep(125,"推送");
        orderSteps.add(orderStep);
        return orderSteps;
    }
}
```

### 发送消息

```java
//同一个订单的消息，放在同一个topic的同一个queue里面
    public static void main(String[] args) throws MQClientException {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("group1");
        consumer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");
        consumer.subscribe("base", "Tag1");
        consumer.setMessageModel(MessageModel.BROADCASTING);
        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
                for (MessageExt messageExt : list) {
                    //log.info(messageExt.toString());
                    String s = new String(messageExt.getBody());
                    log.info(s);
                }
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });
        consumer.start();
    }
```

### 顺序消费消息

```java
public class ConsumerOrder {
    public static void main(String[] args) throws MQClientException {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("group1");
        consumer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");
        consumer.subscribe("OrderTopic", "*");
        consumer.registerMessageListener(new MessageListenerOrderly() {
            @Override
            public ConsumeOrderlyStatus consumeMessage(List<MessageExt> list, ConsumeOrderlyContext consumeOrderlyContext) {
                for (MessageExt messageExt : list) {
                    //log.info(messageExt.toString());
                    String s = new String(messageExt.getBody());
                    log.info(s);
                }
                return ConsumeOrderlyStatus.SUCCESS;
            }
        });
        consumer.start();
    }
}
```

MessageListenerOrderly 保证了同一时刻只有一个线程去消费这个queue，但不能保证每次消费queue的会是同一个线程  
由于queue具有先进先出的有序性，所以这并不影响消费queue中消息的顺序性

# 延时消息

在生产者端设置，可以设置一个消息在一定延时后才能消费

```message.setDelayTimLevel(2)``` //级别2，即延时10秒//1s 5s 10s 30s 1m

# 批量消息发送

```producer.send(List<Message> messages)```

# 事务消息

## 事务消息的架构图

![image-20230407192132494](images/mypost/image-20230407192132494.png)

## 生产者

```java

public class SyncProducer {
    public static void main(String[] args) throws MQClientException, MQBrokerException, RemotingException, InterruptedException {
        //创建Producer，并指定生产者组
        TransactionMQProducer producer = new TransactionMQProducer("group1");
        producer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");

        producer.setTransactionListener(new TransactionListener() {
            /**
             * 在该方法中执行本地事务
             * @param message
             * @param o
             * @return
             */
            @Override
            public LocalTransactionState executeLocalTransaction(Message message, Object o) {
                if("TAGA".equals(message.getTags())){
                    return LocalTransactionState.COMMIT_MESSAGE;
                }else if("TAGB".equals(message.getTags())){
                    return LocalTransactionState.ROLLBACK_MESSAGE;
                }else if("TAGC".equals(message.getTags())){
                    return LocalTransactionState.UNKNOW;
                }
                return LocalTransactionState.UNKNOW;
            }

            /**
             * 该方法时MQ进行消息是无状态的回查
             * @param messageExt
             * @return
             */
            @Override
            public LocalTransactionState checkLocalTransaction(MessageExt messageExt) {
                log.info("消息的回查:"+messageExt.getTags());
                try {
                    log.info("5s后告诉mq可以提交了");
                    TimeUnit.SECONDS.sleep(5);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                //可以提交
                return LocalTransactionState.COMMIT_MESSAGE;
            }
        });
        producer.start();
        String[] tags={"TAGA","TAGB","TAGC"};
        for (int i = 0; i < 3; i++) {
            Message msg = new Message();
            msg.setTopic("TransactionTopic");
            msg.setTags(tags[i]);
            msg.setBody(("hello world" + i).getBytes());
            //发送消息
            //参数：针对某一个消息进行事务控制
            SendResult result = producer.sendMessageInTransaction(msg,null);


            //发送状态
            SendStatus sendStatus = result.getSendStatus();
            log.info(result.toString());
            log.info("status:" + sendStatus );
        }
        log.info("发送结束===================");
        //producer.shutdown();
    }
}

```

## 消费者

```java
@Slf4j
public class Consumer {
    public static void main(String[] args) throws MQClientException {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("group1");
        consumer.setNamesrvAddr("192.168.1.135:9876;192.168.1.138:9876");
        consumer.subscribe("TransactionTopic", "*");
        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
                for (MessageExt messageExt : list) {
                    String s = new String(messageExt.getBody());
                    log.info(s);
                }
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });
        consumer.start();
        log.info("生产者启动----");
    }
}
```

