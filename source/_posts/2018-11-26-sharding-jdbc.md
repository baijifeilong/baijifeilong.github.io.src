---
title: ShardingJDBC大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Database
  - Sharding
  - JDBC
date: 2018-11-26 14:45:46
---

# ShardingJDBC大杂烩

## ShardingJDBC是什么

ShardingJDBC是一个数据库分库分表框架，它通过实现自定义的`javax.sql.DataSource`接口，将分库分表的逻辑封装在了里头，让客户端可以通过`JDBC`相对透明地访问分片数据库。但是，分片数据库有其固有之局限性，需要谨慎使用。

## ShardingJDBC快速入门示例

以SpringBoot+Maven+MySQL为例

### 1. 引入ShardingJDBC依赖

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>bj</groupId>
    <artifactId>hellomaven</artifactId>
    <packaging>jar</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>hellomaven</name>
    <url>http://maven.apache.org</url>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.0.RELEASE</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>

        <dependency>
            <groupId>io.shardingsphere</groupId>
            <artifactId>sharding-jdbc-spring-boot-starter</artifactId>
            <version>3.0.0</version>
        </dependency>
    </dependencies>
</project>
```

<!--more-->

### 2. 创建数据表

创建2库3表共6个user表: ds0.user0 ~ ds1.user2

```python
import mysql.connector

conn = mysql.connector.connect(host='localhost', user='root', password='root', db='foo')
conn.autocommit = True
cursor = conn.cursor()

for i in range(0, 2):
    cursor.execute(f"DROP SCHEMA IF EXISTS ds{i}")
    cursor.execute(f"CREATE SCHEMA ds{i}")
    for j in range(0, 3):
        cursor.execute(f"CREATE TABLE ds{i}.user{j}(_id BIGINT, id INT, username VARCHAR(16))")
```

对应的SQL

```sql
DROP SCHEMA IF EXISTS ds0;
CREATE SCHEMA ds0;
CREATE TABLE ds0.user0(_id BIGINT, id INT, username VARCHAR(16));
CREATE TABLE ds0.user1(_id BIGINT, id INT, username VARCHAR(16));
CREATE TABLE ds0.user2(_id BIGINT, id INT, username VARCHAR(16));
DROP SCHEMA IF EXISTS ds1;
CREATE SCHEMA ds1;
CREATE TABLE ds1.user0(_id BIGINT, id INT, username VARCHAR(16));
CREATE TABLE ds1.user1(_id BIGINT, id INT, username VARCHAR(16));
CREATE TABLE ds1.user2(_id BIGINT, id INT, username VARCHAR(16));
```

### 3. 配置ShardingJDBC

ShardingJDBC的文档乍一看啥都有，仔细一看下不了手，文档跟项目还不同步，需要面向异常，随机应变。

以分库策略对2取模，分表策略对3取模为例:

**application.yml**

```yaml
sharding:
  jdbc:
    datasource:
      names: ds0,ds1
      ds0:
        type: com.zaxxer.hikari.HikariDataSource
        jdbc-url: jdbc:mysql://localhost/ds0
        username: root
        password: root
      ds1:
        type: com.zaxxer.hikari.HikariDataSource
        jdbc-url: jdbc:mysql://localhost/ds1
        username: root
        password: root
    config:
      sharding:
        tables:
          user:
            database-strategy:
              inline:
                sharding-column: id
                algorithm-expression: ds$->{id % 2}
            table-strategy:
              inline:
                sharding-column: id
                algorithm-expression: user$->{id % 3}
            key-generator-column-name: _id
logging:
  level:
    root: debug
