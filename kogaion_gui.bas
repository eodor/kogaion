#include once "kogaion_gui.bi"

private function EnumThreadWindowsProc(Dlg as hwnd,lParam as lparam) as boolean
    if GetWindowLong(dlg,gwl_exstyle) and ws_ex_appwindow=ws_ex_appwindow then
       *cast(integer ptr,lparam)=cint(dlg)
       exit function
    end if
    return false
end function

function MainWindow as hwnd
    EnumThreadWindows(GetCurrentThreadId,cast(enumwindowsproc,@EnumThreadWindowsProc),cint(__hnd))
    return cast(hwnd,*__hnd)
end function

sub ShowMessage(v as string)
    dim as string s=string(256,0)
    GetModuleFileName(GetModuleHandle(0),s,256)
    MessageBox(MainWindow,v,ExtractFileName(s),mb_applmodal or mb_topmost)
end sub

function MessageDlg(v as string,c as string,b as integer=mb_ok) as integer
    return MessageBox(MainWindow,v,c,b or mb_applmodal or mb_topmost)
end function

'''QObject
function QObject.FindObject(v as PObject) as integer
    for i as integer=0 to fObjectCount-1
        if fObjects[i]=v then return i
    next    
    return -1
end function

sub QObject.AddObject(v as PObject)
    dim as integer i=FindObject(v)
    if i>-1 then
       fObjectCount+=1
       fObjects=reallocate(fObjects,sizeof(PObject)*fObjectCount)
       fObjects[fObjectCount-1]=v
    end if   
end sub

sub QObject.RemoveObject(v as PObject)
    dim as integer i=FindObject(v)
    if i <>-1 then
        fobjects[i]=null
        for i as integer = i+1 to fobjectcount-1
            fobjects[i-1] = fobjects[i+1]
        next
        fobjectcount -= 1
        fobjects = reallocate(fobjects,sizeof(PObject)*fobjectcount)
    end if
end sub
    
operator QObject.cast as any ptr
    return @this
end operator

'''QClassObject
property QClassObject.Handle as hwnd
    return fHandle
end property

property QClassObject.Handle (v as hwnd)
    fHandle=v
end property

property QClassObject.Name as string
    return fName
end property

property QClassObject.Name(v as string)
    fName=v
    if onNameChanged then onNameChanged(this)
end property

'''QCanvas
property QCanvas.Handle as hdc
    return fHandle
end property

property QCanvas.Handle (v as hdc)
    fHandle=v
end property

sub QCanvas.TextOut(x as integer,y as integer,v as string)
    .TextOut(fHandle,x,y,v,len(v))
end sub

sub QCanvas.MoveTo(x as integer,y as integer)
    .MoveToEx(fHandle,x,y,0)
end sub

sub QCanvas.LineTo(cx as integer,cy as integer)
    .LineTo(fHandle,cx,cy)
end sub

sub QCanvas.Line(x as integer,y as integer,cx as integer,cy as integer)
    .MoveToEx(fHandle,x,y,0)
    .LineTo(fHandle,cx,cy)
end sub

sub QCanvas.Ellipse(x as integer,y as integer,cx as integer,cy as integer)
    .Ellipse(fHandle,x,y,cx,cy)
end sub

sub QCanvas.Rectangle(x as integer,y as integer,cx as integer,cy as integer)
    .Rectangle(fHandle,x,y,cx,cy)
end sub

sub QCanvas.Rectangle(v as rect)
    .Rectangle(fHandle,v.left,v.top,v.right,v.bottom)
end sub

sub QCanvas.Paint(byref m as QMessage)
    ''do what you want to do here in paint event
    SetBKMode(fHandle,TRANSPARENT)
    SetBKColor(fHandle,fColor)
    SetTextColor(fHandle,fTextColor)
    SetBKMode(fHandle,OPAQUE)/''/
    if onPaint then onPaint(*fFrame)
end sub

property QCanvas.Color as colorref
    if fHandle then fColor=GetDCBrushColor(fHandle)
    return fColor
end property

property QCanvas.Color (v as colorref)
    fColor=v
    if fBrush then DeleteObject(fBrush)
    fBrush=CreateSolidBrush(v)
    if fFrame then
       if isWindow(fFrame->Handle) then
          RedrawWindow(fFrame->Handle,0,0,rdw_erase or rdw_invalidate)
          UpdateWindow(fFrame->Handle)
       end if
    end if
    '''or SetDCBrushColor(fHandle,fColor), but we still need the brush...
end property

