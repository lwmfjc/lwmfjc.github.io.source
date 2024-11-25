---
title: boge-02-flowable进阶_1
description: '02-flowable进阶_1'
categories:
  - 学习
tags:
  - flowable_波哥_b站
date: 2022-05-14 21:59:40
updated: 2022-05-14 21:59:40
---

## 表结构

-  尽量通过API动数据

  - ACT_RE：repository，包含流程定义和流程静态资源
  - ACT_RU: runtime，包含流程实例、任务、变量等，流程结束会删除
  - ACT_HI: history，包含历史数据，比如历史流程实例、变量、任务等
  - ACT_GE: general，通用数据
  - ACT_ID: identity，组织机构。包含标识的信息，如用户、用户组等等

- 具体的

  - 流程历史记录

    ![image-20220514220723828](images/mypost/image-20220514220723828.png)

  - 流程定义表
    ![image-20220514220740732](images/mypost/image-20220514220740732.png)

  - 运行实例表
    ![image-20220514220808753](images/mypost/image-20220514220808753.png)

  - 用户用户组表

    ![image-20220514220856033](images/mypost/image-20220514220856033.png)

- 源码中的体现
  ![image-20220514220933558](images/mypost/image-20220514220933558.png)

  

## 默认的配置文件加载

- 对于 

  ```java
  ProcessEngine defaultProcessEngine = ProcessEngines.getDefaultProcessEngine();
  //-->
  public static ProcessEngine getDefaultProcessEngine() {
          return getProcessEngine(NAME_DEFAULT); //NAME_DEFAULT = "default"
      }
  //-->
  public static ProcessEngine getProcessEngine(String processEngineName) {
          if (!isInitialized()) {
              init();
          }
          return processEngines.get(processEngineName);
      }
  //-->部分
  
      /**
       * Initializes all process engines that can be found on the classpath for resources <code>flowable.cfg.xml</code> (plain Flowable style configuration) and for resources
       * <code>flowable-context.xml</code> (Spring style configuration).
       */
      public static synchronized void init() {
          if (!isInitialized()) {
              if (processEngines == null) {
                  // Create new map to store process-engines if current map is null
                  processEngines = new HashMap<>();
              }
              ClassLoader classLoader = ReflectUtil.getClassLoader();
              Enumeration<URL> resources = null;
              try {
                  resources = classLoader.getResources("flowable.cfg.xml");
              } catch (IOException e) {
                  throw new FlowableIllegalArgumentException("problem retrieving flowable.cfg.xml resources on the classpath: " + System.getProperty("java.class.path"), e);
              }
            //后面还有，每帖出来
          }
      }
  
  ```

