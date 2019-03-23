---
title: 面向聪明小白的编程入门教程 熟悉Qt(Part 5)
categories:
  - Programming
  - Python
tags:
  - Programming
  - Python
  - Tutorial
date: 2019-03-23 09:39:51
---

对Python的语法有一些基本的了解后，是时候一笔笔勾描我们的文档转换器了。

<!--more-->

## 1. 更换新的Python控制台

在命令行下打`python`再回车，会开启一个Python控制台。这个控制台，专业术语叫做REPL(“读取-求值-输出”循环，Read-Eval-Print Loop)，是一个交互式编程环境。意思是，我们不需要写完整段代码再全部运行，而是可以一行代码一行代码地编写，一行代码一行代码地执行。对于初学者来说，这个环境非常有用，可以及时发现程序的错误，也可以直观感受到程序的执行流程。

Python自带的控制台，功能非常简陋，没有代码高亮，没有代码补全。因此，我推荐使用第三方提供的Python控制台。常用的第三方Python控制台主要有`BPython`、`PTPython`和`IPython`。这三个控制台，经过我的比较，分别有以下特点：

- `BPython` 代码补全的速度最快，但是代码补全不完整，有的符号补不出来，比如`__builtins__`(Python内建模块，默认自动导入)
- `PTPython` 代码补全的速度稍慢，但是补全地比较完整
- `IPython` 代码补全地比较完整，但是需要按`Tab`键触发补全，特点是功能强大，比如可以直接执行Shell(系统命令行)

综合考虑，我们选择使用`PTPython`。建议读者将这三个控制台都安装上，自行比较。使用PIP安装：

- `BPython`: `pip install bpython`
- `PTPython`: `pip install ptpython`
- `IPython`: `pip install ipython`

## 2. 在控制台中编写并测试Qt应用

为了照顾小白用户，前期的教程在`Windows`下编写。编程环境准备得差不多后，`Windows`和`macOS`的用法就差不多了。从现在起，我就切到我用着更顺手的黑苹果系统上继续编写这组教程了。在之后的教程中，命令行下的输出可能会跟`Windows`读者的不太一样。

### 2.1 初识PTPython

在命令行下打`ptpython`，显示如下：

```bash
 ~/ ptpython
>>>

 [F4] Emacs  1/1 [F3] History [F6] Paste mode                                                              [F2] Menu - CPython 3.7.2
```

按下键盘上的`F4`，可以切换`Emacs`和`VIM`编辑模式。至于`Emacs`和`VIM`是什么，小白用户就可以不用关心了。`F3`查看命令历史，意思是显示最近打过的Python命令。`F6`是粘贴模式，我没看出来有啥用。`F2`打开设置菜单，再按`F2`关闭菜单。不过这些快捷键都不重要，一般都用不到。

### 2.2 试错

我们要创建一个Qt窗体应用，需要调用`PyQt5`模块的`QApplication`方法。在`PTPython`中打`QApplication`回车，弹出错误提示：

```bash
>>> QApplication
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'QApplication' is not defined

name 'QApplication' is not defined
```

提示中说，名称`QApplication`没有被定义。Python中有来自官方和第三方的大量模块，不可能全部自动导入。因此，使用模块要先导入。

### 2.3 PTPython的智能提示

在`PTPython`中打`from PyQt5.Q`，应该会显示如下：

```bash
 ~/ ptpython
>>> from PyQt5.Q
           Qt                  QtHelp              QtNetworkAuth       QtQuick             QtSvg               QtXmlPatterns
           QtBluetooth         QtLocation          QtNfc               QtQuickWidgets      QtTest
           QtCore              QtMacExtras         QtOpenGL            QtRemoteObjects     QtWebChannel
           QtDBus              QtMultimedia        QtPositioning       QtSensors           QtWebSockets
           QtDesigner          QtMultimediaWidgets QtPrintSupport      QtSerialPort        QtWidgets
           QtGui               QtNetwork           QtQml               QtSql               QtXml
```

`PTPython`会动态地根据当前输入的字符进行代码的智能提示。我们可以看出来，在`PyQt5`这个模块中，以大写字母`Q`开头的子模块共有31个。不过不用害怕，`Qt`是一个巨无霸的多功能框架，我们只会用到其中的一丢丢功能。

