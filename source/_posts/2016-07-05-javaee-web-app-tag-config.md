---
layout: post
title:  "JavaEE 7 下 web.xml 需要更新模式命名空间"
date:   2016-07-05 10:53:16 +0800
categories:
    - Programming
    - Java
tags:
    - Java
    - J2EE
---

从Java EE 7开始，甲骨文更换了模式命名空间。因此，在新版本的java中，需要更新`web.xml`中`web-app`标签的`xmlns`属性。旧版本可以保持不变。

<!-- more -->

## 1. web-app 3.0

{%codeblock web.xml lang:xml%}
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
http://java.sun.com/xml/ns/javaee/web-app_3_1.xsd"
version="3.0">

</web-app>
{%endcodeblock%}

## 2. web-app 3.1

{%codeblock web.xml lang:xml%}
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
version="3.1">

</web-app>
{%endcodeblock%}
