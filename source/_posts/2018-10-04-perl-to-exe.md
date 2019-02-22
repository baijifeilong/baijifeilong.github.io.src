---
title: Perl打包EXE
categories:
  - Programming
  - Perl
tags:
  - Programming
  - Perl
  - Windows
  - Exe
date: 2018-10-04 02:07:01
---

Perl打包exe的工具，搜索一下不少，实际上活跃的差不多也就只有PAR:: Packer下的pp了。

Perl打包exe分主要分两种。一种直接打PAR包，一种编译成二进制字节码。但是脚本语言越更越骚，打包二进制的工具，估计也只有作者用起来有谱了。就算我想试试，也没装上，测试挂了一片。

打包工具在Windows里是`pp.bat`，需要通过`cpan PAR::Packer`装上，perl/site/bin目录下找。打包工具除了命令行的pp外，还有Tk版的`tkpp`，也在同一目录下。

要打包成一个独立的exe，执行命令`pp --gui hello.pl`即可，会在当前目录生成`a.exe`。`--gui`表示隐藏命令行。

但是，我打包的wx程序，打开时光标会在主界面上转七八秒的圈圈，让人很不爽，不知道后台在搞什么鬼。

不打包perl解释器到exe的话，就没这个问题啦。`pp --gui --dependent hello.pl`。最后，记得把带有perl解释器的动态链接库放进去，我的是`perl526.dll`

**打包前后大小如下**

- 5.9M  all.7z
- 2.6M  hello.exe
- 160   hello.pl
- 118K  libgcc_s_dw2-1.dll
- 1.5M  libstdc++-6.dll
- 78K   libwinpthread-1.dll
- 2.1M  perl526.dll
- 3.6M  wxbase30u_gcc_custom.dll
- 3.0M  wxmsw30u_adv_gcc_custom.dll
- 11M   wxmsw30u_core_gcc_custom.dll
