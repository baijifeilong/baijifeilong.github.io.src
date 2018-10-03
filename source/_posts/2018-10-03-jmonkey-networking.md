---
title: jMonkey联网入门
categories:
  - Programming
  - Java
tags:
  - Programming
  - Java
  - Kotlin
  - jMonkey
  - OpenGL
date: 2018-10-03 23:53:23
---

jMonkey的多人游戏(网络通信)需要包`org.jmonkeyengine:jme3-networking`

基本用法是：

1. 创建一个消息类
2. 服务端与客户端都注册此消息类
3. 服务端AND/OR客户端注册消息监听器
4. 服务端广播消息AND/OR客户端发送消息

## 1. 消息类

创建消息类，实现jMonkey的AbstractMeesage接口，并用jMonkey的@Serializable注解

**HelloMessage.kt**

```kotlin
package bj.common

import com.jme3.network.AbstractMessage
import com.jme3.network.serializing.Serializable

/**
 * Created by BaiJiFeiLong@gmail.com at 18-7-28 下午12:57
 */
@Serializable
class HelloMessage : AbstractMessage {
    var hello: String? = null

    @Suppress("unused")
    constructor()

    constructor(hello: String?) : super() {
        this.hello = hello
    }
}
```

<!--more-->

## 2. 服务端

创建服务端，注册消息类，注册消息监听器。启动服务端后，广播消息给所有客户端

**AppServer.kt**
```
package bj.server

import bj.common.HelloMessage
import com.jme3.app.SimpleApplication
import com.jme3.network.*
import com.jme3.network.serializing.Serializer
import com.jme3.system.JmeContext
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled
import java.util.*

/**
 * Created by BaiJiFeiLong@gmail.com at 18-7-28 下午12:21
 */
@SpringBootApplication
@EnableScheduling
class AppServer : SimpleApplication(), ApplicationListener<ApplicationReadyEvent> {
    private lateinit var gameServer: Server

    override fun simpleInitApp() {
        Network.createServer(6143).apply {
            gameServer = this
            addMessageListener(MessageListener<HostedConnection> { source, m ->
                println("<<<<< Message received from client ${source.id} ${(m as HelloMessage).hello}")
            }, HelloMessage::class.java)
            start()
        }
    }

    override fun onApplicationEvent(event: ApplicationReadyEvent?) {
        Serializer.registerClass(HelloMessage::class.java)
        start(JmeContext.Type.Headless)
    }

    @Scheduled(fixedRate = 3000)
    fun doSomething() {
        println(">>>>> Broadcasting...")
        gameServer.broadcast(HelloMessage("I AM SERVER NOW IS ${Date()}"))
    }

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(AppServer::class.java, *args)
        }
    }
}
```

## 3. 客户端

创建客户端，注册消息类，注册消息监听器。启动客户端后，向服务端发送消息。此处为了减少演示代码量，客户端设为HEADLESS模式(无界面)

**App.kt**

```kotlin
package bj.client

import bj.common.HelloMessage
import com.jme3.app.SimpleApplication
import com.jme3.network.Client
import com.jme3.network.MessageListener
import com.jme3.network.Network
import com.jme3.network.serializing.Serializer
import com.jme3.system.JmeContext
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled
import java.util.*

/**
 * Created by BaiJiFeiLong@gmail.com at 18-6-27 下午10:08
 */
@SpringBootApplication
@EnableScheduling
class App : SimpleApplication(), ApplicationListener<ApplicationReadyEvent> {
    private lateinit var client: Client

    override fun simpleInitApp() {
    }

    override fun onApplicationEvent(event: ApplicationReadyEvent?) {
        Serializer.registerClass(HelloMessage::class.java)
        start(JmeContext.Type.Headless)

        Network.connectToServer("localhost", 6143).apply {
            client = this
            addMessageListener(MessageListener<Client> { source, m ->
                println("<<<<< Message received from server ${source.id}: ${(m as HelloMessage).hello}")
            }, HelloMessage::class.java)
            start()
        }
    }

    @Scheduled(fixedDelay = 3000)
    fun sendSomethingToServer() {
        println(">>>>> Sending message")
        client.send(HelloMessage("I AM CLIENT NOW IS ${Date()}"))
    }

    companion object {
        @JvmStatic
        fun main(args: Array<String>) {
            SpringApplication.run(App::class.java, *args);
        }
    }
}


```
