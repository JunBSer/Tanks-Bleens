proc File.LoadContent uses edi,\
     fileName, stOffset, HWSizes

        locals
                hFile              dd      ?
                length             dd      ?
                read               dd      ?
                pBuffer            dd      ?
                pHeaderBuf      dd      ?
        endl

        invoke  CreateFile, [fileName], GENERIC_READ, ebx, ebx, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, ebx
        mov     [hFile], eax

        invoke  GetFileSize, [hFile], ebx
        inc     eax

        mov     [length], eax

        mov     eax,[stOffset]
        sub     [length],eax


        invoke  HeapAlloc, [hHeap], 8, [length]
        mov     [pBuffer], eax

        invoke  SetFilePointer, [hFile], [stOffset], 0, FILE_BEGIN

        ;cmp     [HWSizes], ebx
        ;je      .Next
        ;sub     [length],1
        .Next:
        lea     edi, [read]
        invoke  ReadFile, [hFile], [pBuffer], [length], edi, ebx

.ReadSizes:
        cmp     [HWSizes], ebx
        je      .SkipSetting

        malloc  8
        mov     [pHeaderBuf],eax

        invoke  SetFilePointer, [hFile], 18, 0, FILE_BEGIN
        invoke  ReadFile, [hFile], [pHeaderBuf], 8, edi, ebx

        mov     edi, [pHeaderBuf]
        mov     ecx, [edi]
        mov     edx, [edi + 4]

        mov     edi, [HWSizes]
        xchg    [edi+Vector2.u], ecx
        xchg    [edi+Vector2.v], edx

        free    [pHeaderBuf]
.SkipSetting:

        invoke  CloseHandle, [hFile]

        mov     eax, [pBuffer]
        mov     ecx, [length]

        ret
endp