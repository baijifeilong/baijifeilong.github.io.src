---
title: CLion配置MSVC版Qt
categories:
  - Programming
tags:
  - Programming
date: 2020-01-07 17:58:09
---

## 1. 安装CLion

测试版本 2019.3

## 2. 安装Visual Studio

测试版本 Visual Studio 2019 Enterprise

## 3. 安装Qt5

测试版本 Qt5.12.6 msvc2017版

<!--more-->

## 4. 配置CLion

添加编译工具链，选择Visual Studio，会自动识别

## 5. 创建C++项目

根据CLion新建项目向导进行，创建一个CMake项目

## 6. 编辑CMake配置，用于识别与配置Qt 

示例代码

```cmake
cmake_minimum_required(VERSION 3.3)
project(App)

set(CMAKE_PREFIX_PATH C:/Qt/5.12.6/msvc2017)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_VERBOSE_MAKEFILE ON)
add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")

find_package(Qt5Widgets)

add_executable(App main.cpp MyTimer.h)
target_link_libraries(App Qt5::Widgets)
```

## 7. 示例Qt代码

### 7.1 MyTimer.h

```cpp
//
// Created by BaiJiFeiLong@gmail.com at 2020/1/7 15:47.
//

#ifndef APP_MYTIMER_H
#define APP_MYTIMER_H

#include <QObject>
#include <QThread>

class MyTimer : public QThread {
Q_OBJECT
protected:
    void run() override {
        while ("TRUE") {
            emit tick();
            QThread::msleep(333);
        }
    }

public:
signals:

    void tick();
};


#endif //APP\_MYTIMER\_H
```

### 7.2 main.cpp

```cpp
//
// Created by BaiJiFeiLong@gmail.com at 2020/1/7 15:47.
//

#include <QApplication>
#include <MyTimer.h>
#include <QDateTime>
#include <QDebug>
#include <QPushButton>
#include <QLayout>
#include <QListWidget>

int main(int argc, char *argv[]) {
    new QApplication(argc, argv);
    auto *window = new QWidget();
    auto *layout = new QVBoxLayout();
    window->setWindowTitle("定时器");
    window->setLayout(layout);
    auto *button = new QPushButton("启动");
    auto *listWidget = new QListWidget();
    layout->addWidget(button);
    layout->addWidget(listWidget);
    window->show();

    auto *timer = new MyTimer();
    QObject::connect(timer, &MyTimer::tick, [&]() {
        listWidget->addItem(new QListWidgetItem(QDateTime::currentDateTime().toString("HH:mm:ss.zzz")));
        listWidget->scrollToBottom();
    });
    QObject::connect(button, &QPushButton::clicked, [&]() {
        timer->start();
    });
    return QApplication::exec();
}
```

## 关于控制台乱码

乱就对了，别执着了

## 关于find\_package

在Windows平台下，如果将Qt的bin目录添加到Path环境变量，find\_package可以自动找到Qt。否则，需要设置`CMAKE_PREFIX_PATH`为Qt的安装目录

## 关于动态链接库

Qt程序一般采用动态链接，需要确保程序运行时能找到对应的DLL。可以拷贝所需DLL到工作目录，或者切换工作目录到Qt的bin目录，或者将Qt的bin目录添加到系统Path环境变量(需要重启IDE，确保IDE能加载到最新环境变量)

## 平台位数选择

32位的Qt只能编译32位程序，64位的Qt只能编译64位程序。客户端一般都得支持32位系统，所以直接装32位Qt即可。编译器不管是MSVC还是MINGW，最好直接选择32位，虽然64位编译器可能支持交叉编译到32位，省却配置的麻烦。

## MSYS2配置32位Qt5开发环境

### 1. 安装32位工具链

`pacman -S mingw-w64-i686-toolchain`

### 2. 安装32位Qt5

`pacman -S mingw-w64-i686-qt5 --disable-download-timeout`

### 3. 修复MinGW-Qt5的bug

CMake时`mingw-w64-i686-qt5-5.12.3-1`报错:

```
CMake Error at D:/msys64/mingw64/lib/cmake/Qt5Gui/Qt5GuiConfig.cmake:15 (message):
  The imported target "Qt5::Gui" references the file

     "C:/building/msys32/mingw64/x86_64-w64-mingw32/lib/libglu32.a"
```

将"C:/building/msys32"这个错误的绝对路径改到正确路径即可

### 4. CMake

直接`find_package`即可

### 5. 动态链接库

程序运行时会自动找到对应的动态链接库，不需额外配置


文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
