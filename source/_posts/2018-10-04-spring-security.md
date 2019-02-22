---
title: SpringSecurity 大杂烩
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Spring
  - SpringBoot
  - Security
date: 2018-10-04 01:11:27
---
**App.kt**

```kotlin
package bj

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.Authentication
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter
import org.springframework.security.web.authentication.AnonymousAuthenticationFilter
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler
import org.springframework.security.web.authentication.www.BasicAuthenticationEntryPoint
import org.springframework.security.web.util.matcher.AntPathRequestMatcher
import org.springframework.security.web.util.matcher.NegatedRequestMatcher
import org.springframework.security.web.util.matcher.OrRequestMatcher
import org.springframework.security.web.util.matcher.RequestMatcher
import org.springframework.stereotype.Component
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.*
import javax.annotation.Resource
import javax.servlet.FilterChain
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import kotlin.collections.HashSet

@SpringBootApplication
@RestController
open class App : WebSecurityConfigurerAdapter() {
    companion object {
        // 公开URL，不需要登录即可访问
        val PUBLIC_URLS = arrayOf("/users/login", "/users/register", "/public/**")

        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }

    @Resource
    private lateinit var tokenAuthenticationProvider: TokenAuthenticationProvider

    @Resource
    private lateinit var userService: UserService

    override fun configure(http: HttpSecurity?) {
        // 公开URL取反，即为受保护的URL
        val protectedUrls = NegatedRequestMatcher(OrRequestMatcher(PUBLIC_URLS.map { AntPathRequestMatcher(it) }))
        // 禁用会话
        http?.sessionManagement()?.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                // 认证失败返401
                ?.and()?.exceptionHandling()?.authenticationEntryPoint(BasicAuthenticationEntryPoint())

                // 设置认证提供者
                ?.and()?.authenticationProvider(tokenAuthenticationProvider)
                // 添加过滤器
                ?.addFilterBefore(TokenAuthenticationFilter(protectedUrls).apply {
                    setAuthenticationManager(authenticationManager())
                    // 认证成功不做跳转
                    setAuthenticationSuccessHandler(SimpleUrlAuthenticationSuccessHandler().apply {
                        setRedirectStrategy { _, _, _ -> }
                    })
                }, AnonymousAuthenticationFilter::class.java)
                // 公开URL允许访问，其他URL先认证
                ?.authorizeRequests()?.antMatchers(*PUBLIC_URLS)?.permitAll()?.anyRequest()?.authenticated()

                // 禁用CSRF、表单登录、HTTPBasic认证、登出
                ?.and()?.csrf()?.disable()?.formLogin()?.disable()?.httpBasic()?.disable()?.logout()?.disable()
    }

    @RequestMapping("/")
    fun home(@AuthenticationPrincipal user: User) = "Welcome my precious ${user.username}${user.authorities}!"

    @RequestMapping("/users/register")
    fun register(@RequestParam username: String, @RequestParam password: String): String {
        userService.register(username, password)
        return login(username, password)
    }

    @RequestMapping("/users/login")
    fun login(@RequestParam username: String, @RequestParam password: String): String {
        return userService.login(username, password)
    }

    @RequestMapping("/users/logout")
    fun logout(@AuthenticationPrincipal user: User) {
        userService.logout(user)
    }

    @RequestMapping("/users/current")
    fun current(@AuthenticationPrincipal user: User): User {
        return user
    }

    @RequestMapping("/public/home")
    fun publicHome() = "I am public home"
}

// 令牌认证提供者
@Component
class TokenAuthenticationProvider : AbstractUserDetailsAuthenticationProvider() {
    @Resource
    private lateinit var userService: UserService

    // 根据令牌获取用户
    override fun retrieveUser(username: String?, authentication: UsernamePasswordAuthenticationToken?): UserDetails {
        val token = authentication?.credentials.toString()
        return userService.findByToken(token)
    }

    // 附加认证检测，不做处理
    override fun additionalAuthenticationChecks(userDetails: UserDetails?, authentication: UsernamePasswordAuthenticationToken?) {}
}

// 令牌认证过滤器
class TokenAuthenticationFilter(requiresAuthenticationRequestMatcher: RequestMatcher?) : AbstractAuthenticationProcessingFilter(requiresAuthenticationRequestMatcher) {
    // 从HTTP头提取令牌进行认证
    override fun attemptAuthentication(request: HttpServletRequest?, response: HttpServletResponse?): Authentication {
        val token = Optional.ofNullable(request?.getHeader("Authorization")).orElseThrow { BadCredentialsException("No token") }
        return authenticationManager.authenticate(UsernamePasswordAuthenticationToken(token, token))
    }

    // 认证成功后，继续过滤链
    override fun successfulAuthentication(request: HttpServletRequest?, response: HttpServletResponse?, chain: FilterChain?, authResult: Authentication?) {
        super.successfulAuthentication(request, response, chain, authResult)
        chain?.doFilter(request, response)
    }

    // Spring碰到异常后会变身/error的请求继续进入此过滤器，将其跳过，否则就会对不需要验证的URL进行验证处理
    // TODO 寻找优雅的解决方案
    override fun doFilter(req: ServletRequest?, res: ServletResponse?, chain: FilterChain?) {
        if (req is HttpServletRequest && req.requestURI == "/error") {
            chain?.doFilter(req, res)
        } else {
            super.doFilter(req, res, chain)
        }
    }
}

// 用户服务，负责具体的登录注册等逻辑
@Component
class UserService {
    // 用户集合，模拟数据库
    private val users = HashSet<User>()
    // 字典(令牌=>用户) 储存登录的用户
    private val tokenToUser = HashMap<String, User>()

    // 注册 创建用户
    fun register(username: String, password: String): User {
        if (users.any { it.username == username }) {
            throw RuntimeException("User has already been registered")
        }

        val roles = if (username == "boss") listOf("user", "boss") else listOf("user")
        val user = User(username, password, roles.map { SimpleGrantedAuthority(it) })
        users += user
        return user
    }

    // 登录 创建令牌
    fun login(username: String, password: String): String {
        tokenToUser.values.removeIf { it.username == username }
        val user = users.stream().filter { it.username == username }.findFirst().orElseThrow { RuntimeException("User not exist") }
        if (password != user.password) {
            throw RuntimeException("Invalid password")
        }
        val token = UUID.randomUUID().toString()
        tokenToUser[token] = user
        return token
    }

    // 退出
    fun logout(user: User) {
        tokenToUser.entries.removeIf { it.value.username == user.username }
    }

    // 用令牌查找用户
    fun findByToken(token: String): User {
        return Optional.ofNullable(tokenToUser[token]).orElseThrow { RuntimeException("Token is invalid") }
    }
}
```

