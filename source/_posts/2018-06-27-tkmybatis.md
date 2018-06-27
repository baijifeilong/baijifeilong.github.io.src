---
title: TkMyBatis大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - MyBatis
  - TkMyBatis
date: 2018-06-27 17:28:49
---

## 1. 什么是TkMyBatis

TkMyBatis是一个MyBatis的通用Mapper工具

## 2. 引入TkMyBatis到SpringBoot项目

以Gradle为例
```gradle
compile 'tk.mybatis:mapper-spring-boot-starter:2.0.3'
```

## 3. 基本用法

1. 创建模型类(不需要注解)
2. 创建Mapper接口，并继承tk.mybatis.mapper.common.Mapper<TheModel>(不需要注解)
3. 注册Mapper 通过MapperScan(tk包非MyBatis包)注解来注册全部的Mapper

示例：

<!--more-->

```java
package bj;

import lombok.Data;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import tk.mybatis.mapper.common.Mapper;
import tk.mybatis.spring.annotation.MapperScan;

import javax.annotation.Resource;
import javax.persistence.Column;
import javax.persistence.Id;
import java.util.Date;

/**
 * Created by BaiJiFeiLong@gmail.com at 2018/6/26 下午1:51
 */
@SpringBootApplication
@MapperScan(basePackageClasses = App.class)
public class App implements ApplicationListener<ApplicationReadyEvent> {

    @Resource
    private PersonMapper personMapper;

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        System.out.println("selectAll");
        System.out.println(personMapper.selectAll());
        System.out.println("selectByPrimaryKey");
        System.out.println(personMapper.selectByPrimaryKey(6));
    }
}

@Data
class Person {
    @Id
    private Integer id;
    private String username;
    private String firstName;
    private Date createdAt;
    @Column(name = "the_remark")
    private String remark;
}

interface PersonMapper extends Mapper<Person> {
}
```

## 4. 模型类中的注解

TkMyBatis主要使用的是Jpa注解。一般情况下，如果模型属性与数据库名称一样的话，不需要特殊配置。

如果数据库用下划线命名法，模型类用驼峰命名法，不需要设置，TkMyBatis默认开启转换。

数据库字段与模型字段通过命名转换仍然不匹配的话，需要使用`@Column(name = "the_name")`来进行关联

如果需要用到TkMyBatis提供的主键相关方法，则需要在模型类中注解主键，比如`@Id`

## 5. 具体用法

集成Mapper接口后，我们的Mapper接口就有了大量的基础增删该查接口

- selectAll 查询全部记录
- selectByPrimaryKey 查询主键
- insert 插入一条记录(每个字段都会反映在SQL中)
- insertSelective 插入一条记录，值为null的字段不反映在SQL中，给数据库使用默认值的机会