property QCanvas.TextColor as colorref
    return fTextColor
end property

property QCanvas.TextColor (v as colorref)
    fTextColor=v
    if fFrame then
       if isWindow(fFrame->Handle) then
          RedrawWindow(fFrame->Handle,0,0,rdw_erase or rdw_invalidate)
          UpdateWindow(fFrame->Handle)
       end if
    end if
end property

property QCanvas.Brush as hbrush
    return fBrush
end property

property QCanvas.Brush (v as hbrush)
    dim as logbrush lb
    if fBrush then DeleteObject(fBrush)
    if GetObject(v,sizeof(logbrush),@lb) then
       fBrush=CreateBrushIndirect(@lb)
       fColor=lb.lbColor
       if fFrame then
          if isWindow(fFrame->Handle) then
             RedrawWindow(fFrame->Handle,0,0,rdw_erase or rdw_invalidate)
             UpdateWindow(fFrame->Handle)
          end if
       end if
    end if
end property

property QCanvas.Frame as PFrame
    return fFrame
end property

property QCanvas.Frame (v as PFrame)
    fFrame=v
    if v then
       if isWindow(v->Handle) then
          RedrawWindow(v->Handle,0,0,rdw_erase or rdw_invalidate)
          UpdateWindow(v->Handle)
       end if
    end if
end property

operator QCanvas.cast as hdc
    return fHandle
end operator

operator QCanvas.cast as any ptr
    return @this
end operator

constructor QCanvas
    TextColor=0
end constructor

destructor QCanvas
end destructor

