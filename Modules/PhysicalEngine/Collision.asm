include         "./Collision.inc"
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

proc Collision.ProjectOBB uses edi esi ebx,\
     obb, axis, min, max

        locals
                centerProj      GLfloat         ?
                r               GLfloat         ?
        endl

        mov     esi, [obb]
        mov     edi, [axis]
        lea     ebx, [esi + OBB.h]
        lea     eax, [esi + OBB.c]
        stdcall Vector3.Dot, eax, edi
        mov     [centerProj], eax

        lea     eax, [esi + OBB.u]
        stdcall Vector3.Dot, eax, edi
        push    eax
        fld     dword [esp]
        fmul    [ebx + Vector3.x]
        fabs

        lea     eax, [esi + OBB.v]
        stdcall Vector3.Dot, eax, edi
        push    eax
        fld     dword [esp]
        fmul    [ebx + Vector3.y]
        fabs

        lea     eax, [esi + OBB.w]
        stdcall Vector3.Dot, eax, edi
        push    eax
        fld     dword [esp]
        fmul    [ebx + Vector3.z]
        fabs
        add     esp, 3 * 4

        faddp
        faddp
        fstp    [r]

        fld     [centerProj]
        fld     [r]
        fsubr    st0, st1
        mov     eax, [min]
        fstp    dword [eax]

        fadd    [r]
        mov     eax, [max]
        fstp    dword [eax]

        ret
endp

proc Collision.Overlap,\
     min1, max1, min2, max2

        xor     eax, eax

        fld     dword [max2]
        fld     dword [min1]
        fcomip   st0, st1
        fstp    st0
        jbe     .Check2
        mov     eax, 1
        jmp     .Return
.Check2:

        fld     dword [max1]
        fld     dword [min2]
        fcomip  st0, st1
        fstp    st0
        jbe     .Return
        mov     eax, 1

.Return:
        xor     eax, 1
        ret
endp

proc Collision.Check uses edi esi ebx,\
     obb1, obb2

        locals
                min1            GLfloat         ?
                max1            GLfloat         ?
                min2            GLfloat         ?
                max2            GLfloat         ?
                length          GLfloat         ?
                e               GLfloat         0.000001
                axis            Vector3
        endl

        mov     esi, [obb1]
        mov     edi, [obb2]
        stdcall Collision.InitAxes, esi, edi

        xor     ecx, ecx
        ;mov     esi, axes
.Loop:
        push    ecx
        lea     eax, [axes + ecx]
        lea     ebx, [axis]
        stdcall Vector3.Copy, ebx, eax

        stdcall Vector3.Length, ebx
        mov     [length], eax
        fld     dword [length]
        fld     dword [e]
        fcomip  st0, st1
        fstp    st0
        jae     .Continue

        stdcall Vector3.Div, ebx, [length]
        lea     eax, [min1]
        lea     edx, [max1]
        stdcall Collision.ProjectOBB, esi, ebx, eax, edx
        lea     eax, [min2]
        lea     edx, [max2]
        stdcall Collision.ProjectOBB, edi, ebx, eax, edx

        stdcall Collision.Overlap, [min1], [max1], [min2], [max2]
        cmp     eax, 0
        je      .PopRet
.Continue:
        pop     ecx
        add     ecx, sizeof.Vector3
        cmp     ecx, 15 * sizeof.Vector3
        jb      .Loop

        mov     eax, 1
        jmp     .Return
.PopRet:
        pop     ecx
.Return:
        ret
endp

proc Collision.InitAxes uses edi esi ebx,\
     obb1, obb2

        mov     esi, [obb1]
        mov     edi, [obb2]

        lea     ebx, [axes.a1]
        lea     edx, [esi + OBB.u]
        stdcall Vector3.Copy, ebx, edx
        add     ebx, sizeof.Vector3
        lea     edx, [esi + OBB.v]
        stdcall Vector3.Copy, ebx, edx
        add     ebx, sizeof.Vector3
        lea     edx, [esi + OBB.w]
        stdcall Vector3.Copy, ebx, edx
        add     ebx, sizeof.Vector3
        lea     edx, [edi + OBB.u]
        stdcall Vector3.Copy, ebx, edx
        add     ebx, sizeof.Vector3
        lea     edx, [edi + OBB.v]
        stdcall Vector3.Copy, ebx, edx
        add     ebx, sizeof.Vector3
        lea     edx, [edi + OBB.w]
        stdcall Vector3.Copy, ebx, edx

        xor     ecx, ecx                        ; i
        mov     esi, axes
        mov     edi, axes + 6 * sizeof.Vector3         ; index
