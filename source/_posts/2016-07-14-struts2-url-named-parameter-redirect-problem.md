---
layout: post
title:  "Struts2 URL 命名参数在跳转中的问题"
date:   2016-07-14 17:26:16 +0800
categories:
    - Programming
    - Java
tags:
    - Programming
    - Java
    - Struts
---

Struts2中，URL的命名参数会在跳转中追加到URL查询串里，连续跳转几次后，会出现像`users/1?id=1&id=1&id=1&id=2`这种情况，有时候会导致逻辑错误。而且Struts配置里，没有办法把这个参数去掉，所以，只能使用普通的通配模式。

<!-- more -->

## 1. 不论普通合名参数还是正则命名参数都不行

{%codeblock struts.xml lang:xml%}
<constant name="struts.patternMatcher" value="namedVariable"/> <!--命名参数-->
<constant name="struts.patternMatcher" value="regex"/> <!--正则命名参数-->
{%endcodeblock%}

## 2. 使用命名参数的例子

{%codeblock struts.xml lang:xml%}
<action name="{id}/edit" method="edit"/>
{%endcodeblock%}

## 3. 改为普通的通配模式(不使用命名参数)
{%codeblock struts.xml lang:xml%}
<action name="*/edit" method="edit">
<param name="id">{1}</param>
</action>
{%endcodeblock%}
