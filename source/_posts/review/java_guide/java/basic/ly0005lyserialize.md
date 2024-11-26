---
title: Java序列化详解
description: Java序列化详解
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-基础
date: 2022-10-10 10:39:01
updated: 2022-10-10 10:39:01

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

### 什么是序列化？什么是反序列化

当需要**持久化Java对象**，比如**将Java对象保存在文件**中、或者**在网络中传输Java对象**，这些场景都需要用到序列化

即：  

- 序列化：将**数据结构/对象**，**转换成二进制字节流**
- 反序列化：将在**序列化过程中所生成的二进制字节流**，**转换成数据结构或者对象**的过程

对于Java，序列化的是对象(Object)，也就是实例化后的类(Class)

序列化的目的，是通过网络传输对象，或者说是将对象存储到文件系统、数据库、内存中，如图：
![lyx-20241126133559942](attachments/img/lyx-20241126133559942.png)

###  实际场景

- 对象在**<u>进行网络传输（比如远程方法调用 RPC 的时候）之前</u>**需要先被序列化，<u>**接收到**</u>序列化的对象<u>**之后**</u>需要再进行<u>**反序列化**</u>；
- 将对象<u>**存储到文件中**</u>的时候需要进行序列化，将对象从文件中读取出来需要进行反序列化。
- 将**<u>对象存储到缓存数据库（如 Redis）时需要用到序列化</u>**，将对象**<u>从缓存数据库中读取</u>**出来需要反序列化

### 序列化协议对于TCP/IP 4层模型的哪一层

4层包括，网络接口层，网络层，传输层，应用层
如下图所示：  
![lyx-20241126133600393](attachments/img/lyx-20241126133600393.png)

OSI七层协议模型中，表示层就是**对应用层的用户数据，进行处理转换成二进制流**；反过来的话，就是**将二进制流转换成应用层的用户数据**，即序列化和反序列化，  
因为，OSI 七层协议模型中的**应用层、表示层和会话层**对应的都是 **TCP/IP 四层模型**中的**应用层**，所以**序列化协议**属于 **TCP/IP 协议应用层**的一部分

### 常见序列化协议对比

kryo 英音 [k'rɪəʊ] ，除了JDK自带的序列化，还有**hessian**、**kryo**、**protostuff**

- JDK自带的序列化，只需要实现java.io.Serializable接口即可

  ```java
  @AllArgsConstructor
  @NoArgsConstructor
  @Getter
  @Builder
  @ToString
  public class RpcRequest implements Serializable {
      private static final long serialVersionUID = 1905122041950251207L;
      private String requestId;
      private String interfaceName;
      private String methodName;
      private Object[] parameters;
      private Class<?>[] paramTypes;
      private RpcMessageTypeEnum rpcMessageTypeEnum;
  }
  ```

  serialVersionUID用于版本控制，会被写入二进制序列，反序列化如果发现和当前类不一致则会抛出InvalidClassException异常。一般不使用JDK自带序列化，1 不支持跨语言调用 2 性能差，序列化之后字节数组体积过大

- Kryo
  由于变长存储特性并使用了字节码生成机制，拥有较高的运行速度和较小字节码体积，代码：  

  ```java
  /**
   * Kryo serialization class, Kryo serialization efficiency is very high, but only compatible with Java language
   *
   * @author shuang.kou
   * @createTime 2020年05月13日 19:29:00
   */
  @Slf4j
  public class KryoSerializer implements Serializer {
  
      /**
       * Because Kryo is not thread safe. So, use ThreadLocal to store Kryo objects
       */
      private final ThreadLocal<Kryo> kryoThreadLocal = ThreadLocal.withInitial(() -> {
          Kryo kryo = new Kryo();
          kryo.register(RpcResponse.class);
          kryo.register(RpcRequest.class);
          return kryo;
      });
  
      @Override
      public byte[] serialize(Object obj) {
          try (ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
               Output output = new Output(byteArrayOutputStream)) {
              Kryo kryo = kryoThreadLocal.get();
              // Object->byte:将对象序列化为byte数组
              kryo.writeObject(output, obj);
              kryoThreadLocal.remove();
              return output.toBytes();
          } catch (Exception e) {
              throw new SerializeException("Serialization failed");
          }
      }
  
      @Override
      public <T> T deserialize(byte[] bytes, Class<T> clazz) {
          try (ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bytes);
               Input input = new Input(byteArrayInputStream)) {
              Kryo kryo = kryoThreadLocal.get();
              // byte->Object:从byte数组中反序列化出对象
              Object o = kryo.readObject(input, clazz);
              kryoThreadLocal.remove();
              return clazz.cast(o);
          } catch (Exception e) {
              throw new SerializeException("Deserialization failed");
          }
      }
  
  }
  ```

- Protobuf 出自google

- ProtoStuff，更为易用

- hessian，轻量级的自定义描述的二进制RPC协议，跨语言，hessian2，为阿里修改过的hessian lite，是dubbo RPC默认启用的序列化方式

- 总结

  - 如果不需要跨语言可以考虑Kryo
  - Protobuf，ProtoStuff，hessian支持跨语言

  