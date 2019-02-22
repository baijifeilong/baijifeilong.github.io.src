---
layout: post
title:  "使用Maven创建工程并导出为IDE项目"
date:   2016-07-06 21:41:16 +0800
categories:
    - Programming
    - Java
tags:
    - Programming
    - Maven
    - Java
---

## 1. 创建Java工程

{%codeblock lang:shell%}
mvn archetype:generate -DarchetypeArtifactId=maven-archetype-quickstart -DgroupId=bj -DartifactId=JavaDemo -DinteractiveMode=false
{%endcodeblock%}

<!-- more -->

也可以使用`mvn archetype:generate`开启交互模式，一路回车，除了groupId和artifactId。因为默认的原型就是maven-archetype-quickstart

## 创建Web工程

{%codeblock lang:shell%}
mvn archetype:generate -DarchetypeArtifactId=maven-archetype-webapp -DgroupId=bj -DartifactId=WebDemo -DinteractiveMode=false
{%endcodeblock%}

## 导出到eclipse

`mvn eclipse:eclipse`

## 导出到IDEA

`mvn idea:module`

## 参考：

eclipse:configure-workspace is used to add the classpath variable M2_REPO to Eclipse which points to your local repository and optional to configure other workspace features.

eclipse:eclipse generates the Eclipse configuration files.

eclipse:resolve-workspace-dependencies is used to download all missing M2_REPO classpath variable elements for all projects in a workspace. Used if the Eclipse project configuration files are committed to version control and other users need to resolve new artifacts after an update.

eclipse:clean is used to delete the files used by the Eclipse IDE.



idea:idea is used to execute the other three goals of this plugin: project, module, and workspace.

idea:project is used to generate the project file (*.ipr) needed for an IntelliJ IDEA Project.

idea:module is used to generate the module files (*.iml) needed for an IntelliJ IDEA Module.

idea:workspace is used to generate the workspace file (*.iws) needed for an IntelliJ IDEA Project.

idea:clean is used to delete the files relevant to IntelliJ IDEA.

截图：

![截图](/images/maven-example.jpg)
