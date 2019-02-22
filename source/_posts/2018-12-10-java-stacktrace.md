---
title: Stacktrace
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Stacktrace
  - Exception
date: 2018-12-10 20:18:06
---

# Stacktrace

Java可以通过`Thread.getAllStackTraces()`方法获取当前应用各线程的栈追踪

<!--more-->

## 示例代码

```java
package bj;

import java.util.Comparator;
import java.util.Map;
import java.util.stream.Stream;

class App {
    public static void main(String[] args) {
        Map<Thread, StackTraceElement[]> allStackTraces = Thread.getAllStackTraces();
        System.out.printf("All threads %d, active %d\n", allStackTraces.size(), Thread.activeCount());
        allStackTraces.entrySet().stream().sorted(Comparator.comparing($ -> $.getKey().getId())).forEach(entry -> {
            System.out.printf("[%d] %s\n", entry.getKey().getId(), entry.getKey().getName());
            Stream.of(entry.getValue()).forEach($ -> System.out.printf("\t%s\n", $));
        });
    }
}
```

## 控制台输出

```log
All threads 4, active 1
[1] main
	java.lang.Thread.dumpThreads(Native Method)
	java.lang.Thread.getAllStackTraces(Thread.java:1610)
	bj.App.main(App.java:9)
[2] Reference Handler
	java.lang.Object.wait(Native Method)
	java.lang.Object.wait(Object.java:502)
	java.lang.ref.Reference.tryHandlePending(Reference.java:191)
	java.lang.ref.Reference$ReferenceHandler.run(Reference.java:153)
[3] Finalizer
	java.lang.Object.wait(Native Method)
	java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:144)
	java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:165)
	java.lang.ref.Finalizer$FinalizerThread.run(Finalizer.java:216)
[4] Signal Dispatcher
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
