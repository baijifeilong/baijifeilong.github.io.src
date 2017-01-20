---
layout: post
title:  "Docker空间释放 "
date:   2016-07-01 16:56:22 +0800
categories: it linux
---

Docker在使用一段时间后，可能硬盘就没空间了，这时需要清理一下。

**1. 清理 volume**

Volume用于容器间文件共享和保存工作状态，可能会占用大量空间。我的Volume占了十几个GB。

`docker volume ls -qf dangling=true | xargs -r docker volume rm` 筛选无用的volume并删除

**2. 清理镜像**

`docker rmi $(docker images -f "dangling=true" -q)` 筛选无用的image并删除

**3. 清理容器（慎重！数据无价）**

`docker rm -v $(docker ps -a -q -f status=exited)` 删除不在运行中的容器，慎重！！
