---
title: WSGI大杂烩
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - WSGI
date: 2019-03-19 17:22:36
---

## 什么是WSGI

`WSGI`即`Python Web Server Gateway Interface`，也就是Python的Web服务器网关接口，定义了Python的Web应用与服务端的交互规范，类似于Java中的Servlet规范。

实现了`WSGI`规范的Python模块主要有`wsgiref`(Python官方的WSGI参考实现)、`werkzeug.serving`(Flask用)和`twisted.web`等。

<!--more-->

## WSGI之HelloWorld(lambda版)

```python
from wsgiref.simple_server import make_server

make_server('localhost', 8088, lambda _, rsp: [
    [
        rsp("200 OK", []),
        "Hello World"
    ][-1].encode()
]).serve_forever()
```

其中，传给`make_server`的第三个参数即WSGI规范

- 入参1: 一般命名为environ，环境字典，表示服务器环境，存储服务器的环境变量、客户端请求参数等
- 入参2: 一般命名为start_response，函数，表示开始响应，用来设置响应状态(HTTP状态)与响应头(HTTP头)。响应状态表示为`状态码+状态文本`，响应头表示为二元组列表
- 出参: 响应体，一般表示为单元素列表或单元素元组等可迭代格式


### 多次访问服务器之后的控制台输出

```log
127.0.0.1 - - [19/Mar/2019 17:29:20] "GET / HTTP/1.1" 200 11
127.0.0.1 - - [19/Mar/2019 17:29:21] "GET / HTTP/1.1" 200 11
127.0.0.1 - - [19/Mar/2019 17:29:22] "GET / HTTP/1.1" 200 11
```

### HelloWorld之Class版

```python
from wsgiref.simple_server import make_server


class App:
    def __call__(self, _, rsp):
        rsp("200 OK", [])
        return ["Hello World".encode()]


make_server('localhost', 8088, App()).serve_forever()
```

### HelloWorld之Function版

```python
from wsgiref.simple_server import make_server


def app(_, rsp):
    rsp("200 OK", [])
    return ["Hello World".encode()]


make_server('localhost', 8088, app).serve_forever()
```

## WSGI容器

WSGI容器，即支持运行WSGI应用的Web容器。常用的有`uWSGI`和`gUnicorn`

以`gUnicorn`(`pip install gunicorn`)为例，运行方式：

`gunicorn foo:app` 启动`foo.py`文件中名字为`app`的WSGI应用

### 示例示例输出

```log
[2019-03-19 22:19:31 +0800] [59137] [INFO] Starting gunicorn 19.9.0
[2019-03-19 22:19:31 +0800] [59137] [INFO] Listening at: http://127.0.0.1:8000 (59137)
[2019-03-19 22:19:31 +0800] [59137] [INFO] Using worker: sync
[2019-03-19 22:19:31 +0800] [59140] [INFO] Booting worker with pid: 59140
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
