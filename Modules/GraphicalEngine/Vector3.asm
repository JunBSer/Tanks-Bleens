    proc Vector3.Length uses esi,\
     vector

        locals
                result  dd      ?
        endl

        mov     esi, [vector]

        fld     [esi + Vector3.x]
        fmul    [esi + Vector3.x]

        fld     [esi + Vector3.y]
        fmul    [esi + Vector3.y]

        fld     [esi + Vector3.z]
        fmul    [esi + Vector3.z]

        faddp
        faddp
        fsqrt
        fstp    [result]

        mov     eax, [result]

        ret
endp

proc Vector3.Distance uses esi edi,\
     v1, v2

        locals
                result  dd      ?
        endl

        mov     esi, [v1]
        mov     edi, [v2]

        fld     [esi + Vector3.x]
        fsub    [edi + Vector3.x]
        fmul    st0, st0

        fld     [esi + Vector3.y]
        fsub    [edi + Vector3.y]
        fmul    st0, st0

        fld     [esi + Vector3.z]
        fsub    [edi + Vector3.z]
        fmul    st0, st0

        faddp
        faddp
        fsqrt
        fstp    [result]

        mov     eax, [result]

        ret
endp

proc Vector3.Normalize uses edi,\
     vector

        locals
                l       dd      ?
        endl

        mov     edi, [vector]

        stdcall Vector3.Length, [vector]
        mov     [l], eax

        fld     [edi + Vector3.x]
        fdiv    [l]
        fstp    [edi + Vector3.x]

        fld     [edi + Vector3.y]
        fdiv    [l]
        fstp    [edi + Vector3.y]

        fld     [edi + Vector3.z]
        fdiv    [l]
        fstp    [edi + Vector3.z]

        ret
endp

proc Vector3.Cross uses esi edi ebx,\
     v1, v2, result

        mov     esi, [v1]
        mov     edi, [v2]
        mov     ebx, [result]

        fld     [esi + Vector3.y]
        fmul    [edi + Vector3.z]
        fld     [esi + Vector3.z]
        fmul    [edi + Vector3.y]
        fsubp
        fstp    [ebx + Vector3.x]

        fld     [esi + Vector3.z]
        fmul    [edi + Vector3.x]
        fld     [esi + Vector3.x]
        fmul    [edi + Vector3.z]
        fsubp
        fstp    [ebx + Vector3.y]

        fld     [esi + Vector3.x]
        fmul    [edi + Vector3.y]
        fld     [esi + Vector3.y]
        fmul    [edi + Vector3.x]
        fsubp
        fstp    [ebx + Vector3.z]

        ret
endp

proc Vector3.Copy uses esi edi,\
     dest, src

        mov     esi, [src]
        mov     edi, [dest]
        mov     ecx, 3
        rep     movsd

        ret
endp

proc Vector3.Add uses esi edi,\
     dest, src

        mov     esi, [src]
        mov     edi, [dest]

        fld      [edi + Vector3.x]
        fadd     [esi + Vector3.x]
        fstp    [edi + Vector3.x]

        fld      [edi + Vector3.y]
        fadd     [esi + Vector3.y]
        fstp    [edi + Vector3.y]

        fld      [edi + Vector3.z]
        fadd     [esi + Vector3.z]
        fstp    [edi + Vector3.z]

        ret
endp

proc Vector3.Sub uses esi edi,\
     dest, src

        mov     esi, [src]
        mov     edi, [dest]

        fld     [edi + Vector3.x]
        fsub    [esi + Vector3.x]
        fstp    [edi + Vector3.x]

        fld     [edi + Vector3.y]
        fsub    [esi + Vector3.y]
        fstp    [edi + Vector3.y]

        fld     [edi + Vector3.z]
        fsub    [esi + Vector3.z]
        fstp    [edi + Vector3.z]

        ret
endp

proc Vector3.Mul uses edi,\
     dest, value

        mov     edi, [dest]
        fld     [edi + Vector3.x]
        fmul    [value]
        fstp    [edi + Vector3.x]

        fld     [edi + Vector3.y]
        fmul    [value]
        fstp    [edi + Vector3.y]

        fld     [edi + Vector3.z]
        fmul    [value]
        fstp    [edi + Vector3.z]
        ret
endp

proc Vector3.Div uses edi,\
     dest, value

        mov     edi, [dest]
        fld     [edi + Vector3.x]
        fdiv    [value]
        fstp    [edi + Vector3.x]

        fld     [edi + Vector3.y]
        fdiv    [value]
        fstp    [edi + Vector3.y]

        fld     [edi + Vector3.z]
        fdiv    [value]
        fstp    [edi + Vector3.z]
        ret
endp

proc Vector3.Dot uses edi esi,\
     v1, v2

        locals
                result          GLfloat  ?
        endl

        mov     edi, [v1]
        mov     esi, [v2]

        fld     [edi + Vector3.x]
        fmul    [esi + Vector3.x]

        fld     [edi + Vector3.y]
        fmul    [esi + Vector3.y]

        fld     [edi + Vector3.z]
        fmul    [esi + Vector3.z]
        faddp
        faddp
        fstp    [result]
        mov     eax, [result]

        ret
endp

proc Vector3.MulMat4 uses esi edi ebx,\
     vector, matrix, resVector

        locals
                Temp dd ?
                source          Vector4
                result          Vector4         0.0, 0.0, 0.0, 0.0
        endl

        lea     eax, [source]
        stdcall Vector3.Copy, eax, [vector]
        mov     [source.w], 1.0

        lea     esi, [source]
        lea     edi, [result]
        mov     ebx, [matrix]

        xor     ecx, ecx          ; i
.Loop1:
                xor     edx, edx  ; j
        .Loop2:
                        fld     dword [esi + edx]
                        mov     eax, edx
                        shl     eax, 2
                        add     eax, ecx
                        fmul    dword [ebx + eax]
                        fadd    dword [edi + ecx]
                        fstp    dword [edi + ecx]
                add     edx, 4
                cmp     edx, 16
                jb      .Loop2
        add     ecx, 4
        cmp     ecx, 16
        jb      .Loop1

        lea     eax, [result]
        stdcall Vector3.Copy, [resVector], eax
  ret
endp