此时按下回车，`PtPython`会智能地检测到我们的语法错误，不执行此代码，而是弹出错误提示`Syntax Error`。

### 2.4 关于类

继续补全代码为`from PyQt5.Qt import QApplication`，回车，没有任何输出。说明我们的这个`从模块导入`的语句运行没有出错。

再次输入`QApplication`回车，显示如下：

```bash
>>> QApplication
<class 'PyQt5.QtWidgets.QApplication'>
```

`PTPython`告诉我们，`QApplication`是一个名叫`PyQt5.QtWidgets.QApplication`的类(`class`)。在`Python`中，`.`表示层级关系，`PyQt5`是根模块，`QtWidgets`是`PyQt5`的子模块，`QApplication`是`QtWidgets`子模块下的一个类。`类`是一个比较抽象的概念，是对一组相似对象的归类。这些相似对象有相似的属性（特征/数据），或者也有相似的行为（方法/函数）比如：

- 将黄色、紫色、黑色等对象抽象为颜色（类），颜色类规定了这些对象都有属性红色分量(red)、绿色分量(green)、蓝色分量(blue)，都有方法`反相`，可以将自己的颜色变成相反的颜色
- 将橘子、香蕉、苹果等对象抽象为水果（类），水果类规定了这些对象都有属性颜色、味道、价格等
- 将文本框、按钮、下拉框等对象抽象为控件，控件类规定了这些对象都有属性位置、大小，都有方法调整位置、调整大小等。

`QApplication`是我们从`PyQt5.Qt`模块导入的，但是`PTPython`却告诉我们`QApplication`来自`PyQt5.QtWidgets`。这是因为`PyQt5.Qt`模块也导入了`PyQt5.QtWidgets.QApplication`，所以我们也可以从`PyQt5.Qt`模块导入这个`QApplication`。`PyQt5`中常用的一些类分散在多个模块，我推测`PyQt5.Qt`导入了很多常用类，应该是为了方便程序员一次导入。

此时，可以试试这些命令：

- `dir(QApplication)` 列出`QApplication`这个类的数据成员和方法成员
- `help(QApplication)` 显示`QApplication`这个类的帮助文档。d(Down)下滚，u(Up)上滚，q(Quit)退出。不过这个文档并不详细，详细文档得查询Qt官方文档

### 2.5 实例化QApplication

`QApplication`是一个类，但是也可以作为函数(`QApplication()`)运行。当类名用作函数的时候，这个函数叫做构造函数，这个函数必须返回这个类的一个对象。

输入`app = QApplication()`，显示如下报错信息。

```python
>>> app = QApplication()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: QApplication(List[str]): not enough arguments

QApplication(List[str]): not enough arguments
```

报错信息告诉我们，这个函数调用没有传递足够的参数。函数的签名（格式）是`QApplication(List[str])`，意思是函数参数应该是一个字符串列表。这个参数是用来设置Qt的运行环境的，比如切换显示主题（`QApplication([None, '-style=macintosh'])`可以切换苹果主题）。我们目前不需要处理，所以传递一个空列表即可。

输入`app = QApplication([])`，显示如下信息：

```python
>>> app = QApplication([])
WARNING: QApplication was not created in the main() thread.
```

这里显示了一条报警信息，这条信息之所以出现，是因为我们当前代码的运行环境是`PTPython`交互式环境。先无视。

输入`app`，显示如下信息：

```python
>>> app
<PyQt5.QtWidgets.QApplication object at 0x10c912948>
```

可见，`app`是`QApplication`类的一个对象(object)

### 2.6 换用IPython

输入`app.exec()`，运行这个Qt应用，结果`PTPython`交互环境直接崩溃：

```python
>>> app.exec()
[1]    17039 segmentation fault  ptpython
```

这是因为Qt应用必须在主线程（线程是用来让代码并行执行的一种东西）运行，而`PTPython`把我们的代码运行在了其他线程。而`BPython`和`IPython`都没这个问题。`IPython`虽然需要按`Tab`键补全代码，但是补全效果好，所以我们换用`IPython`。

