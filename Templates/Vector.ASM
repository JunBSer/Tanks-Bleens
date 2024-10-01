proc Vector3.Normalize uses edi,\
     vector

        locals
                l       dd      ?
        endl

        mov     edi, [vector]

        fld     [edi + Vector3.x]
        fmul    [edi + Vector3.x]

        fld     [edi + Vector3.y]
        fmul    [edi + Vector3.y]

        fld     [edi + Vector3.z]
        fmul    [edi + Vector3.z]

        faddp
        faddp
        fsqrt
        fstp    [l]

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

        locals
                temp    dd      ?
        endl

        mov     esi, [v1]
        mov     edi, [v2]
        mov     ebx, [result]

        fld     [esi + Vector3.z]
        fmul    [edi + Vector3.y]
        fstp    [temp]
        fld     [esi + Vector3.y]
        fmul    [edi + Vector3.z]
        fsub    [temp]
        fstp    [ebx + Vector3.x]

        fld     [esi + Vector3.x]
        fmul    [edi + Vector3.z]
        fstp    [temp]
        fld     [esi + Vector3.z]
        fmul    [edi + Vector3.x]
        fsub    [temp]
        fstp    [ebx + Vector3.y]

        fld     [esi + Vector3.y]
        fmul    [edi + Vector3.x]
        fstp    [temp]
        fld     [esi + Vector3.x]
        fmul    [edi + Vector3.y]
        fsub    [temp]
        fstp    [ebx + Vector3.z]

        ret
endp