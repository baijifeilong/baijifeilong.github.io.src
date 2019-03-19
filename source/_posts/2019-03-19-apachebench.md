---
title: ApacheBench大杂烩
categories:
  - Application
tags:
  - Application
date: 2019-03-19 20:39:47
---

## ApacheBench

ApacheBench是命令行下一个常用的HTTP服务压力测试工具。

<!--more-->

## ApacheBench使用示例

### 1. 测试百度首页一次

`ab www.baidu.com/`

默认情况下，ApacheBench只进行一次测试。

注意: URL必须至少有一个斜杠，否则ApacheBench不识别。

#### 控制台输出

```log
This is ApacheBench, Version 2.3 <$Revision: 1826891 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.baidu.com (be patient).....done


Server Software:        BWS/1.1
Server Hostname:        www.baidu.com
Server Port:            80

Document Path:          /
Document Length:        153011 bytes

Concurrency Level:      1
Time taken for tests:   0.048 seconds
Complete requests:      1
Failed requests:        0
Total transferred:      153973 bytes
HTML transferred:       153011 bytes
Requests per second:    21.04 [#/sec] (mean)
Time per request:       47.533 [ms] (mean)
Time per request:       47.533 [ms] (mean, across all concurrent requests)
Transfer rate:          3163.37 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       12   12   0.0     12      12
Processing:    35   35   0.0     35      35
Waiting:       13   13   0.0     13      13
Total:         48   48   0.0     48      48
```

### 2. 压测百度首页，4并发共40个请求

`ab -n 40 -c 4 www.baidu.com/`

#### 控制台输出

```log
This is ApacheBench, Version 2.3 <$Revision: 1826891 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.baidu.com (be patient).....done


Server Software:        BWS/1.1
Server Hostname:        www.baidu.com
Server Port:            80

Document Path:          /
Document Length:        153337 bytes

Concurrency Level:      4
Time taken for tests:   5.136 seconds
Complete requests:      40
Failed requests:        39
   (Connect: 0, Receive: 0, Length: 39, Exceptions: 0)
Total transferred:      6166547 bytes
HTML transferred:       6127863 bytes
Requests per second:    7.79 [#/sec] (mean)
Time per request:       513.563 [ms] (mean)
Time per request:       128.391 [ms] (mean, across all concurrent requests)
Transfer rate:          1172.59 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        4   61 234.6      6    1086
Processing:    30  407 568.1    297    3302
Waiting:        6   18  41.0     10     266
Total:         34  468 610.2    316    3309

Percentage of the requests served within a certain time (ms)
  50%    316
  66%    433
  75%    584
  80%    671
  90%   1088
  95%   1757
  98%   3309
  99%   3309
 100%   3309 (longest request)
```

可见，这些请求最短耗时34毫秒，最长耗时3309毫秒，平均耗时468毫秒

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
