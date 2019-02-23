---
title: 直播协议大杂烩
categories:
  - Application
tags:
  - Application
  - Live
  - RTMP
  - HLS
  - JavaScript
date: 2018-12-01 09:29:38
---

## 在线直播常用协议

### RTMP

RTMP(Real-Time Messaging Protocol)，实时消息协议，Macromedia公司开发，后Macromedia被Adobe收购。

RTMP被设计用来在Flash插件中使用，因此如果用在浏览器端，必须安装Flash插件

其他端也可使用相关解码器解码RTMP流

RTMP实时性较强，一般在3秒左右

### HLS(HTTP Live Streaming)，是一个由苹果公司提出的基于HTTP的流媒体网络传输协议。

HLS只请求HTTP报文，因此可以在浏览器端不依赖任何插件直接使用

HLS实时性较差，一般在10秒左右

<!--more-->

## HLS使用示例

### Web端

Web端可以使用`videojs`加`videojs-http-streaming`播放HLS直播流

**示例代码**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>HLS Sample</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/video.js@7.3.0/dist/video-js.min.css">
    <script src="https://cdn.jsdelivr.net/npm/video.js@7.3.0/dist/video.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@videojs/http-streaming@1.5.0/dist/videojs-http-streaming.js"></script>
</head>
<body>
<video-js id="video" width="600" height="400" class="vjs-default-skin" controls>
    <source src="http://hls.open.ys7.com/openlive/f01018a141094b7fa138b9d0b856507b.hd.m3u8"
            type="application/x-mpegURL">
</video-js>
<script>
    videojs('video').play();
</script>
</body>
</html>
```

其他公开视频流:

- `https://video-dev.github.io/streams/x36xhzz/x36xhzz.m3u8`

## RTMP使用示例

### Web端

Web端可以使用`videojs`加`videojs-flash`加`Flash`插件播放RTMP直播流

**示例代码**

理论上以下代码可以工作，然而实际上播放不了视频。官方没有完整的使用示例，栈爆网搜到的代码也播放不了。。。//TODO

```html
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/video.js@7.3.0/dist/video-js.min.css">
    <script src="https://cdn.jsdelivr.net/npm/video.js@7.3.0/dist/video.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/videojs-flash@2.1.2/dist/videojs-flash.min.js"></script>
</head>
<body>

<video width="600"
       height="400"
       id="example"
       class="video-js vjs-default-skin vjs-big-play-centered"
       controls
       autoplay
       preload="auto"
       data-setup='{"techorder" : ["flash","html5"] }'>
    <source src="rtmp://rtmp.open.ys7.com/openlive/f01018a141094b7fa138b9d0b856507b.hd" type="rtmp/mp4">
</video>

</body>
<script>
    var player = videojs('example');
    player.play();
</script>
</html>
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
