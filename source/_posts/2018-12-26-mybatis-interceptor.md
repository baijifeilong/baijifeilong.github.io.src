---
title: MyBatis拦截器演示
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - MyBatis
  - Database
date: 2018-12-26 15:46:00
---

MyBatis拦截器演示

<!--more-->

## Java示例

```java
package bj.mybatisinterceptor;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import com.zaxxer.hikari.HikariDataSource;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.executor.statement.StatementHandler;
import org.apache.ibatis.plugin.*;
import org.apache.ibatis.reflection.MetaObject;
import org.apache.ibatis.reflection.SystemMetaObject;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.LoggerFactory;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import javax.sql.DataSource;
import javax.validation.constraints.NotNull;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.sql.Connection;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/26 下午1:20
 */
@SpringBootApplication
public class App implements ApplicationListener<ApplicationReadyEvent> {

    public static void main(String[] args) {
        new SpringApplicationBuilder(App.class).web(WebApplicationType.NONE).run(args);
    }

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Resource
    private UserMapper userMapper;

    @Override
    public void onApplicationEvent(@NotNull ApplicationReadyEvent event) {
        ((Logger) LoggerFactory.getLogger(App.class.getPackage().getName())).setLevel(Level.INFO);

        jdbcTemplate.execute("DROP TABLE IF EXISTS user");
        jdbcTemplate.execute("CREATE TABLE user(id INT PRIMARY KEY AUTO_INCREMENT, username TEXT)");
        jdbcTemplate.execute("INSERT INTO user(username) VALUES ('alpha'), ('beta')");

        System.out.println("findAll:");
        System.out.println(userMapper.findAll());
        System.out.println();

        System.out.println("findAllLimitOneByAnnotation:");
        System.out.println(userMapper.findAllLimitOneByAnnotation());
        System.out.println();

        System.out.println("findAll again:");
        System.out.println(userMapper.findAll());
        System.out.println();

        System.out.println("findAllLimitOneByAnnotation again:");
        System.out.println(userMapper.findAllLimitOneByAnnotation());
        System.out.println();
    }

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource() {{
            setJdbcUrl("jdbc:mysql://localhost/foo");
            setUsername("root");
            setPassword("root");
        }};
    }

    @Mapper
    @Component
    interface UserMapper {
        @Select("SELECT * FROM user")
        List<Map<String, Object>> findAll();

        @LimitOne
        @Select("SELECT * FROM user")
        List<Map<String, Object>> findAllLimitOneByAnnotation();
    }


    @Retention(RetentionPolicy.RUNTIME)
    @Target(ElementType.METHOD)
    @interface LimitOne {
    }

    @Component
    @Aspect
    static class MyAspect {
        @Around("@annotation(limitOne)")
        public Object doAnnotation(ProceedingJoinPoint joinPoint, LimitOne limitOne) {
            try {
                LimitOneMyBatisInterceptor.LIMIT_ONE.set(Object.class);
                return joinPoint.proceed();
            } catch (Throwable throwable) {
                throw new RuntimeException(throwable);
            } finally {
                LimitOneMyBatisInterceptor.LIMIT_ONE.remove();
            }
        }
    }

    @Component
    @Intercepts({@Signature(type = StatementHandler.class, method = "prepare", args = {Connection.class, Integer.class})})
    static class LimitOneMyBatisInterceptor implements Interceptor {

        final static ThreadLocal<Object> LIMIT_ONE = new ThreadLocal<>();

        @Override
        public Object intercept(Invocation invocation) throws Throwable {
            final String SQL = "delegate.boundSql.sql";
            MetaObject metaObject = SystemMetaObject.forObject(invocation.getTarget());
            if (LIMIT_ONE.get() != null)
                metaObject.setValue(SQL, String.format("%s LIMIT 1", metaObject.getValue(SQL)));
            System.out.printf("SQL: \033[1;35m%s\033[0m\n", metaObject.getValue(SQL));
            return invocation.proceed();
        }

        @Override
        public Object plugin(Object target) {
            return Plugin.wrap(target, this);
        }

        @Override
        public void setProperties(Properties properties) {
        }
    }
}
```

## 控制台输出

```log
findAll:
SQL: SELECT * FROM user
[{id=1, username=alpha}, {id=2, username=beta}]

findAllLimitOneByAnnotation:
SQL: SELECT * FROM user LIMIT 1
[{id=1, username=alpha}]

findAll again:
SQL: SELECT * FROM user
[{id=1, username=alpha}, {id=2, username=beta}]

findAllLimitOneByAnnotation again:
SQL: SELECT * FROM user LIMIT 1
[{id=1, username=alpha}]
```

## 要点

- 用ThreadLocal保存注解状态，避免多线程冲突
- 在finally块中清空ThreadLocal，避免异常扩散
- 拦截`org.apache.ibatis.executor.statement.StatementHandler#prepare`比较方便修改SQL

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
