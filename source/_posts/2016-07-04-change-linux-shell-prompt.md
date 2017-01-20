---
layout: post
title:  "修改linux提示符 "
date:   2016-07-04 09:47:17 +0800
categories: it linux
---

1. `echo $PS1` 查看当前的提示符配置，我的是`\u@\h:\w\$`，此处u=user, h=host, w=workDirectory，分别表示用户、主机、工作目录

2. `PS1BACKUP=$PS1` 备份PS1的配置

3. `PS1="\u:\w\$"`修改PS1的值，立即生效
