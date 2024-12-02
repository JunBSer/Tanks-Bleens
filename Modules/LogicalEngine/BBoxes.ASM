proc    FindAABBStatic uses esi edi,\
        vertices, vertCnt

        locals
             pAABB      dd      ?

             minX       dd      ?
             minY       dd      ?
             minZ       dd      ?

             maxX       dd      ?
             maxY       dd      ?
             maxZ       dd      ?
        endl

        malloc  sizeof.AABB
        mov     [pAABB],eax

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
        ja      .ChangeMinX
.CmpWithMaxX:
        fld     [maxX] ; maxX currX
        fcomip  st, st1; currX
        jb      .ChangeMaxX
        fstp    st  ; -
.CmpWithMinY:
        fld     [esi + Vector3.y]; currY
        fld     [minY]  ; minY currY
        fcomip  st, st1 ; currY
        ja      .ChangeMinY
.CmpWithMaxY:
        fld     [maxY] ; maxY currY
        fcomip  st, st1; currY
        jb      .ChangeMaxY
        fstp    st
.CmpWithMinZ:
        fld     [esi + Vector3.z]; currZ
        fld     [minZ]  ; minZ currZ
        fcomip  st, st1 ; currZ
        ja      .ChangeMinZ
.CmpWithMaxZ:
        fld     [maxZ] ; maxZ currZ
        fcomip  st, st1; currZ
        jb      .ChangeMaxZ
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

        mov     esi, [pAABB]

        ;x
        mov     ecx, [minX]
        mov     [esi+AABB.minPoint],ecx
        ;y
        mov     ecx, [minY]
        mov     [esi+AABB.minPoint+4],ecx
        ;z
        mov     ecx, [minZ]
        mov     [esi+AABB.minPoint+8],ecx


        ;x
        mov     ecx, [maxX]
        mov     [esi+AABB.maxPoint],ecx
        ;y
        mov     ecx, [maxY]
        mov     [esi+AABB.maxPoint+4],ecx
        ;z
        mov     ecx, [maxZ]
        mov     [esi+AABB.maxPoint+8],ecx

        mov     eax, esi

     ret
endp



