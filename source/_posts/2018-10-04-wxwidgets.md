---
title: wxWidgets大杂烩
categories:
  - Programming
  - CPP
tags:
  - Programming
  - CPP
date: 2018-10-04 01:48:07
---

wxWidgets的CMake文件不识别MinGW，不能直接使用MinGW里装好的wxWidgets，强行更改CMake文件也不行。wxWidgets也不提供Windows下的gcc动态链接库，只能手动编译。

编译步骤：

1. 下载源码，解压
2. cd到`wxWidgets/build/msw`目录
3. Clean `mingw32-make -f makefile.gcc SHARED=1 UNICODE=1 BUILD=release clean`
4. 编译 `mingw32-make -f makefile.gcc -j 8 SHARED=1 UNICODE=1 BUILD=release`，其中`-j 8`表示八核并行编译。i7-4710MQ大概需要5分钟。


**CMakeLists.txt**
```cmake
cmake_minimum_required(VERSION 3.8)
project(hellocpp)

set(CMAKE_CXX_STANDARD 98)

set(wxWidgets_ROOT_DIR D:/app/wxWidgets-3.1.0)
find_package(wxWidgets REQUIRED net gl core base)
include(${wxWidgets_USE_FILE})

set(SOURCE_FILES main.cpp main.c.c)
add_executable(hellocpp ${SOURCE_FILES})
target_link_libraries(hellocpp ${wxWidgets_LIBRARIES})
```

**main.cpp**
```cpp
#include <wx/wx.h>

class MyApp : public wxApp {
public:
    virtual bool OnInit();
};

class MyFrame : public wxFrame {
public:
    MyFrame(const wxString &title, const wxPoint &pos, const wxSize &size);

private:
    void OnHello(wxCommandEvent &event);

    void OnExit(wxCommandEvent &event);

    void OnAbout(wxCommandEvent &event);

wxDECLARE_EVENT_TABLE();
};

enum {
    ID_Hello = 1
};
wxBEGIN_EVENT_TABLE(MyFrame, wxFrame)
                EVT_MENU(ID_Hello, MyFrame::OnHello)
                EVT_MENU(wxID_EXIT, MyFrame::OnExit)
                EVT_MENU(wxID_ABOUT, MyFrame::OnAbout)
wxEND_EVENT_TABLE()
wxIMPLEMENT_APP(MyApp);

bool MyApp::OnInit() {
    MyFrame *frame = new MyFrame("Hello World", wxPoint(50, 50), wxSize(450, 340));
    frame->Show(true);
    return true;
}

MyFrame::MyFrame(const wxString &title, const wxPoint &pos, const wxSize &size)
        : wxFrame(NULL, wxID_ANY, title, pos, size) {
    wxMenu *menuFile = new wxMenu;
    menuFile->Append(ID_Hello, "&Hello...\tCtrl-H",
                     "Help string shown in status bar for this menu item");
    menuFile->AppendSeparator();
    menuFile->Append(wxID_EXIT);
    wxMenu *menuHelp = new wxMenu;
    menuHelp->Append(wxID_ABOUT);
    wxMenuBar *menuBar = new wxMenuBar;
    menuBar->Append(menuFile, "&File");
    menuBar->Append(menuHelp, "&Help");
    SetMenuBar(menuBar);
    CreateStatusBar();
    SetStatusText("Welcome to wxWidgets!");
}

void MyFrame::OnExit(wxCommandEvent &event) {
    Close(true);
}

void MyFrame::OnAbout(wxCommandEvent &event) {
    wxMessageBox("This is a wxWidgets' Hello world sample",
                 "About Hello World", wxOK | wxICON_INFORMATION);
}

void MyFrame::OnHello(wxCommandEvent &event) {
    wxLogMessage("Hello world from wxWidgets!");
}
```

**注意事项**
- wx可以动态绑定事件，不需要EventTable
- wx能用wxDialog就不要用wxFrame
- wxFormBuilder可以生成xrc布局文件
- wx在Windows7上默认不是Win7主题，需要编译一个`#include "wx/msw/wx.rc"`资源文件，链接到程序中。编译命令:`windres resource.rc resource.o`，注意include的搜索位置


## 使用布局文件

**dlg.xrc**
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<resource xmlns="http://www.wxwindows.org/wxxrc" version="2.3.0.1">
    <object class="wxDialog" name="MyDialog1">
        <style>wxDEFAULT_DIALOG_STYLE</style>
        <size>527,415</size>
        <title>Hello wxFormBuilder</title>
        <centered>1</centered>
        <object class="wxBoxSizer">
            <orient>wxVERTICAL</orient>
            <object class="sizeritem">
                <option>0</option>
                <flag>wxALL</flag>
                <border>5</border>
                <object class="wxButton" name="m_button1">
                    <label>MyButton</label>
                    <default>0</default>
                </object>
            </object>
            <object class="sizeritem">
                <option>0</option>
                <flag>wxALL</flag>
                <border>5</border>
                <object class="wxButton" name="m_button2">
                    <label>MyButton</label>
                    <default>0</default>
                </object>
            </object>
            <object class="sizeritem">
                <option>0</option>
                <flag>wxALL</flag>
                <border>5</border>
                <object class="wxButton" name="m_button3">
                    <label>MyButton</label>
                    <default>0</default>
                </object>
            </object>
        </object>
    </object>
</resource>
```

**main.cpp**
```cpp
#include <wx/wx.h>
#include <wx/xrc/xmlres.h>

class MyDialog : public wxDialog {
public:
    void EndModal(int retCode) override {
        wxDialog::EndModal(retCode);
        Destroy();
    }
};

class MyApp : public wxApp {
public:
    bool OnInit() override {
        auto *dlg = new MyDialog;
        wxXmlResource::Get()->InitAllHandlers();
        wxXmlResource::Get()->LoadAllFiles(".");
        wxXmlResource::Get()->LoadDialog(dlg, nullptr, "MyDialog1");
        dlg->ShowModal();
        return true;
    }
};

DECLARE_APP(MyApp);
IMPLEMENT_APP(MyApp); // NOLINT
```
