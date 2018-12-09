---
title: Java播放多媒体
categories:
  - Programming
tags:
  - Programming
date: 2018-12-09 15:52:05
---

# Java播放多媒体

Java对多媒体文件的支持很差，自带的库只能播放`.mp3`等有限的几种格式的文件，连`.wma`都不支持。所以，要想用Java播放几种常见的多媒体文件，就得救助外部的第三方库。

目前用Java播放`.wma`等格式的多媒体文件，主要有两种方式。一种是通过Java的`Runtime`调用第三方播放器，另一种是通过`JNI`调用第三方播放器提供的动态链接库。

调用第三方播放器，`mplayer`支持较好。`mplayer`轻量快速，支持常见的多媒体格式，而且有个`slave`模式，方便外部程序通过`IPC`对其进行控制。

但调用第三方播放器，兼容性较差，需要系统装有相应的播放器，而且不好控制。所以，最好使用动态链接库的方式调用。

Java通过动态链接库播放多媒体文件，常用的第三方Wrapper库主要有以下两个:

<!--more-->

## 1. gst1-java-core

[gst1-java-core](https://github.com/gstreamer-java/gst1-java-core)是Java对GStreamer的绑定

依赖: `compile "org.freedesktop.gstreamer:gst1-java-core:0.9.3"`

示例代码:

```kotlin
import org.freedesktop.gstreamer.Gst
import org.freedesktop.gstreamer.elements.PlayBin
import java.io.File
import java.util.concurrent.TimeUnit

fun main(args: Array<String>) {
    Gst.init()
    val playBin = PlayBin("")
    playBin.setURI(File("/mnt/d/music/test/江美琪-我心似海洋.wma").toURI())
    playBin.play()
    Thread.sleep(100)
    playBin.seek(50, TimeUnit.SECONDS)
    Thread.currentThread().join()
}
```

注意：

1. GStreamer 使用前需要先初始化
2. 从指定位置开始播放，需要Sleep以下，不知道为啥

## 2. vlcj

[vlcj](https://github.com/caprica/vlcj)是Java对VLC的绑定

依赖: `compile "uk.co.caprica:vlcj:3.10.1"`

```kotlin
import uk.co.caprica.vlcj.component.AudioMediaPlayerComponent

fun main(args: Array<String>) {
    val mediaPlayer = AudioMediaPlayerComponent().mediaPlayer
    mediaPlayer.playMedia("/mnt/d/music/test/江美琪-我心似海洋.wma")
    mediaPlayer.skip(80000)
    Thread.currentThread().join()
}
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
