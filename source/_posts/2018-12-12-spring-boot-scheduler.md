---
title: SpringBoot任务调度器
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - SpringBoot
date: 2018-12-12 14:58:33
---

SpringBoot自带了任务调度器，通过注解的方式使用。

启用方式: 在配置类上注解`org.springframework.scheduling.annotation.EnableScheduling`

<!--more-->

## Java示例

```java
package bj.scheduler;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.scheduling.annotation.Schedules;

import java.time.LocalDateTime;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/12 下午2:51
 */
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
@EnableScheduling
@Slf4j
public class SchedulerApp {

    public static void main(String[] args) throws InterruptedException {
        SpringApplication.run(SchedulerApp.class, args);
        Thread.currentThread().join();
    }

    @Schedules({
            @Scheduled(fixedRate = 1000),
            @Scheduled(fixedDelay = 1001),
            @Scheduled(cron = "* * * * * *")
    })
    public void sayHello() {
        log.info("{} Hello", LocalDateTime.now());
    }
}
```

## 要点

- @EnableScheduling 启用任务调度器
- @Schedules 组合多个调度器。多个调度器全部启用。
- @Scheduled 单个调度器的配置
- fixedRate 固定执行频率(毫秒)，不计执行耗时
- fixedDelay 固定执行延迟(毫秒)，表示距离上次执行完毕的时长
- cron CronTab调度格式，第一位表示秒

## 控制台输出

```log

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-12 15:01:00.332  INFO 34660 --- [           main] bj.scheduler.SchedulerApp                : Starting SchedulerApp on MacBook-Air-2.local with PID 34660 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-12 15:01:00.339  INFO 34660 --- [           main] bj.scheduler.SchedulerApp                : No active profile set, falling back to default profiles: default
2018-12-12 15:01:02.395  INFO 34660 --- [           main] o.s.s.c.ThreadPoolTaskScheduler          : Initializing ExecutorService 'taskScheduler'
2018-12-12 15:01:02.496  WARN 34660 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default LoopResources: DefaultLoopResources {prefix=reactor-http, daemon=true, selectCount=4, workerCount=4}
2018-12-12 15:01:02.498  WARN 34660 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default ConnectionProvider: PooledConnectionProvider {name=http, poolFactory=reactor.netty.resources.ConnectionProvider$$Lambda$278/687399269@6594402a}
2018-12-12 15:01:02.707  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:02.707 Hello
2018-12-12 15:01:02.707  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:02.707 Hello
2018-12-12 15:01:02.708  INFO 34660 --- [           main] bj.scheduler.SchedulerApp                : Started SchedulerApp in 3.257 seconds (JVM running for 4.997)
2018-12-12 15:01:03.004  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:03.004 Hello
2018-12-12 15:01:03.704  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:03.704 Hello
2018-12-12 15:01:03.710  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:03.710 Hello
2018-12-12 15:01:04.002  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:04.002 Hello
2018-12-12 15:01:04.702  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:04.702 Hello
2018-12-12 15:01:04.712  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:04.712 Hello
2018-12-12 15:01:05.000  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:05 Hello
2018-12-12 15:01:05.700  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:05.700 Hello
2018-12-12 15:01:05.716  INFO 34660 --- [   scheduling-1] bj.scheduler.SchedulerApp                : 2018-12-12T15:01:05.716 Hello
```


文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
