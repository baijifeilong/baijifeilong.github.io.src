---
title: Java注解大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Annotation
date: 2018-12-10 21:13:05
---

# Java注解大杂烩

## 示例代码

```java
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/4/17 11:15
 */
@App.Rubbish(name = "APP")
public class App {

    @Retention(RetentionPolicy.RUNTIME)
    @interface Rubbish {
        String name();
    }

    public static void main(String[] args) {
        annotation();
    }

    private static void annotation() {
        String name = App.class.getAnnotation(Rubbish.class).name();
        System.out.println("Rubbish name: " + name);
    }
}

```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
