---
title: OpenGL工具箱
categories:
  - Programming
  - C
tags:
  - Programming
  - C
  - OpenGL
date: 2018-10-04 01:51:11
---

OpenGL的简单封装

**CMakeLists.txt**

```cmake
cmake_minimum_required(VERSION 3.8)
project(hellogl)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS -Wall)

set(SOURCE_FILES glad.c main.c alpha.c utils.h glutils.h)
add_executable(hellogl ${SOURCE_FILES})

target_link_libraries(hellogl glfw3)
```

**utils.h**
```c
#ifndef HELLOGL_UTILS_H
#define HELLOGL_UTILS_H

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define UNUSED(x) (void)(x)

char *getFileContent(char *filename) {

    FILE *f = fopen(filename, "rt");
    assert(f);
    fseek(f, 0, SEEK_END);
    size_t length = (size_t) ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buffer = (char *) malloc(length + 1);
    buffer[length] = '\0';
    fread(buffer, 1, length, f);
    fclose(f);
    return buffer;
}

#endif //HELLOGL_UTILS_H
c
```

**glutils.h**
```c
#ifndef HELLOGL_GLUTILS_H
#define HELLOGL_GLUTILS_H

#include <glad/glad.h>
#include "utils.h"

GLuint createShader(GLenum type, char *filename) {
    GLuint shader = glCreateShader(type);
    const GLchar *shaderSource = getFileContent(filename);
    glShaderSource(shader, 1, &shaderSource, 0);
    glCompileShader(shader);

    int success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (success) {
        return shader;
    } else {
        char infoLog[512];
        glGetShaderInfoLog(shader, 512, 0, infoLog);
        fprintf(stderr, "ERROR::SHADER::COMPILATION: %s\n", infoLog);
        return FALSE;
    }
}

GLuint createProgram(int count, ...) {
    GLuint program = glCreateProgram();
    va_list args;
    va_start(args, count);
    for (int i = 0; i < count; ++i) {
        GLuint arg = va_arg(args, GLuint);
        glAttachShader(program, arg);
    }
    va_end(args);
    glLinkProgram(program);
    return program;
}

#endif //HELLOGL_GLUTILS_H
```

**main.c**
```c
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <stdio.h>
#include "utils.h"
#include "glutils.h"

void framebuffer_size_callback(GLFWwindow *window, int width, int height);

void processInput(GLFWwindow *window);

const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

void configureGlfw();

void checkGL();

int main() {
    glfwInit();
    configureGlfw();
    GLFWwindow *window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
    assert(window);

    glfwMakeContextCurrent(window);

    int gladLoadResult = gladLoadGLLoader((GLADloadproc) glfwGetProcAddress);
    assert(gladLoadResult);

    checkGL();

    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);


    GLuint vertexShader = createShader(GL_VERTEX_SHADER, "vertex1.glsl");
    GLuint fragmentShader = createShader(GL_FRAGMENT_SHADER, "fragment1.glsl");
    GLuint fragmentShader2 = createShader(GL_FRAGMENT_SHADER, "fragment2.glsl");

    GLuint shaderProgram = createProgram(2, vertexShader, fragmentShader);
    GLuint shaderProgram2 = createProgram(2, vertexShader, fragmentShader2);

    float vertices[] = {
            0.5f, 0.5f, 0,
            0.5f, -0.5f, 0,
            0, 0, 0,
            -0.5f, -0.5f, 0,
            -0.5f, 0.5f, 0,
            0, 0, 0
    };

    GLuint VBO, VAO;
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, 9 * sizeof(float), vertices, GL_STATIC_DRAW);
    glBindVertexArray(VAO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *) 0);
    glEnableVertexAttribArray(0);

    GLuint VBO2, VAO2;
    glGenBuffers(1, &VBO2);
    glGenVertexArrays(1, &VAO2);
    glBindBuffer(GL_ARRAY_BUFFER, VBO2);
    glBufferData(GL_ARRAY_BUFFER, 9 * sizeof(float), vertices + 9, GL_STATIC_DRAW);
    glBindVertexArray(VAO2);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), NULL);
    glEnableVertexAttribArray(0);

    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

    while (!glfwWindowShouldClose(window)) {
        processInput(window);


        glClearColor(0.2, 0.3, 0.3, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glBindVertexArray(0);

        glUseProgram(shaderProgram2);
        glBindVertexArray(VAO2);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glBindVertexArray(0);


        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glfwTerminate();
    return 0;
}

void framebuffer_size_callback(GLFWwindow *window, int width, int height) {
    glViewport(0, 0, width, height);
    UNUSED(window);
}

void processInput(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, TRUE);
    }
}

void configureGlfw() {
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
}

void checkGL() {
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    printf("Max vertex attributes: %d\n", nrAttributes);
}
```

**vertex1.glsl**
```glsl
#version 330 core

layout (location = 0) in vec3 aPos;

void main() {
    gl_Position = vec4(aPos.x, aPos.y + 0.1, aPos.z, 1);
}

```

**fragment1.glsl**
```glsl
#version 330 core

out vec4 color;

void main() {
    color = vec4(0.8, 0.8, 0, 2);
}
```

**fragment2.glsl**
```glsl
#version 330 core

out vec4 color;

void main() {
    color = vec4(1, 0.5, 0.2, 1);
}
```
