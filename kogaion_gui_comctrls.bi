'kogaion_gui_additional.bi -library windows controls wrapper
'this file is part of Koganion(RqWork7) rad-ide
'and can't be redistributed without permission
'Copyright (c)2020 Vasile Eodor Nastasa
'mail: nastasa.eodor@gmail.com
'web:http://www.rqwork.de

#include once "kogaion_gui.bi"
#include once "kogaion_gui_classes.bi"

''register classes to ide
#Define ComCtrls_RegisterClasses "QToolBar,QStatusBar"

#Define Q_CustomToolBar(__ptr__) *cast(QCustomToolBar ptr, @__ptr__)
#Define W_CustomToolBar(__hwnd__) *cast(QCustomToolBar ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_ToolBar(__ptr__) *cast(QToolBar ptr, @__ptr__)
#Define W_ToolBar(__hwnd__) *cast(QToolBar ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))

#Define Q_CustomStatusBar(__ptr__) *cast(QCustomStatusBar ptr, @__ptr__)
#Define W_CustomStatusBar(__hwnd__) *cast(QCustomStatusBar ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_StatusBar(__ptr__) *cast(QStatusBar ptr, @__ptr__)
#Define W_StatusBar(__hwnd__) *cast(QStatusBar ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))

/' QToolBar '/
type QCustomToolBar extends QFrame
    protected:
        declare sub Click
        declare virtual sub CreateHandle
        declare virtual sub Dispatch(byref m as QMessage) 
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public:
        as QCanvas Canvas  
        declare virtual operator cast as any ptr
    declare constructor
end type

type QToolBar extends QCustomToolBar
    declare static function Register as integer
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type

/' QStatusBar '/
type QCustomStatusBar extends QFrame
    protected:
        declare sub Click
        declare virtual sub CreateHandle
        declare virtual sub Dispatch(byref m as QMessage) 
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public:
        as QCanvas Canvas  
        declare virtual operator cast as any ptr
    declare constructor
end type

type QStatusBar extends QCustomStatusBar
    declare static function Register as integer
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type