```

### 4. 在主程序中调用ShardingJDBC

```java
package bj;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@SpringBootApplication
@RestController
public class App {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Resource
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/")
    public Object index() {
        jdbcTemplate.update("INSERT INTO user(id, username) VALUES (1, 'alpha')");
        jdbcTemplate.update("INSERT INTO user(id, username) VALUES (2, 'beta')");
        jdbcTemplate.update("INSERT INTO user(id, username) VALUES (3, 'gamma')");
        jdbcTemplate.update("INSERT INTO user(id, username) VALUES (4, 'theta')");
        List<Map<String, Object>> maps = jdbcTemplate.queryForList("SELECT * FROM user WHERE id IN (0,1,2,3,4,5,6,7)");
        System.out.println(maps);
        return maps;
    }
}
```

执行主程序，访问`localhost:8080/`，返回的JSON如下:

```json
[
    {
        "_id": 273847537209704448,
        "id": 4,
        "username": "theta"
    },
    {
        "_id": 273847537138401280,
        "id": 2,
        "username": "beta"
    },
    {
        "_id": 273847537163567104,
        "id": 3,
        "username": "gamma"
    },
    {
        "_id": 273847537096458240,
        "id": 1,
        "username": "alpha"
    }
]
```

MySQL的SQL日志如下:

```sql
2018-11-26T08:12:20.690370Z	 1697 Query	INSERT INTO user1(id, username, _id) VALUES (1, 'alpha', 273847537096458240)
2018-11-26T08:12:20.698059Z	 1696 Query	INSERT INTO user2(id, username, _id) VALUES (2, 'beta', 273847537138401280)
2018-11-26T08:12:20.702720Z	 1697 Query	INSERT INTO user0(id, username, _id) VALUES (3, 'gamma', 273847537163567104)
2018-11-26T08:12:20.717724Z	 1696 Query	INSERT INTO user1(id, username, _id) VALUES (4, 'theta', 273847537209704448)
2018-11-26T08:12:20.729676Z	 1697 Query	SELECT * FROM user0 WHERE id IN (0,1,2,3,4,5,6,7)
2018-11-26T08:12:20.729705Z	 1696 Query	SELECT * FROM user0 WHERE id IN (0,1,2,3,4,5,6,7)
2018-11-26T08:12:20.732935Z	 1697 Query	SELECT * FROM user1 WHERE id IN (0,1,2,3,4,5,6,7)
2018-11-26T08:12:20.733504Z	 1696 Query	SELECT * FROM user1 WHERE id IN (0,1,2,3,4,5,6,7)
2018-11-26T08:12:20.736153Z	 1697 Query	SELECT * FROM user2 WHERE id IN (0,1,2,3,4,5,6,7)
2018-11-26T08:12:20.736612Z	 1696 Query	SELECT * FROM user2 WHERE id IN (0,1,2,3,4,5,6,7)
```

可见，ShardingJDBC确实执行了多库多表的插入与查询操作，而且生成了分布式自增ID

### 5. ShardingJDBC的局限性

~~ShardingJDBC似乎只支持带有分表键而且查询条件必须是`=`或`IN`的查询。导致像`SELECT MAX(id) FROM user`(查询用户表中的最大ID)这种看似极其简单的查询(每表做一次MAX，中间件做一次归并)也无法进行。~~

ShardingJDBC的文档做的很烂(PPT文档，理论一大坨，代码没几行)，代码没有能跑得起来的(代码跟文档严重不同步)，示例的代码还只有最基础的用法，看完后对实际的应用几乎无法下手。在这种情况下，还用配置文件做配置，就掉大坑里了。比如我之前写的YAML配置缺了一项配置，还不报错，结果有的代码能跑，有的代码不能跑，文档又稀疏地可怜，让人以为这些功能还没有实现。

所以，在文档更新之前，还是直接走Java配置吧，至少IDE能给出一些有用的提示。

### 6. ShardingJDBC的纯Java配置

创建一个ShardingDataSource，以这个数据源创建数据库连接即可。

注意: actualDataNodes必须设置，不设置此项不会报错，但是不带ShardingKey的查询会失败(找不到真实表，直接走逻辑表)

**示例代码**

```java
package bj;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.core.ConsoleAppender;
import ch.qos.logback.core.Context;
import com.zaxxer.hikari.HikariDataSource;
import io.shardingsphere.api.config.ShardingRuleConfiguration;
import io.shardingsphere.api.config.TableRuleConfiguration;
import io.shardingsphere.api.config.strategy.InlineShardingStrategyConfiguration;
import io.shardingsphere.core.constant.properties.ShardingPropertiesConstant;
import io.shardingsphere.shardingjdbc.api.ShardingDataSourceFactory;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.tuple.Pair;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/5 下午9:31
 */
@Slf4j
public class ShardingJdbcTest {

    private JdbcTemplate normalJdbcTemplate;

    private JdbcTemplate shardingJdbcTemplate;

