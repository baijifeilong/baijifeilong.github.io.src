---
title: Python之AsyncIO大杂烩
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
date: 2019-03-19 20:56:03
---

## AsyncIO

`asyncio`是Python官方的协程库，用于实现异步IO

<!--more-->

## 1. 服务端同步IO示例

```python
from wsgiref.simple_server import make_server
from time import sleep


def app(_, rsp):
    sleep(1)
    rsp("200 OK", [])
    yield "Hello World".encode()


make_server("0.0.0.0", 8888, app).serve_forever()
```

### ApacheBench四并发测试结果

测试命令: `ab -c 4 -n 4 localhost:8888/`

```log
Concurrency Level:      4
Time taken for tests:   4.017 seconds
Complete requests:      4
Failed requests:        0
Total transferred:      500 bytes
HTML transferred:       44 bytes
Requests per second:    1.00 [#/sec] (mean)
Time per request:       4017.108 [ms] (mean)
Time per request:       1004.277 [ms] (mean, across all concurrent requests)
Transfer rate:          0.12 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       0
Processing:  1004 1758 960.3   2009    3011
Waiting:     1004 1757 960.5   2009    3011
Total:       1005 1758 960.3   2010    3011
```

单请求耗时1秒，4个并发请求耗时4秒。系统的并发处理能力为1。

`time.sleep`会锁线程。由于GIL全局解释器锁的存在，sleep会阻塞掉整个Python解释器。即一个请求的阻塞，会阻塞掉整个服务器，这样的系统没有任何并发能力。

## 2. 服务端异步IO示例

WSGI是为同步服务设计的，在异步场景下，不能直接使用WSGI。我们可以使用第三方封装好的[aiohttp](https://github.com/aio-libs/aiohttp)做异步服务器。

```python
from aiohttp import web
import asyncio


async def handle(request: web.Request):
    name = request.match_info.get("name", "Anonymous")
    text = "Hello, " + name
    await asyncio.sleep(1)
    return web.Response(text=text)


app = web.Application()
app.add_routes([
    web.get("/", handler=handle),
    web.get("/{name}", handler=handle),
])

web.run_app(app, port=8888)
```

### ApacheBench四并发测试结果

测试命令: `ab -c 4 -n 4 localhost:8888/`

```log
Concurrency Level:      4
Time taken for tests:   2.016 seconds
Complete requests:      4
Failed requests:        0
Total transferred:      668 bytes
HTML transferred:       64 bytes
Requests per second:    1.98 [#/sec] (mean)
Time per request:       2016.458 [ms] (mean)
Time per request:       504.115 [ms] (mean, across all concurrent requests)
Transfer rate:          0.32 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       0
Processing:  1008 1008   0.1   1008    1008
Waiting:     1007 1007   0.4   1008    1008
Total:       1008 1008   0.1   1008    1009
```

使用异步IO后，每个请求耗时都是1秒。`asyncio.sleep`不会阻塞线程。

## 3. 异步Web框架Sanic示例

安装: `pip install sanic`

```python
from sanic import Sanic
from sanic.response import json
from asyncio import sleep

app = Sanic()


@app.route("/")
async def handle(_):
    await sleep(1)
    return json({'hello': 'world'})


app.run()
```

### 控制台输出示例

```log
[2019-03-19 22:49:36 +0800] [60436] [INFO] Goin' Fast @ http://127.0.0.1:8000
[2019-03-19 22:49:36 +0800] [60436] [INFO] Starting worker [60436]
[2019-03-19 22:49:40 +0800] - (sanic.access)[INFO][127.0.0.1:64966]: GET http://localhost:8000/  200 17
[2019-03-19 22:49:41 +0800] - (sanic.access)[INFO][127.0.0.1:64967]: GET http://localhost:8000/  200 17
[2019-03-19 22:49:41 +0800] - (sanic.access)[INFO][127.0.0.1:64968]: GET http://localhost:8000/  200 17
[2019-03-19 22:49:41 +0800] - (sanic.access)[INFO][127.0.0.1:64969]: GET http://localhost:8000/  200 17
```

## 4. 异步Web框架Tornado示例

```python
from tornado.web import Application, RequestHandler
from tornado.ioloop import IOLoop
from asyncio import sleep


class MainHandler(RequestHandler):
    async def get(self):
        await sleep(1)
        self.write("Hello World")


Application([("/", MainHandler)]).listen(8888)
IOLoop.current().start()
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
