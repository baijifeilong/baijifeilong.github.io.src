---
title: Kotlin 最佳实践
categories:
  - Programming
  - Kotlin
tags:
  - Programming
  - Java
  - Kotlin
  - Ktor
date: 2018-11-18 23:35:11
---

## 为什么写此文

Kotlin很烦，Gralde很烦，还都是升级狂，加一块更烦。几个月不接触Kotlin，再次上手时便一片迷茫。所以记录此文，以便再次上手时查阅。

## 使用Gradle创建Kotlin项目

1. `mkdir hellokt` 创建项目文件夹
2. `cd hellokt` 切换到项目根目录
3. `gradle init --type java-application` 使用Gradle初始化Java项目
4. `rm -rf src/main/java src/test/java gradle gradlew gradlew.bat` 删除Java目录和GradleWrapper配置
5. `vim build.gradle` 编辑Gradle项目配置
6. `mkdir -p src/main/kotlin src/test/kotlin` 创建Kotlin目录
7. `vim src/main/kotlin/App.kt` 编写Kotlin版HelloWorld
8. `gradle clean build run` 使用Gradle清理、构建、运行，直接运行也可
9. `idea .` 用IntelliJ IDEA 打开项目，所有选项均选择默认，开始用IDE进行开发

### 为什么要用命令行创建项目?

用图形化界面创建项目变量太多，人品不好容易掉坑里。用命令行创建项目，可以明确每个文件、每行代码的用途，整个过程可重现、可控制，还可以避免在IDE里某个步骤卡死半天没反应又结束不掉的尴尬。

<!--more-->

### 为什么要删除GradleWrapper

- 很烦、很烦、很烦 我想安静一会儿
- 很大、很大、很大 我硬盘不够你折腾
- 很慢、很慢、很慢 我知道有堵墙，不用你三天两头提醒

我不Care你的Gradle版本。编译不过我自然会升级Gradle构建脚本

**build.gradle**

```gradle
// 注意，这个文件是Gradle构建脚本，是脚本，里面的代码是先后执行的。至少`buildscript`要放在`apply plugin`的前面。
// 构建脚本
buildscript {
    // 插件依赖
    dependencies {
        // Kotlin插件对应的包
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.10"
    }

    // 插件仓库。墙外人可直接用`mavencentral`、`jcenter`
    repositories {
        // 阿里的Maven中心仓库镜像
        maven { url "https://maven.aliyun.com/repository/central"  }
        // 阿里的jCenter镜像
        maven { url "https://maven.aliyun.com/repository/jcenter"  }
    }
}

// 此插件添加了 `gradle run` 命令，通过Gradle运行项目
apply plugin: 'application'
// 此插件对Kotlin语言提供了支持，可以编译Kotlin文件
apply plugin: 'kotlin'

// application插件run的入口class
mainClassName = 'App'

// 项目依赖
dependencies {
    // Kotlin分为两部分，语言部分和库部分。kotlin插件对语言部分提供支持，`kotlin-stdlib`对库部分提供支持。哪怕HelloWorld中使用的`println`也在库中。所以是Kotlin项目的必选依赖
    compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
}

// 项目仓库 
repositories {
    // Maven中心仓库墙内版
    maven { url "https://maven.aliyun.com/repository/central"  }
    // jCenter中心仓库墙内版
    maven { url "https://maven.aliyun.com/repository/jcenter"  }
}
```

**App.kt**

```kotlin
class App {
    companion object {
        @JvmStatic
            fun main(args: Array<String>) {
                println("hello kt")
            }
    }
}
```

之所以将代码放到类里头，是为了支持application插件，他需要指定一个含有JVM入口静态main方法的入口类。

也可以用带main函数的app.kt，此时mainClassName应配置为"AppKt"

## 用Gradle构建Kotlin版的SpringBoot应用

**build.gradle**

