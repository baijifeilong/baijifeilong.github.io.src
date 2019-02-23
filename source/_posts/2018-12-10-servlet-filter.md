---
title: Servlet过滤器大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Servlet
  - Spring
  - SpringBoot
date: 2018-12-10 21:06:47
---

## 示例代码

**DemoApp.java**
```java
package bj.demo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.filter.logging.LoggingFilter;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/4/21 13:52
 */
@SpringBootApplication
@RestController
public class DemoApp {

    public static void main(String[] args) {
        SpringApplication.run(DemoApp.class, args);
    }

    @Component
    class MyDumpFilter extends LoggingFilter {
        public MyDumpFilter() {
            super(new Builder() {{
                this.requestPrefix(">>> ");
                this.responsePrefix("<<< ");
            }});
        }

        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws IOException, ServletException {
            Logger logger = LoggerFactory.getLogger(LoggingFilter.class);
            HttpServletRequest req = (HttpServletRequest)request;
            String url = req.getMethod() + " " + req.getRequestURI() + "?" + req.getQueryString();
            logger.info(">>>>> " + url + " BEGIN");
            super.doFilter(request, response, filterChain);
            logger.info("<<<<< " + url + " END");
        }
    }

    @GetMapping("/")
    public Object index() {
        System.out.println("==> Executing ...");
        return System.getenv().entrySet().stream()
            .filter(x -> x.getValue().length() < 10)
            .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
    }
}
```
<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
