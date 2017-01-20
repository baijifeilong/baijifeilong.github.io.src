---
layout: post
title:  "Hibernate5 示例"
date:   2016-07-06 13:51:47 +0800
categories: it java
---

## 1. hibernate配置

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE hibernate-configuration PUBLIC
"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
<session-factory>
<property name="connection.driver_class">org.h2.Driver</property>
<property name="connection.url">jdbc:h2:~/hibernate;AUTOCOMMIT=OFF</property>
<property name="dialect">org.hibernate.dialect.H2Dialect</property>
<property name="show_sql">true</property>
<property name="format_sql">true</property>
<property name="hbm2ddl.auto">update</property>
<mapping resource="hibernate-mapping/person.xml"/>
</session-factory>
</hibernate-configuration>
{%endcodeblock%}

注意：

1. Hibernate 3.6之后将DTD的命名空间从`http://hibernate.sourceforge.net/`换到了`http://www.hibernate.org/dtd/`

2. Hibernate配置文件的默认文件名是hibernate.cfg.xml，也可任意命名，此处用hibernate.xml

3. 此处用的是H2内存数据库

4. hbm2ddl.auto设为update，自动创建更新表结构而不删除数据

## 2. Hibernate实体

{%codeblock java%}
package cn.corpro.iot.server.model;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/6 10:40
*/
public class Person {
private Long id;
private String name;

public Long getId() {
return id;
}

public void setId(Long id) {
this.id = id;
}

public String getName() {
return name;
}

public void setName(String name) {
this.name = name;
}
}
{%endcodeblock%}

## 3. Hibernate关系对象映射

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-mapping PUBLIC
"-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
<hibernate-mapping>
<class name="cn.corpro.iot.server.model.Person" table="person">
<id name="id" column="id">
<generator class="native"></generator>
</id>
<property name="name" column="name"></property>
</class>
</hibernate-mapping>
{%endcodeblock%}

**注意：此xml可任意命名，放任意位置**

## 4. 使用Hibernate插入数据

{%codeblock java%}
package cn.corpro.iot.server.main;

import cn.corpro.iot.server.model.Person;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/6 9:35
*/
public class Hibernate {

public static void main(String[] args) {
SessionFactory sessionFactory = new Configuration()
.configure("hibernate.xml").buildSessionFactory();
Session session = sessionFactory.openSession();

session.getTransaction().begin();
Person person = new Person();
person.setName("Alice");
session.save(person);
session.getTransaction().commit();

session.close();
sessionFactory.close();
}
}

{%endcodeblock%}

**注意：从Hibernate5开始，不能用以下代码生成SessionFactory**

{%codeblock java%}
Configuration configuration = new Configuration().configure("hibernate.xml");
SessionFactory sessionFactory = configuration.buildSessionFactory
(new StandardServiceRegistryBuilder().applySettings(configuration
.getProperties()).build());
{%endcodeblock%}

而应当用`new Configuration().buildSessionFactory(new StandardServiceRegistryBuilder().configure("hibernate.xml").build())`或`new Configuration().configure("hibernate.xml").buildSessionFactory()`，前者可以通过`loadProperties()`加载properties文件。`configure()`的参数缺省为`hibernate.cfg.xml`

## 5. Hibernate日志控制

Hibernate需要`log4j-core`依赖，log4j-api不必要，可以用logback等取代。此处用logback。

logback.xml

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
<Logger name="org.hibernate" level="INFO"/>

<root level="DEBUG">
<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
<pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
</encoder>
</appender>
</root>
</configuration>
{%endcodeblock%}

通过`<Logger name="org.hibernate" level="INFO"/>`将org.hibernate设为INFO级，log4j用法类似

## 6. 注解的使用

1. 实体类

{%codeblock java%}
package cn.corpro.iot.server.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/6 14:39
*/
@Entity
@Table(name = "plant")
public class Plant {

private int id;
private String name;

@Column(name = "name", unique = true, nullable = false, length = 20)
public String getName() {
return name;
}

public void setName(String name) {
this.name = name;
}

@Id
@Column(name = "id", unique = true, nullable = false, precision = 5)
public int getId() {
return id;
}

public void setId(int id) {
this.id = id;
}
}
{%endcodeblock%}

2. 通过Hibernate配置文件使用

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE hibernate-configuration PUBLIC
"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
<session-factory>
<property name="connection.driver_class">org.h2.Driver</property>
<property name="connection.url">jdbc:h2:~/hibernate;AUTOCOMMIT=OFF</property>
<property name="connection.username"></property>
<property name="connection.password"></property>
<property name="connection.pool_size">1</property>
<property name="dialect">org.hibernate.dialect.H2Dialect</property>
<property name="current_session_context_class">thread</property>
<property name="cache.provider_class">org.hibernate.cache.internal.NoCachingRegionFactory</property>
<property name="show_sql">true</property>
<property name="format_sql">true</property>
<property name="hbm2ddl.auto">create</property>
<mapping resource="hibernate-mapping/person.xml"/>
<mapping class="cn.corpro.iot.server.model.Plant"/>
</session-factory>
</hibernate-configuration>
{%endcodeblock%}

添加了`<mapping class="cn.corpro.iot.server.model.Plant"/>`。添加完后，Java代码不有修改即可运行。

3. 通过Java代码声明使用

{%codeblock java%}
package cn.corpro.iot.server.main;

import cn.corpro.iot.server.model.Plant;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/6 9:35
*/
public class Hibernate {

public static void main(String[] args) {
SessionFactory sessionFactory = new Configuration().configure("hibernate.xml")
.addAnnotatedClass(Plant.class).buildSessionFactory();
Session session = sessionFactory.openSession();

session.getTransaction().begin();
Plant plant = new Plant();
plant.setName("Alice");
session.save(plant);
session.getTransaction().commit();

session.close();
sessionFactory.close();
}
}
{%endcodeblock%}

添加了`.addAnnotatedClass(Plant.class)`

# 7. Hibernate完全抛弃xml的用法

{%codeblock java%}
package cn.corpro.iot.server.main;

import cn.corpro.iot.server.model.Plant;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/6 9:35
*/
public class Hibernate {

public static void main(String[] args) {

SessionFactory sessionFactory = new Configuration()
.setProperty("hibernate.connection.driver_class", "org.h2.Driver")
.setProperty("hibernate.connection.url", "jdbc:h2:~/hibernate;AUTOCOMMIT=OFF")
.setProperty("hibernate.show_sql", "true")
.addAnnotatedClass(Plant.class)
.buildSessionFactory();

Session session = sessionFactory.openSession();

session.getTransaction().begin();
Plant plant = new Plant();
plant.setName("Alice");
session.save(plant);
session.getTransaction().commit();

session.close();
sessionFactory.close();
}
}

{%endcodeblock%}

## 8 连接PostgreSQL

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE hibernate-configuration PUBLIC
"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
<session-factory>
<property name="connection.driver_class">org.postgresql.Driver</property>
<property name="connection.url">jdbc:postgresql://192.168.0.222/bj</property>
<property name="dialect">org.hibernate.dialect.PostgreSQL95Dialect</property>
<property name="connection.username">postgres</property>
<property name="connection.password">admin</property>
<property name="show_sql">true</property>
<property name="format_sql">true</property>
<property name="hbm2ddl.auto">update</property>
<mapping resource="hibernate-mapping/person.xml"/>
</session-factory>
</hibernate-configuration>
{%endcodeblock%}
