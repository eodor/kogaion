
#include once "kogaion_gui_menus.bi"

/' QMenuItem '/
sub QMenuItem.Create
end sub

sub QMenuItem.Free
end sub

operator QMenuItem.cast as any ptr
    return @this
end operator

constructor  QMenuItem
end constructor

/' QMainMenu '/
function QMainMenu.Register as integer
    dim as wndclassex wcls
    wcls.cbsize=sizeof(wcls)
    wcls.lpszclassname=@"QMainMenu"
    wcls.lpfnwndproc=@DefWindowProc
    wcls.hinstance=0
    wcls.cbwndextra+=4
    wcls.cbclsextra+=4
    return RegisterClassEx(@wcls)
end function

sub QMainMenu.Create
    Free
end sub

sub QMainMenu.Free
    if isMenu(this.fHandle)then
       DestroyMenu(this.fHandle)
       this.fHandle=0
    end if   
end sub

operator QMainMenu.cast as any ptr
    return @this
end operator

constructor QMainMenu
end constructor

/' QPopupMenu '/
function QPopupMenu.Register as integer
    dim as wndclassex wcls
    wcls.cbsize=sizeof(wcls)
    wcls.lpszclassname=@"QPopupMenu"
    wcls.lpfnwndproc=@DefWindowProc
    wcls.hinstance=0
    wcls.cbwndextra+=4
    wcls.cbclsextra+=4
    return RegisterClassEx(@wcls)
end function

sub QPopupMenu.Create
    this.fHandle=CreatePopupMenu
end sub

sub QPopupMenu.Free
    if isMenu(this.fHandle)then
       DestroyMenu(this.fHandle)
       this.fHandle=0
    end if   
end sub

operator QPopupMenu.cast as any ptr
    return @this
end operator

constructor QPopupMenu
end constructor