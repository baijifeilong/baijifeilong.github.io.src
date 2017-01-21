---
layout: post
title:  "在Struts2 中集成 Spring4"
date:   2016-07-08 14:10:43 +0800
categories:
    - Programming
    - Java
tags:
    - Java
    - Struts
    - Spring
---

## 1. 安装struts2-spring-plugin依赖

{%codeblock pom.xml lang:xml%}
<dependency>
<groupId>org.apache.struts</groupId>
<artifactId>struts2-spring-plugin</artifactId>
<version>2.5.1</version>
</dependency>
{%endcodeblock%}

<!-- more -->

## 2. 在web.xml中配置Spring监听器

{%codeblock web.xml lang:xml%}
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
version="3.1">
<filter>
<filter-name>struts2</filter-name>
<filter-class>org.apache.struts2.dispatcher.filter.StrutsPrepareAndExecuteFilter</filter-class>
</filter>

<filter-mapping>
<filter-name>struts2</filter-name>
<url-pattern>/*</url-pattern>
</filter-mapping>

<listener>
<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>

<context-param>
<param-name>contextConfigLocation</param-name>
<param-value>/WEB-INF/classes/spring.xml</param-value>
</context-param>
</web-app>
{%endcodeblock%}

注：contextConfigLocation缺省为applicationContext.xml

## 3. 在Struts中使用Spring注入Action

Spring配置

{%codeblock applicationContext.xml lang:xml%}
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context"
xsi:schemaLocation="http://www.springframework.org/schema/beans
http://www.springframework.org/schema/beans/spring-beans.xsd
http://www.springframework.org/schema/context
http://www.springframework.org/schema/context/spring-context.xsd">

<context:component-scan base-package="cn.corpro.iot"/>

<bean class="cn.corpro.iot.service.UserService" id="userService"/>

<bean class="cn.corpro.iot.action.UserAction" id="userAction">
<property name="userService" ref="userService"/>
</bean>
</beans>
{%endcodeblock%}

注：Spring也可使用@Component(@Service, @Controller, @Repository)和@Autowired(@Inject)俩注解进行注入。

Struts配置

{%codeblock struts.xml lang:xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
"-//Apache Software Foundation//DTD Struts Configuration 2.0//EN"
"http://struts.apache.org/dtds/struts-2.0.dtd">
<struts>
<constant name="struts.convention.result.path" value="/"/>
<constant name="struts.custom.i18n.resources" value="i18n"/>

<package name="users" namespace="/users" extends="struts-default">
<action name="login" class="userAction" method="signIn">
<result>fsd</result>
</action>
</package>
</struts>
{%endcodeblock%}

struts.package.action.class中的userAction即为Spring Bean
