---
title: 面向聪明小白的编程入门教程 完成文档转换器(Part 10)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-26 19:16:54
---

知识储备得差不多了，是时候完成我们的文档转换器了。

<!--more-->

荀子有云：“君子生非异也，善假于物也”。不要说文档转换，就算是任意一个文档格式，也能写几本大书。所以，我们不可能去阅读各种文档格式的规范，手动实现文档转换。

因此，我们需要借助外部的文档转换工具。当然，不可能是一个图形化工具，不然我们的转换器也就没有存在的意义了。我们需要的是一个命令行工具，也就是可以在虚拟终端(控制台)下执行的工具。

我们选择的工具是`pandoc`。这是一个万能文档转换器，几乎支持所有主流文档格式的相互转换。如果要转`PDF`格式，`pandoc`需要依赖外部的工具，这里我们选择`wkhtmltopdf`。`pandoc`会将文档转成网页，然后再调用这个工具将网页转成`PDF`。

调用外部工具，涉及到了多进程的概念。`Python`会将外部工具运行在新进程里，然后根这个新进程交互，完成我们的文档转换。

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
for idx, (k, v) in enumerate(
        dict(docx="Word", pdf="PDF", pptx="PowerPoint", html="HTML", mobi="Mobi", epub="EPUB").items()):
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

这段代码涉及到的新知识点主要有：

1. 为了防止我们的对话框被`Python`回收掉，我们使用了`global`关键字，将对话框定义为全局变量。至于为什么Python会将我们好好运行着的对话框回收掉，我想是因为`Python`系统和`Qt`系统相互独立，一个对象在`Python`系统中好像没用了，但是在`Qt`系统中还在起作用。
2. `打开文件`对话框定位文件非常麻烦。所以，我们选用拖拽选择文件。`Qt`支持文件拖拽。在一个控件上调用`QWidget.setAcceptDrops(True)`，即可启用文件拖拽。一次文件拖拽会产生两个事件：拖和放。我们需要处理放事件，但是拖事件不处理，就不会产生放事件。我们需要在`QWidget.dragEnterEvent`中，调用`e.accept()`表示接受拖事件，这样才会产生放事件。
3. 一次拖放可能拖放多个文件。所以，在拖放事件中，`e.mimeData().urls()`可能会有多个文件的`URL`(QUrl对象)。调用`QUrl.path()`方法，可以将文件的`URL`转换成文件的磁盘路径。`next(iter(...), None)`可以安全地取出列表中的第一个元素，取不到则返回`None`。
4. 除了线性布局外，`Qt`还支持网格布局。`QGridLayout.addWidget(控件, 第几行, 第几列)`用来放置网格中的控件。`QGridLayout`会根据放置的控件自动调整布局。
5. 由于`Windows`和`macOS`的文件路径格式不一致，我们需要根据当前的操作系统类型处理文件路径。`platform.system()`方法可以获取当前的操作系统。
6. `subprocess.Popen`方法可以创建新进程，执行指定的程序。我们需要通过这个方法来调用`pandoc`。为了跟这个进程通信，我们需要将这个进程的输入和输出都通过管道进入我们的程序(比如`stdout=PIPE`)。
7. `process.communicate()`方法会执行进程，返回管道列表。第二个管道是标准错误流管道，如果转换出错，我们可以通过这个管道获取错误信息。通过管道获取到的是字节数组，我们需要调用`decode()`方法解码成字符串。
8. `process.returncode`是进程的结束代码。一般情况，0表示正常，其他表示出错。
9. `pandoc`调用格式类似`pandoc FROM.doc -o TO.pdf`。`-o`后面表示转换后文件的名称。`pandoc`会根据这个名称的后缀确定转换格式。如果要转`PDF`，需要使用选项`--pdf-engine`指定PDF引擎。
10. 在`Windows`下，调用控制台程序会拖出一个控制台窗口。为了避免这种情况，`Popen`函数需要传入`Windows`操作系统专用的参数`startupinfo`。由于这个参数对应的类在其他操作系统中不存在，直接`import`会导致程序无法在其他操作系统下运行。所以，我们将这些逻辑放在一个`try...except`块中，忽略掉产生的异常，避免程序奔溃。

师父领进门，修行在个人。教程虽短，涉及到的东西可不少，需要多多练习才能逐渐掌握。由于笔者水平太次，找工作屡屡碰壁，需要时间来反省反省。所以，这个系列教程就暂时完结了。希望读者们可以拥抱谷歌大法，创造美好明天！

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
