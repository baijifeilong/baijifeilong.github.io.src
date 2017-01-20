---
layout: post
title:  "JavaEE的web-app标签配置"
date:   2016-07-05 10:53:16 +0800
categories: it java
---

**从Java EE 7开始，甲骨文更换了模式命名空间，之前版本不变**

**web-app 3.0**

{%codeblock xml%}
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
http://java.sun.com/xml/ns/javaee/web-app_3_1.xsd"
version="3.0">

</web-app>
{%endcodeblock%}

**web-app 3.1**

{%codeblock xml%}
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
version="3.1">

</web-app>
{%endcodeblock%}
