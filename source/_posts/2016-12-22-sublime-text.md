---
layout: post
title:  "Sublime Text 大杂烩"
date:   2016-12-22 22:02:18 +0800
categories:
    - Application
tags:
    - Application
    - Editor
    - SublimeText
---

## 主题

推荐主题： Monokai Extended

<!-- more -->

## 插件

- InsertDate 按F5键插入日期

## 代码碎片

例子：

{%codeblock snippets.xml lang:xml%}
<snippet>
<content><![CDATA[
---
layout: post
title:  "${1:title}"
date:   "${2:datetime}" +0800
categories: ${3}
---
]]></content>
<tabTrigger>jk</tabTrigger>
<scope>text.html.markdown</scope>
</snippet>
{%endcodeblock%}