```python
 ~/ ipython
Python 3.7.2 (default, Feb 12 2019, 08:15:36)
Type 'copyright', 'credits' or 'license' for more information
IPython 7.3.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: from PyQt5.Qt import QApplication

In [2]: app = QApplication([])

In [3]: app.exec()
```

在`IPython`中调用`QApplication()`方法，没有打印(输出)报警信息，`app.exec()`也没有崩溃。但是现在，我们的控制台已经卡死不动了。不过这种情况正是我们想要的。如果`QApplication.exec`方法没有意外情况，而且用户不主动要求退出，就应该永远运行。

Qt应用运行起来了，但是我们看不到屏幕上多了任何窗体(类似于运行在后台的电脑病毒或木马)。这是因为我们还没有创建任何窗体。但是我们怎么关闭这个没有窗体的应用呢？主要有三种方法：

1. 直接关闭命令行窗口，会把运行在命令行的程序杀掉
2. 在Windows任务管理器窗口中找到`python.exe`，把它结束掉
3. 在命令行下执行命令`taskkill /F /IM python.exe`，用命令结束此Qt进程

### 2.7 显示一个空窗体

执行以下代码，会显示一个空窗体：

```python
 ~/ ipython
Python 3.7.2 (default, Feb 12 2019, 08:15:36)
Type 'copyright', 'credits' or 'license' for more information
IPython 7.3.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: from PyQt5.Qt import QApplication

In [2]: app = QApplication([])

In [3]: from PyQt5.Qt import QWidget

In [4]: wnd = QWidget()

In [5]: wnd.show()

In [6]: app.exec()
```

其中：

- 执行`QWidget`构造函数，会生成一个空窗体。
- 执行`QWidget.show`成员方法，会将这个窗体标记为显示状态。
- 执行`QApplication.exec`成员方法，会运行Qt应用，显示需要显示的窗体。

### 2.8 尝试多种图形控件

在常见的各种图形化应用程序中，除了空窗体，还需要按钮、文本框、下拉框等各种控件。

在交互式编程环境下，虽然可以一行一行运行代码，但是修改之前运行过的代码并不方便，所以我们接着使用`PyCharm`。

#### 2.8.1 初识文本标签

```python
from PyQt5.Qt import QApplication
from PyQt5.Qt import QLabel

app = QApplication([])
lbl = QLabel("白云千载空悠悠")
lbl.show()
app.exec()
```

以上代码会显示一个很小的窗体，窗体中有一个文本标签，标签内容是“白云千载空悠悠”。标签的大小正好跟文本大小一致，窗体的大小也正好跟标签的大小一致。这属于一种布局的自适应。

#### 2.8.2 空文本标签

```python
from PyQt5.Qt import QApplication
from PyQt5.Qt import QLabel

app = QApplication([])
lbl = QLabel()  # 跟 lbl = QLabel("")的最终效果一致
lbl.show()
app.exec()
```

以上代码会显示一个更小的窗体。因为文本是空的，窗体会小到几乎看不见。

### 2.8.3 使用大号字体

```python
from PyQt5.Qt import (
    QApplication,
    QLabel,
    QFont
)

app = QApplication([])
lbl = QLabel("白云千载空悠悠")
lbl.setFont(QFont(None, 72)
lbl.show()
app.exec()
```

`QLabel.setFont`成员方法可以用来设置标签的字体。`QFont`构造函数可以创建字体对象。当给`QFont`构造函数传递两个参数时，第一个参数是字体名称，第二个参数是字体大小。当字体名称为空，或是找不到时，Qt就会使用默认字体。我们只想修改字体大小，所以第一个参数可以传`None`。`None`在Python中表示空对象，在其他编程语言中，这个空对象可能表示为`null`或`nil`。

### 2.8.3 使用粗体

```python
from PyQt5.Qt import (
    QApplication,
    QLabel,
    QFont
)

app = QApplication([])
lbl = QLabel("白云千载空悠悠")
lbl.setFont(QFont(None, 72, QFont.Bold))
lbl.show()
app.exec()
```

当给`QFont`构造函数传递三个参数时，第三个参数表示字体风格。这个参数是Qt预定义的几个常量(不变的量)，比如这个`QFont.Bold`，其实是75。直接用75也能工作，但是难以记忆与阅读。

