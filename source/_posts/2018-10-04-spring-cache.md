---
title: SpringCache示例
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
date: 2018-10-04 01:20:00
---

## Demo

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
