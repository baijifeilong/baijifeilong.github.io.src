---
title: Ghost版Windows7在GPT分区的安装
categories:
  - OS
  - Windows
tags:
  - OS
  - Windows
  - Ghost
  - GPT
  - Window7
  - bcdboot
  - UEFI
date: 2018-12-10 21:24:25
---

**安装步骤**

1. 准备Ghost镜像，有些Ghost镜像需要外置驱动包，最好放到`D:\Drv`目录
2. Ghost镜像到磁盘，可以手动GHOST或一键Ghost
3. 修复引导（可能不需要）
4. 重启进入安装界面，完成安装

**什么情况不需要修复引导**

1. 之前装过Windows 7 (不一定不需要)
2. Ghost工具自动修复了引导，比如`SGI映像总裁`


**如何修复引导**

- 使用引导修复工具(最好注明支持ESP)。理论可行，但是我没成功过。
- 使用`bcdboot.exe`，在cmd命令行下执行`bcdboot c:\windows`(将C盘系统的引导写入默认的ESP分区，特殊情况根据`bcdboot /?查看帮助修改命令`)修复引导

**bcdboot哪里找**
1. 任意Windows Vista 或 Windows 7系统分区的`C:\Windows\System32\bcdboot.exe`(64bit系统带的是64bit的bcdboot)
2. EasyBCD安装目录(我的是32-bit)
3. PartAssist安装目录(36bit,64bit都有)

**bcdboot使用注意**
- 32bit的Windows PE执行不了64bit的bcdboot

**进不了Boot Loader怎么办**
- 使用EasyUEFI编辑或添加UEFI引导

**Boot Loader里没有Windows怎么办**
- 使用EasyBCD添加Windows引导项，也可以编辑引导项，调整顺序，修改默认项，修改等待时间等

**卡在安装界面怎么办**
- 重试，不行的话换系统


<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
