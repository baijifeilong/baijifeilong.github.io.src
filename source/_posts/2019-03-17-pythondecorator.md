---
title: Python装饰器
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
date: 2019-03-17 16:47:02
---

## 什么是Python装饰器

Python装饰器类似于Java中的切面，以类似Java注解的形式，将一个函数替换为另一个函数

<!--more-->

## 1. Python装饰器示例

```python
def log(func):
    from datetime import datetime
    return lambda *args, **kwargs: [
        print(
            f"[{datetime.now()}] >>> {func.__name__}"
            f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
        func(*args, **kwargs),
        print(
            f"[{datetime.now()}] <<< {func.__name__}"
            f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
    ][1]


@log
def hello(name, **kwargs):
    print(f"Hello: {', '.join([name] + list(kwargs.values()))}")
    return "OK"


result = hello("world", alpha="ALPHA", beta="BETA")
print("Result:", result)
```

### 控制台输出

```log
[2019-03-17 16:38:35.629506] >>> hello(world, alpha=ALPHA, beta=BETA)
Hello: world, ALPHA, BETA
[2019-03-17 16:38:35.629561] <<< hello(world, alpha=ALPHA, beta=BETA)
Result: OK
```

## 2. 装饰器带参数示例

```python
def log(level):
    from datetime import datetime
    return lambda func: lambda *args, **kwargs: [
        print(
            f"[{datetime.now()}] {level} >>> {func.__name__}"
            f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
        func(*args, **kwargs),
        print(
            f"[{datetime.now()}] {level} <<< {func.__name__}"
            f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
    ][1]


@log("DEBUG")
def hello(name, **kwargs):
    print(f"Hello: {', '.join([name] + list(kwargs.values()))}")
    return "OK"


result = hello("world", alpha="ALPHA", beta="BETA")
print("Result:", result)
```

### 控制台输出

```log
[2019-03-17 17:09:31.427342] DEBUG >>> hello(world, alpha=ALPHA, beta=BETA)
Hello: world, ALPHA, BETA
[2019-03-17 17:09:31.427401] DEBUG <<< hello(world, alpha=ALPHA, beta=BETA)
Result: OK
```

## 3. 用Class写装饰器

```python
class Log(object):
    def __init__(self, level):
        self.level = level

    def __call__(self, func):
        from datetime import datetime
        level = self.level
        return lambda *args, **kwargs: [
            print(
                f"[{datetime.now()}] {level} >>> {func.__name__}"
                f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
            func(*args, **kwargs),
            print(
                f"[{datetime.now()}] {level} <<< {func.__name__}"
                f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
        ][1]


@Log("DEBUG")
def hello(name, **kwargs):
    print(f"Hello: {', '.join([name] + list(kwargs.values()))}")
    return "OK"


result = hello("world", alpha="ALPHA", beta="BETA")
print("Result:", result)
```

### 控制台输出

```log
[2019-03-17 17:23:17.428339] DEBUG >>> hello(world, alpha=ALPHA, beta=BETA)
Hello: world, ALPHA, BETA
[2019-03-17 17:23:17.428404] DEBUG <<< hello(world, alpha=ALPHA, beta=BETA)
Result: OK
```

## 4. 使用@wraps保留函数元数据

装饰器会替换原函数，导致原函数的元信息被替换。使用@wraps装饰器，可以还原函数的元数据

```python
class Log(object):
    def __init__(self, level):
        self.level = level

    def __call__(self, func):
        from datetime import datetime
        from functools import wraps
        level = self.level
        return wraps(func)(lambda *args, **kwargs: [
            print(
                f"[{datetime.now()}] {level} >>> {func.__name__}"
                f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
            func(*args, **kwargs),
            print(
                f"[{datetime.now()}] {level} <<< {func.__name__}"
                f"({', '.join([', '.join(args), ', '.join([f'{k}={v}' for k, v in kwargs.items()])])})"),
        ][1])


@Log("DEBUG")
@Log("DEBUG")
@Log("DEBUG")
def hello(name, **kwargs):
    print(f"Hello: {', '.join([name] + list(kwargs.values()))}")
    return "OK"


result = hello("world", alpha="ALPHA", beta="BETA")
print("Result:", result)
```

### 控制台输出

```log
[2019-03-17 17:30:54.099987] DEBUG >>> hello(world, alpha=ALPHA, beta=BETA)
[2019-03-17 17:30:54.100037] DEBUG >>> hello(world, alpha=ALPHA, beta=BETA)
[2019-03-17 17:30:54.100050] DEBUG >>> hello(world, alpha=ALPHA, beta=BETA)
Hello: world, ALPHA, BETA
[2019-03-17 17:30:54.100068] DEBUG <<< hello(world, alpha=ALPHA, beta=BETA)
[2019-03-17 17:30:54.100079] DEBUG <<< hello(world, alpha=ALPHA, beta=BETA)
[2019-03-17 17:30:54.100089] DEBUG <<< hello(world, alpha=ALPHA, beta=BETA)
Result: OK
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
