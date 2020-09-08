#include once "kogaion_gui_comctrls.bi"

/' QCustomToolBar '/
sub QCustomToolBar.Click
    if onClick then onClick(this)
end sub

function QCustomToolBar.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QCustomToolBar
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomToolBar.CreateHandle
    Base.CreateHandle
    if IsWindow(fHandle) then  SendMessage(fHandle,tb_buttonstructsize,sizeof(tbbutton),0)
end sub

sub QCustomToolBar.Dispatch(byref m as QMessage)
    Base.Dispatch(m) '''not forgot to inherite from base class
    select case m.msg
    case wm_lbuttondown
         click
         m.result=0
    end select
end sub

operator QCustomToolBar.cast as any ptr
    return @this
end operator

constructor QCustomToolBar
    classname="QToolBar"
    classancestor="ToolBarWindow32"
end constructor

/' QToolBar '/
function QToolBar.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"ToolBarWindow32",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QToolBar"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomToolBar.dlgproc
       wc.cbwndextra +=4
    end if
    return RegisterClassEx(@wc)
end function

operator QToolBar.cast as any ptr
    return @this
end operator

operator QToolBar.cast as hwnd
    return fHandle
end operator

constructor QToolBar
    fexstyle=ws_ex_controlparent
    fcx=215
    fcy=21
    fStyle=ws_child or ccs_noparentalign or ccs_noresize
end constructor

/' QCustomStatusBar '/
sub QCustomStatusBar.Click
    if onClick then onClick(this)
end sub

function QCustomStatusBar.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QCustomStatusBar
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomStatusBar.CreateHandle
    Base.CreateHandle
    if IsWindow(fHandle) then  SendMessage(fHandle,tb_buttonstructsize,sizeof(tbbutton),0)
end sub

sub QCustomStatusBar.Dispatch(byref m as QMessage)
    Base.Dispatch(m) '''not forgot to inherite from base class
    select case m.msg
    case wm_lbuttondown
         click
         m.result=0
    end select
end sub

operator QCustomStatusBar.cast as any ptr
    return @this
end operator

constructor QCustomStatusBar
    classname="QStatusBar"
    classancestor="msctls_StatusBar32"
end constructor

/' QStatusBar '/
function QStatusBar.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"msctls_StatusBar32",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QStatusBar"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomStatusBar.dlgproc
       wc.cbwndextra +=4
    end if
    return RegisterClassEx(@wc)
end function

operator QStatusBar.cast as any ptr
    return @this
end operator

operator QStatusBar.cast as hwnd
    return fHandle
end operator

constructor QStatusBar
    fexstyle=ws_ex_controlparent
    fcx=215
    fcy=17
    fStyle=ws_child or sbars_sizegrip or ccs_noparentalign or ccs_noresize
end constructor

''module initialization
sub ComCtrls_initialization constructor
    InitCommonControls
    QToolBar.Register
    QStatusBar.Register
end sub

sub ComCtrls_finalization destructor
    unRegisterClass("QToolBar",instance)
end sub