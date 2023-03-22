---
title: Mybatis原理系列(1)
description: Mybatis原理系列(1)
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-framework
date: 2023-02-10 08:54:26
updated: 2023-02-10 08:54:26
---

> 转载自https://www.jianshu.com/p/ada025f97a07（添加小部分笔记）感谢作者!

> 作为Java码农，无论在面试中，还是在工作中都会遇到MyBatis的相关问题。笔者从大学开始就接触MyBatis，到现在为止都是会用，知道怎么配置，怎么编写xml，但是不知道Mybatis核心原理，一遇到问题就复制错误信息百度解决。为了改变这种境地，鼓起勇气开始下定决心阅读MyBatis源码，并开始记录阅读过程，希望和大家分享。

#### 1. 初识MyBatis

还记得当初接触MyBatis时，觉得要配置很多，而且sql要单独写在xml中，相比Hibernate来说简直不太友好，直到后来出现了复杂的业务需求，需要编写相应的复杂的sql，此时用Hibernate反而更加麻烦了，用MyBatis是真香了。因此笔者对MyBatis的第一印象就是**将业务关注的sql**和**java代码**进行了解耦，在业务复杂变化的时候，相应的数据库操作需要相应进行修改，**如果通过java代码构建操作数据逻辑**，这不断变动的需求对程序员的耐心是极大的考验。如果**将sql统一的维护在一个文件**里，java代码用接口定义，在需求变动时，**只用改相应的sql**，从而**减少了修改量**，**提高开发效率**。以上也是经常在面试中经常问到的Hibernate和MyBatis间的区别一点。

切到正题，Mybatis是什么呢？

Mybatis SQL 映射框架使得一个**面向对象构建的应用程序**去**访问一个关系型数据库**变得更容易。MyBatis使用**XML描述符**或**注解**将**对象**与**存储过程**或**SQL语句耦合**。与对象关系映射工具相比，简单性是MyBatis数据映射器的最大优势。

以上是Mybatis的官方解释，其中“映射”，“面向对象”，“关系型”，“xml”等等都是Mybatis的关键词，也是我们了解了Mybatis原理后，会恍然大悟的地方。笔者现在不详述这些概念，在最后总结的时候再进行详述。我们只要知道Mybatis为我们操作数据库提供了很大的便捷。

#### 2. 源码下载

> 这里建议使用maven即可，在pom.xml添加以下依赖   
>
> ```xml
>     <dependencies>
>         <!-- https://mvnrepository.com/artifact/mysql/mysql-connector-java -->
>         <dependency>
>             <groupId>mysql</groupId>
>             <artifactId>mysql-connector-java</artifactId>
>             <version>8.0.32</version>
>         </dependency>
> 
>         <dependency>
>             <groupId>org.mybatis</groupId>
>             <artifactId>mybatis</artifactId>
>             <version>3.5.6</version>
>         </dependency>
>         
>         <!--这里还添加了一些辅助的依赖-->
>         <!--lombok-->
>         <dependency>
>             <groupId>org.projectlombok</groupId>
>             <artifactId>lombok</artifactId>
>             <version>1.18.8</version>
>         </dependency>
>         <!--日志模块-->
>         <dependency>
>             <groupId>org.apache.logging.log4j</groupId>
>             <artifactId>log4j-api</artifactId>
>             <version>2.17.1</version>
>         </dependency> 
>     </dependencies>
> ```
>
> 然后在ExternalLibraries 的mybatis:3.5.6里找到，就能看到目录结构 ，随便找一个进去 idea右上角会出现DownloadSource之类的字样 ，点击即可  
> ![image-20230210102234207](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230210102234207.png)

我们首先要从github上下载源码，[仓库地址](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fmybatis%2Fmybatis-3)，然后在IDEA中clone代码

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1183379-4ab2cebdd0d9d205.png)

 

在打开中的IDEA中，选择vsc -> get from version control -> 复制刚才的地址

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1183379-2f422fc1a790fdeb.png)



image.png

点击clone即可



![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1183379-27b6070991809b7e.png)

image.png

经过漫长的等待后，代码会全部下载下来，项目结果如下，框起来的就是我们要关注的核心代码了。

![img](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/1183379-f85e5ba220b55a7d.png)

image.png

