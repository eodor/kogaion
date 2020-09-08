#include once "kogaion_gui_standards.bi"

Const EM_GETSELTEXT = &H43E

/' QGadget '/
function QGadget.DlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QGadget(CreationParams)
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QGadget.Dispatch(byref m as QMessage)
    Base.Dispatch(m)
    select case m.msg
    case cm_ctlcolor
         dim as wndclassex wcls
         wcls.cbsize=sizeof(wcls)
         if GetClassInfoEx(0,classancestor,@wcls) or GetClassInfoEx(instance,classancestor,@wcls) then
            SetBKMode(cast(hdc,m.wparam),transparent)
            SetBKColor(cast(hdc,m.wparam),canvas.color)
            SetTextColor(cast(hdc,m.wparam),canvas.textcolor)
            SetBKMode(cast(hdc,m.wparam),opaque)
            m.result=cint(canvas.brush)
            exit sub
         end if
         m.result=0
    case wm_erasebkgnd
         dim as wndclassex wcls
         wcls.cbsize=sizeof(wcls)
         if not GetClassInfoEx(0,classancestor,@wcls) and not GetClassInfoEx(instance,classancestor,@wcls) then
            GetClientRect(m.dlg,@fclientrect)
            FillRect(cast(hdc,m.wparam),@fclientrect,canvas.brush)
            m.result=cint(canvas.brush)
            exit sub
         end if
         m.result=0
    end select
end sub

function QGadget.WindowProc as wndproc
    return @QGadget.dlgproc
end function

constructor QGadget(cp as PCreationParams=0)
    if Cp then
       ClassName=cp->ClassName
       ClassAncestor=cp->ClassAncestor
       this.registerproc(cp->proc)
       fStyle=cp->Style
       fExStyle=cp->ExStyle
       fcx=cp->cx
       fcy=cp->cy
    end if
    Canvas.Frame=@this
    Canvas.Color=GetSysColor(color_btnface)
    Canvas.TextColor=0
end constructor

operator QGadget.cast as any ptr
    return @this
end operator

' QForm '/
constructor QForm
    classname="QForm"
    fcx=350
    fcy=250
    fstyle=ws_overlappedwindow
    Canvas.Frame=this
    Canvas.Color=GetSysColor(color_btnface)
end constructor

function QForm.Register as integer
    dim as wndclassex wcls
    wcls.cbsize=sizeof(wcls)
    wcls.hinstance=instance
    wcls.hcursor=LoadCursor(0,idc_arrow)
    wcls.cbwndextra+=4
    wcls.lpfnwndproc=@QCustomForm.dlgproc
    wcls.lpszclassname=@"QForm"
    return RegisterClassEx(@wcls)
end function

sub QForm.CreateHandle
    Base.CreateHandle
    dim as hmenu MainMenu=LoadMenu(instance,"MainMenu")  
    SetMenu(fHandle,MainMenu)
    DrawMenuBar(fHandle)
end sub

operator QForm.cast as any ptr
    return @this
end operator

