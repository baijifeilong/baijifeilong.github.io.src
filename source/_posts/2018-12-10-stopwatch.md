---
title: StopWatch大杂烩
categories:
  - Programming
tags:
  - Programming
date: 2018-12-10 20:53:44
---

# StopWatch大杂烩

## Spring StopWatch 的基本用法

**App.kt**

```kotlin
package bj

import org.springframework.util.StopWatch
import java.util.concurrent.TimeUnit

fun main(args: Array<String>) {
    val stopWatch = StopWatch("Sleeping")
    stopWatch.start("First sleeping")
    TimeUnit.SECONDS.sleep(1)
    stopWatch.stop()
    stopWatch.start("Second sleeping")
    TimeUnit.SECONDS.sleep(2)
    stopWatch.stop()
    println(stopWatch.prettyPrint())
}
```

<!--more-->

## 控制台输出

```
StopWatch 'Sleeping': running time (millis) = 3006
-----------------------------------------
ms     %     Task name
-----------------------------------------
01002  033%  First sleeping
02004  067%  Second sleeping
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
