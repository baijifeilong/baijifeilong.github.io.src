---
title: Java播放多媒体
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Multimedia
  - GST
  - VLCJ
  - macOS
date: 2018-12-09 15:52:05
---

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

### VLCJ在macOS上的配置

VLCJ在Linux上开箱即用，但是在macOS需要比较复杂和匪夷所思的配置

VLCJ项目在macOS上跑起来，会报找不到动态链接库`libvlc.dylic`的错误，会提示

```log
The error was "Unable to load library 'vlc': Native library (darwin/libvlc.dylib) not found in resource path ...

The required native libraries are named "libvlc.dylib" and "libvlccore.dylib".

In the text below <libvlc-path> represents the name of the directory containing "libvlc.dylib" and "libvlccore.dylib"...

There are a number of different ways to specify where to find the native libraries:
 1. Include NativeLibrary.addSearchPath("vlc", "<libvlc-path>"); at the start of your application code.
 2. Include System.setProperty("jna.library.path", "<libvlc-path>"); at the start of your application code.
 3. Specify -Djna.library.path=<libvlc-path> on the command-line when starting your application.
 4. Add <libvlc-path> to the system search path (and reboot).
```

注意，VLCJ需要的不是在CLASSPATH下寻找`libvlc.dylib`，而是`darwin/libvlc.dylib`。

执行以下操作:

1. `cd src/main/resources/` 跳转到CLASSPATH目录下
2. `cp -r /Applications/VLC.app/Contents/MacOS/lib darwin` 创建文件夹darwin，里面是VLC的动态链接库
3. `rm darwin/*.*.*` 删除无用的文件

然后，继续报错

```log
java.lang.RuntimeException: Failed to load the native library.

The error was "dlopen(/Users/yuchao/workspace/java/steelplayer/build/resources/main/darwin/libvlc.dylib, 9): Library not loaded: @rpath/libvlccore.dylib
  Referenced from: /Users/yuchao/workspace/java/steelplayer/build/resources/main/darwin/libvlc.dylib
  Reason: image not found".
```

可见，`libvlc.dylib`已经被找到，但是它所依赖的`libvlccore.dylib`找不到。

执行 `otool -L libvlc.dylib`，返回如下:

```log
libvlc.dylib:
	@rpath/libvlc.dylib (compatibility version 12.0.0, current version 12.0.0)
	@rpath/libvlccore.dylib (compatibility version 10.0.0, current version 10.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)
	/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
```

可见，`libvlc`寻找`libvlccore`走的是相对路径

动态链接库寻找它所依赖的其他动态链接库，不是在Java的CLASSPATH里头找，而是在C系的`@rpath`里头找。怎么查询当前动态链接库所使用的`@rpath`，我没找到方法，但是找到了添加`@rpath`的方法

继续执行以下操作:

1. `cd src/main/resources/darwin`
2. `md5 libvlc.dylib` MD5值`52c4d6bfe42a0ccfc99b0c56a0df5b40`
3. `install_name_tool -add_rpath @loader_path libvlc.dylib` @loader_path指当前DLL的路径，把当前DLL路径添加到@rpath，意思是让它到自己所在的目录寻找其他DLL去
4. `md5 libvlc.dylib` MD5值 `f0bae5e3c0120cf73a3fb500c536cd78` 可见，install_name_tool不是修改的系统环境或用户环境，修改的是DLL文件本身

运行项目，继续报错:

```log
java.lang.RuntimeException: Failed to initialise libvlc.

This is most often caused either by an invalid vlc option being passed when creating a MediaPlayerFactory or by libvlc being unable to locate the required plugins.

If libvlc is unable to locate the required plugins the instructions below may help:

In the text below <libvlc-path> represents the name of the directory containing "libvlc.dylib" and "libvlccore.dylib" and <plugins-path> represents the name of the directory containing the vlc plugins...

For libvlc to function correctly the vlc plugins must be available, there are a number of different ways to achieve this:
 1. Make sure the plugins are installed in the "<libvlc-path>/vlc/plugins" directory, this should be the case with a normal vlc installation.
 2. Set the VLC_PLUGIN_PATH operating system environment variable to point to "<plugins-path>".
```

这次，是找不到VLC插件。提示说要把插件放在`<libvlc-path>/vlc/plugins`目录。然而，不清楚它所谓的`<libvlc-path>`指的是哪一级目录。实际测试发现，只有把插件放在`/src/main/resources/darwin/vlc/plugins`下才会生效

继续以下步骤:

1. `cd src/main/resources/darwin`
2. `mkdir vlc`
3. `cp -r /Applications/VLC.app/Contents/MacOS/plugins vlc/plugins`

Over.

总结:

```bash
cd src/main/resources/
cp -r /Applications/VLC.app/Contents/MacOS/lib darwin
rm darwin/*.*.*
cd darwin
install_name_tool -add_rpath @loader_path libvlc.dylib
mkdir vlc
cp -r /Applications/VLC.app/Contents/MacOS/plugins vlc/plugins
```


文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
