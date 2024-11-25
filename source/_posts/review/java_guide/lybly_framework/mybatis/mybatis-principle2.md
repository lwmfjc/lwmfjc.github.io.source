---
title: Mybatis原理系列(2)
description: Mybatis原理系列(2)
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-framework
date: 2023-02-10 11:04:31
updated: 2023-02-10 11:04:31
---

> 转载自https://www.jianshu.com/p/7d6b891180a3（添加小部分笔记）感谢作者!

> 在上篇文章中，我们举了一个例子如何使用MyBatis，但是对其中**dao层**，**entity层**，**mapper层**间的关系不得而知，从此篇文章开始，笔者将**从MyBatis的启动流程**着手，真正的开始研究MyBatis源码了。

#### 1. MyBatis启动代码示例

在上篇文章中，介绍了MyBatis的相关配置和各层代码编写，本文将以下代码展开描述和介绍MyBatis的启动流程，并简略的介绍各个模块的作用，**各个模块的细节部分将在其它文章中呈现**。

回顾下上文中使用mybatis的部分代码，包括七步。每步虽然都是一行代码，但是隐藏了很多细节。接下来我们将围绕这起步展开了解。



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
            // 6. 提交事物
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

#### 2. 读取配置



```cpp
// 1. 读取配置
InputStream inputStream = Resources.getResourceAsStream("mybatis-config.xml");
```

在**mybatis-config.xml**中我们配置了**属性**，**环境**，**映射文件路径**等，其实不仅可以配置以上内容，还可以配置**插件**，**反射工厂**，**类型处理器**等等其它内容。在启动流程中的第一步我们就需要**读取这个配置文件**，并获取一个输入流为下一步解析配置文件作准备。

mybatis-config.xml 内容如下



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
                <property name="url" value="jdbc:mysql://10.255.0.50:3306/volvo_bev?useUnicode=true"/>
                <property name="username" value="appdev"/>
                <property name="password" value="FEGwo3EzsdDYS9ooYKGCjRQepkwG"/>
            </dataSource>
        </environment>
    </environments>

    <mappers>
        <!--这边可以使用package和resource两种方式加载mapper-->
        <!--<package name="包名"/>-->
        <!--<mapper resource="./mappers/SysUserMapper.xml"/>
        <package name="com.example.demo.dao"/> -->
        <mapper resource="./mapper/TTestUserMapper.xml"/>
    </mappers>

</configuration>
```

#### 3. 创建SqlSessionFactory工厂



```cpp
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```

我们在学习Java的设计模式时，会学到**工厂模式**，工厂模式又分为**简单工厂模式**，**工厂方法模式**，**抽象工厂模式**等等。工厂模式就是**为了创建对象提供接口**，并**将创建对象的具体细节屏蔽**起来，从而可以提高灵活性。



```java
public interface SqlSessionFactory {

  SqlSession openSession();

  SqlSession openSession(boolean autoCommit);

  SqlSession openSession(Connection connection);

  SqlSession openSession(TransactionIsolationLevel level);

  SqlSession openSession(ExecutorType execType);

  SqlSession openSession(ExecutorType execType, boolean autoCommit);

  SqlSession openSession(ExecutorType execType, TransactionIsolationLevel level);

  SqlSession openSession(ExecutorType execType, Connection connection);

  Configuration getConfiguration();

}
```

由此可知**SqlSessionFactory工厂是为了创建一个对象而生**的，其产出的对象就是**SqlSession对象**。**SqlSession**是MyBatis面向数据库的高级接口，其提供了**执行查询sql**，**更新sql**，**提交事物**，**回滚事物**，**获取映射代理类(也就是Mapper)**等等方法。

在此笔者列出了主要方法，一些重载的方法就过滤掉了。



```java
public interface SqlSession extends Closeable {

  /**
  * 查询一个结果对象
  **/ 
  <T> T selectOne(String statement, Object parameter);
  
