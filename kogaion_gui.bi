'koganion_gui.bi -library windows controls wrapper
'this file is part of Koganion(RqWork7) rad-ide
'and can't be redistributed without permission
'Copyright (c)2020 Vasile Eodor Nastasa
'mail: nastasa.eodor@gmail.com
'web:http://www.rqwork.de

#define Debug /'false'/ true

#if defined(RecreateOnStyleApply)=0 
common shared as boolean RecreateOnStyleApply
#endif

#include once "windows.bi"
#include once "win/CommCtrl.bi"
#include once "kogaion_gui_sysutils.bas"

''local instances and default cursor
#define instance GetModuleHandle(0)
#define crDefault LoadCursor(0,idc_arrow)

#define clBtnFace GetSysColor(color_btnface)
#define clWindow GetSysColor(color_window)
#define clWindowText GetSysColor(color_windowtext)

'''define casting types
#Define Q_Object(__ptr__) *cast(QObject ptr, @__ptr__)
#Define W_Object(__hwnd__) *cast(QObject ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))

#Define Q_Frame(__ptr__) *cast(QFrame ptr, @__ptr__)
#Define W_Frame(__hwnd__) *cast(QFrame ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))

#Define Q_CustomForm(__ptr__) *cast(QCustomForm ptr, @__ptr__)
#define W_CustomForm(dlg) *cast(PCustomForm, GetWindowLong(dlg,GetClassLong(dlg,gcl_cbwndextra)-4))

dim as OSVERSIONINFO os
os.dwOSVersionInfoSize=sizeof(os)
if GetVersionEx(@os) then
   if os.dwMajorVersion>=6 then
      RecreateOnStyleApply=true
   else
      RecreateOnStyleApply=false   
   end if
end if

''the windows bug was fixed
RecreateOnStyleApply=false

type PObject as QObject ptr
type PClassObject as QClassObject ptr
type PFrame as QFrame ptr 
type PCustomForm as QCustomForm ptr
type PApplication as QApplication ptr

common shared as PClassObject CreationData
common shared as PApplication IApplication

#Define Application *(iApplication)

const CM_COMMAND  = WM_APP+100
const CM_CTLCOLOR = WM_APP+101

const RTTI_SET =wm_app+10000
const RTTI_GET =wm_app+10001

declare function MainWindow as hwnd
declare sub ShowMessage(as string)
declare function messageDlg(as string,as string,as integer) as integer

type PCreationParams as QCreationParams ptr
type QCreationParams
    as string  ClassName
    as string  ClassAncestor
    as integer ExStyle
    as integer Style
    as integer cx
    as integer cy
    as wndproc Proc
    as any ptr lpData '''reserved
end type

common shared as PCreationParams CreationParams

#define Q_CreationParams(__ptr__) *cast(PCreationParams,__ptr__)

type PCanvasMessage as QCanvasMessage ptr
type QCanvasMessage
    Handle as hdc
    ps     as paintstruct ptr
end type

type QMessage
     dlg      as hwnd
     msg      as uint
     wparam   as wparam
     lparam   as lparam
     result   as lresult
     Sender   as PObject
     Captured as PObject
     Painted  as PCanvasMessage
end type

type QObject extends object 
    protected:
    as integer fObjectCount
    as PObject ptr fObjects
    as string fName
    public:
    declare function FindObject(v as PObject) as integer
    declare sub AddObject(as PObject)
    declare sub RemoveObject(as PObject)
    as any ptr TagPtr
    as integer Tag
    declare operator cast as any ptr
end type

type QClassObject extends QObject
    protected:
    as hwnd fHandle
    public:
    as any ptr id
    as string  ClassName,ClassAncestor
    declare abstract sub Create
    declare abstract sub RegisterProc(as wndproc)
    declare abstract sub CreateHandle
    declare abstract sub ReCreateHandle
    declare abstract sub DestroyHandle
    declare abstract sub Dispatch(byref as QMessage)
    declare abstract sub DefaultHandler(byref as QMessage)
    declare property Handle as hwnd
    declare property Handle (as hwnd)
    declare property Name as string
    declare property Name(as string)
    declare abstract operator cast as any ptr
    as sub(byref as QObject) onNameChanged
