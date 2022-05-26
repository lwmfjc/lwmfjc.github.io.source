---
title: hello-world
description: 'mybatis-plus-hello world'
categories:
  - 学习
tags:
  - mybatis-plus official
date: 2022-05-20 17:16:29
updated: 2022-05-20 17:16:29
---

## 简介 

- MyBatis-Plus (opens new window)（简称 MP）是一个 MyBatis (opens new window)的增强工具，在 MyBatis 的基础上只做增强不做改变，为简化开发、提高效率而生。

## 快速开始

- 数据库的Schema脚本 resources/db/schema-mysql.sql

  ```mysql
  DROP TABLE IF EXISTS user;
  
  CREATE TABLE user
  (
      id BIGINT(20) NOT NULL COMMENT '主键ID',
      name VARCHAR(30) NULL DEFAULT NULL COMMENT '姓名',
      age INT(11) NULL DEFAULT NULL COMMENT '年龄',
      email VARCHAR(50) NULL DEFAULT NULL COMMENT '邮箱',
      PRIMARY KEY (id)
  );
  ```

- 数据库Data脚本 resources/db/data-mysql.sql

  ```mysql
  DELETE FROM user;
  
  INSERT INTO user (id, name, age, email) VALUES
  (1, 'Jone', 18, 'test1@baomidou.com'),
  (2, 'Jack', 20, 'test2@baomidou.com'),
  (3, 'Tom', 28, 'test3@baomidou.com'),
  (4, 'Sandy', 21, 'test4@baomidou.com'),
  (5, 'Billie', 24, 'test5@baomidou.com');
  ```

- 创建一个spring boot工程（使用maven）

  - 父工程

    ```xml
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.0</version>
        <relativePath/>
    </parent>
    ```

  - springboot 相关仓库及mybatis-plus、mysql、Lombok相关仓库引入

    ```xml
    
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter</artifactId>
            </dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-test</artifactId>
                <scope>test</scope>
            </dependency>
            <dependency>
                <groupId>com.baomidou</groupId>
                <artifactId>mybatis-plus-boot-starter</artifactId>
                <version>3.5.1</version>
            </dependency>
    
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
            </dependency>
            <dependency>
                <groupId>com.h2database</groupId>
                <artifactId>h2</artifactId>
                <scope>runtime</scope>
            </dependency>
            <!-- https://mvnrepository.com/artifact/mysql/mysql-connector-java -->
            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <version>8.0.29</version>
            </dependency>
            <!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->
            <dependency>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok</artifactId>
                <version>1.18.24</version>
                <scope>provided</scope>
            </dependency>
    
        </dependencies>
    ```
  
  - 配置resources/application.yml文件
  
    ```yml
    spring:
      datasource:
        url: jdbc:mysql://localhost:3306/mybatis_plus_demo?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true&nullCatalogMeansCurrent=true
        username: root
        password: 123456
        driver-class-name: com.mysql.cj.jdbc.Driver
      sql:
        init:
          schema-locations: classpath:db/schema-mysql.sql
          data-locations: classpath:db/data-mysql.sql
          mode: always
    ```
  
  - entity类和mapper类的处理
  
    - entity
  
      ```java
      @Data
      public class User {
          private Long id;
          private String name;
          private Integer age;
          private String email;
      }
      ```
  
    - mapper
  
      ```java
      
      import com.baomidou.mybatisplus.core.mapper.BaseMapper;
      import com.baomidou.mybatisplus.samples.quickstart.entity.User;
      
      public interface UserMapper extends BaseMapper<User> {
      
      }
      ```
  
  - 测试类
  
    ```java
    import com.baomidou.mybatisplus.samples.quickstart.Application;
    import com.baomidou.mybatisplus.samples.quickstart.entity.User;
    import com.baomidou.mybatisplus.samples.quickstart.mapper.UserMapper;
    import org.junit.jupiter.api.Assertions;
    import org.junit.jupiter.api.Test;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.boot.test.context.SpringBootTest;
    
    import java.util.List;
    
    @SpringBootTest(classes = {Application.class})
    public class SampleTest {
    
        @Autowired
        private UserMapper userMapper;
    
        @Test
        public void testSelect() {
            System.out.println(("----- selectAll method test ------"));
            List<User> userList = userMapper.selectList(null);
            Assertions.assertEquals(5, userList.size());
            userList.forEach(System.out::println);
        }
    
    }
    ```
  
  - 
  
  
