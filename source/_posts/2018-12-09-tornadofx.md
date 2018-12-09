---
title: TornadoFX大杂烩
categories:
  - Programming
tags:
  - Programming
date: 2018-12-09 19:54:48
---

# TornadoFX大杂烩

TornadoFX是为Kotlin语言准备的JavaFX开发框架

## 开发环境配置

1. 配置好Kotlin开发环境
2. 添加Graldle依赖`compile 'no.tornado:tornadofx:1.7.17'`
3. 配置项目编译格式为JVM8(否则部分功能编译不过)

```gradle
compileKotlin {
    kotlinOptions.jvmTarget = "1.8"
}
```

<!--more-->

## HelloWorld

```kotlin
import javafx.application.Application
import tornadofx.*

class App : tornadofx.App(MainView::class, MainStylesheet::class)

class MainView : View() {
    override val root = vbox {
        label("Hello World")
    }
}

class MainStylesheet : Stylesheet() {
    init {
        label {
            fontSize = 20.px
        }
    }
}

fun main(args: Array<String>) {
    Application.launch(App::class.java, *args)
}
```

## 进阶之Observable

```kotlin
import javafx.application.Application
import javafx.collections.FXCollections
import tornadofx.*

class App : tornadofx.App(MainView::class, MainStylesheet::class)

class Person(id: Int, name: String) {
    var id: Int by property(id)
    var name: String by property(name)
}

class MainView : View() {
    private val persons = FXCollections.observableArrayList(
            Person(10, "Ant"),
            Person(20, "Bee"),
            Person(30, "Cat")
    )
    override val root = tableview(persons) {
        column("ID", Person::id)
        column("name", Person::name)
    }
}

class MainStylesheet : Stylesheet() {
    init {
        label {
            fontFamily = "Noto Sans CJK SC Medium"
            fontSize = 20.px
        }
    }
}

fun main(args: Array<String>) {
    Application.launch(App::class.java, *args)
}

```

注意:

- JavaFX可能对中文支持不好，最要手动设置中g字体



文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
