---
title: Java动态代理
categories:
  - Programming
tags:
  - Programming
date: 2018-12-10 21:14:19
---

# Java动态代理

## 示例代码

```java
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/4/17 11:15
 */
public class App {

    interface HiService {
        String hi(String name);
    }

    public static void main(String[] args) {
        proxy();
    }

    private static void proxy() {
        HiService hiService = (HiService)Proxy.newProxyInstance(
            App.class.getClassLoader(),
            new Class[]{HiService.class},
            new InvocationHandler() {
                @Override
                public Object invoke(Object proxy, Method method, Object[] args) {
                    return "Hi ~ " + args[0];
                }
            });
        String str = hiService.hi("world");
        System.out.println("str = " + str);
    }

}
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