- 注意这行```classLoader.getResources("flowable.cfg.xml");```
  需要在resources根目录下放这么一个文件

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
      <bean id="processEngineConfiguration" class="org.flowable.engine.impl.cfg.StandaloneProcessEngineConfiguration">
          <property name="jdbcUrl"
                    value="jdbc:mysql://localhost:3306/flow1?useUnicode=true&amp;characterEncoding=utf-8&amp;allowMultiQueries=true&amp;nullCatalogMeansCurrent=true"/>
          <property name="jdbcDriver" value="com.mysql.cj.jdbc.Driver"/>
          <property name="jdbcUsername" value="root"/>
          <property name="jdbcPassword" value="123456"/>
          <property name="databaseSchemaUpdate" value="true"/>
          <!--异步执行器-->
          <property name="asyncExecutorActivate" value="false"/>
      </bean>
  </beans>
  ```

- 新建数据库flow1，运行测试代码

  ```java
  
      @Test
      public void processEngine2(){
          ProcessEngine defaultProcessEngine = ProcessEngines.getDefaultProcessEngine();
          System.out.println(defaultProcessEngine);
      }
  ```

  此时数据库已经有表

  

## 加载自定义名称的配置文件

- 把刚才的数据库清空，将flowable的配置文件放到目录custom/lycfg.xml中
  ![image-20220514225700704](images/mypost/image-20220514225700704.png)

- 代码

  ```java
  @Test
      public void processEngine03(){
          ProcessEngineConfiguration configuration = ProcessEngineConfiguration.createProcessEngineConfigurationFromResource("custom/lycfg.xml");
          System.out.println(configuration);
          ProcessEngine processEngine = configuration.buildProcessEngine();
          System.out.println(processEngine);
      }
  ```

  

## ProcessEngine源码查看

- 源码追溯

  ```java
  configuration.buildProcessEngine()
  //--->ProcessEngineConfigurationImpl.class
  @Override
  public ProcessEngine buildProcessEngine() {
          init();
          ProcessEngineImpl processEngine = new ProcessEngineImpl(this);
    //...
  }
  //---->ProcessEngineImpl.class
  public class ProcessEngineImpl implements ProcessEngine {
  
      private static final Logger LOGGER = LoggerFactory.getLogger(ProcessEngineImpl.class);
  
      protected String name;
      protected RepositoryService repositoryService;
      protected RuntimeService runtimeService;
      protected HistoryService historicDataService;
      protected IdentityService identityService;
      protected TaskService taskService;
      protected FormService formService;
      protected ManagementService managementService;
      protected DynamicBpmnService dynamicBpmnService;
      protected ProcessMigrationService processInstanceMigrationService;
      protected AsyncExecutor asyncExecutor;
      protected AsyncExecutor asyncHistoryExecutor;
      protected CommandExecutor commandExecutor;
      protected Map<Class<?>, SessionFactory> sessionFactories;
      protected TransactionContextFactory transactionContextFactory;
      protected ProcessEngineConfigurationImpl processEngineConfiguration;
      //这里通过ProcessEngineConfigurationImpl获取各种对象
      public ProcessEngineImpl(ProcessEngineConfigurationImpl processEngineConfiguration) {
          this.processEngineConfiguration = processEngineConfiguration;
          this.name = processEngineConfiguration.getEngineName();
          this.repositoryService = processEngineConfiguration.getRepositoryService();
          this.runtimeService = processEngineConfiguration.getRuntimeService();
          this.historicDataService = processEngineConfiguration.getHistoryService();
          this.identityService = processEngineConfiguration.getIdentityService();
          this.taskService = processEngineConfiguration.getTaskService();
          this.formService = processEngineConfiguration.getFormService();
          this.managementService = processEngineConfiguration.getManagementService();
          this.dynamicBpmnService = processEngineConfiguration.getDynamicBpmnService();
          this.processInstanceMigrationService = processEngineConfiguration.getProcessMigrationService();
          this.asyncExecutor = processEngineConfiguration.getAsyncExecutor();
          this.asyncHistoryExecutor = processEngineConfiguration.getAsyncHistoryExecutor();
          this.commandExecutor = processEngineConfiguration.getCommandExecutor();
          this.sessionFactories = processEngineConfiguration.getSessionFactories();
          this.transactionContextFactory = processEngineConfiguration.getTransactionContextFactory();
      }
      //...
  }
  //---->ProcessEngine.class 获取各个service服务
  public interface ProcessEngine extends Engine {
  
      /** the version of the flowable library */
      String VERSION = FlowableVersions.CURRENT_VERSION;
  
      /**
       * Starts the execuctors (async and async history), if they are configured to be auto-activated.
       */
      void startExecutors();
  
      RepositoryService getRepositoryService();
  
      RuntimeService getRuntimeService();
  
      FormService getFormService();
  
      TaskService getTaskService();
  
      HistoryService getHistoryService();
  
      IdentityService getIdentityService();
  
      ManagementService getManagementService();
  
      DynamicBpmnService getDynamicBpmnService();
  
      ProcessMigrationService getProcessMigrationService();
  
      ProcessEngineConfiguration getProcessEngineConfiguration();
  }
  
  
  
  ```

  

## ProcessEngineConfiguration中的init方法

- 源码追溯

  ```java
  configuration.buildProcessEngine()
  //--->ProcessEngineConfigurationImpl.class
  @Override
  public ProcessEngine buildProcessEngine() {
          init();
          ProcessEngineImpl processEngine = new ProcessEngineImpl(this);
    //...
  }
  //--->ProcessEngineConfigurationImpl.init();
  
   public void init() {
          initEngineConfigurations();
          initConfigurators();
          configuratorsBeforeInit();
          initClock();
          initObjectMapper();
          initProcessDiagramGenerator();
          initCommandContextFactory();
          initTransactionContextFactory();
          initCommandExecutors();
          initIdGenerator();
          initHistoryLevel();
          initFunctionDelegates();
          initAstFunctionCreators();
          initDelegateInterceptor();
          initBeans();
          initExpressionManager();
          initAgendaFactory();
          //关系型数据库
          if (usingRelationalDatabase) {
              initDataSource();//下面拿这个举例1
          } else {
              initNonRelationalDataSource();
          }
  
          if (usingRelationalDatabase || usingSchemaMgmt) {
              initSchemaManager();
              initSchemaManagementCommand();
          }
          
          configureVariableServiceConfiguration();
          configureJobServiceConfiguration();
  
          initHelpers();
          initVariableTypes();
          initFormEngines();
          initFormTypes();
          initScriptingEngines();
          initBusinessCalendarManager();
          initServices();
          initWsdlImporterFactory();
          initBehaviorFactory();
          initListenerFactory();
          initBpmnParser();
          initProcessDefinitionCache();
          initProcessDefinitionInfoCache();
          initAppResourceCache();
          initKnowledgeBaseCache();
          initJobHandlers();
          initHistoryJobHandlers();
  
          initTransactionFactory();
  
          if (usingRelationalDatabase) {
              initSqlSessionFactory();//下面拿这个举例2
          }
  
          initSessionFactories();
          //相关表结构操作
          initDataManagers(); //下面拿这个举例2
          initEntityManagers();
          initCandidateManager();
          initVariableAggregator();
          initHistoryManager();
          initChangeTenantIdManager();
          initDynamicStateManager();
          initProcessInstanceMigrationValidationManager();
          initIdentityLinkInterceptor();
          initJpa();
          initDeployers();
          initEventHandlers();
          initFailedJobCommandFactory();
          initEventDispatcher();
          initProcessValidator();
          initFormFieldHandler();
          initDatabaseEventLogging();
          initFlowable5CompatibilityHandler();
          initVariableServiceConfiguration(); //流程变量
          initIdentityLinkServiceConfiguration();
          initEntityLinkServiceConfiguration();
          initEventSubscriptionServiceConfiguration();
          initTaskServiceConfiguration();
          initJobServiceConfiguration();
          initBatchServiceConfiguration();
          initAsyncExecutor();
          initAsyncHistoryExecutor();
  
          configuratorsAfterInit();
          afterInitTaskServiceConfiguration();
          afterInitEventRegistryEventBusConsumer();
          
          initHistoryCleaningManager();
          initLocalizationManagers();
     }
  //--->AbstractEngineConfiguration 
  //---->AbstractEngineConfiguration.initDataSrouce()
  public static Properties getDefaultDatabaseTypeMappings() {
          Properties databaseTypeMappings = new Properties();
          databaseTypeMappings.setProperty("H2", DATABASE_TYPE_H2);
          databaseTypeMappings.setProperty("HSQL Database Engine", DATABASE_TYPE_HSQL);
          databaseTypeMappings.setProperty("MySQL", DATABASE_TYPE_MYSQL);
          databaseTypeMappings.setProperty("MariaDB", DATABASE_TYPE_MYSQL);
          databaseTypeMappings.setProperty("Oracle", DATABASE_TYPE_ORACLE);
          databaseTypeMappings.setProperty(PRODUCT_NAME_POSTGRES, DATABASE_TYPE_POSTGRES);
          databaseTypeMappings.setProperty("Microsoft SQL Server", DATABASE_TYPE_MSSQL);
          databaseTypeMappings.setProperty(DATABASE_TYPE_DB2, DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/NT", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/NT64", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2 UDP", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/LINUX", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/LINUX390", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/LINUXX8664", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/LINUXZ64", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/LINUXPPC64", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/LINUXPPC64LE", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/400 SQL", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/6000", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2 UDB iSeries", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/AIX64", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/HPUX", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/HP64", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/SUN", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/SUN64", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/PTX", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2/2", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty("DB2 UDB AS400", DATABASE_TYPE_DB2);
          databaseTypeMappings.setProperty(PRODUCT_NAME_CRDB, DATABASE_TYPE_COCKROACHDB);
          return databaseTypeMappings;
      }
  //initDataSource();
  protected void initDataSource() {
          if (dataSource == null) {
              if (dataSourceJndiName != null) {
                  try {
                      dataSource = (DataSource) new InitialContext().lookup(dataSourceJndiName);
                  } catch (Exception e) {
                      throw new FlowableException("couldn't lookup datasource from " + dataSourceJndiName + ": " + e.getMessage(), e);
                  }
  
              } else if (jdbcUrl != null) {
                  if ((jdbcDriver == null) || (jdbcUsername == null)) {
                      throw new FlowableException("DataSource or JDBC properties have to be specified in a process engine configuration");
                  }
  
                  logger.debug("initializing datasource to db: {}", jdbcUrl);
  
                  if (logger.isInfoEnabled()) {
                      logger.info("Configuring Datasource with following properties (omitted password for security)");
                      logger.info("datasource driver : {}", jdbcDriver);
                      logger.info("datasource url : {}", jdbcUrl);
                      logger.info("datasource user name : {}", jdbcUsername);
                  }
  
                  PooledDataSource pooledDataSource = new PooledDataSource(this.getClass().getClassLoader(), jdbcDriver, jdbcUrl, jdbcUsername, jdbcPassword);
  
                  if (jdbcMaxActiveConnections > 0) {
                      pooledDataSource.setPoolMaximumActiveConnections(jdbcMaxActiveConnections);
                  }
                  if (jdbcMaxIdleConnections > 0) {
                      pooledDataSource.setPoolMaximumIdleConnections(jdbcMaxIdleConnections);
                  }
                  if (jdbcMaxCheckoutTime > 0) {
                      pooledDataSource.setPoolMaximumCheckoutTime(jdbcMaxCheckoutTime);
                  }
                  if (jdbcMaxWaitTime > 0) {
                      pooledDataSource.setPoolTimeToWait(jdbcMaxWaitTime);
                  }
                  if (jdbcPingEnabled) {
                      pooledDataSource.setPoolPingEnabled(true);
                      if (jdbcPingQuery != null) {
                          pooledDataSource.setPoolPingQuery(jdbcPingQuery);
                      }
                      pooledDataSource.setPoolPingConnectionsNotUsedFor(jdbcPingConnectionNotUsedFor);
                  }
                  if (jdbcDefaultTransactionIsolationLevel > 0) {
                      pooledDataSource.setDefaultTransactionIsolationLevel(jdbcDefaultTransactionIsolationLevel);
                  }
                  dataSource = pooledDataSource;
              }
          }
  
          if (databaseType == null) {
              initDatabaseType();
          }
      }
  //initSqlSessionFactory();
  public void initSqlSessionFactory() {
          if (sqlSessionFactory == null) {
              InputStream inputStream = null;
              try {
                  //获取MyBatis配置文件信息
                  inputStream = getMyBatisXmlConfigurationStream();
  
                  Environment environment = new Environment("default", transactionFactory, dataSource);
                  Reader reader = new InputStreamReader(inputStream);
                  Properties properties = new Properties();
                  properties.put("prefix", databaseTablePrefix);
  
                  String wildcardEscapeClause = "";
                  if ((databaseWildcardEscapeCharacter != null) && (databaseWildcardEscapeCharacter.length() != 0)) {
                      wildcardEscapeClause = " escape '" + databaseWildcardEscapeCharacter + "'";
                  }
                  properties.put("wildcardEscapeClause", wildcardEscapeClause);
  
                  // set default properties
                  properties.put("limitBefore", "");
                  properties.put("limitAfter", "");
                  properties.put("limitBetween", "");
                  properties.put("limitBeforeNativeQuery", "");
                  properties.put("limitAfterNativeQuery", "");
                  properties.put("blobType", "BLOB");
                  properties.put("boolValue", "TRUE");
  
                  if (databaseType != null) {
                      properties.load(getResourceAsStream(pathToEngineDbProperties()));
                  }
                
                  //Mybatis相关的配置
                  Configuration configuration = initMybatisConfiguration(environment, reader, properties);
                  sqlSessionFactory = new DefaultSqlSessionFactory(configuration);
  
              } catch (Exception e) {
                  throw new FlowableException("Error while building ibatis SqlSessionFactory: " + e.getMessage(), e);
              } finally {
                  IoUtil.closeSilently(inputStream);
              }
          }
      }
    //ProcessEngineConfigurationImpl.getMyBatisXmlConfigurationStream();
    @Override
      public InputStream getMyBatisXmlConfigurationStream() {
          return getResourceAsStream(mybatisMappingFile);
      }
    //代码往上翻
    //构造器中
  
      public ProcessEngineConfigurationImpl() {
          mybatisMappingFile = DEFAULT_MYBATIS_MAPPING_FILE;
      }
    //其中
  
      public static final String DEFAULT_MYBATIS_MAPPING_FILE = "org/flowable/db/mapping/mappings.xml";
  
  ```

- 查找映射文件
  mappings.xml

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  
  <!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
  
  <configuration>
  
      <settings>
          <setting name="lazyLoadingEnabled" value="false" />
      </settings>
      <typeAliases>
          <typeAlias type="org.flowable.common.engine.impl.persistence.entity.ByteArrayRefTypeHandler" alias="ByteArrayRefTypeHandler" />
          <typeAlias type="org.flowable.common.engine.impl.persistence.entity.ByteArrayRefTypeHandler" alias="VariableByteArrayRefTypeHandler" />
          <typeAlias type="org.flowable.common.engine.impl.persistence.entity.ByteArrayRefTypeHandler" alias="JobByteArrayRefTypeHandler" />
          <typeAlias type="org.flowable.common.engine.impl.persistence.entity.ByteArrayRefTypeHandler" alias="BatchByteArrayRefTypeHandler" />
      </typeAliases>
      <typeHandlers>
          <typeHandler handler="ByteArrayRefTypeHandler" javaType="org.flowable.common.engine.impl.persistence.entity.ByteArrayRef" jdbcType="VARCHAR" />
          <typeHandler handler="VariableByteArrayRefTypeHandler" javaType="org.flowable.common.engine.impl.persistence.entity.ByteArrayRef" jdbcType="VARCHAR" />
          <typeHandler handler="JobByteArrayRefTypeHandler" javaType="org.flowable.common.engine.impl.persistence.entity.ByteArrayRef" jdbcType="VARCHAR" />
          <typeHandler handler="BatchByteArrayRefTypeHandler" javaType="org.flowable.common.engine.impl.persistence.entity.ByteArrayRef" jdbcType="VARCHAR" />
      </typeHandlers>
  
      <mappers>
          <mapper resource="org/flowable/db/mapping/ChangeTenantBpmn.xml" />
  
          <mapper resource="org/flowable/db/mapping/entity/Attachment.xml" />
          <mapper resource="org/flowable/db/mapping/entity/Comment.xml" />
          <mapper resource="org/flowable/job/service/db/mapping/entity/DeadLetterJob.xml" />
          <mapper resource="org/flowable/db/mapping/entity/Deployment.xml" />
          <mapper resource="org/flowable/db/mapping/entity/Execution.xml" />
          <mapper resource="org/flowable/db/mapping/entity/ActivityInstance.xml" />
          <mapper resource="org/flowable/db/mapping/entity/HistoricActivityInstance.xml" />
          <mapper resource="org/flowable/db/mapping/entity/HistoricDetail.xml" />
          <mapper resource="org/flowable/db/mapping/entity/HistoricProcessInstance.xml" />
          <mapper resource="org/flowable/variable/service/db/mapping/entity/HistoricVariableInstance.xml" />
          <mapper resource="org/flowable/task/service/db/mapping/entity/HistoricTaskInstance.xml" />
          <mapper resource="org/flowable/task/service/db/mapping/entity/HistoricTaskLogEntry.xml" />
          <mapper resource="org/flowable/identitylink/service/db/mapping/entity/HistoricIdentityLink.xml" />
          <mapper resource="org/flowable/entitylink/service/db/mapping/entity/HistoricEntityLink.xml" />
          <mapper resource="org/flowable/job/service/db/mapping/entity/HistoryJob.xml" />
          <mapper resource="org/flowable/identitylink/service/db/mapping/entity/IdentityLink.xml" />
          <mapper resource="org/flowable/entitylink/service/db/mapping/entity/EntityLink.xml" />
          <mapper resource="org/flowable/job/service/db/mapping/entity/Job.xml" />
          <mapper resource="org/flowable/db/mapping/entity/Model.xml" />
          <mapper resource="org/flowable/db/mapping/entity/ProcessDefinition.xml" />
          <mapper resource="org/flowable/db/mapping/entity/ProcessDefinitionInfo.xml" />
          <mapper resource="org/flowable/common/db/mapping/entity/Property.xml" />
          <mapper resource="org/flowable/common/db/mapping/entity/ByteArray.xml" />
          <mapper resource="org/flowable/common/db/mapping/common.xml" />
          <mapper resource="org/flowable/db/mapping/entity/Resource.xml" />
          <mapper resource="org/flowable/job/service/db/mapping/entity/SuspendedJob.xml" />
          <mapper resource="org/flowable/job/service/db/mapping/entity/ExternalWorkerJob.xml" />
          <mapper resource="org/flowable/common/db/mapping/entity/TableData.xml" />
          <mapper resource="org/flowable/task/service/db/mapping/entity/Task.xml" />
          <mapper resource="org/flowable/job/service/db/mapping/entity/TimerJob.xml" />
          <mapper resource="org/flowable/variable/service/db/mapping/entity/VariableInstance.xml" />
          <mapper resource="org/flowable/eventsubscription/service/db/mapping/entity/EventSubscription.xml" />
          <mapper resource="org/flowable/db/mapping/entity/EventLogEntry.xml" />
          <mapper resource="org/flowable/batch/service/db/mapping/entity/Batch.xml" />
          <mapper resource="org/flowable/batch/service/db/mapping/entity/BatchPart.xml" />
      </mappers>
  
  </configuration>
  ```

- 源码

  ```java
  //ProcessEnginConfigurationImpl.init()中的代码
  initDataManagers(); //下面拿这个举例3
  //->>>
  
      @Override
      @SuppressWarnings("rawtypes")
      public void initDataManagers() {
          super.initDataManagers();
          if (attachmentDataManager == null) {
              attachmentDataManager = new MybatisAttachmentDataManager(this);
          }
          if (commentDataManager == null) {
              commentDataManager = new MybatisCommentDataManager(this);
          }
          if (deploymentDataManager == null) {
              //下面拿这个查看
              deploymentDataManager = new MybatisDeploymentDataManager(this);
          }
          if (eventLogEntryDataManager == null) {
              eventLogEntryDataManager = new MybatisEventLogEntryDataManager(this);
          }
          if (executionDataManager == null) {
              executionDataManager = new MybatisExecutionDataManager(this);
          }
          if (dbSqlSessionFactory != null && executionDataManager instanceof AbstractDataManager) {
              dbSqlSessionFactory.addLogicalEntityClassMapping("execution", ((AbstractDataManager) executionDataManager).getManagedEntityClass());
          }
          if (historicActivityInstanceDataManager == null) {
              historicActivityInstanceDataManager = new MybatisHistoricActivityInstanceDataManager(this);
          }
          if (activityInstanceDataManager == null) {
              activityInstanceDataManager = new MybatisActivityInstanceDataManager(this);
          }
          if (historicDetailDataManager == null) {
              historicDetailDataManager = new MybatisHistoricDetailDataManager(this);
          }
          if (historicProcessInstanceDataManager == null) {
              historicProcessInstanceDataManager = new MybatisHistoricProcessInstanceDataManager(this);
          }
          if (modelDataManager == null) {
              modelDataManager = new MybatisModelDataManager(this);
          }
          if (processDefinitionDataManager == null) {
              processDefinitionDataManager = new MybatisProcessDefinitionDataManager(this);
          }
          if (processDefinitionInfoDataManager == null) {
              processDefinitionInfoDataManager = new MybatisProcessDefinitionInfoDataManager(this);
          }
          if (resourceDataManager == null) {
              resourceDataManager = new MybatisResourceDataManager(this);
          }
      }
  //-->MybatisDeploymentDataManager，这个类相当于mybatis中的mapper
  
  /**
   * @author Joram Barrez
   */
  public class MybatisDeploymentDataManager extends AbstractProcessDataManager<DeploymentEntity> implements DeploymentDataManager {
  
      public MybatisDeploymentDataManager(ProcessEngineConfigurationImpl processEngineConfiguration) {
          super(processEngineConfiguration);
      }
  
      @Override
      public Class<? extends DeploymentEntity> getManagedEntityClass() {
          return DeploymentEntityImpl.class;
      }
  
      @Override
      public DeploymentEntity create() {
          return new DeploymentEntityImpl();
      }
  
      @Override
      public long findDeploymentCountByQueryCriteria(DeploymentQueryImpl deploymentQuery) {
          return (Long) getDbSqlSession().selectOne("selectDeploymentCountByQueryCriteria", deploymentQuery);
      }
  
      @Override
      @SuppressWarnings("unchecked")
      public List<Deployment> findDeploymentsByQueryCriteria(DeploymentQueryImpl deploymentQuery) {
          final String query = "selectDeploymentsByQueryCriteria";
          return getDbSqlSession().selectList(query, deploymentQuery);
      }
  
      @Override
      public List<String> getDeploymentResourceNames(String deploymentId) {
          return getDbSqlSession().getSqlSession().selectList("selectResourceNamesByDeploymentId", deploymentId);
      }
  
      @Override
      @SuppressWarnings("unchecked")
      public List<Deployment> findDeploymentsByNativeQuery(Map<String, Object> parameterMap) {
          return getDbSqlSession().selectListWithRawParameter("selectDeploymentByNativeQuery", parameterMap);
      }
  
      @Override
      public long findDeploymentCountByNativeQuery(Map<String, Object> parameterMap) {
          return (Long) getDbSqlSession().selectOne("selectDeploymentCountByNativeQuery", parameterMap);
      }
  
  }
  ```

  

## ProcessEngine各种方法对比

- ProcessEngines.getDefaultProcessEngine();的方式

  ```
  
  ```

  ```java
  /**
   * Initializes all process engines that can be found on the classpath for resources <code>flowable.cfg.xml</code> (plain Flowable style configuration) and for resources
   * <code>flowable-context.xml</code> (Spring style configuration).
   */
  public static synchronized void init() {
      if (!isInitialized()) {
          if (processEngines == null) {
              // Create new map to store process-engines if current map is null
              processEngines = new HashMap<>();
          }
          ClassLoader classLoader = ReflectUtil.getClassLoader();
          Enumeration<URL> resources = null;
          try {
              resources = classLoader.getResources("flowable.cfg.xml");
          } catch (IOException e) {
              throw new FlowableIllegalArgumentException("problem retrieving flowable.cfg.xml resources on the classpath: " + System.getProperty("java.class.path"), e);
          }
  
          // Remove duplicated configuration URL's using set. Some
          // classloaders may return identical URL's twice, causing duplicate
          // startups
          Set<URL> configUrls = new HashSet<>();
          while (resources.hasMoreElements()) {
              configUrls.add(resources.nextElement());
          }
          for (URL resource : configUrls) {
              LOGGER.info("Initializing process engine using configuration '{}'", resource);
              initProcessEngineFromResource(resource); //注意这个
          }
  
          try {
              resources = classLoader.getResources("flowable-context.xml");
          } catch (IOException e) {
              throw new FlowableIllegalArgumentException("problem retrieving flowable-context.xml resources on the classpath: " + System.getProperty("java.class.path"), e);
          }
          while (resources.hasMoreElements()) {
              URL resource = resources.nextElement();
              LOGGER.info("Initializing process engine using Spring configuration '{}'", resource);
              initProcessEngineFromSpringResource(resource);
          }
  
          setInitialized(true);
      } else {
          LOGGER.info("Process engines already initialized");
      }
  }
  ```

  可以通过Spring配置文件的方式

  ```java
  initProcessEngineFromResource(resource); //注意这个
  
  private static EngineInfo initProcessEngineFromResource(URL resourceUrl) {
          EngineInfo processEngineInfo = processEngineInfosByResourceUrl.get(resourceUrl.toString());
          // if there is an existing process engine info
          if (processEngineInfo != null) {
              // remove that process engine from the member fields
              processEngineInfos.remove(processEngineInfo);
              if (processEngineInfo.getException() == null) {
                  String processEngineName = processEngineInfo.getName();
                  processEngines.remove(processEngineName);
                  processEngineInfosByName.remove(processEngineName);
              }
              processEngineInfosByResourceUrl.remove(processEngineInfo.getResourceUrl());
          }
  
          String resourceUrlString = resourceUrl.toString();
          try {
              LOGGER.info("initializing process engine for resource {}", resourceUrl);
              //注意这个
              ProcessEngine processEngine = buildProcessEngine(resourceUrl);
              String processEngineName = processEngine.getName();
              LOGGER.info("initialised process engine {}", processEngineName);
              processEngineInfo = new EngineInfo(processEngineName, resourceUrlString, null);
              processEngines.put(processEngineName, processEngine);
              processEngineInfosByName.put(processEngineName, processEngineInfo);
          } catch (Throwable e) {
              LOGGER.error("Exception while initializing process engine: {}", e.getMessage(), e);
              processEngineInfo = new EngineInfo(null, resourceUrlString, ExceptionUtils.getStackTrace(e));
          }
          processEngineInfosByResourceUrl.put(resourceUrlString, processEngineInfo);
          processEngineInfos.add(processEngineInfo);
          return processEngineInfo;
      }
  ```

- 源码

  ```java
  buildProcessEngine(resourceUrl);
  //
  private static ProcessEngine buildProcessEngine(URL resource) {
          InputStream inputStream = null;
          try {
              inputStream = resource.openStream();
              ProcessEngineConfiguration processEngineConfiguration = ProcessEngineConfiguration.createProcessEngineConfigurationFromInputStream(inputStream);
              return processEngineConfiguration.buildProcessEngine();
  
          } catch (IOException e) {
              throw new FlowableIllegalArgumentException("couldn't open resource stream: " + e.getMessage(), e);
          } finally {
              IoUtil.closeSilently(inputStream);
          }
   }
  ```

  
