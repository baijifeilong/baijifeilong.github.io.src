---
title: SpringAOP大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - AOP
  - Spring
  - AspectJ
date: 2018-12-10 21:00:44
---

# SpringAOP大杂烩

## 示例代码

*App.java*
```java
package bj.demo;

import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import javax.annotation.Nonnull;
import javax.annotation.Resource;

@SpringBootApplication
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Resource
    private ApplicationContext applicationContext;

    @Override
    public void onApplicationEvent(@Nonnull ApplicationReadyEvent applicationReadyEvent) {
        applicationContext.getBean(Google.class).google();
    }


    @Aspect
    @Component
    public static class MyAspect {
        @Before("execution(public void App.Google.google())")
        public void doBefore() {
            System.out.println("Before....");
        }

        @After("execution(public void App.Google.google())")
        public void doAfter() {
            System.out.println("After...");
        }
    }

    @Component
    public static class Google {
        public void google() {
            System.out.println("googling");
        }
    }
}

```

注意:

- AspectJ只能拦截Spring容器创建的对象，自己new出来的不行，代理不了

<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
