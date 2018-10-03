---
title: java-reflection
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
date: 2018-10-04 00:42:14
---

Java动态编程有两种实现方式，一种是reflect包中的反射，另一种使invoke包中的方法句柄。
以下为示例代码

```java
package bj;

import java.awt.*;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.MethodType;

class App {
    public static void main(String[] var0) throws Throwable {
        System.out.println(MethodHandles.lookup().findVirtual(Object.class, "toString", MethodType.methodType(String.class)).invoke(new Point()));
        System.out.println(Object.class.getMethod("toString").invoke(new Point()));
    }
}
```

**输出**

```
java.awt.Point[x=0,y=0]
java.awt.Point[x=0,y=0]

```