'''QFrame
constructor QFrame
    fenabled=true
    fvisible=true
    Canvas.Frame=@this
    Canvas.Color=GetSysColor(color_window)
end constructor

destructor QFrame
    if fParent then fParent->RemoveControl(this)
    for i as integer=0 to fControlCount-1
         fControls[i]->DestroyHandle
    next
end destructor

sub QFrame.Click
    if onclick then onclick(this)
end sub

sub QFrame.Create
end sub

function QFrame.Register(sClassName as string="",sClassAncestor as string="",wproc as wndproc=@DefWindowProc) as integer
    dim as wndclassex wc
    wc.cbsize=sizeof(wc)
    if sClassName="" and sClassAncestor="" then exit function
    if sClassName="" and sClassAncestor<>"" then exit function
    if (GetClassInfoEx(0,sClassAncestor,@wc)>0) /'or (GetClassInfoEx(instance,sClassAncestor,@wc)>0)'/ then
       wc.style=wc.style or cs_dblclks or cs_owndc or cs_globalclass
       wc.lpszclassname=strptr(sClassName)
       wc.hinstance=instance
       wc.lpfnwndproc=wproc
       wc.cbwndextra +=4
    end if
    return RegisterClassEx(@wc)
end function'

sub QFrame.SetBounds(x as integer,y as integer,cx as integer,cy as integer)
    fx=x
    fy=y
    fcx=cx
    fcy=cy
    if isWindow(fHandle) then MoveWindow(fHandle,fx,fy,fcx,fcy,1)
end sub

sub QFrame.SetBounds(v as rect)
    fx=v.left
    fy=v.top
    fcx=v.right
    fcy=v.right
    if isWindow(fHandle) then MoveWindow(fHandle,fx,fy,fcx,fcy,1)
end sub

sub QFrame.AddControl(value as PFrame)
    if indexOfControl(value) = -1 then
        fcontrolcount += 1
        fcontrols = reallocate(fcontrols,sizeof(PFrame)*fcontrolcount)
        fcontrols[fcontrolcount-1] = value
    end if
end sub

sub QFrame.RemoveControl(value as PFrame)
    dim as integer i = IndexOfControl(value)
    if i <>-1 then
        fcontrols[i] = null
        for i as integer = i+1 to fcontrolcount-1
            fcontrols[i-1] = fcontrols[i+1]
        next
        fcontrolcount -= 1
        fcontrols = reallocate(fcontrols,sizeof(PFrame)*fcontrolcount)
    end if
end sub

function QFrame.IndexOfControl(value as PFrame) as integer
    for i as integer = 0 to fcontrolcount-1
        if fcontrols[i] = value then return i
    next
    return -1
end function

sub QFrame.InsertControl(value as PFrame)
    AddControl(value)
    if value then if value->fparent then value->fparent->requestAlign
end sub

sub QFrame.RequestAnchor
end sub

sub QFrame.RequestAlign
     dim as PFrame ptr ListLeft, ListRight, Listtop, ListBottom, ListClient
     dim as integer i,LeftCount = 0, RightCount = 0, topCount = 0, BottomCount = 0, ClientCount = 0
     dim as integer ttop, btop, lLeft, rLeft
     dim as integer aLeft, atop, aWidth, aHeight
     if ControlCount = 0 then exit sub
     lLeft = 0
     rLeft = ClientWidth
     ttop  = 0
     btop  = ClientHeight
     for i = 0 to fControlCount -1
         aleft = fcontrols[i]->left
         atop = fcontrols[i]->top
         awidth = fcontrols[i]->width
         aheight = fcontrols[i]->height
         select case fcontrols[i]->Align
                case 1'alLeft
                    LeftCount += 1
                    ListLeft = reallocate(ListLeft,sizeof(PFrame)*LeftCount)
                    ListLeft[LeftCount -1] = fcontrols[i]
                case 2'alRight
                    RightCount += 1
                    ListRight = reallocate(ListRight,sizeof(PFrame)*RightCount)
                    ListRight[RightCount -1] = fcontrols[i]
                case 3'altop
                    topCount += 1
                    Listtop = reallocate(Listtop,sizeof(PFrame)*topCount)
                    Listtop[topCount -1] = fcontrols[i]
                case 4'alBottom
                    BottomCount += 1
                    ListBottom = reallocate(ListBottom,sizeof(PFrame)*BottomCount)
                    ListBottom[BottomCount -1] = fcontrols[i]
                case 5'alClient
                    ClientCount += 1
                    ListClient = reallocate(ListClient,sizeof(PFrame)*ClientCount)
                    ListClient[ClientCount -1] = fcontrols[i]
          end select
     next i

   for i = 0 to topCount -1
      with *Listtop[i]
         if .fvisible then
            ttop += .Height
            .SetBounds(0,ttop - .Height,rLeft,.Height)
                if .anchor.left then .SetBounds(aleft,ttop - .Height,rLeft,.Height)
                if .anchor.right then .SetBounds(aleft,ttop - .Height,rLeft,aheight)
         end if
      end with
   next i
   'btop = ClientHeight
   for i = 0 to BottomCount -1
      with *ListBottom[i]
         if .fvisible then
            btop -= .Height
            .SetBounds(0,btop,rLeft,.Height)
         end if
      end with
   next i
   'lLeft = 0
   for i = 0 to LeftCount -1
      with *ListLeft[i]
         if .fvisible then
            lLeft += .Width
            .SetBounds(lLeft - .Width, ttop, .Width, btop - ttop)
         end if
      end with
   next i
   'rLeft = ClientWidth
   for i = 0 to RightCount -1
      with *ListRight[i]
         if .fvisible then
            rLeft -= .Width
            if Debug then ?.ClassName, rLeft, .Width
            .SetBounds(rLeft, ttop, .Width, btop - ttop)
         end if
      end with
   next i
   for i = 0 to ClientCount -1
      with *ListClient[i]
         if .fvisible then
            .SetBounds(lLeft,ttop,rLeft - lLeft,btop - ttop)
         end if
      end with
   next i
    if ListLeft   then deallocate ListLeft
    if ListRight  then deallocate ListRight
    if Listtop    then deallocate Listtop
    if ListBottom then deallocate ListBottom
    if ListClient then deallocate ListClient
end sub

function QFrame.Perform(msg as uint,wparam as wparam,lparam as lparam) as lresult
    return SendMessage(fhandle,msg,wparam,lparam)
end function

sub QFrame.BringToFront
    if IsWindow(fhandle) then
        'dim as HWND Dlg = GetTopWindow(fhandle)
        'while ( Dlg )
        '    foldz += 1
        '    GetnextWindow( Dlg, GW_HWNDnext)
        'wend
        foldZ = IndexOfControl(@this)
        BringWindowToTop(fhandle)
    end if
end sub

sub QFrame.SendToBack
    if IsWindow(fhandle) then
        SetWindowPos(fhandle,fcontrols[foldz]->handle, 0, 0 ,0 ,0, SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOSIZE)
    end if
end sub

sub QFrame.SetFocus
    if IsWindow(fhandle) then .SetFocus(fhandle)
end sub

sub QFrame.KillFocus
    if IsWindow(fhandle) then Perform(WM_KILLFOCUS, 0, 0)
end sub

sub QFrame.Invalidate
    if IsWindow(fhandle) then InvalidateRect(fhandle, 0, 0)
end sub

sub QFrame.Repaint
    if IsWindow(fhandle) then RedrawWindow(fhandle, 0, 0, RDW_INTERNALPAINT)
end sub

sub QFrame.Refresh
    if IsWindow(fhandle) then RedrawWindow(fhandle, 0, 0, RDW_ERASE or RDW_INVALIDATE)
end sub

sub QFrame.ClientToScreen(byref p as point)
    if IsWindow(fhandle) then .ClientToScreen(fhandle,@p)
end sub

sub QFrame.ScreenToClient(byref p as point)
    if IsWindow(fhandle) then .ScreenToClient(fhandle,@p)
end sub

property QFrame.ControlStyle as integer
    return fControlStyle
end property

property QFrame.ControlStyle(v as integer)
    if v<3 then
       fControlStyle=v
    else
       fControlStyle=0
    end if
    if csTransparent and v=csTransparent then 
       if isWindow(fHandle) then
          ExStyle=ExStyle or ws_ex_transparent
       end if 
    end if            
end property

property QFrame.Id as integer
    if isWindow(fHandle) then
       fid=GetWindowLong(fHandle,gwl_id)
    end if
    return fid
end property

property QFrame.Id (v as integer)
    fid=v
    if isWindow(fhandle) then SetWindowLong(fhandle,gwl_id,fid)
end property

property QFrame.ClientWidth as integer
    if isWindow(fHandle) then
       GetClientRect(fHandle,@fClientRect)
       fClientWidth=fClientRect.Right
    end if
    return fclientwidth
end property

property QFrame.ClientWidth(value as integer)
end property

property QFrame.ClientHeight as integer
    if isWindow(fHandle) then
       GetClientRect(fHandle,@fClientRect)
       fClientHeight=fClientRect.Bottom
    end if
    return fclientheight
end property

property QFrame.ClientHeight(value as integer)
end property

property QFrame.ClientRect as rect
    if isWindow(fHandle) then GetClientRect(fHandle,@fclientrect)
    return fclientrect
end property

property QFrame.ClientRect(value as rect)
end property

property QFrame.Proc as wndproc
    if isWindow(fhandle) then
       fdlgproc=cast(wndproc,GetWindowLong(fHandle,gwl_wndproc))
    else
        dim as wndclassex wcls
        wcls.cbsize=sizeof(wcls)
        if GetClassInfoEx(instance,ClassName,@wcls) then
           fdlgproc=wcls.lpfnwndproc
        end if
    end if
    return fdlgproc
end property

property QFrame.Proc(v as wndproc)
    if v<>GetWindowLong(fHandle,gwl_wndproc) then
       fdlgproc=v
       fprevproc=cast(wndproc,SetWindowLong(fHandle,gwl_wndproc,cint(v)))
    end if
end property

property QFrame.Align as integer
    return falign
end Property

property QFrame.Align(value as integer)
    falign = value
    if fparent then
       fparent->RequestAlign
       fParent->Repaint
    end if
end Property

property QFrame.ControlCount as integer
    return fcontrolcount
end property

property QFrame.ControlCount(value as integer)
    '''do nothing
