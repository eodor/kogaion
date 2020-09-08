'Small_gui_standard.bi -library windows controls wrapper
'this file is part of Koganion(RqWork7) rad-ide
'and can't be redistributed without permission
'Copyright (c)2020 Vasile Eodor Nastasa
'mail: nastasa.eodor@gmail.com
'web:http://www.rqwork.de
#include once "kogaion_gui.bas"
#include once "kogaion_gui_classes.bas"

''set main type, for form builder
#Define MainType "QForm"

''register classes to ide
#Define Standard_RegisterClasses "QLabel,QButton,QEdit,QMemo,QComboBox,QListBox,QCheckBox,QRadioButton,QGroupBox,QScrollBar"


'  QGadget -a generic class
'can be any control , depends of his classname, it's suitable for multiplatform coding
#Define Q_Gadget(__ptr__) *cast(QGadget ptr, @__ptr__)
#Define W_Gadget(__hwnd__) *cast(QGadget ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_Form(__ptr__) *cast(QForm ptr, @__ptr__)
#Define W_Form(__hwnd__) *cast(QForm ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_CustomStatic(__ptr__) *cast(QCustomStatic ptr, @__ptr__)
#Define W_CustomStatic(__hwnd__) *cast(QCustomStatic ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_Label(__ptr__) *cast(QLabel ptr, @__ptr__)
#Define W_Label(__hwnd__) *cast(Label ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_CustomButton(__ptr__) *cast(QCustomButton ptr, @__ptr__)
#Define W_CustomButton(__hwnd__) *cast(QCustomButton ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_Button(__ptr__) *cast(QButton ptr, @__ptr__)
#Define W_Button(__hwnd__) *cast(QButton ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_RadioButton(__ptr__) *cast(QRadioButton ptr, @__ptr__)
#Define W_RadioButton(__hwnd__) *cast(QRadioButton ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_CheckBox(__ptr__) *cast(QCheckBox ptr, @__ptr__)
#Define W_CheckBox(__hwnd__) *cast(QCheckBox ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_GroupBox(__ptr__) *cast(QGroupBox ptr, @__ptr__)
#Define W_GroupBox(__hwnd__) *cast(QGroupBox ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_CustomEdit(__ptr__) *cast(QCustomEdit ptr, @__ptr__)
#Define W_CustomEdit(__hwnd__) *cast(QCustomEdit ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_Edit(__ptr__) *cast(QEdit ptr, @__ptr__)
#Define W_Edit(__hwnd__) *cast(QEdit ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_Memo(__ptr__) *cast(QMemo ptr, @__ptr__)
#Define W_Memo(__hwnd__) *cast(QMemo ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_ListBox(__ptr__) *cast(QListBox ptr, @__ptr__)
#Define W_ListBox(__hwnd__) *cast(QListBox ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_ComboBox(__ptr__) *cast(QComboBox ptr, @__ptr__)
#Define W_ComboBox(__hwnd__) *cast(QComboBox ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))
#Define Q_ScrollBar(__ptr__) *cast(QScrollBar ptr, @__ptr__)
#Define W_ScrollBar(__hwnd__) *cast(QScrollBar ptr, GetWindowLong(__hwnd__,GetClassLong(__hwnd__,gcl_cbwndextra)-4))

type PGadget as QGadget ptr
type PCanvas as QCanvas ptr
type PForm as QForm ptr
type PLabel as QLabel ptr
type PButton as QButton ptr
type PCheckBox as QCheckBox ptr
type PRadioButton as QRadioButton ptr
type PGroupBox as QGroupBox ptr
type PEdit as QEdit ptr
type PMemo as QMemo ptr
type PListBox as QListBox ptr

type QGadget extends QFrame
    protected:
        declare virtual sub Dispatch(byref as QMessage)
    public:
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
        declare static function WindowProc as wndproc
        declare virtual operator cast as any ptr
        declare constructor(as PCreationParams=0)
end type

'  QForm
type QForm extends QCustomForm
    protected:
    declare virtual sub CreateHandle
    public:
    declare static function Register as integer
    declare virtual operator cast as any ptr 'for parent alowing
    declare operator cast as hwnd
    declare constructor 
end type

