---
title: Python连接MySQL
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - MySQL
  - SQL
  - Database
date: 2018-10-04 00:03:22
---

Python连接MySQL目前主要使用官方的python-mysql-connector和非官方的pymysql

## PyMySQL

### 示例代码

```python
import pymysql

connection = pymysql.connect(user='foo', password='foo', db='foo')

try:
    with connection.cursor() as cursor:
        cursor.execute("DROP TABLE IF EXISTS person")
        cursor.execute("CREATE TABLE person(id INTEGER PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255) NOT NULL)")
        cursor.execute("INSERT INTO person(name) VALUES ('ant'), ('bee'), ('cat')")
        cursor.execute("SELECT * FROM person")
        print(cursor.fetchall())
    connection.commit()
finally:
    connection.close()

```

<!--more-->

### 输出

```
((1, 'ant'), (2, 'bee'), (3, 'cat'))
```

## PythonMySQLConnector

### 示例代码

```python
import mysql.connector

conn = mysql.connector.connect(user='foo', password='foo', db='foo')
cursor = conn.cursor()
cursor.execute("DROP TABLE IF EXISTS person")
cursor.execute("CREATE TABLE person(id INTEGER PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255) NOT NULL)")
cursor.execute("INSERT INTO person(name) VALUES ('ant'), ('bee'), ('cat')")
cursor.execute("SELECT * FROM person")
result = cursor.fetchall()
for item in result:
    print(item)

```

### 输出

```
(1, 'ant')
(2, 'bee')
(3, 'cat')
```
