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

ShardingJDBC似乎只支持带有分表键而且查询条件必须是`=`或`IN`的查询。导致像`SELECT MAX(id) FROM user`(查询用户表中的最大ID)这种看似极其简单的查询(每表做一次MAX，中间件做一次归并)也无法进行。

文章首发: [https://baijifeilong.github.io/2018/11/26/sharding-jdbc](https://baijifeilong.github.io/2018/11/26/sharding-jdbc)