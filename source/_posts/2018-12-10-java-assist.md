---
title: JavaAssist大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - JavaAssist
  - ByteCode
date: 2018-12-10 21:10:57
---

# JavaAssist大杂烩

## 示例程序

```java
package com.example.springone;

import javassist.*;

import java.lang.reflect.InvocationTargetException;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/4/20 16:32
 */
public class AssistApp {

    public static void main(String[] args) throws CannotCompileException, ClassNotFoundException,
        IllegalAccessException, InstantiationException, NoSuchMethodException, InvocationTargetException {
        ClassPool classPool = ClassPool.getDefault();
        CtClass clazz = classPool.makeClass("bj.Cat");
        clazz.addField(CtField.make("public int id = 10;", clazz));
        clazz.addField(CtField.make("public String name = \"Kitty\";", clazz));
        clazz.addMethod(CtMethod.make("public void hello() {" +
            "System.out.println(\"Hello, I am \" + this.id + \" \" + this.name);" +
            "}", clazz));
        clazz.toClass();

        Object cat = Class.forName("bj.Cat").newInstance();
        cat.getClass().getMethod("hello").invoke(cat);
    }
}

```

<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