### 2.8.4 改变标签文本的颜色

```python
from PyQt5.Qt import (
    QApplication,
    QLabel,
    QFont,
    QPalette,
    QColor
)

app = QApplication([])
plt = QPalette()
plt.setColor(QPalette.WindowText, QColor("magenta"))
lbl = QLabel("白云千载空悠悠")
lbl.setFont(QFont(None, 72, QFont.Bold))
lbl.setPalette(plt)
lbl.show()
app.exec()
```

以上代码会将标签文本显示成洋红色。`QLabel.setColor`方法不存在，要想给`QLabel`对象设置颜色，需要通过一个调色板对象。把需要的颜色传递给这个调色板，再把这个调色板传递给`QLabel`对象。

`QColor(0xFF0000)`这种写法可以根据红绿蓝三原色自由配色。此时，参数传递的不是颜色名称字符串，而是一个数字。表示颜色用16进制数字比较方便，`0x`开头的数字是16进制数字。三原色中的每一个的范围都是`00`到`FF`，可以自由搭配。`0xFF0000`就表示纯红色。

### 2.8.5 改变窗体大小

在`Qt`中，每个图形控件都是一个抽象的窗体。当这个图形控件作为根控件时，就会自动加上与操作系统相匹配的边框、标题栏和按钮组(最大化、隐藏、关闭等)。所以，我们可以直接将文本标签作为一个根控件(根窗体)。

```python
from PyQt5.Qt import (
    QApplication,
    QLabel,
    QFont,
    QPalette,
    QColor
)

app = QApplication([])
plt = QPalette()
plt.setColor(QPalette.WindowText, QColor("magenta"))
lbl = QLabel("白云千载空悠悠")
lbl.resize(600, 600 * 0.618)
lbl.setFont(QFont(None, 72, QFont.Bold))
lbl.setPalette(plt)
lbl.show()
app.exec()
```

以上的代码会将窗体的宽度设置为600像素，高度设置为370像素。此处，`0.618`是一个黄金分割数。据说，长宽比`0.618`比较养眼。

### 2.8.6 标签文本水平居中

```python
from PyQt5.QtCore import Qt
from PyQt5.Qt import (
    QApplication,
    QLabel,
    QFont,
    QPalette,
    QColor,
)

app = QApplication([])
plt = QPalette()
plt.setColor(QPalette.WindowText, QColor(Qt.magenta))
lbl = QLabel("白云千载空悠悠")
lbl.resize(600, 600 * 0.618)
lbl.setFont(QFont(None, 72, QFont.Bold))
lbl.setPalette(plt)
lbl.setAlignment(Qt.AlignCenter)
lbl.show()
app.exec()
```

`QLabel.setAlignment`可以设置对齐策略，对齐策略是个枚举常量，定义在`PyQt5.QtCore`模块下的`Qt`类中。同时，我们发现`Qt`类中也有常用的颜色常量，用颜色常量`Qt.magenta`可以避免拼写错误。

### 2.8.7 将标签替换为按钮

文本标签默认情况下，不响应用户的点击事件。为了让我们的应用可以跟用户交互，我们将文本标签替换为按钮。

```python
from PyQt5.QtCore import Qt
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
    QPalette,
    QColor,
)

app = QApplication([])
btn = QPushButton("白云千载空悠悠")
btn.resize(600, 600 * 0.618)
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("color: magenta")
# plt = QPalette()
# plt.setColor(QPalette.WindowText, QColor(Qt.magenta))
# btn.setPalette(plt) # 调色板对按钮不起作用
# btn.setAlignment(Qt.AlignCenter)  # 按钮默认居中，不支持自定义对齐策略
btn.show()
app.exec()
```

运行此程序，会发现原来的标签被替换成了一个大大的按钮。注意，`QPushButton`和`QLabel`支持的方法不太一样，比如，`setAlignment`方法在`QPushButton`中不存在，但是`QPushButton`是默认居中对齐的，我们可以不用处理。`setPalette`方法无效，改变不了按钮的颜色。我们可以换用`QPushButton.setStyleSheet`方法来设置按钮文本颜色。这个方法的参数是一个字符串，设置颜色的语法类似于网页设计中用到的`CSS`。

