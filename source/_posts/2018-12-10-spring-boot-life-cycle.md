---
title: SpringBoot生命周期
categories:
  - Programming
tags:
  - Programming
date: 2018-12-10 21:08:22
---

# SpringBoot生命周期

**/META-INF/spring.factories**
```
# 必须在这里指明，否则不生效
org.springframework.boot.env.EnvironmentPostProcessor=bj.demo.DemoApp
```

**DemoApp.java**

```java
package bj.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.context.ApplicationListener;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertiesPropertySource;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/4/21 13:52
 */
@SpringBootApplication
@RestController
public class DemoApp implements ApplicationListener<ApplicationReadyEvent>, EnvironmentPostProcessor {
    public static void main(String[] args) {
        SpringApplication.run(DemoApp.class, args);
    }

    @GetMapping("/")
    public Object index() {
        System.out.println("==> Executing ...");
        return System.getenv().entrySet().stream()
            .filter(x -> x.getValue().length() < 15)
            .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
    }

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        System.out.println("Post processing environment ...");
        environment.getPropertySources().addFirst(new PropertiesPropertySource("lorem", new Properties() {{
            // Change the server port to listen
            setProperty("server.port", "1234");
        }}));
    }

    @Override
    public void onApplicationEvent(@NonNull ApplicationReadyEvent event) {
        System.out.println("Ready...");
    }
}
```

<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
