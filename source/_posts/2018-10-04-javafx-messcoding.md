---
title: JavaFX乱码解决
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Kotlin
  - JavaFX
  - TornadoFX
  - GUI
  - Desktop
  - Font
date: 2018-10-04 00:49:25
---

JavaFX乱码是因为字体不支持中文。切换默认字体即可。

以TornadoFX代码为例，将默认字体换为Noto

```kotlin
package bj

import tornadofx.*

class MyView : View() {
    override val root = vbox {
        button("天地玄黄")
        button("宇宙洪荒")
    }
}

class MyStylesheet : Stylesheet() {
    init {
        root {
            fontFamily = "Noto Sans CJK SC Regular"
        }
    }
}

class MyApp : App(MyView::class, MyStylesheet::class)

fun main(args: Array<String>) {
    launch<MyApp>(*args)
}
```
