---
layout: post
title:  "使用Spring进行依赖注入的三种用法 "
date:   2016-07-05 14:08:29 +0800
categories:
    - Programming
    - Java
tags:
    - Programming
    - Java
    - Spring
---

使用 Spring 框架进行依赖注入，可以通过XML配置文件，也可以通过Java注解。

<!-- more -->

## 1. 使用XML配置文件

XML的文件名任意，一般是applicationContext.xml或spring-config.xml

{%codeblock HelloWorld.java lang:java%}
package cn.corpro.iot.server.model;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 11:36
*/
public class HelloWorld {

private String name;

public void setName(String name) {
this.name = name;
}

public void printHello() {
System.out.printf("Spring 4: Hello %s!\n", name);
}
}
{%endcodeblock%}

{%codeblock applicationContext.xml lang:xml%}
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context"
xsi:schemaLocation="http://www.springframework.org/schema/beans
http://www.springframework.org/schema/beans/spring-beans.xsd
http://www.springframework.org/schema/context
http://www.springframework.org/schema/context/spring-context.xsd">

<bean id="helloBean" class="cn.corpro.iot.server.model.HelloWorld">
<property name="name" value="skyEarth"/>
</bean>
</beans>
{%endcodeblock%}

## 2. @Bean 注解

{%codeblock HelloWorld.java lang:java%}
package cn.corpro.iot.server.model;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 11:36
*/
public class HelloWorld {

private String name;

public void setName(String name) {
this.name = name;
}

public void printHello() {
System.out.printf("Spring 4: Hello %s!\n", name);
}
}
{%endcodeblock%}

{%codeblock Spring.java lang:java%}
package cn.corpro.iot.server.config;

import cn.corpro.iot.server.model.HelloWorld;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 13:39
*/
@Configuration
public class Spring {

@Bean(name = "helloBean2")
public HelloWorld helloWorld() {
return new HelloWorld();
}
}
{%endcodeblock%}

## 3. @Component 注解

@Component @Service @Repository @Controller是同一种东西，只是后三种表意性更强，更具体，也更常用。

使用组建扫描需要在配置里添加 `context:component-scan`

{%codeblock AnnotationTest.java lang:java%}
package cn.corpro.iot.server.model;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 14:03
*/
@Component("annotation-test")
public class AnnotationTest {

@Value("Wahaha")
private String name;

public void sayHello() {
System.out.println("Hello, I'm annotation test: " + name);
}
}
{%endcodeblock%}

{%codeblock spring.xml lang:xml%}
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context"
xsi:schemaLocation="http://www.springframework.org/schema/beans
http://www.springframework.org/schema/beans/spring-beans.xsd
http://www.springframework.org/schema/context
http://www.springframework.org/schema/context/spring-context.xsd">

<context:component-scan base-package="cn"/>
<bean id="helloBean" class="cn.corpro.iot.server.model.HelloWorld">
<property name="name" value="skyEarth"/>
</bean>
</beans>
{%endcodeblock%}

## 以上三种方法的使用测试：

{%codeblock Main.java lang:java%}
package cn.corpro.iot.server.main;

import cn.corpro.iot.server.config.Spring;
import cn.corpro.iot.server.model.AnnotationTest;
import cn.corpro.iot.server.model.HelloWorld;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 11:59
*/
public class Main {
public static void main(String[] args) {
((HelloWorld) new ClassPathXmlApplicationContext("spring.xml")
.getBean("helloBean")).printHello();

((HelloWorld) new AnnotationConfigApplicationContext(Spring.class)
.getBean("helloBean2")).printHello();

((AnnotationTest) new ClassPathXmlApplicationContext("spring.xml")
.getBean("annotation-test")).sayHello();
}
}

{%endcodeblock%}
