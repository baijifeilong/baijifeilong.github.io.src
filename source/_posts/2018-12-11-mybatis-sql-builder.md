---
title: MyBatisSQLBuilder
categories:
  - Programming
tags:
  - Programming
date: 2018-12-11 11:13:53
---

# MyBatisSQLBuilder

在MyBatis中，可以使用SQLBuilder用Java代码动态构建SQL语句

<!--more-->

## 示例代码

```java
package bj.mybatis;

import com.zaxxer.hikari.HikariDataSource;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.ibatis.annotations.*;
import org.apache.ibatis.jdbc.SQL;
import org.apache.ibatis.session.Configuration;
import org.mybatis.spring.boot.autoconfigure.MybatisProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.annotation.Resource;
import javax.sql.DataSource;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/11 上午9:57
 */
@SpringBootApplication(exclude = QuartzAutoConfiguration.class)
public class App implements ApplicationListener<ApplicationReadyEvent> {

    public static void main(String[] args) {
        new SpringApplication(App.class) {{
            setWebApplicationType(WebApplicationType.NONE);
        }}.run(args);
    }

    @Resource
    private UserMapper userMapper;

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Bean
    @Primary
    public MybatisProperties mybatisProperties() {
        return new MybatisProperties() {{
            this.setConfiguration(new Configuration() {{
                this.setMapUnderscoreToCamelCase(true);
            }});
        }};
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        initDatabase();
        User one = new User("sky", "九天");
        User two = new User("thunder", "韵雷");
        User three = new User("rain", "暴雨");
        userMapper.create(one);
        userMapper.create(two);
        userMapper.create(three);
        System.out.println(one);
        System.out.println(two);
        System.out.println(three);
        System.out.println(userMapper.findAllByIdList(Arrays.asList(1, 2)));
    }

    @Data
    @NoArgsConstructor
    private static class User {
        private Integer id;
        private String username;
        private String realName;

        User(String username, String realName) {
            this.username = username;
            this.realName = realName;
        }
    }

    @SuppressWarnings("UnusedReturnValue")
    @Mapper
    interface UserMapper {
        @SuppressWarnings("unused")
        class Provider {
            public String findAllByIdList(Map<String, Object> params) {
                List<?> idList = (List<?>) params.get("idList");
                return new SQL() {{
                    SELECT("*");
                    FROM("user");
                    WHERE("id IN " + idList.stream().map(Object::toString).collect(Collectors.joining(",", "(", ")")));
                }}.toString();
            }

            public String create(Map<String, Object> params) {
                User user = (User) params.get("user");
                return new SQL() {{
                    INSERT_INTO("user");
                    VALUES("username", String.format("'%s'", user.username));
                    VALUES("real_name", "#{user.realName}");
                }}.toString();
            }
        }

        @SelectProvider(type = Provider.class, method = "findAllByIdList")
        List<User> findAllByIdList(@Param("idList") List<Integer> idList);

        @InsertProvider(type = Provider.class, method = "create")
        @Options(useGeneratedKeys = true, keyColumn = "id", keyProperty = "user.id")
        int create(@Param("user") User user);
    }

    private void initDatabase() {
        jdbcTemplate.execute("DROP TABLE IF EXISTS user");
        jdbcTemplate.execute("CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(16) UNIQUE ,real_name VARCHAR(32) CHARSET 'utf8')");
    }

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource() {{
            this.setJdbcUrl("jdbc:mysql://localhost/foo?characterEncoding=utf-8");
            this.setUsername("root");
            this.setPassword("root");
        }};
    }
}
```

## 控制台输出

```log
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-11 11:12:33.049  INFO 17749 --- [           main] bj.mybatis.App                           : Starting App on MacBook-Air-2.local with PID 17749 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-11 11:12:33.103  INFO 17749 --- [           main] bj.mybatis.App                           : No active profile set, falling back to default profiles: default
2018-12-11 11:12:37.851  WARN 17749 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default LoopResources: DefaultLoopResources {prefix=reactor-http, daemon=true, selectCount=4, workerCount=4}
2018-12-11 11:12:37.853  WARN 17749 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default ConnectionProvider: PooledConnectionProvider {name=http, poolFactory=reactor.netty.resources.ConnectionProvider$$Lambda$263/708214419@806996}
2018-12-11 11:12:38.057  INFO 17749 --- [           main] bj.mybatis.App                           : Started App in 6.862 seconds (JVM running for 9.432)
2018-12-11 11:12:38.073  INFO 17749 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2018-12-11 11:12:38.538  INFO 17749 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
App.User(id=1, username=sky, realName=九天)
App.User(id=2, username=thunder, realName=韵雷)
App.User(id=3, username=rain, realName=暴雨)
[App.User(id=1, username=sky, realName=九天), App.User(id=2, username=thunder, realName=韵雷)]
2018-12-11 11:12:38.996  INFO 17749 --- [      Thread-20] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2018-12-11 11:12:39.009  INFO 17749 --- [      Thread-20] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
```

## 要点

- `SelectProvider`用来做Select语句生成器
- `InsertProvider`用来做Insert语句生成器。不能跟`SelectProvider`混用，返回类型不一致
- `Provider`不能是接口，只能是类，提供SQL语句的方法必须有访问权限
- `org.apache.ibatis.annotations.Options`注解可以配置自动生成列
- `Map<String, Object> params`可以获取到Mapper方法的所有参数
- 自定义`org.mybatis.spring.boot.autoconfigure.MybatisProperties`类型的Bean可以动态配置MyBatis
- Insert方法不能返回对象，只能返回改动的行数
- 生成的SQL跟XML生成的SQL格式完全一致

