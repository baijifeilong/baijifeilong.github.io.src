---
layout: post
title:  "Sublime Text"
date:   2016-12-22 22:02:18 +0800
categories: editor
---

## 主题

推荐主题： Monokai Extended

## 插件

- InsertDate 按F5键插入日期

## 代码碎片

例子：

~~~ xml
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
~~~
