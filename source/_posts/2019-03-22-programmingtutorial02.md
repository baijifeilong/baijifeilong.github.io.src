---
title: 面向聪明小白的编程入门教程 利其器(Part 2)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-22 16:04:52
---

编程的方式方法五花八门，在这个系列教程中，我会将我多年编程总结的最佳实践分享出来。

<!--more-->

## 1. 约定由于配置

编程并不难，但是学好编程需要涉猎的面特别广。当涉猎的东西太多，很可能会搞不清重点，把自己搞得头重脚轻。编程的目的是写程序，也就是做软件。做出有价值的东西来，才是编程的意义所在。

金无足赤，人无完人，程序也没有完美的程序。在追求完美的过程中，有时候也不得不对机器、对网络、对人做一些妥协，来达到完美的中庸（其实是个悖论，完美必不中庸，中庸必不完美^_^）。

人的精力有限，应该把有限的精力放在无限的为人民服务上，不，是放在有意义的事情上。对于工具、方法和编码规范等这些支线任务，寻找最权威的解决方案即可。

约定优于配置（convention over configuration），是我推崇的编程第一法则。通俗来讲，就是跟编程主线无关的需要做出选择的地方，随大流即可。不过我说的这个随大流主要是随国际大流，必要时可妥协为国内大流。一个好的程序，不可能是个程序孤岛，肯定要跟人有交互。跟自己交互，跟用户交互，跟代码阅读者交互。交互必然产生扯皮。碰到扯皮，就用CoC来KY之。

## 2. 工欲善其事，必先利其器

工欲善其事，必先利其器。学好编程需要接触一大堆工具。一大堆工具又有一大堆版本。这一大堆工具还可能存在依赖关系，一个工具的问题可能会影响到另一个工具。当你运行一段代码出现问题请教别人时，别人可能会表示这段代码在他机子上运行没有任何问题。同样的代码，在不同的环境运行，确实可能会产生不同的结果。

为了减少不必要的扯皮，为了更精准地定位程序的bug，更为了更方便地安装与管理软件，一个软件包管理器必不可少。

