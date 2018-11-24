---
title: MySQL联合索引VS单列索引
categories:
  - Programming
  - MySQL
tags:
  - Programming
  - MySQL
date: 2018-11-22 11:36:45
---

以一个一千万数据量的表格为例

## 1. 建表建索引

```sql
USE foo;
DROP TABLE IF EXISTS tmp;
CREATE TABLE tmp (
  id         INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  school_id  INT UNSIGNED NOT NULL,
  student_id INT UNSIGNED NOT NULL,
  INDEX school_id(school_id),
  INDEX student_id(student_id),
  INDEX school_id_and_student_id(school_id, student_id)
);
```

## 2. 插入1000万条数据

```sql
DROP PROCEDURE IF EXISTS tmpproc;
CREATE PROCEDURE tmpproc() BEGIN
  DECLARE i INT UNSIGNED DEFAULT 0;
  DECLARE j INT UNSIGNED DEFAULT 0;
  WHILE i < 100000 DO
    SET i = i + 1;
    SET j = 0;
    START TRANSACTION;
    WHILE j < 100 DO
      INSERT INTO tmp (school_id, student_id) VALUES (i, i * 100 + j);
      SET j = j + 1;
    END WHILE;
    COMMIT;
  END WHILE;
END;
CALL tmpproc();
```

<!--more-->

字符串做索引的情况:

```sql
USE foo;
DROP TABLE IF EXISTS tmp;
CREATE TABLE tmp (
  id         INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  school_id  CHAR(4) NOT NULL,
  student_id CHAR(6) NOT NULL,
  INDEX school_id(school_id),
  INDEX student_id(student_id),
  INDEX school_id_and_student_id(school_id, student_id)
);
DROP PROCEDURE IF EXISTS tmpproc;
CREATE PROCEDURE tmpproc() BEGIN
  DECLARE i INT UNSIGNED DEFAULT 0;
  WHILE i < 10000000 DO
    INSERT INTO tmp (school_id, student_id)
    VALUES (SUBSTR(MD5(RAND()) FROM 1 FOR 4), SUBSTR(MD5(RAND()) FROM 1 FOR 6));
    SET i = i + 1;
  END WHILE;
END;
CALL tmpproc();
```

## 3. 查询速度比较

### 走联合索引

```sql
SELECT *
FROM tmp
WHERE school_id = 88888
  AND student_id = 8888888;
```

耗时 9ms

### 走单列索引

```sql
SELECT *
FROM tmp
WHERE student_id = 7777777;
```

耗时 9ms

多执行几次后，两个查询耗时互有出入

## 4. 结论

在查询速度上没什么区别。至少在1000万的数据量上很难体现出来。字符串做索引也差不多。

## SQL日志

```sql
[2018-11-22 10:53:50] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> USE foo
[2018-11-22 10:53:50] completed in 25 ms
[2018-11-22 10:53:50] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> DROP TABLE IF EXISTS tmp
[2018-11-22 10:53:51] completed in 682 ms
[2018-11-22 10:53:51] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> CREATE TABLE tmp (
       id         INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
       school_id  INT UNSIGNED NOT NULL,
       student_id INT UNSIGNED NOT NULL,
       INDEX school_id(school_id),
       INDEX student_id(student_id),
       INDEX school_id_and_student_id(school_id, student_id)
     )
[2018-11-22 10:53:51] completed in 45 ms
[2018-11-22 10:53:51] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> DROP PROCEDURE IF EXISTS tmpproc
[2018-11-22 10:53:51] completed in 7 ms
[2018-11-22 10:53:51] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> CREATE PROCEDURE tmpproc() BEGIN
       DECLARE i INT UNSIGNED DEFAULT 0;
       DECLARE j INT UNSIGNED DEFAULT 0;
       WHILE i < 100000 DO
         SET i = i + 1;
         SET j = 0;
         START TRANSACTION;
         WHILE j < 100 DO
           INSERT INTO tmp (school_id, student_id) VALUES (i, i * 100 + j);
           SET j = j + 1;
         END WHILE;
         COMMIT;
       END WHILE;
     END
[2018-11-22 10:53:51] completed in 3 ms
[2018-11-22 10:53:51] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> CALL tmpproc()
[2018-11-22 11:02:24] completed in 8 m 32 s 887 ms
[2018-11-22 11:02:24] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> select database()
[2018-11-22 11:02:24] completed in 14 ms
sql> SELECT *
     FROM tmp
     ORDER BY id DESC
[2018-11-22 11:02:24] 500 rows retrieved starting from 1 in 111 ms (execution: 8 ms, fetching: 103 ms)
[2018-11-22 11:02:24] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> select database()
[2018-11-22 11:02:24] completed in 10 ms
sql> SELECT *
     FROM tmp
     WHERE school_id = 88888
       AND student_id = 8888888
[2018-11-22 11:02:24] 1 row retrieved starting from 1 in 116 ms (execution: 9 ms, fetching: 107 ms)
[2018-11-22 11:02:24] [1287] '@@tx_isolation' is deprecated and will be removed in a future release. Please use '@@transaction_isolation' instead
sql> select database()
[2018-11-22 11:02:24] completed in 7 ms
sql> SELECT *
     FROM tmp
     WHERE student_id = 7777777
[2018-11-22 11:02:24] 1 row retrieved starting from 1 in 87 ms (execution: 9 ms, fetching: 78 ms)
```

文章首发[https://baijifeilong.github.io/2018/11/22/mysql-index-single-vs-union/](https://baijifeilong.github.io/2018/11/22/mysql-index-single-vs-union/)
