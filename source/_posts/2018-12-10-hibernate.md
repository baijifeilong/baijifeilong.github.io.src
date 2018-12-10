---
title: Hibernate大杂烩
categories:
  - Programming
tags:
  - Programming
date: 2018-12-10 20:56:48
---

# Hibernate大杂烩

## SpringBoot集成Hibernate

*App.java*

```java
package bj.demo;

import org.hibernate.SessionFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;

import javax.annotation.Nonnull;
import javax.annotation.Resource;
import javax.persistence.EntityManagerFactory;
import java.util.List;

@SpringBootApplication
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Resource
    private
    EntityManagerFactory entityManagerFactory;

    @Override
    public void onApplicationEvent(@Nonnull ApplicationReadyEvent applicationReadyEvent) {
        SessionFactory sessionFactory = entityManagerFactory.unwrap(SessionFactory.class);
        List<Animal> animals = sessionFactory.openSession().createQuery("FROM bj.demo.Animal", Animal.class).list();
        System.out.println(animals);
    }
}
```

- 需要依赖spring-boot-starter-data-jpa
- Animal类需要注解@Entity

<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
