---
title: Spring项目中Swagger文档转HTML
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Swagger
  - Converter
  - HTML
  - Document
  - Spring
  - SpringBoot
  - Asciidoctorj
date: 2018-10-04 01:33:14
---

在SpringBoot项目中，可以利用Swagger生成HTML格式的API文档

<!--more-->

## 用到的依赖

```xml
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.8.0</version>
</dependency>

<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.8.0</version>
</dependency>

<dependency>
    <groupId>io.github.swagger2markup</groupId>
    <artifactId>swagger2markup</artifactId>
    <version>1.3.2</version>
</dependency>

<dependency>
    <groupId>org.asciidoctor</groupId>
    <artifactId>asciidoctorj</artifactId>
    <version>1.5.6</version>
</dependency>
```

## 1. 生成Swagger文档

添加依赖项`springfox-swagger2`,在主Application(@SpringBootApplication)上启用@EnableSwagger2, 启动应用后即可访问`/v2/api-docs`，得到Swagger的JSON文档

## 2. 启用Swagger UI(可选)

添加依赖项`springfox-swagger-ui`，启用应用后即可打开`/swagger-ui.html`,访问SwaagerUI页面

## 3. Swagger转换adoc

添加依赖项`swagger2markup`，调用`Swagger2MarkupConverter`进行转换

## 4. adoc转HTML

添加依赖项`Swagger2MarkupConverter`,调用`Asciidoctor.convertDirectory`进行转换(可以设置CSS和生成目录)

## 实例：在Spring单元测试周期中生成HTML格式的API文档

```java
package com.example.springone;

import io.github.swagger2markup.Swagger2MarkupConverter;
import org.asciidoctor.*;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.nio.file.Paths;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@SpringBootTest
public class DemoApplicationTests {

    @Autowired
    private WebApplicationContext context;

    private MockMvc mockMvc;

    @Before
    public void setUp() {
        this.mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
    }

    @Test
    public void convert() throws Exception {
        MvcResult mvcResult = mockMvc.perform(get("/v2/api-docs"))
            .andExpect(status().isOk())
            .andReturn();

        String json = mvcResult.getResponse().getContentAsString();

        Swagger2MarkupConverter.from(json)
            .build()
            .toFile(Paths.get("./hello"));

        Asciidoctor asciidoctor = Asciidoctor.Factory.create();
        asciidoctor.convertDirectory(
            new GlobDirectoryWalker("*.adoc"), OptionsBuilder
                .options()
                .safe(SafeMode.UNSAFE) // CSS
                .attributes(new Attributes() {{
                    setTableOfContents(Placement.LEFT); // TOC
                }}));

    }
}
```

## Swagger转HTML的工具函数

**SwaggerUtils.java**
```java
package yy.sjq.api.util;

import io.github.swagger2markup.Swagger2MarkupConverter;
import org.apache.commons.io.FileUtils;
import org.asciidoctor.*;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Created by BaiJiFeiLong@gmail.com at 18-5-6 上午8:56
 */
public interface SwaggerUtils {
    static String swaggerToHtml(String swagger) throws IOException {
        Asciidoctor asciidoctor = Asciidoctor.Factory.create();
        OptionsBuilder optionsBuilder = OptionsBuilder.options()
                .backend("html5")
                .docType("book")
                .eruby("")
                .inPlace(true)
                .safe(SafeMode.UNSAFE)
                .attributes(new Attributes() {{
                    setCopyCss(true);
                    setLinkCss(false);
                    setSectNumLevels(3);
                    setAnchors(true);
                    setSectionNumbers(true);
                    setHardbreaks(true);
                    setTableOfContents(Placement.LEFT);
                }});

        String adoc = Swagger2MarkupConverter.from(swagger).build().toString();
        Path tmp = Files.createTempFile(null, null);
        FileUtils.writeStringToFile(tmp.toFile(), adoc, Charset.defaultCharset());

        asciidoctor.convertFile(tmp.toFile(), optionsBuilder);

        return FileUtils.readFileToString(new File(tmp.toString().replace(".tmp", ".html")));
    }
}

```
