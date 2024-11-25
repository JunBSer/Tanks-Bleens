include         "../Data/Vector.inc"
include         "./Vector3.asm"

matrixM          Matrix4x4
matrixPr         Matrix4x4
matrixR          Matrix4x4
matrixT          Matrix4x4
matrixV          Matrix4x4
matrixS          Matrix4x4

proc Matrix.Projection uses edi,\
     aspect, fov, zNear, zFar

        locals
                matrix          Matrix4x4
                sine            dd              ?
                cotangent       dd              ?
                deltaZ          dd              ?
                radians         dd              ?
        endl

        lea     edi, [matrix]
        mov     ecx, 4 * 4
        xor     eax, eax
        rep     stosd

        lea     edi, [matrix]

        fld     [fov]
        fld1
        fld1
        faddp
        fdivp
        fdiv    [radian]
        fstp    [radians]

        fld     [zFar]
        fsub    [zNear]
        fstp    [deltaZ]

        fld     [radians]
        fsin
        fstp    [sine]

        fld     [radians]
        fcos
        fdiv    [sine]
        fstp    [cotangent]

        fld     [cotangent]
        fdiv    [aspect]
        fstp    [edi + Matrix4x4.m11]

        fld     [cotangent]
        fstp    [edi + Matrix4x4.m22]

        fld     [zFar]
        fadd    [zNear]
        fdiv    [deltaZ]
        fchs
        fstp    [edi + Matrix4x4.m33]

        fld1
        fchs
        fstp    [edi + Matrix4x4.m34]

        fld1
        fld1
        faddp
        fchs
        fmul    [zNear]
        fmul    [zFar]
        fdiv    [deltaZ]
        fstp    [edi + Matrix4x4.m43]

        invoke  glMultMatrixf, edi

        invoke  glGetFloatv, GL_PROJECTION_MATRIX, matrixPr
        ret
endp

