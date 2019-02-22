---
title: 过滤器VS拦截器
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Filter
  - VS
  - Interceptor
date: 2018-12-10 21:09:38
---

# 过滤器VS拦截器

## 示例代码

```java
package bj.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/4/21 13:52
 */
@SpringBootApplication
@RestController
public class DemoApp implements Filter, WebMvcConfigurer, HandlerInterceptor {
    public static void main(String[] args) {
        SpringApplication.run(DemoApp.class, args);
    }

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println(">>> Filter");
        chain.doFilter(request, response);
        System.out.println("<<< Filter Over");
    }

    @Override
    public void destroy() {
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(this);
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        System.out.println(">>> Intercept");
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        System.out.println("<<< Intercept over");
    }

    @GetMapping("/")
    public Object index() {
        System.out.println("==> Executing ...");
        return System.getenv().entrySet().stream()
            .filter(x -> x.getValue().length() < 15)
            .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
    }
}
```

**执行结果**

```
>>> Filter
>>> Intercept
==> Executing ...
<<< Intercept over
<<< Filter Over
```

<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