end property

property QFrame.Control(index as integer) as PFrame
    if index>-1 and index<fControlCount then
       return fcontrols[index]
    end if
    return null
end property

property QFrame.Control(index as integer,value as PFrame)
    ''' do nothing
end property

property QFrame.Text as string
    if isWindow(fHandle) then
       dim as integer i=GetWiNdowTextLength(fHandle)
       fText=space(i)+chr(0)
       GetWindowText(fHandle,fText,len(fText))
    end if
    return fText
end property

property QFrame.Text (v as string)
    fText=v
    if isWindow(fHandle) then SetWindowText(fHandle,fText)
end property

property QFrame.Parent as PFrame
    if IsWindow(fhandle) then
       fparent = W_Frame(fhandle).fParent
    end if
    return fParent
end property

property QFrame.Parent (v as PFrame)
    if fParent then fParentWindow=fParent->fHandle
    dim as PFrame saveParent=fParent
    fParent=v
    if v then fParentWindow=v->fhandle
    if IsWindow(fHandle) then
       SetParent(fHandle,fParentWindow)
       if SaveParent then SaveParent->RemoveControl(this)
       if fParent then fParent->AddControl(this)
    else
       if fParent then fParent->AddControl(this)
       CreateHandle
    end if
end property

property QFrame.ParentWindow as hwnd
    if isWindow(fHandle) then
       fParentWindow=GetParent(fHandle)
       if isWindow(fParentWindow) then fParent=W_Frame(fParentWindow)
    end if
    return fParentWindow
end property

property QFrame.ParentWindow (v as hwnd)
    fParentWindow=v
    if isWindow(fParentWindow) then fParent=W_Frame(fParentWindow)
    SetParent(fHandle,v)
end property

operator QFrame.cast as any ptr
    return @this
end operator

sub QFrame.RegisterProc(dlgproc as wndproc)
    wc.cbsize=sizeof(wc)
    wc.style=cs_dblclks or cs_owndc or cs_globalclass
    if GetClassInfoEx(0,ClassAncestor,@wc)=0 then
       wc.hcursor=crDefault
       'wc.hbrbackground=cast(hbrush,16)
    end if
    wc.lpszclassname=strptr(ClassName)
    wc.hinstance=instance
    wc.lpfnwndproc=dlgproc
    wc.cbwndextra +=4
    RegisterClassEx(@wc)
end sub

sub QFrame.ReCreateHandle
    DestroyHandle
    CreateHandle
end sub

sub QFrame.CreateHandle
    wc.cbsize=sizeof(wc)
    if GetClassInfoEx(instance,ClassName,@wc) then  :if Debug then print ClassName
       CreationData=this
       CreateWindowEx(fExStyle,ClassName,fText,fStyle or ws_clipchildren or ws_clipsiblings,fx,fy,fcx,fcy,fParentWindow,0,instance,0): if Debug then print "LastError Was=", getlasterror
       if isWindow(fHandle) then
          if fParent then fParent->ReQuestAlign
          EnableWindow(fHandle,fEnabled)
          ShowWindow(fHandle,iif(fvisible,sw_show,sw_hide))
          SetWindowLong(fHandle,gwl_id,fid)
          UpdateWindow(fHandle)
       end if
    else
       MessageBox(fParentWindow,"Can''t find the class.",ClassName,mb_applmodal or mb_topmost)
    end if
end sub

sub QFrame.DestroyHandle
    if IsWindow(fHandle) then
       DestroyWindow(fHandle)
       fHandle=0
    end if
end sub

sub QFrame.Dispatch(byref message as QMessage)
    select case message.msg
    case rtti_set
         message.result=0
         CreationParams=cast(PCreationParams,message.lparam)
         if CreationParams then
            this.ClassName=Q_CreationParams(CreationParams).ClassName
            this.ClassAncestor=Q_CreationParams(CreationParams).ClassAncestor
            this.ExStyle=Q_CreationParams(CreationParams).ExStyle
            this.Style=Q_CreationParams(CreationParams).Style
            this.width=Q_CreationParams(CreationParams).cx
            this.height=Q_CreationParams(CreationParams).cy
            this.Proc=Q_CreationParams(CreationParams).Proc
            message.result=len(*CreationParams)
         end if
    case rtti_get
         message.result=0
         CreationParams=cast(PCreationParams,message.lparam)
         if CreationParams then
            Q_CreationParams(CreationParams).ClassName=this.ClassName
            Q_CreationParams(CreationParams).ClassAncestor=this.ClassAncestor
            Q_CreationParams(CreationParams).ExStyle=this.ExStyle
            Q_CreationParams(CreationParams).Style=this.Style
            Q_CreationParams(CreationParams).cx=this.width
            Q_CreationParams(CreationParams).cy=this.height
            Q_CreationParams(CreationParams).Proc=this.Proc
            message.result=len(*CreationParams)
         end if
    case wm_erasebkgnd
         if ClassAncestor="" then
            GetClientRect(fHandle,@fClientRect)
            FillRect(cast(hdc,message.wparam),@fclientrect,Canvas.Brush)
         end if
         message.result=0
    case wm_paint
         dim as QCanvasMessage cm
         Canvas.Handle=GetDC(fHandle)
         cm.Handle=Canvas.Handle
         message.Painted=@cm
         Canvas.Paint(message)
         if onPaint then onPaint(this)
         message.result=0
    case wm_ctlcolordlg to wm_ctlcolorstatic
         message.result=SendMessage(cast(hwnd,message.lparam),cm_ctlcolor,message.wparam,message.wparam)
         exit sub
    case wm_nccreate:
         dim as zstring*255 s
         dim as integer l = getclassname(fhandle,s,255)
         classname = .left(s,l)
         SetWindowLongPtr(fhandle,GetClassLong(fhandle,gcl_cbwndextra)-4,cint(@this))
         fstyle = GetwindowLong(fhandle,GWL_STYLE)
         fexstyle = GetwindowLong(fhandle,GWL_EXSTYLE)
         CreationData=0
         message.result = 0
    case wm_create
         for i as integer=0 to fControlCount-1
             if isWindow(fControls[i]->fHandle)=0 then fControls[i]->Parent=this
         next
         if onCreate then onCreate(this)
         message.result=0
    case wm_destroy
         if Canvas.Handle then
            ReleaseDC(fHandle,Canvas.Handle)
         end if
         if onDestroy then onDestroy(this)
         message.result=message.wparam
    case wm_close
         dim as integer CloseAction=1 '''hide not free
         if this is QCustomForm then
            if Q_CustomForm(this).onClose then  Q_CustomForm(this).onClose(this,CloseAction)
         end if
         select case CloseAction
         case 0 : exit sub
         case 1 :/' message.result=1: PostQuitMessage(0) :'/if Debug then print "destroy"
         case 2 : ShowWindow(fHandle,sw_minimize):message.result=1 :exit sub
         case 3 : ShowWindow(fHandle,sw_maximize):message.result=1 :exit sub
         end select
         message.result=0
    case wm_size:
         fclientrect = type<rect>(0,0,loword(message.lparam),hiword(message.lparam))
         fclientwidth = loword(message.lparam)
         fclientheight = hiword(message.lparam)
         if fcontrolcount>0 then
            RequestAlign
            RequestAnchor
         end if
         message.result = 0
    case wm_settext
         fText=*cast(zstring ptr,message.lparam)
         message.result=0
    case wm_command
         fid=loword(message.wparam)
         dim as integer code=hiword(message.wparam)
         if isWindow(cast(hwnd,message.lparam)) then
             message.result=SendMessage(cast(hwnd,message.lparam),cm_command,fid,code)
             exit select
         end if
         if id=0 then
             if onMenu then onMenu(this,id,code)
             message.result=0
         elseif id=1 then
             if onAccel then onAccel(this,id,code)
             message.result=0
         end if
    case wm_stylechanged
         message.result=0
    case cm_command
         ''doing nothing
         message.result=0
    case wm_setfocus
         if fParent then
            fParent->fSelected=this
         end if
         message.result=0
    case wm_killfocus
         if fParent then if this=fParent->fSelected then fParent->fSelected=0
         message.result=0
    case wm_keydown
         if message.wparam=vk_tab then
            if fParent then
               nextID=fParent->indexOfControl(this)+1
               if nextID>fParent->fControlCount-1 then nextID=0
               Perform(wm_nextdlgctl,nextID,cint(fParent->fControls[nextID]))
            end if
         end if
         if onKeyDown then onKeyDown(This,cast(word,message.wparam),message.wparam and &hffff)
         message.result=0
    case wm_keyup
         if onKeyUp then onKeyUp(This,cast(word,message.wparam),message.wparam and &hffff)
         message.result=0
    case wm_char
         if onKeyPress then onKeyPress(This,cast(byte,message.wparam))
         message.result=0
    case wm_getdlgcode
         message.result = dlgc_wantallkeys
    case wm_nextdlgctl
         dim as PFrame nextCtrl=cast(PFrame,message.lparam)
         if nextCtrl then nextCtrl->SetFocus
         message.result = 0
    case wm_lbuttondblclk
         if onDblClick then onDblClick(this)
         message.result=0
    case wm_lbuttondown
         if onMouseDown then onMouseDown(this,1,loword(message.lparam),hiword(message.lparam),message.wparam and &hFFFFF)
         message.result=0
    case wm_lbuttonup
         if onMouseUp then onMouseUp(this,1,loword(message.lparam),hiword(message.lparam),message.wparam and &hFFFFF)
         message.result=0
    case wm_mbuttondown
         if onMouseDown then onMouseDown(this,2,loword(message.lparam),hiword(message.lparam),message.wparam and &hFFFFF)
         message.result=0
    case wm_mbuttonup
         if onMouseUp then onMouseUp(this,2,loword(message.lparam),hiword(message.lparam),message.wparam and &hFFFFF)
         message.result=0
    case wm_rbuttondown
         if onMouseDown then onMouseDown(this,3,loword(message.lparam),hiword(message.lparam),message.wparam and &hFFFFF)
         message.result=0
    case wm_rbuttonup
         if onMouseUp then onMouseUp(this,3,loword(message.lparam),hiword(message.lparam),message.wparam and &hFFFFF)
         message.result=0
    case wm_mousemove
         if onMouseMove then onMouseMove(this,loword(message.lparam),hiword(message.lparam),message.wparam and &hFFFFF)
         message.result=0
    case wm_mousewheel
         If OnMouseWheel Then OnMouseWheel(This,Sgn(Message.wParam),loword(Message.lParam),hiword(Message.lParam),Message.wParam AND &HFFFF)
         message.result=0
    case wm_ctlcolormsgbox to wm_ctlcolorstatic
         message.result=SendMessage(cast(hwnd,message.lparam),cm_ctlcolor,message.wparam,0)
         exit sub
    case wm_mousefirst to wm_mouselast
        if (fstyle and ws_child) then
            if fdesignmode then
               message.result = 1
               exit sub
            end if
        else
            message.result = 0
        end if
    case wm_nchittest
        if (fstyle and ws_child) then
            if fdesignmode then
               message.result = HTTRANSPARENT
               exit sub
            end if
        else
           message.result = 0
        end if
    end select
    DefaultHandler(message)