Token使用Jwt
**App.kt**

```
package bj

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.SignatureAlgorithm
import io.jsonwebtoken.impl.crypto.MacProvider
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.Authentication
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter
import org.springframework.security.web.authentication.AnonymousAuthenticationFilter
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler
import org.springframework.security.web.authentication.www.BasicAuthenticationEntryPoint
import org.springframework.security.web.util.matcher.AntPathRequestMatcher
import org.springframework.security.web.util.matcher.NegatedRequestMatcher
import org.springframework.security.web.util.matcher.OrRequestMatcher
import org.springframework.security.web.util.matcher.RequestMatcher
import org.springframework.stereotype.Component
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.*
import javax.annotation.Resource
import javax.servlet.FilterChain
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import kotlin.collections.HashSet

@SpringBootApplication
@RestController
open class App : WebSecurityConfigurerAdapter() {
    companion object {
        // 公开URL，不需要登录即可访问
        val PUBLIC_URLS = arrayOf("/users/login", "/users/register", "/public/**")

        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args)
        }
    }

    @Resource
    private lateinit var tokenAuthenticationProvider: TokenAuthenticationProvider

    @Resource
    private lateinit var userService: UserService

    override fun configure(http: HttpSecurity?) {
        // 公开URL取反，即为受保护的URL
        val protectedUrls = NegatedRequestMatcher(OrRequestMatcher(PUBLIC_URLS.map { AntPathRequestMatcher(it) }))
        // 禁用会话
        http?.sessionManagement()?.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                // 认证失败返401
                ?.and()?.exceptionHandling()?.authenticationEntryPoint(BasicAuthenticationEntryPoint())

                // 设置认证提供者
                ?.and()?.authenticationProvider(tokenAuthenticationProvider)
                // 添加过滤器
                ?.addFilterBefore(TokenAuthenticationFilter(protectedUrls).apply {
                    setAuthenticationManager(authenticationManager())
                    // 认证成功不做跳转
                    setAuthenticationSuccessHandler(SimpleUrlAuthenticationSuccessHandler().apply {
                        setRedirectStrategy { _, _, _ -> }
                    })
                }, AnonymousAuthenticationFilter::class.java)
                // 公开URL允许访问，其他URL先认证
                ?.authorizeRequests()?.antMatchers(*PUBLIC_URLS)?.permitAll()?.anyRequest()?.authenticated()

                // 禁用CSRF、表单登录、HTTPBasic认证、登出
                ?.and()?.csrf()?.disable()?.formLogin()?.disable()?.httpBasic()?.disable()?.logout()?.disable()
    }

    @RequestMapping("/")
    fun home(@AuthenticationPrincipal user: User) = "Welcome my precious ${user.username}${user.authorities}!"

    @RequestMapping("/users/register")
    fun register(@RequestParam username: String, @RequestParam password: String): String {
        userService.register(username, password)
        return login(username, password)
    }

    @RequestMapping("/users/login")
    fun login(@RequestParam username: String, @RequestParam password: String): String {
        return userService.login(username, password)
    }

    @RequestMapping("/users/logout")
    fun logout(@AuthenticationPrincipal user: User) {
        userService.logout(user)
    }

    @RequestMapping("/users/current")
    fun current(@AuthenticationPrincipal user: User): User {
        return user
    }

    @RequestMapping("/public/home")
    fun publicHome() = "I am public home"
}

// 令牌认证提供者
@Component
class TokenAuthenticationProvider : AbstractUserDetailsAuthenticationProvider() {
    @Resource
    private lateinit var userService: UserService

    // 根据令牌获取用户
    override fun retrieveUser(username: String?, authentication: UsernamePasswordAuthenticationToken?): UserDetails {
        val token = authentication?.credentials.toString()
        return userService.findByToken(token)
    }

    // 附加认证检测，不做处理
    override fun additionalAuthenticationChecks(userDetails: UserDetails?, authentication: UsernamePasswordAuthenticationToken?) {}
}

// 令牌认证过滤器
class TokenAuthenticationFilter(requiresAuthenticationRequestMatcher: RequestMatcher?) : AbstractAuthenticationProcessingFilter(requiresAuthenticationRequestMatcher) {
    // 从HTTP头提取令牌进行认证
    override fun attemptAuthentication(request: HttpServletRequest?, response: HttpServletResponse?): Authentication {
        val token = Optional.ofNullable(request?.getHeader("Authorization")).map { it.removePrefix("Bearer").trim() }.orElseThrow { BadCredentialsException("No token") }
        return authenticationManager.authenticate(UsernamePasswordAuthenticationToken(token, token))
    }

    // 认证成功后，继续过滤链
    override fun successfulAuthentication(request: HttpServletRequest?, response: HttpServletResponse?, chain: FilterChain?, authResult: Authentication?) {
        super.successfulAuthentication(request, response, chain, authResult)
        chain?.doFilter(request, response)
    }

    // Spring碰到异常后会变身/error的请求继续进入此过滤器，将其跳过，否则就会对不需要验证的URL进行验证处理
    // TODO 寻找优雅的解决方案
    override fun doFilter(req: ServletRequest?, res: ServletResponse?, chain: FilterChain?) {
        if (req is HttpServletRequest && req.requestURI == "/error") {
            chain?.doFilter(req, res)
        } else {
            super.doFilter(req, res, chain)
        }
    }
}

// 用户服务，负责具体的登录注册等逻辑
@Component
class UserService {
    // 用户集合，模拟数据库
    private val users = HashSet<User>()

    // Jwt 密钥
    private val key = MacProvider.generateKey()

    // 注册 创建用户
    fun register(username: String, password: String): User {
        if (users.any { it.username == username }) {
            throw RuntimeException("User has already been registered")
        }

        val roles = if (username == "boss") listOf("user", "boss") else listOf("user")
        val user = User(username, password, roles.map { SimpleGrantedAuthority(it) })
        users += user
        return user
    }

    // 登录 创建令牌
    fun login(username: String, password: String): String {
        val user = users.stream().filter { it.username == username }.findFirst().orElseThrow { RuntimeException("User not exist") }
        if (password != user.password) {
            throw RuntimeException("Invalid password")
        }
        return Jwts.builder().setSubject(username).signWith(SignatureAlgorithm.HS256, key).compact()
    }

    // 退出
    fun logout(user: User) {}

    // 用令牌查找用户
    fun findByToken(token: String): User {
        val username = Jwts.parser().setSigningKey(key).parseClaimsJws(token).body.subject
        return users.stream().filter { it.username == username }.findFirst().orElseThrow { RuntimeException("User $username not exist") }
    }
}
```