    @SuppressWarnings("unchecked")
    private void initLogger() {
        ((Logger) (LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME))).setLevel(Level.INFO);
        ((ConsoleAppender) ((Logger) (LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME))).getAppender("console")).setEncoder(new PatternLayoutEncoder() {
            {
                setContext((Context) LoggerFactory.getILoggerFactory());
                setPattern("[%date] %highlight([%level]) [%logger{10} %file:%line] [%thread] %msg%n");
                start();
            }
        });
    }

    private void initDatabase() {
        normalJdbcTemplate = new JdbcTemplate(new HikariDataSource() {{
            setJdbcUrl("jdbc:mysql://localhost/foo");
            setUsername("root");
            setPassword("root");
        }});
        for (int i : new int[]{0, 1}) {
            normalJdbcTemplate.execute("DROP SCHEMA IF EXISTS ds" + i);
            normalJdbcTemplate.execute("CREATE SCHEMA ds" + i);
            normalJdbcTemplate.execute("USE ds" + i);
            for (int j : new int[]{0, 1, 2}) {
                normalJdbcTemplate.execute("CREATE TABLE user" + j + "(id INT, username VARCHAR(32))");
            }
        }
    }

    private void initShadingJdbc() throws SQLException {
        TableRuleConfiguration tableRuleConfiguration = new TableRuleConfiguration();
        tableRuleConfiguration.setLogicTable("user");
        tableRuleConfiguration.setActualDataNodes("ds${0..1}.user${0..2}"); // 必须设置，否则会有意想不到的结果
        tableRuleConfiguration.setDatabaseShardingStrategyConfig(new InlineShardingStrategyConfiguration("id", "ds${id % 2}"));
        tableRuleConfiguration.setTableShardingStrategyConfig(new InlineShardingStrategyConfiguration("id", "user${id % 3}"));

        ShardingRuleConfiguration shardingRuleConfiguration = new ShardingRuleConfiguration();
        shardingRuleConfiguration.getTableRuleConfigs().add(tableRuleConfiguration);

        shardingJdbcTemplate = new JdbcTemplate(ShardingDataSourceFactory.createDataSource(
                Stream.of("ds0", "ds1").map($ -> Pair.of(
                        $, new HikariDataSource() {{
                            setJdbcUrl("jdbc:mysql://localhost/" + $);
                            setUsername("root");
                            setPassword("root");
                        }}
                )).collect(Collectors.toMap(Pair::getLeft, Pair::getRight)),
                shardingRuleConfiguration, new HashMap<>(), new Properties() {{
                    this.setProperty(ShardingPropertiesConstant.SQL_SHOW.getKey(), "true");
                }}
        ));
    }

    private void inspectDatabase() {
        System.out.println("Inspecting database...");
        for (int i : new int[]{0, 1}) {
            for (int j : new int[]{0, 1, 2}) {
                List<Map<String, Object>> list = normalJdbcTemplate.queryForList(String.format("SELECT * FROM ds%d.user%d", i, j));
                System.out.println(String.format("ds%d.user%d: %s", i, j, list));
            }
        }
    }

    @Before
    public void before() throws SQLException {
        log.info("Initializing logger...");
        initLogger();
        log.info("Initializing database...");
        initDatabase();
        log.info("Initializing jdbc...");
        initShadingJdbc();
    }

    @Test
    public void testAlpha() {
        System.out.println();
        inspectDatabase();
        System.out.println();

        System.out.println("Inserting 10 users...\n");
        IntStream.rangeClosed(1, 10).forEach($ -> {
            shardingJdbcTemplate.update("INSERT INTO user(id, username) VALUES (?, ?)", $, "User" + $);
        });
        System.out.println();

        inspectDatabase();
        System.out.println();

        System.out.println("All users:");
        shardingJdbcTemplate.queryForList("SELECT * FROM user ORDER BY id").forEach(System.out::println);
        System.out.println();

        Long maxId = shardingJdbcTemplate.queryForObject("SELECT MAX(id) FROM user", Long.class);
        System.out.println("Max user id: " + maxId);
        System.out.println();

        Object eight = shardingJdbcTemplate.queryForMap("SELECT * FROM user WHERE id = 8");
        System.out.println("User(id=8): " + eight);
        System.out.println();

        List<Map<String, Object>> usersIdLte3 = shardingJdbcTemplate.queryForList("SELECT * FROM user WHERE id <= 3");
        System.out.println("Users(id<=3): " + usersIdLte3);
        System.out.println();

        List<Map<String, Object>> usersIdInOneThreeFive = shardingJdbcTemplate.queryForList("SELECT * FROM user WHERE id IN (1,3,5)");
        System.out.println("Users(id IN (1,3,5)): " + usersIdInOneThreeFive);
    }
}
```

**控制台输出**

```log
13:17:41.816 [main] INFO bj.ShardingJdbcTest - Initializing logger...
[2018-12-06 13:17:41,932] [INFO] [b.ShardingJdbcTest ShardingJdbcTest.java:106] [main] Initializing database...
[2018-12-06 13:17:42,175] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:110] [main] HikariPool-1 - Starting...
[2018-12-06 13:17:42,979] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:123] [main] HikariPool-1 - Start completed.
[2018-12-06 13:17:43,400] [INFO] [b.ShardingJdbcTest ShardingJdbcTest.java:108] [main] Initializing jdbc...
[2018-12-06 13:17:44,938] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:110] [main] HikariPool-2 - Starting...
[2018-12-06 13:17:44,950] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:123] [main] HikariPool-2 - Start completed.
[2018-12-06 13:17:44,960] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:110] [main] HikariPool-3 - Starting...
[2018-12-06 13:17:44,972] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:123] [main] HikariPool-3 - Start completed.

