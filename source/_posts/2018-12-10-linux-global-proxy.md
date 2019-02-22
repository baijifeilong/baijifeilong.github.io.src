---
title: Linux全局代理
categories:
  - OS
  - Linux
tags:
  - OS
  - Linux
  - Redsocks
  - PCap
  - DNS
  - DNSProxy
  - IPTables
date: 2018-12-10 20:33:17
---

# Linux全局代理

Linux的全局代理需要通过iptables配置

以ArchLinux为例

## 1. 安装Redsocks

Redsocks用于转发连接到socks代理

安装 `yaourt -S --noconfirm redsocks-git`

配置Redsocks

`vim /etc/redsocks.conf`

1. 修改`redsocks -> ip`为Socks代理的IP
2. 修改`redsocks -> port`为Socks代理的端口
3. 删除或注释掉 `redudp` 部分
4. 删除或注释掉 `dnstc` 部分

## 2. 安装pcap-dnsproxy-git

PCap用于搭建本地DNS服务器，对抗DNS污染。必须安装，Redsocks默认走
本机53端口的DNS服务器，不知道在哪可以配置

## 3. 配置Iptables

将不需要或不能走代理的IP加入规则列表

一般情况下，Shadowsocks代理需要忽略远程Shadowsocks服务器的ip
和本地Socks服务器的ip(本地一般为127.0.0.1 不需要设置)

`vim /etc/iptables/redsocks.rules`

`-A REDSOCKS -d <SHADOWSOCKS.IP> -j RETURN`

## 4. 启动服务

`systemctl start iptables pcap-dnsproxy redsocks`

## 5. 应用Redsocks的Iptables规则

`sudo iptables-restore < /etc/iptables/redsocks.rules`

取消全局代理: `sudo /usr/lib/systemd/scripts/iptables-flush`

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
