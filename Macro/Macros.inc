macro switch value
{
        mov     eax, value
}

macro case label, [value]
{
        cmp     eax, value
        je      label
}

macro memset address, value, count
{
        mov     edi, address
        mov     eax, value
        mov     ecx, count
        rep     stosb
}

macro memcpy dest, src, count
{
        mov     esi, src
        mov     edi, dest
        mov     ecx, count
        rep     movsb
}

macro malloc size
{
        invoke  HeapAlloc, [hHeap], ebx, size
}

macro mallocCnt count, size
{
        invoke  HeapAlloc, [hHeap], 8, count * size
}

macro free address 
{
        invoke  HeapFree, [hHeap], ebx, address 
}

macro len strAddr 
{
        mov     ecx, 256
        mov     edi,strAddr
        mov     al,bl
        repne   scasb
        sub     ecx,255
        neg     ecx
}

macro minf firstVal, secondVal, Res
{
        local   ..Return
        fld     dword [firstVal]
        fld     dword [secondVal]
        fcomi   st, st1
        jb      @f

        fstp    dword [secondVal]

        jmp     ..Return

@@:    
        fxch
        fstp    dword [firstVal]
        
..Return:
        fstp    dword [Res]
}

macro maxf firstVal, secondVal, Res
{
        local   ..Return
        fld     dword [firstVal]      
        fld     dword [secondVal]     
        fcomi   st, st1
        jb      @f

        fxch
        fstp    dword [firstVal]

        jmp     ..Return

@@:    
        fstp    dword [secondVal]
        
..Return:
        fstp    dword [Res]
}