Inspecting database...
ds0.user0: []
ds0.user1: []
ds0.user2: []
ds1.user0: []
ds1.user1: []
ds1.user2: []

Inserting 10 users...

[2018-12-06 13:17:45,506] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,507] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,507] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,508] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: INSERT INTO user1(id, username) VALUES (?, ?) ::: [[1, User1]]
[2018-12-06 13:17:45,734] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,734] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,734] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,735] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user2(id, username) VALUES (?, ?) ::: [[2, User2]]
[2018-12-06 13:17:45,742] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,743] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,743] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,743] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[3, User3]]
[2018-12-06 13:17:45,746] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,746] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,747] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,747] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user1(id, username) VALUES (?, ?) ::: [[4, User4]]
[2018-12-06 13:17:45,749] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,750] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,750] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,750] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: INSERT INTO user2(id, username) VALUES (?, ?) ::: [[5, User5]]
[2018-12-06 13:17:45,753] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,754] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,754] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,754] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[6, User6]]
[2018-12-06 13:17:45,757] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,758] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,758] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,759] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: INSERT INTO user1(id, username) VALUES (?, ?) ::: [[7, User7]]
[2018-12-06 13:17:45,762] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,763] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,763] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,764] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user2(id, username) VALUES (?, ?) ::: [[8, User8]]
[2018-12-06 13:17:45,768] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,769] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,769] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,769] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[9, User9]]
[2018-12-06 13:17:45,773] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,773] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 13:17:45,773] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@6622fc65], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 13:17:45,773] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user1(id, username) VALUES (?, ?) ::: [[10, User10]]

Inspecting database...
ds0.user0: [{id=6, username=User6}]
ds0.user1: [{id=4, username=User4}, {id=10, username=User10}]
ds0.user2: [{id=2, username=User2}, {id=8, username=User8}]
ds1.user0: [{id=3, username=User3}, {id=9, username=User9}]
ds1.user1: [{id=1, username=User1}, {id=7, username=User7}]
ds1.user2: [{id=5, username=User5}]

All users:
[2018-12-06 13:17:45,852] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:45,852] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user ORDER BY id
[2018-12-06 13:17:45,853] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[OrderItem(owner=Optional.absent(), name=Optional.of(id), orderDirection=ASC, nullOrderDirection=ASC, index=-1, alias=Optional.absent())], limit=null, subQueryStatement=null)
[2018-12-06 13:17:45,853] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user0 ORDER BY id
[2018-12-06 13:17:45,853] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user1 ORDER BY id
[2018-12-06 13:17:45,854] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user2 ORDER BY id
[2018-12-06 13:17:45,854] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user0 ORDER BY id
[2018-12-06 13:17:45,854] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user1 ORDER BY id
[2018-12-06 13:17:45,854] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user2 ORDER BY id
{id=1, username=User1}
{id=2, username=User2}
{id=3, username=User3}
{id=4, username=User4}
{id=5, username=User5}
{id=6, username=User6}
{id=7, username=User7}
{id=8, username=User8}
{id=9, username=User9}
{id=10, username=User10}

[2018-12-06 13:17:46,007] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:46,010] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT MAX(id) FROM user
[2018-12-06 13:17:46,011] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=false, selectListLastPosition=15, groupByLastPosition=0, items=[AggregationSelectItem(type=MAX, innerExpression=(id), alias=Optional.absent(), derivedAggregationSelectItems=[], index=-1)], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 13:17:46,012] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT MAX(id) FROM user0
[2018-12-06 13:17:46,012] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT MAX(id) FROM user1
[2018-12-06 13:17:46,012] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT MAX(id) FROM user2
[2018-12-06 13:17:46,012] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT MAX(id) FROM user0
[2018-12-06 13:17:46,013] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT MAX(id) FROM user1
[2018-12-06 13:17:46,013] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT MAX(id) FROM user2
Max user id: 10

[2018-12-06 13:17:46,046] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:46,047] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user WHERE id = 8
[2018-12-06 13:17:46,047] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={0=8}, positionIndexMap={})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 13:17:46,047] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user2 WHERE id = 8
User(id=8): {id=8, username=User8}

