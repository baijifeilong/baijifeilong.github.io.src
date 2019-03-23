---
title: 面向聪明小白的编程入门教程 深入Qt(Part 6)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-23 19:33:10
---

经过上一节的学习，我们熟悉了Qt的一些基本用法。本节继续深入。

<!--more-->

## 1. 消息框

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QMessageBox
)
from datetime import datetime

app = QApplication([])
btn = QPushButton("明月几时有？")
btn.resize(600, 600 * 0.618)
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setObjectName("MyButton")
btn.setStyleSheet("#MyButton { color: magenta }")
btn.clicked.connect(lambda: QMessageBox.information(btn, None, f"明月 {str(datetime.now())[:19]} 有"))
btn.show()
app.exec()
```

执行这段代码，点击按钮，会弹出一个对话框，显示系统的当前时间。

Qt内置了多种对话框，供开发者直接调用。最常用的对话框是消息对话框，通过`QMessageBox.information`调用。此函数接收至少三个参数，第一个参数是父控件，第二个参数是对话框标题，第三个参数是对话框正文。除了`information`消息对话框外，还可以使用`warning`弹出报警对话框，使用`critical`弹出错误对话框。

对于对话框来说，它会居中于父控件显示。如果父控件为空，它会居中于屏幕显示。

在这段代码中，我们接触到到了很多新知识。其中:

1. datetime是Python内置的日期时间处理模块。`datetime.datetime`是日期时间(日期+时间)类。从`datetime`导入`datetime`，模块名和类名相同。由于Python是一门草根语言，难免会有部分命名匪夷所思，以后就见怪不怪了。
2. `datetime.now()`获取当前的日期时间，返回一个日期时间(datetime)对象。
3. 我们需要获取日期时间的字符串形式，所以调用了方法`str`。`str`可以将对象转换为字符串。比如日期时间对象，转换为字符串的格式类似于`2019-03-23 19:50:26.439716`。
4. 由于我们不需要微秒部分，所以需要把多余的部分截取掉。语法`[0:19]`可以截取字符串的前19位。在大多数编程语言中，索引(序号)都是从0开始的，区间范围一般都是左闭右开，`[0:19]`即`[0,19)`，即从索引0到索引18，共19个字符。`[0:19]`可以简写为`[:19]`。除了从前往后索引外，我们还可以从后往前索引。对于`datetime`字符串，`[0:19]`于`[0:-7]`截取的结果一致。 `[0:-7]`表示从索引0截取到索引-7(不包括)。负数的索引不是从0开始，而是从1开始。索引-7即表示倒数第七个字符。`[0:-7]`也可以简写为`[:-7]`。
5. `information`方法的第三个参数是一个字符串，因此我们需要做字符串拼接。字符串的拼接可以使用`+`符号，也可以用`f`语法。如果字符串前缀以`f`字符，字符串里`{}`里面的文本就会当作`Python`代码运算。

## 2. 动态更新窗体标题

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QWidget
)
from datetime import datetime

app = QApplication([])
btn = QPushButton("明月几时有？")
btn.resize(600, 600 * 0.618)
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setObjectName("MyButton")
btn.setStyleSheet("#MyButton { color: magenta }")
btn.clicked.connect(lambda: btn.setWindowTitle(f"明月 {str(datetime.now())[:-7]} 有"))
btn.show()
app.exec()
```

执行这段代码，每次点击按钮，都会将当前的系统时间更新到窗口的标题栏。

## 3. 使用状态栏

普通的按钮只是一个简单的控件，不可能内嵌一个状态栏。为了简化开发，`Qt`提供了一个通用的主窗体类`QMainWindow`。这个窗体内置了菜单栏、工具栏和状态栏，省却了程序员自己布局。

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QMainWindow,
    QStatusBar
)
from datetime import datetime