end type

type QEvent as sub(byref as QObject)
type QCloseEvent as sub(byref as QObject,byref as integer)
type QMouseDownEvent as sub(byref as QObject,as byte,as integer,as integer,as integer)
type QMouseUpEvent as sub(byref as QObject,as byte,as integer,as integer,as integer)
type QMouseWheelEvent as sub(byref as QObject,as byte,as integer,as integer,as integer)
type QMouseMoveEvent as sub(byref as QObject,as byte,as integer,as integer)
type QKeyDownEvent as sub(byref as QObject,as word,as integer)
type QKeyUpEvent as sub(byref as QObject,as word,as integer)
type QKeyPressEvent as sub(byref as QObject,as byte)
type QCommandEvent as sub(byref as QObject,as byte,as integer,as hwnd)
type QMenuEvent as sub(byref as QObject,as integer,as integer)
type QAccelEvent as sub(byref as QObject,as integer,as integer)
type QMouseWheel as sub(byref as QObject,as integer,as integer,as integer,as integer) 

type QCustomCanvas extends QObject
    protected:
    as PFrame fFrame
    as hdc fHandle
    as hbrush fBrush
    as hpen fPen
    as hfont fFont
    public:
    declare abstract sub Paint(byref as QMessage)
    declare abstract sub TextOut(as integer,as integer,as string)
    declare abstract sub MoveTo(as integer,as integer)
    declare abstract sub LineTo(as integer,as integer)
    declare abstract sub Line(as integer,as integer,as integer,as integer)
    declare abstract sub Ellipse(as integer,as integer,as integer,as integer)
    declare abstract sub Rectangle overload(as integer,as integer,as integer,as integer)
    declare abstract sub Rectangle(as rect)
end type

type QCanvas extends QCustomCanvas
    private:
    protected:
    as colorref fColor,fTextColor
    public:
    declare virtual sub Paint(byref as QMessage)
    declare virtual sub TextOut(as integer,as integer,as string)
    declare virtual sub MoveTo(as integer,as integer)
    declare virtual sub LineTo(as integer,as integer)
    declare virtual sub Line(as integer,as integer,as integer,as integer)
    declare virtual sub Ellipse(as integer,as integer,as integer,as integer)
    declare virtual sub Rectangle overload(as integer,as integer,as integer,as integer)
    declare virtual sub Rectangle(as rect)
    declare property Handle as hdc
    declare property Handle (as hdc)
    declare property Color as colorref
    declare property Color (as colorref)
    declare property TextColor as colorref
    declare property TextColor (as colorref)
    declare property Brush as hbrush
    declare property Brush (as hbrush)
    declare property Frame as PFrame
    declare property Frame (as PFrame)
    declare operator cast as hdc
    declare operator cast as any ptr
    declare constructor
    declare destructor
    onPaint as QEvent
end type

type QAnchor
     as integer Left,Top,Right,Bottom
end type

enum QAlign
    alNone=0, alLeft, alRight, alTop, alBottom, alClient, alCustom
end enum

enum QControlStyle
    csDefault,csAcceptChilds,csTransparent
end enum