[2018-12-06 13:17:46,054] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:46,054] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user WHERE id <= 3
[2018-12-06 13:17:46,054] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 13:17:46,054] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user0 WHERE id <= 3
[2018-12-06 13:17:46,054] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user1 WHERE id <= 3
[2018-12-06 13:17:46,055] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user2 WHERE id <= 3
[2018-12-06 13:17:46,056] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user0 WHERE id <= 3
[2018-12-06 13:17:46,056] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user1 WHERE id <= 3
[2018-12-06 13:17:46,056] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user2 WHERE id <= 3
Users(id<=3): [{id=2, username=User2}, {id=3, username=User3}, {id=1, username=User1}]

[2018-12-06 13:17:46,071] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 13:17:46,071] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user WHERE id IN (1,3,5)
[2018-12-06 13:17:46,072] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=IN, positionValueMap={0=1, 1=3, 2=5}, positionIndexMap={})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 13:17:46,073] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user0 WHERE id IN (1,3,5)
[2018-12-06 13:17:46,073] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user1 WHERE id IN (1,3,5)
[2018-12-06 13:17:46,073] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user2 WHERE id IN (1,3,5)
Users(id IN (1,3,5)): [{id=3, username=User3}, {id=1, username=User1}, {id=5, username=User5}]
```

### 7. 自定义Sharding策略

ShardingJDBC的分库策略和分表策略都得实现同一个接口`io.shardingsphere.api.config.strategy.ShardingStrategyConfiguration`。这是一个空接口，有五种实现:

1. `io.shardingsphere.api.config.strategy.NoneShardingStrategyConfiguration` 不切片
2. `io.shardingsphere.api.config.strategy.InlineShardingStrategyConfiguration` Groovy表达式切片
3. `io.shardingsphere.api.config.strategy.HintShardingStrategyConfiguration` 按提示切片，所谓的提示指的是分片条件不在标准SQL中，是按ShardingJDBC的特殊语法注入进去的
4. `io.shardingsphere.api.config.strategy.StandardShardingStrategyConfiguration` 标准切片策略，需要指定: 1. 切片键; 2. 切片值到真实源/表的映射
5. `io.shardingsphere.api.config.strategy.ComplexShardingStrategyConfiguration` 复杂切片策略，适用于有多个切片键的情况。需要指定: 1. 切片键集合; 2. 切片键集合到真实源/表集合的映射

这些切片策略的切片算法都实现了`io.shardingsphere.core.routing.strategy.ShardingAlgorithm`接口，这个接口是个空接口，有四个子接口:

1. `io.shardingsphere.api.algorithm.sharding.standard.PreciseShardingAlgorithm` 精确标准算法，用于表示切片值到真实源/表的一对一映射
2. `io.shardingsphere.api.algorithm.sharding.standard.RangeShardingAlgorithm` 范围切片算法，用于表示切片值范围到真实源/表集合的多对多映射
3. `io.shardingsphere.api.algorithm.sharding.complex.ComplexKeysShardingAlgorithm` 多键切片算法，用于表示切片值集合到真实源/表集合的多对多映射
4. `io.shardingsphere.api.algorithm.sharding.hint.HintShardingAlgorithm` 提示切片算法，用于表示提示信息到真实源/表集合的一对多映射

#### 自定义切片策略举例

1. 普通取模切片

```java
TableRuleConfiguration tableRuleConfiguration = new TableRuleConfiguration();
tableRuleConfiguration.setLogicTable("user");
tableRuleConfiguration.setActualDataNodes("ds${0..1}.user${0..2}");
tableRuleConfiguration.setDatabaseShardingStrategyConfig(new StandardShardingStrategyConfiguration("id",
        (availableTargetNames, shardingValue) -> "ds" + ((Number) shardingValue.getValue()).intValue() % 2));
tableRuleConfiguration.setTableShardingStrategyConfig(new StandardShardingStrategyConfiguration("id",
        (availableTargetNames, shardingValue) -> "user" + ((Number) shardingValue.getValue()).intValue() % 3));
```

2. 一致性哈希切片
```java
package bj;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.core.ConsoleAppender;
import ch.qos.logback.core.Context;
import com.zaxxer.hikari.HikariDataSource;
import io.shardingsphere.api.config.ShardingRuleConfiguration;
import io.shardingsphere.api.config.TableRuleConfiguration;
import io.shardingsphere.api.config.strategy.StandardShardingStrategyConfiguration;
import io.shardingsphere.core.constant.properties.ShardingPropertiesConstant;
import io.shardingsphere.shardingjdbc.api.ShardingDataSourceFactory;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;

