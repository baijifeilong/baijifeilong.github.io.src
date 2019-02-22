---
title: GoogleJSON风格接口的Java实现
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Google
  - JSON
  - API
date: 2018-10-04 01:03:05
---

```kotlin
package bj

import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageImpl

fun main(args: Array<String>) {
    val success = ApiSuccess.of("Hello")
    val failure = ApiFailure.of(1, "Dammit")
    val successWithPage = ApiSuccess.of(ApiPage.of(PageImpl(listOf(1, 2, 3))))

    val objectMapper = ObjectMapper().writerWithDefaultPrettyPrinter()
    println("Success: ${objectMapper.writeValueAsString(success)}")
    println("Failure: ${objectMapper.writeValueAsString(failure)}")
    println("SuccessWithPage: ${objectMapper.writeValueAsString(successWithPage)}")

}

// 接口成功返回
class ApiSuccess<T> private constructor(var data: T) {

    companion object {
        fun <T> of(t: T): ApiSuccess<T> {
            return ApiSuccess(t)
        }
    }
}

// 接口失败返回
class ApiFailure private constructor(code: Int, message: String) {
    var error: Error

    init {
        this.error = ApiFailure.Error(code, message)
    }

    companion object {
        fun of(code: Int, message: String): ApiFailure {
            return ApiFailure(code, message)
        }
    }

    data class Error(val code: Int, val message: String)
}

// 数据分页
data class ApiPage<T>(
        var pageIndex: Int,
        var itemsPerPage: Int,
        var totalItems: Long,
        var totalPages: Int,
        var currentItemCount: Int,
        var items: List<T>

) {
    companion object {
        fun <T> of(page: Page<T>): ApiPage<T> {
            return ApiPage(
                    pageIndex = page.number + 1,
                    itemsPerPage = page.size,
                    totalItems = page.totalElements,
                    totalPages = page.totalPages,
                    currentItemCount = page.content.size,
                    items = page.content
            )
        }
    }
}

```