```gradle
buildscript {
    repositories {
        maven { url "https://maven.aliyun.com/repository/central"  }
        maven { url "https://maven.aliyun.com/repository/jcenter"  }
    }
    dependencies {
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.10'
        classpath 'org.springframework.boot:spring-boot-gradle-plugin:2.0.3.RELEASE'
    }
}
apply plugin: 'application'
apply plugin: 'kotlin'

// SpringBoot插件。Kotlin默认一切final，Spring又需要各种代理，所以需要特殊处理。同时提供`spring:bootRun`命令
apply plugin: 'org.springframework.boot'
// Spring依赖管理。自动选择依赖版本。Gradle中没有Maven那样内建的依赖管理(通过Parent POM 实现)，需要插件处理。
apply plugin: 'io.spring.dependency-management'

mainClassName = 'bj.App'

dependencies {
    compile "org.jetbrains.kotlin:kotlin-stdlib" // Kotlin是要在JVM里跑的。那么多语言特性，没有依赖库怎么跑
    compile "org.jetbrains.kotlin:kotlin-reflect" // 无反射不Spring。反射不在Kotlin标准库，需单独添加
    compile 'org.springframework.boot:spring-boot-starter' // 创建单机应用所需要的最基本的Starter
}
repositories {
    maven { url "https://maven.aliyun.com/repository/central"  }
    maven { url "https://maven.aliyun.com/repository/jcenter"  }
}
```

**bj/App.kt**

```kotlin
package bj
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
/**
 * Created by BaiJiFeiLong@gmail.com at 18-6-27 下午10:08
 */
@SpringBootApplication
open class App : ApplicationListener<ApplicationReadyEvent> {
    override fun onApplicationEvent(event: ApplicationReadyEvent?) {
        println("Ready.")
    }
    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args);
        }
    }
}
```

注意:

主类一定要放在包里头(不能用root或者说default)，否则报java.lang.ClassNotFoundException: org.springframework.dao.DataAccessException

## 创建Ktor应用

**build.gradle**

```gradle
buildscript {
    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.10"
    }
    repositories {
        maven { url "https://maven.aliyun.com/repository/central"  }
        maven { url "https://maven.aliyun.com/repository/jcenter"  }
    }
}

apply plugin: 'application'
apply plugin: 'kotlin'

mainClassName = 'App'

dependencies {
    compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
    // 2. 添加Ktor依赖
    compile "io.ktor:ktor-server-netty:1.0.0-beta-3"
    // 3.  添加Logback依赖。Ktor只依赖了Slf4J，没有Slf4J的具体实现。如果不导入一个Slf4J的实现，将打印不出日志来
    compile "ch.qos.logback:logback-classic:1.2.3"
}

repositories {
    maven { url "https://maven.aliyun.com/repository/central"  }
    maven { url "https://maven.aliyun.com/repository/jcenter"  }
    // 1. 添加Ktor仓库。没出正式版，所以Maven中心仓没有最新版本
    maven { url "https://dl.bintray.com/kotlin/ktor" }
}
```

**bj/App.kt**

```kotlin
import io.ktor.application.call
import io.ktor.http.ContentType
import io.ktor.response.respondText
import io.ktor.routing.get
import io.ktor.routing.routing
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty

class App {
    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            val server = embeddedServer(Netty, port = 8080) {
                routing {
                    get("/") {
                        call.respondText("xx", ContentType.Text.Plain)
                    }
                }
            }
            server.start(wait = true)
        }
    }
}
```

## Ktor应用打包

**build.gradle**

`gradle build` 默认打包的jar不带Manifest，也不是FatJar，不能直接运行。添加`shadow`插件后，将多打包出一个可以直接运行的FatJar

```gradle
buildscript {
    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.10"
        // 1. 添加shadow插件的依赖
        classpath "com.github.jengelman.gradle.plugins:shadow:4.0.2"
    }
    repositories {
        maven { url "https://maven.aliyun.com/repository/central"  }
        maven { url "https://maven.aliyun.com/repository/jcenter"  }
    }
}

apply plugin: 'application'
apply plugin: 'kotlin'

// 2. 应用shadow插件
apply plugin: 'com.github.johnrengelman.shadow'

// 需要带main函数的kotlin文件main.kt或Main.kt
mainClassName = 'MainKt'

dependencies {
    compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
    compile "io.ktor:ktor-server-netty:1.0.0-beta-3"
    // 用于组装HTML。非必选依赖
    compile "io.ktor:ktor-html-builder:1.0.0-beta-3"
    compile "ch.qos.logback:logback-classic:1.2.3"
}

repositories {
    maven { url "https://maven.aliyun.com/repository/central"  }
    maven { url "https://maven.aliyun.com/repository/jcenter"  }
    maven { url "https://dl.bintray.com/kotlin/ktor" }
}
```

