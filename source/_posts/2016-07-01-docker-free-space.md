---
layout: post
title:  "释放 Docker 浪费掉的磁盘空间"
date:   2016-07-01 16:56:22 +0800
categories: 
    - Application
tags:
    - Application
    - Docker
    - Linux
---

Docker在使用一段时间后，可能产生大量的垃圾文件，严重浪费磁盘空间。这时可以通过以下三条命令，释放Docker浪费掉的磁盘空间。

<!-- more -->

## 1. 清理 volume

Volume用于容器间文件共享和保存工作状态，可能会占用大量空间。比如笔者的Volume曾经占了十几个GB。

`docker volume ls -qf dangling=true | xargs -r docker volume rm` 筛选无用的volume并删除

## 2. 清理镜像

`docker rmi $(docker images -f "dangling=true" -q)` 筛选无用的image并删除

## 3. 清理容器（数据无价，谨慎操作）

`docker rm -v $(docker ps -a -q -f status=exited)` 删除所有不在运行中的容器
