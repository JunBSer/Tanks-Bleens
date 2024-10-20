proc ReadModel uses ebx,\
        resultMesh, filePath
        locals
                hFile           dd      ?
                fileData        dd      ?
                fileSize        dd      ?
                facesCount      dd      ?
                verticesCount   dd      ?
                vertices        dd      ?
                indices         dd      ?
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

        stdcall    GetVerticesFacesCounts, [fileData], [fileSize]
        mov        [facesCount], edx
        mov        [verticesCount], eax

        xor        edx, edx
        mov        eax, sizeof.Vertex
        mov        ecx, [verticesCount]
        mul        ecx
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
        mov        [vertices], eax
        mov        [tempMesh + Mesh.vertices], eax

        xor        edx, edx
        mov        eax, 3
        mov        ecx, [facesCount]
        mul        ecx
        mov        [PLANE_VERTICES_COUNT], eax
        xor        edx, edx
        mov        ecx, 4
        mul        ecx
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
        mov        [indices], eax
        mov        [tempMesh + Mesh.indices], eax

        mov        edx, [facesCount]
        mov        [tempMesh + Mesh.trianglesCount], edx

        stdcall    ParseData, [fileData], [fileSize], [vertices], [indices]
        invoke     HeapFree, [hHeap], ebx, [fileData]
        stdcall    GenerateMesh, tempMesh, [resultMesh], true
        invoke     HeapFree, [hHeap], ebx, [vertices]
        invoke     HeapFree, [hHeap], ebx, [indices]
        ret
endp

proc ParseData uses ebx edi esi,\
        fileData, fileSize, vertices, indices

        mov     ecx, [fileSize]
        mov     edi, [fileData]
        mov     esi, [vertices]
        mov     edx, [indices]
        mov     eax, LF
.parseLoop:
        push     eax ecx edi
        cmp     byte [edi], 'v'
        jne     .Else
        cmp     byte [edi + 1], ' '
        je      .parseVertices
.Else:
        cmp     byte [edi], 'f'
        jne     .Skip

.parseIndices:
        add     edi, 2
        sub     ecx, 2
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [edx], eax
        add     edx, 4
        mov     eax, ' '
        repne scasb

        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [edx], eax
        add     edx, 4
        mov     eax, ' '
        repne scasb

        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [edx], eax
        add     edx, 4
        jmp     .Skip

.parseVertices:
        push    edx
        add     edi, 2
        sub     ecx, 2
        push    ecx
        stdcall StrToFloat, edi
        pop     ecx
        mov     [esi], eax
        add     esi, 4
        mov     eax, ' '
        repne scasb

        push    ecx
        stdcall StrToFloat, edi
        pop     ecx
        mov     [esi], eax
        add     esi, 4
        mov     eax, ' '
        repne scasb

        push    ecx
        stdcall StrToFloat, edi
        pop     ecx
        mov     [esi], eax
        add     esi, 4
        pop     edx
.Skip:
        pop     edi ecx eax
        repne scasb
        cmp     ecx, 0
        jne    .parseLoop
        ret
endp

proc GetVerticesFacesCounts uses edi esi,\
        fileData, fileSize

        xor     esi, esi        ; verticesCount
        xor     edx, edx        ; facesCount
        mov     ecx, [fileSize]
        mov     edi, [fileData]
        mov     eax, LF

.CalcLoop:
        cmp     byte [edi], 'v'
        jne     .Else
        cmp     byte [edi + 1], ' '
        je      .IncVert
.Else:
        cmp     byte [edi], 'f'
        jne     .SearchLF

        inc     edx
        jmp     .SearchLF
.IncVert:
        cmp     byte [edi + 1], ' '
        jne     .SearchLF
        inc     esi
.SearchLF:
        repne scasb
        inc     ecx
        loop    .CalcLoop

        xchg    esi, eax
        ret
endp

proc StrToFloat uses ebx edi esi,\
        strFLOAT
        locals
                _10     dd      10.0
                frac    dd      1.0
                result  dd      0.0
        endl
        mov     esi, [strFLOAT]
        fldz
        xor     eax, eax
        xor     edx, edx
        mov     ecx, 0          ; minus flag
        mov     edi, 10

        cmp     byte [esi], '-'
        jne     .check_plus
        mov     ecx, 1
        inc     esi

.check_plus:
        cmp     byte [esi], '+'
        jne     .parse_number
        inc     esi

.parse_number:

.next_digit:
        cmp     byte [esi], 0
        je      .end_conversion

        cmp     byte [esi], '.'
        je      .fraction_part

        sub     byte [esi], '0'
        cmp     byte [esi], 9
        ja      .end_conversion

        mul     edi
        movzx   ebx, byte [esi]
        add     eax, ebx
        inc     esi
        jmp     .next_digit

.fraction_part:
        mov     [result], eax
        fild    [result]
        faddp
        inc     esi
        mov     edx, 1
        mov     ebx, 1

.parse_fraction:
        cmp     byte [esi], 0
        je      .end_conversion

        sub     byte [esi], '0'
        cmp     byte [esi], 9
        ja      .end_conversion


        movzx   eax, byte [esi]
        push    eax
        fild    dword [esp]
        add     esp, 4
        fld     [frac]
        fdiv    [_10]
        fmul    st1, st0
        fstp    [frac]
        faddp

        inc     esi
        jmp     .parse_fraction

.end_conversion:
        cmp     ecx, 1
        jne     .skip
        fchs
.skip:
        add     byte [esi], '0'
        fstp    [result]
        mov     eax, [result]
        ret
endp

proc StrToInt uses ebx edi esi,\
        strINT
        mov     esi, [strINT]
        xor     eax, eax
        xor     edx, edx
        mov     ecx, 0          ; minus flag
        mov     edi, 10

        cmp     byte [esi], '-'
        jne     .check_plus
        mov     ecx, 1
        inc     esi

.check_plus:
        cmp     byte [esi], '+'
        jne     .parse_number
        inc     esi

.parse_number:

.next_digit:
        cmp     byte [esi], 0
        je      .end_conversion

        sub     byte [esi], '0'
        cmp     byte [esi], 9
        ja      .end_conversion

        mul     edi
        movzx   ebx, byte [esi]
        add     eax, ebx
        inc     esi
        jmp     .next_digit

.end_conversion:
        add     byte [esi], '0'
        cmp     ecx, 1
        jne     .Skip
        neg     eax
.Skip:
        ret
endp