end sub

sub QFrame.DefaultHandler(byref message as QMessage)
    wc.cbsize=sizeof(wc)
    if ClassAncestor<>"" then
       if GetClassInfoEx(0,ClassAncestor,@wc) then
          message.result=CallWindowProc(wc.lpfnwndproc,fhandle,message.msg,message.wparam,message.lparam)
       else
          message.result=0
       end if
    else
       message.result=DefWindowProc(fhandle,message.msg,message.wparam,message.lparam)
    end if
end sub

property QFrame.Style as integer
    if isWindow(fHandle) then fStyle=GetWindowLong(fHandle,gwl_style)
    return fStyle
end property

property QFrame.Style (v as integer)
    fStyle=v
    if isWindow(fHandle) then
       if RecreateOnStyleApply then
          RecreateHandle
       else
       SetWindowLong(fHandle,gwl_style,v)
       SetWindowPos(fHandle,0,0,0,0,0,swp_nosize or swp_nomove or swp_noactivate or swp_nozorder or swp_framechanged)
       UpdateWindow(fHandle)
       end if
    end if
end property

property QFrame.ExStyle as integer
    if isWindow(fHandle) then fStyle=GetWindowLong(fHandle,gwl_exstyle)
    return fExStyle
end property

property QFrame.ExStyle (v as integer)
    fExStyle=v
    if isWindow(fHandle) then
       if RecreateOnStyleApply then
          RecreateHandle
       else
       SetWindowLong(fHandle,gwl_exstyle,v)
       SetWindowPos(fHandle,0,0,0,0,0,swp_nosize or swp_nomove or swp_noactivate or swp_nozorder or swp_framechanged)
       UpdateWindow(fHandle)
       end if
    end if
