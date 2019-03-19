---
title: Python之TimeIt
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
date: 2019-03-19 18:29:25
---

## 什么是TimeIt

TimeIt是Python内置的一个模块，用来做性能测试，或者说压力测试

<!--more-->

## 1. 在命令行下使用TimeIt

常用参数:

- `-n` 测试次数

示例: `python -mtimeit "import this"`

### 示例输出

```log
The Zen of Python, by Tim Peters

Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently. Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
2000000 loops, best of 5: 134 nsec per loop
```

可见，代码共执行了两百万次，最快的5次平均耗时134纳秒

## 2. 在Python代码中使用TimeIt

```python
import timeit

seconds = timeit.timeit("request.urlopen('http://www.baidu.com')", setup="from urllib import request", number=100)
print(f"Total seconds: {seconds}")
print(f"Average seconds: {seconds / 100}")
```

### 控制台输出

```log
Total seconds: 2.5575550860000003
Average seconds: 0.025575550860000004
```

访问百度首页100次，共耗时2.56秒，平均耗时25毫秒

## 3. 使用TimeIt测试自定义的函数

```python
import timeit
from urllib.request import urlopen

access = lambda: urlopen("http://www.baidu.com")

seconds = timeit.timeit("access()", setup="from __main__ import access", number=100)
print(f"Total seconds: {seconds}")
print(f"Average seconds: {seconds / 100}")
```

## 4. 使用TimeIt测试gevent性能

```python
from urllib.request import urlopen
from gevent import joinall, spawn, monkey
from timeit import timeit

monkey.patch_all()

reqs = [spawn(urlopen, "http://www.baidu.com") for _ in range(100)]
access = lambda: joinall(reqs)

seconds = timeit("access()", setup="from __main__ import access", number=1)
print(f"Total seconds with gevent: {seconds}")

seconds2 = timeit("urlopen('http://www.baidu.com')", setup="from __main__ import urlopen", number=100)
print(f"Total seconds without gevent: {seconds2}")
```

### 控制台输出

```log
Total seconds with gevent: 3.616773271
Total seconds without gevent: 5.776799337
```

对于100个访问百度首页的网络请求，在不使用gevent的情况下，平均耗时58毫秒。在使用gevent的情况下，平均耗时36毫秒。可见，gevent确实提升了页面访问性能

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
