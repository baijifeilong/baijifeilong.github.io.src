---
title: Java字符串连接
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - String
  - Benchmark
date: 2018-12-10 20:21:40
---

# Java字符串连接

Java字符串连接，常用的类有`StringBuffer`和`StringBuilder`。StringBuilder非线程安全，运行效率更高

<!--more-->

## 示例代码

```java
package bj;

import org.springframework.util.StopWatch;

import java.lang.reflect.Field;
import java.util.stream.Stream;

@SuppressWarnings({"StringBufferMayBeStringBuilder", "unused", "MismatchedQueryAndUpdateOfStringBuilder", "StringConcatenationInLoop"})
class App {
    public static void main(String[] args) throws NoSuchFieldException, IllegalAccessException {
        String a = "";
        StringBuffer b = new StringBuffer();
        StringBuilder c = new StringBuilder();

        StopWatch stopWatch = new StopWatch("String concatenation");

        stopWatch.start("+");
        for (int i = 0; i < 10000; ++i) {
            a += i;
        }
        stopWatch.stop();

        stopWatch.start("StringBuffer");
        for (int i = 0; i < 10000000; ++i) {
            b.append(i);
        }
        stopWatch.stop();

        stopWatch.start("StringBuilder");
        for (int i = 0; i < 10000000; ++i) {
            c.append(i);
        }
        stopWatch.stop();

        for (StopWatch.TaskInfo taskInfo : stopWatch.getTaskInfo()) {
            if (taskInfo.getTaskName().equals("+")) {
                Field timeMillis = StopWatch.TaskInfo.class.getDeclaredField("timeMillis");
                timeMillis.setAccessible(true);
                long millis = (long) timeMillis.get(taskInfo);
                timeMillis.set(taskInfo, millis * 1000);
            }
        }

        Field totalTimeMillis = stopWatch.getClass().getDeclaredField("totalTimeMillis");
        totalTimeMillis.setAccessible(true);
        totalTimeMillis.set(stopWatch, Stream.of(stopWatch.getTaskInfo()).mapToLong(StopWatch.TaskInfo::getTimeMillis).sum());

        System.out.println(stopWatch.prettyPrint());
    }
}
```

## 控制台输出

```log
StopWatch 'String concatenation': running time (millis) = 361027
-----------------------------------------
ms     %     Task name
-----------------------------------------
360000  100%  +
00636  000%  StringBuffer
00391  000%  StringBuilder
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
