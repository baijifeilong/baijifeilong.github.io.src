---
title: Java之Servlet大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Servlet
  - Thread
  - Concurrent
date: 2018-10-04 00:25:12
---

Servlet线程不安全，以下为测试代码

## 代码

```java
package bj;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationListener;
import org.springframework.core.env.Environment;
import org.springframework.util.MimeTypeUtils;
import org.springframework.web.client.RestTemplate;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Random;
import java.util.stream.IntStream;

@SuppressWarnings("SpringJavaAutowiredFieldsWarningInspection")
@SpringBootApplication(exclude = DispatcherServletAutoConfiguration.class)
class App extends HttpServlet implements ApplicationListener<ApplicationReadyEvent> {

    @Autowired
    private ApplicationContext applicationContext;

    private RestTemplate restTemplate = new RestTemplate();

    private ObjectMapper objectMapper = new ObjectMapper();

    private Random random = new Random();

    private int id;

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            this.doService(req, resp);
        } catch (InterruptedException e) {
            System.exit(-1);
        }
    }

    private void doService(HttpServletRequest req, HttpServletResponse resp) throws IOException, InterruptedException {
        id = Integer.parseInt(req.getParameter("id"));
        Thread.sleep(random.nextInt(100));
        resp.setContentType(MimeTypeUtils.APPLICATION_JSON_VALUE);
        resp.getWriter().write(objectMapper.writeValueAsString(new HashMap<String, Object>() {{
            this.put("id", id);
            this.put("thread", Thread.currentThread().getName());
        }}));
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        try {
            this.doReady();
        } catch (UnknownHostException e) {
            System.exit(-1);
        }
    }

    private void doReady() throws UnknownHostException {
        String ip = InetAddress.getLocalHost().getHostAddress();
        int port = applicationContext.getBean(Environment.class).getProperty("server.port", Integer.class, 8080);
        String url = String.format("http://%s:%d", ip, port);

        IntStream.rangeClosed(1, 30).parallel().forEach($ -> {
            JsonNode result = restTemplate.getForObject(url + "?id={id}", JsonNode.class, $);
            assert result != null;
            int serverId = result.get("id").asInt();
            String serverThread = result.get("thread").asText();
            System.out.printf("%-32s%4d => %-4d%-10s%s\n", Thread.currentThread().getName(), $, serverId, serverId == $, serverThread);
        });
    }
}
```

<!--more-->

## 输出

```
ForkJoinPool.commonPool-worker-3   5 => 28  false     http-nio-8080-exec-2
ForkJoinPool.commonPool-worker-1  10 => 28  false     http-nio-8080-exec-3
ForkJoinPool.commonPool-worker-6   2 => 28  false     http-nio-8080-exec-4
ForkJoinPool.commonPool-worker-7   9 => 11  false     http-nio-8080-exec-5
main                              20 => 8   false     http-nio-8080-exec-1
ForkJoinPool.commonPool-worker-4  25 => 19  false     http-nio-8080-exec-8
ForkJoinPool.commonPool-worker-2  28 => 26  false     http-nio-8080-exec-6
ForkJoinPool.commonPool-worker-5  14 => 27  false     http-nio-8080-exec-7
ForkJoinPool.commonPool-worker-2  27 => 15  false     http-nio-8080-exec-1
ForkJoinPool.commonPool-worker-3   4 => 30  false     http-nio-8080-exec-3
ForkJoinPool.commonPool-worker-3   7 => 7   true      http-nio-8080-exec-7
ForkJoinPool.commonPool-worker-6   3 => 6   false     http-nio-8080-exec-9
ForkJoinPool.commonPool-worker-7   8 => 1   false     http-nio-8080-exec-2
ForkJoinPool.commonPool-worker-1  11 => 29  false     http-nio-8080-exec-10
main                              19 => 29  false     http-nio-8080-exec-4
ForkJoinPool.commonPool-worker-4  26 => 22  false     http-nio-8080-exec-5
ForkJoinPool.commonPool-worker-5  15 => 17  false     http-nio-8080-exec-8
ForkJoinPool.commonPool-worker-2  30 => 17  false     http-nio-8080-exec-6
ForkJoinPool.commonPool-worker-6   1 => 17  false     http-nio-8080-exec-3
ForkJoinPool.commonPool-worker-3   6 => 21  false     http-nio-8080-exec-1
ForkJoinPool.commonPool-worker-4  17 => 12  false     http-nio-8080-exec-10
main                              22 => 12  false     http-nio-8080-exec-2
ForkJoinPool.commonPool-worker-4  18 => 16  false     http-nio-8080-exec-3
main                              16 => 16  true      http-nio-8080-exec-1
ForkJoinPool.commonPool-worker-6  21 => 16  false     http-nio-8080-exec-8
ForkJoinPool.commonPool-worker-1  24 => 16  false     http-nio-8080-exec-9
ForkJoinPool.commonPool-worker-3  12 => 16  false     http-nio-8080-exec-6
ForkJoinPool.commonPool-worker-5  13 => 16  false     http-nio-8080-exec-4
ForkJoinPool.commonPool-worker-7  29 => 16  false     http-nio-8080-exec-7
ForkJoinPool.commonPool-worker-2  23 => 16  false     http-nio-8080-exec-5

```
