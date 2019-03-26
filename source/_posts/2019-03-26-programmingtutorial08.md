---
title: 面向聪明小白的编程入门教程 多任务(Part 8)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-26 15:28:52
---

我们上节中做的应用，在访问网络时，会造成界面假死。虽然界面假死不影响功能，但是会影响用户体验。本节课，我们就来学习如何避免这种情况。

<!--more-->

首先，我们得明白为什么应用窗口会在访问网络时假死。在我们的应用程序中，所有的代码都是顺序执行的，一步结束才能进行下一步。在请求网络时，我们的代码进入阻塞(等待)状态，必须等待网页下载结束或者有异常情况发生才能将这句代码执行完毕。Qt框架会响应用户的点击等操作，但是响应用户的点击事件也是要执行代码的。由于请求网络的代码阻塞了整个应用，所以响应用户事件的代码没有机会执行，这样导致的结果是窗口假死。

要想在下载网页时，让窗口也能响应用户操作，就得让下载网页的代码与响应用户事件的代码同时执行。但是到目前为止，我们写的代码都是从头到尾一行行依次执行的。要想让代码同时执行，需要引入多任务机制。

Windows操作系统本身支持多任务机制。我们可以一边听音乐，一边打游戏。这种多任务机制是最常见的多进程。我们的应用只是操作系统的一个进程，所以多进程机制对我们的应用并不合适。音乐播放器多支持边下边播，可见，单个进程内部也是可以实现多任务的。

单个进程内的多任务，叫做多线程。线程是操作系统任务调度的最小单位。意思是，线程是Python代码向操作系统申请的。受CPU核心数的限制，多个线程不一定是完全并行(同时)运行的。大部分情况下，多个线程是交替执行的，但是由于交替得太快(毫秒到微秒级)，所以给我们造成多个线程同时执行的错觉。

为了不让我们的应用假死，我们计划让下载任务走单独的线程，下载的同时显示加载对话框。加载结束后，需要关闭对话框。跨线程操作Qt界面控件是不安全的，可能会造成应用奔溃。所以，我们需要告知主线程(代码默认运行在主线程)下载结束，让主线程来更新UI(User Interface, 用户界面)。这就涉及到了多线程通信的话题。

在Python中，多线程通信一般用队列(Queue)来实现，一个线程向队列发消息，另一个线程向队列拉消息。但是，队列这个概念太过抽象，放在我们的应用中难以理解。好在Qt提供的比较直观易懂的`信号-槽`机制可以用在多线程里。所以，我们选用Qt的信号来进行多线程通信。

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

app = QApplication([])
lbl = QLabel("Ready.")
lbl.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
lbl.setWordWrap(True)
lbl.setStyleSheet("font-size: 36px")
btn = QPushButton("刷新段子")
lft = QVBoxLayout()
lft.setSpacing(1)
for i in range(1, 6):
    wgt = QPushButton(f"段子{i}")
    wgt.setStyleSheet("* { font-size: 36px; background: steelblue }"
                      "*:hover { background: cadetblue }")
    wgt.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
    lft.addWidget(wgt)
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

dlg = QProgressDialog()
dlg.setMaximum(0)
dlg.setCancelButton(None)
dlg.setWindowFlags(Qt.FramelessWindowHint)
dlg.setWindowModality(Qt.WindowModal)
dlg.close()


class JokeFetcher(QThread):
    done = pyqtSignal(object)
    url: str

    def __init__(self):
        super().__init__()
        self.done.connect(self.on_joke_fetched)

    @staticmethod
    def on_joke_fetched(joke):
        lbl.setText(joke)
        dlg.close()

    def run(self):
        html = urlopen(self.url).read().decode()
        title = Selector(html).xpath("//article//h1/text()").get()
        content = "\n".join(Selector(html).xpath("//article/section/p/text()").getall())
        self.done.emit(f"{title}\n{content}")

    def start_with_url(self, url):
        self.url = url
        self.start()


