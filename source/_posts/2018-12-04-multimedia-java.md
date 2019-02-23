---
title: Java处理多媒体文件
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Multimedia
  - HumbleVideo
date: 2018-12-04 20:56:48
---

## 1. HumbleVideo

[HumbleVideo](https://github.com/artclarke/humble-video)是Java界比较活跃的多媒体处理库

### Maven依赖

```xml
<dependency>
    <groupId>io.humble</groupId>
    <artifactId>humble-video-all</artifactId>
    <version>0.3.0</version>
</dependency>
```

<!--more-->

### Java代码示例

```java
package bj;

import io.humble.video.Demuxer;
import io.humble.video.DemuxerFormat;
import io.humble.video.MediaPacket;
import org.junit.Test;

import java.io.IOException;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/4 下午4:33
 */
public class HumbleTest {

    @Test
    public void testAlpha() throws IOException, InterruptedException {
        Demuxer demuxer = Demuxer.make();
        demuxer.open("hello.flv", DemuxerFormat.findFormat("flv"), false, true, null, null);

        // 获取容器格式
        DemuxerFormat format = demuxer.getFormat();

        System.out.println(format);
        System.out.println(demuxer.getURL());

        // 打印容器元数据
        demuxer.getMetaData().getKeys().forEach($ ->
                System.out.println(String.format("%s: %s", $, demuxer.getMetaData().getValue($))));

        /// 读取媒体文件
        MediaPacket mediaPacket = MediaPacket.make();
        int read = demuxer.read(mediaPacket);
        assert read != 0;
    }
}
```

### 示例输出

```log
21:01:30.425 [main] ERROR org.ffmpeg - Invalid UE golomb code
21:01:30.495 [main] ERROR org.ffmpeg - Invalid UE golomb code
io.humble.video.DemuxerFormat@401960608[name:flv;description:FLV (Flash Video);]
hello.flv
server: Red5
canSeekToEnd: true
recordeddate: 2018-12-04T08:54:36.843Z
noaudiocodec: 0

java.lang.AssertionError
	at bj.HumbleTest.testAlpha(HumbleTest.java:27)
```

作为Java最活跃的多媒体库，读取文件信息和文件内容都报不明所以的异常，所以用Java处理多媒体不太容易

## 2. ffmpeg-cli-wrapper

[ffmpeg-cli-wrapper](https://github.com/bramp/ffmpeg-cli-wrapper)是对系统`ffmpeg`命令的封装，可以调用系统安装的`ffmpeg`处理多媒体文件

### Maven依赖

```xml
<dependency>
    <groupId>net.bramp.ffmpeg</groupId>
    <artifactId>ffmpeg</artifactId>
    <version>0.6.2</version>
</dependency>
```

### Java示例代码

```java
package bj;

import net.bramp.ffmpeg.FFmpeg;
import net.bramp.ffmpeg.FFmpegExecutor;
import net.bramp.ffmpeg.builder.FFmpegBuilder;
import org.junit.Test;

import java.io.IOException;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/12/4 下午5:57
 */
public class FFMpegTest {

    @Test
    public void testAlpha() throws IOException {
        /// FFmpeg命令构建器
        // 示例: 合并视频文件
        FFmpegBuilder builder = new FFmpegBuilder()
                .setInput("concat:0.ts|1.ts|2.ts")
                .overrideOutputFiles(true)
                .addOutput("three.ts")
                .done();

        System.out.println("Command: " + String.join("", builder.build()));

        // 使用系统FFmpeg的安装路径构造FFmpegExecutor
        FFmpegExecutor executor = new FFmpegExecutor(new FFmpeg("/usr/local/bin/ffmpeg"));

        // 执行转码任务，并打印执行进度
        executor.createJob(builder, progress -> System.out.println("Progress: " + progress)).run();
    }
}
```

### 控制台输出

```log
Command: -y -v error -i concat:0.ts|1.ts|2.ts three.ts
21:18:29.246 [main] INFO net.bramp.ffmpeg.RunProcessFunction - /usr/local/bin/ffmpeg -version
21:18:29.665 [main] INFO net.bramp.ffmpeg.RunProcessFunction - /usr/local/bin/ffmpeg -y -v error -progress tcp://127.0.0.1:62492 -i concat:0.ts|1.ts|2.ts three.ts
21:18:30.407 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 440011
Progress: Progress{frame=14, fps=0/1, bitrate=4766100, total_size=262144, out_time_ns=440011000, dup_frames=0, drop_frames=0, speed=0.877, status=continue}
21:18:30.943 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 1360011
Progress: Progress{frame=37, fps=3621/100, bitrate=3084000, total_size=524288, out_time_ns=1360011000, dup_frames=0, drop_frames=0, speed=1.33, status=continue}
21:18:31.444 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 1960011
Progress: Progress{frame=52, fps=841/25, bitrate=2139900, total_size=524288, out_time_ns=1960011000, dup_frames=0, drop_frames=0, speed=1.27, status=continue}
21:18:31.976 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 2920011
Progress: Progress{frame=76, fps=3671/100, bitrate=2154600, total_size=786432, out_time_ns=2920011000, dup_frames=0, drop_frames=0, speed=1.41, status=continue}
21:18:32.482 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 3960011
Progress: Progress{frame=102, fps=1973/50, bitrate=1588700, total_size=786432, out_time_ns=3960011000, dup_frames=0, drop_frames=0, speed=1.53, status=continue}
21:18:32.992 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 5080011
Progress: Progress{frame=130, fps=2101/50, bitrate=1651300, total_size=1048576, out_time_ns=5080011000, dup_frames=0, drop_frames=0, speed=1.64, status=continue}
21:18:33.514 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 6160011
Progress: Progress{frame=157, fps=4353/100, bitrate=1702200, total_size=1310720, out_time_ns=6160011000, dup_frames=0, drop_frames=0, speed=1.71, status=continue}
21:18:34.029 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 6880011
Progress: Progress{frame=175, fps=2121/50, bitrate=1524100, total_size=1310720, out_time_ns=6880011000, dup_frames=0, drop_frames=0, speed=1.67, status=continue}
21:18:34.520 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 8000011
Progress: Progress{frame=203, fps=877/20, bitrate=1572900, total_size=1572864, out_time_ns=8000011000, dup_frames=0, drop_frames=0, speed=1.73, status=continue}
21:18:35.030 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 9760011
Progress: Progress{frame=247, fps=481/10, bitrate=1504100, total_size=1835008, out_time_ns=9760011000, dup_frames=0, drop_frames=0, speed=1.9, status=continue}
21:18:35.544 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 11240011
Progress: Progress{frame=284, fps=5031/100, bitrate=1492600, total_size=2097152, out_time_ns=11240011000, dup_frames=0, drop_frames=0, speed=1.99, status=continue}
21:18:35.733 [TcpProgressParser(tcp://127.0.0.1:62492)] WARN net.bramp.ffmpeg.progress.Progress - skipping unhandled key: out_time_us = 11920011
Progress: Progress{frame=300, fps=5127/100, bitrate=1557500, total_size=2320672, out_time_ns=11920011000, dup_frames=0, drop_frames=0, speed=2.04, status=end}
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
