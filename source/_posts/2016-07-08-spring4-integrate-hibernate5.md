---
layout: post
title:  "Spring4 集成 Hibernate5"
date:   2016-07-08 16:09:43 +0800
categories: it java
---

## 1. Spring配置

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context" xmlns:tx="http://www.springframework.org/schema/tx"
xmlns:aop="http://www.springframework.org/schema/aop"
xsi:schemaLocation="http://www.springframework.org/schema/beans
http://www.springframework.org/schema/beans/spring-beans.xsd
http://www.springframework.org/schema/context
http://www.springframework.org/schema/context/spring-context.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx.xsd http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd">

<context:component-scan base-package="cn.corpro.iot"/>

<!--sessionFactory with dataSource begin-->

<bean class="org.apache.commons.dbcp2.BasicDataSource" id="dataSource" destroy-method="close">
<property name="driverClassName" value="org.postgresql.Driver"/>
<property name="url" value="jdbc:postgresql://192.168.0.222/bj"/>
<property name="username" value="postgres"/>
<property name="password" value="admin"/>
</bean>

<bean class="org.springframework.orm.hibernate5.LocalSessionFactoryBean" id="sessionFactory">
<property name="dataSource" ref="dataSource"/>
<property name="hibernateProperties">
<value>hibernate.dialect=org.hibernate.dialect.PostgreSQL95Dialect</value>
</property>
<property name="mappingResources">
<list>
<value>hibernate-mapping/person.xml</value>
</list>
</property>
</bean>

<!--sessionFactory with dataSource end-->

<!-- Spring integrate Hibernate transaction begin -->

<bean class="org.springframework.orm.hibernate5.HibernateTransactionManager" id="transactionManager">
<property name="sessionFactory" ref="sessionFactory"/>
</bean>

<tx:advice id="txAdvice" transaction-manager="transactionManager">
<tx:attributes>
<tx:method name="get*" read-only="true"/>
<tx:method name="*"/>
</tx:attributes>
</tx:advice>

<aop:config>
<aop:pointcut id="serviceCut"
expression="execution(public * cn.corpro.iot.service.*.*(..))"/>
<aop:advisor advice-ref="txAdvice" pointcut-ref="serviceCut"/>
</aop:config>

<!-- Spring integrate Hibernate transaction end -->

<bean class="cn.corpro.iot.service.UserService" id="userService">
<property name="sessionFactory" ref="sessionFactory"/>
</bean>

<bean class="cn.corpro.iot.action.UserAction" id="userAction">
<property name="userService" ref="userService"/>
</bean>

</beans>
{%endcodeblock%}

注：

如果不要Spring接管Hibernate会话的话，只要设置好sessionFactory并在DAO里注入使用就行。

如果需要Spring ORM接管Hibernate，就需要HibernateTransactionManager和后面的切面设置，否则会报错：`org.springframework.dao.InvalidDataAccessApiUsageException: Write operations are not allowed in read-only mode (FlushMode.MANUAL): Turn your Session into FlushMode.COMMIT/AUTO or remove 'readOnly' marker from transaction definition.`

## 2. Hibernate配置

数据源在Spring中设置了，所以Hibernate只需要设置关系对象映射就行。

hibernate-mapping/person.xml:

{%codeblock xml%}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-mapping PUBLIC
"-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
<hibernate-mapping>
<class name="cn.corpro.iot.model.Person" table="person">
<id name="id" column="id">
<generator class="native"></generator>
</id>
<property name="name" column="name"></property>
</class>
</hibernate-mapping>
{%endcodeblock%}

## 3. 使用

{%codeblock java%}
package cn.corpro.iot.service;

import cn.corpro.iot.model.Person;
import cn.corpro.iot.util.Failure;
import cn.corpro.iot.util.Success;
import fj.data.Either;
import org.apache.commons.lang3.SystemUtils;
import org.springframework.orm.hibernate5.support.HibernateDaoSupport;

/**
* Author: BaiJiFeiLong@gmail.com
* Date: 2016/7/8 9:37
*/
public class UserService extends HibernateDaoSupport implements IUserService {

public Either<Failure, Success> login(String username, String password) {
getHibernateTemplate().save(new Person("Ella"));
if (SystemUtils.IS_JAVA_1_8) {
return Either.right(new Success());
} else {
return Either.left(new Failure(null));
}
}
}
{%endcodeblock%}

注：HibernateDaoSupport中定义了sessionFactory，可以通过sping进行注入