## Ktor应用安装到Docker

1. `gradle build`
2. `vim Dockerfile`
3. `docker build --tag=hellokt .`
4. `docker run -it --rm -p 8080:8080 hellokt`

**Dockerfile**

```docker
FROM openjdk:8-jre-alpine
RUN mkdir /app
COPY ./build/libs/hellokt-all.jar /app
WORKDIR /app
CMD ["java", "-jar", "hellokt-all.jar" ]
```

## Ktor使用配置文件(application.conf)

Ktor使用配置文件，需要更改Application入口类，并在配置文件中指明模块，最后通过`gradle run`命令运行

**main.kt**

```kotlin
import io.ktor.application.Application
import io.ktor.application.call
import io.ktor.application.install
import io.ktor.features.CallLogging
import io.ktor.features.DefaultHeaders
import io.ktor.response.respondText
import io.ktor.routing.Routing
import io.ktor.routing.get

/**
 * Created by BaiJiFeiLong@gmail.com at 18-11-18 下午12:10
 */

fun Application.main() {
    install(DefaultHeaders)
    install(CallLogging)
    install(Routing) {
        get("/") {
            call.respondText("Hello ")
        }
    }
}
```

**application.conf**

放到Resources根目录

```hocon
ktor {
  deployment {
    port = 8088
  }

  application {
    modules = [MainKt.main]
  }
}
```

在gradle构建脚本中更改mainClassName

```gradle
mainClassName = 'io.ktor.server.netty.EngineMain'
```

## 在Ktor项目中使用JWT

**build.gradle**

```gradle
buildscript {
    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.10"
        classpath "com.github.jengelman.gradle.plugins:shadow:4.0.2"
    }
    repositories {
        maven { url "https://maven.aliyun.com/repository/central" }
        maven { url "https://maven.aliyun.com/repository/jcenter" }
    }
}

apply plugin: 'application'
apply plugin: 'kotlin'
apply plugin: 'com.github.johnrengelman.shadow'

mainClassName = 'io.ktor.server.netty.EngineMain'

dependencies {
    compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8"
    compile "io.ktor:ktor-server-netty:1.0.0-beta-3"
    compile "io.ktor:ktor-html-builder:1.0.0-beta-3"
    compile "io.ktor:ktor-jackson:1.0.0-beta-3"
    compile "io.ktor:ktor-auth:1.0.0-beta-3"
    compile "io.ktor:ktor-auth-jwt:1.0.0-beta-3"
    compile "ch.qos.logback:logback-classic:1.2.3"
}

repositories {
    maven { url "https://maven.aliyun.com/repository/central" }
    maven { url "https://maven.aliyun.com/repository/jcenter" }
    maven { url "https://dl.bintray.com/kotlin/ktor" }
}
```

**main.kt**