每个包就是MyBatis的一个模块，每个包的作用如下：

![image-20230210092001911](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20230210092001911.png)

 

#### 3. 一个简单的栗子

不知道现在还有没有同学知道怎么使用**原生的JDBC**进行数据库操作，现在框架太方便了，为我们考虑了很多，也隐藏了很多细节，因此会让我们处于一个云里雾里的境地，**为什么**这么设计，这样设计**解决了**什么问题，我们是不得而知的，为了了解其中奥秘，还是需要我们**从头**开始了解。

接下来笔者将以两个栗子来分别讲讲如何用原生的JDBC操作数据库，以及如何使用MyBatis框架来实现相同的功能，并比较两者的区别。

> 首先创建数据库 test

##### 3.1 创建表

在此我们建了两张表，一张是**t_test_user**用户信息主表，一张是**t_test_user_info**用户信息副表，两张表通过**member_id**进行关联。



```php
DROP TABLE IF EXISTS `t_test_user`;
CREATE TABLE `t_test_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `member_id` bigint(20) NOT NULL COMMENT '会员id',
  `real_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '真实姓名',
  `nickname` varchar(255) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '会员昵称',
  `date_create` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `date_update` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint(20) DEFAULT '0' COMMENT '删除标识，0未删除，时间戳-删除时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42013 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='测试表';

DROP TABLE IF EXISTS `t_test_user_info`;
CREATE TABLE `t_test_user_info` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `member_id` bigint(20) NOT NULL COMMENT '会员id',
  `member_phone` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '电话',
  `member_province` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '省',
  `member_city` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '市',
  `member_county` varchar(50) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '区',
  `date_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `date_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` bigint(20) NOT NULL DEFAULT '0' COMMENT '删除标识，0未删除，时间戳-删除时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息测试表';
```

##### 3.2 使用Java JDBC进行操作数据库

JDBC(**Java Database Connectivity**，简称**JDBC**）是Java中用来**规范客户端程序如何来访问数据库**的**应用程序接口**，提供了诸如查询和更新数据库中数据的方法。使用JDBC操作数据库，一般包含7步，代码如下。



```swift
public class JDBCTest {

    /**
     * 数据库地址 替换成本地的地址
     */
    private static final String url = "jdbc:mysql://localhost:3306/test?useUnicode=true";
    /**
     * 数据库用户名
     */
    private static final String username = "test";
    /**
     * 密码
     */
    private static final String password = "test";

    public static void main(String[] args) {
        try {
            // 1. 加载数据库驱动
            Class.forName("com.mysql.jdbc.Driver");
            // 2. 获得连接
            Connection connection = DriverManager.getConnection(url, username, password);
            // 3. 创建sql语句
            String sql = "select * from t_test_user";
            Statement statement = connection.createStatement();
            // 4. 执行sql
            ResultSet result = statement.executeQuery(sql);
            // 5. 处理结果
            while(result.next()){
                System.out.println("result = " + result.getString(1));
            }
            // 6. 关闭连接
            result.close();
            connection.close();
        } catch (Exception e){
            System.out.println(e);
        }

    }
}
```

##### 3.3 使用Mybatis进行操作数据库

###### 3.3.1 新增mybatis-config.xml配置

在路径src/main/resources/mybatis-config.xml新增配置，配置内容如下



```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

    <!--一些重要的全局配置-->
    <settings>
        <setting name="cacheEnabled" value="true"/>
        <!--<setting name="lazyLoadingEnabled" value="true"/>-->
        <!--<setting name="multipleResultSetsEnabled" value="true"/>-->
        <!--<setting name="useColumnLabel" value="true"/>-->
        <!--<setting name="useGeneratedKeys" value="false"/>-->
        <!--<setting name="autoMappingBehavior" value="PARTIAL"/>-->
        <!--<setting name="autoMappingUnknownColumnBehavior" value="WARNING"/>-->
        <!--<setting name="defaultExecutorType" value="SIMPLE"/>-->
        <!--<setting name="defaultStatementTimeout" value="25"/>-->
        <!--<setting name="defaultFetchSize" value="100"/>-->
        <!--<setting name="safeRowBoundsEnabled" value="false"/>-->
        <!--<setting name="mapUnderscoreToCamelCase" value="false"/>-->
        <!--<setting name="localCacheScope" value="STATEMENT"/>-->
        <!--<setting name="jdbcTypeForNull" value="OTHER"/>-->
        <!--<setting name="lazyLoadTriggerMethods" value="equals,clone,hashCode,toString"/>-->
        <!--<setting name="logImpl" value="STDOUT_LOGGING" />-->
    </settings>

    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.cj.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://localhost:3306/test?useUnicode=true"/>
                <property name="username" value="root"/>
                <property name="password" value="123456"/>
            </dataSource>
        </environment>
    </environments>

    <mappers>
        <!--这边可以使用package或resource两种方式加载mapper-->

        <!--<package name="包名"/>-->
        <!--如果这里使用了包名, 那么resource下
        的Mapper.xml文件的层级,一定要和Mapper类的全类名一样,即com/example/demo/dao/TTestUserMapper.xml-->

        <!--<mapper resource="具体的Mapper.xml地址" />-->

        <mapper resource="mapper/TTestUserMapper.xml" />
        <!--<package name="com.example.demo.dao"/>-->
    </mappers>

