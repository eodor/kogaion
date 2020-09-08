#include once "kogaion_gui_ex.bi"

function QEnumerator.NameExists(v as string) as integer
    for i as integer=0 to NameCount-1
        if *Names[i]=v then return i
    next
    return -1
end function

sub QEnumerator.AddName(v as string)
    dim as integer ni=NameExists(v)
    if ni=-1 then
       NameCount+=1
       Names=reallocate(Names,sizeof(zstring ptr)*NameCount)
       Names[NameCount]=callocate(len(v)+1)
       *Names[NameCount]=v
    else
       MessageBox(Main,"Name already exists.",v,mb_taskmodal or mb_applmodal or mb_iconinformation)
    end if
end sub

sub QEnumerator.RemoveName(v as string)
    if v="" then exit sub
    dim as integer ni=NameExists(v)
    if ni>-1 then Names[ni]=0
end sub

sub QEnumerator.ClearNames
    for i as integer=0 to NameCount-1 step -1
        Names[i]=callocate(0)
        Names[i]=0
    next
    Names=0
    NameCount=0
end sub

function QEnumerator.FindBase(v as string) as PNameItem
    if v<>"" then
       for i as integer=0 to Count-1
           if Items[i]->BaseClass=v then
              Items[i]->id+=1
              return Items[i]
           end if
       next
    end if
    return 0
end function

function QEnumerator.Add(v as string) as string
     dim as string Nm=""
     if v="" then exit function
     dim as PNameItem it=FindBase(v)
     if it then
        it->ID+=1
        Nm=v & it->id
     else
        it=new EItem
        it->id+=1
        it->BaseClass=v
        Nm=it->BaseClass & it->id
     end if
     return Nm
end function

sub QEnumerator.Remove(v as string)
    dim as PNameItem it=FindBase(v)
    if it then Delete(it)
end sub

sub QEnumerator.Clear
    for i as integer=0 to Count-1 step -1
       delete(Items[i])
       items[i]=0
    next
    Items=callocate(0)
    Count=0
end sub