proc Matrix.LookAtV uses esi edi ebx,\
     camera, target, up

        locals
                temp    dd              ?
                zAxis   Vector3         ;f
                xAxis   Vector3         ;s
                yAxis   Vector3         ;u
        endl

        mov     edi, matrixV
        mov     ecx, 4 * 4
        xor     eax, eax
        rep     stosd

        mov     esi, [camera]
        mov     edi, [target]
        mov     ebx, [up]

        fld     [edi + Vector3.x]
        fsub    [esi + Vector3.x]
        fstp    [zAxis.x]

        fld     [edi + Vector3.y]
        fsub    [esi + Vector3.y]
        fstp    [zAxis.y]

        fld     [edi + Vector3.z]
        fsub    [esi + Vector3.z]
        fstp    [zAxis.z]

        lea     eax, [zAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [zAxis]
        lea     ecx, [xAxis]
        stdcall Vector3.Cross, eax, ebx, ecx

        lea     eax, [xAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [xAxis]
        lea     ecx, [zAxis]
        lea     ebx, [yAxis]
        stdcall Vector3.Cross, eax, ecx, ebx

        lea     esi, [xAxis]
        mov     edi, matrixV
        fld     [esi + Vector3.x]
        fstp    [edi + Matrix4x4.m11]
        fld     [esi + Vector3.y]
        fstp    [edi + Matrix4x4.m21]
        fld     [esi + Vector3.z]
        fstp    [edi + Matrix4x4.m31]

        fld     [ebx + Vector3.x]
        fstp    [edi + Matrix4x4.m12]
        fld     [ebx + Vector3.y]
        fstp    [edi + Matrix4x4.m22]
        fld     [ebx + Vector3.z]
        fstp    [edi + Matrix4x4.m32]

        lea     esi, [zAxis]
        fld     [esi + Vector3.x]
        fchs
        fstp    [edi + Matrix4x4.m13]
        fld     [esi + Vector3.y]
        fchs
        fstp    [edi + Matrix4x4.m23]
        fld     [esi + Vector3.z]
        fchs
        fstp    [edi + Matrix4x4.m33]

        fld1
        fstp    [edi + Matrix4x4.m44]

        ; Translate
        lea     eax, [xAxis]
        mov     edx, [camera]
        stdcall Vector3.Dot, eax, edx
        mov     [temp], eax
        fld     dword [temp]
        fchs
        fstp    [edi + Matrix4x4.m41]

        lea     eax, [yAxis]
        mov     edx, [camera]
        stdcall Vector3.Dot, eax, edx
         mov     [temp], eax
        fld     dword [temp]
        fchs
        fstp    [edi + Matrix4x4.m42]

        lea     eax, [zAxis]
        mov     edx, [camera]
        stdcall Vector3.Dot, eax, edx
        mov     [temp], eax
        fld     dword [temp]
        fstp    [edi + Matrix4x4.m43]

        ret
endp

proc Matrix.LookAt uses esi edi ebx,\
     camera, target, up

        locals
                temp    dd              ?
                matrix  Matrix4x4
                zAxis   Vector3
                xAxis   Vector3
                yAxis   Vector3
        endl

        lea     edi, [matrix]
        mov     ecx, 4 * 4
        xor     eax, eax
        rep     stosd

        mov     esi, [camera]
        mov     edi, [target]
        mov     ebx, [up]

        fld     [edi + Vector3.x]
        fsub    [esi + Vector3.x]
        fstp    [zAxis.x]

        fld     [edi + Vector3.y]
        fsub    [esi + Vector3.y]
        fstp    [zAxis.y]

        fld     [edi + Vector3.z]
        fsub    [esi + Vector3.z]
        fstp    [zAxis.z]

        lea     eax, [zAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [zAxis]
        lea     ecx, [xAxis]
        stdcall Vector3.Cross, eax, ebx, ecx

        lea     eax, [xAxis]
        stdcall Vector3.Normalize, eax

        lea     eax, [xAxis]
        lea     ecx, [zAxis]
        lea     ebx, [yAxis]
        stdcall Vector3.Cross, eax, ecx, ebx

        lea     esi, [xAxis]
        lea     edi, [matrix]
        fld     [esi + Vector3.x]
        fstp    [edi + Matrix4x4.m11]
        fld     [esi + Vector3.y]
        fstp    [edi + Matrix4x4.m21]
        fld     [esi + Vector3.z]
        fstp    [edi + Matrix4x4.m31]

        fld     [ebx + Vector3.x]
        fstp    [edi + Matrix4x4.m12]
        fld     [ebx + Vector3.y]
        fstp    [edi + Matrix4x4.m22]
        fld     [ebx + Vector3.z]
        fstp    [edi + Matrix4x4.m32]

        lea     esi, [zAxis]
        fld     [esi + Vector3.x]
        fchs
        fstp    [edi + Matrix4x4.m13]
        fld     [esi + Vector3.y]
        fchs
        fstp    [edi + Matrix4x4.m23]
        fld     [esi + Vector3.z]
        fchs
        fstp    [edi + Matrix4x4.m33]

        fld1
        fstp    [edi + Matrix4x4.m44]

        invoke  glMultMatrixf, edi

        mov     esi, [camera]
        fld     [esi + Vector3.z]
        fchs
        fstp    [temp]
        push    [temp]
        fld     [esi + Vector3.y]
        fchs
        fstp    [temp]
        push    [temp]
        fld     [esi + Vector3.x]
        fchs
        fstp    [temp]
        push    [temp]
        invoke  glTranslatef

        invoke  glGetFloatv, GL_MODELVIEW_MATRIX, matrixX

        ret
endp

proc Matrix.LoadIdentity uses edi,\
     matrix

        mov     edi, [matrix]

        mov     [edi + Matrix4x4.m11], 1.0
        mov     [edi + Matrix4x4.m12], 0.0
        mov     [edi + Matrix4x4.m13], 0.0
        mov     [edi + Matrix4x4.m14], 0.0

        mov     [edi + Matrix4x4.m21], 0.0
        mov     [edi + Matrix4x4.m22], 1.0
        mov     [edi + Matrix4x4.m23], 0.0
        mov     [edi + Matrix4x4.m24], 0.0

        mov     [edi + Matrix4x4.m31], 0.0
        mov     [edi + Matrix4x4.m32], 0.0
        mov     [edi + Matrix4x4.m33], 1.0
        mov     [edi + Matrix4x4.m34], 0.0

        mov     [edi + Matrix4x4.m41], 0.0
        mov     [edi + Matrix4x4.m42], 0.0
        mov     [edi + Matrix4x4.m43], 0.0
        mov     [edi + Matrix4x4.m44], 1.0

        ret
endp

proc Matrix.Copy uses edi esi,\
     matDest, matSrc

        mov     ecx, 16
        mov     edi, [matDest]
        mov     esi, [matSrc]
        rep     movsd
        ret
endp

proc Matrix.Multiply uses esi edi ebx,\
     matDest, matSrc

        locals
                matTemp         Matrix4x4
        endl

        mov     edi, [matDest]
        mov     esi, [matSrc]

        mov     ecx, 0
.MulLoop0:
        mov     ebx, 0

.MulLoop1:
        push    edi

        ;matDest[i][0] * matSrc[0][j]
        xor     edx, edx
        mov     eax, 4 * 4
        mul     ecx
        add     edi, eax
        push    edi
        ;add     edi, 0 * 4
        fld     dword [edi]

        push    esi
        ;add     esi, 0 * 4 * 4
        xor     edx, edx
        mov     eax, 4
        mul     ebx
        add     esi, eax
        fmul    dword [esi]
        pop     esi

        ;matDest[i][1] * matSrc[1][j]
        mov     edi, [esp]
        add     edi, 1 * 4
        fld     dword [edi]

        push    esi
        xor     edx, edx
        add     esi, 1 * 4 * 4
        mov     eax, 4
        mul     ebx
        add     esi, eax
        fmul    dword [esi]
        pop     esi

        ;matDest[i][2] * matSrc[2][j]
        mov     edi, [esp]
        add     edi, 2 * 4
        fld     dword [edi]

        push    esi
        add     esi, 2 * 4 * 4
        xor     edx, edx
        mov     eax, 4
        mul     ebx
        add     esi, eax
        fmul    dword [esi]
        pop     esi

        ;matDest[i][3] * matSrc[3][j]
        pop     edi
        add     edi, 3 * 4
        fld     dword [edi]

        push    esi
        add     esi, 3 * 4 * 4
        xor     edx, edx
        mov     eax, 4
        mul     ebx
        add     esi, eax
        fmul    dword [esi]
        pop     esi

        ;matTemp[i][j] = matDest[i][0] * matSrc[0][i] + ... + matDest[i][3] * matSrc[3][j]
        faddp
        faddp
        faddp
        lea     edi, [matTemp]
        xor     edx, edx
        mov     eax, 4 * 4
        mul     ecx
        add     edi, eax
        xor     edx, edx
        mov     eax, 4
        mul     ebx
        add     edi, eax
        fstp    dword [edi]


        pop     edi
        inc     ebx
        cmp     ebx, 4
        jne     .MulLoop1

        inc     ecx
        cmp     ecx, 4
        jne     .MulLoop0

        lea     eax, [matTemp]
        stdcall Matrix.Copy, [matDest], eax
        ret
endp

proc Matrix.Rotate uses esi edi ebx,\
     angle, x, y, z

        locals
                c        dd      ?
                s        dd      ?
                revC     dd      ?
                PIDegree dd      180.0
        endl

        lea     eax, [x]
        stdcall Vector3.Normalize, eax

        fld     [angle]
        fldpi
        fdiv    [PIDegree]
        fmulp
        fsincos
        fstp    [c]
        fstp    [s]
        fld1
        fsub    [c]
        fstp    [revC]

        ;mov     eax, [axis + Vector3.x]
        ;mov     [x], eax
        ;mov     eax, [axis + Vector3.y]
        ;mov     [y], eax
        ;mov     eax, [axis + Vector3.z]
        ;mov     [z], eax

        ; 1st
        fld     [c]
        fld     [x]
        fmul    [x]
        fmul    [revC]
        faddp
        fstp    [matrixR + Matrix4x4.m11]

        fld     [x]
        fmul    [y]
        fmul    [revC]
        fld     [z]
        fmul    [s]
        fsubp
        fstp    [matrixR + Matrix4x4.m12]

        fld     [x]
        fmul    [z]
        fmul    [revC]
        fld     [y]
        fmul    [s]
        faddp
        fstp    [matrixR + Matrix4x4.m13]

        mov     dword [matrixR + Matrix4x4.m14], 0.0

        ; 2nd
        fld     [x]
        fmul    [y]
        fmul    [revC]
        fld     [z]
        fmul    [s]
        faddp
        fstp    [matrixR + Matrix4x4.m21]

        fld     [c]
        fld     [y]
        fmul    [y]
        fmul    [revC]
        faddp
        fstp    [matrixR + Matrix4x4.m22]

        fld     [z]
        fmul    [y]
        fmul    [revC]
        fld     [x]
        fmul    [s]
        fsubp
        fstp    [matrixR + Matrix4x4.m23]

        mov     dword [matrixR + Matrix4x4.m24], 0.0

        ; 3rd
        fld     [x]
        fmul    [z]
        fmul    [revC]
        fld     [y]
        fmul    [s]
        fsubp
        fstp    [matrixR + Matrix4x4.m31]

        fld     [z]
        fmul    [y]
        fmul    [revC]
        fld     [x]
        fmul    [s]
        faddp
        fstp    [matrixR + Matrix4x4.m32]

        fld     [c]
        fld     [z]
        fmul    [z]
        fmul    [revC]
        faddp
        fstp    [matrixR + Matrix4x4.m33]

        mov     dword [matrixR + Matrix4x4.m34], 0.0

        ; 4th
        mov     dword [matrixR + Matrix4x4.m41], 0.0
        mov     dword [matrixR + Matrix4x4.m42], 0.0
        mov     dword [matrixR + Matrix4x4.m43], 0.0
        mov     dword [matrixR + Matrix4x4.m44], 1.0

        ret
endp

proc Matrix.Translate uses esi,\
     translation

        stdcall Matrix.LoadIdentity, matrixT
        mov     esi, [translation]

        mov     eax, [esi + Vector3.x]
        mov     [matrixT + Matrix4x4.m41], eax

        mov     eax, [esi + Vector3.y]
        mov     [matrixT + Matrix4x4.m42], eax

        mov     eax, [esi + Vector3.z]
        mov     [matrixT + Matrix4x4.m43], eax
        ret
endp

proc Matrix.Scale uses esi,\
     scale

        stdcall Matrix.LoadIdentity, matrixT
        mov     esi, [scale]

        mov     eax, [translation + Vector3.x]
        mov     [matrixS + Matrix4x4.m11], eax

        mov     eax, [translation + Vector3.y]
        mov     [matrixS + Matrix4x4.m22], eax

        mov     eax, [translation + Vector3.z]
        mov     [matrixS + Matrix4x4.m33], eax
        ret
endp