---
title: 搬瓦工穿墙的最佳姿势
categories:
  - OS
  - Linux
tags:
  - OS
  - Linux
  - Proxy
  - Shadowsocks
date: 2018-12-10 20:34:42
---

# 搬瓦工穿墙的最佳姿势

## 一、帐号注册

没有邀请码机制，直接注册即可。需要填写大量信息，或真或假都可以

## 二、服务器配置选择

年付19.99刀的10G硬盘VPS服务器即可

目前配置如下

> 10G VPS
> SSD: 10 GB RAID-10
> RAM: 512 MB
> CPU: 1x Intel Xeon
> Transfer: 500 GB/mo
> Link speed: 1 Gigabit
> Multiple locations
> $19.99/year

## 三、服务器机房选择

洛杉矶机房二选一（DC2 QNET、DC4 MCOM）。DC4为搬瓦工新加机房。
实际体验上半斤八两。
加拿大、荷兰机房最好不要选择。
根据概率论，美国与赵国的网络连接基数大，IP被封杀的机率低

## 四、服务器购买

支付宝购买即可。美刀自动换算为人民币

有6.25趴优惠码(BWH26FXH3HIQ)可用。优惠码来自网络，有效期不详。可省1.25美刀，最终需支付18.74美刀

## 五、服务器系统选择

默认系统是 `Centos 6 x86 bbr`。

BBR是谷歌出品的拥塞控制算法，据说优化网速有奇效

建议换为`Centos 7 x86_64 bbr`。Centos 6 太老，官方包的python只支持到2.6。没有Systemd服务管理工具

## 六、Shadowsocks服务安装

### 1. 安装Shadowsocks

1. `yum install -y epel-release` 安装Centos社区仓库，pip与sodium在里头
2. `yum install -y python2-pip libsodium git` pip和git用来安装Shadowsocks libsodium用于支持chacha20加密算法
3. `pip install git+https://github.com/shadowsocks/shadowsocks.git@master` 从Shadowsocks官方Git仓库的主分支下载Shadowsocks源码并安装

### 2. 添加Shadowsocks为Systemd服务

创建并填充 */usr/lib/systemd/system/myss.service*

```
[Unit]
Description=My shadowsocks server

[Service]
ExecStart=/usr/bin/ssserver -k password -m chacha20 -p 33333
```

### 3. 启动Shadowsocks服务

- `systemctl start myss` 启动服务
- `systemctl status myss` 查看服务运行状态
- stop 停止服务 restart 重启服务

## 七、Shadowsocks的使用

### 1. 运行本地代理服务

`sslocal -s <SERVER-HOST> -k password -m chacha20 -p 33333 -l 44444`

Shadowsocks会开启一个SOCKS5本地代理。

端口最好更改一下，减小被封杀机率

加密方法建议选择`chacha20`，CPU负载低，给搬瓦工公司节省几分钱电费

### 2. 测试代理是否工作

`curl --socks5-host localhost:44444 www.google.com`

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
