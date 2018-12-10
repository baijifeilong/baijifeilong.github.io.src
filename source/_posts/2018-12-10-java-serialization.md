---
title: Java对象序列化
categories:
  - Programming
tags:
  - Programming
date: 2018-12-10 19:43:00
---

# Java对象序列化

对象序列化是将对象转换为字节数组或者字符数组，方便网络传输或存储

要序列化的对象需要实现接口`java.io.Serializable`

Java对象的序列化与反序列化主要使用以下两个方法:

1. `java.io.ObjectOutputStream#writeObject`
2. `java.io.ObjectInputStream#readObject`

<!--more-->

## Java示例代码

```java
package bj;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.io.*;
import java.util.Base64;

class App {
    public static void main(String[] args) throws IOException, ClassNotFoundException {
        User user = new User("foo");
        System.out.println("User: " + user);
        String userString = objToString(user);
        System.out.println("Serialized: " + userString);
        User parsedUser = stringToObj(userString);
        System.out.println("Parsed: " + parsedUser);
    }

    /**
     * 序列化
     *
     * @param t   .
     * @param <T> .
     * @return .
     * @throws IOException .
     */
    private static <T extends Serializable> String objToString(T t) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        new ObjectOutputStream(byteArrayOutputStream).writeObject(t);
        return Base64.getEncoder().encodeToString(byteArrayOutputStream.toByteArray());
    }

    /**
     * 反序列化
     *
     * @param s   .
     * @param <T> .
     * @return .
     * @throws IOException            .
     * @throws ClassNotFoundException .
     */
    @SuppressWarnings("unchecked")
    private static <T> T stringToObj(String s) throws IOException, ClassNotFoundException {
        return (T) new ObjectInputStream(new ByteArrayInputStream(Base64.getDecoder().decode(s))).readObject();
    }

    @Data
    @AllArgsConstructor
    private static class User implements Serializable {
        private String name;
    }
}
```

## 控制台输出

```log
User: App.User(name=foo)
Serialized: rO0ABXNyAAtiai5BcHAkVXNlcqYnZVHZ7jOhAgABTAAEbmFtZXQAEkxqYXZhL2xhbmcvU3RyaW5nO3hwdAADZm9v
Parsed: App.User(name=foo)
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