Windows上最权威的软件包管理器是[Chocolatey](https://chocolatey.org/)。这是一个命令行工具。苹果电脑用户请绕道[Homebrew](https://brew.sh/)自行触类旁通。

## 3. 虚拟终端

不会修电脑的程序员不是好画家。

命令行，也叫控制台，也叫终端，也叫虚拟终端，在Windows上也叫`cmd`。个人电脑刚诞生的时候，还没有鼠标这个概念，人机交互完全是通过键盘输入指令进行的。比如用`Microsoft Word`打开文档`resume.doc`，可能需要在命令行上敲`word resume.doc`，然后回车，才能用古老的Word打开这个文档。再比如输入`shutdown`再回车，一般就代表关闭计算机。

现代的计算机，基本都是图形用户界面，使用鼠标点击屏幕上的按钮完成交互操作。但是，古老的命令交互功能并没有被操作系统删除掉，而是由一个单独的App（Application，应用程序，软件）来模拟古老的终端界面。至于为什么叫终端，应该是因为很久以前电脑太贵，一台电脑配一堆显示器，大家通过不同的终端共享同一台主机吧（用终端解释终端，这种解释法也太GNU了吧）。

在Windows上，官方的虚拟终端软件叫`命令提示符`，可以在开始菜单中找，也可以按下快捷键`Win+R`(Win指微软徽标键，R不区分大小写)，在弹出的`运行`窗口中输入`cmd`回车打开。在Windows 7下，虚拟终端默认的显示内容如下：

```log
Microsoft Windows [版本 6.1.7601]
版权所有 (c) 2009 Microsoft Corporation。保留所有权利。

C:\Users\Administrator>
```

除了官方的`cmd`，Windows上也可以使用第三方开发的虚拟终端。因为`Windows`是闭源操作系统，而且好多接口不开放，所以第三方的虚拟终端虽然交互体验好点，但是兼容性比较差，容易出问题（比如乱码）。

之所以在`运行`窗口中输入`cmd`会启动虚拟终端，是因为这个虚拟终端软件被放在磁盘上的`C:\Windows\System32\cmd.exe`。输入`cmd`，系统会在`C:\Windows\System32\`目录（文件夹）下查找`cmd.exe`，找到的话会将其运行。

事实上，这个查找逻辑并没有那么简单。在命令行下，输入`where cmd`再回车，可以让系统去查找名字为`cmd`的可执行文件。查找结果为`C:\Windows\System32\cmd.exe`。

```log
Microsoft Windows [版本 6.1.7601]
版权所有 (c) 2009 Microsoft Corporation。保留所有权利。

C:\Users\Administrator>where cmd
C:\Windows\System32\cmd.exe

C:\Users\Administrator>
```

想知道具体的查找逻辑，可以在命令行下打`where`再回车，会显示`where`命令的帮助手册。微软对`where`命令的解释为`显示符合搜索模式的文件位置。在默认情况下，搜索是在当前目录和 PATH环境变量指定的路径中执行的。`。此处提到了一堆对小白来说非常陌生的名词，不过不用担心，我觉得很多工作五年甚至十年的程序员也不一定真正明白这句话是什么意思。

## 4. 环境变量

先说一下环境变量吧。环境变量是一种相对说法，相对的是程序的内部变量。程序运行在操作系统环境。有时候，我们想不修改程序代码，就能改变程序的一些行为。这时候，就可以用到环境变量了。变量，就是指一个可以改变的值，可以是一个数字，也可以是一串文本。软件是运行在系统环境下的，可以读取到系统环境中的一些变量，即`环境变量`。如果软件根据这个变量的值来控制程序逻辑的话，我们就实现了不修改程序代码，改变程序的运行行为。

在`Windows`操作系统中，最重要的环境变量是`PATH`。这是一个最常用的依赖搜索路径。它的值是一串用分号分割的文件夹。当我们在`运行`窗口输入`cmd`再回车时，`Windows`会从这个文件夹列表中，从前往后，从一个个文件夹里面顺序搜索`cmd.exe`。搜到一个匹配的`cmd.exe`后，便终止搜索，然后运行这个`cmd.exe`。

要想查看当前`PATH`环境变量的值，可以在命令行下打`echo %PATH%`，我的环境变量显示如下：

```log
C:\Users\Administrator>echo %PATH%
C:\Python37\Scripts\;C:\Python37\;C:\Windows\system32;C:\Windows;C:\Windows\Syst
em32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\ProgramData\chocolatey\
bin;C:\Program Files\Git\cmd;C:\Program Files\Microsoft VS Code\bin;C:\Program F
iles (x86)\vim\vim80;C:\Program Files\Calibre2\;C:\Program Files (x86)\Yarn\bin\
;C:\Program Files\nodejs\;C:\Users\Administrator\AppData\Local\Pandoc\;C:\tools\
Cmder;C:\Users\Administrator\AppData\Local\Yarn\bin;C:\Users\Administrator\AppDa
ta\Roaming\npm
```

每个人的环境变量可能会不太一样。很正常，因为这是一个`变`量

事实上，在`运行`窗口中打`cmd`，搜索的不一定是`cmd.exe`，也有`cmd.bat`、`cmd.js`等。`运行`窗口搜索的是可执行文件。除了`.exe`文件，我们下载软件时碰到的`.msi`文件也可以双击运行。可见，Windows的可执行文件不止有`.exe`这种格式。Windows可执行文件的格式，是通过`PATHEXT`环境变量来进行配置的。我的`PATHEXT`环境变量的配置是：

```bat
C:\Users\Administrator>echo %PATHEXT%
.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.PY;.PYW
```

可见，`.py`文件在我的操作系统上也是可执行文件格式。我可以通过双击Python脚本（后缀`.py`或`.pyw`）来执行它。

除了这两个环境变量，Windows还有多个环境变量，也支持自行添加环境变量。Windows环境变量有单独的配置窗口。`Win+R`输入`SystemPropertiesAdvanced`回车，可以打开`系统属性窗口`。点击`高级`标签，再点击`环境变量`按钮，可以弹出环境变量编辑窗口。

Windows的环境变量分为`系统变量`和`用户变量`。他们的变量名可以重名。如果`PATH`环境变量重名，Windows会把`PATH`对应的两个环境变量连接起来，其中，系统变量在前，用户变量在后。所以，在搜索可执行文件的时候，系统变量优先。Windows这么设计，应该是出于安全考虑，免得输入系统应用名称，执行的却是某些流氓软件。其他场景下的环境变量重名，我认为应该是用户变量优先。

之所以会有用户变量，是因为Windows是个多用户操作系统，意思是可以多个用户（每个用户有各自的桌面、我的文档、开始菜单等）共同使用这台电脑。一般情况下，个人电脑都是单显示器单键鼠运行的，当然也可以连接多套输入输出设备。电脑被黑后，黑客也可以远程登录这台电脑上的另一个用户，跟你一块玩这台计算机。不同的用户相互隔离，也需要不同的配置，用户变量就是环境变量层面的用户隔离。

## 5. 安装Chocolatey

Windows操作系统一般用[`Chocolatey`](https://chocolatey.org/)做软件包管理。注意，这是一个第三方软件，不是微软出品。

英语好的小白，可以直接查看官网教程进行安装。其他小白可以在命令行下执行以下命令进行安装：

```bat
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
```

如果安装过程被各大管家卫士拦截，可以先退出这些管家卫士（建议有基本Windows安全常识的小白将其卸载）

## 6. 了解Chocolatey

在命令行下输入`choco`，如果显示如下内容，说明安装成功了。

```bat
C:\Users\Administrator>choco
Chocolatey v0.10.11
Please run 'choco -?' or 'choco <command> -?' for help menu.
```

命令告诉我们，当前`Chocolatey`版本号是`0.10.11`。输入`choco -?`可以查看帮助菜单。输入`choco install -?`可以查看`choco install`子命令的帮助菜单。

执行命令`where choco`，输出如下：

```bat
C:\Users\Administrator>where choco
C:\ProgramData\chocolatey\bin\choco.exe
```

可见，我们的`Chocolatey`被安装到了本地磁盘的C盘。有C盘洁癖的同学注意了，`Chocolatey`管理的其他工具也是要往C盘装的，`MKLINK /J`外加折腾几个小时，了解一下。

## 7. 了解命令行指令

使用`cd`(Change Directory)命令可以跳转到其他目录。使用`dir`(Directory)命令可以查看当前目录的信息和当前目录的所有文件。使用`explorer .`可以用资源管理器（俗称我的电脑）打开当前目录。

不懂命令行，做不好程序员，附录二的命令走一遍。不过我的`Chocolatey`目录的文件数量应该比你多，因为我已经用Chocolatey装过了其他工具。

## 8. 使用Chocolatey查看已安装的软件

输入命令`choco list --local-only`，意思是列出软件包，只要本地（已安装）的。

我的输出如下（新安装的应该只有chocolatey一个软件包）：

```bat
C:\ProgramData\chocolatey\bin>choco list --local-only
Chocolatey v0.10.11
7zip.install 18.6
aria2 1.34.0.1
blender 2.79.2
calibre 3.39.1
chocolatey 0.10.11
chocolatey-core.extension 1.3.3
Cmder 1.3.11
DotNet4.5.2 4.5.2.20140902
ffmpeg 4.1
git 2.20.1
git.install 2.20.1
GoogleChrome 72.0.3626.109
nodejs.install 11.9.0
pandoc 2.6
python 3.7.2
python3 3.7.2
vcredist2008 9.0.30729.6161
vcredist2010 10.0.40219.2
vim 8.0.604
vscode 1.31.1
yarn 1.13.0
21 packages installed.
```

## 9. 使用Chocolatey搜索软件包

以音乐播放器`Foobar2000`为例，在命令行输入`choco search foobar`。等待数秒（取决于网络状况）后，可看到如下输出：

```bat
C:\ProgramData\chocolatey\bin>
C:\ProgramData\chocolatey\bin>
C:\ProgramData\chocolatey\bin>choco search foobar
Chocolatey v0.10.11
foobar2000 1.4.3 [Approved]
opencodecs 0.85.17777 [Approved]
freeencoderpack 2018.10.19 [Approved]
3 packages found.
```

Chocolatey以"foobar"为关键字搜到了三个软件包（package）。"Approved"应该是已审核之意。很显然，`foobar2000`这个软件包正是我们要找的。它在`Chocolatey`仓库中的最新版本是`1.4.3`。

除了在命令行界面下搜索，Chocolatey也提供了[网页端的搜索](https://chocolatey.org/packages?q=foobar)。

## 10. 使用Chocolatey查询软件包详情

打命令`choco info foobar2000`，输出如下：

```bat
C:\ProgramData\chocolatey\bin>choco info foobar2000
Chocolatey v0.10.11
foobar2000 1.4.3 [Approved]
 Title: foobar2000 | Published: 2019/3/18
 Package approved as a trusted package on 三月 18 2019 23:39:36.
 Package testing status: Passing on 三月 18 2019 22:20:58.
 Number of Downloads: 75964 | Downloads for this version: 1134
 Package url
 Chocolatey Package Source: https://github.com/niks255/ChocolateyPackages
 Package Checksum: 'J/RYGaUhQwaXVSoifyEsgfRowtPy7ifMb1Qq9RcX80bwxGSCkbMcx5Zdxama
fQjOvXvebet5TzeTsGwUcyJQWw==' (SHA512)
 Tags: foobar2000 media player admin
 Software Site: http://www.foobar2000.org/
 Software License: http://www.foobar2000.org/?page=License
 Summary: foobar2000
 Description: foobar2000 is an advanced freeware audio player for the Windows pl
atform. Some of the basic features include full unicode support, ReplayGain supp
ort and native support for several popular audio formats.

1 packages found.
```

软件详情提供了软件的官网。可见，这个`foobar2000`就是我们要找的`Foobar`。而且最新版本发布于`2019/3/18`，今天是`2019/3/22`，应该是官网最新版本。

## 11. 使用Chocolatey安装软件

打命令`choco install foobar2000`，下载安装包结束后，按`Y`同意执行安装脚本，最终输出如下：

```bat
C:\Users\Administrator>choco install foobar2000
Chocolatey v0.10.11
Installing the following packages:
foobar2000
By installing you accept licenses for the packages.
Progress: Downloading foobar2000 1.4.3... 100%

foobar2000 v1.4.3 [Approved]
foobar2000 package files install completed. Performing other installation steps.

The package foobar2000 wants to run 'chocolateyInstall.ps1'.
Note: If you don't run this script, the installation will fail.
Note: To confirm automatically next time, use '-y' or consider:
choco feature enable -n allowGlobalConfirmation
Do you want to run the script?([Y]es/[N]o/[P]rint): y

Installing foobar2000...
foobar2000 has been installed.
  foobar2000 may be able to be automatically uninstalled.
 The install of foobar2000 was successful.
  Software installed to 'C:\Program Files (x86)\foobar2000'

Chocolatey installed 1/1 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
```

可见，`Foobar2000`被安装到了`C:\Program Files (x86)\foobar2000`。此时，桌面上和开始菜单中应该都可以找到我们新安装的播放器。执行命令`choco list --local-only`应该也能看到变化。

## 12. Chocolatey的其他用法

- `choco uninstall foobar2000` 卸载Foobar2000
- `choco upgrade foobar2000` 更新Foobar2000到最新版本

## 附录

### 附录一 `where`命令帮助手册

```bat
Microsoft Windows [版本 6.1.7601]
版权所有 (c) 2009 Microsoft Corporation。保留所有权利。

C:\Users\Administrator>where
此命令的语法是:

WHERE [/R dir] [/Q] [/F] [/T] pattern...

描述:
    显示符合搜索模式的文件位置。在默认情况下，搜索是在当前目录和 PATH
    环境变量指定的路径中执行的。

参数列表:
    /R       从指定目录开始，递归性搜索并显示符合指定模式的文件。

    /Q       只返回退出代码，不显示匹配文件列表。(安静模式)

             匹配文件。(安静模式)

    /F       显示所有相配文件并用双引号括上。

    /T       显示所有相配文件的文件的文件。

    pattern  指定要匹配的文件的搜索模式。通配符 * 和 ? 可以用在模式中。
             也可以指定 "$env:pattern" 和 "path:pattern" 格式; 其中
             "env" 是环境变量，搜索是在 "env" 变量的指定的路径中执行的。
             这些格式不应该跟 /R 一起使用。此搜索也可以用将 PATHEXT 变
             量扩展名附加于此模式的方式完成。

     /?      显示此帮助消息。

  注意: 如果搜索成功，此工具返回错误级别 0; 如果不成功，返回 1; 如果失
        败或发生错误，返回 2。

示例:
    WHERE /?
    WHERE myfilename1 myfile????.*
    WHERE $windir:*.*
    WHERE /R c:\windows *.exe *.dll *.bat
    WHERE /Q ??.???
    WHERE "c:\windows;c:\windows\system32:*.dll"
    WHERE /F /T *.dll

C:\Users\Administrator>
```

### 附录二 Chocolatey目录结构

```bat
C:\Users\Administrator>cd C:\ProgramData\chocolatey\bin\

C:\ProgramData\chocolatey\bin>dir
 驱动器 C 中的卷是 mywin
 卷的序列号是 12FD-5B61

 C:\ProgramData\chocolatey\bin 的目录

2019/02/25  18:37    <DIR>          .
2019/02/25  18:37    <DIR>          ..
2019/02/14  14:42            25,600 7z.exe
2019/02/14  13:42            26,112 aria2c.exe
2018/05/04  18:09           143,496 choco.exe
2018/05/04  18:09           143,496 chocolatey.exe
2018/05/04  18:09           143,496 cinst.exe
2018/05/04  18:09           143,496 clist.exe
2018/05/04  18:09           143,496 cpack.exe
2018/05/04  18:09           143,496 cpush.exe
2018/05/04  18:09           143,496 cuninst.exe
2018/05/04  18:09           143,496 cup.exe
2018/05/04  18:09           143,496 cver.exe
2019/02/25  18:37            26,112 ffmpeg.exe
2019/02/25  18:37            26,112 ffplay.exe
2019/02/25  18:37            26,112 ffprobe.exe
2019/02/13  16:10           129,536 Git-2.20.1-32-bit.exe
2018/05/04  18:09             2,283 RefreshEnv.cmd
2018/12/16  12:31                21 _processed.txt
              17 个文件      1,553,352 字节
               2 个目录 18,996,658,176 可用字节

C:\ProgramData\chocolatey\bin>explorer .

C:\ProgramData\chocolatey\bin>
```

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
