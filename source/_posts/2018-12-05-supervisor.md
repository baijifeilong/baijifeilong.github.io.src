---
title: Supervisor大杂烩
categories:
  - Application
tags:
  - Application
  - Supervisor
date: 2018-12-05 20:14:16
---

# Supervisor大杂烩

## Supervisor是什么

[Supervisor](https://github.com/Supervisor/supervisor)是类UNIX系统上的一个进程管理工具，用于进程的批量启动、停止、配置、守护与监控。Supervisor默认情况下会自动重启挂掉的进程

## Supervisor的安装

`brew install supervisor`

## Supervisor的启动

理论上`brew services start supervisor`可以启动，但是我启动不了。

执行命令`supervisor`即可在后台启动`Supervisor`。如果要启动到前台，可以执行命令`supervisor --nodaemon`

`Supervisor`默认使用的配置文件是`/usr/local/etc/supervisord.conf`，但是用`Homebrew`安装的`Supervisor`的配置文件是`supervisord.ini`，需要改名使用，或者直接指定配置文件

## Supervisor开启Web管理界面

Supervisor默认不开启Web管理界面。注释掉配置文件中的`[inet_http_server]`和下一行的`port=...`后，重启服务即可启用Web后台

<!--more-->

## Supervisor添加程序示例

1. 一个一直守在后台啥也不干的程序

```ini
[program:helloworld]
command=tail -f /dev/null
```

2. 在后台每隔一秒报时一次的程序

```
[program:clock]
command=bash -c 'while `true`; do date; sleep 1; done'
```

## Supervisor常用命令

1. `supervisord --nodaemon` 前台启动Supervisor服务
2. `supervisorctl -i` 进入交互式Shell
3. `supervisorctl status` 查看任务列表
4. `supervisorctl status helloworld` 查看指定任务的状态
5. `supervisorctl stop/start/restart all ` 结束/启动/重启所有任务
6. `supervisorctl stop/start/restart helloworld` 结束/启动/重启指定任务
7. `supervisorctl reread` 重新加载配置文件，不增减任务
8. `supervisorctl update all` 重新加载配置文件，并进行必要的增减任务
9. `supervisorctl remove/add` 移除/添加任务(配置文件中已经存在的任务)
10. `supervisorctl tail -f helloworld` 实时查看任务的控制台输出
11. `supervisorctl tail -f helloworld stderr` 实时查看任务的控制台错误输出
12. `supervisorctl reload` 重启Supervisor服务
13. `supervisorctl fg helloworld` 将任务拉到前台，此时`Ctrl+C`不会结束任务，而是将任务放回后台
14. `supervisorctl shutdown` 终止Supervisor服务
15. `supervisorctl clear all` 清楚所有进程的日志文件
16. `supervisorctl maintail -f` 实时查看Supervisor服务的日志文件
17. `supervisorctl signal SIGTERM all` 结束所有进程
18. `supervisorctl signal SIGKILL all` 杀死所有进程
19. `supervisorctl --serverurl http://localhost:9001 status` 管理远程Supervisor服务

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
