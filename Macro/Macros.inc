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
        mov     edi, adress
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