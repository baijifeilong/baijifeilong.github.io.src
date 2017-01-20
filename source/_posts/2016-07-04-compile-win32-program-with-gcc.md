---
layout: post
title:  "用gcc编译win32程序 "
date:   2016-07-04 22:10:19 +0800
categories: it win32
---

**测试环境：msys2**

**编译最简单的win32程序**

`gcc -mwindows main.c` 会在当前目录下生成`a.exe`，用-o指定输出文件

**编译带多媒功能的win32程序**

`gcc -mwindows -lwinmm main.c` 此命令链接的应该是`C:\Windows\System32\winmm.dll`

**编译并使用win32资源文件**

`windres res.rc res.o` 将`res.rc`编译为`res.o`

`gcc -mwindows main.c res.o` 使用编译后的资源文件
