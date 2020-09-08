type PNameItem as EItem ptr 
type PEnumerator as QEnumerator ptr
type EItem
    as string BaseClass
    as integer id
    as PEnumerator Enumerator
    declare operator cast as any ptr
end type
operator EItem.cast as any ptr
    return @this
end operator  

type QEnumerator extends Object
    Count as integer
    Items as EItem ptr ptr
    NameCount as integer
    Names as zstring ptr ptr
    declare sub AddName(as string)
    declare sub RemoveName(as string)
    declare sub ClearNames
    declare function NameExists(as string) as integer
    declare function FindBase(as string) as PNameItem
    declare function Add(as string) as string
    declare sub Remove(as string)
    declare sub Clear
end type
