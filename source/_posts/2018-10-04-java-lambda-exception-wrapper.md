---
title: Java之Lambda异常包装器
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Functional
  - Lambda
  - Exception
  - Wrapper
date: 2018-10-04 00:29:23
---

Java中的Lambda一般不处理受检异常，可以写一个异常包装器，将其包裹起来，
免去写Try、Catch

## 示例代码

```java
package bj;

import java.util.function.Consumer;
import java.util.stream.Stream;

class App {
    public static void main(String[] args) {
        Stream.generate(() -> null).limit(10).forEach(Try.of($ -> {
            throw new Exception();
        }));
    }

    interface Try {
        @FunctionalInterface
        interface ConsumerUnchecked<T> {
            void accept(T t) throws Exception;
        }

        static <T> Consumer<T> of(ConsumerUnchecked<T> consumer) {
            return t -> {
                try {
                    consumer.accept(t);
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            };
        }
    }
}


```
