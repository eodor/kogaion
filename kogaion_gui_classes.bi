'Small_gui.bi -library windows controls wrapper
'Copyright (c)2020 Vasile Eodor Nastasa
'mail: nastasa.eodor@gmail.com
'web:http://www.rqwork.de

#include once "vbcompat.bi"
#include once "kogaion_gui.bi"

type QStrings extends QObject
    enum QStringsAction
        acNone=0
        acError
        acAdd
        acInsert
        acRemove
        acClear
        acLoadFromFile
        acSaveToFile
    end enum
    protected:
    as QStringsAction fAction
    as zstring ptr ptr fItems
    as integer fCount, fCapacity
    as string fText
    as any ptr ptr fObjects
    as boolean fAllowDuplicates
    as string fFileName 
    as PObject fOwner
    public:
    declare sub Change
    declare function IndexOf(as string) as integer
    declare function IndexOfObject(as any ptr) as integer
    declare function Add(v as string="",as any ptr=0) as integer
    declare sub Remove overload(as string)
    declare sub Remove overload(as integer)
    declare sub Clear
    declare sub LoadFromFile(as string)
    declare sub SaveToFile(as string)
    declare property Owner as PObject
    declare property Owner(as PObject)
    declare property Items as zstring ptr ptr
    declare property Items (as zstring ptr ptr)
    declare property Item(as integer) as string
    declare property Item(as integer,as string)
    declare property Count as integer
    declare property Count (as integer)
    declare property Capacity as integer
    declare property Capacity (as integer)
    declare property Text as string
    declare property Text(as string)
    declare operator cast as zstring ptr ptr
    declare operator cast as any ptr
    declare operator cast as string
    declare operator let (as string)
    declare constructor( as zstring ptr ptr=0)
    declare destructor
    onChange as sub(byref as QStrings,as QStringsAction)
end type

