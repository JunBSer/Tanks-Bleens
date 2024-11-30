include         "./Vector3.asm"


matrixPr         Matrix4x4
matrixV          Matrix4x4

matrixR          Matrix4x4
matrixT          Matrix4x4
matrixS          Matrix4x4
matrixM          Matrix4x4

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
        mov     ecx, 4 * 4
        xor     eax, eax
        rep     stosd

        mov     edi, [matrix]
        mov     eax, 1.0
        mov     [edi + Matrix4x4.m11], eax
        mov     [edi + Matrix4x4.m22], eax
        mov     [edi + Matrix4x4.m33], eax
        mov     [edi + Matrix4x4.m44], eax

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

proc Matrix.Multiply uses ebx esi edi,\
     Matrix1, Matrix2, ResMatrix
   locals
     Temp dd ?
   endl

   mov ebx, 0
   .Loop_A1:   ;(i)
      mov esi, 0
     .Loop_A2:   ;(j)
        mov edi, 0
        mov [Temp], 0.0
        .Loop_A3:    ;(k)
           push ebx
           add ebx, [Matrix1]
           fld dword [ebx + edi]
           mov ebx, edi
           shl ebx, 2
           add ebx, [Matrix2]
           fld dword [ebx + esi]
           fmulp
           fadd dword [Temp]
           fstp dword [Temp]
           pop ebx
        add edi, 4
        cmp edi, 16
        jnz .Loop_A3
        mov eax, [Temp]
        push ebx
        add ebx, [ResMatrix]
        mov [ebx + esi], eax
        pop ebx
      add esi, 4
      cmp esi, 16
      jnz .Loop_A2
   add ebx, 16
   cmp ebx, 16 * 4
   jnz .Loop_A1
   
  ret
endp

proc Matrix.Rotate uses esi edi ebx,\
     matrix,angle, x, y, z

        locals
                c        dd      ?
                s        dd      ?
                revC     dd      ?
                PIDegree dd      180.0
        endl

        mov     esi, [matrix]

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
        fstp    [esi + Matrix4x4.m11]

        fld     [x]
        fmul    [y]
        fmul    [revC]
        fld     [z]
        fmul    [s]
        fsubp
        fstp    [esi + Matrix4x4.m12]

        fld     [x]
        fmul    [z]
        fmul    [revC]
        fld     [y]
        fmul    [s]
        faddp
        fstp    [esi + Matrix4x4.m13]

        mov     dword [esi + Matrix4x4.m14], 0.0

        ; 2nd
        fld     [x]
        fmul    [y]
        fmul    [revC]
        fld     [z]
        fmul    [s]
        faddp
        fstp    [esi + Matrix4x4.m21]

        fld     [c]
        fld     [y]
        fmul    [y]
        fmul    [revC]
        faddp
        fstp    [esi + Matrix4x4.m22]

        fld     [z]
        fmul    [y]
        fmul    [revC]
        fld     [x]
        fmul    [s]
        fsubp
        fstp    [esi + Matrix4x4.m23]

        mov     dword [esi + Matrix4x4.m24], 0.0

        ; 3rd
        fld     [x]
        fmul    [z]
        fmul    [revC]
        fld     [y]
        fmul    [s]
        fsubp
        fstp    [esi + Matrix4x4.m31]

        fld     [z]
        fmul    [y]
        fmul    [revC]
        fld     [x]
        fmul    [s]
        faddp
        fstp    [esi + Matrix4x4.m32]

        fld     [c]
        fld     [z]
        fmul    [z]
        fmul    [revC]
        faddp
        fstp    [esi + Matrix4x4.m33]

        mov     dword [esi + Matrix4x4.m34], 0.0

        ; 4th
        mov     dword [esi + Matrix4x4.m41], 0.0
        mov     dword [esi + Matrix4x4.m42], 0.0
        mov     dword [esi + Matrix4x4.m43], 0.0
        mov     dword [esi + Matrix4x4.m44], 1.0

        ret
endp

proc Matrix.Translate uses esi edi,\
     matrixT, translation

        mov     edi, [matrixT]

        stdcall Matrix.LoadIdentity, edi
        mov     esi, [translation]

        mov     eax, [esi + Vector3.x]
        mov     [edi + Matrix4x4.m41], eax

        mov     eax, [esi + Vector3.y]
        mov     [edi + Matrix4x4.m42], eax

        mov     eax, [esi + Vector3.z]
        mov     [edi + Matrix4x4.m43], eax
        ret
endp

proc Matrix.Scale uses esi edi,\
     matrixS, scale

        mov     edi, [matrixS]

        stdcall Matrix.LoadIdentity, edi
        mov     esi, [scale]

        mov     eax, [esi + Vector3.x]
        mov     [edi + Matrix4x4.m11], eax

        mov     eax, [esi + Vector3.y]
        mov     [edi + Matrix4x4.m22], eax

        mov     eax, [esi + Vector3.z]
        mov     [edi + Matrix4x4.m33], eax
        ret
endp