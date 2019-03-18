---
title: Python生成器大杂烩
categories:
  - Programming
tags:
  - Programming
date: 2019-03-18 23:14:02
---

## Python生成器

Python生成器可以用来定义迭代行为，也可以用作协程。

<!--more-->

## 1. 生成器的基本用法

```python
numbers = (x for x in range(1, 6))
print(type(numbers), list(numbers))
```

### 控制台输出

```log
<class 'generator'> [1, 2, 3, 4, 5]
```

## 2. 带有yield关键字的生成器

```python
numbers = [(yield x) for x in range(1, 6)]
print(type(numbers), list(numbers))
```

### 控制台输出

```log
<class 'generator'> [1, 2, 3, 4, 5]
```

## 3. 向生成器发送消息，进行交互

```python
pig = [print(f"Received: {yield}") for _ in iter(bool, True)]
[pig.send(_) for _ in [None] + list(range(10))]
```

### 控制台输出

```log
Received: 0
Received: 1
Received: 2
Received: 3
Received: 4
Received: 5
Received: 6
Received: 7
Received: 8
Received: 9
```

## 4. 生产者消费者模型示例

```python
from time import sleep
from random import random


def eat():
    while True:
        food = yield
        print("3. Eating:", food)
        sleep(random())
        print("4. Ate:", food)


def cook(eater):
    eater.send(None)
    for food in ("Apple", "Banana", "Cabbage"):
        print("1. Cooking:", food)
        sleep(random())
        print("2. Cooked:", food)
        eater.send(food)


cook(eat())
```

### 控制台输出

```log
1. Cooking: Apple
2. Cooked: Apple
3. Eating: Apple
4. Ate: Apple
1. Cooking: Banana
2. Cooked: Banana
3. Eating: Banana
4. Ate: Banana
1. Cooking: Cabbage
2. Cooked: Cabbage
3. Eating: Cabbage
4. Ate: Cabbage
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
