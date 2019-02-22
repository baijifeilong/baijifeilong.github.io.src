---
title: Linux全局代理跳过国内IP
categories:
  - OS
  - Linux
tags:
  - OS
  - Linux
  - Proxy
  - Ipset
date: 2018-12-10 20:31:45
---

# Linux全局代理跳过国内IP

## 1. 安装ipset

`sudo pacman -S ipset`

## 2. 配置ipset

1. `sudo ipset create china hash:net`
2. `wget http://www.ipdeny.com/ipblocks/data/countries/cn.zone`
3. `for i in $(cat cn.zone); do sudo ipset add china $i; done`

## 3. 持久化ipset配置

`sudo ipset save | sudo tee /etc/ipset.conf`
`sudo systemctl enable ipset`
`sudo systemctl start ipset`

## 4. 测试ipset

`sudo ipset test china 114.114.114.114` 返回in
`sudo ipset test china 8.8.8.8` 返回not in

## 5. 配置ipset到iptables规则

`sudo vim /etc/iptables/redsocks.conf`

添加一行

`-A REDSOCKS -p tcp -m set --match-set china dst -j RETURN`

## 6. 应用ipset

`sudo iptables-restore < /etc/iptables/redsocks.rules`

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