import java.nio.ByteBuffer;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/5 下午9:31
 */
@Slf4j
public class ShardingJdbcTest {

    private JdbcTemplate normalJdbcTemplate;

    private JdbcTemplate shardingJdbcTemplate;

    @SuppressWarnings("unchecked")
    private void initLogger() {
        ((Logger) (LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME))).setLevel(Level.INFO);
        ((ConsoleAppender) ((Logger) (LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME))).getAppender("console")).setEncoder(new PatternLayoutEncoder() {
            {
                setContext((Context) LoggerFactory.getILoggerFactory());
                setPattern("[%date] %highlight([%level]) [%logger{10} %file:%line] [%thread] %msg%n");
                start();
            }
        });
    }

    private void initDatabase() {
        normalJdbcTemplate = new JdbcTemplate(new HikariDataSource() {{
            setJdbcUrl("jdbc:mysql://localhost/foo");
            setUsername("root");
            setPassword("root");
        }});
        for (int i : new int[]{0, 1}) {
            normalJdbcTemplate.execute("DROP SCHEMA IF EXISTS ds" + i);
            normalJdbcTemplate.execute("CREATE SCHEMA ds" + i);
            normalJdbcTemplate.execute("USE ds" + i);
            for (int j : new int[]{0, 1, 2}) {
                normalJdbcTemplate.execute("CREATE TABLE user" + j + "(id INT, username VARCHAR(32))");
            }
        }
    }

    private void initShadingJdbc() throws SQLException {
        @RequiredArgsConstructor
        class Node implements Comparable<Node> {
            private final String name;

            private long digest() {
                return Integer.toUnsignedLong(ByteBuffer.wrap(DigestUtils.md5(name), 0, 4).getInt());
            }

            @Override
            public int compareTo(Node o) {
                return Long.compare(this.digest(), o.digest());
            }

            private Node route(Set<Node> nodes) {
                for (Node node : nodes) {
                    if (node.digest() > this.digest()) {
                        return node;
                    }
                }
                return nodes.iterator().next();
            }
        }
        Set<Node> nodes = new TreeSet<>();
        for (int i : new int[]{0, 1}) {
            for (int j : new int[]{0, 2}) {
                nodes.add(new Node("ds" + i + "." + "user" + j));
            }
        }

        TableRuleConfiguration tableRuleConfiguration = new TableRuleConfiguration();
        tableRuleConfiguration.setLogicTable("user");
        tableRuleConfiguration.setActualDataNodes("ds${0..1}.user${0..2}");

        tableRuleConfiguration.setDatabaseShardingStrategyConfig(new StandardShardingStrategyConfiguration("id",
                (availableTargetNames, shardingValue) -> new Node(shardingValue.getValue().toString()).route(nodes).name.split("\\.")[0]));
        tableRuleConfiguration.setTableShardingStrategyConfig(new StandardShardingStrategyConfiguration("id",
                (availableTargetNames, shardingValue) -> new Node(shardingValue.getValue().toString()).route(nodes).name.split("\\.")[1]));

        ShardingRuleConfiguration shardingRuleConfiguration = new ShardingRuleConfiguration();
        shardingRuleConfiguration.getTableRuleConfigs().add(tableRuleConfiguration);

        shardingJdbcTemplate = new JdbcTemplate(ShardingDataSourceFactory.createDataSource(
                Stream.of("ds0", "ds1").map($ -> Pair.of(
                        $, new HikariDataSource() {{
                            setJdbcUrl("jdbc:mysql://localhost/" + $);
                            setUsername("root");
                            setPassword("root");
                        }}
                )).collect(Collectors.toMap(Pair::getLeft, Pair::getRight)),
                shardingRuleConfiguration, new HashMap<>(), new Properties() {{
                    this.setProperty(ShardingPropertiesConstant.SQL_SHOW.getKey(), "true");
                }}
        ));
    }

    private void inspectDatabase() {
        System.out.println("Inspecting database...");
        for (int i : new int[]{0, 1}) {
            for (int j : new int[]{0, 1, 2}) {
                List<Map<String, Object>> list = normalJdbcTemplate.queryForList(String.format("SELECT * FROM ds%d.user%d", i, j));
                System.out.println(String.format("ds%d.user%d: %s", i, j, list));
            }
        }
    }

    @Before
    public void before() throws SQLException {
        log.info("Initializing logger...");
        initLogger();
        log.info("Initializing database...");
        initDatabase();
        log.info("Initializing jdbc...");
        initShadingJdbc();
    }

    @Test
    public void testAlpha() {
        System.out.println();
        inspectDatabase();
        System.out.println();

        System.out.println("Inserting 10 users...\n");
        IntStream.rangeClosed(1, 10).forEach($ -> {
            shardingJdbcTemplate.update("INSERT INTO user(id, username) VALUES (?, ?)", $, "User" + $);
        });
        System.out.println();

        inspectDatabase();
        System.out.println();

        System.out.println("All users:");
        shardingJdbcTemplate.queryForList("SELECT * FROM user ORDER BY id").forEach(System.out::println);
        System.out.println();

        Long maxId = shardingJdbcTemplate.queryForObject("SELECT MAX(id) FROM user", Long.class);
        System.out.println("Max user id: " + maxId);
        System.out.println();

        Object eight = shardingJdbcTemplate.queryForMap("SELECT * FROM user WHERE id = 8");
        System.out.println("User(id=8): " + eight);
        System.out.println();

        List<Map<String, Object>> usersIdLte3 = shardingJdbcTemplate.queryForList("SELECT * FROM user WHERE id <= 3");
        System.out.println("Users(id<=3): " + usersIdLte3);
        System.out.println();

        List<Map<String, Object>> usersIdInOneThreeFive = shardingJdbcTemplate.queryForList("SELECT * FROM user WHERE id IN (1,3,5)");
        System.out.println("Users(id IN (1,3,5)): " + usersIdInOneThreeFive);
    }
}
```

控制台输出:

```log
16:30:29.966 [main] INFO bj.ShardingJdbcTest - Initializing logger...
[2018-12-06 16:30:30,095] [INFO] [b.ShardingJdbcTest ShardingJdbcTest.java:138] [main] Initializing database...
[2018-12-06 16:30:30,370] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:110] [main] HikariPool-1 - Starting...
[2018-12-06 16:30:31,103] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:123] [main] HikariPool-1 - Start completed.
[2018-12-06 16:30:31,428] [INFO] [b.ShardingJdbcTest ShardingJdbcTest.java:140] [main] Initializing jdbc...
[2018-12-06 16:30:32,698] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:110] [main] HikariPool-2 - Starting...
[2018-12-06 16:30:32,707] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:123] [main] HikariPool-2 - Start completed.
[2018-12-06 16:30:32,712] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:110] [main] HikariPool-3 - Starting...
[2018-12-06 16:30:32,725] [INFO] [c.z.h.HikariDataSource HikariDataSource.java:123] [main] HikariPool-3 - Start completed.