function QCustomLabel.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QLabel
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomLabel.Dispatch(byref m as QMessage)
    Base.Dispatch(m) '''not forgot to inherite from base class
    select case m.msg
    case cm_ctlcolor
        SetBKMode(cast(hdc,m.wparam),transparent)
        SetBKColor(cast(hdc,m.wparam),Canvas.color)
        SetTextColor(cast(hdc,m.wparam),Canvas.textcolor)
        SetBKMode(cast(hdc,m.wparam),opaque)
        m.result=cint(Canvas.brush)
        exit sub
    case cm_command
        if m.wparam=stn_clicked then
           if onClick then onClick(this)
        end if
    end select
end sub

operator QCustomLabel.cast as any ptr
    return @this
end operator

constructor QCustomLabel
    classancestor="static"
end constructor

/' QLabel '/
function QLabel.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"Static",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QLabel"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomLabel.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function'

operator QLabel.cast as any ptr
    return @this
end operator

operator QLabel.cast as hwnd
    return fHandle
end operator

constructor QLabel
    classname="QLabel"
    fstyle=ws_child or ss_notify
    fcx=115
    fcy=18
    Canvas.Color=clWindow
    Canvas.TextColor=0
end constructor

/' QCustomButton '/
function QCustomButton.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QButton
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           'Q_CustomButton(obj).Handle=dlg
           'Q_CustomButton(obj).fParentWindow=GetParent(dlg)
           'Q_CustomButton(obj).fExStyle=GetWindowLong(dlg,gwl_exstyle)
           'Q_CustomButton(obj).fStyle=GetWindowLong(dlg,gwl_style)
           'GetWindowRect(dlg,@Q_CustomButton(obj).fWindowRect)
           'MapWindowPoints(0,Q_CustomButton(obj).fParentWindow,cast(point ptr,@Q_CustomButton(obj).fWindowRect),2)
           'Q_CustomButton(obj).fx=Q_CustomButton(obj).fWindowRect.left
           'Q_CustomButton(obj).fy=Q_CustomButton(obj).fWindowRect.top
           'Q_CustomButton(obj).fcx=Q_CustomButton(obj).fWindowRect.right-Q_CustomButton(obj).fWindowRect.left
           'Q_CustomButton(obj).fcy=Q_CustomButton(obj).fWindowRect.bottom-Q_CustomButton(obj).fWindowRect.top
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomButton.Dispatch(byref m as QMessage)
    Base.Dispatch(m) '''not forgot to inherite from base class
    select case m.msg
    case wm_create
         print classname
         m.result=0
    case cm_ctlcolor
        SetBKMode(cast(hdc,m.wparam),transparent)
        SetBKColor(cast(hdc,m.wparam),Canvas.color)
        SetTextColor(cast(hdc,m.wparam),Canvas.textcolor)
        SetBKMode(cast(hdc,m.wparam),opaque)
        m.result=cint(Canvas.brush)
        exit sub
    case cm_command
        if m.wparam=bn_clicked then
           if onClick then onClick(this)
        end if
    end select
end sub

operator QCustomButton.cast as any ptr
    return @this
end operator

constructor QCustomButton
    classancestor="button"
end constructor

/' QButton '/
function QButton.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"Button",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QButton"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomButton.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function'

operator QButton.cast as any ptr
    return @this
end operator

operator QButton.cast as hwnd
    return fHandle
end operator

constructor QButton
    classname="QButton"
    fcx=75
    fcy=35
    fstyle=ws_child
    Canvas.TextColor=0
end constructor

/' QCheckBox '/
function QRadioButton.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"Button",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QRadioButton"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomButton.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function

operator QRadioButton.cast as any ptr
    return @this
end operator

operator QRadioButton.cast as hwnd
    return fHandle
end operator

constructor QRadioButton
    classname="QRadioButton"
    fStyle=ws_child or bs_autoradiobutton
    Canvas.TextColor=0
    fcx=97
    fcy=19
end constructor

/' QRadioButton '/
function QCheckBox.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"Button",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QCheckBox"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomButton.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function'

operator QCheckBox.cast as any ptr
    return @this
end operator

operator QCheckBox.cast as hwnd
    return fHandle
end operator

constructor QCheckBox
    classname="QCheckBox"
    fStyle=ws_child or bs_autocheckbox
    Canvas.TextColor=0
    fcx=97
    fcy=19
end constructor

/' QGroupBox '/
function QGroupBox.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"Button",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QGroupBox"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomButton.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function

operator QGroupBox.cast as any ptr
    return @this
end operator

operator QGroupBox.cast as hwnd
    return fHandle
end operator

constructor QGroupBox
    classname="QGroupBox"
    fStyle=ws_child or bs_groupbox
    fexstyle=ws_ex_transparent
    Canvas.TextColor=0
    fcx=221
    fcy=51
end constructor

/' QCustomEdit '/
function QCustomEdit.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QEdit
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomEdit.Dispatch(byref message as QMessage)
    Base.Dispatch(message)
    select case message.msg
    case cm_ctlcolor
        SetBKMode(cast(hdc,message.wparam),transparent)
        SetBKColor(cast(hdc,message.wparam),canvas.color)
        SetTextColor(cast(hdc,message.wparam),Canvas.textcolor)
        SetBKMode(cast(hdc,message.wparam),opaque)
        message.result=cint(Canvas.brush)
        exit sub
    end select
end sub

operator QCustomEdit.cast as any ptr
    return @this
end operator

constructor QCustomEdit
    classancestor="edit"
    classname="QEdit"
end constructor

/' QEdit '/
function QEdit.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"Edit",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QEdit"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomEdit.dlgproc
       wc.cbwndextra +=4
    end if
    return RegisterClassEx(@wc)
