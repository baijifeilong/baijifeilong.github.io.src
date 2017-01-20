---
layout: post
title:  "J2EE Servlet 示例"
date:   2016-07-05 15:26:26 +0800
categories: it java
---

**HelloWorldServlet**

{%codeblock java%}
package cn.corpro.iot.server.servlet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/5 15:21
*/
public class HelloWorldServlet extends HttpServlet {
@Override
protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
resp.getWriter().write("Hello Servlet");
}
}
{%endcodeblock%}

**web.xml**

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
version="3.1">
<servlet>
<servlet-name>s</servlet-name>
<servlet-class>cn.corpro.iot.server.servlet.HelloWorldServlet</servlet-class>
</servlet>

<servlet-mapping>
<servlet-name>s</servlet-name>
<url-pattern>/hello</url-pattern>
</servlet-mapping>
</web-app>
{%endcodeblock%}

**然后启动web服务器到/hello下查看效果**
