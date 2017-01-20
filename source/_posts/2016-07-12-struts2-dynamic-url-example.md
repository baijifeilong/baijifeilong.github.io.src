---
layout: post
title:  "Struts2 动态URL示例"
date:   2016-07-12 14:50:22 +0800
categories: it java
---

## Struts配置

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
"-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
"http://struts.apache.org/dtds/struts-2.3.dtd">
<struts>
<constant name="struts.convention.result.path" value="/"/>
<constant name="struts.custom.i18n.resources" value="i18n"/>

<!--动态URL使用如下三条配置-->
<constant name="struts.enable.SlashesInActionNames" value="true"/>
<constant name="struts.mapper.alwaysSelectFullNamespace" value="false"/>
<constant name="struts.patternMatcher" value="regex"/>

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

<package name="users" namespace="/users" extends="base">
<default-class-ref class="userAction"/>

<action name="new" method="_new">
<result>new.jsp</result>
</action>

<action name="create" method="create">
<result type="redirect">${referer}</result>
</action>

<action name="signIn" method="signIn">
<result type="redirect">${referer}</result>
</action>

<action name="signOut" method="signOut">
<result type="redirect">${referer}</result>
</action>

<action name="test/{username}" method="test">

</action>

<action name="{username}" method="test2">

</action>
</package>
</struts>
{%endcodeblock%}

访问`/test/aaa`将会调用对应action的方法`setUsername("aaa")`