app = QApplication([])
wnd = QMainWindow()
wnd.setWindowTitle("白云千载空悠悠")
wnd.resize(600, 600 * 0.618)
sb: QStatusBar = wnd.statusBar()
sb.setFont(QFont("Aria", 27))
sb.setStyleSheet("color: green")
btn = QPushButton("明月几时有？")
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setObjectName("MyButton")
btn.setStyleSheet("#MyButton { color: magenta }")
btn.clicked.connect(lambda: sb.showMessage(f"明月 {str(datetime.now())} 有"))
wnd.setCentralWidget(btn)
wnd.show()
app.exec()
```

执行以上代码，每次点击按钮，都会把当前日期时间更新到状态栏。要点：

1. `QMainWindow.setCentralWidget`用来设置窗体的中心控件，也就是主控件。这个中心控件的大小会自动适应窗体大小。所以，在中心控件上调用`resize`没有效果，需要`resize`的是主窗体`wnd`。
2. `QMainWindow.statusBar`方法可以获取窗体的状态栏
3. `QStatusBar.showMessage`方法可以更新状态栏
4. `QFont('Aria', 27)`构造函数会生成大小为27个像素点(1K分辨率的屏幕有200万个像素点)的Aria字体
5. 主窗体是根控件，应该调用主窗体的`show`方法来显示窗体。
6. 由于`PyQt5`的代码不够完善，IDE无法推导`QMainWindow.statusBar`方法返回的数据类型。`sb: QStatusBar`这种语法用来做类型提示，在执行代码时不起作用，但是可以告知IDE当前变量的类型，帮助IDE做代码分析与提示

## 4. 初识布局

由于`Qt`的状态栏在苹果系统上显示得挺丑，我们决定使用自定义的布局来显示当前时间。

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QWidget,
    QLabel,
    QVBoxLayout
)
from PyQt5.QtCore import Qt
from datetime import datetime

app = QApplication([None, '-style=Macintosh'])
wnd = QWidget()
wnd.setWindowTitle("白云千载空悠悠")
wnd.resize(600, 600 * 0.618)
lbl = QLabel("Ready.")
lbl.setStyleSheet("color: lime; font-size: 108px; background: teal")
lbl.setAlignment(Qt.AlignCenter)
btn = QPushButton("明月几时有？")
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("color: magenta")
btn.clicked.connect(lambda: lbl.setText(datetime.now().strftime('%X')))
box = QVBoxLayout()
box.addWidget(lbl)
box.addWidget(btn)
wnd.setLayout(box)
wnd.show()
app.exec()
```

执行以上代码，可以看到窗体中从上到下排列了两个控件。上面的是一个文本框，下面的是一个按钮。拖动窗体边框来拉伸窗体，会发现按钮只能左右伸缩，而文本标签会同时进行水平伸缩和垂直伸缩来填充剩余空间。说明这两个控件有不同的布局策略。

这段代码引入的新知识：

- `QApplication` 构造函数列表的第二个参数可以用来设置显示主题。Qt支持Windows主题(Windows)和macOS主题(Macintosh)
- `datetime.strftime` 可以按照指定的格式来格式化日期时间，'%X'只显示时分秒。
- `QVBoxLayout` 是一种垂直布局，子控件按照`QVBoxLayout.addWidget`的执行顺序依次排列各子组件

## 5. 均分布局

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QWidget,
    QLabel,
    QVBoxLayout,
    QSizePolicy
)
from PyQt5.QtCore import Qt
from datetime import datetime

