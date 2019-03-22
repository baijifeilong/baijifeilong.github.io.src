---
title: 面向聪明小白的编程入门教程 照猫画猫(Part 3)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-22 16:05:08
---

编程是一种自我挑战。挑战需要的是激情，激情需要的是能看到点滴的进步。大学四年，没学会怎么做一个能显示“Hello World”的空窗体出来，日复一日地在命令行下研究算法、数据结构、操作系统、编译原理，到头来还是一脸蒙逼。独木舟还没造出来，就去研究航母的核子发动机，连纸上谈兵的赵括都笑了。

<!--more-->

我们的第一课，就是做一个有具体功能的，有一定实用性的Windows窗体应用程序出来，并且可以打包成`.exe`可执行文件给别人使用。有时候，囫囵吞枣，也不一定是贬义词。

这个要做的软件，我们称之为“麦多文档转换器”。具体的介绍、截图和源代码见[Github项目主页](https://github.com/baijifeilong/my-doctor)。Github是全球最大的开源软件集散中心。

此软件是我在业余时间，花了七八个小时开发而成。之所以要花这么长时间，是因为好多东西不熟或者忘了，我也是现学现卖。

## 1. 源码窥探

```python
import os
import os.path
import platform
from subprocess import Popen, PIPE
from threading import Thread

from PyQt5.QtCore import *
from PyQt5.QtWidgets import *

label: QLabel
wnd: QMainWindow
currentFilename: str = None
dlg: QProgressDialog = None


def loadFile(filename):
    if filename is None:
        return
    if platform.system() == "Windows":
        filename = filename[1:]
    global currentFilename
    currentFilename = filename
    label.setText("当前文件: " + filename)
    wnd.statusBar().showMessage("文件载入成功: " + filename)


class Converter(QThread):
    done = pyqtSignal(bool)

    def __init__(self, fmt):
        super().__init__()
        self.fmt = fmt

    def run(self):
        fmt = self.fmt
        fromFilename = currentFilename
        toFilename = os.path.splitext(fromFilename)[0] + "." + fmt
        args = ["pandoc", fromFilename]
        if fmt == "pdf":
            args.extend(["--pdf-engine", "wkhtmltopdf"])
        args.extend(["-o", toFilename])
        try:
            from subprocess import STARTUPINFO, STARTF_USESHOWWINDOW
            startupinfo = STARTUPINFO()
            startupinfo.dwFlags |= STARTF_USESHOWWINDOW
        except:
            startupinfo = None
        process = Popen(args=args, stdin=PIPE, stdout=PIPE, stderr=PIPE, startupinfo=startupinfo)
        err = process.communicate()[1].decode()
        code = process.returncode
        wnd.statusBar().showMessage(("转换成功: " + toFilename) if code == 0 else "转换失败: " + err)
        self.done.emit(True)


def convertFile(fmt):
    if currentFilename is None:
        return
    global dlg
    dlg = QProgressDialog(wnd)
    dlg.setWindowTitle("转换中...")
    dlg.setMaximum(0)
    dlg.setCancelButton(None)
    dlg.setWindowFlags(Qt.Window | Qt.WindowTitleHint | Qt.CustomizeWindowHint)
    dlg.setWindowModality(Qt.WindowModal)
    dlg.show()
    wnd.statusBar().showMessage("转换中...")
    global converter
    converter = Converter(fmt)
    converter.done.connect(dlg.close)
    converter.start()


app = QApplication([])
wnd = QMainWindow()
wnd.resize(400, 400 * 0.618)
wnd.setAcceptDrops(True)
wnd.dragEnterEvent = lambda e: e.accept()
wnd.dropEvent = lambda e: print(e.mimeData().urls())
wnd.dropEvent = lambda e: loadFile(next(iter([x.path() for x in e.mimeData().urls()]), None))
wnd.statusBar().showMessage("就绪.")
payload = QWidget()
label = QLabel("请拖入文件.转换后会自动覆盖同名文件,请谨慎使用")

buttons = QGridLayout()
mapper = QSignalMapper()
for idx, (k, v) in enumerate(dict(docx="Word", pdf="PDF", pptx="PowerPoint", html="HTML", mobi="Mobi", epub="EPUB").items()):
    button = QPushButton(v)
    button.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
    mapper.setMapping(button, k)
    button.clicked.connect(mapper.map)
    buttons.addWidget(button, idx / 3 + 1, idx % 3 + 1)
mapper.mapped["QString"].connect(convertFile)

layout = QVBoxLayout()
layout.addWidget(label)
layout.addLayout(buttons)
payload.setLayout(layout)
wnd.setCentralWidget(payload)
wnd.setWindowTitle("麦多文档转换器")
wnd.show()
font = app.font()
font.setPointSize(font.pointSize() / 0.618)
app.setFont(font)
app.exec()
```

一共区区104行代码，就完成了整个软件需要的全部功能。可见，编程并没有想象中的那么复杂，至少，不需要想象中那样多的代码。

## 2. 下载源代码

源代码的[下载链接](https://raw.githubusercontent.com/baijifeilong/my-doctor/master/app.py)。由于源代码是个文本文件，浏览器应该不会弹出下载提示框，需要我们按下`Ctrl+S`，将此文件保存到本地。保存位置放到桌面。保存类型选择`所有文件(*.*)`。

下载完成后，桌面上会出现一个Python（一种编程语言）源码文件`app.py`，请确保它的名字不是`app.py.txt`。

鼠标右键点击这个`app.py`，选择“用记事本打开”，即可查看源代码。如果没有此右键菜单，打开记事本，将文件拖拽进记事本窗口即可。

## 3. 选择文本编辑器

程序代码可以用记事本编写，但是记事本不显示代码行号，也没有代码高亮，更没有代码智能提示等高级功能。所以，一般情况很少用记事本做开发（软件开发，即编程）。

除了记事本，很多文本编辑器都支持代码高亮，比如来自湾湾的`Notepad++`和来自微软的`Visual Studio Code`。`Notepad++`主打小巧快捷方便，`Visual Studio Code`主打功能丰富，插件众多，开箱即用，迷你IDE。建议两者都安装上，进行比较选择。

这两个编辑器的安装方法：

- Notepad ++ : `choco install notepadplusplus`
- Visual Studio Code : `choco install vscode`

安装完成后，可以将代码文件`app.py`分别拖进`Notepad++`和`Visual Studio Code`，看哪个更顺眼就选用哪个。注意，以后的编码并不会用这两个软件，而是要用真·宇宙第一的IDE：PyCharm。当然，这是后话了。

## 4. 安装Python

麦多文档转换器是用`Python`编程语言编写的。Python是一个比较流行的高级编程语言，作者来自荷兰。

Python有2和3两个版本，而且他们之间的兼容性非常差。现在，新版的Python3已经普及了，一般情况下是没有必要再学Python2了。但是，在网上搜索相关资料的时候，要注意这个版本。

在命令行下安装Python: `choco install python`。这个过程可能会特别慢，此时可以穿墙重新执行命令，或者直接官网下载安装包运行。

Python安装完成后，在命令行下执行`python`，验证是否安装成功。如果`Chocolatey`提示Python已安装成功，但是执行`python`命令可能会报错："'python' 不是内部或外部命令，也不是可运行的程序或批处理文件。"。注意，此时报错才正常。因为当前的`PATH`环境变量里，没有Python可执行文件所在的目录。虽然`Chocolatey`已经将Python需要的`PATH`环境变量改好了，但我们的虚拟终端`cmd`还没有意识到，它开始运行时加载的环境变量并不会自动更新。此时，在同一个终端（不同终端的环境相互独立，修改一个终端的环境变量，不会影响到其他已经开启的终端）下执行命令`refreshenv`，即可刷新当前环境，让虚拟终端更新保存的环境变量。

## 5. Python交互式环境

如果一切正常，此时执行命令，应该可以看到如下的Python交互(输入一句执行一句)环境。

```bat
C:\Users\Administrator>python
Python 3.7.2 (tags/v3.7.2:9a3ffc0492, Dec 23 2018, 23:09:28) [MSC v.1916 64 bit
(AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

输入`2 ** 10`，回车，应该能看到输出为`1024`。此处，`**`是求幂运算符。可见，Python可以直接当一个命令行下的计算器使用。

```bat
>>> 2 ** 10
1024
>>>
```

再输入`exit()`，回车，即可退出Python控制台。注意，括号要输入英文半角，因为Python是一门国际化的编程语言，不可能迁就这边14亿的玻璃心。

```bat
C:\Users\Administrator>python
Python 3.7.2 (tags/v3.7.2:9a3ffc0492, Dec 23 2018, 23:09:28) [MSC v.1916 64 bit
(AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
>>> 2 ** 10
1024
>>> exit()

C:\Users\Administrator>
```

## 6. 执行我们的Python程序

如果我们的Python程序安装得完全正常的话，应该可以双击运行。但是，如果程序有异常，很可能会只有一个黑屏一闪而过，不知道发生了什么。所以，我们需要换种执行方法。

在桌面上按住`Shift`键右击鼠标，选择`在此处打开命令窗口`，会打开一个控制台窗口，并且这个控制台下的当前目录（专业术语叫当前工作目录）就是桌面（桌面也是Windows系统的一个文件夹）。确保当前命令提示符为`C:\Users\Administrator\Desktop>`，这样`Python`才能找到我们要执行的文件。

在这个命令行下键入`python app.py`，回车，应该会报出如下异常(错误信息):

```bat
C:\Users\Administrator\Desktop>python app.py
Traceback (most recent call last):
  File "app.py", line 7, in <module>
    from PyQt5.QtCore import *
ModuleNotFoundError: No module named 'PyQt5'
```

注意，异常不一定是坏事，异常有时候正是程序员所期望的。比如，以上的异常完全正常，因为我们的程序的运行环境还缺少一些必要的东西。

## 7. 关于模块

一个好的程序员，肯定擅长在合适的场景选择使用合适的工具。我们要写的程序是一个图形界面程序，然而，Windows只对（也只能对）C语言和汇编语言开放了图形界面的相关接口。因此，一个Python程序是不能直接调用系统接口的。Python提供了Windows接口调用的相关模块，但是这些模块只能用于Windows操作系统。为了照顾苹果用户，我们需要让我们的应用程序可以跨操作系统（跨平台）运行。

理论上，我们可以分别调用Windows和macOS的底层API，写一个通用的程序出来。但是，这个工作量太大，不是一般人更不是小白能Hold住的。因此，我们选用第三方开发的图形界面模块来进行我们的界面开发。在这里，我们选择的是来自前诺基亚公司的`PyQt5`模块。

除了图形界面模块，Python中还有用于处理文件、网络等功能的各种模块。除了官方的模块，还有第三方开发的模块（任何人都可以开发并发布Python模块 ）。使用模块，可以屏蔽掉那些我们不关心的底层实现细节，快速开发我们需要的功能。

在Windows上，我们可以用`Chocolatey`管理软件包。在Python中，我们需要用`PIP`来管理Python模块。`PIP`不仅能安装我们需要的模块，也能自动处理模块间的依赖关系。

在命令行下执行`pip install PyQt5`，即可自动安装我们需要的图形模块PyQt5。同理于`Chocolatey`，我们也可以使用命令`pip search pyqt`搜索相关的模块。

`PyQt5`安装好后，继续运行命令`python app.py`。此时，应该可以看到应用窗体。这个窗体已经做好了自适应布局，可以随意拉伸缩放。拖入一个Word文档，点击`PDF`，将这个Word文档转为PDF格式。此时，程序应该会奔溃，界面应该会消失。

这次的程序奔溃非常正常，因为我们的应用的运行环境还缺少一些必要的依赖。我们做的应用是一个文档转格式应用。文档转格式，是一个很有技术含量，同时又十分枯燥的任务。所以，我们选择使用第三方的工具在后台帮我们转。

我选择使用`pandoc`来转换文档格式。`pandoc`转HTML格式没问题，但是转`PDF`的话，它本身并不会，需要依赖其他的转PDF工具。我配置的是一个比较小巧的`wkhtmltopdf`。`pandoc`和`wkhtmltopdf`都可以通过`Chocolatey`安装：

- `choco install pandoc`
- `choco install wkhtmltopdf`

安装完成后，再执行文档转换，应该会提示转换成功，并在当前目录下生成转换好的文件。

## 8. 自用开发好的软件

我们开发好的软件，不可能每次使用的时候都到命令行下打命令吧。好在正常安装了Python之后，`.py`文件就是可执行文件了，会自动调用Python来执行我们的程序。但是，直接运行`.py`文件，会带出一个控制台窗口，用以显示程序日志。这个控制台窗口非常扎眼，将`.py`文件重命名为`.pyw`(w表示Window)后，双击`.pyw`文件，就不会再拖出这个命令行窗口了。

## 9. 打包开发好的软件

独乐乐不如众乐乐。做好的程序能在我们电脑上运行，但是到别人电脑上是不能直接跑的。我们不能要求别人去安装Python、安装PyQt5、安装pandoc、安装wkhtmltopdf，尤其是这个别人是客户的时候。所以，我们需要把程序代码和全部的依赖打包到一个可执行文件里面。这样，只需要把这个`.exe`发送给别人，别人就可以直接双击运行了。

Python是一门脚本语言，用它写的程序不能直接运行，需要Python解释器来一行代码一行代码地顺序解释执行。打包应用，至少要把Python解释器打包到`.exe`里面。

Python官方不提供打包工具，因此，我们需要用到第三方的模块`PyInstaller`。打命令`pip install pyinstaller`安装。这是一个可执行模块，可以直接运行。

PyInstaller安装完成后，执行命令`pyinstaller --onefile app.py`，即可将`app.py`打包到`dist\app.exe`。

此时，双击这个`.exe`，程序正常运行，功能也没问题。但是，这个软件在别的电脑上还是没法正常工作的。因为`pandoc`和`wkhtmltopdf`还没有打包进去。不过，我也不清楚怎么打包外部的`.exe`，姑且先把`pandoc.exe`和`wkhtmltopdf.exe`放到`app.exe`目录下，将整个目录打包成一个压缩包吧。至少用户解包后，执行`app.exe`，还是能找到这两个依赖的。

`pandoc`和`wkhtmltopdf`的安装位置：

- C:\Users\Administrator\AppData\Local\Pandoc\pandoc.exe
- C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