type QFrame extends QClassObject
     private:
     as integer nextID=0    
     protected:
     as wndproc fprevproc
     as integer fAlign, foldZ, fClientWidth, fClientHeight
     as QControlStyle fControlStyle
     as integer fControlCount
     as PFrame ptr fControls
     as PFrame fSelected
     as wndclassex wc
     as rect fClientRect, fWindowRect
     as PFrame fParent
     as hwnd fParentWindow
     as string fText
     as integer fStyle, fExStyle, fID, fx, fy, fcx, fcy
     as boolean fEnabled, fVisible, fGrouped, fTabStop, fdesignmode
     as wndproc fdlgproc
     declare virtual sub Create
     declare virtual sub RegisterProc(as wndproc)
     declare virtual sub CreateHandle
     declare virtual sub DestroyHandle
     declare virtual sub ReCreateHandle
     declare virtual sub Dispatch(byref as QMessage)
     declare virtual sub DefaultHandler(byref as QMessage)
     declare sub AddControl(as PFrame)
     declare sub RemoveControl(as PFrame)
     public:
     as QAnchor Anchor
     as QCanvas Canvas 
     declare sub Click
     declare static function Register(as string="",as string="",as wndproc=@DefWindowProc) as integer
     declare property Proc as wndproc
     declare property Proc(as wndproc)
     declare property Text as string
     declare property Text (as string)
     declare property ControlStyle as integer
     declare property ControlStyle(as integer)
     declare property Align as integer
     declare property Align(as integer)
     declare property Parent as PFrame
     declare property Parent (as PFrame)
     declare property ParentWindow as hwnd
     declare property ParentWindow (as hwnd)
     declare property Style as integer
     declare property Style (as integer)
     declare property ExStyle as integer
     declare property ExStyle (as integer)
     declare property Id as integer
     declare property Id (as integer)
     declare property Left as integer
     declare property Left (as integer)
     declare property Top as integer
     declare property Top (as integer)
     declare property Width as integer
     declare property Width (as integer)
     declare property Height as integer
     declare property Height (as integer)
     declare property Enabled as boolean
     declare property Enabled (as boolean)
     declare property Visible as boolean
     declare property Visible (as boolean)
     declare property TabStop as boolean
     declare property TabStop (as boolean)
     declare property Grouped as boolean
     declare property Grouped (as boolean)
     declare property Control(as integer) as PFrame
     declare property Control(as integer,as PFrame)
     declare property ControlCount as integer
     declare property ControlCount( as integer)
     declare property ClientWidth as integer
     declare property ClientWidth( as integer)
     declare property ClientHeight as integer
     declare property ClientHeight( as integer)
     declare property ClientRect as rect
     declare property ClientRect( as rect)
     declare sub SetBounds overload(x as integer,y as integer,cx as integer,cy as integer)
     declare sub SetBounds(v as rect)
     declare virtual operator cast as any ptr
     declare constructor
     declare destructor
     declare function IndexOfControl(as PFrame) as integer
     declare sub InsertControl(value as PFrame)
     declare sub RequestAlign
     declare sub RequestAnchor
     declare function Perform(as uint,as wparam,as lparam) as lresult
     declare sub BringToFront
     declare sub SendToBack
     declare sub SetFocus
     declare sub KillFocus
     declare sub Invalidate
     declare sub Repaint
     declare sub Refresh
     declare sub ClientToScreen(byref as point)
     declare sub ScreenToClient(byref as point)
     onCreate as QEvent
     onDestroy as QEvent
     onClick as QEvent
     onDblClick as QEvent
     onPaint as QEvent
     onMouseDown as QMouseDownEvent
     onMouseUp as QMouseUpEvent
     onMouseMove as QMouseMoveEvent
     onMouseWheelEvent as QMouseWheelEvent
     onKeyDown as QKeyDownEvent
     onKeyUp as QKeyUpEvent
     onKeyPress as QKeyPressEvent
     onCommand as QCommandEvent
     onMenu as QMenuEvent
     onAccel as QAccelEvent
     onMouseWheel as QMouseWheel
end type

type QCustomForm extends QFrame
    enum QFormStyle
         fsNormal, fsMDIForm, fsMDIChild, fsStayOnTop
    end enum
    protected:
    as QFormStyle fFormStyle
    declare static function DlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public:
    declare static function WindowProc as wndproc
    declare virtual operator cast as any ptr
    declare property FormStyle as QFormStyle
    declare property FormStyle (as QFormStyle)
    declare constructor
    declare destructor
    onClose as QCloseEvent
end type

type QApplication extends QCustomForm
     declare sub Run
     declare sub Quit
     declare sub Terminate
     declare operator cast as any ptr
     declare operator cast as hwnd
     declare operator cast as hinstance
     declare constructor
     declare Destructor
end type


'''Global 
common shared as integer ptr __hnd 
