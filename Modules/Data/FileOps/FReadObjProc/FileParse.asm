proc GetElementsCounts uses edi esi ebx,\
        fileData, fileSize, fileMesh

        xor     eax, eax        ; verticesCount
        xor     edx, edx        ; trianglesCount
        xor     ebx, ebx        ; normalsCount
        xor     esi, esi        ; texturesCount
        mov     ecx, [fileSize]
        mov     edi, [fileData]


.CalcLoop:
        cmp     byte [edi], 'v'
        je      .IncVert
        cmp     byte [edi], 'f'
        jne     .SearchLF

        inc     edx
        jmp     .SearchLF
.IncVert:
        cmp     byte [edi + 1], ' '
        jne     .CheckT
        inc     eax
.CheckT:
        cmp     byte [edi + 1], 't'
        jne     .CheckN
        inc     esi
.CheckN:
        cmp     byte [edi + 1], 'n'
        jne     .SearchLF
        inc     ebx
.SearchLF:
        push    eax
        mov     eax, LF
        repne scasb
        pop     eax
        inc     ecx
        loop    .CalcLoop

        mov     edi, [fileMesh]
        mov     [edi + FileMesh.verticesCount], eax
        mov     [edi + FileMesh.normalsCount], ebx
        mov     [edi + FileMesh.texturesCount], esi
        mov     [edi + FileMesh.trianglesCount], edx
        ret
endp

proc ParseData uses ebx edi esi,\
        fileData, fileSize, fileMesh

        locals
                vertices        dd      ?
                normals         dd      ?
                textures        dd      ?
                vInd            dd      ?
                vnInd           dd      ?
                vtInd           dd      ?
        endl

        mov     ebx, [fileMesh]
        mov     eax, [ebx + FileMesh.vertices]
        mov     ecx, [ebx + FileMesh.normals]
        mov     edx, [ebx + FileMesh.textures]
        mov     esi, [ebx + FileMesh.vInd]
        mov     edi, [ebx + FileMesh.vnInd]
        mov     [vertices], eax
        mov     [normals], ecx
        mov     [textures], edx
        mov     [vInd], esi
        mov     [vnInd], edi
        mov     esi, [ebx + FileMesh.vtInd]
        mov     [vtInd], esi


        mov     ecx, [fileSize]
        mov     edi, [fileData]
        mov     eax, LF
.parseLoop:
        push     eax ecx edi
        cmp     byte [edi], 'v'
        je      .parseVertices
        cmp     byte [edi], 'f'
        jne     .Skip

.parseIndices:
        mov     esi, [vInd]
        mov     edx, [vtInd]
        mov     ebx, [vnInd]

        add     edi, 2
        sub     ecx, 2
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [esi], eax
        add     esi, 4
        mov     eax, '/'
        repne scasb
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [edx], eax
        add     edx, 4
        mov     eax, '/'
        repne scasb
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [ebx], eax
        add     ebx, 4
        mov     eax, ' '
        repne scasb

        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [esi], eax
        add     esi, 4
        mov     eax, '/'
        repne scasb
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [edx], eax
        add     edx, 4
        mov     eax, '/'
        repne scasb
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [ebx], eax
        add     ebx, 4
        mov     eax, ' '
        repne scasb

        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [esi], eax
        add     esi, 4
        mov     eax, '/'
        repne scasb
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [edx], eax
        add     edx, 4
        mov     eax, '/'
        repne scasb
        push    ecx edx
        stdcall StrToInt, edi
        pop     edx ecx
        mov     [ebx], eax
        add     ebx, 4

        mov     [vInd], esi
        mov     [vtInd], edx
        mov     [vnInd], ebx

        jmp     .Skip

.parseVertices:
        cmp     byte [edi + 1], ' '
        jne     .CheckN

        mov     esi, [vertices]
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
        mov     [vertices], esi

.CheckN:
        cmp     byte [edi + 1], 'n'
        jne     .CheckT

        mov     esi, [normals]
        add     edi, 3
        sub     ecx, 3
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
        mov     [normals], esi

.CheckT:
        cmp     byte [edi + 1], 't'
        jne     .Skip

        mov     esi, [textures]
        add     edi, 3
        sub     ecx, 3
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
        mov     [textures], esi

.Skip:
        pop     edi ecx eax
        repne scasb
        cmp     ecx, 0
        jne    .parseLoop
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