end property

property QFrame.Left as integer
    if isWindow(fHandle) then
       dim as rect rc
       GetWindowRect(fHandle,@rc)
       MapWindowPoints(0,GetParent(fHandle),cast(point ptr,@rc),2)
       fx=rc.Left
    end if
    return fx
end property

property QFrame.Left (v as integer)
    fx=v
    if isWindow(fHandle) then MoveWindow(fHandle,fx,fy,fcx,fcy,1)
end property

property QFrame.Top as integer
    if isWindow(fHandle) then
       dim as rect rc
       GetWindowRect(fHandle,@rc)
       MapWindowPoints(0,GetParent(fHandle),cast(point ptr,@rc),2)
       fy=rc.Top
    end if
    return fy
end property

property QFrame.Top (v as integer)
    fy=v
    if isWindow(fHandle) then MoveWindow(fHandle,fx,fy,fcx,fcy,1)
end property

property QFrame.Width as integer
    if isWindow(fHandle) then
       dim as rect rc
       GetWindowRect(fHandle,@rc)
       MapWindowPoints(0,GetParent(fHandle),cast(point ptr,@rc),2)
       fcx=rc.Right-rc.Left
    end if
    return fcx
end property

property QFrame.Width (v as integer)
    fcx=v
    if isWindow(fHandle) then MoveWindow(fHandle,fx,fy,fcx,fcy,1)
