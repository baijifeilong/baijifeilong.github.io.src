---
title: MyBatis多数据源的配置
categories:
  - Programming
tags:
  - Programming
date: 2018-12-07 11:49:43
---

# MyBatis多数据源的配置

MyBatis多数据源的配置主要有两种方式:

1. 通过@MapperScan注解，对不同包下的Mapper使用不同的sqlSessionFactory
2. 通过@MapperScan注解加自定义注解，对使用不同注解的Mapper使用不同的sqlSessionFactory

第二种配置相对灵活，示例如下:

<!--more-->

```java
package bj;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import com.zaxxer.hikari.HikariDataSource;
import io.shardingsphere.shardingjdbc.spring.boot.SpringBootConfiguration;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.annotation.Resource;
import javax.sql.DataSource;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.List;
import java.util.Map;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/6 下午9:29
 * <p>
 * MyBatis多数据源演示
 */
@SpringBootApplication(exclude = {SpringBootConfiguration.class})
@Configuration
@MapperScan(annotationClass = Mapper.class, basePackageClasses = MyBatisApp.class,
        sqlSessionFactoryRef = "sqlSessionFactory")
public class MyBatisApp implements ApplicationListener<ApplicationReadyEvent> {

    /**
     * SecondaryMapper配置
     * \@MapperScan 注解一次只能添加一个，所以需要单独再加一个配置类
     * 自定义@MapperScan会替换MyBatis自动添加的默认@MapperScan。所以主@MapperScan也必须显式添加
     */
    @Configuration
    @MapperScan(annotationClass = SecondaryMapper.class, basePackageClasses = MyBatisApp.class,
            sqlSessionFactoryRef = "sqlSessionFactorySecond")
    static class SecondaryMapperConfiguration {
    }

    public static void main(String[] args) {
        new SpringApplication(MyBatisApp.class) {{
            setWebApplicationType(WebApplicationType.NONE);
        }}.run(args);
    }

    @Resource
    private DataSource dataSource;

    @Resource
    private DataSource dataSourceSecond;

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Resource
    private UserMapper userMapper;

    @Resource
    private SecondaryUserMapper secondaryUserMapper;

    private void initLogger() {
        ((Logger) LoggerFactory.getLogger(MyBatisApp.class)).setLevel(Level.DEBUG);
        ((Logger) LoggerFactory.getLogger(JdbcTemplate.class)).setLevel(Level.DEBUG);
    }

    private void initDatabase() {
        String oldDatabase = jdbcTemplate.queryForObject("SELECT DATABASE()", String.class);
        jdbcTemplate.execute("DROP SCHEMA IF EXISTS one");
        jdbcTemplate.execute("CREATE SCHEMA one");
        jdbcTemplate.execute("USE one");
        jdbcTemplate.execute("CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32) CHARSET 'utf8')");
        jdbcTemplate.execute("INSERT INTO user(name) VALUES ('人民的儿子')");
        jdbcTemplate.execute("INSERT INTO user(name) VALUES ('人民的孙子')");
        jdbcTemplate.execute("INSERT INTO user(name) VALUES ('人民的曾孙子')");
        jdbcTemplate.execute("DROP SCHEMA IF EXISTS two");
        jdbcTemplate.execute("CREATE SCHEMA two");
        jdbcTemplate.execute("USE two");
        jdbcTemplate.execute("CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32) CHARSET 'utf8')");
        jdbcTemplate.execute("INSERT INTO user(name) VALUES ('人民的爹')");
        jdbcTemplate.execute("INSERT INTO user(name) VALUES ('人民的爷')");
        jdbcTemplate.execute("INSERT INTO user(name) VALUES ('人民的太爷')");
        jdbcTemplate.execute("INSERT INTO user(name) VALUES ('人民的老太爷')");
        jdbcTemplate.execute("USE " + oldDatabase);
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent applicationReadyEvent) {
        initLogger();
        initDatabase();
        System.out.println("Users:");
        userMapper.selectAll().forEach(System.out::println);
        System.out.println("Secondary users:");
        secondaryUserMapper.selectAll().forEach(System.out::println);
    }

    /**
     * 主数据源
     * <p>
     * 如果不添加@Primary注解, MyBatis可以工作，但是JdbcTemplate无法注入
     *
     * @return .
     */
    @Primary
    @Bean
    public DataSource dataSource() {
        return new HikariDataSource() {{
            setJdbcUrl("jdbc:mysql://localhost/one?useUnicode=true&characterEncoding=utf8");
            setUsername("root");
            setPassword("root");
        }};
    }

    /**
     * 副数据源
     *
     * @return .
     */
    @Bean
    public DataSource dataSourceSecond() {
        return new HikariDataSource() {{
            setJdbcUrl("jdbc:mysql://localhost/two?useUnicode=true&characterEncoding=utf8");
            setUsername("root");
            setPassword("root");
        }};
    }

    /**
     * 主SqlSessionFactory。使用主数据源。自定义SqlSessionFactory后，MyBatis就不自动添加SqlSessionFactory了，所以必须有
     *
     * @return .
     * @throws Exception .
     */
    @Bean
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        return new SqlSessionFactoryBean() {{
            setDataSource(dataSource);
        }}.getObject();
    }

    /**
     * 副SqlSessionFactory。使用副数据源
     *
     * @return .
     * @throws Exception .
     */
    @Bean
    public SqlSessionFactory sqlSessionFactorySecond() throws Exception {
        return new SqlSessionFactoryBean() {{
            setDataSource(dataSourceSecond);
        }}.getObject();
    }

    @Mapper
    interface UserMapper {
        @Select("SELECT * FROM user")
        List<Map<String, Object>> selectAll();
    }

    @SecondaryMapper
    interface SecondaryUserMapper {
        @Select("SELECT * FROM user")
        List<Map<String, Object>> selectAll();
    }

    /**
     * 自定义Mapper注解，用于标识使用的数据源
     */
    @Target(ElementType.TYPE)
    @Retention(RetentionPolicy.RUNTIME)
    @interface SecondaryMapper {
    }
}
```