   /**
  * 查询一个结果集合
  **/ 
  <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds);
  
   /**
  * 查询一个map
  **/ 
  <K, V> Map<K, V> selectMap(String statement, Object parameter, String mapKey, RowBounds rowBounds);

   /**
  * 查询游标
  **/ 
  <T> Cursor<T> selectCursor(String statement, Object parameter, RowBounds rowBounds);

  void select(String statement, Object parameter, RowBounds rowBounds, ResultHandler handler);
  
     /**
  * 插入
  **/ 
  int insert(String statement, Object parameter);

    /**
  * 修改
  **/ 
  int update(String statement, Object parameter);

  /**
  * 删除
  **/
  int delete(String statement, Object parameter);

   /**
  * 提交事物
  **/
  void commit(boolean force);
  
   /**
  * 回滚事物
  **/
  void rollback(boolean force);

  List<BatchResult> flushStatements();

  void close();

  void clearCache();

  Configuration getConfiguration();

   /**
  * 获取映射代理类
  **/
  <T> T getMapper(Class<T> type);

   /**
  * 获取数据库连接
  **/
  Connection getConnection();
}
```

回到开始，SqlSessionFactory工厂是怎么创建的出来的呢？**SqlSessionFactoryBuilder就是创建者**，以Builder结尾我们很容易想到了Java设计模式中的**建造者**模式，一个对象的创建是**由众多复杂对象组成**的，建造者模式就是一个**创建复杂对象**的选择，它与工厂模式相比，建造者模式更加**关注零件装配的顺序**。



```java
public class SqlSessionFactoryBuilder {

  public SqlSessionFactory build(InputStream inputStream, String environment, Properties properties) {
    try {
      XMLConfigBuilder parser = new XMLConfigBuilder(inputStream, environment, properties);
      return build(parser.parse());
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error building SqlSession.", e);
    } finally {
      ErrorContext.instance().reset();
      try {
        inputStream.close();
      } catch (IOException e) {
        // Intentionally ignore. Prefer previous error.
      }
    }
  }

}
```

其中**XMLConfigBuilder**就是**解析mybatis-config.xml**中每个标签的内容，parse()方法**返回**的就是一个**Configuration**对象.Configuration也是MyBatis中一个很重要的组件，包括**插件**，**对象工厂**，**反射工厂**，**映射文件**，**类型解析器**等等都**存储在Configuration**对象中。



```cpp
public Configuration parse() {
    if (parsed) {
      throw new BuilderException("Each XMLConfigBuilder can only be used once.");
    }
    parsed = true;
    parseConfiguration(parser.evalNode("/configuration"));
    return configuration;
  }

  private void parseConfiguration(XNode root) {
    try {
      // issue #117 read properties first
      // 解析properties节点
      propertiesElement(root.evalNode("properties"));
      Properties settings = settingsAsProperties(root.evalNode("settings"));
      loadCustomVfs(settings);
      loadCustomLogImpl(settings);
      typeAliasesElement(root.evalNode("typeAliases"));
      pluginElement(root.evalNode("plugins"));
      objectFactoryElement(root.evalNode("objectFactory"));
      objectWrapperFactoryElement(root.evalNode("objectWrapperFactory"));
      reflectorFactoryElement(root.evalNode("reflectorFactory"));
      settingsElement(settings);
      // read it after objectFactory and objectWrapperFactory issue #631
      environmentsElement(root.evalNode("environments"));
      databaseIdProviderElement(root.evalNode("databaseIdProvider"));
      typeHandlerElement(root.evalNode("typeHandlers"));
      mapperElement(root.evalNode("mappers"));
    } catch (Exception e) {
      throw new BuilderException("Error parsing SQL Mapper Configuration. Cause: " + e, e);
    }
  }
```

在获取到Configuration对象后，SqlSessionFactoryBuilder就会**创建一个DefaultSqlSessionFactory**对象，DefaultSqlSessionFactory是SqlSessionFactory的一个**默认实现**，还有一个实现是**SqlSessionManager**。



```cpp
  public SqlSessionFactory build(Configuration config) {
    return new DefaultSqlSessionFactory(config);
  }
```

![img](images/mypost/1183379-7878f46b525e5eb5.png)

#### 4. 获取sqlSession

```cpp
  // 3. 获取sqlSession
 SqlSession sqlSession = sqlSessionFactory.openSession();
```

在前面我们讲到，sqlSession是**操作数据库的高级接口**，我们**操作数据库**都是**通过这个接口**操作的。获取sqlSession有两种方式，一种是**从数据源中获取**的，还有一种是**从连接中**获取。

> 貌似默认是从数据源获取

 获取到的都是**DefaultSqlSession**对象，也就是sqlSession的默认实现。

> 注意，过程中有个Executor---执行器

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

获取SqlSession步骤   


![img](images/mypost/1183379-eeb14e57446c8a35.png)

#### 5. 获取Mapper代理类

在上一步获取到sqlSession后，我们接下来就获取到了mapper代理类。



```java
 // 4. 获取Mapper
 TTestUserMapper userMapper = sqlSession.getMapper(TTestUserMapper.class);
```

这个getMapper方法，我们看看DefaultSqlSession是怎么做的

DefaultSqlSession 的 getMapper 方法



```kotlin
  public <T> T getMapper(Class<T> type) {
       return this.configuration.getMapper(type, this);
   }