</configuration>
```

###### 3.3.2 新增mapper接口

新增src/main/java/com/example/demo/dao/TTestUserMapper.java 接口



```dart
package com.example.demo.dao;

import com.example.demo.entity.TTestUser;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface TTestUserMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    int deleteByPrimaryKey(Long id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    int insert(TTestUser record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    int insertSelective(TTestUser record);

    int batchInsert(List<TTestUser> records);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    TTestUser selectByPrimaryKey(Long id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    int updateByPrimaryKeySelective(TTestUser record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    int updateByPrimaryKey(TTestUser record);
}
```

###### 3.3.3 新增映射配置文件

src/main/resources/mapper/TTestUserMapper.xml 新增映射配置文件



```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.example.demo.dao.TTestUserMapper">
  <resultMap id="BaseResultMap" type="com.example.demo.entity.TTestUser">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    <id column="id" jdbcType="BIGINT" property="id" />
    <result column="member_id" jdbcType="BIGINT" property="memberId" />
    <result column="real_name" jdbcType="VARCHAR" property="realName" />
    <result column="nickname" jdbcType="VARCHAR" property="nickname" />
    <result column="date_create" jdbcType="TIMESTAMP" property="dateCreate" />
    <result column="date_update" jdbcType="TIMESTAMP" property="dateUpdate" />
    <result column="deleted" jdbcType="BIGINT" property="deleted" />
  </resultMap>
  <sql id="Base_Column_List">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    id, member_id, real_name, nickname, date_create, date_update, deleted
  </sql>
  <select id="selectByPrimaryKey" parameterType="java.lang.Long" resultMap="BaseResultMap">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    select 
    <include refid="Base_Column_List" />
    from t_test_user
    where id = #{id,jdbcType=BIGINT}
  </select>
  <delete id="deleteByPrimaryKey" parameterType="java.lang.Long">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    delete from t_test_user
    where id = #{id,jdbcType=BIGINT}
  </delete>
  <insert id="insert" parameterType="com.example.demo.entity.TTestUser">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    insert into t_test_user (id, member_id, real_name, 
      nickname, date_create, date_update, 
      deleted)
    values (#{id,jdbcType=BIGINT}, #{memberId,jdbcType=BIGINT}, #{realName,jdbcType=VARCHAR}, 
      #{nickname,jdbcType=VARCHAR}, #{dateCreate,jdbcType=TIMESTAMP}, #{dateUpdate,jdbcType=TIMESTAMP}, 
      #{deleted,jdbcType=BIGINT})
  </insert>
  <insert id="insertSelective" parameterType="com.example.demo.entity.TTestUser">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    insert into t_test_user
    <trim prefix="(" suffix=")" suffixOverrides=",">
      <if test="id != null">
        id,
      </if>
      <if test="memberId != null">
        member_id,
      </if>
      <if test="realName != null">
        real_name,
      </if>
      <if test="nickname != null">
        nickname,
      </if>
      <if test="dateCreate != null">
        date_create,
      </if>
      <if test="dateUpdate != null">
        date_update,
      </if>
      <if test="deleted != null">
        deleted,
      </if>
    </trim>
    <trim prefix="values (" suffix=")" suffixOverrides=",">
      <if test="id != null">
        #{id,jdbcType=BIGINT},
      </if>
      <if test="memberId != null">
        #{memberId,jdbcType=BIGINT},
      </if>
      <if test="realName != null">
        #{realName,jdbcType=VARCHAR},
      </if>
      <if test="nickname != null">
        #{nickname,jdbcType=VARCHAR},
      </if>
      <if test="dateCreate != null">
        #{dateCreate,jdbcType=TIMESTAMP},
      </if>
      <if test="dateUpdate != null">
        #{dateUpdate,jdbcType=TIMESTAMP},
      </if>
      <if test="deleted != null">
        #{deleted,jdbcType=BIGINT},
      </if>
    </trim>
  </insert>
  <update id="updateByPrimaryKeySelective" parameterType="com.example.demo.entity.TTestUser">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    update t_test_user
    <set>
      <if test="memberId != null">
        member_id = #{memberId,jdbcType=BIGINT},
      </if>
      <if test="realName != null">
        real_name = #{realName,jdbcType=VARCHAR},
      </if>
      <if test="nickname != null">
        nickname = #{nickname,jdbcType=VARCHAR},
      </if>
      <if test="dateCreate != null">
        date_create = #{dateCreate,jdbcType=TIMESTAMP},
      </if>
      <if test="dateUpdate != null">
        date_update = #{dateUpdate,jdbcType=TIMESTAMP},
      </if>
      <if test="deleted != null">
        deleted = #{deleted,jdbcType=BIGINT},
      </if>
    </set>
    where id = #{id,jdbcType=BIGINT}
  </update>
  <update id="updateByPrimaryKey" parameterType="com.example.demo.entity.TTestUser">
    <!--
      WARNING - @mbggenerated
      This element is automatically generated by MyBatis Generator, do not modify.
    -->
    update t_test_user
    set member_id = #{memberId,jdbcType=BIGINT},
      real_name = #{realName,jdbcType=VARCHAR},
      nickname = #{nickname,jdbcType=VARCHAR},
      date_create = #{dateCreate,jdbcType=TIMESTAMP},
      date_update = #{dateUpdate,jdbcType=TIMESTAMP},
      deleted = #{deleted,jdbcType=BIGINT}
    where id = #{id,jdbcType=BIGINT}
  </update>
</mapper>
```

###### 3.3.5 新增实体类



```dart
package com.example.demo.entity;

import java.io.Serializable;
import java.util.Date;

public class TTestUser implements Serializable {
    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_test_user.id
     *
     * @mbggenerated
     */
    private Long id;

    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_test_user.member_id
     *
     * @mbggenerated
     */
    private Long memberId;

    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_test_user.real_name
     *
     * @mbggenerated
     */
    private String realName;

    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_test_user.nickname
     *
     * @mbggenerated
     */
    private String nickname;

    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_test_user.date_create
     *
     * @mbggenerated
     */
    private Date dateCreate;

    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_test_user.date_update
     *
     * @mbggenerated
     */
    private Date dateUpdate;

    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database column t_test_user.deleted
     *
     * @mbggenerated
     */
    private Long deleted;

    /**
     * This field was generated by MyBatis Generator.
     * This field corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    private static final long serialVersionUID = 1L;

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_test_user.id
     *
     * @return the value of t_test_user.id
     *
     * @mbggenerated
     */
    public Long getId() {
        return id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_test_user.id
     *
     * @param id the value for t_test_user.id
     *
     * @mbggenerated
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_test_user.member_id
     *
     * @return the value of t_test_user.member_id
     *
     * @mbggenerated
     */
    public Long getMemberId() {
        return memberId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_test_user.member_id
     *
     * @param memberId the value for t_test_user.member_id
     *
     * @mbggenerated
     */
    public void setMemberId(Long memberId) {
        this.memberId = memberId;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_test_user.real_name
     *
     * @return the value of t_test_user.real_name
     *
     * @mbggenerated
     */
    public String getRealName() {
        return realName;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_test_user.real_name
     *
     * @param realName the value for t_test_user.real_name
     *
     * @mbggenerated
     */
    public void setRealName(String realName) {
        this.realName = realName == null ? null : realName.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_test_user.nickname
     *
     * @return the value of t_test_user.nickname
     *
     * @mbggenerated
     */
    public String getNickname() {
        return nickname;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_test_user.nickname
     *
     * @param nickname the value for t_test_user.nickname
     *
     * @mbggenerated
     */
    public void setNickname(String nickname) {
        this.nickname = nickname == null ? null : nickname.trim();
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_test_user.date_create
     *
     * @return the value of t_test_user.date_create
     *
     * @mbggenerated
     */
    public Date getDateCreate() {
        return dateCreate;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_test_user.date_create
     *
     * @param dateCreate the value for t_test_user.date_create
     *
     * @mbggenerated
     */
    public void setDateCreate(Date dateCreate) {
        this.dateCreate = dateCreate;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_test_user.date_update
     *
     * @return the value of t_test_user.date_update
     *
     * @mbggenerated
     */
    public Date getDateUpdate() {
        return dateUpdate;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_test_user.date_update
     *
     * @param dateUpdate the value for t_test_user.date_update
     *
     * @mbggenerated
     */
    public void setDateUpdate(Date dateUpdate) {
        this.dateUpdate = dateUpdate;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method returns the value of the database column t_test_user.deleted
     *
     * @return the value of t_test_user.deleted
     *
     * @mbggenerated
     */
    public Long getDeleted() {
        return deleted;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method sets the value of the database column t_test_user.deleted
     *
     * @param deleted the value for t_test_user.deleted
     *
     * @mbggenerated
     */
    public void setDeleted(Long deleted) {
        this.deleted = deleted;
    }

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table t_test_user
     *
     * @mbggenerated
     */
    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(hashCode());
        sb.append(", id=").append(id);
        sb.append(", memberId=").append(memberId);
        sb.append(", realName=").append(realName);
        sb.append(", nickname=").append(nickname);
        sb.append(", dateCreate=").append(dateCreate);
        sb.append(", dateUpdate=").append(dateUpdate);
        sb.append(", deleted=").append(deleted);
        sb.append(", serialVersionUID=").append(serialVersionUID);
        sb.append("]");
        return sb.toString();
    }
}
```

###### 3.3.6 执行查询



```java
@Slf4j
public class MyBatisBootStrap {

    public static void main(String[] args) {
        try {
            // 1. 读取配置
            InputStream inputStream = Resources.getResourceAsStream("mybatis-config.xml");
            // 2. 创建SqlSessionFactory工厂
            SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
            // 3. 获取sqlSession
            SqlSession sqlSession = sqlSessionFactory.openSession();
            // 4. 获取Mapper
            TTestUserMapper userMapper = sqlSession.getMapper(TTestUserMapper.class);
            // 5. 执行接口方法
            TTestUser userInfo = userMapper.selectByPrimaryKey(16L);
            System.out.println("userInfo = " + JSONUtil.toJsonStr(userInfo));
            // 6. 提交事务
            sqlSession.commit();
            // 7. 关闭资源
            sqlSession.close();
            inputStream.close();
        } catch (Exception e){
            log.error(e.getMessage(), e);
        }
    }
}
```

##### 3.4 区别

发现没有在写MyBatis的时候，新增了**dao**, **mapper.xml**, **entity**, **mybatis-config.xml**等很多东西，工作量反而增大了。但是**dao**, **mapper.xml,** **entity**都是可以**根据插件mybatis-generator生成**的，我们也不用一一去创建，而且我们没有涉及到原生JDBC中加载驱动，创建连接，处理结果集，关闭连接等等这些操作，这些都是MyBatis帮我们做了，我们**只用关心提供的查询接口**和**sql**编写即可。

如果使用原生的JDBC进行数据库操作，我们需要关心**如何加载驱动**，**如何获取连接关闭连接**，**如何获取结果集**等等与业务无关的地方，而MyBatis通过**“映射”**这个核心概念将**sql**和**java接口**关联起来，我们**调用java接口就相当于可以直接执行sql**，并且**将结果映射为java pojo对象**，这也是我们开头说的**“映射”**，**“面向对象的”**的原因了。

##### 4. 总结

这篇文章简单的介绍了下MyBatis的**基本概念**，并提供了简单的栗子，**接下来几篇文章打算写下Mybatis的启动流程**，让我们更好的了解下**mybatis的各模块协作**。

![image.png](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/20230322145827.png)
