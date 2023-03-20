---
title: Mybatis原理系列(3)
description: Mybatis原理系列(3)
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-framework
date: 2023-02-10 11:27:48
updated: 2023-02-10 11:27:48
---

> 转载自https://www.jianshu.com/p/4e268828db48（添加小部分笔记）感谢作者!

**还没看完**

> 在上篇文章中，我们讲解了MyBatis的启动流程，以及启动过程中涉及到的组件，在本篇文中，我们继续探索SqlSession,SqlSessionFactory,SqlSessionFactoryBuilder的关系。SqlSession作为MyBatis的核心组件，可以说MyBatis的所有操作都是围绕SqlSession来展开的。对**SqlSession理解透彻**，才能全面掌握MyBatis。

#### 1. SqlSession初识

SqlSession在一开始就介绍过是高级接口，类似于JDBC操作的connection对象，它包装了数据库连接，通过这个接口我们可以实现增删改查，提交/回滚事物，关闭连接，获取代理类等操作。SqlSession是个接口，其默认实现是DefaultSqlSession。SqlSession是线程不安全的，每个线程都会有自己唯一的SqlSession，不同线程间调用同一个SqlSession会出现问题，因此在使用完后需要close掉。



![img](https:////upload-images.jianshu.io/upload_images/1183379-d5d3c96bed2f4352.png?imageMogr2/auto-orient/strip|imageView2/2/w/413/format/webp)

SqlSession的方法

#### 2. SqlSession的创建

SqlSessionFactoryBuilder的build()方法使用建造者模式创建了SqlSessionFactory接口对象，SqlSessionFactory接口的默认实现是DefaultSqlSessionFactory。SqlSessionFactory使用实例工厂模式来创建SqlSession对象。SqlSession,SqlSessionFactory,SqlSessionFactoryBuilder的关系如下(图画得有点丑...)：

![img](https:////upload-images.jianshu.io/upload_images/1183379-8e031424b84ca308.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

类图

DefaultSqlSessionFactory中openSession是有两种方法一种是openSessionFromDataSource，另一种是openSessionFromConnection。这两种是什么区别呢？从字面意义上将，一种是从数据源中获取SqlSession对象，一种是由已有连接获取SqlSession。SqlSession实际是对数据库连接的一层包装，数据库连接是个珍贵的资源，如果频繁的创建销毁将会影响吞吐量，因此使用数据库连接池化技术就可以复用数据库连接了。因此openSessionFromDataSource会从数据库连接池中获取一个连接，然后包装成一个SqlSession对像。openSessionFromConnection则是直接包装已有的连接并返回SqlSession对像。

openSessionFromDataSource 主要经历了以下几步：

1. 从获取configuration中获取Environment对象，Environment包含了数据库配置
2. 从Environment获取DataSource数据源
3. 从DataSource数据源中获取Connection连接对象
4. 从DataSource数据源中获取TransactionFactory事物工厂
5. 从TransactionFactory中创建事物Transaction对象
6. 创建Executor对象
7. 包装configuration和Executor对象成DefaultSqlSession对象



```java
private SqlSession openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit) {
    Transaction tx = null;
    try {
      final Environment environment = configuration.getEnvironment();
      final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);
      tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);
      final Executor executor = configuration.newExecutor(tx, execType);
      return new DefaultSqlSession(configuration, executor, autoCommit);
    } catch (Exception e) {
      closeTransaction(tx); // may have fetched a connection so lets call close()
      throw ExceptionFactory.wrapException("Error opening session.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }

  private SqlSession openSessionFromConnection(ExecutorType execType, Connection connection) {
    try {
      boolean autoCommit;
      try {
        autoCommit = connection.getAutoCommit();
      } catch (SQLException e) {
        // Failover to true, as most poor drivers
        // or databases won't support transactions
        autoCommit = true;
      }
      final Environment environment = configuration.getEnvironment();
      final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);
      final Transaction tx = transactionFactory.newTransaction(connection);
      final Executor executor = configuration.newExecutor(tx, execType);
      return new DefaultSqlSession(configuration, executor, autoCommit);
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error opening session.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }
```

#### 3. SqlSession的使用

SqlSession 获取成功后，我们就可以使用其中的方法了，比如直接使用SqlSession发送sql语句，或者通过mapper映射文件的方式来使用，在上两篇文章中我们都是通过mapper映射文件来使用的，接下来就介绍第一种，直接使用SqlSession发送sql语句。



```cpp
public static void main(String[] args){
        try {
            // 1. 读取配置
            InputStream inputStream = Resources.getResourceAsStream("mybatis-config.xml");
            // 2. 获取SqlSessionFactory对象
            SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
            // 3. 获取SqlSession对象
            SqlSession sqlSession = sqlSessionFactory.openSession();
            // 4. 执行sql
            TTestUser user = sqlSession.selectOne("com.example.demo.dao.TTestUserMapper.selectByPrimaryKey", 13L);
            log.info("user = [{}]", JSONUtil.toJsonStr(user));
            // 5. 关闭连接
            sqlSession.close();
            inputStream.close();
        } catch (Exception e){
            log.error("errMsg = [{}]", e.getMessage(), e);
        }

    }
```

其中com.example.demo.dao.TTestUserMapper.selectByPrimaryKey指定了TTestUserMapper中selectByPrimaryKey这个方法，在对应的mapper/TTestUserMapper.xml我们定义了id一致的sql语句



```csharp
  <select id="selectByPrimaryKey" parameterType="java.lang.Long" resultMap="BaseResultMap">
    select 
    <include refid="Base_Column_List" />
    from t_test_user
    where id = #{id,jdbcType=BIGINT}
  </select>
```

Mybatis会在一开始加载的时候将每个标签中的sql语句包装成MappedStatement对象，并以类全路径名+方法名为key，MappedStatement为value缓存在内存中。在执行对应的方法时，就会根据这个唯一路径找到TTestUserMapper.xml这条sql语句并且执行返回结果。

#### 4. SqlSession的执行原理

#### 4. 1 SqlSession的selectOne的执行原理

SqlSession的selectOne代码如下，其实是调用selectList()方法获取第一条数据的。其中参数statement就是statement的id，parameter就是参数。



```cpp
public <T> T selectOne(String statement, Object parameter) {
        List<T> list = this.selectList(statement, parameter);
        if (list.size() == 1) {
            return list.get(0);
        } else if (list.size() > 1) {
            throw new TooManyResultsException("Expected one result (or null) to be returned by selectOne(), but found: " + list.size());
        } else {
            return null;
        }
    }
```

RowBounds 对象是分页对象，主要拼接sql中的start,limit条件。并且可以看到两个重要步骤：

1. 从configuration的成员变量mappedStatements中获取MappedStatement对象。mappedStatements是Map<String, MappedStatement>类型的缓存结构，其中key就是mapper接口全类名+方法名，MappedStatement就是对标签中配置的sql一个包装
2. 使用executor成员变量来执行查询并且指定结果处理器，并且返回结果。Executor也是mybatis的一个重要的组件。sql的执行都是由Executor对象来操作的。



```kotlin
public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {
        List var5;
        try {
            MappedStatement ms = this.configuration.getMappedStatement(statement);
            var5 = this.executor.query(ms, this.wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);
        } catch (Exception var9) {
            throw ExceptionFactory.wrapException("Error querying database.  Cause: " + var9, var9);
        } finally {
            ErrorContext.instance().reset();
        }

        return var5;
    }
```

MappedStatement对象的具体内容和Executor对象的类型，我们将在其它文章中详述。

#### 4. 2 SqlSession的通过mapper对象使用的执行原理

在启动流程那篇文章中，我们大致了解了sqlSession.getMapper返回的其实是个代理类MapperProxy，然后调mapper接口的方法其实都是调用MapperProxy的invoke方法，进而调用MapperMethod的execute方法。



```java
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
           // 6. 提交事物
           sqlSession.commit();
           // 7. 关闭资源
           sqlSession.close();
           inputStream.close();
       } catch (Exception e){
           log.error(e.getMessage(), e);
       }
   }
```

MapperMethod的execute方法中使用命令模式进行增删改查操作，其实也是调用了sqlSession的增删改查方法。



```tsx
public Object execute(SqlSession sqlSession, Object[] args) {
    Object result;
    switch (command.getType()) {
      case INSERT: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.insert(command.getName(), param));
        break;
      }
      case UPDATE: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.update(command.getName(), param));
        break;
      }
      case DELETE: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.delete(command.getName(), param));
        break;
      }
      case SELECT:
        if (method.returnsVoid() && method.hasResultHandler()) {
          executeWithResultHandler(sqlSession, args);
          result = null;
        } else if (method.returnsMany()) {
          result = executeForMany(sqlSession, args);
        } else if (method.returnsMap()) {
          result = executeForMap(sqlSession, args);
        } else if (method.returnsCursor()) {
          result = executeForCursor(sqlSession, args);
        } else {
          Object param = method.convertArgsToSqlCommandParam(args);
          result = sqlSession.selectOne(command.getName(), param);
          if (method.returnsOptional()
              && (result == null || !method.getReturnType().equals(result.getClass()))) {
            result = Optional.ofNullable(result);
          }
        }
        break;
      case FLUSH:
        result = sqlSession.flushStatements();
        break;
      default:
        throw new BindingException("Unknown execution method for: " + command.getName());
    }
    if (result == null && method.getReturnType().isPrimitive() && !method.returnsVoid()) {
      throw new BindingException("Mapper method '" + command.getName()
          + " attempted to return null from a method with a primitive return type (" + method.getReturnType() + ").");
    }
    return result;
  }
```

#### 总结

在这篇文章中我们详细介绍了SqlSession的作用，创建过程，使用方法，以及执行原理等，对SqlSession已经有了比较全面的了解。其中涉及到的Executor对象，MappedStatement对象，ResultHandler我们将在其它文章中讲解。欢迎在评论区中讨论指正，一起进步。

 