### 2.8.8 响应按钮的点击事件

上个程序虽然显示了一个按钮，但是点击这个按钮后，除了点击动画，什么事都没有发生。这是因为我们没有告诉程序，用户点击按钮后，程序应该干什么。

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
)

app = QApplication([])
btn = QPushButton("白云千载空悠悠")
btn.resize(600, 600 * 0.618)
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("color: magenta")
btn.clicked.connect(QApplication.exit)
btn.show()
app.exec()
```

执行以上程序，点击按钮，会发现窗口被关闭，应用被退出。这是因为我们处理了按钮的点击事件，处理的逻辑是退出程序。Qt的事件处理，按官方的说法，是一种`信号-槽`机制。信号是事件对象，比如单击、双击、键盘按键，槽是函数，是程序逻辑，用于接收与处理信号。

在这个程序中，信号对象是`QPushButton.clicked`，槽函数是`QApplication.exit`。信号对象通过调用`connect`方法连接到槽函数。这样，当用户点击按钮后，Qt系统感应到用户的操作，会生成一个点击事件对象，分发给用户点击的控件，即这个按钮。这个按钮把用户点击事件传递给绑定到的槽函数`QApplication.exit`，槽函数被执行，程序被退出（程序窗口也被关闭）。

### 2.8.9 匿名函数Lambda

槽函数可以是系统的函数、第三方模块的函数，也可以用户自定义的函数。函数可以是有名字的函数，也可以是匿名函数。有名字的函数一般通过`def`关键字定义，没名字的函数一般通过`lambda`关键字定义。

下面这个例子，演示了匿名函数的使用：

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
)

app = QApplication([])
btn = QPushButton("白云千载空悠悠")
btn.resize(600, 600 * 0.618)
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("color: magenta")
btn.clicked.connect(lambda: QApplication.exit())
btn.show()
app.exec()
```

匿名函数通过语法`lambda ... : ...`定义，冒号左边是函数入参（输入参数），冒号右边是函数出参（函数输出，也可执行程序逻辑）。在上面的例子中，我们定义的匿名函数不关心入参，所以置空。匿名函数的逻辑是退出应用，我们直接调用`QApplication.exit()`即可。

### 2.8.10 对话框

对话框，是人机交互最常见的表现形式之一。

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
)

app = QApplication([])
btn = QPushButton("白云千载空悠悠")
btn.resize(600, 600 * 0.618)
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setStyleSheet("color: magenta")
btn.clicked.connect(QApplication.aboutQt)
btn.show()
app.exec()
```

执行以上代码，点击按钮，会弹出一个`About Qt`对话框。这是`Qt`内置的一个对话框。我们发现这个对话框的文字也是洋红色的，这是因为`btn`上的样式设置被传递到了它的子对话框上。为了让`btn`的样式不影响它的子控件，我们需要对样式的影响范围做限定。

### 2.8.11 样式表

```python
from PyQt5.Qt import (
    QApplication,
    QPushButton,
    QFont,
)

app = QApplication([])
btn = QPushButton("白云千载空悠悠")
btn.resize(600, 600 * 0.618)
btn.setFont(QFont(None, 72, QFont.Bold))
btn.setObjectName("MyButton")
btn.setStyleSheet("#MyButton { color: magenta }")
btn.clicked.connect(QApplication.aboutQt)
btn.show()
app.exec()
```

执行以上代码，点击按钮，新弹出的对话框的文本颜色变成了黑色。Qt默认情况下会自动传递样式给子控件，而且没有提供直接阻止这种行为的方法。所以，我们必须在样式表语法中进行限定。样式表`#MyButton { color: magenta }` 限定了这个样式的作用范围是名字为`MyButton`的对象。所以，我们需要给我们的按钮起名为`MyButton`。这个名字是这个按钮在`Qt`系统中的名字，不是在`Python`系统中的名字。`Qt`是用`C++`语言写的框架，`Qt`不懂我们的`Python`代码。所以，我们需要调用`QPushButton.setObjectName`来给按钮取一个`Qt`能识别的名字。

文章首发: [https://baijifeilong.github.io](https://baijifeilong.github.io)
