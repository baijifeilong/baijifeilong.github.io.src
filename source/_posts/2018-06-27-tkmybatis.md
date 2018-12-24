---
title: TkMyBatis大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - MyBatis
  - TkMyBatis
date: 2018-06-27 17:28:49
---

## 1. 什么是TkMyBatis

TkMyBatis是一个MyBatis的通用Mapper工具

## 2. 引入TkMyBatis到SpringBoot项目

[最新版本](https://mvnrepository.com/artifact/tk.mybatis/mapper-spring-boot-starter)

以Gradle为例
```gradle
compile 'tk.mybatis:mapper-spring-boot-starter:2.0.3'
```

## 3. 基本用法

1. 创建模型类(不需要Entity注解)
2. 创建Mapper接口，并继承tk.mybatis.mapper.common.Mapper<TheModel>(不需要注解)
3. 注册Mapper 通过MapperScan(tk包非MyBatis包)注解来注册全部的Mapper

示例：

<!--more-->

```java
package com.ddweilai.microservice;

import com.zaxxer.hikari.HikariDataSource;
import lombok.Data;
import org.apache.ibatis.annotations.Select;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import tk.mybatis.mapper.common.Mapper;
import tk.mybatis.spring.annotation.MapperScan;

import javax.annotation.Resource;
import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.sql.DataSource;
import java.util.List;

@SpringBootApplication
@MapperScan(basePackageClasses = App.class)
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        new SpringApplicationBuilder(App.class).web(WebApplicationType.NONE).run(args);
    }

    @Resource
    private UserMapper userMapper;

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        jdbcTemplate.execute("DROP TABLE IF EXISTS user");
        jdbcTemplate.execute("CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(16), real_name VARCHAR(16)) CHARSET utf8");

        User alpha = new User() {{
            setUsername("alpha");
            setRealName("阿尔法");
        }};
        userMapper.insert(alpha);

        User beta = new User() {{
            setUsername("beta");
            setRealName("贝塔");
        }};
        userMapper.insert(beta);

        System.out.println("Inserted alpha:");
        System.out.println(alpha);
        System.out.println("Inserted beta:");
        System.out.println(beta);
        System.out.println("Select by primary key");
        System.out.println(userMapper.selectByPrimaryKey(1));
        System.out.println("selectAll:");
        System.out.println(userMapper.selectAll());
        System.out.println("mySelectAll:");
        System.out.println(userMapper.myFindAll());
    }

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource() {{
            setJdbcUrl("jdbc:mysql://localhost/foo?useSSL=false&characterEncoding=utf8");
            setUsername("root");
            setPassword("root");
        }};
    }
}

@Data
class User {

    @Id
    @Column
    @GeneratedValue(generator = "JDBC")
    private Integer id;

    private String username;

    private String realName;
}

interface UserMapper extends Mapper<User> {
    @Select("SELECT * FROM user")
    List<User> myFindAll();
}
```

### 示例输出

```log
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.0.1.RELEASE)

2018-12-24 20:51:57.025  INFO 35138 --- [           main] com.ddweilai.microservice.App            : Starting App on MacBook-Air-2.local with PID 35138 (/Users/yuchao/workspace/java/1d1d/chat-system/target/classes started by yuchao in /Users/yuchao/workspace/java/1d1d/chat-system)
2018-12-24 20:51:57.040  INFO 35138 --- [           main] com.ddweilai.microservice.App            : The following profiles are active: local
2018-12-24 20:51:57.189  INFO 35138 --- [           main] s.c.a.AnnotationConfigApplicationContext : Refreshing org.springframework.context.annotation.AnnotationConfigApplicationContext@4135c3b: startup date [Mon Dec 24 20:51:57 CST 2018]; root of context hierarchy
2018-12-24 20:51:58.534  WARN 35138 --- [           main] o.m.s.mapper.ClassPathMapperScanner      : Skipping MapperFactoryBean with name 'userMapper' and 'com.ddweilai.microservice.UserMapper' mapperInterface. Bean already defined with the same name!
2018-12-24 20:51:58.535  WARN 35138 --- [           main] o.m.s.mapper.ClassPathMapperScanner      : No MyBatis mapper was found in '[com.ddweilai.microservice]' package. Please check your configuration.
2018-12-24 20:51:59.897  INFO 35138 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear tk.mybatis.mapper.util.MsUtil CLASS_CACHE cache.
2018-12-24 20:51:59.897  INFO 35138 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear tk.mybatis.mapper.genid.GenIdUtil CACHE cache.
2018-12-24 20:51:59.898  INFO 35138 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear tk.mybatis.mapper.version.VersionUtil CACHE cache.
2018-12-24 20:51:59.898  INFO 35138 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear EntityHelper entityTableMap cache.
2018-12-24 20:52:00.414  INFO 35138 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Registering beans for JMX exposure on startup
2018-12-24 20:52:00.416  INFO 35138 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Bean with name 'dataSource' has been autodetected for JMX exposure
2018-12-24 20:52:00.416  INFO 35138 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Bean with name 'statFilter' has been autodetected for JMX exposure
2018-12-24 20:52:00.424  INFO 35138 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Located MBean 'dataSource': registering with JMX server as MBean [com.ddweilai.microservice:name=dataSource,type=App.3]
2018-12-24 20:52:00.425  INFO 35138 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Located MBean 'statFilter': registering with JMX server as MBean [com.alibaba.druid.filter.stat:name=statFilter,type=StatFilter]
2018-12-24 20:52:00.451  INFO 35138 --- [           main] com.ddweilai.microservice.App            : Started App in 4.783 seconds (JVM running for 6.841)
2018-12-24 20:52:00.473  INFO 35138 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2018-12-24 20:52:01.259  INFO 35138 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
Inserted alpha:
User(id=1, username=alpha, realName=阿尔法)
Inserted beta:
User(id=2, username=beta, realName=贝塔)
Select by primary key
User(id=1, username=alpha, realName=阿尔法)
selectAll:
[User(id=1, username=alpha, realName=阿尔法), User(id=2, username=beta, realName=贝塔)]
mySelectAll:
[User(id=1, username=alpha, realName=null), User(id=2, username=beta, realName=null)]
2018-12-24 20:52:01.569  INFO 35138 --- [      Thread-13] s.c.a.AnnotationConfigApplicationContext : Closing org.springframework.context.annotation.AnnotationConfigApplicationContext@4135c3b: startup date [Mon Dec 24 20:51:57 CST 2018]; root of context hierarchy
2018-12-24 20:52:01.572  INFO 35138 --- [      Thread-13] o.s.j.e.a.AnnotationMBeanExporter        : Unregistering JMX-exposed beans on shutdown
2018-12-24 20:52:01.573  INFO 35138 --- [      Thread-13] o.s.j.e.a.AnnotationMBeanExporter        : Unregistering JMX-exposed beans
2018-12-24 20:52:01.576  INFO 35138 --- [      Thread-13] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2018-12-24 20:52:01.602  INFO 35138 --- [      Thread-13] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.

Process finished with exit code 0
```

### 注意

- Mapper不能做子类，否则不能注入成功
- TkMyBatis只能使用@MapperScan寻找Mapper，不能使用@Mapper注解显式指定
- TkMyBatis的Mapper上不需要@Mapper注解，注解了完全没用
- TkMyBatis的Mapper里可以直接添加方法，跟MyBatis用法一致
- TkMyBatis的模型类不需要@Entity注解，各属性也不需要注解，会自动识别
- 如果使用TkMapper提供的主键相关方法，必须有一列注解为@Id
- 如果使用自增ID(MySQL)，必须注解为(@GeneratedValue(generator = "JDBC"))，其他写法均无效
- TkMyBatis自动处理CamelCase与SnakeCase的转换，自定义的Mapper方法不处理，得手动设置`mybatis.configuration.map-underscore-to-camel-case`
- 使用XML格式的Mapper需要手动设置`mybatis.mapper-locations`

## 4. 模型类中的注解

TkMyBatis主要使用的是Jpa注解。一般情况下，如果模型属性与数据库名称一样的话，不需要特殊配置。

如果数据库用下划线命名法，模型类用驼峰命名法，不需要设置，TkMyBatis默认开启转换。

数据库字段与模型字段通过命名转换仍然不匹配的话，需要使用`@Column(name = "the_name")`来进行关联

如果需要用到TkMyBatis提供的主键相关方法，则需要在模型类中注解主键，比如`@Id`

## 5. 具体用法

集成Mapper接口后，我们的Mapper接口就有了大量的基础增删该查接口

- selectAll 查询全部记录
- selectByPrimaryKey 查询主键
- insert 插入一条记录(每个字段都会反映在SQL中)
- insertSelective 插入一条记录，值为null的字段不反映在SQL中，给数据库使用默认值的机会

