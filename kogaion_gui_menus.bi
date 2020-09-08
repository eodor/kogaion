'kogaion_gui_menus.bi -library windows controls wrapper
'this file is part of Koganion(RqWork7) rad-ide
'and can't be redistributed without permission
'Copyright (c)2020 Vasile Eodor Nastasa
'mail: nastasa.eodor@gmail.com
'web:http://www.rqwork.de

#include once "kogaion_gui.bi"
#include once "kogaion_gui_classes.bi"

''register classes to ide
#Define Menus_RegisterComponents "QMainMenu,QPopupMenu"

#Define Q_Menu(__ptr__) *cast(QMenu ptr, @__ptr__)
#Define Q_MenuItem(__ptr__) *cast(QMMenuItem ptr, @__ptr__)
#Define Q_MainMenu(__ptr__) *cast(QMainMenu ptr, @__ptr__)
#Define Q_PopupMenu(__ptr__) *cast(QPopupMenu ptr, @__ptr__)

type PMenu as QMenu ptr
type QMenu extends QObject
    protected:
    as hmenu fHandle
    as PMenu ptr fItems
    as integer fCount
    declare abstract sub Create
    declare abstract sub Free
    public:
    declare abstract operator cast as any ptr
end type

type QMenuItem extends QMenu
    protected:
    declare virtual sub Create
    declare virtual sub Free
    public:
    declare virtual operator cast as any ptr
    declare constructor
end type

type QMainMenu extends QMenu
    protected:
    declare virtual sub Create
    declare virtual sub Free
    public:
    declare static function Register as integer ''for ide using
    declare virtual operator cast as any ptr
    declare constructor
end type

type QPopupMenu extends QMenu
    protected:
    declare virtual sub Create
    declare virtual sub Free
    public:
    declare static function Register as integer ''for ide using
    declare virtual operator cast as any ptr
    declare constructor
end type
