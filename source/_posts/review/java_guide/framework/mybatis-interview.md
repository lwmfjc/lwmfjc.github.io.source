---
title: Mybatis面试
description: Mybatis面试
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-framework
date: 2023-02-09 16:34:39
updated: 2023-02-09 16:34:39
---

> 转载自https://github.com/Snailclimb/JavaGuide（添加小部分笔记）感谢作者!
>
> 部分疑问参考自 https://blog.csdn.net/Gherbirthday0916 感谢作者! 

### #{} 和 ${} 的区别是什么？

注：这道题是面试官面试我同事的。

答：

- `${}`是 Properties **文件中的变量占位符**，它可以用于**标签属性值**和 **sql 内部**，属于**静态文本替换**，比如${driver}会被静态替换为`com.mysql.jdbc. Driver`。
- `#{}`是 sql 的参数占位符，MyBatis 会**将 sql 中的`#{}`**替换为**? 号**，在 sql 执行前会使用 **PreparedStatement 的参数设置**方法，**按序给 sql 的? 号占位符设置参数值**，比如 ps.setInt(0, parameterValue)，`#{item.name}` 的取值方式为使用**反射从参数对象中获取 item 对象的 name 属性值**，相当于 **`param.getItem().getName()`**。 [**这里用到了反射**]

> 在**底层构造完整SQL**语句时，MyBatis的两种**传参方式**所采取的方式不同。`#{Parameter}`采用**预编译**的方式构造SQL，**避免了 SQL注入** 的产生。而**`${Parameter}`采用拼接**的方式构造SQL，在**对用户输入过滤不严格**的前提下，此处很可能存在SQL注入

### xml 映射文件中，除了常见的 select、insert、update、delete 标签之外，还有哪些标签？

注：这道题是京东面试官面试我时问的。

答：还有很多其他的标签， **`<resultMap>`** 、 **`<parameterMap>`** 、 **`<sql>`** 、 **`<include>`** 、 **`<selectKey>`** ，加上动态 sql 的 9 个标签， **`trim|where|set|foreach|if|choose|when|otherwise|bind`** 等，其中 `<sql>` 为 sql 片段标签，通过 `<include>` 标签引入 sql 片段， `<selectKey>` 为不支持自增的主键生成策略标签。  

> set标签，是update用的  
>
> ```xml
> <update id="updateUserById" parameterType="user">
>      update user
>      <set>
>          <if test="uid!=null">
>            uid=#{uid} 
>          </if> 
>  	</set>
> </update>
> ```
>
> -----
>
> 1. **ResultMap（结果集映射）：**  
>    假设我们的**数据库字段**和**映射pojo类的属性字段不一致**，那么查询结果，不一致的字段值会为null  
>    这时可以使用Mybatis `ResultMap` 结果集映射
>
> 2. **parameterMap（参数类型映射）：**  
>
>    > 很少使用，基本都用**parameterType**替代
>
>    `parameterMap`标签可以用来定义参数组，可以为参数组**指定ID**、**参数类型**
>
>    例如有一个bean是这样的：  
>
>    ```java
>    public class ArgBean {
>        private String name;
>        private int age;
>        // 忽略 getter 和 setter
>    }
>    ```
>
>    下面使用 `<parameterMap>` 将参数 ArgBean 对象进行映射
>
>    ```xml
>    <parameterMap id="PARAM_MAP" type="com.hxstrive.mybatis.parameter.demo2.ArgBean">
>        <parameter property="age" javaType="integer" />
>        <parameter property="name" javaType="String" />
>    </parameterMap> 
>    ```
>
> 3. **sql（sql片段标签）/include（片段插入标签）：**  重复的SQL预计永远不可避免，`<sql>`标签就是用来解决这个问题的
>
>    其中 `<sql>` 为 sql 片段标签，通过 `<include>` 标签引入 sql 片段
>
>    例如：  
>
>    ```xml
>    <mapper namespace="com.klza.dao.UserMapper">
>        <sql id="sqlUserParameter">id,username,password</sql>
>        <select id="getUserList" resultType="user">
>            select
>            <include refid="sqlUserParameter"/>
>            from test.user
>        </select>
>    </mapper> 
>    ```
>
>    **`<selectKey>` 为不支持自增的主键生成策略标签**  
>
>    ```xml
>    <insert id="insert" parameterType="com.pinyougou.pojo.TbGoods" >
>        <selectKey resultType="java.lang.Long" order="AFTER" keyProperty="id">
>          SELECT LAST_INSERT_ID() AS id
>        </selectKey>
>        insert into tb_goods (id, seller_id )
>        values (#{id,jdbcType=BIGINT}, #{sellerId,jdbcType=VARCHAR} 
>      </insert>
>    ```
>
>    

