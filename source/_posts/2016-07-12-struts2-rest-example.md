---
layout: post
title:  "Struts2 REST 插件使用示例"
date:   2016-07-12 14:28:24 +0800
categories:
    - Programming
    - Java
tags:
    - Programming
    - Java
    - Struts
    - REST
---

## 1. struts 配置

<!-- more -->

{%codeblock struts.xml lang:xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
"-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
"http://struts.apache.org/dtds/struts-2.3.dtd">
<struts>
<constant name="struts.convention.result.path" value="/"/>
<constant name="struts.custom.i18n.resources" value="i18n"/>

<constant name="struts.convention.action.suffix" value="Action"/>
<constant name="struts.convention.action.mapAllMatches" value="true"/>
<constant name="struts.convention.default.parent.package" value="me"/>
<constant name="struts.convention.package.locators" value="action"/>

<package name="me" namespace="" extends="rest-default">
<interceptors>
<interceptor name="appInterceptor" class="cn.corpro.iot.AppInterceptor"/>
<interceptor-stack name="appInterceptorStack">
<interceptor-ref name="appInterceptor"/>
<interceptor-ref name="params"/>
<interceptor-ref name="restDefaultStack"/>
</interceptor-stack>
</interceptors>

<default-interceptor-ref name="appInterceptorStack"/>

<action name="" class="cn.corpro.iot.action.HomeAction" method="index">
<result>home.jsp</result>
</action>
</package>
</struts>
{%endcodeblock%}

注：

1. appInterceptor是自定义拦截器

2. 增加params拦截器自动赋值URL参数到Action

## 2. Controller 示例

{%codeblock PlantAction.java lang:java%}
package cn.corpro.iot.controller;

import cn.corpro.iot.model.Plant;
import com.opensymphony.xwork2.ModelDriven;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.rest.DefaultHttpHeaders;
import org.apache.struts2.rest.HttpHeaders;

import java.io.IOException;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/12 11:42
*/
public class PlantAction implements ModelDriven<Plant> {

private String id;

private String name;

@Override
public Plant getModel() {
return new Plant();
}

public HttpHeaders index() {
return new DefaultHttpHeaders("index");
}

public String show() throws IOException {
return "show";
}

public HttpHeaders showw() throws IOException {
ServletActionContext.getResponse().getWriter().write("showw");
return null;
}

public String getId() {
return id;
}

public void setId(String id) {
this.id = id;
}

public String getName() {
return name;
}

public void setName(String name) {
this.name = name;
}
}
{%endcodeblock%}

## 3. 视图文件

"show"对应`plant-show.jsp`，依此类推

## 备注

Struts的REST插件太严格，不支持自定义方法，跟普通Action放一块又冲突，不够灵活。
