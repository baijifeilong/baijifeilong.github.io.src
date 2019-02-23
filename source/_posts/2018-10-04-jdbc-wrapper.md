---
title: JDBC的简单封装
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Database
  - JDBC
  - Kotlin
  - Utils
date: 2018-10-04 11:28:10
---

JDBC的API使用过于繁琐，一般情况需要封装后使用

<!--more-->

## 代码

```kotlin
package bj

import ch.qos.logback.classic.Level
import ch.qos.logback.classic.Logger
import ch.qos.logback.classic.encoder.PatternLayoutEncoder
import ch.qos.logback.core.ConsoleAppender
import ch.qos.logback.core.Context
import org.intellij.lang.annotations.Language
import org.slf4j.LoggerFactory
import java.sql.DriverManager

class MyDb(url: String, user: String, password: String) {
    private val logger = LoggerFactory.getLogger(javaClass)
    private val connection = DriverManager.getConnection(url, user, password)

    fun select(@Language("MySQL") sql: String): List<MutableMap<String, Any>> {
        logger.info("SELECTING: $sql")
        val statement = connection.createStatement()
        val resultSet = statement.executeQuery(sql)
        val list = mutableListOf<MutableMap<String, Any>>()
        while (resultSet.next()) {
            val map = resultSet.metaData.columnCount.downTo(1).reversed().map {
                resultSet.metaData.getColumnName(it) to resultSet.getObject(it)
            }.toMap().toMutableMap()
            list.add(map)
        }
        logger.info("RESULTS(size=${list.size}):")
        list.forEach {
            logger.info(it.toString())
        }
        return list
    }

    fun insert(table: String, row: Map<String, Any>) {
        val sql = "INSERT INTO $table(${row.keys.joinToString(",")}) VALUES (${row.keys.size.downTo(1).joinToString(",") { "?" }})";
        logger.info("INSERTING: $sql")
        val preparedStatement = connection.prepareStatement(sql)
        row.values.forEachIndexed { index, any ->
            preparedStatement.setObject(index + 1, any)
        }
        val rowsCount = preparedStatement.executeUpdate()
        logger.info("INSERTED ROWS: $rowsCount")
    }

    fun update(table: String, where: String, what: Map<String, Any>) {
        val sql = "UPDATE $table SET ".plus(what.keys.joinToString { "$it=?" }).plus(" WHERE $where")
        logger.info("UPDATING: $sql")
        val preparedStatement = connection.prepareStatement(sql)
        what.values.forEachIndexed { index, any ->
            preparedStatement.setObject(index + 1, any)
        }
        val rowsCount = preparedStatement.executeUpdate()
        logger.info("UPDATED ROWS: $rowsCount")

    }

    fun execute(@Language("MySQL") sql: String) {
        logger.info("EXECUTING: $sql")
        val rowsEffected = connection.createStatement().executeUpdate(sql)
        logger.info("EFFECTED ROWS: $rowsEffected")
    }
}

private fun initLogging() {
    (LoggerFactory.getLogger("ROOT") as Logger).apply {
        level = Level.TRACE
        (getAppender("console") as ConsoleAppender).encoder = PatternLayoutEncoder().apply {
            context = LoggerFactory.getILoggerFactory() as Context
            pattern = "[%date] %highlight([%level]) [%logger{10} %file:%line] %msg%n"
            start()
        }
    }
}

fun main(args: Array<String>) {
    initLogging()
    val db = MyDb("jdbc:mysql://localhost/foo?characterEncoding=UTF-8", "foo", "foo")
    db.execute("DROP TABLE IF EXISTS user")
    db.execute("CREATE TABLE user(id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT, username VARCHAR(255) NOT NULL UNIQUE, password VARCHAR(255))")
    arrayOf("ant", "bee", "cat").forEach {
        db.insert("user", mapOf("username" to it, "password" to it.toUpperCase()))
    }
    db.update("user", "username = 'ant'", mapOf("password" to "changed"))
    db.select("SELECT * FROM user").forEach { println(it) }
}
```

## 输出

```
[2018-10-04 11:26:53,226] [INFO] [bj.MyDb Bar.kt:58] EXECUTING: DROP TABLE IF EXISTS user
[2018-10-04 11:26:53,246] [INFO] [bj.MyDb Bar.kt:60] EFFECTED ROWS: 0
[2018-10-04 11:26:53,247] [INFO] [bj.MyDb Bar.kt:58] EXECUTING: CREATE TABLE user(id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT, username VARCHAR(255) NOT NULL UNIQUE, password VARCHAR(255))
[2018-10-04 11:26:53,323] [INFO] [bj.MyDb Bar.kt:60] EFFECTED ROWS: 0
[2018-10-04 11:26:53,351] [INFO] [bj.MyDb Bar.kt:36] INSERTING: INSERT INTO user(username,password) VALUES (?,?)
[2018-10-04 11:26:53,375] [INFO] [bj.MyDb Bar.kt:42] INSERTED ROWS: 1
[2018-10-04 11:26:53,375] [INFO] [bj.MyDb Bar.kt:36] INSERTING: INSERT INTO user(username,password) VALUES (?,?)
[2018-10-04 11:26:53,383] [INFO] [bj.MyDb Bar.kt:42] INSERTED ROWS: 1
[2018-10-04 11:26:53,383] [INFO] [bj.MyDb Bar.kt:36] INSERTING: INSERT INTO user(username,password) VALUES (?,?)
[2018-10-04 11:26:53,406] [INFO] [bj.MyDb Bar.kt:42] INSERTED ROWS: 1
[2018-10-04 11:26:53,407] [INFO] [bj.MyDb Bar.kt:47] UPDATING: UPDATE user SET password=? WHERE username = 'ant'
[2018-10-04 11:26:53,420] [INFO] [bj.MyDb Bar.kt:53] UPDATED ROWS: 1
[2018-10-04 11:26:53,421] [INFO] [bj.MyDb Bar.kt:17] SELECTING: SELECT * FROM user
[2018-10-04 11:26:53,425] [INFO] [bj.MyDb Bar.kt:27] RESULTS(size=3):
[2018-10-04 11:26:53,426] [INFO] [bj.MyDb Bar.kt:29] {id=1, username=ant, password=changed}
[2018-10-04 11:26:53,426] [INFO] [bj.MyDb Bar.kt:29] {id=2, username=bee, password=BEE}
[2018-10-04 11:26:53,426] [INFO] [bj.MyDb Bar.kt:29] {id=3, username=cat, password=CAT}
{id=1, username=ant, password=changed}
{id=2, username=bee, password=BEE}
{id=3, username=cat, password=CAT}
```