app = QApplication([None, '-style=Macintosh'])
wnd = QWidget()
wnd.setWindowTitle("白云千载空悠悠")
wnd.resize(600, 600 * 0.618)
lbl = QLabel("Ready.")
lbl.setStyleSheet("color: lime; font-size: 108px; background: teal")
lbl.setAlignment(Qt.AlignCenter)
btn = QPushButton("明月几时有？")
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("color: magenta")
btn.clicked.connect(lambda: lbl.setText(datetime.now().strftime('%X')))
btn.setSizePolicy(QSizePolicy.Preferred, QSizePolicy.Preferred)
box = QVBoxLayout()
box.addWidget(lbl)
box.addWidget(btn)
wnd.setLayout(box)
wnd.show()
app.exec()
```

要点：

- `QSizePolicy` 类表示控件的缩放策略。`QSizePolicy.Preferred`表示这个控件可以被缩放
- `QPushButton`是`QWidget`的子类，`QPushButton`可以调用`QWidget`提供的任何方法
- `QWidget.setSizePolicy` 可以用来设置控件的缩放策略，两个参数分别代表水平方向和垂直方向的缩放策略

## 6. 按比例均分布局

接下来的例子中，我们将演示如何按比例来均分布局。

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QWidget,
    QLabel,
    QVBoxLayout,
    QSizePolicy,
    QToolButton
)
from PyQt5.QtCore import Qt
from datetime import datetime

app = QApplication([None, '-style=Macintosh'])
wnd = QWidget()
wnd.setWindowTitle("白云千载空悠悠")
wnd.resize(600, 600 * 0.618)
lbl = QLabel("Ready.")
lbl.setStyleSheet("color: lime; font-size: 108px; background: teal")
lbl.setAlignment(Qt.AlignCenter)
lbl.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
btn = QPushButton()
btn.setText("明月几时有？")
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("QPushButton { color: magenta; border: none }"
                  "QPushButton:pressed { background: lightcyan }")
btn.clicked.connect(lambda: lbl.setText(datetime.now().strftime('%X')))
btn.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
box = QVBoxLayout()
box.setSpacing(0)
box.setContentsMargins(0, 0, 0, 0)
box.addWidget(lbl, 2)
box.addWidget(btn, 1)
wnd.setLayout(box)
wnd.show()
app.exec()
```

运行以上代码，缩放窗口，会发现两个控件的高度始终保持`2:1`。这段代码要点如下：

1. `QVBoxLayout.addWidget`函数的第二个参数是拉伸因子，表示填充布局剩余空间的能力的比重
2. `QSizePolicy.Ignored`也支持自动缩放，但是最小大小是0，意思是可以缩小到消失
3. `QVBoxLayout.setSpacing`设置布局子控件的间距
4. `QVBoxLayout.setContentMargins`设置布局的边距，四个参数分别表示左、上、右、下
5. `border: none`可以隐藏按钮的边框，但是也会丢失掉默认的点击动画
6. `QPushButton:pressed`可以用来设置按钮在按下时的样式，用来实现点击动画
7. `Python`会自动将两个相邻的字符串合并为一个字符串

## 7. 布局嵌套

布局可以互相嵌套。

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QWidget,
    QLabel,
    QVBoxLayout,
    QSizePolicy,
    QToolButton,
    QHBoxLayout
)
from PyQt5.QtCore import Qt
from datetime import datetime

app = QApplication([None, '-style=Macintosh'])
wnd = QWidget()
wnd.setWindowTitle("白云千载空悠悠")
wnd.resize(666, 666 * 0.618)
lbl = QLabel("经海底问无由")
lbl.setStyleSheet("color: lime; font-size: 108px; background: teal")
lbl.setAlignment(Qt.AlignCenter)
lbl.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
btn = QPushButton("明月几时有")
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("QPushButton { color: aqua; border: none; background: seagreen }"
                  "QPushButton:pressed { background: olive }")
btn.clicked.connect(lambda: lbl.setText(str(datetime.now())[11:-4]))
btn.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
bye = QPushButton("休休")
bye.setFont(btn.font())
bye.setStyleSheet("QPushButton { color: aqua; border: none; background: darkgoldenrod }"
                  "QPushButton:pressed { background: olive }")