## MyBatisSQLBuilder结合jOOQ使用

### Java代码

```java
package bj.mybatis;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import com.zaxxer.hikari.HikariDataSource;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.ibatis.annotations.*;
import org.apache.ibatis.session.Configuration;
import org.jooq.DSLContext;
import org.jooq.SQLDialect;
import org.jooq.conf.ParamType;
import org.jooq.impl.DSL;
import org.mybatis.spring.boot.autoconfigure.MybatisProperties;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.annotation.Resource;
import javax.sql.DataSource;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static jooq.tables.User.USER;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/11 上午9:57
 */
@SpringBootApplication(exclude = QuartzAutoConfiguration.class)
public class App implements ApplicationListener<ApplicationReadyEvent> {

    public static void main(String[] args) {
        new SpringApplication(App.class) {{
            setWebApplicationType(WebApplicationType.NONE);
        }}.run(args);
    }

    @Resource
    private UserMapper userMapper;

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Bean
    @Primary
    public MybatisProperties mybatisProperties() {
        return new MybatisProperties() {{
            this.setConfiguration(new Configuration() {{
                this.setMapUnderscoreToCamelCase(true);
            }});
        }};
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        initLogger();
        initDatabase();
        User one = new User("sky", "九天");
        User two = new User("thunder", "韵雷");
        User three = new User("rain", "暴雨");
        userMapper.create(one);
        userMapper.create(two);
        userMapper.create(three);
        System.out.println(one);
        System.out.println(two);
        System.out.println(three);
        System.out.println("Users(id in (1,2)):");
        System.out.println(userMapper.findAllByIdList(Arrays.asList(1, 2)));
    }

    @Data
    @NoArgsConstructor
    private static class User {
        private Integer id;
        private String username;
        private String realName;

        User(String username, String realName) {
            this.username = username;
            this.realName = realName;
        }
    }

    @SuppressWarnings("UnusedReturnValue")
    @Mapper
    interface UserMapper {
        @SuppressWarnings("unused")
        class Provider {
            private DSLContext dslContext = DSL.using(SQLDialect.MYSQL_8_0);

            public String findAllByIdList(Map<String, Object> params) {
                List<?> idList = (List<?>) params.get("idList");
                return dslContext.selectFrom(USER).where(USER.ID.in(idList)).getSQL(ParamType.INLINED);
            }

            public String create(Map<String, Object> params) {
                User user = (User) params.get("user");
                return dslContext.insertInto(USER)
                        .set(USER.USERNAME, user.username)
                        .set(USER.REAL_NAME, user.realName)
                        .getSQL(ParamType.INLINED);
            }
        }

        @SelectProvider(type = Provider.class, method = "findAllByIdList")
        List<User> findAllByIdList(@Param("idList") List<Integer> idList);

        @InsertProvider(type = Provider.class, method = "create")
        @Options(useGeneratedKeys = true, keyColumn = "id", keyProperty = "user.id")
        int create(@Param("user") User user);
    }

    private void initLogger() {
        ((Logger) LoggerFactory.getLogger(org.jooq.Constants.class)).setLevel(Level.WARN);
    }

    private void initDatabase() {
        jdbcTemplate.execute("DROP TABLE IF EXISTS user");
        jdbcTemplate.execute("CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(16) UNIQUE ,real_name VARCHAR(32) CHARSET 'utf8')");
    }

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource() {{
            this.setJdbcUrl("jdbc:mysql://localhost/foo?characterEncoding=utf-8");
            this.setUsername("root");
            this.setPassword("root");
        }};
    }
}

```

### 控制台输出

```log

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-11 15:18:09.320  INFO 18826 --- [           main] bj.mybatis.App                           : Starting App on MacBook-Air-2.local with PID 18826 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-11 15:18:09.328  INFO 18826 --- [           main] bj.mybatis.App                           : No active profile set, falling back to default profiles: default
2018-12-11 15:18:11.540  INFO 18826 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2018-12-11 15:18:11.668  INFO 18826 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2018-12-11 15:18:12.281  WARN 18826 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default LoopResources: DefaultLoopResources {prefix=reactor-http, daemon=true, selectCount=4, workerCount=4}
2018-12-11 15:18:12.281  WARN 18826 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default ConnectionProvider: PooledConnectionProvider {name=http, poolFactory=reactor.netty.resources.ConnectionProvider$$Lambda$281/609825180@ffaaaf0}
2018-12-11 15:18:12.451  INFO 18826 --- [           main] bj.mybatis.App                           : Started App in 4.13 seconds (JVM running for 6.377)
App.User(id=1, username=sky, realName=九天)
App.User(id=2, username=thunder, realName=韵雷)
App.User(id=3, username=rain, realName=暴雨)
Users(id in (1,2)):
[App.User(id=1, username=sky, realName=九天), App.User(id=2, username=thunder, realName=韵雷)]
2018-12-11 15:18:13.038  INFO 18826 --- [      Thread-14] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2018-12-11 15:18:13.042  INFO 18826 --- [      Thread-14] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.

```

注意:

- 需要配置好jOOQ
- 没有用到PreparedStatement，影响性能

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