Inspecting database...
ds0.user0: []
ds0.user1: []
ds0.user2: []
ds1.user0: []
ds1.user1: []
ds1.user2: []

Inserting 10 users...

[2018-12-06 16:30:33,041] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,042] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,042] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,043] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[1, User1]]
[2018-12-06 16:30:33,173] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,173] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,174] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,174] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[2, User2]]
[2018-12-06 16:30:33,178] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,179] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,179] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,179] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[3, User3]]
[2018-12-06 16:30:33,182] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,183] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,183] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,183] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[4, User4]]
[2018-12-06 16:30:33,187] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,187] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,188] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,188] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[5, User5]]
[2018-12-06 16:30:33,192] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,192] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,192] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,192] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[6, User6]]
[2018-12-06 16:30:33,197] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,197] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,197] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,197] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[7, User7]]
[2018-12-06 16:30:33,201] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,201] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,201] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,202] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[8, User8]]
[2018-12-06 16:30:33,206] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,206] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,206] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,207] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user2(id, username) VALUES (?, ?) ::: [[9, User9]]
[2018-12-06 16:30:33,210] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,210] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: INSERT INTO user(id, username) VALUES (?, ?)
[2018-12-06 16:30:33,210] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: InsertStatement(super=DMLStatement(super=AbstractSQLStatement(type=DML, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={}, positionIndexMap={0=0})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user), io.shardingsphere.core.parsing.parser.token.InsertValuesToken@54dcfa5a], parametersIndex=2)), columns=[Column(name=id, tableName=user), Column(name=username, tableName=user)], generatedKeyConditions=[], insertValues=InsertValues(insertValues=[InsertValue(type=VALUES, expression=(?, ?), parametersCount=2)]), columnsListLastPosition=29, generateKeyColumnIndex=-1, insertValuesListLastPosition=44)
[2018-12-06 16:30:33,211] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: INSERT INTO user0(id, username) VALUES (?, ?) ::: [[10, User10]]

