---
title: ObjectiveC大杂烩
categories:
  - Programming
  - ObjectiveC
tags:
  - Programming
  - ObjectiveC
date: 2018-10-04 01:39:39
---

## 1. Install gnustep

以 ArchLinux 为例

`sudo pacman -S gnustep-base gnustep-make`

## 2. Edit hello.m

```c
#import <Foundation/Foundation.h>

int main(int argc, const char *argv[]) {
    NSLog(@"Hello world");
    return 0;
}
```

## 3. Compile

gcc `gnustep-config --objc-flags` hello.m -lobjc -lgnustep-base

## 4. Run

`./a.out`
