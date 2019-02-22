---
title: Java之Wait、Notify
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Thread
  - Concurrent
  - Wait
  - Notify
date: 2018-10-04 00:23:10
---

## 示例代码

```java
package bj;

import java.util.concurrent.Callable;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;
import java.util.stream.Stream;

abstract class App {
    public static void main(String[] args) throws InterruptedException {

        final Object donkey = new Object();

        new Thread(() -> {
            synchronized (donkey) {
                try {
                    System.out.println("我有一头小毛驴，我从来也不骑");
                    while (Boolean.parseBoolean("true")) {
                        System.out.println("谁骑？");
                        donkey.wait();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();

        Executors.newSingleThreadExecutor().invokeAll(Stream.of("万明,李楠,项波".split(",")).map($ -> (Callable<Void>) () -> {
            synchronized (donkey) {
                System.out.printf("%s骑 %s卒\n", $, $);
                donkey.notify();
            }
            return null;
        }).collect(Collectors.toSet()));
    }
}
```

## Example two

```java
abstract class Foo {
    synchronized public static void main(String[] args) throws InterruptedException {
        new Thread(() -> {
            synchronized (Foo.class) {
                System.out.println("Notifying...");
                Foo.class.notify();
            }
        }).start();

        System.out.println("I am waiting");
        Foo.class.wait();
        System.out.println("I am done");
    }
}
```

## 输出

```
我有一头小毛驴，我从来也不骑
谁骑？
万明骑 万明卒
谁骑？
李楠骑 李楠卒
谁骑？
项波骑 项波卒
谁骑？
```
