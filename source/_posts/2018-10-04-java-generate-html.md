---
title: Java组装HTML
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Generator
  - HTML
  - j2html
date: 2018-10-04 01:24:56
---

有时候，业务需要组装HTML，又不想用JSP等模板引擎。这种情况下，可以考虑以下几个办法。

以SpringBoot的Kotlin工程为例

## 1. 直接组装HTML

```kotlin
package bj

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import tk.mybatis.spring.annotation.MapperScan

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/6/28 下午3:18
 */
@SpringBootApplication
@MapperScan(basePackageClasses = [App::class])
@RestController
class App {

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }

    @RequestMapping("/{height}/{text}", produces = [MediaType.TEXT_HTML_VALUE])
    fun index(@PathVariable height: Int, @PathVariable text: String) =
            "<body style='margin: 0'><div style='width: 100%; height: ${height}px; " +
                    "display: flex; justify-content: center; align-items: center; background: magenta; font-size: 36pt'>$text</div></body>"
}
```

## 2. 使用第三方库`j2html`

Gradle依赖：

```gradle
compile 'com.j2html:j2html:1.3.0'
```

App.kt
```kotlin
package bj

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import tk.mybatis.spring.annotation.MapperScan
import j2html.TagCreator.*

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/6/28 下午3:18
 */
@SpringBootApplication
@MapperScan(basePackageClasses = [App::class])
@RestController
class App {

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }

    @RequestMapping("/{height}/{text}", produces = [MediaType.TEXT_HTML_VALUE])
    fun home(@PathVariable height: Int, @PathVariable text: String): String = html(
            body(
                    div(
                            text(text)
                    ).withStyle("width: 100%; height: $height; display: flex; " +
                            "align-items:center; justify-content: center; background:magenta; font-size: 36pt")
            ).withStyle("margin: 0")
    ).render()
}
```
