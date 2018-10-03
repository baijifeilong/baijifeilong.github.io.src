---
title: MyBatis处理自定义枚举
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Enum
date: 2018-10-04 00:56:37
---

MyBatis自定义枚举处理

```java
package bj.configurer;

import bj.IntEnum;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedTypes;
import org.apache.ibatis.type.TypeHandler;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/7/19 上午11:57
 */
@MappedTypes(IntEnum.class)
public class MyEnumTypeHandler<T extends Enum<?> & IntEnum> implements TypeHandler<IntEnum> {

    private Class<T> type;

    public MyEnumTypeHandler(Class<T> type) {
        this.type = type;
    }

    @Override
    public void setParameter(PreparedStatement preparedStatement, int i, IntEnum intEnum, JdbcType jdbcType) throws SQLException {
        preparedStatement.setInt(i, intEnum.getCode());
    }

    @Override
    public IntEnum getResult(ResultSet resultSet, String s) throws SQLException {
        return enumOf(resultSet.getInt(s));
    }

    @Override
    public IntEnum getResult(ResultSet resultSet, int i) throws SQLException {
        return enumOf(resultSet.getInt(i));
    }

    @Override
    public IntEnum getResult(CallableStatement callableStatement, int i) throws SQLException {
        return enumOf(callableStatement.getInt(i));
    }

    private T enumOf(int code) {
        for (T t : type.getEnumConstants()) {
            if (t.getCode() == code) {
                return t;
            }
        }
        throw new IllegalArgumentException();
    }
}
```
