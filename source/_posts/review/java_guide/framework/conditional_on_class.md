---
title: ConditionalOnClass实践
description: ConditionalOnClass实践
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-framework
date: 2023-02-09 15:38:01
updated: 2023-02-09 15:38:01
---

# 两个测试方向

## 方向1：两个maven项目 

>  详见git上的 conditional_on_class_main 项目以及 conditional_on_class2 项目

1. 基础maven项目 conditional_on_class2  
   pom文件   

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>
   
       <groupId>org.example</groupId>
       <artifactId>conditional_on_class_2</artifactId>
       <version>1.0-SNAPSHOT</version>
   
   </project>
   ```

     java类    

   ```java
   package com;
   
   public class LyReferenceImpl  {
       public String sayWord() {
           return "hello one";
       }
   }
   ```

2. 简单的SpringBoot项目   conditional_on_class_main

   ```xml
   <!--pom文件-->
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>
   
       <groupId>org.example</groupId>
       <artifactId>conditional_on_class_main</artifactId>
       <version>1.0-SNAPSHOT</version>
   
       <parent>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-parent</artifactId>
           <version>2.7.8</version>
       </parent>
       <dependencies>
   
           <!--把1配置的bean引用进来-->
           <dependency>
               <groupId>org.example</groupId>
               <artifactId>conditional_on_class_2</artifactId>
               <version>1.0-SNAPSHOT</version>
               <scope>provided</scope>
               <optional>true</optional>
           </dependency>
   
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-web</artifactId>
           </dependency>
       </dependencies>
       <build>
           <plugins>
               <plugin>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-maven-plugin</artifactId>
                   <configuration>
                       <excludes>
                           <!-- 默认会将conditional_on_class_2 打包进去,现在会配置SayExist
   						如果放开注释,那么会配置SayNotExist-->
                           <!--<dependency>
                               <groupId>org.example</groupId>
                               <artifactId>conditional_on_class_2</artifactId>
                           </dependency>-->
                       </excludes>
                       <jvmArguments>-Dfile.encoding=UTF-8</jvmArguments>
                   </configuration>
                   <executions>
                       <execution>
                           <goals>
                               <goal>repackage</goal><!--可以把依赖的包都打包到生成的Jar包中 -->
                           </goals>
                       </execution>
                   </executions>
               </plugin>
           </plugins>
       </build>
   
   </project>
   ```

   ```java
   //两个配置类  
   //配置类1
   package com.config;
   
   import com.service.ISay;
   import com.service.SayExist;
   import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   @Configuration
   //不要放在方法里面,否则会报错"java.lang.ArrayStoreException: sun.reflect.annotation.TypeNotPresentExceptionProxy"
   @ConditionalOnClass(value = com.LyReferenceImpl.class)
   public class ExistConfiguration {
   
       @Bean
       public ISay getISay1(){
           return new SayExist();
       }
   }
   
   ```

   ```java
   //配置类2
   package com.config;
   
   import com.service.ISay;
   import com.service.SayNotExist;
   import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingClass;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   @Configuration
   @ConditionalOnMissingClass("com.LyReferenceImpl")
   public class NotExistConfiguration {
   
       @Bean
       public ISay getISay1(){
           return new SayNotExist();
       }
   }
   
   ```

## 方向2：3个maven项目(建议用这个理解)

> 注意，这里可能还漏了一个问题，那就是 这个conditional_on_class1 的configuration之所以能够被自动装配，是因为和 conditional_on_class_main1的Application类是同一个包，所以不用特殊处理。如果是其他包名的话，那么是需要用到spring boot的自动装配机制的：在conditional_on_class1 工程的 resources 包下创建`META-INF/spring.factories`，并写上Config类的全类名

> 详见 git上的 conditional_on_class_main1,  conditional_on_class1 项目以及 conditional_on_class2 项目

1. 基础 conditional_on_class2  
   pom文件   

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>
   
       <groupId>org.example</groupId>
       <artifactId>conditional_on_class_2</artifactId>
       <version>1.0-SNAPSHOT</version>
   
   </project>
   ```

     java类    

   ```java
   package com;
   
   public class LyReferenceImpl  {
       public String sayWord() {
           return "hello one";
       }
   }
   ```
   
   
   
   以LyReferenceImpl.class存不存在，决定创建哪个bean
   
2. conditional_on_class_1  pom.xml

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>
   
       <groupId>org.example</groupId>
       <artifactId>conditional_on_class_1</artifactId>
       <version>1.0-SNAPSHOT</version>
       <dependencies>
           <!--引入被引用的类，只在编译期存在-->
           <dependency>
               <groupId>org.example</groupId>
               <artifactId>conditional_on_class_2</artifactId>
               <version>1.0-SNAPSHOT</version>
               <scope>provided</scope>
               <optional>true</optional>
           </dependency>
   
           <!-- https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-autoconfigure -->
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-autoconfigure</artifactId>
               <version>2.7.8</version>
           </dependency>
   
       </dependencies>
   </project>
   ```

   ```java
   //根据是否存在class_2中的类，进行自动装配  
   @Configuration
   //不要放在方法里面,否则会报错"java.lang.ArrayStoreException: sun.reflect.annotation.TypeNotPresentExceptionProxy"
   @ConditionalOnClass(value = com.LyReferenceImpl.class)
   public class ExistConfiguration {
   
       @Bean
       public LyEntity lyEntity1(){
           return new LyEntity("存在");
       }
   }
   ```

   ```java
   @Configuration
   @ConditionalOnMissingClass("com.LyReferenceImpl")
   public class NotExistConfiguration {
   
       @Bean
       public LyEntity lyEntity1(){
           return new LyEntity("不存在");
       }
   }
   ```

   ```java
   //基础类  
   
   public class LyEntity {
       private String name;
       private Integer age;
   
       public LyEntity(String name) {
           this.name = name;
       }
   
       public String getName() {
           return name;
       }
   
       public void setName(String name) {
           this.name = name;
       }
   
       public Integer getAge() {
           return age;
       }
   
       public void setAge(Integer age) {
           this.age = age;
       }
   }
   ```

3. 使用 在_main项目中   pom.xml

   ```xml
   <parent>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-parent</artifactId>
           <version>2.7.8</version>
       </parent>
       <dependencies>
   
           <!--把1配置的bean引用进来-->
           <dependency>
               <groupId>org.example</groupId>
               <artifactId>conditional_on_class_1</artifactId>
               <version>1.0-SNAPSHOT</version>
           </dependency>
           
           
           <!--加上这个则会提示存在-->
          <!-- <dependency>
               <groupId>org.example</groupId>
               <artifactId>conditional_on_class_2</artifactId>
               <version>1.0-SNAPSHOT</version>
           </dependency> -->
   
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-web</artifactId>
           </dependency>
       </dependencies> 
   ```

   如果不存在class_2中的类，则提示不存在；如果存在则提示存在  

   ```java
   
   @SpringBootApplication
   @RestController
   public class MyApplication {
   
       @Autowired
       private LyEntity lyEntity;
   
       @RequestMapping("hello")
       public String hello(){
           return lyEntity.getName();
       }
   
       public static void main(String[] args) {
           SpringApplication.run(MyApplication.class,args);
       }
   }
   ```

   


