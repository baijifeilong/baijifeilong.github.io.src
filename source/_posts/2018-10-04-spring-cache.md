---
title: SpringCache大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - SpringBoot
  - SpringCache
  - Cache
date: 2018-10-04 01:20:00
---

# SpringCache大杂烩

## 示例代码

**App.java**

```java
package bj;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Service;

@SpringBootApplication
@EnableCaching
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        new SpringApplicationBuilder(App.class).web(WebApplicationType.NONE).run(args);
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println(foo());
        System.out.println(foo());
        System.out.println(foo());
        System.out.println(barService.bar());
        System.out.println(barService.bar());
        System.out.println(barService.bar());
    }


    @Cacheable("foo")
    public String foo() {
        System.out.println(String.format("%s: I am foo", this));
        return "FOO";
    }

    @Autowired
    private BarService barService;

    @Service
    public static class BarService {
        @Cacheable("bar")
        public String bar() {
            System.out.println(String.format("%s: I am bar", this));
            return "BAR";
        }
    }
}
```

**输出**

```
bj.App$$EnhancerBySpringCGLIB$$cadd77f2@4df5bcb4: I am foo
FOO
bj.App$$EnhancerBySpringCGLIB$$cadd77f2@4df5bcb4: I am foo
FOO
bj.App$$EnhancerBySpringCGLIB$$cadd77f2@4df5bcb4: I am foo
FOO
bj.App$BarService@5c00384f: I am bar
BAR
BAR
BAR
```

使用@EnableCaching开启Spring的缓存功能。在需要缓存的函数上注解@Cacheable("<name>")。

`App`类下的函数不能直接缓存。Controller下的函数需要有@RequestMapping才能缓存。缓存需要在@Cacheable中配置name，或者在class上注解@CacheConfig，让method使用同样的name

## 缓存失效

**App.kt**

```kotlin
package bj

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.cache.annotation.CacheEvict
import org.springframework.cache.annotation.Cacheable
import org.springframework.cache.annotation.EnableCaching
import org.springframework.context.ApplicationListener
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.web.bind.annotation.RestController
import java.util.concurrent.TimeUnit
import javax.annotation.Resource

@SpringBootApplication
@RestController
@EnableCaching
@EnableScheduling
class App : ApplicationListener<ApplicationReadyEvent> {
    override fun onApplicationEvent(event: ApplicationReadyEvent?) {
        TimeUnit.MILLISECONDS.sleep(400)
        sky.hello()
        TimeUnit.MILLISECONDS.sleep(400)
        sky.hello()
        TimeUnit.MILLISECONDS.sleep(400)
        sky.hello()
        TimeUnit.MILLISECONDS.sleep(400)
        sky.hello()
        TimeUnit.MILLISECONDS.sleep(400)
        sky.hello()
    }

    @Resource
    private lateinit var sky: Sky;

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }
}


@Component
class Sky {
    @Cacheable("hello")
    fun hello() {
        println("hello")
    }

    @CacheEvict("hello")
    @Scheduled(fixedDelay = 1000)
    fun evictHello() = println("Clearing cache for hello")
}
```

## 使用其他的缓存实现

SpringBoot默认的缓存实现是`org.springframework.cache.concurrent.ConcurrentMapCacheManager`。这是个内存缓存，而且不支持超时设定。换用其他缓存实现有两种方法:

### 方法一 Spring自动配置

引入`SpringBootStarterCache`和其他缓存实现后，SpringBoot会自动寻找并配置相应的缓存实现

例:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>

<dependency>
    <groupId>com.github.ben-manes.caffeine</groupId>
    <artifactId>caffeine</artifactId>
</dependency>
```

### 方法二 自定义CacheManager

例(使用CaffeineCache并设置1秒的生存时间):

```java
package bj.cache;

import com.github.benmanes.caffeine.cache.CaffeineSpec;
import io.vavr.control.Try;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/11 下午8:41
 */
@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
@EnableCaching
public class CacheApp implements ApplicationListener<ApplicationReadyEvent> {

    public static void main(String[] args) {
        SpringApplication.run(CacheApp.class, args);
    }

    @Resource
    private Inner inner;

    @Resource
    private CacheManager cacheManager;

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println("CacheManager: " + cacheManager.getClass().getSuperclass());

        System.out.println("First fetching...");
        inner.hi();
        Try.run(() -> Thread.sleep(1000));
        System.out.println("Second fetching after 1000 millis...");
        inner.hi();
        System.out.println("Third fetching...");
        inner.hi();
    }

    @Component
    static class Inner {
        @Cacheable("hi")
        public String hi() {
            System.out.println("hi");
            return "hi";
        }
    }

    @Bean
    public CacheManager cacheManager() {
        return new CaffeineCacheManager() {{
            this.setCaffeineSpec(CaffeineSpec.parse("expireAfterWrite=1s"));
        }};
    }
}
```

控制台输出:

```log

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2018-12-11 21:40:04.930  INFO 28595 --- [           main] bj.cache.CacheApp                        : Starting CacheApp on MacBook-Air-2.local with PID 28595 (/Users/yuchao/temp/java/hellomaven/target/classes started by yuchao in /Users/yuchao/temp/java/hellomaven)
2018-12-11 21:40:04.940  INFO 28595 --- [           main] bj.cache.CacheApp                        : No active profile set, falling back to default profiles: default
2018-12-11 21:40:08.261  WARN 28595 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default LoopResources: DefaultLoopResources {prefix=reactor-http, daemon=true, selectCount=4, workerCount=4}
2018-12-11 21:40:08.263  WARN 28595 --- [           main] reactor.netty.tcp.TcpResources           : [http] resources will use the default ConnectionProvider: PooledConnectionProvider {name=http, poolFactory=reactor.netty.resources.ConnectionProvider$$Lambda$287/1238994373@22d6cac2}
2018-12-11 21:40:08.445  INFO 28595 --- [           main] bj.cache.CacheApp                        : Started CacheApp in 4.751 seconds (JVM running for 6.37)
CacheManager: class org.springframework.cache.caffeine.CaffeineCacheManager
First fetching...
hi
Second fetching after 1000 millis...
hi
Third fetching...
```

## 不同的Cache设置不同的超时时间

需要使用`SimpleCacheManager`的`setCaches`方法

```java
@Bean
public CacheManager cacheManager() {
    List<CaffeineCache> cacheList = Stream.of(
            Triple.of("hello", 10, 100),
            Triple.of("hi", 1, 100)
    ).map($ -> new CaffeineCache($.getLeft(), Caffeine.newBuilder().recordStats()
            .expireAfterWrite($.getMiddle(), TimeUnit.SECONDS).maximumSize($.getRight()).build()))
            .collect(Collectors.toList());
    return new SimpleCacheManager() {{
        this.setCaches(cacheList);
    }};
}
```