```

Configuration 的 getMapper 方法



```kotlin
  public <T> T getMapper(Class<T> type, SqlSession sqlSession) {
        return this.mapperRegistry.getMapper(type, sqlSession);
    }
```

MapperRegistry 中有个getMapper方法，实际上是从成员变量knownMappers中获取的，这个knownMappers是个key-value形式的缓存，key是mapper接口的class对象，value是**MapperProxyFactory代理工厂**，**这个工厂就是用来创建MapperProxy代理类**的。



```java
public class MapperRegistry {
    private final Configuration config;
    private final Map<Class<?>, MapperProxyFactory<?>> knownMappers = new HashMap();

    public MapperRegistry(Configuration config) {
        this.config = config;
    }

    public <T> T getMapper(Class<T> type, SqlSession sqlSession) {
        MapperProxyFactory<T> mapperProxyFactory = (MapperProxyFactory)this.knownMappers.get(type);
        if (mapperProxyFactory == null) {
            throw new BindingException("Type " + type + " is not known to the MapperRegistry.");
        } else {
            try {
                return mapperProxyFactory.newInstance(sqlSession);
            } catch (Exception var5) {
                throw new BindingException("Error getting mapper instance. Cause: " + var5, var5);
            }
        }
    }
}
```

如果对java动态代理了解的同学就知道，**Proxy.newProxyInstance()**方法可以创建出一个目标对象一个代理对象。由此可知**每次调用getMapper方法都会创建出一个代理类**出来。



```kotlin
public class MapperProxyFactory<T> {
    private final Class<T> mapperInterface;
    private final Map<Method, MapperMethod> methodCache = new ConcurrentHashMap();

    public MapperProxyFactory(Class<T> mapperInterface) {
        this.mapperInterface = mapperInterface;
    }

    public Class<T> getMapperInterface() {
        return this.mapperInterface;
    }

    public Map<Method, MapperMethod> getMethodCache() {
        return this.methodCache;
    }

    protected T newInstance(MapperProxy<T> mapperProxy) {
        return Proxy.newProxyInstance(this.mapperInterface.getClassLoader(), new Class[]{this.mapperInterface}, mapperProxy);
    }

    public T newInstance(SqlSession sqlSession) {
        MapperProxy<T> mapperProxy = new MapperProxy(sqlSession, this.mapperInterface, this.methodCache);
        return this.newInstance(mapperProxy);
    }
}
```

回到上面，那这个MapperProxyFactory是怎么加载到MapperRegistry的knownMappers缓存中的呢？

在上面的**Configuration类的parseConfiguration**方法中，我们会**解析 mappers标签**，mapperElement方法就会解析mapper接口。



```cpp
private void parseConfiguration(XNode root) {
    try {
      // issue #117 read properties first
      // 解析properties节点
      propertiesElement(root.evalNode("properties"));
      Properties settings = settingsAsProperties(root.evalNode("settings"));
      loadCustomVfs(settings);
      loadCustomLogImpl(settings);
      typeAliasesElement(root.evalNode("typeAliases"));
      pluginElement(root.evalNode("plugins"));
      objectFactoryElement(root.evalNode("objectFactory"));
      objectWrapperFactoryElement(root.evalNode("objectWrapperFactory"));
      reflectorFactoryElement(root.evalNode("reflectorFactory"));
      settingsElement(settings);
      // read it after objectFactory and objectWrapperFactory issue #631
      environmentsElement(root.evalNode("environments"));
      databaseIdProviderElement(root.evalNode("databaseIdProvider"));
      typeHandlerElement(root.evalNode("typeHandlers"));
      mapperElement(root.evalNode("mappers"));
    } catch (Exception e) {
      throw new BuilderException("Error parsing SQL Mapper Configuration. Cause: " + e, e);
    }
  }