end function

property QEdit.SelText as string
    if isWindow(fHandle) then
       dim as integer i=0
       SendMessage(fHandle,wm_gettext,0,cint(@ftext))
       SendMessage(fHandle,em_getsel,cint(@fSelStart),cint(@i))
       fSelLength=i-fSelStart
       fSelText=mid(fText,instr(ftext,fseltext),fSelLength)
    end if
    return fSelText   
end property

property QEdit.SelText(v as string)
    fSelText=v
    fSelStart=instr(lcase(v),lcase(ftext))
    fSelLength=fSelStart+len(v)
    if isWindow(fHandle) then
      SendMessage(fHandle,em_setsel,fSelStart,cint(@fSelLength))
    end if
end property

property QEdit.SelStart as integer
    dim as integer i=0
    if isWindow(fHandle) then
       fSelStart=SendMessage(fHandle,em_getsel,cint(@fSelStart),cint(@i)) 
       fSelLength=i-fSelStart
    end if
    return fSelStart  
end property

property QEdit.SelStart(v as integer)
    fSelStart=v
    if isWindow(fHandle) then
       SendMessage(fHandle,em_setsel,fSelStart,fSelStart+fSelLength)
    end if
end property

property QEdit.SelLength as integer
    dim as integer i=0
    if isWindow(fHandle) then
       fSelStart=SendMessage(fHandle,em_getsel,cint(@fSelStart),cint(@i)) 
       fSelLength=i-fSelStart
    end if
    return fSelLength 
end property

property QEdit.SelLength(v as integer)
    fSelLength=v
    if isWindow(fHandle) then
       SendMessage(fHandle,em_setsel,fSelStart,fSelStart+fSelLength)
    end if 
end property

operator QEdit.cast as any ptr
    return @this
end operator

operator QEdit.cast as hwnd
    return fHandle
end operator

constructor QEdit
    fcx=121
    fcy=21
    fstyle=ws_child or es_autohscroll
    fExStyle=ws_ex_clientedge
    Canvas.Frame=this
    Canvas.color=clWindow
    Canvas.TextColor=0
end constructor

/' QMemo '/
function QMemo.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"Edit",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QMemo"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomEdit.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function

Property QMemo.Lines(Index as integer) as string
    if Handle then
        dim as integer L = SendMessage(Handle,em_linelength,0,0)
        dim as string s = Space(L)
        SendMessage(Handle,em_getline,Index,cint(strptr(s)))
        return s
    end if
    return ""
end Property

Property QMemo.Lines(Index as integer,value as string)
    if Handle then
    end if
end Property

Property QMemo.Count as Integer
    if Handle then
        return SendMessage(Handle,em_getlinecount,0,0)
    end if
    return 0
end Property

Property QMemo.Count(value as Integer)
end Property

Property QMemo.CaretPos as Point
    if Handle then
       dim as integer x,y 
       x = hiword(SendMessage(Handle,EM_GETSEL,0,0))
       y = SendMessage(Handle,EM_LINEFROMCHAR,x,0)
       x = x - SendMessage(Handle,EM_LINEINDEX,-1,0)
       return Type(x,y)
    end if
    return Type(0,0)
end Property

Property QMemo.CaretPos(value as Point)
end Property

Property QMemo.SelText as string
    if Handle then
        dim as string Buff = Space(SelLength)
        SendMessage(Handle,EM_GETSELTEXT,0,cint(strptr(Buff)))
    end if
    return ""
end Property

Property QMemo.SelText(value as string)
    if Handle then
       SendMessage(Handle,EM_REPLACESEL,0,cint(strptr(value)))
    end if
end Property

Property QMemo.SelStart as integer
    if Handle then
       dim as integer Result
       SendMessage(Handle,EM_GETSEL,cint(@Result),0)
       return result
    end if   
    return 0
end Property

Property QMemo.SelStart(value as integer)
    if Handle then
       SendMessage(Handle,EM_SETSEL,value,value)
    end if
end Property

Property QMemo.SelLength as integer
    if Handle then
       dim as Point Selection
       SendMessage(Handle,EM_GETSEL,cint(@Selection.x),cint(@Selection.y))
       return Selection.y - Selection.x
    end if
    return 0
end Property

