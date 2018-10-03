---
title: Java热部署
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - HotSwap
date: 2018-10-04 00:52:13
---

热部署分两种方案，HotSwap和JRebel。HotSwap通过调用JDK的DebuggerAPI实现热部署，但是仅限方法体的修改，增减方法会导致热部署失败。JRebel通过监控磁盘.class文件的变化，动态更新类，支持类结构的改变，比如增减方法。

IDEA天然支持HotSwap，如果用JRebel需要安装相应的插件`JRebel for IntelliJ`

IDEA中的`Reload`操作即为热部署。如果是普通方式启动项目，热部署方案使用`HotSwap`。如果项目用JRebel启动，热部署方案就使用`JRebel`

IDEA热部署的几种操作方式:

## 1. 重新编译当前java文件并重新加载

1. `Build -> Recompile __CURRENT__.java` 重新编译
2. `Run -> Reload Changed Classes` 重新加载发生变化的类

## 2. 重新编译整个项目并重新加载

1. `Build -> Rebuild Project` 重新构建项目
2. `Run -> Reload Changed Classes` 重新加载发生变化的类

## 3. 开启重新加载时自动构建项目，然后直接使用重新加载

`Build, Execution, Deployment -> HotSwap` 勾选 `Build project before reloading classes`

1. `Run -> Reload Changed Classes` 重新编译并重新加载发生变化的类

## 4. SpringBoot更新操作触发自动编译(仅支持SpringBoot)

在项目的运行配置界面，`Spring Boot -> Running Application Update Policies`，在`On Update action`下拉框中选择`Update classes and resources`，将会在更新操作触发后，自动进行重新编译

1. `Run -> Update __APP_NAME__ application` 此时会触发编译操作
2. `Run -> Reload Changed Classes`

如果将`On frame deactivation`设为`Update classes and resources`，将会在IDE窗体失焦后触发编译操作

## 一些热部署相关的配置:

1. `Build... -> Debugger -> HotSwap => Build project before reloading classes : true` 热部署前构建项目
2. `Build... -> Debugger -> HotSwap => Reload classes after compiliation : Always` 构建项目后热部署
3. 以上两项都勾选的话，无论是构建操作，还是Reload操作，都是先构建后Reload，都能进行完整的热部署
4. `JRebel -> Advanced => Enable IntelliJ automatic compiliation` JRebel开启IntelliJ自动编译 理论上开启此选项后，修改代码后会自动热部署，但是我的JRebel自动部署过几次后，就再也没有自动触发过

## 总结:

IDEA的热部署

对于HotSwap，需要Compile/Build + Reload

对于JRebel，仅需要Compile/Build。 Reload操作会由JRebel通过磁盘监控自动完成