控制台输出:

```log
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-07 11:49:02.596  INFO 5154 --- [           main] bj.MyBatisApp                            : Starting MyBatisApp on MacBook-Air-2.local with PID 5154 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-07 11:49:02.633  INFO 5154 --- [           main] bj.MyBatisApp                            : No active profile set, falling back to default profiles: default
2018-12-07 11:49:05.341  INFO 5154 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2018-12-07 11:49:05.499  INFO 5154 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2018-12-07 11:49:05.547  INFO 5154 --- [           main] org.quartz.impl.StdSchedulerFactory      : Using default implementation for ThreadExecutor
2018-12-07 11:49:05.569  INFO 5154 --- [           main] org.quartz.core.SchedulerSignalerImpl    : Initialized Scheduler Signaller of type: class org.quartz.core.SchedulerSignalerImpl
2018-12-07 11:49:05.569  INFO 5154 --- [           main] org.quartz.core.QuartzScheduler          : Quartz Scheduler v.2.3.0 created.
2018-12-07 11:49:05.570  INFO 5154 --- [           main] org.quartz.simpl.RAMJobStore             : RAMJobStore initialized.
2018-12-07 11:49:05.571  INFO 5154 --- [           main] org.quartz.core.QuartzScheduler          : Scheduler meta-data: Quartz Scheduler (v2.3.0) 'quartzScheduler' with instanceId 'NON_CLUSTERED'
  Scheduler class: 'org.quartz.core.QuartzScheduler' - running locally.
  NOT STARTED.
  Currently in standby mode.
  Number of jobs executed: 0
  Using thread pool 'org.quartz.simpl.SimpleThreadPool' - with 10 threads.
  Using job-store 'org.quartz.simpl.RAMJobStore' - which does not support persistence. and is not clustered.

2018-12-07 11:49:05.571  INFO 5154 --- [           main] org.quartz.impl.StdSchedulerFactory      : Quartz scheduler 'quartzScheduler' initialized from an externally provided properties instance.
2018-12-07 11:49:05.571  INFO 5154 --- [           main] org.quartz.impl.StdSchedulerFactory      : Quartz scheduler version: 2.3.0
2018-12-07 11:49:05.571  INFO 5154 --- [           main] org.quartz.core.QuartzScheduler          : JobFactory set to: org.springframework.scheduling.quartz.SpringBeanJobFactory@769a58e5
2018-12-07 11:49:05.780  WARN 5154 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default LoopResources: DefaultLoopResources {prefix=reactor-http, daemon=true, selectCount=4, workerCount=4}
2018-12-07 11:49:05.780  WARN 5154 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default ConnectionProvider: PooledConnectionProvider {name=http, poolFactory=reactor.netty.resources.ConnectionProvider$$Lambda$284/1788545647@10667848}
2018-12-07 11:49:06.061  INFO 5154 --- [           main] o.s.s.quartz.SchedulerFactoryBean        : Starting Quartz Scheduler now
2018-12-07 11:49:06.062  INFO 5154 --- [           main] org.quartz.core.QuartzScheduler          : Scheduler quartzScheduler_$_NON_CLUSTERED started.
2018-12-07 11:49:06.079  INFO 5154 --- [           main] bj.MyBatisApp                            : Started MyBatisApp in 4.645 seconds (JVM running for 6.354)
2018-12-07 11:49:06.084 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL query [SELECT DATABASE()]
2018-12-07 11:49:06.105 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [DROP SCHEMA IF EXISTS one]
2018-12-07 11:49:06.115 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [CREATE SCHEMA one]
2018-12-07 11:49:06.117 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [USE one]
2018-12-07 11:49:06.119 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32) CHARSET 'utf8')]
2018-12-07 11:49:06.153 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [INSERT INTO user(name) VALUES ('人民的儿子')]
2018-12-07 11:49:06.157 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [INSERT INTO user(name) VALUES ('人民的孙子')]
2018-12-07 11:49:06.161 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [INSERT INTO user(name) VALUES ('人民的曾孙子')]
2018-12-07 11:49:06.164 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [DROP SCHEMA IF EXISTS two]
2018-12-07 11:49:06.174 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [CREATE SCHEMA two]
2018-12-07 11:49:06.176 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [USE two]
2018-12-07 11:49:06.178 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32) CHARSET 'utf8')]
2018-12-07 11:49:06.226 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [INSERT INTO user(name) VALUES ('人民的爹')]
2018-12-07 11:49:06.231 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [INSERT INTO user(name) VALUES ('人民的爷')]
2018-12-07 11:49:06.235 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [INSERT INTO user(name) VALUES ('人民的太爷')]
2018-12-07 11:49:06.243 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [INSERT INTO user(name) VALUES ('人民的老太爷')]
2018-12-07 11:49:06.246 DEBUG 5154 --- [           main] o.s.jdbc.core.JdbcTemplate               : Executing SQL statement [USE one]
Users:
2018-12-07 11:49:06.271 DEBUG 5154 --- [           main] bj.MyBatisApp$UserMapper.selectAll       : ==>  Preparing: SELECT * FROM user
2018-12-07 11:49:06.297 DEBUG 5154 --- [           main] bj.MyBatisApp$UserMapper.selectAll       : ==> Parameters:
2018-12-07 11:49:06.314 DEBUG 5154 --- [           main] bj.MyBatisApp$UserMapper.selectAll       : <==      Total: 3
{name=人民的儿子, id=1}
{name=人民的孙子, id=2}
{name=人民的曾孙子, id=3}
Secondary users:
2018-12-07 11:49:06.318  INFO 5154 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-2 - Starting...
2018-12-07 11:49:06.324  INFO 5154 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-2 - Start completed.
2018-12-07 11:49:06.325 DEBUG 5154 --- [           main] b.M.selectAll                            : ==>  Preparing: SELECT * FROM user
2018-12-07 11:49:06.325 DEBUG 5154 --- [           main] b.M.selectAll                            : ==> Parameters:
2018-12-07 11:49:06.328 DEBUG 5154 --- [           main] b.M.selectAll                            : <==      Total: 4
{name=人民的爹, id=1}
{name=人民的爷, id=2}
{name=人民的太爷, id=3}
{name=人民的老太爷, id=4}
```


文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
