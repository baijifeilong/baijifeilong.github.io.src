---
title: java-observable
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
date: 2018-10-04 00:47:23
---

Java Observable 示例

```java
package bj;

import java.util.Observable;
import java.util.stream.IntStream;
import java.util.stream.Stream;

class App {
    public static void main(String[] var0) throws Throwable {
        new Observable() {{
            IntStream.rangeClosed(1, 3).forEach($ -> this.addObserver((o, arg) -> System.out.println("updated received by " + $)));
            Stream.generate(() -> null).limit(3).forEach($ -> {
                        this.clearChanged();
                        this.setChanged();
                        this.notifyObservers();
                    }
            );
        }};
    }
}
```

输出:

```
updated received by 3
updated received by 2
updated received by 1
updated received by 3
updated received by 2
updated received by 1
updated received by 3
updated received by 2
updated received by 1
```