'  QCustomLabel
type QCustomLabel extends QFrame
    protected:
        declare virtual sub Dispatch(byref m as QMessage) 
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public: 
        declare virtual operator cast as any ptr
    declare constructor
end type

'  QLabel
type QLabel extends QCustomLabel
    declare static function Register as integer
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type

'  QCustomButton
type QCustomButton extends QFrame
    protected:
        declare virtual sub Dispatch(byref m as QMessage) 
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public:
    declare virtual operator cast as any ptr
    declare constructor
end type

'  QButton
type QButton extends QCustomButton
    declare static function Register as integer
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type

'  QRadioButton
type QRadioButton extends QCustomButton
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
    declare static function Register as integer
end type

'  QCheckBox
type QCheckBox extends QButton
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
    declare static function Register as integer
end type

'  QGroupBox
type QGroupBox extends QButton
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
    declare static function Register as integer
end type

'  QCustomEdit
type QCustomEdit extends QFrame
    protected:
    as string fSelText
    as integer fSelStart, fSelLength
    declare virtual sub Dispatch(byref as QMessage) 
    declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    declare abstract property SelText as string
    declare abstract property SelText(as string)
    declare abstract property SelStart as integer
    declare abstract property SelStart(as integer)
    declare abstract property SelLength as integer
    declare abstract property SelLength(as integer) 
    public:
    declare virtual operator cast as any ptr
    declare constructor
end type

'  QEdit
type QEdit extends QCustomEdit
    declare virtual property SelText as string  '''publish property for this
    declare virtual property SelText(as string)
    declare virtual property SelStart as integer
    declare virtual property SelStart(as integer)
    declare virtual property SelLength as integer
    declare virtual property SelLength(as integer) 
    declare static function Register as integer 
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type

'  QMemo
type QMemo extends QEdit
    protected:
    as integer fScrollBars, fWordWraps
    public:
    declare sub AddLine(as string="",as any ptr=0)
    declare sub InsertLine(as integer,as string="",as any ptr=0)
    declare sub RemoveLine overload(as integer)
    declare sub RemoveLine overload(as string)
    declare sub Clear
    declare virtual property SelText as string  '''publish properties for this
    declare virtual property SelText(as string)
    declare virtual property SelStart as integer
    declare virtual property SelStart(as integer)
    declare virtual property SelLength as integer
    declare virtual property SelLength(as integer)
    declare Property Lines(Index as integer) as string
    declare Property Lines(Index as integer,value as string)
    declare Property Count as Integer
    declare Property Count(value as Integer)
    declare Property CaretPos as Point
    declare Property CaretPos(value as Point)
    declare Property ScrollBars as integer
    declare Property ScrollBars(value as integer)
    declare Property WordWraps as Integer
    declare Property WordWraps(value as Integer)
    declare Sub Add(as string)
    declare Sub Insert(as integer,as string)
    declare Sub Undo
    declare Sub PasteFromClipboard
    declare Sub CopyToClipboard
    declare Sub CutToClipboard
    declare Sub SelectAll
    declare Sub LoadFromFile(File as string)
    declare Sub SaveToFile(File as string) 
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
    declare static function Register as integer
end type

'  QCustomComboBox
type QCustomComboBox extends QFrame
    protected:
        declare virtual sub Dispatch(byref m as QMessage)
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public:
        declare virtual operator cast as any ptr
        declare constructor
end type

'  QComboBox
type QComboBox extends QCustomComboBox
    declare static function Register as integer 
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type

'  QCustomLitBox
type QCustomListBox extends QFrame
    protected:
        declare virtual sub Dispatch(byref as QMessage) 
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public: 
        declare virtual operator cast as any ptr
    declare constructor
end type

''' QListBox
type QListBox extends QCustomListBox
    declare static function Register as integer
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type

'  QCustomScrollBar
type QCustomScrollBar extends QFrame
    protected:
        declare virtual sub Dispatch(byref as QMessage) 
        declare static function dlgProc(Dlg as hwnd,Msg as uint,wparam as wparam,lparam as lparam) as lresult
    public:
        declare virtual operator cast as any ptr
    declare constructor
end type

''' QScrollBar
type QScrollBar extends QCustomScrollBar
    declare static function Register as integer
    declare virtual operator cast as any ptr
    declare operator cast as hwnd
    declare constructor
end type

