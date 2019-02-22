---
layout: post
title:  "Freemarker 简明用法"
date:   2016-07-07 15:30:31 +0800
categories:
    - Programming
    - Java
tags:
    - Programming
    - Java
    - Freemarker
    - TemplateEngine
---

简要记录Freemarker的基本用法，以备参考。

<!-- more -->

## 1. 创建模板

{%codeblock templates.ftl lang:xml%}
<#macro main title>
<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>${title}</title>

<link rel="stylesheet" href="libs/bootstrap-3.3.6-dist/css/bootstrap.css">
<link rel="stylesheet" href="libs/bootstrap-3.3.6-dist/css/bootstrap-theme.css">
<script src="libs/jquery-2.2.4.js"></script>
<script src="libs/bootstrap-3.3.6-dist/js/bootstrap.js"></script>
</head>
<body>
<#nested/>
</body>
</html>
</#macro>

<#macro greet>
Hello, I'm greet template
</#macro>
{%endcodeblock%}

## 2. 使用模板

{%codeblock main.ftl lang:xml%}
<#import "templates.ftl" as templates>

<@templates.main title="Index page">
<@templates.greet/>
</@templates.main>
{%endcodeblock%}

## 3.通过Struts调用

{%codeblock struts.xml lang:xml%}
<package name="root" namespace="/" extends="struts-default">
<action name="">
<result type="freemarker">home.ftl</result>
</action>
</package>
{%endcodeblock%}

注：action.name可设为空，这样可以匹配url：`/`
