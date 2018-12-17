---
title: SpringValidator
categories:
  - Programming
tags:
  - Programming
date: 2018-12-13 15:07:11
---

# SpringValidator

<!--more-->

## 手动触发Validation

注入Validator，调用`javax.validation.Validator#validate`即可

### 示例代码

```java
package bj.valid;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;

import javax.annotation.Resource;
import javax.validation.ConstraintViolation;
import javax.validation.Valid;
import javax.validation.Validator;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import java.util.Collections;
import java.util.List;
import java.util.Set;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/13 下午2:49
 */
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
public class ValidApp implements ApplicationListener<ApplicationReadyEvent> {

    @Data
    @AllArgsConstructor
    static class User {
        private int id;

        @NotEmpty
        private String username;

        @Valid
        private List<Bankcard> bankcards;
    }

    @Data
    @AllArgsConstructor
    private static class Bankcard {
        private int id;

        @NotEmpty
        private String name;
    }

    @Resource
    private Validator validator;

    public static void main(String[] args) {
        SpringApplication.run(ValidApp.class, args);
    }

    @Override
    public void onApplicationEvent(@NotNull ApplicationReadyEvent event) {
        Set<ConstraintViolation<User>> violations = validator.validate(new User(1, "", Collections.singletonList(new Bankcard(1, ""))));
        System.out.println(violations.size());
        violations.forEach(System.out::println);
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

2018-12-13 15:06:08.153  INFO 555 --- [           main] bj.valid.ValidApp                        : Starting ValidApp on MacBook-Air-2.local with PID 555 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-13 15:06:08.161  INFO 555 --- [           main] bj.valid.ValidApp                        : No active profile set, falling back to default profiles: default
2018-12-13 15:06:09.826  INFO 555 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Multiple Spring Data modules found, entering strict repository configuration mode!
2018-12-13 15:06:09.835  INFO 555 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data repositories in DEFAULT mode.
2018-12-13 15:06:09.909  INFO 555 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 34ms. Found 0 repository interfaces.
2018-12-13 15:06:11.584  INFO 555 --- [           main] bj.valid.ValidApp                        : Started ValidApp in 4.916 seconds (JVM running for 7.047)
2
ConstraintViolationImpl{interpolatedMessage='不能为空', propertyPath=bankcards[0].name, rootBeanClass=class bj.valid.ValidApp$User, messageTemplate='{javax.validation.constraints.NotEmpty.message}'}
ConstraintViolationImpl{interpolatedMessage='不能为空', propertyPath=username, rootBeanClass=class bj.valid.ValidApp$User, messageTemplate='{javax.validation.constraints.NotEmpty.message}'}

```

### 要点

- 要对容器中的元素做校验，需要将容器对象注解为`@Valid`


文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
