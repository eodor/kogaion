#include once "kogaion_gui_sysutils.bi"

function ExtractFileName(v as string) as string
    if v="" then return v
    dim as integer x
    for i as integer=1 to len(v)
        if chr(v[i])="/" or chr(v[i])="\" then
           x=i+1
        end if
    next
    return mid(v,x+1,len(v))
end function

function ExtractFilePath(v as string) as string
    if v="" then return v
    dim as integer x
    for i as integer=1 to len(v)
        if chr(v[i])="/" or chr(v[i])="\" then
           x=i+1
        end if
    next
    return mid(v,1,x)
end function

function ExtractFileExt(v as string) as string
    if v="" then return v
    dim as integer x
    for i as integer=1 to len(v)
        if chr(v[i])="." then
           x=i+1
        end if
    next
    return mid(v,x,len(v))
end function

function ChangeFileExt(v as string,e as string) as string
    if v="" then return v
    dim as integer x
    for i as integer=1 to len(v)
        if chr(v[i])="." then
           x=i+1
        end if
    next
    return mid(v,1,x-1)+e
end function

function ChangeFilePath(v as string,p as string) as string
    if v="" then return v
    dim as integer x
    for i as integer=1 to len(v)
        if chr(v[i])="/" or chr(v[i])="\" then
           x=i+1
        end if
    next
    return p+mid(v,x+1,len(v))
end function