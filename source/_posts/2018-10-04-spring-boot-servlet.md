---
title: 在SpringBoot中使用Servlet
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - Servlet
  - SpringBoot
date: 2018-10-04 00:32:57
---

## 1. 替换org.springframework.web.servlet.DispatcherServlet

```java
package bj;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@SpringBootApplication(exclude = DispatcherServletAutoConfiguration.class)
class App extends HttpServlet {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.getWriter().write("hello " + req.getRequestURL());
    }
}
```

## 2. 与org.springframework.web.servlet.DispatcherServlet并存

```java
import org.springframework.boot.web.servlet.ServletRegistrationBean;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@SpringBootApplication
class App implements BeanDefinitionRegistryPostProcessor {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
        registry.registerBeanDefinition("myServlet", new RootBeanDefinition(ServletRegistrationBean.class,
                () -> new ServletRegistrationBean<>(new HttpServlet() {
                    @Override
                    protected void service(HttpServletRequest req, HttpServletResponse resp) throws IOException {
                        resp.getWriter().write("hello world");
                    }
                }, "/foo/*")));
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
    }
}
```
