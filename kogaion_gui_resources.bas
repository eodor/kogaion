#include once "kogaion_gui_resources.bi"

sub ExtractResourceToFile(Module as HMODULE, ResName as string, ResType as string , ResFile as string)
   dim as integer i, Size
   dim as any ptr hRes, hGlb
   dim A() as byte
   dim as any ptr hLock
   hRes = findResource(Module,ResName,ResType)
   if hRes then
      hGlb = LoadResource(Module,hRes)
      if hGlb then
         hLock = LockResource(hRes)
         if hLock then
            size = SizeofResource(Module, hRes)
            redim preserve A(size)
            CopyMemory(@A(0), hLock, Size)
            if Open(ResFile for binary access write as #1)=0  then
               for i as integer = 0 to ubound(A)
                   put #1,,A(i)
               next
               Close(1)
            end if
         end if
      end if
   end if
end sub