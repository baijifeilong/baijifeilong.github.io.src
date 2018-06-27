---
title: SpringBoot环境搭建
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - SpringBoot
  - SpringBootCLI
date: 2018-06-27 17:23:07
---

SpringBoot环境搭建主要有以下三种方式：

1. 在线生成(SpringInitailizr)
2. SpringBootCLI生成
3. 手动搭建

## 1. 在线生成

打开[start.spring.io](https://start.spring.io/)，根据需要填写group、artifact、springBootVersion、buildType、language、dependencies等选项，点击"Generate Project"即可生成打包好(zip格式)的SpringBoot工程

如果用`IntelliJ IDEA`，在新建项目对话框中，选择"Spring Initializr"，点击"Next"，配置好各选项，IDEA就会调用SpringInitializr帮助我们生成SpringBoot项目

<!--more-->

## 2. SpringBootCLI生成

SpringBootCLI的官方文档：[https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html](https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started-installing-spring-boot.html)

安装SpringBootCLI:

- macOS `brew tap pivotal/tap && brew install springboot`
- SDKMan `sdk install springboot`

生成SpringBoot项目:

- `spring init <project>` 生成Maven项目
- `spring init --build gradle <project>` 生成Gradle项目

## 3. 手动生成

前提：先生成一个Maven项目或Gradle项目

**App.java**
```java
package bj;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;

@SpringBootApplication
public class App implements ApplicationListener<ApplicationReadyEvent> {
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println("Ready.");
    }
}
```

### Maven项目

Maven项目在pom.xml添加如下内容

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.0.3.RELEASE</version>
</parent>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

其中，Maven插件是可选项。spring依赖的版本可由父模块`spring-boot-starter-parent`管理

运行项目: `mvn spring-boot:run` (需要插件)

### Gradle项目

Gradle项目在`build.gradle`中添加如下内容：

```groovy
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'org.springframework.boot:spring-boot-gradle-plugin:2.0.3.RELEASE'
    }
}

apply plugin: 'java'
apply plugin: 'org.springframework.boot'
apply plugin: 'io.spring.dependency-management'

dependencies {
    compile 'org.springframework.boot:spring-boot-starter'
    testCompile 'org.springframework.boot:spring-boot-starter-test'
}

repositories {
    mavenCentral()
}
```

以上配置全部必填。跟Maven不一样，Gradle要用插件`io.spring.dependency-management`来管理Spring的依赖版本。`io.spring.dependency-management`又依赖于`org.springframework.boot`，所以这俩插件都要添加。

运行项目：`gradle bootRun`

**注意**：

- 项目主类必须放到非空包中(也就是.java文件中第一行必须有package声明)，否则`gradle bootRun`的时候会报一个诡异的错误：`java.lang.ClassNotFoundException: org.springframework.dao.DataAccessException`

- 添加gradle插件的语法必须使用"apply :plugin <plugin>"，不能使用"plugins {id <plugin>}"，否则会出错(依赖的版本不能由Spring插件管理，导致没法识别与下载依赖)

