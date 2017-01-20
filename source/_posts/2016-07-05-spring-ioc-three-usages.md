---
layout: post
title:  "Sprint IOC的三种用法 "
date:   2016-07-05 14:08:29 +0800
categories: it java
---

**1. XML配置**

XML的文件名任意，一般是applicationContext.xml或spring-config.xml

{%codeblock java%}
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

{%codeblock xml%}
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

**2. JavaConfig**

{%codeblock java%}
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

{%codeblock java%}
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

**3. 注解**

@Component @Service @Repository @Controller是同一种东西，后三种表意性更强

使用注解需要在配置里添加 `context:component-scan`

{%codeblock java%}
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

{%codeblock xml%}
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

**用法**

{%codeblock java%}
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
