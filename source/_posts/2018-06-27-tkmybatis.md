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

以Maven为例
```xml
<dependency>
    <groupId>tk.mybatis</groupId>
    <artifactId>mapper-spring-boot-starter</artifactId>
    <version>2.1.2</version>
</dependency>

<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.2</version>
</dependency>
```

注意:

- lombok最好用1.18.2版本，太老的话不支持`@FieldNameConstants`注解，太新的话IDEA插件不支持

## 3. 基本用法

1. 创建模型类(不需要Entity注解)
2. 创建Mapper接口，并继承tk.mybatis.mapper.common.Mapper<TheModel>(不需要注解)
3. 注册Mapper 通过MapperScan(tk包非MyBatis包)注解来注册全部的Mapper

示例：

<!--more-->

```java
`package bj.tkmybatis;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import com.zaxxer.hikari.HikariDataSource;
import lombok.Data;
import lombok.experimental.FieldNameConstants;
import org.apache.ibatis.annotations.Select;
import org.slf4j.LoggerFactory;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import tk.mybatis.mapper.entity.Example;

import javax.annotation.Resource;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.sql.DataSource;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/25 上午9:55
 */
@SpringBootApplication
@tk.mybatis.spring.annotation.MapperScan(basePackageClasses = App.class)
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        new SpringApplicationBuilder(App.class).web(WebApplicationType.NONE).run(args);
    }

    @Resource
    private UserMapper userMapper;

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Override
    public void onApplicationEvent(@NotNull ApplicationReadyEvent event) {
        ((Logger) LoggerFactory.getLogger(App.class.getPackage().getName())).setLevel(Level.DEBUG);

        jdbcTemplate.execute("DROP TABLE IF EXISTS user");
        jdbcTemplate.execute("CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(16) DEFAULT 'DeFaUlT', real_name VARCHAR(16)) DEFAULT CHARSET utf8");

        User alpha = new User() {{
            setUsername("alpha");
            setRealName("阿尔法");
        }};
        userMapper.insertSelective(alpha);

        User beta = new User() {{
            setUsername("beta");
            setRealName("贝塔");
        }};
        userMapper.insertSelective(beta);

        User gamma = new User() {{
            setUsername("gamma");
        }};
        userMapper.insertSelective(gamma);

        User theta = new User();
        userMapper.insertSelective(theta);

        System.out.println("Inserted alpha:");
        System.out.println(alpha);
        System.out.println("Inserted beta:");
        System.out.println(beta);
        System.out.println("Inserted gamma:");
        System.out.println(gamma);
        System.out.println("Inserted theta:");
        System.out.println(theta);
        System.out.println("Select by primary key");
        System.out.println(userMapper.selectByPrimaryKey(1));
        System.out.println("selectAll:");
        System.out.println(userMapper.selectAll());
        System.out.println("mySelectAll:");
        System.out.println(userMapper.myFindAll());

        System.out.println("Real name is null:");
        List<User> id = userMapper.selectByExample(new Example(User.class) {{
            createCriteria().andIsNull(User.FIELD_REAL_NAME);
        }});
        System.out.println(id);
    }

    @Bean
    public DataSource dataSource() {
        return new HikariDataSource() {{
            setJdbcUrl("jdbc:mysql://localhost/foo?useSSL=false&characterEncoding=utf8");
            setUsername("root");
            setPassword("root");
        }};
    }

    @FieldNameConstants
    class X {
        private int aaa;
    }
}

@Data
@FieldNameConstants
class User {

    @Id
    @GeneratedValue(generator = "JDBC")
    private Integer id;

    private String username;

    private String realName;
}

interface UserMapper extends tk.mybatis.mapper.common.Mapper<User> {
    @Select("SELECT * FROM user")
    List<User> myFindAll();
}
``

### 示例输出