class JokesFetcher(QThread):
    done = pyqtSignal(object)

    def __init__(self):
        super().__init__()
        self.done.connect(self.on_jokes_fetched)
        self.joke_fetcher = JokeFetcher()
        self.mapper = QSignalMapper()
        self.mapper.mapped["QString"].connect(lambda url: [dlg.show(), self.joke_fetcher.start_with_url(url)])

    def on_jokes_fetched(self, jokes):
        for index, joke in enumerate(jokes):
            btn: QPushButton = lft.itemAt(index).widget()
            self.mapper.setMapping(btn, joke["href"])
            btn.setText(textwrap.fill(joke["title"][:24], 12))
            btn.clicked.connect(self.mapper.map)
        dlg.close()

    def run(self):
        html = urlopen("https://duanziwang.com").read().decode()
        jokes = [x.attrib for x in Selector(html).xpath("//div/li/a")]
        self.done.emit(jokes)


jokes_fetcher = JokesFetcher()

btn.clicked.connect(lambda: [dlg.show(), jokes_fetcher.start()])
app.exec()
```

以上是完成后的代码。下载段子时，会弹出一个加载对话框。下载结束后，对话框会自动关闭。这段代码涉及到了不少新知识，我来解释一下：

1. `QApplication.setStyleSheet`可以设置应用程序的全局样式，全局样式会影响到我们的加载对话框。为了让加载对话框保持Qt的默认样式，我们将全局样式设置到了主窗体(一个`QWidget`)上。
2. `QProgressDialog`是`Qt`内置的进度对话框。因为我们下载网页没有确定的时间，也不需要具体的进度。所以，我们要把进度条设为不确定模式。在`Qt中`，`QProgressDialog.setMaximum(0)`可以实现这种效果。
3. 进度对话框默认有一个`取消`按钮。为简单起见，我们不想处理取消下载的逻辑。所以，我们隐藏掉这个按钮。`QProgressDialog.setCancelButton(None)`可以实现这个效果。
4. `QProgressDialog.setWindowFlags(Qt.FramelessWindowHint)`可以隐藏对话框的边框。
5. 进度对话框弹出后，我们不想让用户可以点击我们的主窗体。实现这种效果的对话框叫`模态对话框`。在`Qt`中，调用`QProgressDialog.setWindowModality(Qt.WindowModal)`即可。
6. `Python`有自己的多线程模块，但是为了利用`Qt`提供的`信号槽`机制，我们选择使用`Qt`提供的多线程功能。即继承`QThread`类。目前，我们可以将继承理解为克隆后按需修改。比如我们的`JokesFetcher`类，继承了`QThread`，但是修改了它的`run`方法。这样，相当于我们自定了线程的执行逻辑。
7. `__init__`是类的初始化方法。在类中定义了`__init__`方法后，会覆盖父类的同名的初始化方法。调用`super().__init__()`可以调用父类的初始化方法，保证父类的初始化逻辑也被执行。
8. 按惯例，在类的实例方法中，`self`表示对象(类的实例)自身。
9. 在`class`中定义的方法，默认情况下是实例方法(类的实例才能调用)，而不是静态方法或类方法(类可以直接调用)。实例方法的第一个参数被当作对象自身(一般表示为`self`)。在方法前面加`@staticmethod`可以将方法定义为静态方法。
10. `QThread.run`方法定义线程的主逻辑。在调用`QThread.start()`启动线程后，`QThread.run`方法会被执行。
11. Qt的信号通过`pyqtSignal(...)`方法来定义。括号中是信号所携带数据的类型。留空的话，表示空信号。我们将信号类型设为`object`。在`Python`中`ojbect`是一切类型的祖宗类，因此可以表示任意类型的数据。
12. `pyqtSignal.emit()`方法可以用来发射信号
13. `pyqtSignal.connect()`方法可以将信号绑定到槽函数
14. 在上节中，我们通过`app.sender()`方法在槽函数中获取被点击的按钮。但是，这个方法是用来返回最新信号源的，从定义上来说并不可靠，在这节的例子中会返回`None`。所以，我们换一种解决方案。`Qt`提供了`QSingalMapper`类，用来做信号映射。在这里，我们将按钮点击的事件映射成段子的`url`。这样，槽函数便可以直接接收到段子的网址。
15. 之所以在创建进度对话框后，直接调用`QProgressDialog.close()`方法，是因为这个对话框不`close()`的话会自己弹出来。

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