### Dao 接口的工作原理是什么？Dao 接口里的方法，参数不同时，方法能重载吗？

注：这道题也是京东面试官面试我被问的。

答：最佳实践中，通常**一个 xml 映射**文件，都会写**一个 Dao 接口**与之对应。Dao 接口就是人们常说的 `Mapper` **接口**，接口的全限名，就是**映射文件中的 namespace 的值**，**接口的方法名**，就是**映射文件中 `MappedStatement` 的 id 值**，接口方法内的**参数**，就是**传递给 sql 的参数**。 `Mapper` 接口是没有实现类的，当**调用接口方法**时，**接口全限名+方法名拼接字符串作为 key** 值，可**唯一定位一个 `MappedStatement`** ，举例： `com.mybatis3.mappers. StudentDao.findStudentById` ，可以唯一找到 namespace 为 `com.mybatis3.mappers. StudentDao` 下面 `id = findStudentById` 的 `MappedStatement` 。在 MyBatis 中，**每一个 `<select>`** 、 **`<insert>`** 、 **`<update>`** 、 **`<delete>`** 标签，都会被解析为一个 **`MappedStatement`** 对象。

~~Dao 接口里的方法，是不能重载的，因为是全限名+方法名的保存和寻找策略。~~

Dao 接口里的**方法可以重载**，但是 Mybatis 的 **xml 里面的 ID 不允许重复**。

Mybatis 版本 3.3.0，亲测如下：

```java
/**
 * Mapper接口里面方法重载
 */
public interface StuMapper {

	List<Student> getAllStu();

	List<Student> getAllStu(@Param("id") Integer id);
}
```

然后在 `StuMapper.xml` 中利用 Mybatis 的动态 sql 就可以实现。

```xml
	<select id="getAllStu" resultType="com.pojo.Student">
 		select * from student
		<where>
			<if test="id != null">
				id = #{id}
			</if>
		</where>
 	</select>
```

能正常运行，并能得到相应的结果，这样就实现了在 Dao 接口中写重载方法。

**Mybatis 的 Dao 接口可以有多个重载方法，但是多个接口对应的映射必须只有一个，否则启动会报错。**

