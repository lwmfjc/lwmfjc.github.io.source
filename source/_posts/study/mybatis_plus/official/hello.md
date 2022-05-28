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
  
  - mybatis-plus 代码自动生成
  
    - maven 依赖
  
      ```xml
      
              <!-- https://mvnrepository.com/artifact/com.baomidou/mybatis-plus-generator -->
              <dependency>
                  <groupId>com.baomidou</groupId>
                  <artifactId>mybatis-plus-generator</artifactId>
                  <version>3.5.2</version>
              </dependency>
              <!-- https://mvnrepository.com/artifact/org.apache.velocity/velocity-engine-core -->
              <dependency>
                  <groupId>org.apache.velocity</groupId>
                  <artifactId>velocity-engine-core</artifactId>
                  <version>2.3</version>
              </dependency>
      ```
  
    - 在测试类中编写程序让其自动生成
  
      ```java
      import com.baomidou.mybatisplus.generator.FastAutoGenerator;
      import com.baomidou.mybatisplus.generator.config.DataSourceConfig;
      import org.apache.ibatis.jdbc.ScriptRunner;
      
      import java.io.InputStream;
      import java.io.InputStreamReader;
      import java.sql.Connection;
      import java.sql.SQLException;
      
      /**
       * <p>
       * 快速生成
       * </p>
       *
       * @author lanjerry
       * @since 2021-09-16
       */
      public class FastAutoGeneratorTest {
      
          /**
           * 执行初始化数据库脚本
           */
          public static void before() throws SQLException {
              Connection conn = DATA_SOURCE_CONFIG.build().getConn();
              InputStream inputStream = FastAutoGeneratorTest.class.getResourceAsStream("/db/schema-mysql.sql");
              ScriptRunner scriptRunner = new ScriptRunner(conn);
              scriptRunner.setAutoCommit(true);
              scriptRunner.runScript(new InputStreamReader(inputStream));
              conn.close();
          }
      
          /**
           * 数据源配置
           */
          private static final DataSourceConfig.Builder DATA_SOURCE_CONFIG = new DataSourceConfig
                  .Builder("jdbc:mysql://localhost:3306/mybatis_plus_demo?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true&nullCatalogMeansCurrent=true", "root", "123456");
      
          /**
           * 执行 run
           */
          public static void main(String[] args) throws SQLException {
              before();
              FastAutoGenerator.create(DATA_SOURCE_CONFIG)
                      // 全局配置
                      .globalConfig((scanner, builder) -> builder.author(scanner.apply("请输入作者名称")))
                      // 包配置
                      .packageConfig((scanner, builder) -> builder.parent(scanner.apply("请输入包名")))
                      // 策略配置
                      .strategyConfig((scanner, builder) -> builder.addInclude(scanner.apply("请输入表名，多个表名用,隔开")))
                      /*
                          模板引擎配置，默认 Velocity 可选模板引擎 Beetl 或 Freemarker
                         .templateEngine(new BeetlTemplateEngine())
                         .templateEngine(new FreemarkerTemplateEngine())
                       */
                      .execute();
          }
      }
      
      ```
  
  - 使用mybats-x插件自动生成代码
  
    - 操作
      ![image-20220526151137850](C:\Users\ztx11\AppData\Roaming\Typora\typora-user-images\image-20220526151137850.png)
      ![](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220526151155505.png)
      ![image-20220526151232408](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220526151232408.png)
  
    - 编写controller确定
  
      ```java
      @RestController
      @RequestMapping("user")
      public class UserController {
      
          @Autowired
          private UserService userService;
      
          @RequestMapping("findAll")
          public List<User> findAll(){
              List<User> list = userService.list();
              return list;
          }
      }
      ```
  
      - xml文件
  
        ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE mapper
                PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
                "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
        <mapper namespace="com.baomidou.mybatisplus.samples.quickstart.mapper.UserMapper">
        
            <resultMap id="BaseResultMap" type="com.baomidou.mybatisplus.samples.quickstart.entity.User">
                    <id property="id" column="id" jdbcType="BIGINT"/>
                    <result property="name" column="name" jdbcType="VARCHAR"/>
                    <result property="age" column="age" jdbcType="INTEGER"/>
                    <result property="email" column="email" jdbcType="VARCHAR"/>
            </resultMap>
        
            <sql id="Base_Column_List">
                id,name,age,
                email
            </sql>
        </mapper>
        ```
  
      - entity
  
        ```java
        
        /**
         * 
         * @TableName user
         */
        @TableName(value ="user")
        public class User implements Serializable {
            /**
             * 主键ID
             */
            @TableId
            private Long id;
        
            /**
             * 姓名
             */
            private String name;
        
            /**
             * 年龄
             */
            private Integer age;
        
            /**
             * 邮箱
             */
            private String email;
        
            @TableField(exist = false)
            private static final long serialVersionUID = 1L;
        
            /**
             * 主键ID
             */
            public Long getId() {
                return id;
            }
        
            /**
             * 主键ID
             */
            public void setId(Long id) {
                this.id = id;
            }
        
            /**
             * 姓名
             */
            public String getName() {
                return name;
            }
        
            /**
             * 姓名
             */
            public void setName(String name) {
                this.name = name;
            }
        
            /**
             * 年龄
             */
            public Integer getAge() {
                return age;
            }
        
            /**
             * 年龄
             */
            public void setAge(Integer age) {
                this.age = age;
            }
        
            /**
             * 邮箱
             */
            public String getEmail() {
                return email;
            }
        
            /**
             * 邮箱
             */
            public void setEmail(String email) {
                this.email = email;
            }
        
            @Override
            public boolean equals(Object that) {
                if (this == that) {
                    return true;
                }
                if (that == null) {
                    return false;
                }
                if (getClass() != that.getClass()) {
                    return false;
                }
                User other = (User) that;
                return (this.getId() == null ? other.getId() == null : this.getId().equals(other.getId()))
                    && (this.getName() == null ? other.getName() == null : this.getName().equals(other.getName()))
                    && (this.getAge() == null ? other.getAge() == null : this.getAge().equals(other.getAge()))
                    && (this.getEmail() == null ? other.getEmail() == null : this.getEmail().equals(other.getEmail()));
            }
        
            @Override
            public int hashCode() {
                final int prime = 31;
                int result = 1;
                result = prime * result + ((getId() == null) ? 0 : getId().hashCode());
                result = prime * result + ((getName() == null) ? 0 : getName().hashCode());
                result = prime * result + ((getAge() == null) ? 0 : getAge().hashCode());
                result = prime * result + ((getEmail() == null) ? 0 : getEmail().hashCode());
                return result;
            }
        
            @Override
            public String toString() {
                StringBuilder sb = new StringBuilder();
                sb.append(getClass().getSimpleName());
                sb.append(" [");
                sb.append("Hash = ").append(hashCode());
                sb.append(", id=").append(id);
                sb.append(", name=").append(name);
                sb.append(", age=").append(age);
                sb.append(", email=").append(email);
                sb.append(", serialVersionUID=").append(serialVersionUID);
                sb.append("]");
                return sb.toString();
            }
        }
        ```
  
      - service接口类
  
        ```java
        public interface UserService extends IService<User> {
        
        }
        ```
  
      - serviceImpl
  
        ```java
        @Service
        public class UserServiceImpl extends ServiceImpl<UserMapper, User>
            implements UserService{
        
        }
        ```
  
      - mapper
  
        ```xml
        public interface UserMapper extends BaseMapper<User> {
        
        }
        ```
  
      - controller测试
  
        ```java
        @RestController
        @RequestMapping("user")
        public class UserController {
        
            @Autowired
            private UserService userService;
        
            @RequestMapping("findAll")
            public List<User> findAll(){
                List<User> list = userService.list();
                return list;
            }
        }
        ```
  
    - 测试
      ![image-20220526151658557](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220526151658557.png)
  
  - 使用mybatis-x 插件（idea）
  
  
    
    ![image-20220526153005432](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220526153005432.png)
    ![image-20220526152906823](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220526152906823.png)
  
    ![image-20220526152939073](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20220526152939073.png)
  
  
