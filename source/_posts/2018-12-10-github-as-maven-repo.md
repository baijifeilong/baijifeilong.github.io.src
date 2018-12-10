---
title: Github做Maven仓库
categories:
  - Programming
tags:
  - Programming
date: 2018-12-10 21:02:30
---

## 1. One package one repo (Not real groupId and artifactId and version)

```xml
<repository>
    <id>jitpack.io</id>
    <url>https://jitpack.io</url>
</repository>
```

## 2. Real repo

*pom.xml*
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>bj</groupId>
    <artifactId>hellospring</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>hellospring</name>
    <url>http://maven.apache.org</url>

    <properties>
        <github.global.server>github</github.global.server>
    </properties>

    <repositories>
        <repository>
            <id>github.baijifeilong.repo</id>
            <url>https://raw.github.com/baijifeilong/repo/mvn-repo/</url>
            <snapshots>
                <enabled>true</enabled>
                <!--<updatePolicy>always</updatePolicy>-->
            </snapshots>
        </repository>
    </repositories>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.10.RELEASE</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-deploy-plugin</artifactId>
                <version>2.8.1</version>
                <configuration>
                    <altDeploymentRepository>internal.repo::default::file://${project.build.directory}/mvn-repo
                    </altDeploymentRepository>
                </configuration>
            </plugin>
            <plugin>
                <groupId>com.github.github</groupId>
                <artifactId>site-maven-plugin</artifactId>
                <version>0.12</version>
                <configuration>
                    <message>Maven artifacts for ${project.version}</message>  <!-- git commit message -->
                    <noJekyll>true</noJekyll>                                  <!-- disable webpage processing -->
                    <outputDirectory>${project.build.directory}/mvn-repo
                    </outputDirectory> <!-- matches distribution management repository url above -->
                    <branch>refs/heads/mvn-repo</branch>                       <!-- remote branch name -->
                    <includes>
                        <include>**/*</include>
                    </includes>
                    <repositoryName>repo</repositoryName>      <!-- github repo name -->
                    <repositoryOwner>baijifeilong</repositoryOwner>    <!-- github username  -->
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>site</goal>
                        </goals>
                        <phase>deploy</phase>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

    <distributionManagement>
        <repository>
            <id>internal.repo</id>
            <name>Temporary Staging Repository</name>
            <url>file://${project.build.directory}/mvn-repo</url>
        </repository>
    </distributionManagement>
</project>
```

*~/.m2/settings.xml*
```xml
<settings>
  <servers>
    <server>
      <id>github</id>
      <username>YOUR-USERNAME</username>
      <password>YOUR-PASSWORD</password>
    </server>
  </servers>
</settings>
```
Or use token to replace username and password

<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