Property QMemo.SelLength(value as integer)
    if Handle then
       dim as Point Selection 
       SendMessage(Handle,EM_GETSEL,cint(@Selection.x),cint(@Selection.y))
       Selection.y = Selection.x + value
       SendMessage(Handle,EM_SETSEL,Selection.x,Selection.y)
       SendMessage(Handle,EM_SCROLLCARET,0,0)
    end if
end Property

Property QMemo.ScrollBars as integer
    return FScrollBars
end Property

Property QMemo.ScrollBars(value as integer)
    FScrollBars = value
    select case FScrollBars
    case 0
        Style = Style and not (ws_hscroll or ws_vscroll)
    case 1
        Style = (Style and not ws_hscroll) or ws_vscroll
    case 2
        Style = (Style and not ws_vscroll) or ws_hscroll
    case 3
        Style = Style or (ws_hscroll or ws_vscroll)
    end select
end Property

Property QMemo.WordWraps as Integer
    return FWordWraps
end Property

Property QMemo.WordWraps(value as Integer)
    FWordWraps = value
    if value then
       Style = Style and not es_autohscroll 
    else
       Style = Style or es_autohscroll
    end if
end Property

Sub QMemo.AddLine(v as string="",o as any ptr=0)
    InsertLine(this.Count-1,v)
end Sub

Sub QMemo.InsertLine(i as integer,v as string="",o as any ptr=0)
    dim as integer iStart, LineLen
    dim as string sLine
    if i >= 0 then
       iStart = SendMessage(Handle,EM_LINEINDEX,i,0)
       if iStart >= 0 then 
          sLine = v + Chr(13) & Chr(10) 
       else
          iStart = SendMessage(Handle,EM_LINEINDEX,i - 1,0)
          if iStart < 0 then Exit Sub
          LineLen = SendMessage(Handle,EM_LINELENGTH,SelStart,0)
          if LineLen = 0 then Exit Sub
          iStart += LineLen
          sLine = Chr(13) & Chr(10) + v
       end if
       SendMessage(Handle,EM_SETSEL,iStart,iStart)
       SendMessage(Handle,EM_REPLACESEL,0,cint(strptr(sLine)))
    end if
end Sub

Sub QMemo.RemoveLine(i as integer)
    const Empty = ""
    dim as integer iStart,iEnd
    iStart = SendMessage(Handle,EM_LINEINDEX,i, 0)
    if iStart >= 0 then
       iEnd = SendMessage(Handle,EM_LINEINDEX,i + 1,0)
       if iEnd < 0 then iEnd = iStart + SendMessage(Handle,EM_LINELENGTH,iStart,0)
       SendMessage(Handle,EM_SETSEL,iStart,iEnd)
       SendMessage(Handle,EM_REPLACESEL,0,cint(strptr(Empty)))
    end if
end Sub

sub QMemo.RemoveLine(v as string)
end sub

Sub QMemo.Clear
    if Handle then
        SetWindowText(Handle,"")
    end if
end Sub

