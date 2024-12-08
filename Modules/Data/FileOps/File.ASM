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

proc File.ReadModel uses ebx esi edi,\
        filePath
        locals
                hFile           dd      ?
                fileData        dd      ?
                fileSize        dd      ?
                fileMesh        dd      ?
                tempFileMesh    dd      ?
        endl

        xor        ebx, ebx
        invoke     CreateFile, [filePath], GENERIC_READ, ebx, ebx, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, ebx
        mov        [hFile], eax
        invoke     GetFileSize, [hFile], ebx
        mov        [fileSize], eax
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
        mov        [fileData], eax
        invoke     ReadFile, [hFile], [fileData], [fileSize], ebx, ebx
        invoke     CloseHandle, [hFile]

        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, sizeof.FileMesh
        mov        [fileMesh], eax
        stdcall    GetElementsCounts, [fileData], [fileSize], [fileMesh]
        stdcall    FileMeshAlloc, [fileMesh]

        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, sizeof.TempFileMesh
        mov        [tempFileMesh], eax

        stdcall    ParseData, [fileData], [fileSize], [fileMesh]
        invoke     HeapFree, [hHeap], ebx, [fileData]

        mov        eax, [fileMesh]
        stdcall    TempFileMeshAlloc, [tempFileMesh], [eax + FileMesh.trianglesCount]
        stdcall    GenerateMesh, [fileMesh], [tempFileMesh]
        stdcall    FileMeshFree, [fileMesh]

        mov        esi, [tempFileMesh]

        mov        eax, esi
        ret
endp