```kotlin
import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.fasterxml.jackson.databind.SerializationFeature
import io.ktor.application.Application
import io.ktor.application.call
import io.ktor.application.install
import io.ktor.auth.Authentication
import io.ktor.auth.UserIdPrincipal
import io.ktor.auth.authenticate
import io.ktor.auth.jwt.jwt
import io.ktor.auth.principal
import io.ktor.features.CORS
import io.ktor.features.ContentNegotiation
import io.ktor.features.StatusPages
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpMethod
import io.ktor.http.HttpStatusCode
import io.ktor.jackson.jackson
import io.ktor.request.receive
import io.ktor.response.respond
import io.ktor.routing.get
import io.ktor.routing.post
import io.ktor.routing.route
import io.ktor.routing.routing
import java.util.*

/**
 * Created by BaiJiFeiLong@gmail.com at 18-11-18 下午12:10
 */

class InvalidCredentialsException(message: String) : RuntimeException(message)

data class Snippet(val user: String, val text: String)

data class PostSnippet(val snippet: Text) {
    data class Text(val text: String)
}

open class SimpleJwt(val secret: String) {
    private val algorithm = Algorithm.HMAC256(secret)
    val verifier = JWT.require(algorithm).build()
    fun sign(name: String): String = JWT.create().withClaim("name", name).sign(algorithm)
}

class User(val name: String, val password: String)

val users = Collections.synchronizedMap(
        listOf(User("test", "test")).associateBy { it.name }.toMutableMap()
)

class LoginRegister(val user: String, val password: String)

val snippets = Collections.synchronizedList(mutableListOf(
        Snippet("demo", "hello"),
        Snippet("demo", "world")
))

fun Application.main() {
//    install(DefaultHeaders)
//    install(CallLogging)
    val simpleJwt = SimpleJwt("my-super-secret-for-jwt")

    install(ContentNegotiation) {
        jackson {
            enable(SerializationFeature.INDENT_OUTPUT)
        }
    }
    install(Authentication) {
        jwt {
            verifier(simpleJwt.verifier)
            validate {
                UserIdPrincipal(it.payload.getClaim("name").asString())
            }
        }
    }
    install(StatusPages) {
        exception<InvalidCredentialsException> {
            call.respond(HttpStatusCode.Unauthorized, mapOf("OK" to false, "error" to (it.message ?: "")))
        }
    }
    install(CORS) {
        method(HttpMethod.Options)
        method(HttpMethod.Get)
        method(HttpMethod.Post)
        method(HttpMethod.Put)
        method(HttpMethod.Delete)
        method(HttpMethod.Patch)
        header(HttpHeaders.Authorization)
        allowCredentials = true
        anyHost()
    }
    routing {
        route("/snippets") {
            authenticate {
                get {
                    call.respond(mapOf("snippets" to synchronized(snippets) {
                        snippets.toList()
                    }))
                }
            }
            authenticate {
                post {
                    val post = call.receive<PostSnippet>()
                    val principal = call.principal<UserIdPrincipal>() ?: error("No principle")
                    snippets += Snippet(principal.name, post.snippet.text)
                    call.respond(mapOf("OK" to true))
                }
            }
        }

        post("/login-register") {
            val post = call.receive<LoginRegister>()
            val user = users.getOrPut(post.user) { User(post.user, post.password) }
            if (user.password != post.password) throw InvalidCredentialsException("Invalid credentials")
            call.respond(mapOf("token" to simpleJwt.sign(user.name)))
        }
    }
}
```
## Ktor与Websocket

需要添加Websocket的feature:

`compile "io.ktor:ktor-websockets:1.0.0-beta-3"`

**main.kt**

```kotlin
import io.ktor.application.Application
import io.ktor.application.install
import io.ktor.http.cio.websocket.DefaultWebSocketSession
import io.ktor.http.cio.websocket.Frame
import io.ktor.http.cio.websocket.readText
import io.ktor.routing.routing
import io.ktor.websocket.WebSockets
import io.ktor.websocket.webSocket
import java.util.*
import java.util.concurrent.atomic.AtomicInteger
import kotlin.collections.LinkedHashSet

/**
 * Created by BaiJiFeiLong@gmail.com at 18-11-18 下午12:10
 */

class ChatClient(val session: DefaultWebSocketSession) {
    companion object {
        var lastId = AtomicInteger(0)
    }

    val id = lastId.getAndIncrement()
    val name = "user$id"
}

fun Application.main() {
    install(WebSockets)

    routing {
        val wsConnections = Collections.synchronizedSet(LinkedHashSet<ChatClient>())

        webSocket("/chat") {
            val client = ChatClient(this)
            wsConnections += client
            try {
                while (true) {
                    val frame = incoming.receive()
                    when (frame) {
                        is Frame.Text -> {
                            val text = frame.readText()
                            for (conn in wsConnections) {
                                val txt = wsConnections.map { it.name }.joinToString(", ")
                                conn.session.outgoing.send(Frame.Text(txt))
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                println("Exception: ${e.message}")
            } finally {
                println("A connection has gone")
                wsConnections -= client
            }
        }
    }
}
```

代码实现的功能：广播消息到每个WS客户端

文章首发: [http://baijifeilong.github.io/2018/11/18/kotlin-best-practice/](http://baijifeilong.github.io/2018/11/18/kotlin-best-practice/)
