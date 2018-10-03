---
title: Shiro大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
date: 2018-10-04 01:12:54
---

## 1. 添加依赖

```gradle
compile 'org.apache.shiro:shiro-spring-boot-starter:1.4.0'
```

## 2. 实现一个 Realm

Realm 是 Shiro 的核心。所以，至少要实现一个 Realm。注意：此处要用认证 Realm （`org.apache.shiro.realm.AuthenticatingRealm`），不是授权 Realm （`org.apache.shiro.realm.AuthorizingRealm`）

## 3. 设置 SecurityManager

ShiroSpringBoot 会自动注入一个默认的 SecurityManager。通过 `org.apache.shiro.SecurityUtils#setSecurityManager` 静态方法设置好此 SecurityManager 即可

## 4. 登录与退出

通过 `org.apache.shiro.SecurityUtils#getSubject` 静态方法获取当前用户，再调用 `login` 进行登录，调用 `logout` 进行退出

## 5. 登录退出实例

**App.kt**

```kotlin
package bj

import org.apache.shiro.SecurityUtils
import org.apache.shiro.authc.*
import org.apache.shiro.mgt.SecurityManager
import org.apache.shiro.realm.AuthenticatingRealm
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.stereotype.Component
import javax.annotation.Resource

@SpringBootApplication
class App : ApplicationListener<ApplicationReadyEvent> {

    @Resource
    private lateinit var securityManager: SecurityManager


    override fun onApplicationEvent(event: ApplicationReadyEvent?) {
        SecurityUtils.setSecurityManager(securityManager)

        val subject = SecurityUtils.getSubject()
        println("isOnline: ${subject.isAuthenticated}")

        println("===== Login by not:exist")
        try {
            subject.login(UsernamePasswordToken("not", "exist"))
        } catch (e: UnknownAccountException) {
            println("Login failed: ${e.localizedMessage}")
        }
        println("isOnline: ${subject.isAuthenticated}")

        println("===== Login by hello:world")
        subject.login(UsernamePasswordToken("hello", "world"))
        println("isOnline: ${subject.isAuthenticated}")

        println("===== Logout")
        subject.logout()
        println("isOnline: ${subject.isAuthenticated}")
    }

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }
}

@Component
class MyRealm : AuthenticatingRealm() {
    override fun doGetAuthenticationInfo(token: AuthenticationToken?): AuthenticationInfo? {
        if (token is UsernamePasswordToken && token.username == "hello" && String(token.password) == "world") {
            return SimpleAuthenticationInfo("hello", "world", name)
        }
        return null
    }
}
```

## 6. 角色与权限实例

**App.kt**

```kotlin
package bj

import org.apache.shiro.SecurityUtils
import org.apache.shiro.authc.AuthenticationInfo
import org.apache.shiro.authc.AuthenticationToken
import org.apache.shiro.authc.SimpleAuthenticationInfo
import org.apache.shiro.authc.UsernamePasswordToken
import org.apache.shiro.authz.AuthorizationException
import org.apache.shiro.authz.AuthorizationInfo
import org.apache.shiro.authz.SimpleAuthorizationInfo
import org.apache.shiro.authz.annotation.RequiresPermissions
import org.apache.shiro.authz.annotation.RequiresRoles
import org.apache.shiro.authz.permission.DomainPermission
import org.apache.shiro.authz.permission.PermissionResolver
import org.apache.shiro.authz.permission.RolePermissionResolver
import org.apache.shiro.mgt.SecurityManager
import org.apache.shiro.realm.AuthorizingRealm
import org.apache.shiro.subject.PrincipalCollection
import org.springframework.boot.SpringApplication
import org.springframework.boot.SpringBootConfiguration
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.stereotype.Component
import javax.annotation.Resource

@SpringBootApplication
class App : ApplicationListener<ApplicationReadyEvent> {

    @Resource
    private lateinit var securityManager: SecurityManager

    @Resource
    private lateinit var operators: Operators

    override fun onApplicationEvent(event: ApplicationReadyEvent?) {
        SecurityUtils.setSecurityManager(securityManager)

        val subject = SecurityUtils.getSubject()

        println("===== Login with employee/pass")
        subject.login(UsernamePasswordToken("employee", "pass"))

        println("Has read permission: ${subject.isPermitted("read")}")
        println("Has write permission: ${subject.isPermitted("write")}")

        println("Has admin role: ${subject.hasRole("admin")}")
        println("Has user role: ${subject.hasRole("user")}")

        operators.doRead()
        try {
            operators.doWrite()
        } catch (e: AuthorizationException) {
            println("No write permission: ${e.localizedMessage}")
        }
        try {
            operators.imBoss()
        } catch (e: AuthorizationException) {
            println("Not boss: ${e.localizedMessage}")
        }

        println("===== Login with boss/pass")
        subject.logout()
        subject.login(UsernamePasswordToken("boss", "pass"))

        println("Has read permission: ${subject.isPermitted("read")}")
        println("Has write permission: ${subject.isPermitted("write")}")

        println("Has admin role: ${subject.hasRole("admin")}")
        println("Has user role: ${subject.hasRole("user")}")
    }

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }
}

/**
 * 此 Component 必须起名为 authorizer 否则抛异常：
 * Parameter 0 of method authorizationAttributeSourceAdvisor in
 * org.apache.shiro.spring.boot.autoconfigure.ShiroAnnotationProcessorAutoConfiguration
 * required a bean named 'authorizer' that could not be found.
 */
@Component("authorizer")
class MyRealm() : AuthorizingRealm() {
    init {
        // 字符串权限映射到权限类 字符串权限=>权限类
        permissionResolver = PermissionResolver { DomainPermission(it) }
        // 角色映射到权限集合 角色=>权限集合
        rolePermissionResolver = RolePermissionResolver {
            when (it) {
                "admin" -> setOf("read", "write")
                "user" -> setOf("read")
                else -> setOf()
            }.map { DomainPermission(it) }
        }
    }

    // 授权 登录用户=>角色集合
    override fun doGetAuthorizationInfo(principals: PrincipalCollection?): AuthorizationInfo {
        return SimpleAuthorizationInfo(if (principals?.primaryPrincipal == "boss") setOf("admin") else setOf("user"))
    }

    // 认证 用户=>登录用户
    override fun doGetAuthenticationInfo(token: AuthenticationToken?): AuthenticationInfo? {
        if (token is UsernamePasswordToken && token.username in listOf("boss", "employee") && String(token.password) == "pass") {
            return SimpleAuthenticationInfo(token.username, String(token.password), name)
        }
        return null
    }
}

/**
 * 必须注解 @SpringBootConfiguration, 否则报错：
 * The bean 'operators' could not be injected as a 'bj.Operators' because it is a JDK dynamic proxy that implements
 */
@Component
@SpringBootConfiguration
class Operators {
    @RequiresPermissions("read")
    fun doRead() = println("Reading...")

    @RequiresPermissions("write")
    fun doWrite() = println("Writing...")

    @RequiresRoles("admin")
    fun imBoss() = println("I am boss...")
}
```