相关 issue ：[更正：Dao 接口里的方法可以重载，但是 Mybatis 的 xml 里面的 ID 不允许重复！](https://github.com/Snailclimb/JavaGuide/issues/1122)。

Dao 接口的工作原理是 **JDK 动态代理**，MyBatis 运行时会**使用 JDK 动态代理为 Dao 接口生成代理 proxy 对象**，代理对象 proxy 会**拦截接口方法**，转而**执行 `MappedStatement` 所代表的 sql**，然后**将 sql 执行结果返回**。

**补充** ：

Dao 接口方法可以重载，但是需要满足以下条件：

1. **仅有一个无参方法**和**一个有参方法**
2. **(多个参数)的方法中，参数数量必须(和xml中的)一致**。且使用**相同的 `@Param`** ，或者使用 `param1` 这种

**测试如下** ：

```java
PersonDao.java
Person queryById();

Person queryById(@Param("id") Long id);

Person queryById(@Param("id") Long id, @Param("name") String name);
PersonMapper.xml
<select id="queryById" resultMap="PersonMap">
    select
      id, name, age, address
    from person
    <where>
        <if test="id != null">
            id = #{id}
        </if>
        <if test="name != null and name != ''">
            and name = #{name}
        </if>
    </where>
    limit 1
</select>
```

`org.apache.ibatis.scripting.xmltags. DynamicContext. ContextAccessor#getProperty` 方法用于获取 `<if>` 标签中的条件值  

> ContextAccessor 这个修饰符为默认（同一个包内）

```java
public Object getProperty(Map context, Object target, Object name) {
  Map map = (Map) target;

  Object result = map.get(name);
  if (map.containsKey(name) || result != null) {
    return result;
  }

  Object parameterObject = map.get(PARAMETER_OBJECT_KEY);
  if (parameterObject instanceof Map) {
    return ((Map)parameterObject).get(name);
  }

  return null;
}
```

`parameterObject` 为 map，存放的是 Dao 接口中参数相关信息。

`((Map)parameterObject).get(name)` 方法如下

```java
public V get(Object key) {
  if (!super.containsKey(key)) {
    throw new BindingException("Parameter '" + key + "' not found. Available parameters are " + keySet());
  }
  return super.get(key);
}
```

1. `queryById()`方法执行时，**`parameterObject`为 null**，**`getProperty`方法返回 null 值**，**`<if>`标签获取的所有条件值都为 null**，所有条件不成立，动态 sql 可以正常执行。
2. `queryById(1L)`方法执行时，`parameterObject`为 map，包含了**`id`和`param1`**两个 key 值。当获取`<if>`标签中`name`的属性值时，**进入`((Map)parameterObject).get(name)`方法中，map 中 key 不包含`name`，所以抛出异常**。
3. `queryById(1L,"1")`方法执行时，**`parameterObject`中包含`id`,`param1`,`name`,`param2`四个 key 值，`id`和`name`属性都可以获取到**，动态 sql 正常执行。

> 也就是说，if**的test一定是会进行判断**的(**除非整个parameterObject为null)**。但是如果这里面的param 不存在，那么就会抛异常 (BindingException)

### MyBatis 是如何进行分页的？分页插件的原理是什么？

注：我出的。

答：**(1)** MyBatis 使用 RowBounds 对象进行分页，它是**针对 ResultSet 结果集**执行的**内存分页**，而非物理分页；  

```java
//使用 
//Mapper中  
List<User> getUserListLimit(RowBounds rowBounds);
//Mapper.xml定义 （不变）  
<select id="getUserListLimit" resultType="user">
    select * from test.user
</select>
//使用, 将会从index为0的记录开始，取两条记录

List<User> userListLimit = userMapper.getUserListLimit(new RowBounds(0, 2));
for (User user : userListLimit) {
    System.out.println(user);
} 
```

> 想要使用mybatis日志，只要加上日志模块的依赖即可  
>
> ```xml
> 		<dependency>
>             <groupId>org.slf4j</groupId>
>             <artifactId>slf4j-api</artifactId>
>             <version>1.7.30</version>
>         </dependency>
>         <!-- https://mvnrepository.com/artifact/ch.qos.logback/logback-classic -->
>         <dependency>
>             <groupId>ch.qos.logback</groupId>
>             <artifactId>logback-classic</artifactId>
>             <version>1.2.3</version>
>         </dependency>
> ```
>
> 查看上面的日志可以发现，实际查找的是全部的数据(没有使用物理分页)  
>
> ```shell
> 14:28:14.938 [main] DEBUG org.mybatis.example.BlogMapper.selectBlog - ==>  Preparing: select * from Blog
> 14:28:14.996 [main] DEBUG org.mybatis.example.BlogMapper.selectBlog - ==> Parameters: 
> [Blog{id=2, name='n2', age=20}, Blog{id=3, name='n3', age=30}]
> ```

**(2)** **可以在 sql 内直接书写带有物理分页的参数来完成物理分页功能**   
**(3)** 也可以**使用分页插件**来完成物理分页  
分页插件的基本原理是使用 MyBatis 提供的插件接口，实现自定义插件，在**插件的拦截方法内拦截待执行的 sql**，然后**重写 sql**，根据 dialect 方言，添加**对应的物理分页语句**和**物理分页参数**。

举例： `select _ from student` ，拦截 sql 后重写为： `select t._ from （select \* from student）t limit 0，10`  

> 分页插件的使用  
> 接下来介绍PageHelper插件的使用：
>
> 第一步，引入依赖：
>
> ```xml
> <!-- https://mvnrepository.com/artifact/com.github.pagehelper/pagehelper -->
> <dependency>
>     <groupId>com.github.pagehelper</groupId>
>     <artifactId>pagehelper</artifactId>
>     <version>5.3.2</version>
> </dependency>
> ```
>
> 第二步，mybatis-config.xml配置拦截器：
>
> ```xml
> <!-- 配置pageHelper拦截器 -->
> <plugins>
>     <plugin interceptor="com.github.pagehelper.PageInterceptor"/>
> </plugins>
> ```
>
> 第三步，代码编写：
>
> Mapper接口类：
>
> ```java
> List<User> getUserListByPageHelper();
> ```
>
> Mapper.xml：  
>
> ```xml
> <select id="getUserListByPageHelper" resultType="user">
>     select * from test.user
> </select>
> ```
>
> 测试程序：
>
> ```java
> // 开启分页功能
> int pageNum = 1;  // 当前页码
> int pageSize = 2;  // 每页的记录数
> PageHelper.startPage(pageNum, pageSize);
> List<User> userListByPageHelper = userMapper.getUserListByPageHelper();
> userListByPageHelper.forEach(System.out::println); 
> ```
>
> 第四步：获取pageInfo信息：
>
> pageHelper真正强大的地方在于它的pageInfo功能，它可以为我们提供详细的分页数据：
>
> 例如：
>
> ```java
> // 开启分页功能
> int pageNum = 2;  // 当前页码
> int pageSize = 5;  // 每页的记录数
> PageHelper.startPage(pageNum, pageSize);
> List<User> userListByPageHelper = userMapper.getUserListByPageHelper();
> // 设置导航的卡片数为3
> PageInfo<User> userPageInfo = new PageInfo<>(userListByPageHelper, 3);
> System.out.println(userPageInfo);
> /*
>  * PageInfo{pageNum=2, pageSize=5, size=5, startRow=6, endRow=10, total=1004, pages=201,
>  * list=Page{count=true, pageNum=2, pageSize=5, startRow=5, endRow=10, total=1004, pages=201, reasonable=false, pageSizeZero=false}
>  * [User(id=6, username=Cheng Zhennan, password=Jx3SLGXeS4), User(id=7, username=Thelma Hernandez, password=VxVO6dEgym), User(id=8, username=Emma Wood, password=XljUnUrnFZ), User(id=9, username=Kikuchi Akina, password=IgditeatR7), User(id=10, username=Miura Kenta, password=2CbmTGczZv)],
>  * prePage=1, nextPage=3, isFirstPage=false, isLastPage=false, hasPreviousPage=true, hasNextPage=true, navigatePages=3, navigateFirstPage=1, navigateLastPage=3, navigatepageNums=[1, 2, 3]} 
> ```

### 简述 MyBatis 的插件运行原理，以及如何编写一个插件。

注：我出的。

答：MyBatis 仅可以编写针对 **`ParameterHandler`** 、 **`ResultSetHandler`** 、 **`StatementHandler`** 、 **`Executor`** 这 4 种接口的插件，MyBatis **使用 JDK 的动态代理**，为**需要拦截的接口生成代理对象**以实现接口方法拦截功能，**每当执行这 4 种接口**对象的方法时，就会进入拦截方法，具体就是 **`InvocationHandler` 的 `invoke()`** 方法，当然，只会**拦截那些你指定需要拦截的方法**。

实现 MyBatis 的 `Interceptor` 接口并复写 `intercept()` 方法，然后在**给插件编写注解**，**指定要拦截哪一个接口的哪些方法**即可，记住，别忘了**在配置文件中配置你编写的插件**。

### MyBatis 执行批量插入，能返回数据库主键列表吗？

注：我出的。

答：能，JDBC 都能，MyBatis 当然也能。

### MyBatis 动态 sql 是做什么的？都有哪些动态 sql？能简述一下动态 sql 的执行原理不？

注：我出的。

答：MyBatis 动态 sql 可以让我们在 xml 映射文件内，**以标签的形式编写动态 sql**，完成**逻辑判断**和**动态拼接 sql** 的功能。其执行原理为，使用 **OGNL 从 sql 参数对象中计算表达式的值**，**根据表达式的值动态拼接 sql**，**以此来完成动态 sql 的功能**。

MyBatis 提供了 9 种动态 sql 标签:

- `<if></if>`
- `<where></where>(trim,set)`
- `<choose></choose>（when, otherwise）`
- `<foreach></foreach>`
- `<bind/>`

关于 MyBatis 动态 SQL 的详细介绍，请看这篇文章：[Mybatis 系列全解（八）：Mybatis 的 9 大动态 SQL 标签你知道几个？](https://segmentfault.com/a/1190000039335704) 。

关于这些动态 SQL 的具体使用方法，请看这篇文章：[Mybatis【13】-- Mybatis 动态 sql 标签怎么使用？](https://cloud.tencent.com/developer/article/1943349)

### MyBatis 是如何将 sql 执行结果封装为目标对象并返回的？都有哪些映射形式？

注：我出的。

答：第一种是使用 **`<resultMap>`** 标签，逐一定义列名和对象属性名之间的映射关系。第二种是使用 **sql 列的别名**功能，将列别名书写为**对象属性名**，比如 T_NAME AS NAME，对象属性名一般是 name，小写，但是**列名不区分大小写**，MyBatis 会忽略列名大小写，智能找到**与之对应对象属性名**，你甚至可以写成 T_NAME AS NaMe，MyBatis 一样可以正常工作。

有了列名与属性名的映射关系后，MyBatis 通过反射创建对象，同时**使用反射** 给对象的属性逐一赋值并返回，那些找不到映射关系的属性，是无法完成赋值的。

### MyBatis 能执行一对一、一对多的关联查询吗？都有哪些实现方式，以及它们之间的区别。【实际没有用过】

注：我出的。

答：能，MyBatis 不仅可以执行**一对一**、**一对多**的关联查询，还可以执行**多对一**，**多对多**的关联查询，多对一查询，其实就是一对一查询，只需要把 `selectOne()` 修改为 `selectList()` 即可；多对多查询，其实就是一对多查询，只需要把 `selectOne()` 修改为 `selectList()` 即可。

关联对象查询，有两种实现方式，一种是单独发送一个 sql 去查询关联对象，赋给主对象，然后返回主对象。另一种是使用嵌套查询，嵌套查询的含义为使用 join 查询，一部分列是 A 对象的属性值，另外一部分列是关联对象 B 的属性值，好处是只发一个 sql 查询，就可以把主对象和其关联对象查出来。

那么问题来了，join 查询出来 100 条记录，如何确定主对象是 5 个，而不是 100 个？其去重复的原理是 `<resultMap>` 标签内的 `<id>` 子标签，指定了唯一确定一条记录的 id 列，MyBatis 根据 `<id>` 列值来完成 100 条记录的去重复功能， `<id>` 可以有多个，代表了联合主键的语意。

同样主对象的关联对象，也是根据这个原理去重复的，尽管一般情况下，只有主对象会有重复记录，关联对象一般不会重复。

举例：下面 join 查询出来 6 条记录，一、二列是 Teacher 对象列，第三列为 Student 对象列，MyBatis 去重复处理后，结果为 1 个老师 6 个学生，而不是 6 个老师 6 个学生。

| t_id | t_name  | s_id |
| ---- | ------- | ---- |
| 1    | teacher | 38   |
| 1    | teacher | 39   |
| 1    | teacher | 40   |
| 1    | teacher | 41   |
| 1    | teacher | 42   |
| 1    | teacher | 43   |

### MyBatis 是否支持延迟加载？如果支持，它的实现原理是什么？

注：我出的。

答：MyBatis **仅支持 association 关联对象**和 **collection 关联集合对象**的**延迟加载**，association 指的就是一对一，collection 指的就是一对多查询。在 MyBatis 配置文件中，可以配置是否启用延迟加载 `lazyLoadingEnabled=true|false。`

它的原理是，使用 `CGLIB` 创建目标对象的代理对象，当调用目标方法时，进入拦截器方法，比如调用 `a.getB().getName()` ，拦截器 `invoke()` 方法发现 `a.getB()` 是 null 值，那么就会单独发送事先保存好的查询关联 B 对象的 sql，把 B 查询上来，然后调用 a.setB(b)，于是 a 的对象 b 属性就有值了，接着完成 `a.getB().getName()` 方法的调用。这就是延迟加载的基本原理。

当然了，不光是 MyBatis，几乎所有的包括 Hibernate，支持延迟加载的原理都是一样的。

### MyBatis 的 xml 映射文件中，不同的 xml 映射文件，id 是否可以重复？

注：我出的。

答：**不同的 xml 映射文件，如果配置了 namespace，那么 id 可以重复；如果没有配置 namespace，那么 id 不能重复**；毕竟 namespace 不是必须的，只是最佳实践而已。

原因就是 namespace+id 是作为 `Map<String, MappedStatement>` 的 key 使用的，如果没有 namespace，就剩下 id，那么，id 重复会导致数据互相覆盖。有了 namespace，自然 id 就可以重复，**namespace 不同，namespace+id 自然也就不同**。

### MyBatis 中如何执行批处理？

注：我出的。

答：使用 **`BatchExecutor`** 完成批处理。

### MyBatis 都有哪些 Executor 执行器？它们之间的区别是什么？

注：我出的

答：MyBatis 有三种基本的 `Executor` 执行器：

- **`SimpleExecutor`：** **每执行**一次 **update** 或 **select**，就开启一个 Statement 对象，**用完立刻关闭** Statement 对象。
- **`ReuseExecutor`：** 执行 update 或 select，**以 sql 作为 key 查找 Statement 对象**，存在就使用，不存在就创建，用完后，不关闭 Statement 对象，而是**放置于 Map<String, Statement>内，供下一次使用**。简言之，就是重复使用 Statement 对象。
- **`BatchExecutor`** ：执行 update（没有 select，JDBC 批处理不支持 select），**将所有 sql 都添加到批处理中**（addBatch()），等待统一执行（executeBatch()），它缓存了多个 Statement 对象，每个 Statement 对象都是 addBatch()完毕后，等待逐一执行 executeBatch()批处理。与 JDBC 批处理相同。

作用范围：`Executor` 的这些特点，都严格限制在 SqlSession 生命周期范围内。

### MyBatis 中如何指定使用哪一种 Executor 执行器？

注：我出的

答：在 MyBatis 配置文件中，可以**指定默认的 `ExecutorType`** 执行器类型，也可以手动给 **`DefaultSqlSessionFactory` 的创建 SqlSession 的方法传递 `ExecutorType` 类型参**数。

### MyBatis 是否可以映射 Enum 枚举类？

注：我出的

答：MyBatis 可以映射枚举类，不单可以映射枚举类，MyBatis 可以**映射任何对象到表的一列**上。映射方式为自定义一个 `TypeHandler` ，实现 `TypeHandler` 的 `setParameter()` 和 `getResult()` 接口方法。 `TypeHandler` 有两个作用：

- 一是完成从 javaType 至 jdbcType 的转换；
- 二是完成 jdbcType 至 javaType 的转换，体现为 `setParameter()` 和 `getResult()` 两个方法，分别代表设置 sql 问号占位符参数和获取列查询结果。

### MyBatis 映射文件中，如果 A 标签通过 include 引用了 B 标签的内容，请问，B 标签能否定义在 A 标签的后面，还是说必须定义在 A 标签的前面？

注：我出的

答：虽然 MyBatis 解析 xml 映射文件是按照顺序解析的，但是，**被引用的 B 标签依然可以定义在任何地方**，MyBatis 都可以正确识别。

**原理是，MyBatis 解析 A 标签，发现 A 标签引用了 B 标签，但是 B 标签尚未解析到，尚不存在，此时，MyBatis 会将 A 标签标记为未解析状态，然后继续解析余下的标签，包含 B 标签，待所有标签解析完毕，MyBatis 会重新解析那些被标记为未解析的标签，此时再解析 A 标签时，B 标签已经存在，A 标签也就可以正常解析完成了。**

### 简述 MyBatis 的 xml 映射文件和 MyBatis 内部数据结构之间的映射关系？[不懂]

注：我出的

答：MyBatis 将所有 xml 配置信息都封装到 All-In-One 重量级对象 Configuration 内部。在 xml 映射文件中， `<parameterMap>` 标签会被解析为 `ParameterMap` 对象，其每个子元素会被解析为 ParameterMapping 对象。 `<resultMap>` 标签会被解析为 `ResultMap` 对象，其每个子元素会被解析为 `ResultMapping` 对象。每一个 `<select>、<insert>、<update>、<delete>` 标签均会被解析为 **`MappedStatement`** 对象，**标签内的 sql 会被解析为 BoundSql 对象**。

### 为什么说 MyBatis 是半自动 ORM 映射工具？它与全自动的区别在哪里？

注：我出的

答：Hibernate 属于全自动 ORM 映射工具，使用 **Hibernate 查询关联对象**或者**关联集合对象**时，可以**根据对象关系模型直接获**取，所以它是全自动的。而 MyBatis 在查询关联对象或关联集合对象时，需要**手动编写 sql 来完成**，所以，称之为**半自动 ORM 映射工具**。

面试题看似都很简单，但是想要能正确回答上来，必定是研究过源码且深入的人，而不是仅会使用的人或者用的很熟的人，以上所有面试题及其答案所涉及的内容，在我的 MyBatis 系列博客中都有详细讲解和原理分析。