end property

property QFrame.Height as integer
    if isWindow(fHandle) then
       dim as rect rc
       GetWindowRect(fHandle,@rc)
       MapWindowPoints(0,GetParent(fHandle),cast(point ptr,@rc),2)
       fcy=rc.Bottom-rc.Top
    end if
    return fcy
end property

property QFrame.Height (v as integer)
    fcy=v
    if isWindow(fHandle) then MoveWindow(fHandle,fx,fy,fcx,fcy,1)
end property

property QFrame.Enabled as boolean
     if isWindow(fHandle) then fEnabled=IsWindowEnabled(fHandle)
     return fEnabled
end property

property QFrame.Enabled (v as boolean)
    fEnabled=v
    if isWindow(fHandle) then EnableWindow(fHandle,fEnabled)
end property

property QFrame.Visible as boolean
    if isWindow(fHandle) then fVisible=IsWindowVisible(fHandle)
    return fVisible
end property

property QFrame.Visible (v as boolean)
    fVisible=v
    if isWindow(fHandle) then  ShowWindow(fHandle,iif(v,sw_show,sw_hide))
end property

property QFrame.TabStop as boolean
    if isWindow(fHandle) then
       fTabStop=GetWindowLong(fHandle,gwl_style) and ws_tabstop
    end if
    return fTabStop
