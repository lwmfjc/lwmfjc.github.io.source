---
title: Flowable-05-spring-boot
description: 'spring-boot'
categories:
  - 学习
tags:
  - 'flowable官方'
date: 2022-04-29 15:31:15
updated: 2022-04-29 15:31:15
---

### 入门

需要两个依赖

```xml
<properties>

        <flowable.version>6.7.2</flowable.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.flowable</groupId>
            <artifactId>flowable-spring-boot-starter</artifactId>
            <version>${flowable.version}</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/com.h2database/h2 -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <version>2.1.212</version>
        </dependency>

    </dependencies>

```

结合Spring：

只需将依赖项添加到类路径并使用*@SpringBootApplication*注释，幕后就会发生很多事情：

- 自动创建内存数据源（因为 H2 驱动程序位于类路径中）并传递给 Flowable 流程引擎配置

- 已创建并公开了 Flowable ProcessEngine、CmmnEngine、DmnEngine、FormEngine、ContentEngine 和 IdmEngine bean

- 所有 Flowable 服务都暴露为 Spring bean

- Spring Job Executor 已创建

- 将自动部署*流程*文件夹中的任何 BPMN 2.0 流程定义。创建一个文件夹*processes*并将一个虚拟进程定义（名为*one-task-process.bpmn20.xml*）添加到此文件夹。该文件的内容如下所示。

  ```java
  <?xml version="1.0" encoding="UTF-8"?>
  <definitions
          xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
          xmlns:flowable="http://flowable.org/bpmn"
          targetNamespace="Examples">
  
      <process id="oneTaskProcess" name="The One Task Process">
          <startEvent id="theStart" />
          <sequenceFlow id="flow1" sourceRef="theStart" targetRef="theTask" />
          <userTask id="theTask" name="my task" flowable:assignee="kermit" />
          <sequenceFlow id="flow2" sourceRef="theTask" targetRef="theEnd" />
          <endEvent id="theEnd" />
      </process>
  
  </definitions>
  ```

  
  
- *案例*文件夹中的任何 CMMN 1.1 案例定义都将自动部署。

- 将自动部署*dmn*文件夹中的任何 DMN 1.1 dmn 定义。

- *表单*文件夹中的任何表单定义都将自动部署。

java代码 在项目服务启动的时候就去加载一些数据

```java

@SpringBootApplication(proxyBeanMethods = false)
public class MyApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }

    @Bean
    public CommandLineRunner init(final RepositoryService repositoryService,
                                  final RuntimeService runtimeService,
                                  final TaskService taskService) {

        //该bean在项目服务启动的时候就去加载一些数据
        return new CommandLineRunner() {
            @Override
            public void run(String... strings) throws Exception {
                //有几个流程定义
                System.out.println("Number of process definitions : "
                        + repositoryService.createProcessDefinitionQuery().count());
                //有多少个任务
                System.out.println("Number of tasks : " + taskService.createTaskQuery().count());
                runtimeService.startProcessInstanceByKey("oneTaskProcess");
                //开启流程后有多少个任务（+1）
                System.out.println("Number of tasks after process start: "
                        + taskService.createTaskQuery().count());
            }
        };
    }
}
```

### 更改数据库

- 添加依赖

  ```xml
  
          <dependency>
              <groupId>mysql</groupId>
              <artifactId>mysql-connector-java</artifactId>
              <version>8.0.29</version>
          </dependency>
  ```

- application.yml中添加配置

  ```yaml
  spring:
    datasource:
      url: jdbc:mysql://localhost:3306/flowable-spring-boot?useUnicode=true&characterEncoding=utf-8&allowMultiQueries=true&nullCatalogMeansCurrent=true
      username: root
      password: 123456
      driver-class-name: com.mysql.jdbc.Driver
  ```

### Rest支持

- web支持

  ```xml
      <parent>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-parent</artifactId>
          <version>2.6.7</version>
      </parent>
  ```

  - 添加依赖

    ```xml
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
            </dependency>
    ```

- 使用Service启动流程及获取给定受让人的任务

  ```java
  @Service
  public class MyService {
  
      @Autowired
      private RuntimeService runtimeService;
  
      @Autowired
      private TaskService taskService;
  
      @Transactional
      public void startProcess() {
          runtimeService.startProcessInstanceByKey("oneTaskProcess");
      }
  
      @Transactional
      public List<Task> getTasks(String assignee) {
          return taskService.createTaskQuery().taskAssignee(assignee).list();
      }
  
  }
  ```

- 创建REST端点

  ```java
  @RestController
  public class MyRestController {
  
      @Autowired
      private MyService myService;
  
      @PostMapping(value="/process")
      public void startProcessInstance() {
          myService.startProcess();
      }
  
      @RequestMapping(value="/tasks", method= RequestMethod.GET, produces=MediaType.APPLICATION_JSON_VALUE)
      public List<TaskRepresentation> getTasks(@RequestParam String assignee) {
          List<Task> tasks = myService.getTasks(assignee);
          List<TaskRepresentation> dtos = new ArrayList<TaskRepresentation>();
          for (Task task : tasks) {
              dtos.add(new TaskRepresentation(task.getId(), task.getName()));
          }
          return dtos;
      }
  
      static class TaskRepresentation {
  
          private String id;
          private String name;
  
          public TaskRepresentation(String id, String name) {
              this.id = id;
              this.name = name;
          }
  
          public String getId() {
              return id;
          }
          public void setId(String id) {
              this.id = id;
          }
          public String getName() {
              return name;
          }
          public void setName(String name) {
              this.name = name;
          }
  
      }
  
  }
  ```