.loop1:
                mov     ebx, 3 * sizeof.Vector3 ; j
        .loop2:
                        push    ecx
                        lea     eax, [esi + ecx]
                        lea     edx, [esi + ebx]
                        stdcall Vector3.Cross, eax, edx, edi

                        add     edi, sizeof.Vector3
                        pop     ecx
                add     ebx, sizeof.Vector3
                cmp     ebx, 6 * sizeof.Vector3
                jb      .loop2
        add     ecx, sizeof.Vector3
        cmp     ecx, 3 * sizeof.Vector3
        jb      .loop1
        ret
endp

proc Collision.OBB.Setup uses edi esi ebx,\
     tank
        locals
                tankSize        GLfloat         0.08

        endl

        mov     esi, [tank]
        mov     edi, [esi + Tank.pTurretObj]
        mov     ebx, [edi + Object.pOBB]
        fld     dword [ebx + OBB.h + Vector3.y]  ; load half y size from turret

        mov     edi, [esi + Tank.pBodyObj]
        mov     ebx, [edi + Object.pOBB]
        fld     dword [ebx + OBB.h + Vector3.y]  ; load half y size from body
        fadd    st0, st1
        fstp    dword [ebx + OBB.h + Vector3.y]

        fadd    dword [ebx + OBB.c + Vector3.y]
        fstp    dword [ebx + OBB.c + Vector3.y]

        lea     eax, [ebx + OBB.h]
        stdcall Vector3.Mul, eax, [tankSize]
        ret
endp

proc Collision.OBB.Update uses esi edi ebx,\
     obb, matrix

        mov     edi, [obb]
        mov     esi, [matrix]
        lea     ebx, [edi + OBB.c]
        stdcall Vector3.MulMat4, ebx, 1.0, esi, ebx
        lea     ebx, [edi + OBB.u]
        stdcall Vector3.MulMat4, ebx, 0.0, esi, ebx
        stdcall Vector3.Normalize, ebx
        lea     ebx, [edi + OBB.v]
        stdcall Vector3.MulMat4, ebx, 0.0, esi, ebx
        stdcall Vector3.Normalize, ebx
        lea     ebx, [edi + OBB.w]
        stdcall Vector3.MulMat4, ebx, 0.0, esi, ebx
        stdcall Vector3.Normalize, ebx
        ret
endp

proc Collision.OBB.Copy uses edi esi,\
     dest, src

        mov     esi, [src]
        mov     edi, [dest]
        mov     ecx, 5 * 3
        rep     movsd

        ret
endp

proc Collision.SetupModelMatrix uses esi edi ebx,\
     tank, matrixC

        locals
                newObb          OBB
                matrixTemp      Matrix4x4
        endl

        mov     eax, [tank]
        mov     esi, [eax + Tank.pBodyObj]        ; esi <- pBodyObj
        lea     edi, [newObb]
        stdcall Collision.OBB.Copy, edi, [esi + Object.pOBB]

        lea     ebx, [matrixTemp]
        mov     eax, [tank]
        stdcall Matrix.Multiply, [matrixC], [eax + Tank.pModelMatrix], ebx

        stdcall Collision.OBB.Update, edi, ebx

        mov     ecx, [DinObjCnt]
        mov     ebx, [DinObjects]          ; ebx <- array of objects pointer
        fld     [DISTANCE_FOR_CHECK_COLLISION]
.Collision.Loop:
        mov     eax, ecx                ; index of object
        dec     eax
        shl     eax, 2                  ; offset of object in byte
        mov     edx, [ebx + eax]

        push    ecx edx
        stdcall Vector3.Distance, edi, [edx + Object.pOBB]
        pop     edx ecx
        push    eax
        fld     dword [esp]
        add     esp, 4
        fcomip  st0, st1
        ja      .SkipCheck

        push    ecx
        stdcall Collision.Check, edi, [edx + Object.pOBB]
        pop     ecx
        cmp     eax, 1
        je      .Return1
.SkipCheck:
        loop    .Collision.Loop

        ;stdcall Collision.OBB.Copy, [esi + Object.pOBB], edi
        lea     ebx, [matrixTemp]
        mov     eax, [tank]
        stdcall Matrix.Copy, [eax + Tank.pModelMatrix], ebx
        xor     eax, eax
        jmp     .Return
.Return1:
        ;stdcall Matrix.LoadIdentity, [matrix]
        mov      eax, 1
.Return:
        fstp    st0
        ret
endp