end property

property QFrame.TabStop (v as boolean)
    fTabStop=v
    if v then
       if fStyle and ws_tabstop=0 then fStyle or= ws_tabstop
    else
       if fStyle and ws_tabstop=ws_tabstop then fStyle = fStyle and not ws_tabstop
    end if
    if isWindow(fHandle) then SetWindowLong(fHandle,gwl_style,fStyle)
end property

property QFrame.Grouped as boolean
    if isWindow(fHandle) then
       fGrouped=GetWindowLong(fHandle,gwl_style) and ws_group
    end if
    return fGrouped
end property

property QFrame.Grouped (v as boolean)
    fGrouped=v
    if v then
       if fStyle and ws_group=0 then fStyle or= ws_group
    else
       if fStyle and ws_group=ws_group then fStyle = fStyle and not ws_group
    end if
    if isWindow(fHandle) then SetWindowLong(fHandle,gwl_style,fStyle)
end property

'''QCustomForm
function QCustomForm.WindowProc as wndproc
    return @QCustomForm.dlgProc
end function

function QCustomForm.dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
     dim as PClassObject obj=iif(creationdata,creationdata,cast(PClassObject,GetWindowLong(Dlg,GetClassLong(Dlg,gcl_cbwndextra)-4)))
     dim as QMessage m=type(dlg,msg,wparam,lparam,0,obj,0)
     if obj then
        obj->Handle=dlg
        obj->Dispatch(m)
        return m.result
     else
        obj=new QCustomForm
        dim as zstring*256 s
        dim as integer c=GetClassName(dlg,s,255)
        if obj then
           obj->classname=.left(s,c)
           obj->Handle=dlg
           obj->Dispatch(m)
           return m.result
        end if
     end if
     return m.result
end function

property QCustomForm.FormStyle as QFormStyle
    return fFormStyle
end property

property QCustomForm.FormStyle (v as QFormStyle)
    fFormStyle=v
    select case v
    case fsMDIChild
         if ExStyle and ws_ex_mdichild<>ws_ex_mdichild then ExStyle=ExStyle or ws_ex_mdichild
    case fsStayOnTop
         if ExStyle and ws_ex_topmost<>ws_ex_topmost then ExStyle=ExStyle or ws_ex_topmost
    case fsNormal
         if ExStyle and ws_ex_mdichild=ws_ex_mdichild then ExStyle=ExStyle and not ws_ex_mdichild
         if ExStyle and ws_ex_topmost=ws_ex_topmost then ExStyle=ExStyle and not ws_ex_topmost
    end select
end property


operator QCustomForm.cast as any ptr
    return @this
end operator

constructor QCustomForm
    fcx=450
    fcy=250
    fStyle=ws_overlappedwindow
    Canvas.Frame=@this
    Canvas.Color=GetSysColor(color_btnface)
end constructor

destructor QCustomForm
    this.DestroyHandle
end destructor


'''QApplication
IApplication=new QApplication

sub QApplication.Run
    dim as msg m
    while GetMessage(@m,0,0,0)>0
          TranslateMessage(@m)
          DispatchMessage(@m)
    wend
end sub

sub QApplication.Quit
end sub

sub QApplication.Terminate
end sub

operator QApplication.cast as any ptr
    return @this
end operator

operator QApplication.cast as hwnd
    return fHandle
end operator

operator QApplication.cast as hinstance
    return GetModuleHandle(0)
end operator

constructor QApplication
end constructor

destructor QApplication
end destructor


''module initialization
sub koganion_gui_initialization constructor
    __hnd=allocate(4)
end sub

sub koganion_gui_finalization destructor
    deallocate(__hnd)
end sub
