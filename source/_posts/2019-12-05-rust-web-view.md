---
title: Rust之WebView趟坑
categories:
  - Programming
  - Rust
tags:
  - Programming
  - Rust
date: 2019-12-05 10:29:04
---

## WebView仓库

[web-view](https://github.com/Boscop/web-view)

## Cargo.toml

```toml
[package]
name = "hello-rust"
version = "0.1.0"
authors = ["BaiJiFeiLong <baijifeilong@gmail.com>"]
edition = "2018"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
web-view = "0.5.4"
#web-view = "0.4.3"
```
<!--more-->

## main.rs

```rust
#![windows_subsystem = "windows"]

extern crate web_view;

use web_view::Content;

fn main() {
    web_view::builder()
        .title("web-view 0.5.4")
        .content(web_view::Content::Html(r#"
        <span style='font-size:1rem'>1rem</span>
        <span style='font-size:3rem'>3rem</span>
        "#))
        .size(400, 100)
        .resizable(false)
        .user_data(0)
        .invoke_handler(|_webview, _arg| Ok(()))
        .run()
        .unwrap();
}
```

我用最新版web-view(0.5.4)在Windows10上编译运行后，发现显示很不正常，`rem`单位不工作，`flex`布局不工作，`bootstrap`引入后只有部分样式起作用，整体上看特别丑。所以，这玩意的渲染引擎应该太古老了。

但是，官方文档的介绍是:

> It uses Cocoa/WebKit on macOS, gtk-webkit2 on Linux and MSHTML (IE10/11) or EdgeHTML (with the edge feature) on Windows, so your app will be much leaner than with Electron.

但是，不管是IE10、IE11还是Edge，都不算古老的浏览器，不至于连很基本的`rem`、`flex`都不支持。

下载了一个使用web-view开发的[App](https://github.com/Freaky/Compactor)，只有500KB多，但是样式显示完全正常，里面也用到了flex布局。

想编译一下这个APP，看看是不是我电脑编译环境有问题，结果没编译过，可能是WindowsSDK版本不够吧。

这个`web-view`本身是另一个webview库[https://github.com/zserge/webview](https://github.com/zserge/webview)的Rust语言绑定。这个框架官方支持C/C++/Golang。用Golang版本的试了一下，发现居然显示没问题。看来是这个Rust绑定有毛病。

改了一下我Demo用到的web-view的版本号，从`0.5.4`降级到了`Compactor`用的`0.4.3`，居然显示正常了。难道是新版本出Bug了？再切换回新版本，竟然也显示没问题了。

拿IE浏览器的调试工具对比了一下各个IE版本，发现之前怪异的显示样式，渲染引擎应该是IE7，不在官方宣称的`IE10/IE11/Edge`之内。看来，这玩意也是个坑多多。

问题是复现不了了。但是分析一下发生的原因，可能是跟我安装的WindowsSDK2015版本有关。可能是安装完没有重启电脑，导致没有识别到新版渲染引擎，所以才使用了古老的IE7吧。

用`Process Explorer`可以查询进程加载的DLL模块，可以看到应用程序加载的渲染引擎文件是`/mnt/c/Windows/System32/mshtml.dll`。使用`CFF Explorer`分析此DLL，可以看到该DLL版本为11。说明当前应用程序加载的是当前操作系统自带的IE11渲染引擎。所以编译后的可执行文件可以小到几百KB。

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
