---
title: Java对象的序列化
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Serialization
date: 2018-10-04 00:17:06
---

## 示例代码

```java
package bj;

import java.io.*;
import java.util.Base64;

class App {
    public static void main(String[] args) throws IOException, ClassNotFoundException {
        System.out.println(App.<User>stringToObj(objToString(new User("foo"))));
        System.out.println(App.<User>stringToObj(objToString(new User("bar"))));
        System.out.println(App.<User>stringToObj(objToString(new User("baz"))));
        System.out.println(objToString(new User("lorem")));
    }

    private static <T extends Serializable> String objToString(T t) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        new ObjectOutputStream(byteArrayOutputStream).writeObject(t);
        return Base64.getEncoder().encodeToString(byteArrayOutputStream.toByteArray());
    }

    @SuppressWarnings("unchecked")
    private static <T> T stringToObj(String s) throws IOException, ClassNotFoundException {
        return (T) new ObjectInputStream(new ByteArrayInputStream(Base64.getDecoder().decode(s))).readObject();
    }

    private static class User implements Serializable {
        private static final long serialVersionUID = 4;

        private String name;

        User(String name) {
            this.name = name;
        }

        @Override
        public String toString() {
            return "User{" +
                    "name='" + name + '\'' +
                    '}';
        }
    }
}
```

## 输出

```
User{name='foo'}
User{name='bar'}
User{name='baz'}
rO0ABXNyAAtiai5BcHAkVXNlcgAAAAAAAAAEAgABTAAEbmFtZXQAEkxqYXZhL2xhbmcvU3RyaW5nO3hwdAAFbG9yZW0=
```

