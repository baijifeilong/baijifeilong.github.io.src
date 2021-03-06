---
title: 面向聪明小白的编程入门教程 开篇(Part 1)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-22 16:04:48
---

作为一个在磕磕绊绊中蜗行摸索，一步步艰辛成长起来的半吊子程序员，我很早之前就有编写一个编程入门教程的想法。编程虽然不难，但是如果没有过来人的清晰指路，难免会一次次地掉进坑里。轻则在坑里摸爬滚打几天，重则会完全丧失学习的兴趣。今天正好闲来无事，着手写下此教程的开篇。

<!--more-->

## 本教程适用读者

本教程面向的是小白。这里的小白说的是编程小白，不是计算机小白。如果你没说过操作系统，不知道什么是浏览器，更不会在浏览器里添加书签（收藏），那你此时应该按下键盘上的`Ctrl+W`关闭此页面（苹果系统需要按下`Meta+W`，不过如果你是真·计算机小白的话，应该已经看不懂我在说啥了吧）。

本教程面向的是聪明的小白。作为一名小白，又不够聪明的话，是不适合学编程的。聪明这个词很难定义。我认为聪明的第一要义是勤奋。如果脑子都懒得动，就算天生智商再高，脑子终究也会秀逗。聪明的第二要义是谦逊。懂得越多，越能发现自己的无知。无知并不可怕，可怕的是你今天跟昨天一样无知，甚至比昨天更无知。一个人活了几十年，辛辛苦苦走出了楚门的世界，但你敢保证他看到的新世界不是一个更大的更楚门的世界吗？

## 编程是什么

编程，英文名叫`Programming`，意思是`编写程序`。何谓程序，就是控制计算机运行的一段指令。何谓指令，只可意会不可言传，不懂的话慢慢体会吧。

程序是用来控制计算机的，但是直接控制计算机需要用到`CPU指令`。CPU指令一般使用晦涩难懂的汇编语言（低级语言）代码编写，需要了解一些计算机底层的运行原理才能看得明白。作为一名小白，还是选用高级语言来入门吧。对于编程语言来说，不是越高级越复杂，而是越高级离计算机越远，离人越近，越容易看懂。

## 关于操作系统

这门教程里的编程，不是广义的编程，是面向操作系统的编程。直接控制硬件太过复杂，一般情况下，我们都是直接控制操作系统，让操作系统来控制硬件。

广义的操作系统，除了运行在电脑上，也运行在手机、游戏机、手环等智能设备上。

本教程面向的是电脑操作系统。常用的电脑操作系统，按使用人数排序，主要是微软公司的`Windows`(视窗操作系统)，苹果公司的`macOS`(也俗称苹果系统)和任何人都可以致敬出一个的`Linux`操作系统。

如果你没听说过苹果系统的话，你用的应该就是Windows操作系统了。如果你是Linux用户，就别说自己是编程小白了，`Ctrl+W`走好不送。

由于Windows系统的用户基数太大，因此本教程主要面向Windows用户，macOS用户可适当参考。

Windows操作系统，现在主要有三大分支，`Windows 10 / Windows 8`，`Windows 7 / Windows Vista`和`Windows XP`。由于我本人是从`Windows Vista`开始玩电脑的，有`Vista`情结，所以至今使用的还是`Windows 7`。对于使用其他Windows版本的用户，本教程可能会有一丝出入，如果照顾不周，请自行触类旁通。

知道自己用的是哪个操作系统后，就开始学习编程吧。

## 关于穿墙

穿墙，为的是翻越大中华局域网，进入国际互联网。这个伟大的防火墙，就是我们大中华局域网的上帝，God is a girl，上帝的脾气是捉摸不透的，理论上本教程的所有操作都不需要穿墙，但是如果你人品不好，可能会在某个操作上卡上数小时。碰到这种情况的话，您就需要穿墙来降降肾上腺素了。

穿墙与建墙是一个博弈的过程。事实上，只要上帝愿意，你就永远无法穿过这堵墙。上帝不想让你穿墙，但是想让某些人穿墙，但是他又做不到精准控制，所以我们才有穿墙的机会。如果你愿意的话，就感谢上帝吧。

上不了外网，必须借助一个可以上外网，你又能访问得到的机器做跳板，来代为处理（代理）你的上网请求。这样的一台（或者多台）服务器，叫做代理服务器。自己搭建一个代理服务器，门槛太高，需要花钱，而且被封杀的机率也高。对于小白用户来说，最好直接使用第三方的代理服务器。

目前，[蓝灯](https://github.com/getlantern/lantern)是最好的穿墙选择。免费（到一定流量后会限速）、高速、相对稳定、支持大部分主流操作系统。蓝灯的下载、安装与使用非常简单，几乎是一键操作。在蓝灯的主页上可以找到对应操作系统的下载链接。对于Windows用户，下载链接是[蓝灯Windows安装器](https://raw.githubusercontent.com/getlantern/lantern-binaries/master/lantern-installer.exe)。下载完成后，双击即可安装运行，并自动接管系统的网络连接。

使用蓝灯有以下注意事项:

1. 蓝灯的下载链接也可能被墙，多试几次即可
2. 蓝灯开启后，打开[谷歌](https://www.google.com)可以查看是否穿墙成功
3. 穿墙可能会影响上网速度，需要注意
4. 蓝灯默认的穿墙策略是智能穿墙，即只穿黑名单网站。如果有些站点穿不过去，需要改用全局穿墙模式
5. 蓝灯异常退出可能会导致整个系统断网。这时候需要手动取消蓝灯接管操作系统网络连接的配置。配置入口：`Internet选项 -> 连接 -> 局域网设置 -> 使用自动配置脚本`。取消打勾，即可退出蓝灯代理模式。`Internet选项`窗口可在控制面板查找，也可在开始菜单中搜索。

## 附录

### 附录一 汇编语言HelloWorld窗体应用程序代码

```asm
.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

.data
MsgBoxCaption  db "Iczelion Tutorial No.2",0
MsgBoxText       db "Win32 Assembly is Great!",0

.code
start:
invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK
invoke ExitProcess, NULL
end start
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