```



```tsx
  private void mapperElement(XNode parent) throws Exception {
    if (parent != null) {
      for (XNode child : parent.getChildren()) {
        if ("package".equals(child.getName())) {
          String mapperPackage = child.getStringAttribute("name");
          configuration.addMappers(mapperPackage);
        } else {
          String resource = child.getStringAttribute("resource");
          String url = child.getStringAttribute("url");
          String mapperClass = child.getStringAttribute("class");
          if (resource != null && url == null && mapperClass == null) {
            ErrorContext.instance().resource(resource);
            InputStream inputStream = Resources.getResourceAsStream(resource);
            XMLMapperBuilder mapperParser = new XMLMapperBuilder(inputStream, configuration, resource, configuration.getSqlFragments());
            mapperParser.parse();
          } else if (resource == null && url != null && mapperClass == null) {
            ErrorContext.instance().resource(url);
            InputStream inputStream = Resources.getUrlAsStream(url);
            XMLMapperBuilder mapperParser = new XMLMapperBuilder(inputStream, configuration, url, configuration.getSqlFragments());
            mapperParser.parse();
          } else if (resource == null && url == null && mapperClass != null) {
            Class<?> mapperInterface = Resources.classForName(mapperClass);
            configuration.addMapper(mapperInterface);
          } else {
            throw new BuilderException("A mapper element may only specify a url, resource or class, but not more than one.");
          }
        }
      }
    }
  }
```

解析完后，就**将这个mapper接口加到 mapperRegistry**中，



```css
configuration.addMapper(mapperInterface);
```

Configuration的addMapper方法



```tsx
  public <T> void addMapper(Class<T> type) {
    mapperRegistry.addMapper(type);
  }
```

最后还是加载到了MapperRegistry的knownMappers中去了



```tsx
  public <T> void addMapper(Class<T> type) {
    if (type.isInterface()) {
      if (hasMapper(type)) {
        throw new BindingException("Type " + type + " is already known to the MapperRegistry.");
      }
      boolean loadCompleted = false;
      try {
        knownMappers.put(type, new MapperProxyFactory<>(type));
        // It's important that the type is added before the parser is run
        // otherwise the binding may automatically be attempted by the
        // mapper parser. If the type is already known, it won't try.
        MapperAnnotationBuilder parser = new MapperAnnotationBuilder(config, type);
        parser.parse();
        loadCompleted = true;
      } finally {
        if (!loadCompleted) {
          knownMappers.remove(type);
        }
      }
    }
  }
```

![img](images/mypost/1183379-a4d935d1159e3cad.png)

获取mapper代理类过程

#### 6. 执行mapper接口方法



```cpp
 // 5. 执行接口方法
 TTestUser userInfo = userMapper.selectByPrimaryKey(16L);
```

selectByPrimaryKey是TTestUserMapper接口中定义的一个方法，但是我们没有编写TTestUserMapper接口的的实现类，那么Mybatis是怎么帮我们执行的呢？前面讲到，获取mapper对象时，是**会获取到一个MapperProxyFactory工厂类**，并**创建一个MapperProxy代理类**，在**执行Mapper接口的方法**时，会**调用MapperProxy的invoke方法**。



```dart
 @Override
  public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    try {
      if (Object.class.equals(method.getDeclaringClass())) {
        return method.invoke(this, args);
      } else {
        return cachedInvoker(method).invoke(proxy, method, args, sqlSession);
      }
    } catch (Throwable t) {
      throw ExceptionUtil.unwrapThrowable(t);
    }
  }
```

如果是Object的方法就直接执行，否则**执行cachedInvoker(method).invoke(proxy, method, args, sqlSession);** 这行代码，到这里，想必有部分同学已经头晕了吧。怎么又来了个invoke方法。
 **cachedInvoker** 是返回**缓存的MapperMethodInvoker**对象，**MapperMethodInvoker**的invoke方法会执行**MapperMethod的execute**方法。



```tsx
public class MapperMethod {

  private final SqlCommand command;
  private final MethodSignature method;

  public MapperMethod(Class<?> mapperInterface, Method method, Configuration config) {
    this.command = new SqlCommand(config, mapperInterface, method);
    this.method = new MethodSignature(config, mapperInterface, method);
  }

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
}
```

然后**根据执行的接口找到mapper.xml中配置的sql**，并**处理参数**，然后执行返回结果处理结果等步骤。

#### 7. 提交事务



```cpp
// 6. 提交事务
sqlSession.commit();
```

事务就是将若干数据库操作看成一个单元，要么全部成功，要么全部失败，如果失败了，则会执行执行回滚操作，恢复到开始执行的数据库状态。

#### 8. 关闭资源



```go
 // 7. 关闭资源
sqlSession.close();
inputStream.close();
```

sqlSession是种共用资源，用完了要返回到池子中，以供其它地方使用。

#### 9. 总结

至此我们已经大致了解了**Mybatis启动时的大致流程**，很多细节都还没有详细介绍，这是因为涉及到的层面又深又广，如果在一篇文章中介绍，反而会让读者如置云里雾里，不知所云。因此，在接下来我将每个模块的详细介绍。如果文章有什么错误或者需要改进的，希望同学们指出来，希望对大家有帮助。

![image.png](images/mypost/20230322160744.png)
