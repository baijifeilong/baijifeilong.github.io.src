---
title: Java线程大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Thread
date: 2018-10-04 00:11:02
---

## 列出当前所有线程

### 代码

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

<!--more-->

### 输出

```
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
