---
layout: post
title:  "Linux 下进行磁盘空间管理的几条实用命令"
date:   2016-07-01 17:17:17 +0800
categories:
    - OS
    - Linux
tags:
    - OS
    - Linux
    - Shell
---

## 1. 查看硬盘使用情况

`df -h`

## 2. 查看一个目录下直接子文件夹的大小（只看子文件夹一层）

`du -hs * | sort -hr` 以人类可读格式列出子文件夹的大小，并以人类可读格式倒序排列

或者可以用命令：`du -h --max-depth=1 | sort -hr`

<!-- more -->

## 3. 列出一个目录下占用空间最大的十个文件或文件夹

`du -ah | sort -hr | head` head可用`-n`参数指定其他数目