- 使用下面语句进行测试

  ```shell
  curl http://localhost:8080/tasks?assignee=kermit
  []
  
  curl -X POST  http://localhost:8080/process
  
  curl http://localhost:8080/tasks?assignee=kermit
  [{"id":"10004","name":"my task"}]
  ```

  

#### JPA支持

- 添加依赖

  ```xml
  
          <dependency>
              <groupId>org.springframework.boot</groupId>
              <artifactId>spring-boot-starter-data-jpa</artifactId> 
          </dependency>
  ```

- 创建一个实体类

  ```java
  @Entity
  class Person {
  
      @Id
      @GeneratedValue
      private Long id;
  
      private String username;
  
      private String firstName;
  
      private String lastName;
  
      private Date birthDate;
  
      public Person() {
      }
  
      public Person(String username, String firstName, String lastName, Date birthDate) {
          this.username = username;
          this.firstName = firstName;
          this.lastName = lastName;
          this.birthDate = birthDate;
      }
  
      public Long getId() {
          return id;
      }
  
      public void setId(Long id) {
          this.id = id;
      }
  
      public String getUsername() {
          return username;
      }
  
      public void setUsername(String username) {
          this.username = username;
      }
  
      public String getFirstName() {
          return firstName;
      }
  
      public void setFirstName(String firstName) {
          this.firstName = firstName;
      }
  
      public String getLastName() {
          return lastName;
      }
  
      public void setLastName(String lastName) {
          this.lastName = lastName;
      }
  
      public Date getBirthDate() {
          return birthDate;
      }
  
      public void setBirthDate(Date birthDate) {
          this.birthDate = birthDate;
      }
  }
  ```

- 属性文件添加

  ```java
  spring.jpa.hibernate.ddl-auto=update
  ```

- 添加Repository类

  ```java
  @Repository
  public interface PersonRepository extends JpaRepository<Person, Long> {
  
      Person findByUsername(String username);
  }
  ```

- 代码

  - 添加事务

  - startProcess现在修改成：获取传入的受理人用户名，查找Person，并将PersonJPA对象作为流程变量放入流程实例中

  - 在CommandLineRunner中初始化时创建用户

    ```java
    @Service
    @Transactional
    public class MyService {
    
        @Autowired
        private RuntimeService runtimeService;
    
        @Autowired
        private TaskService taskService;
    
        @Autowired
        private PersonRepository personRepository;
    
        public void startProcess(String assignee) {
    
            Person person = personRepository.findByUsername(assignee);
    
            Map<String, Object> variables = new HashMap<String, Object>();
            variables.put("person", person);
            runtimeService.startProcessInstanceByKey("oneTaskProcess", variables);
        }
    
        public List<Task> getTasks(String assignee) {
            return taskService.createTaskQuery().taskAssignee(assignee).list();
        }
    
        public void createDemoUsers() {
            if (personRepository.findAll().size() == 0) {
                personRepository.save(new Person("jbarrez", "Joram", "Barrez", new Date()));
                personRepository.save(new Person("trademakers", "Tijs", "Rademakers", new Date()));
            }
        }
    
    }
    ```

  - CommandRunner修改

    ```java
    @Bean
    public CommandLineRunner init(final MyService myService) {
    
        return new CommandLineRunner() {
            public void run(String... strings) throws Exception {
                myService.createDemoUsers();
            }
        };
    }
    ```

  - RestController修改

    ```java
    @RestController
    public class MyRestController {
    
        @Autowired
        private MyService myService;
    
        @PostMapping(value="/process")
        public void startProcessInstance(@RequestBody StartProcessRepresentation startProcessRepresentation) {
            myService.startProcess(startProcessRepresentation.getAssignee());
        }
    
       ...
    
        static class StartProcessRepresentation {
    
            private String assignee;
    
            public String getAssignee() {
                return assignee;
            }
    
            public void setAssignee(String assignee) {
                this.assignee = assignee;
            }
        }
    ```

  - 修改流程定义

    ```xml
    <userTask id="theTask" name="my task" flowable:assignee="${person.id}"/>
    
    ```

  - 测试

    - 启动spring boot之后person表会有两条数据

    - 启动流程实例

      此时会把从数据库查找到的person传入流程图(变量)

      ```shell
      curl -H "Content-Type: application/json" -d '{"assignee" : "jbarrez"}' http://localhost:8080/process
      
      ```

    - 使用id获取任务列表

      ```shell
      curl http://localhost:8080/tasks?assignee=1
      
      [{"id":"12505","name":"my task"}]
      ```

      

### 可流动的执行器端点