bye.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
bye.clicked.connect(QApplication.exit)
btm = QHBoxLayout()
btm.addWidget(btn, 2)
btm.addWidget(bye, 1)
box = QVBoxLayout()
box.setSpacing(0)
box.setContentsMargins(0, 0, 0, 0)
box.addWidget(lbl, 2)
box.addLayout(btm, 1)
wnd.setLayout(box)
wnd.show()
app.exec()
```

执行以上代码，可以看到窗体同时使用了水平布局和垂直布局。要点：

- `QHBoxLayout`表示水平布局
- `QBoxLayout.addLayout`可以添加子布局

## 8. 全屏切换

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QWidget,
    QLabel,
    QVBoxLayout,
    QSizePolicy,
    QToolButton,
    QHBoxLayout
)
from PyQt5.QtCore import Qt
from datetime import datetime

app = QApplication([None, '-style=Macintosh'])
wnd = QWidget()
wnd.setWindowTitle("白云千载空悠悠")
wnd.resize(999, 999 * 0.618)
lbl = QLabel("经海底问无由")
lbl.setStyleSheet("color: lime; font-size: 108px; background: teal")
lbl.setAlignment(Qt.AlignCenter)
lbl.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
btn = QPushButton("明月几时有")
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("QPushButton { color: aqua; border: none; background: seagreen }"
                  "QPushButton:pressed { background: olive }")
btn.clicked.connect(lambda: lbl.setText("经海底问无由\n" + str(datetime.now())[11:-4]))
btn.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
big = QPushButton("画屏幽")
big.setFont(btn.font())
big.setStyleSheet("QPushButton { color: aqua; border: none; background: steelblue }"
                  "QPushButton:pressed { background: olive }")
big.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
big.clicked.connect(lambda: wnd.showNormal() if wnd.isFullScreen() else wnd.showFullScreen())
bye = QPushButton("休休")
bye.setFont(btn.font())
bye.setStyleSheet("QPushButton { color: aqua; border: none; background: forestgreen }"
                  "QPushButton:pressed { background: olive }")
bye.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
bye.clicked.connect(QApplication.exit)
btm = QHBoxLayout()
btm.addWidget(btn, 3)
btm.addWidget(big, 2)
btm.addWidget(bye, 1)
box = QVBoxLayout()
box.setSpacing(0)
box.setContentsMargins(0, 0, 0, 0)
box.addWidget(lbl, 2)
box.addLayout(btm, 1)
wnd.setLayout(box)
wnd.show()
app.exec()
```

要点：

- `QWidget.showFullScreen()` 进入全屏模式
- `QWidget.showNormal()` 退出全屏模式
- `QWidget.isFullScreen()` 判断控件是否全屏，返回值是布尔值(只有True和False两种情况)
- `吃饭 if 饿了 else 减肥` 这种语法中`if`要倒装
- 字符串中以`\`开头的字符有特殊意义，比如`\n`表示换行

## 9. 移除窗体边框

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QWidget,
    QLabel,
    QVBoxLayout,
    QSizePolicy,
    QHBoxLayout
)
from PyQt5.QtCore import Qt
from datetime import datetime

app = QApplication([None, '-style=Macintosh'])
wnd = QWidget()
wnd.setWindowTitle("白云千载空悠悠")
wnd.resize(999, 999 * 0.618)
lbl = QLabel("经海底问无由")
lbl.setStyleSheet("color: lime; font-size: 108px; background: teal")
lbl.setAlignment(Qt.AlignCenter)
lbl.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
btn = QPushButton("明月几时有")
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("QPushButton { color: aqua; border: none; background: seagreen }"
                  "QPushButton:pressed { background: olive }")
btn.clicked.connect(lambda: lbl.setText("经海底问无由\n" + str(datetime.now())[11:-4]))
btn.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
big = QPushButton("画屏幽")
big.setFont(btn.font())
big.setStyleSheet("QPushButton { color: aqua; border: none; background: steelblue }"
                  "QPushButton:pressed { background: olive }")
big.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
big.clicked.connect(lambda: wnd.showNormal() if wnd.isFullScreen() else wnd.showFullScreen())
bye = QPushButton("休休")
bye.setFont(btn.font())
bye.setStyleSheet("QPushButton { color: aqua; border: none; background: forestgreen }"
                  "QPushButton:pressed { background: olive }")
bye.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
bye.clicked.connect(QApplication.exit)
btm = QHBoxLayout()
btm.addWidget(btn, 3)
btm.addWidget(big, 2)
btm.addWidget(bye, 1)
box = QVBoxLayout()
box.setSpacing(0)
box.setContentsMargins(0, 0, 0, 0)
box.addWidget(lbl, 2)
box.addLayout(btm, 1)
wnd.setLayout(box)
wnd.setWindowFlags(Qt.FramelessWindowHint)
wnd.show()
app.exec()
```

`QWidget.setWindowFlags(Qt.FramelessWindowHint)`可以移除窗体边框。

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
