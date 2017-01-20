---
layout: post
title:  "Struts2 示例"
date:   2016-07-05 16:00:43 +0800
categories: it java
---

**1. web.xml配置**

{%codeblock xml%}
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
</web-app>
{%endcodeblock%}

**2. struts配置（文件名必须是struts..xml）**

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
"-//Apache Software Foundation//DTD Struts Configuration 2.0//EN"
"http://struts.apache.org/dtds/struts-2.0.dtd">
<struts>
<package name="root" namespace="/" extends="struts-default">
<action name="home">
<result>struts/helloStruts.jsp</result>
</action>
</package>
</struts>
{%endcodeblock%}

**3. 运行服务器，打开/home看效果**

# 使用Action

**1. struts配置（文件名必须是struts..xml）**

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
"-//Apache Software Foundation//DTD Struts Configuration 2.0//EN"
"http://struts.apache.org/dtds/struts-2.0.dtd">
<struts>
<package name="root" namespace="/" extends="struts-default">
<action name="home">
<result>struts/helloStruts.jsp</result>
</action>

<action name="helloStruts" class="cn.corpro.iot.server.action.HelloStrutsAction">
<result name="success">struts/success.jsp</result>
<result name="error">struts/error.jspx</result>
</action>
</package>
</struts>
{%endcodeblock%}

**2. action文件**

{%codeblock java%}
package cn.corpro.iot.server.action;

import com.opensymphony.xwork2.ActionSupport;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 16:10
*/
public class HelloStrutsAction extends ActionSupport {
@Override
public String execute() throws Exception {
return System.currentTimeMillis() % 2 == 0 ? SUCCESS : ERROR;
}
}
{%endcodeblock%}

**3. 运行服务器，打开/helloStruts看效果**

# 使用注解

**1. 添加依赖，注解需要struts2-convention-plugin**

{%codeblock xml%}
<dependency>
<groupId>org.apache.struts</groupId>
<artifactId>struts2-convention-plugin</artifactId>
<version>2.5.1</version>
</dependency>
{%endcodeblock%}

**2. Action**

{%codeblock java%}
package cn.corpro.iot.server.action;

import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.ResultPath;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 16:51
*/

@Namespace("/users")
@ResultPath(value = "/")
@Result(name = "success", location = "login.jsp")
public class LoginAction extends ActionSupport {
}
{%endcodeblock%}


{%codeblock java%}
package cn.corpro.iot.server.action;

import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.ResultPath;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 16:56
*/

@Namespace("/users")
@ResultPath(value = "/")
public class WelcomeAction extends ActionSupport {

private String username;

public String getUsername() {
return username;
}

public void setUsername(String username) {
this.username = username;
}

@Action(value = "welcome", results = {
@Result(name = "success", location = "welcome.jsp")
})
@Override
public String execute() throws Exception {
return super.execute();
}
}
{%endcodeblock%}

**3. 不需要xml配置**

**4. 运行服务器，打开/users/login看效果**

**注意**

1. 添加依赖后，不要忘了将jar加入IDEA的Output layout，否则注解不生效

2. 如果不用根命名空间，jsp文件也要放入相应的命名空间，如`/users/login.jsp`

3. 如果不设置`@ResultPath(value = "/")`，struts2将会去`/WEB-INF/content/`目录下寻找视图文件，一般jsp文件不放这位置。可在struts.xml中设置默认值`<constant name="struts.convention.result.path" value="/"/>`

4. 如果只用注解的话，struts2和spring都可以完全抛弃xml配置文件

{%codeblock java%}
{%endcodeblock%}

{%codeblock java%}
{%endcodeblock%}
