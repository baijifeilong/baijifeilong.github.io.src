---
title: SpringBoot配置
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - SpringBoot
date: 2018-12-10 15:38:17
---

SpringBoot可以将配置文件(.properties或.yaml)与实体Bean绑定起来

## 示例配置文件

```yaml
app:
  name: HelloWorld
  version: 1
```

<!--more-->

## 示例Java代码

```java
package bj;

import lombok.Data;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class, QuartzAutoConfiguration.class})
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        new SpringApplication(App.class) {{
            setWebApplicationType(WebApplicationType.NONE);
        }}.run(args);
    }

    @Resource
    private Settings settings;

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println(settings);
    }

    @Component
    @ConfigurationProperties(prefix = "app")
    @Data
    public static class Settings {
        private String name;
        private int version;
    }
}

```

除了将配置类注解为`Component`外，还可以使用注解`@EnableConfigurationProperties(...)`显示指定启用的配置类。用法:

```java
package bj;

import lombok.Data;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.ApplicationListener;

import javax.annotation.Resource;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class, QuartzAutoConfiguration.class})
@EnableConfigurationProperties(App.Settings.class)
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        new SpringApplication(App.class) {{
            setWebApplicationType(WebApplicationType.NONE);
        }}.run(args);
    }

    @Resource
    private Settings settings;

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println(settings);
    }

    @ConfigurationProperties(prefix = "app")
    @Data
    public static class Settings {
        private String name;
        private int version;
    }
}

```

## 示例控制台输出

```log

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-10 15:44:53.585  INFO 4761 --- [           main] bj.App                                   : Starting App on MacBook-Air-2.local with PID 4761 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-10 15:44:53.591  INFO 4761 --- [           main] bj.App                                   : No active profile set, falling back to default profiles: default
2018-12-10 15:44:55.490  WARN 4761 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default LoopResources: DefaultLoopResources {prefix=reactor-http, daemon=true, selectCount=4, workerCount=4}
2018-12-10 15:44:55.492  WARN 4761 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default ConnectionProvider: PooledConnectionProvider {name=http, poolFactory=reactor.netty.resources.ConnectionProvider$$Lambda$270/2128961136@6c44052e}
2018-12-10 15:44:55.770  INFO 4761 --- [           main] bj.App                                   : Started App in 3.103 seconds (JVM running for 4.582)
App.Settings(name=HelloWorld, version=1)
```

## 启用IDE智能提示

Spring自定义配置的IDE提示，需要使用APT技术。因此，需要添加依赖`spring-boot-configuration-processor`。

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

依赖项添加完成后，执行命令`mvn clean build`，智能提示即可生效。APT会生成智能提示所需的JSON文件

**target/classes/META-INF/spring-configuration-metadata.json**

```json
{
  "groups": [
    {
      "name": "app",
      "type": "bj.App$Settings",
      "sourceType": "bj.App$Settings"
    }
  ],
  "properties": [
    {
      "name": "app.name",
      "type": "java.lang.String",
      "sourceType": "bj.App$Settings"
    },
    {
      "name": "app.version",
      "type": "java.lang.Integer",
      "sourceType": "bj.App$Settings",
      "defaultValue": 0
    }
  ],
  "hints": []
}
```

## 多级配置示例

有时候只有List和Map数据类型不能满足配置需求，需要嵌套另一个配置类。示例如下:

### Yaml配置

```yaml
logging:
  level:
    root: info

app:
  name: HelloWorld
  version: 1
  author:
    name: Unname
    age: 88
```

### Java代码

```java
package bj;

import lombok.Data;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class, QuartzAutoConfiguration.class})
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        new SpringApplication(App.class) {{
            setWebApplicationType(WebApplicationType.NONE);
        }}.run(args);
    }

    @Resource
    private Settings settings;

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println(settings);
    }

    @ConfigurationProperties(prefix = "app")
    @Component
    @Data
    public static class Settings {
        private String name;
        private int version;
        @Resource
        private Author author;

        @ConfigurationProperties(prefix = "app.author")
        @Component
        @Data
        public static class Author {
            private String name;
            private String age;
        }
    }
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
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-10 16:01:41.261  INFO 4798 --- [           main] bj.App                                   : Starting App on MacBook-Air-2.local with PID 4798 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-10 16:01:41.267  INFO 4798 --- [           main] bj.App                                   : No active profile set, falling back to default profiles: default
2018-12-10 16:01:43.718  WARN 4798 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default LoopResources: DefaultLoopResources {prefix=reactor-http, daemon=true, selectCount=4, workerCount=4}
2018-12-10 16:01:43.720  WARN 4798 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default ConnectionProvider: PooledConnectionProvider {name=http, poolFactory=reactor.netty.resources.ConnectionProvider$$Lambda$269/828088650@6650813a}
2018-12-10 16:01:44.030  INFO 4798 --- [           main] bj.App                                   : Started App in 3.727 seconds (JVM running for 6.006)
App.Settings(name=HelloWorld, version=1, author=App.Settings.Author(name=Unname, age=88))
```

### 多级配置的简化写法

多级配置，里层可以不用注解，Spring已经做过了处理，因此可以直接写成以下这种形式:

```java
@ConfigurationProperties(prefix = "app")
@Component
@Data
public static class Settings {
    private String name;
    private int version;
    private Author author;

    @Data
    static class Author {
        private String name;
        private String age;
    }
}
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
