---
title: 面向聪明小白的编程入门教程 低耦合高内聚(Part 9)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-26 17:58:14
---

在上一节的示例中，我们的程序已经膨胀到了一百多行，代码也开始变得乱七八糟。在这一节中，我们将学习如何拆解代码，构造有条理的程序。

<!--more-->

代码变长变乱，不仅影响别人的阅读和理解，更容易藏污纳垢，给以后的扩展与维护留下隐患。

代码太长，而每一行代码又都是必要的，不能随便删掉。所以，我们想到的第一种思路就是拆分代码。将一段很长的代码拆分成多段相对较短的代码，每段代码处理起来就会相对容易一些。

事实上，之前的代码我们已经用到了代码拆分。我们将段子的下载功能封装到了两个类(class)中。不过，我们当初这么做不是为了分解代码，而是为了实现多线程不得已而为之。

我们的段子下载器名字叫`JokesFetcher`。顾名思义，是用来下载段子的。但是这个下载器不仅下载了段子，还在下载结束后更新了UI。这样，这个类实现的功能不仅超出了它名字中表达的范围，更将更新界面和下载段子的逻辑揉到了一起。

相关度不高的代码逻辑被混杂在一起，在代码量较少时还勉强可以看懂，但是当代码量变大时，就会将整个程序搞得一团糟。就算是在现有的代码上添加新功能，也会很难下手。

这种现象在软件设计界的专业术语叫做违背了`单一职责`。

拆解代码，必然需要选择一个拆解的维度。为了程序逻辑的清晰，一般的拆解维度是代码块的功能。拆解的原则是“低耦合高内聚”，意思是每个代码块里面的代码相关度要特别高，实现的是明确的同一个任务，各个代码块要尽可能减少关联，降低交互的成本。

在我们的代码中，为了程序的简洁，应用、窗体、布局、控件、下载器等功能各异的对象，都被放在了全局的作用域下。随着我们代码的扩张，这些变量的数量在不断窜升，它们之间的关联关系也越来越模糊。

为了将这些变量归类整理，我们引入了面向对象的编程思想。我们把内聚性(内在关联性)很强的数据和方法封装在一个类(`class`)里，再通过功能相对单一的各个类的相互通信，组装成我们的整个应用程序。

```python
from PyQt5.Qt import (
    QApplication,
    QWidget,
    QLabel,
    QPushButton,
    QVBoxLayout,
    QSizePolicy,
    QHBoxLayout,
    QProgressDialog
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal, QSignalMapper
from urllib.request import urlopen
from parsel import Selector
import textwrap


class App(QApplication):
    wnd: QWidget
    dlg: QProgressDialog
    btn: QPushButton
    lbl: QLabel
    lft: QVBoxLayout

    def __init__(self):
        super().__init__([])
        self.mapper = QSignalMapper()
        self.jokesFetcher = JokesFetcher()
        self.jokeFetcher = JokeFetcher()
        self.setupLayout()
        self.setupDialog()
        self.setupEvents()

    def setupEvents(self):
        self.jokesFetcher.done.connect(self.onJokesFetched)
        self.jokeFetcher.done.connect(self.onJokeFetched)
        self.btn.clicked.connect(lambda: [self.dlg.show(), self.jokesFetcher.start()])
        self.mapper.mapped["QString"].connect(lambda url: [self.dlg.show(), self.jokeFetcher.startWithUrl(url)])

    def onJokesFetched(self, jokes):
        for index, joke in enumerate(jokes):
            btn: QPushButton = self.lft.itemAt(index).widget()
            self.mapper.setMapping(btn, joke["href"])
            btn.setText(textwrap.fill(joke["title"][:24], 12))
            btn.clicked.connect(self.mapper.map)
        self.dlg.close()

    def onJokeFetched(self, joke):
        self.lbl.setText(joke)
        self.dlg.close()

    def setupDialog(self):
        dlg = QProgressDialog()
        dlg.setMaximum(0)
        dlg.setCancelButton(None)
        dlg.setWindowFlags(Qt.FramelessWindowHint)
        dlg.setWindowModality(Qt.WindowModal)
        dlg.close()
        self.dlg = dlg

    def setupLayout(self):
        lbl = QLabel("Ready.")
        lbl.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
        lbl.setWordWrap(True)
        lbl.setStyleSheet("font-size: 36px")
        btn = QPushButton("刷新段子")
        lft = QVBoxLayout()
        lft.setSpacing(1)
        top = QHBoxLayout()
        top.addLayout(lft)
        top.addWidget(lbl)
        box = QVBoxLayout()
        box.addLayout(top)
        box.addWidget(btn)
        box.setSpacing(0)
        box.setContentsMargins(0, 0, 0, 0)
        wnd = QWidget()
        wnd.setWindowTitle("五个段子")
        wnd.resize(999, 999 * 0.618)
        wnd.setLayout(box)
        wnd.show()
        wnd.setStyleSheet(
            "* { font-size: 72px; color: lime; background: darkturquoise }"
            "QLabel { background: teal; qproperty-alignment: AlignCenter }"
            "QPushButton { background: darkgreen; border: none }"
            "QPushButton:hover { background: seagreen }"
            "QPushButton:pressed { background: green }"
        )
        for i in range(1, 6):
            wgt = QPushButton(f"段子{i}")
            wgt.setStyleSheet("* { font-size: 36px; background: steelblue }"
                              "*:hover { background: cadetblue }")
            wgt.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
            lft.addWidget(wgt)
        self.wnd = wnd
        self.btn = btn
        self.lbl = lbl
        self.lft = lft


class JokeFetcher(QThread):
    done = pyqtSignal(object)
    url: str

    def run(self):
        html = urlopen(self.url).read().decode()
        title = Selector(html).xpath("//article//h1/text()").get()
        content = "\n".join(Selector(html).xpath("//article/section/p/text()").getall())
        self.done.emit(f"{title}\n{content}")

    def startWithUrl(self, url):
        self.url = url
        self.start()


class JokesFetcher(QThread):
    done = pyqtSignal(object)

    def run(self):
        html = urlopen("https://duanziwang.com").read().decode()
        jokes = [x.attrib for x in Selector(html).xpath("//div/li/a")]
        self.done.emit(jokes)


App().exec()
```

经过封装，我们将整个应用程序抽象成`App`类。而`Qt`应用也需要一个全局的`QApplication`，我们正好将我们的`App`类继承`QApplication`。

对于这个应用，我们将其拆解成三个方法：初始化布局、初始化对话框与初始化事件处理。在初始化布局中，我们将应用程序所需要的各种控件创建出来，并布局到窗体中。在初始化对话框中，我们创建了一个单独的加载对话框。在初始化事件处理中，我们将刷新段子与加载单个段子的事件与相应的槽函数连接起来。

对于刷新段子列表和刷新段子内容等与段子下载器无关的功能，我们将其移动到了`App`类中。这样，便保证了下载器的单一职责，减少了下载器与外界不必要的耦合。

`低耦合高内聚`这种编程思想，只可意会不可言传。说起来是一套，做起来可能又是一套。思想这种东西，需要靠自己领悟。在对代码精益求精的追求中，必然会走向`低耦合高内聚`。

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
