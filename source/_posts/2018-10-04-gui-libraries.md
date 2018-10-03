---
title: Windows下各图形库大小比较
categories:
  - Programming
tags:
  - Programming
date: 2018-10-04 02:03:54
---

**规则**

创建Hello World，在Windows上编译，带上动态链接库，使用7z进行极限压缩

**比较**

- Qt 5.9.2  5.71MB
- Qt 4.8.6  3.99MB
- GTK 3.0   5.18MB
- wxWidgets 3.1.0   3.16MB
- MFC   14KB
- Win32 10KB
- WinForm   5KB
- Swing 2KB
- JavaFX    1KB
- WPF   5KB

**注意**
- 理论上MFC需要几百KB的DLL，但是`C:\Windows\SysWOW64`目录下已经有多个版本的MFC链接库了，因此不便测试。一般压缩后应该在500KB左右。
- WinForm、WPF需要.NET运行时
- Swing需要Java运行时
- JavaFX需要Java8运行时，太旧的java8也可能缺失组件
