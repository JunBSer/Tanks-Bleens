proc Collision.ConvertAABBtoOBB uses esi edi ebx,\
     aabb

        locals
                X       Vector3         1.0, 0.0, 0.0
                Y       Vector3         0.0, 1.0, 0.0
                Z       Vector3         0.0, 0.0, 1.0
                obb     dd              ?
        endl

        xor     ebx, ebx
        malloc  sizeof.OBB
        mov     [obb], eax
        mov     edi, eax;[obb]
        mov     esi, [aabb]

        lea     ebx, [edi + OBB.c]
        lea     eax, [esi + AABB.maxPoint]
        stdcall Vector3.Copy, ebx, eax
        lea     eax, [esi + AABB.minPoint]
        stdcall Vector3.Add, ebx, eax
        stdcall Vector3.Div, ebx, 2.0

        lea     ebx, [edi + OBB.h]
        lea     eax, [esi + AABB.maxPoint]
        stdcall Vector3.Copy, ebx, eax
        lea     eax, [esi + AABB.minPoint]
        stdcall Vector3.Sub, ebx, eax
        stdcall Vector3.Div, ebx, 2.0

        lea     ebx, [edi + OBB.u]
        lea     eax, [X]
        stdcall Vector3.Copy, ebx, eax

        lea     ebx, [edi + OBB.v]
        lea     eax, [Y]
        stdcall Vector3.Copy, ebx, eax

        lea     ebx, [edi + OBB.w]
        lea     eax, [Z]
        stdcall Vector3.Copy, ebx, eax

        mov     eax, [obb]
        ret
endp
