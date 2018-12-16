---
title: Java对象工具类
categories:
  - Programming
tags:
  - Programming
date: 2018-12-12 17:34:43
---

# Java对象工具类

在Java开发中，处理对象的时候，经常会发现一些自己感觉很基础的功能，JDK不提供，第三方也找不到，只能自己开发。

<!--more-->

## 对象转字典

### Java代码

```java
package bj; 
import io.vavr.control.Try;

import java.awt.*;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.*;
import java.util.List;
import java.util.function.Function;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/11/1 下午4:03
 */
public class MyBeanUtils {

    public static Map<String, Object> objectToMap(Object object) {
        List<Field> fields = new ArrayList<>();
        Class clazz = object.getClass();
        while (clazz != null) {
            fields.addAll(Arrays.asList(clazz.getDeclaredFields()));
            clazz = clazz.getSuperclass();
        }

        return fields.stream()
                .peek($ -> $.setAccessible(true))
                .filter($ -> !$.isSynthetic())
                .filter($ -> !Modifier.isStatic($.getModifiers()))
                .collect(HashMap::new, (stringObjectHashMap, field) -> stringObjectHashMap.put(field.getName(), Try.of(() -> field.get(object)).getOrElseThrow((Function<Throwable, RuntimeException>) RuntimeException::new)), HashMap::putAll);
    }

    public static void main(String[] args) {
        System.out.println(objectToMap(new Color(22, 144, 100) {{
        }}));
    }
}
```

### 控制台输出

```log
{falpha=0.0, cs=null, fvalue=null, frgbvalue=null, value=-15298460}
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
