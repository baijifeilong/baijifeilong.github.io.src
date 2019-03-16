---
title: TensorFlow大杂烩
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - TensorFlow
date: 2019-03-15 23:44:31
---

## TensorFlow是什么

TensorFlow是一个谷歌出品的深度学习框架

## TensorFlow的安装

`pip install tensorflow` 大约需要下载100MB

<!--more-->

## TensorFlow之HelloWorld

示例: 使用TensorFlow在平面上计算最接近指定点集的直线

```python
import tensorflow as tf

# 已知二维平面的五个点(训练数据)，计算与这五个点最接近的一条直线(最终待求模型)

points = [(1, 4), (2, 6), (3, 8), (5, 12), (8, 18)]

# 横轴数据、纵轴数据
xx = [point[0] for point in points]
yy = [point[1] for point in points]

# 直线公式: y = a * x + b

# 待求变量: 直线坡度a, 直线与y轴的交点b
a = tf.Variable(0, dtype=tf.float32)
b = tf.Variable(0, dtype=tf.float32)

# 样本占位符x, y
x = tf.placeholder(tf.float32)
y = tf.placeholder(tf.float32)

# 损失模型/误差模型
loss = tf.reduce_sum(tf.square(a * x + b - y))
# 训练模型(梯度0.001)
train = tf.train.GradientDescentOptimizer(0.001).minimize(loss)

# 创建TensorFlow会话
sess = tf.Session()
# 初始化TensorFlow全局变量
sess.run(tf.global_variables_initializer())
# 训练5000次
for i in range(5000):
    sess.run(train, {x: xx, y: yy})
    if (i < 10) or (i % 1000 is 0):
        print(f"{i + 1:04}: y={sess.run(a):.9f}x+{sess.run(b):.9f} => {sess.run(loss, {x: xx, y: yy}):.12f}")
```

### 控制台输出

输出格式: 训练次数: 公式 => 损失

```log
0001: y=0.488000035x+0.096000001 => 362.995117187500
0002: y=0.871824026x+0.172496006 => 226.141662597656
0003: y=1.173673511x+0.233641744 => 141.394470214844
0004: y=1.411018372x+0.282705724 => 88.911415100098
0005: y=1.597605824x+0.322259963 => 56.406211853027
0006: y=1.744253159x+0.354328334 => 36.271305084229
0007: y=1.859472513x+0.380503446 => 23.796068191528
0008: y=1.949962020x+0.402038455 => 16.063734054565
0009: y=2.020992279x+0.419919521 => 11.268218040466
0010: y=2.076710939x+0.434922606 => 8.291220664978
1001: y=2.016209364x+1.913361430 => 0.011228192598
2001: y=2.000897169x+1.995205998 => 0.000034384284
3001: y=2.000049353x+1.999734759 => 0.000000105264
4001: y=2.000005484x+1.999973178 => 0.000000001114
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
