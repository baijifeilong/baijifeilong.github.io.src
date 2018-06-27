---
layout: post
title:  "Linux shell 下 VPN 的安装与使用"
date:   2016-07-01 11:54:36 +0800
categories:
    - OS
    - Linux
tags:
    - Linux
    - GFW
    - VPN
---

服务器Linux往往不安装图形界面，在这种情况下，翻越防火长城就得通过命令行进行安装配置了。本文为笔者在Ubuntu下使用PPTP协议VPN翻墙的简要记录。

<!-- more -->

## 1. 安装pptp-linux pptpsetup

- *pptp-linux*(http://pptpclient.sourceforge.net/) 是一个Linux下的PPTP客户端

- *pptpsetup*是pptp-linux的配置工具，如果不装这个，就得手动编写配置文件

在终端下输入命令 `sudo apt-get install pptp-linux pptpsetup`,安装*pptp-linux*和*pptpsetup*

## 2. 配置pptp-linux

`pptpsetup --create a --server a.krgjsq.xyz --username baijifeilong --password bugaosuni --encrypt`

`--create` 连接名，随便填写，最好短点，方便连接时用

`--server` 服务器地址，可以是域名或ip

`--username` 用户名

`--password` 密码

`--encrypt` 使用加密连接 此处看PPTP服务器的配置，一般情况应该需要

配置完成后，会生成文件`/etc/ppp/peers/a` 如有需要可根据官方文档删除或修改

## 3. 连接pptp服务器

`pon a` 后台连接，看不出来是否连接成功

`pon a debug dump logfd2 nodetach` 前台连接，并显示日志

连接完成后，运行`ifconfig`可以看到新建立的ppp0连接

## 4. 验证是否连接到服务器

运行`route -n` (-n不解析主机名，显示快)，会多出两条路由，类似

`10.0.0.4        0.0.0.0         255.255.255.255 UH    0      0        0 ppp0`

`45.32.147.207   192.168.0.1     255.255.255.255 UGH   0      0        0 em1`

其中`45.32.147.207`是pptp服务器的外网IP，`10.0.0.4`是pptp服务器的内网（VPN即虚拟局域网）IP
`ping 10.0.0.4` 如果可以ping通，说明成功连接到了pptp服务器

## 5. 翻越防火长城

VPN的设计初衷不是科学上网，pptp-linux默认也不开启科学上网模式。要开启科学上网模式，即全部流量（也可部分）都走VPN，使用命令`sudo route add default dev ppp0` 或 `sudo route add -net 0.0.0.0 dev ppp0`将ppp0设为默认路由。此处`dev`指device，设备，即网卡。

## 6. 验证是否可以科学上网

`ping www.google.com`

## 7. 备注：

### 7.1 自动启动科学上网

要想连接vpn后直接科学上网，可以在`/etc/ppp/ip-up.d/`目录中新建一个脚本文件，文件名任意，比如`baijifeilong`，将设置默认路由的命令写入此文件，并将此文件设为可执行。此目录中的所有脚本将在连接pptp服务器后执行。

{% codeblock shell %}
cd /etc/ppp/ip-up.d
printf "#! /bin/bash\nroute add default dev ppp0" | sudo tee baijifeilong
sudo chmod +x baijifeilong
{% endcodeblock%}

### 7.2 本地局域网设置

如果设置默认路由后，不能访问本地局域网，需要再填加一条路由，让本地连接走本地网卡。

`sudo route add -net 192.168.0.0 netmask 255.255.255.0 dev em1`

此处`192.168.0.0`是本地网络，一般也可能是`192.168.1.0`，`netmask`是子网掩码，`em1`是本地连接的网卡名，通过`ipconfig`可查
