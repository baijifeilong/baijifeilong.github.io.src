---
layout: post
title:  "使用 GCC 编译Win32程序 "
date:   2016-07-04 22:10:19 +0800
categories:
    - Programming
    - C
tags:
    - Programming
    - C
    - Win32
    - GCC
---

使用 GCC 也可以编译 Win32 应用程序。以下是几条常用的 GCC 编译命令：

## 1. 编译最简单的win32程序

`gcc -mwindows main.c` 会在当前目录下生成`a.exe`，用`-o`可以指定输出文件

<!-- more -->

## 2. 编译带多媒功能的win32程序

`gcc -mwindows -lwinmm main.c` 此命令链接的DLL应该是`C:\Windows\System32\winmm.dll`

## 3. 编译带资源文件的Win32程序

`windres res.rc res.o` 将`res.rc`编译为`res.o`

`gcc -mwindows main.c res.o` 使用编译后的资源文件
