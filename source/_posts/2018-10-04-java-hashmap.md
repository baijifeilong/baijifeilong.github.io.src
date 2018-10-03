---
title: Java之HashMap大杂烩 
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Dictionary
date: 2018-10-04 00:18:53
---

据说哈希不均匀会影响HashMap的性能，以下为测试代码

## 代码

```java
package bj;

import java.util.HashMap;
import java.util.Map;

class App {
    public static void main(String[] args) {
        Map<A, A> mapA = new HashMap<>();
        Map<B, B> mapB = new HashMap<>();
        for (int i = 1; i <= 50000; ++i) {
            A a = new A();
            B b = new B();
            mapA.put(a, a);
            mapB.put(b, b);
            if (i % 100 == 0) {
                System.out.print(".");
            }
            if (i % 10000 == 0) {
                System.out.println();
            }
        }


        long beforeA = System.currentTimeMillis();
        mapA.containsKey(new A());
        long afterA = System.currentTimeMillis();

        long beforeB = System.currentTimeMillis();
        mapB.containsKey(new B());
        long afterB = System.currentTimeMillis();

        System.out.printf("A used %d millis\n", afterA - beforeA);
        System.out.printf("B used %d millis\n", afterB - beforeB);
    }
}

class A implements Comparable<A> {
    @Override
    public int hashCode() {
        return 0;
    }

    @Override
    public int compareTo(A o) {
        return 0;
    }
}

class B {
}
```

## 输出

```
....................................................................................................
....................................................................................................
....................................................................................................
....................................................................................................
....................................................................................................
A used 5 millis
B used 0 millis
```
