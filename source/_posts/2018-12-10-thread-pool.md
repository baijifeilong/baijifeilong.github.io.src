---
title: Java线程池
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Concurrent
  - Thread
date: 2018-12-10 13:57:40
---

# Java线程池

Java线程池(`java.util.concurrent.ThreadPoolExecutor`)实现了接口`java.util.concurrent.ExecutorService`，将线程资源缓存起来，实现了线程的复用。

<!--more-->

## 示例代码

```java
package bj;

import io.vavr.control.Try;

import java.time.LocalTime;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;
import java.util.stream.IntStream;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/7 上午10:05
 */
public class FooTest {

    public static void main(String[] args) {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(4, 6, 5, TimeUnit.SECONDS, new LinkedBlockingQueue<>(3), new ThreadFactory() {
            private int count = 0;

            @Override
            public Thread newThread(Runnable r) {
                return new Thread(r, String.format("Thread[%d]", ++count));
            }
        }, (r, executor1) -> System.out.println("Ignored: " + r));
        executor.allowCoreThreadTimeOut(true);
        IntStream.range(0, 10).forEach($ -> executor.execute(() -> {
            Try.run(() -> Thread.sleep(1000)).getOrElseThrow((Supplier<RuntimeException>) RuntimeException::new);
            System.out.println(String.format("%s Progress: %d Thread: %s", LocalTime.now(), $, Thread.currentThread().getName()));
        }));
    }
}
```

## 示例输出

```log
Ignored: bj.FooTest$$Lambda$3/783286238@27082746
14:13:53.247 Progress: 0 Thread: Thread[1]
14:13:53.247 Progress: 2 Thread: Thread[3]
14:13:53.247 Progress: 8 Thread: Thread[6]
14:13:53.247 Progress: 3 Thread: Thread[4]
14:13:53.248 Progress: 1 Thread: Thread[2]
14:13:53.248 Progress: 7 Thread: Thread[5]
14:13:54.252 Progress: 5 Thread: Thread[6]
14:13:54.252 Progress: 6 Thread: Thread[3]
14:13:54.252 Progress: 4 Thread: Thread[1]

Process finished with exit code 0
```

## 线程池各参数讲解

以线程池参数最多的构造函数(`java.util.concurrent.ThreadPoolExecutor#ThreadPoolExecutor(int, int, long, java.util.concurrent.TimeUnit, java.util.concurrent.BlockingQueue<java.lang.Runnable>, java.util.concurrent.ThreadFactory, java.util.concurrent.RejectedExecutionHandler)`)为例

- corePoolSize 核心池大小。核心池直接开辟空间
- maximumPoolSize 最大池(核心池+普通池)大小 线程数量超过这个大小，会拒绝执行
- keepAliveTime 线程存活时间 线程过了存活时间会自动销毁，默认情况下核心池例外
- unit 线程存活时间单位
- workQueue 工作队列 任务会在workQueue排队
- threadFactory 线程工厂 如何创建线程。可以指定线程名称、记录日志等
- handler 拒绝执行策略 默认抛异常，不执行

## 线程池基本工作流程

1. 创建线程池，核心池分配满线程
2. 新任务进入，放入核心池，开始执行
3. 新任务进入，核心池已满，放入执行队列
4. 新任务进入，执行队列已满，新任务放入普通池立即执行
5. 新任务进入，线程数量超过最大池大小，拒绝执行
6. 任务执行完毕，进入等待状态。普通池的线程超时后自动销毁
7. 如果`allowCoreThreadTimeOut`设为`true`，核心池中的线程超时后自动销毁

## 示例程序中，各任务的流向

1. 任务1，放入核心池执行
2. 任务2，放入核心池执行
3. 任务3，放入核心池执行
4. 任务4，放入核心池执行
5. 任务5，核心池已满，放入执行队列等待
6. 任务6，核心池已满，放入执行队列等待
7. 任务7，核心池已满，放入执行队列等待
8. 任务8，核心池和指定队列都已满，放入普通池立即执行
9. 任务9，核心池和指定队列都已满，放入普通池立即执行
10. 任务10, 核心池+普通池已达上限，任务被拒绝执行

## 线程池任务执行完成后自动销毁全部线程

线程池的存在，默认会阻止主程序的自动退出。销毁掉线程池中的全部线程后，主程序才可以顺利退出。

实现线程池任务全部接触后，自动销毁全部线程，有两种方式:

1. `executor.allowCoreThreadTimeOut(true);` 将核心池中的线程设为超时自动销毁
2. `executor.setCorePoolSize(0);` 将核心池大小设为0，核心池中的线程执行完后会自动销毁


文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
