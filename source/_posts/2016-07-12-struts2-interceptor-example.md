---
layout: post
title:  "Struts2 拦截器示例"
date:   2016-07-12 14:29:40 +0800
categories:
    - Programming
    - Java
tags:
    - Programming
    - Java
    - Struts
---

## 1. 拦截器定义

<!-- more -->

{%codeblock AppInterceptor.java lang:java%}
package cn.corpro.iot;

import cn.corpro.iot.util.Flash;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/11 11:14
*/
public class AppInterceptor extends AbstractInterceptor implements AppConfig {

private static final Logger LOGGER = LoggerFactory.getLogger(AppInterceptor.class);

private static final String KEY_LAST_ACTION = "lastAction";

@Override
public String intercept(ActionInvocation invocation) throws Exception {

LOGGER.info("-----Intercepting-----");

Map<String, Object> session = invocation.getInvocationContext().getSession();

LOGGER.info("flash: {}", session.get(KEY_FLASH));

if (invocation.getProxy().getActionName().equals(session.get(KEY_LAST_ACTION))) {
session.put(KEY_FLASH, new Flash());
}
session.put(KEY_LAST_ACTION, invocation.getProxy().getActionName());
return invocation.invoke();
}
}
{%endcodeblock%}

注：此拦截器勉强实现了Flash作用域

## 2. Struts 配置

{%codeblock struts.xml lang:xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
"-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
"http://struts.apache.org/dtds/struts-2.3.dtd">
<struts>
<constant name="struts.convention.result.path" value="/"/>
<constant name="struts.custom.i18n.resources" value="i18n"/>

<package name="base" extends="struts-default">
<interceptors>
<interceptor name="appInterceptor" class="cn.corpro.iot.AppInterceptor"/>
<interceptor-stack name="appInterceptorStack">
<interceptor-ref name="appInterceptor"/>
<interceptor-ref name="defaultStack"/>
</interceptor-stack>
</interceptors>

<default-interceptor-ref name="appInterceptorStack"/>
</package>

<package name="root" extends="base">
<action name="" class="cn.corpro.iot.action.HomeAction" method="index">
<result>home.jsp</result>
</action>

<action name="redirect" class="cn.corpro.iot.action.HomeAction" method="redirect">
</action>
</package>
</struts>
{%endcodeblock%}

注：

1. `default-interceptor-ref`用来设置默认的拦截器

2. 可以使用package的extends来让每个包继承同样的拦截器