Inspecting database...
ds0.user0: [{id=1, username=User1}, {id=2, username=User2}, {id=3, username=User3}, {id=4, username=User4}, {id=5, username=User5}, {id=7, username=User7}, {id=8, username=User8}, {id=10, username=User10}]
ds0.user1: []
ds0.user2: [{id=9, username=User9}]
ds1.user0: [{id=6, username=User6}]
ds1.user1: []
ds1.user2: []

All users:
[2018-12-06 16:30:33,363] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,364] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user ORDER BY id
[2018-12-06 16:30:33,364] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[OrderItem(owner=Optional.absent(), name=Optional.of(id), orderDirection=ASC, nullOrderDirection=ASC, index=-1, alias=Optional.absent())], limit=null, subQueryStatement=null)
[2018-12-06 16:30:33,365] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user0 ORDER BY id
[2018-12-06 16:30:33,365] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user1 ORDER BY id
[2018-12-06 16:30:33,365] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user2 ORDER BY id
[2018-12-06 16:30:33,366] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user0 ORDER BY id
[2018-12-06 16:30:33,366] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user1 ORDER BY id
[2018-12-06 16:30:33,366] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user2 ORDER BY id
{id=1, username=User1}
{id=2, username=User2}
{id=3, username=User3}
{id=4, username=User4}
{id=5, username=User5}
{id=6, username=User6}
{id=7, username=User7}
{id=8, username=User8}
{id=9, username=User9}
{id=10, username=User10}

[2018-12-06 16:30:33,483] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,483] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT MAX(id) FROM user
[2018-12-06 16:30:33,483] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=false, selectListLastPosition=15, groupByLastPosition=0, items=[AggregationSelectItem(type=MAX, innerExpression=(id), alias=Optional.absent(), derivedAggregationSelectItems=[], index=-1)], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 16:30:33,484] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT MAX(id) FROM user0
[2018-12-06 16:30:33,484] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT MAX(id) FROM user1
[2018-12-06 16:30:33,484] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT MAX(id) FROM user2
[2018-12-06 16:30:33,485] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT MAX(id) FROM user0
[2018-12-06 16:30:33,485] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT MAX(id) FROM user1
[2018-12-06 16:30:33,485] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT MAX(id) FROM user2
Max user id: 10

[2018-12-06 16:30:33,505] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,505] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user WHERE id = 8
[2018-12-06 16:30:33,506] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=EQUAL, positionValueMap={0=8}, positionIndexMap={})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 16:30:33,506] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user0 WHERE id = 8
User(id=8): {id=8, username=User8}

[2018-12-06 16:30:33,511] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,511] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user WHERE id <= 3
[2018-12-06 16:30:33,512] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 16:30:33,512] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user0 WHERE id <= 3
[2018-12-06 16:30:33,512] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user1 WHERE id <= 3
[2018-12-06 16:30:33,512] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user2 WHERE id <= 3
[2018-12-06 16:30:33,513] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user0 WHERE id <= 3
[2018-12-06 16:30:33,513] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user1 WHERE id <= 3
[2018-12-06 16:30:33,513] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds1 ::: SELECT * FROM user2 WHERE id <= 3
Users(id<=3): [{id=1, username=User1}, {id=2, username=User2}, {id=3, username=User3}]

[2018-12-06 16:30:33,529] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Rule Type: sharding
[2018-12-06 16:30:33,531] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Logic SQL: SELECT * FROM user WHERE id IN (1,3,5)
[2018-12-06 16:30:33,532] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] SQLStatement: SelectStatement(super=DQLStatement(super=AbstractSQLStatement(type=DQL, tables=Tables(tables=[Table(name=user, alias=Optional.absent())]), conditions=Conditions(orCondition=OrCondition(andConditions=[AndCondition(conditions=[Condition(column=Column(name=id, tableName=user), operator=IN, positionValueMap={0=1, 1=3, 2=5}, positionIndexMap={})])])), sqlTokens=[TableToken(skippedSchemaNameLength=0, originalLiterals=user)], parametersIndex=0)), containStar=true, selectListLastPosition=9, groupByLastPosition=0, items=[StarSelectItem(owner=Optional.absent())], groupByItems=[], orderByItems=[], limit=null, subQueryStatement=null)
[2018-12-06 16:30:33,532] [INFO] [Sharding-Sphere-SQL SQLLogger.java:71] [main] Actual SQL: ds0 ::: SELECT * FROM user0 WHERE id IN (1,3,5)
Users(id IN (1,3,5)): [{id=1, username=User1}, {id=3, username=User3}, {id=5, username=User5}]
```

文章首发: [https://baijifeilong.github.io/2018/11/26/sharding-jdbc](https://baijifeilong.github.io/2018/11/26/sharding-jdbc)