Sub QMemo.LoadFromFile(File as string)
    if open(File for binary access read as #1) = 0 then
        dim as string s = Space(Lof(1)+1)
        get #1,,s
        SetWindowText(Handle,s)
    end if
    Close #1
end Sub

Sub QMemo.SaveToFile(File as string)
    if open(File for binary access write as #1) = 0 then
        dim as string s = Space(GetWindowTextLength(Handle)+1)
        GetWindowText(Handle,s,Len(s))
        put #1,,s
    end if
    Close #1
end Sub

operator QMemo.cast as any ptr
    return @this
end operator

operator QMemo.cast as hwnd
    return fHandle
end operator

constructor QMemo
    classname="QMemo"
    fStyle=ws_child or es_autovscroll or es_multiline or es_wantreturn 
    fcx=221
    fcy=121
    Canvas.Frame=this
    canvas.Color=clWindow
    canvas.TextColor=0
end constructor

/' QCustomComboBox '/
function QCustomComboBox.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QComboBox
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomComboBox.Dispatch(byref m as QMessage)
    Base.Dispatch(m) '''not forgot to inherite from base class
    select case m.msg
    case cm_ctlcolor
        SetBKMode(cast(hdc,m.wparam),transparent)
        SetBKColor(cast(hdc,m.wparam),Canvas.color)
        SetTextColor(cast(hdc,m.wparam),Canvas.textcolor)
        SetBKMode(cast(hdc,m.wparam),opaque)
        m.result=cint(Canvas.brush)
        exit sub
    case cm_command
    end select
end sub

operator QCustomComboBox.cast as any ptr
    return @this
end operator

constructor QCustomComboBox
    classancestor="ComboBox"
    classname="QComboBox" 
    Canvas.TextColor=0
    Canvas.Color=clWindow
end constructor

/' QCaomboBox '/
function QComboBox.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"ComboBox",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QComboBox"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomComboBox.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function

operator QComboBox.cast as any ptr
    return @this
end operator

operator QComboBox.cast as hwnd
    return fHandle
end operator

constructor QComboBox
    fcx=115
    fcy=18
    fstyle=ws_child or cbs_hasstrings or cbs_nointegralheight or cbs_dropdown
end constructor

/' QCustomListBox '/
function QCustomListBox.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QListBox
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomListBox.Dispatch(byref message as QMessage)
    Base.Dispatch(message)
    select case message.msg
    case cm_ctlcolor
        SetBKMode(cast(hdc,message.wparam),transparent)
        SetBKColor(cast(hdc,message.wparam),Canvas.color)
        SetTextColor(cast(hdc,message.wparam),Canvas.textcolor)
        SetBKMode(cast(hdc,message.wparam),opaque)
        message.result=cint(Canvas.brush)
        exit sub
    end select
end sub

operator QCustomListBox.cast as any ptr
    return @this
end operator

constructor QCustomListBox
    classname="QListBox"
    classancestor="ListBox"
    Canvas.color=clwindow
    Canvas.TextColor=0
end constructor

/' QListBox '/
function QListBox.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"ListBox",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QListBox"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomListBox.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function

operator QListBox.cast as any ptr
    return @this
end operator

operator QListBox.cast as hwnd
    return fHandle
end operator

constructor QListBox
    fcx=121
    fcy=21
    fstyle=ws_child or lbs_hasstrings or lbs_nointegralheight
    fExStyle=ws_ex_clientedge
end constructor

/' QCustomScrollBar '/
function QCustomScrollBar.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QScrollbar
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomScrollBar.Dispatch(byref message as QMessage)
    Base.Dispatch(message)
    select case message.msg
    case cm_ctlcolor
        SetBKMode(cast(hdc,message.wparam),transparent)
        SetBKColor(cast(hdc,message.wparam),Canvas.color)
        SetTextColor(cast(hdc,message.wparam),Canvas.textcolor)
        SetBKMode(cast(hdc,message.wparam),opaque)
        message.result=cint(Canvas.brush)
        exit sub
    end select
end sub

operator QCustomScrollBar.cast as any ptr
    return @this
end operator

constructor QCustomScrollBar
    classancestor="ScrollBar"
    classname="Scrollar"
end constructor

/' QScrollBar '/
function QScrollBar.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if (GetClassInfoEx(0,"ScrollBar",@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=@"QScrollBar"
       wc.hinstance=instance
       wc.lpfnwndproc=@QCustomScrollBar.dlgproc
       wc.cbwndextra +=4
       return RegisterClassEx(@wc)
    end if
    return 0
end function

operator QScrollBar.cast as any ptr
    return @this
end operator

operator QScrollBar.cast as hwnd
    return fHandle
end operator

constructor QScrollBar
    fcx=121
    fcy=17
    Canvas.color=clBtnFace
    Canvas.TextColor=0
    fstyle=ws_child
end constructor

''module initialization
sub Standard_Initialization constructor
    QForm.Register
    QLabel.Register
    QButton.Register
    QCheckBox.Register
    QRadioButton.Register
    QGroupBox.Register
    QEdit.Register
    QMemo.Register
    QComboBox.Register
    QListBox.Register
    QScrollBar.Register
end sub/'register classes in system'/

sub Standard_finalization destructor
    unRegisterClass("QForm",instance)
    unRegisterClass("QLabel",instance)
    unRegisterClass("QButton",instance)
    unRegisterClass("QCheckBox",instance)
    unRegisterClass("QRadioButton",instance)
    unRegisterClass("QGroupBox",instance)
    unRegisterClass("QEdit",instance)
    unRegisterClass("QMemo",instance)
    unRegisterClass("QListBox",instance)
    unRegisterClass("QComboBox",instance)
    unRegisterClass("QScrollBar",instance)
end sub/'unregister classes in system'/