```log
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-25 10:11:54.745  INFO 37343 --- [           main] bj.tkmybatis.App                         : Starting App on MacBook-Air-2.local with PID 37343 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-25 10:11:54.792  INFO 37343 --- [           main] bj.tkmybatis.App                         : No active profile set, falling back to default profiles: default
2018-12-25 10:11:56.829  WARN 37343 --- [           main] o.m.s.mapper.ClassPathMapperScanner      : No MyBatis mapper was found in '[bj.tkmybatis]' package. Please check your configuration.
2018-12-25 10:11:56.918  INFO 37343 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Multiple Spring Data modules found, entering strict repository configuration mode!
2018-12-25 10:11:56.924  INFO 37343 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data repositories in DEFAULT mode.
2018-12-25 10:11:57.065  INFO 37343 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 90ms. Found 0 repository interfaces.
2018-12-25 10:11:58.997  INFO 37343 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear tk.mybatis.mapper.util.MsUtil CLASS_CACHE cache.
2018-12-25 10:11:58.999  INFO 37343 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear tk.mybatis.mapper.genid.GenIdUtil CACHE cache.
2018-12-25 10:11:59.000  INFO 37343 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear tk.mybatis.mapper.version.VersionUtil CACHE cache.
2018-12-25 10:11:59.004  INFO 37343 --- [           main] t.m.m.autoconfigure.MapperCacheDisabler  : Clear EntityHelper entityTableMap cache.
2018-12-25 10:11:59.912  INFO 37343 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2018-12-25 10:12:00.060  INFO 37343 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2018-12-25 10:12:00.627  INFO 37343 --- [           main] bj.tkmybatis.App                         : Started App in 7.205 seconds (JVM running for 9.92)
2018-12-25 10:12:00.775 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==>  Preparing: INSERT INTO user ( id,username,real_name ) VALUES( ?,?,? ) 
2018-12-25 10:12:00.795 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==> Parameters: null, alpha(String), 阿尔法(String)
2018-12-25 10:12:00.801 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : <==    Updates: 1
2018-12-25 10:12:00.819 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==>  Preparing: INSERT INTO user ( id,username,real_name ) VALUES( ?,?,? ) 
2018-12-25 10:12:00.819 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==> Parameters: null, beta(String), 贝塔(String)
2018-12-25 10:12:00.822 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : <==    Updates: 1
2018-12-25 10:12:00.823 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==>  Preparing: INSERT INTO user ( id,username ) VALUES( ?,? ) 
2018-12-25 10:12:00.824 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==> Parameters: null, gamma(String)
2018-12-25 10:12:00.827 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : <==    Updates: 1
2018-12-25 10:12:00.837 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==>  Preparing: INSERT INTO user ( id ) VALUES( ? ) 
2018-12-25 10:12:00.838 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : ==> Parameters: null
2018-12-25 10:12:00.840 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.insertSelective  : <==    Updates: 1
Inserted alpha:
User(id=1, username=alpha, realName=阿尔法)
Inserted beta:
User(id=2, username=beta, realName=贝塔)
Inserted gamma:
User(id=3, username=gamma, realName=null)
Inserted theta:
User(id=4, username=null, realName=null)
Select by primary key
2018-12-25 10:12:00.851 DEBUG 37343 --- [           main] b.t.UserMapper.selectByPrimaryKey        : ==>  Preparing: SELECT id,username,real_name FROM user WHERE id = ? 
2018-12-25 10:12:00.852 DEBUG 37343 --- [           main] b.t.UserMapper.selectByPrimaryKey        : ==> Parameters: 1(Integer)
2018-12-25 10:12:00.865 DEBUG 37343 --- [           main] b.t.UserMapper.selectByPrimaryKey        : <==      Total: 1
User(id=1, username=alpha, realName=阿尔法)
selectAll:
2018-12-25 10:12:00.866 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.selectAll        : ==>  Preparing: SELECT id,username,real_name FROM user 
2018-12-25 10:12:00.866 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.selectAll        : ==> Parameters: 
2018-12-25 10:12:00.868 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.selectAll        : <==      Total: 4
[User(id=1, username=alpha, realName=阿尔法), User(id=2, username=beta, realName=贝塔), User(id=3, username=gamma, realName=null), User(id=4, username=DeFaUlT, realName=null)]
mySelectAll:
2018-12-25 10:12:00.869 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.myFindAll        : ==>  Preparing: SELECT * FROM user 
2018-12-25 10:12:00.869 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.myFindAll        : ==> Parameters: 
2018-12-25 10:12:00.872 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.myFindAll        : <==      Total: 4
[User(id=1, username=alpha, realName=null), User(id=2, username=beta, realName=null), User(id=3, username=gamma, realName=null), User(id=4, username=DeFaUlT, realName=null)]
Real name is null:
2018-12-25 10:12:00.888 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.selectByExample  : ==>  Preparing: SELECT id,username,real_name FROM user WHERE ( ( real_name is null ) ) 
2018-12-25 10:12:00.889 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.selectByExample  : ==> Parameters: 
2018-12-25 10:12:00.890 DEBUG 37343 --- [           main] bj.tkmybatis.UserMapper.selectByExample  : <==      Total: 2
[User(id=3, username=gamma, realName=null), User(id=4, username=DeFaUlT, realName=null)]
2018-12-25 10:12:00.949  INFO 37343 --- [      Thread-17] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2018-12-25 10:12:00.975  INFO 37343 --- [      Thread-17] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
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

