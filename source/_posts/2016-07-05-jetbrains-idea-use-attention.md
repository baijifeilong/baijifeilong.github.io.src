---
layout: post
title:  "Intellij IDEA 的使用技巧"
date:   2016-07-05 15:31:36 +0800
categories:
    - Programming
    - Java
tags:
    - Programming
    - IDE
    - Java
---

## 1. 使用IDEA开发J2EE，不自动加载依赖

使用IDEA开发J2EE，不自动加载依赖，所以需要手动加载

`Ctrl+Shift+Alt+S`打开工程属性，选择`Artifacts->Output Layout`,将右边的可用库放入左边的输出目录，这样这些jar将会自动放到web项目的布署目录的`WEB-INFO/lib`目录下，不然Web程序运行时会找不到类。

<!-- more -->

## 2. Jetbrains使用FiraCode字体

FiraCode字体支持连字。在换用FiraCode字体后，还需要在字体选项中启用连字(Enable font igatures)

## 3. Jetbrains常用插件:

- BashSupport
- Close All Processes
- CodeGlance
- Grep Console
- JRebel for IntelliJ
- Key Promoter X
- Lombok Plugin
- Nyan Progress Bar
- String Manipulation

![Jetbrains IDEA use attention](/images/jetbrains-idea-use-attention.jpg)
