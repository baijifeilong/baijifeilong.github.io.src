---
title: Windows电脑安全防护技巧
categories:
  - OS
  - Windows
tags:
  - OS
  - Windows
  - Security
date: 2018-12-10 21:23:16
---

# Windows电脑安全防护技巧

1. 安装杀毒软件，安全卫士之类。理论可行，实际严重影响运行速度，造成莫名其妙的bug，比如git奇慢、单机游戏联不了机或联机不稳定等bug。而且据说全家桶系列与用户隐私不共戴天。
2. 平时用普通帐号或普通管理员帐号（非Administrator）使用系统。理论非常美好，实际上右键以管理员身份运行并没有Administrator权限，需要Shift右键以其他用户身份运行，输入administrator和密码，administrator还不能是空密码，而且没有用户列表选择，每次都要输入一长串用户名外加一长串或短串的密码，操作相当吃力。而且就算这样，实际权限似乎还不够真正的Administrator，具体原理不懂，反正我的小狼毫重新部署不了。
3. 平时用Administrator账户使用系统。碰到不放心的软件，右键以其他用户运行，选择一个普通账户（前提是先创建好这个账户并设好密码）。实际操作仍然不够方便，但是比方法2强多了。
4. 不放心的软件先在线查毒（网速够的话），比如[http://www.virscan.org/](http://www.virscan.org/)
5. 不放心的软件扔沙箱(Sandboxie)运行，但是有些软件沙箱跑不了。
6. 不放心的软件扔虚拟机运行。很靠谱，但是不方便，浪费资源。
7. 不放心的软件用Total Uninstall打开，如果感觉有异常，用完后用Total Uninstall恢复到运行此软件前的状态
8. 不放心的软件到影子系统(比如Shadow Defender)里打开。但是好进不好出。
9. 使用增量系统备份软件，随时备份，随时还原。前提要有足够的硬盘空间。
10. 常用PowerTool、PCHunter等查毒工具看看有没有异常的进程（先看颜色，再看名字，再看文件位置）

<!--more-->

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
