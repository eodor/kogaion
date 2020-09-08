#include once "kogaion_gui_additional.bi"

property QCustomPanel.BorderStyle as integer
    return fBorderStyle
end property

property QCustomPanel.BorderStyle(v as integer)
    if v<4 then
       fborderstyle=v
    else
       fborderstyle=0
    end if
    Repaint
end property

property QCustomPanel.ImageBackground as string
    return fImageBackground
end property

property QCustomPanel.ImageBackground(v as string)
    fImageBackground=v
    if FileExists(v) then
       dim as string ext=ExtractFileExt(v)
       select case ext
       case ".bmp",".BMP":
            fImageHandle=LoadImage(0,v,image_bitmap,0,0,lr_loadfromfile)
       case ".ico",".ICO":
            fImageHandle=LoadImage(0,v,image_icon,0,0,lr_loadfromfile)
       case ".cur",".CUR":
            fImageHandle=LoadImage(0,v,image_cursor,0,0,lr_loadfromfile)
       case ".png",".PNG":
            fImageHandle=LoadImage(0,v,image_enhmetafile,0,0,lr_loadfromfile)
       end select
       Repaint
    end if
end property

property QCustomPanel.TextAlignment as integer
    return ftextalignment
end property

property QCustomPanel.TextAlignment (v as integer)
    ftextalignment=v
    if v>5 then ftextalignment=0
end property

function QCustomPanel.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QPanel
        if obj then
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

sub QCustomPanel.Dispatch(byref m as QMessage)
    Base.Dispatch(m) '''not forgot to inherite from base class
    select case m.msg
    case cm_ctlcolor
        SetBKMode(cast(hdc,m.wparam),transparent)
        SetBKColor(cast(hdc,m.wparam),Canvas.color)
        SetTextColor(cast(hdc,m.wparam),Canvas.textcolor)
        SetBKMode(cast(hdc,m.wparam),opaque)
        m.result=cint(Canvas.brush)
        exit sub
    case wm_lbuttondown
         click
         m.result=0
    case wm_erasebkgnd
         FillRect(Canvas.Handle,@fclientrect,canvas.brush)
         m.result=0
    case wm_paint
        dim as paintstruct ps
        BeginPaint(fHandle,@ps)
        Canvas.Handle=ps.hDC
        fClientRect=ps.rcpaint
        if this.fBorderStyle=1 then
            ExStyle=ExStyle or ws_ex_clientedge
        elseif this.fBorderStyle=2 then
            ExStyle=Exstyle and not ws_ex_clientedge
            DrawEdge(Canvas.Handle,@fclientrect,EDGE_SUNKEN,BF_RECT )
   	elseif this.fBorderStyle=3 then
   	    ExStyle=Exstyle and not ws_ex_clientedge
            DrawEdge(Canvas.Handle,@fclientrect,EDGE_RAISED,BF_RECT )
   	elseif this.fBorderStyle=4 then
   	    ExStyle=Exstyle and not ws_ex_clientedge
            DrawEdge(Canvas.Handle,@fclientrect,EDGE_BUMP,BF_RECT )
   	end if
   	dim as integer drStyle
        Select Case fTextAlignment
            Case 0
             drStyle = DT_SINGLELINE or DT_LEFT or DT_VCENTER
            Case 1
             drStyle = DT_SINGLELINE or DT_CENTER or DT_VCENTER
            Case 2
             drStyle = DT_SINGLELINE or DT_RIGHT  or DT_VCENTER
            Case 3
             drStyle = DT_EDITCONTROL or DT_LEFT or DT_VCENTER Or DT_WORDBREAK
            Case 4
             drStyle = DT_EDITCONTROL or DT_CENTER or DT_VCENTER Or DT_WORDBREAK
            Case 5
             drStyle = DT_EDITCONTROL or DT_RIGHT or DT_VCENTER Or DT_WORDBREAK
        End Select
        if fBorderStyle>0 then InflateRect(@fclientrect, 2, 2)
        DrawText(Canvas.Handle, Text, -1, @fclientrect, drStyle)
        EndPaint(fHandle,@ps)
        Base.Dispatch(m)
        m.result=0
    end select
end sub

operator QCustomPanel.cast as any ptr
    return @this
end operator

constructor QCustomPanel
    classname="QPanel"
end constructor

/' QPanel '/
function QPanel.Register as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    wc.lpszclassname=@"QPanel"
    wc.hinstance=instance
    wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
    wc.lpfnwndproc=@QCustomPanel.dlgproc
    wc.cbwndextra +=4
    return RegisterClassEx(@wc)
end function

operator QPanel.cast as any ptr
    return @this
end operator

operator QPanel.cast as hwnd
    return fHandle
end operator

constructor QPanel
    fstyle=ws_child
    fexstyle=ws_ex_controlparent
    fcx=115
    fcy=51
    ftextAlignment=4
end constructor

property QPanel.BorderStyle as integer  '''publish property
    return Base.BorderStyle
end property

property QPanel.BorderStyle(v as integer)
    Base.BorderStyle=v
end property

property QPanel.Alignment as integer  '''publish property
    return Base.TextAlignment
end property

property QPanel.Alignment(v as integer)
    Base.TextAlignment=v
end property

property QPanel.ImageBackground as string
    return Base.ImageBackground
end property

property QPanel.ImageBackground(v as string)
    Base.ImageBackground=v
end property

''module initialization
sub Additional_initialization constructor
    QPanel.Register
end sub

sub Additional_finalization destructor
    unRegisterClass("QPanel",instance)
end sub