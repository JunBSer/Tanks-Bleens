proc    FindAABBStatic uses esi edi,\
        vertices, vertCnt

        locals
             minPoint   dd      ?
             maxPoint   dd      ?

             minX       dd      ?
             minY       dd      ?
             minZ       dd      ?

             maxX       dd      ?
             maxY       dd      ?
             maxZ       dd      ?
        endl

        malloc  sizeof.Vector3
        mov     [minPoint], eax

        malloc  sizeof.Vector3
        mov     [maxPoint], eax

        mov     esi, [vertices]
        mov     ecx, [vertCnt]
        sub     ecx, 1

        ;init first (min.* = vertices[0].*)
        mov     eax, [esi+ Vector3.x]
        mov     [minX], eax
        mov     [maxX], eax

        mov     eax, [esi+ Vector3.y]
        mov     [minY], eax
        mov     [maxY], eax

        mov     eax, [esi+ Vector3.z]
        mov     [minZ], eax
        mov     [maxZ], eax

        add     esi, sizeof.Vector3
.FindKeyPoints:
        mov     eax, [esi + Vector3.x]
        mov     edx, [esi + Vector3.y]
        mov     edi, [esi + Vector3.z]

        fld     [esi + Vector3.x] ; currX
.CmpWithMinX:
        fld     [minX] ; minX  currX
        fcomip  st, st1 ;currX
        jb      .ChangeMinX
.CmpWithMaxX:
        fld     [maxX] ; maxX currX
        fcomip  st, st1; currX
        ja      .ChangeMaxX
        fstp    st  ; -
.CmpWithMinY:
        fld     [esi + Vector3.y]; currY
        fld     [minY]  ; minY currY
        fcomip  st, st1 ; currY
        jb      .ChangeMinY
.CmpWithMaxY:
        fld     [maxY] ; maxY currY
        fcomip  st, st1; currY
        ja      .ChangeMaxY
        fstp    st
.CmpWithMinZ:
        fld     [esi + Vector3.z]; currZ
        fld     [minZ]  ; minZ currZ
        fcomip  st, st1 ; currZ
        jb      .ChangeMinZ
.CmpWithMaxZ:
        fld     [maxZ] ; maxZ currZ
        fcomip  st, st1; currZ
        ja      .ChangeMaxZ
        fstp    st
        jmp     .Skip

.ChangeMinX:
        mov     [minX], eax
        jmp     .CmpWithMaxX
.ChangeMinY:
        mov     [minY], edx
        jmp     .CmpWithMaxY
.ChangeMinZ:
        mov     [minZ], edi
        jmp     .CmpWithMaxZ
.ChangeMaxX:
        mov     [maxX], eax
        fstp    st
        jmp     .CmpWithMinY
.ChangeMaxY:
        mov     [maxY], edx
        fstp    st
        jmp     .CmpWithMinZ
.ChangeMaxZ:
        mov     [maxZ], edi
        fstp    st
.Skip:
        add     esi, sizeof.Vector3

        sub     ecx, 1
        jnz     .FindKeyPoints


.FillPoints:
        mov     eax, [minPoint]
        mov     ecx, [minX]
        mov     [eax + Vector3.x], ecx
        mov     ecx, [minY]
        mov     [eax + Vector3.y], ecx
        mov     ecx, [minZ]
        mov     [eax + Vector3.z], ecx

        mov     edx, [maxPoint]
        mov     ecx, [maxX]
        mov     [edx + Vector3.x], ecx
        mov     ecx, [maxY]
        mov     [edx + Vector3.y], ecx
        mov     ecx, [maxZ]
        mov     [edx + Vector3.z], ecx
     ret
endp



