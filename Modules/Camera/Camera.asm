proc Camera.Move uses ebx edi esi

        locals
                direction               Vector3         0.0, 0.0, 0.0
                up                      Vector3         0.0, 0.0, 0.0
                right                   Vector3         0.0, 0.0, 0.0
                tempTarget              Vector3         0.0, 0.0, 0.0
                worldUp                 Vector3         0.0, 1.0, 0.0
        endl

        stdcall Camera.ChangeAngles, turn

        lea     esi, [direction]
        stdcall Camera.CalcDirection, esi, turn
        lea     edi, [up]
        stdcall Camera.CalcUp, edi, esi

        lea     eax, [right]
        stdcall Camera.CalcRight, eax, esi, edi

        lea     edi, [direction]
        lea     esi, [right]
        stdcall Camera.CalcPosition, edi, esi

        lea     edi, [tempTarget]
        stdcall Vector3.Copy, edi, position
        lea     esi, [direction]
        stdcall Vector3.Add, edi, esi

        lea     esi, [up]


        ;stdcall Matrix.LookAtV, position, edi, esi
        ;stdcall Matrix.Copy, matrixX, matrixV

        stdcall Matrix.Rotate, [mapAngleX], 1.0, 0.0, 0.0
        stdcall Matrix.Copy, matrixX, matrixR
        ;stdcall Matrix.Rotate, [mapAngleZ], 0.0, 0.0, 1.0
        ;stdcall Matrix.Multiply, matrixX, matrixR
        stdcall Matrix.LookAtV, position, edi, esi
        stdcall Matrix.Multiply, matrixX, matrixV

        ret
endp



proc Camera.CalcPosition uses esi edi,\
        direction, right

        locals
                tempDirection   Vector3
                tempRight       Vector3
        endl
        mov     esi, [direction]
        mov     edi, [right]
        lea     eax, [tempDirection]
        stdcall Vector3.Copy, eax, esi
        lea     esi, [tempDirection]
        stdcall Vector3.Mul, esi, [speed]

        lea     edx, [tempRight]
        stdcall Vector3.Copy, edx, edi
        lea     edi, [tempRight]
        stdcall Vector3.Mul, edi, [speed]

.PressW:
        invoke  GetAsyncKeyState, VK_W
        test    eax, 0x8000
        jz      .PressS
        stdcall Vector3.Add, position, esi
.PressS:
        invoke  GetAsyncKeyState, VK_S
        test    eax, 0x8000
        jz      .PressA
        stdcall Vector3.Sub, position, esi
.PressA:
        invoke  GetAsyncKeyState, VK_A
        test    eax, 0x8000
        jz      .PressD
        stdcall Vector3.Sub, position, edi
.PressD:
        invoke  GetAsyncKeyState, VK_D
        test    eax, 0x8000
        jz      .Skip
        stdcall Vector3.Add, position, edi
.Skip:
        ret
endp

proc Camera.CalcUp uses esi,\
        up, direction

        locals
                worldUp         Vector3         0.0, 1.0, 0.0
                right           Vector3         0.0, 0.0, 0.0
        endl

        lea     eax, [worldUp]
        lea     esi, [right]
        stdcall Vector3.Cross, eax, [direction], esi
        stdcall Vector3.Normalize, esi

        stdcall Vector3.Cross, [direction], esi, [up]
        ret
endp

proc Camera.CalcRight uses esi,\
        right, direction, up

        stdcall Vector3.Cross, [direction], [up], [right]
        stdcall Vector3.Normalize, [right]

        ret
endp

proc Camera.CalcDirection uses esi,\
        direction, turn

        locals
                a                       GLfloat         ?
                b                       GLfloat         ?
                PIDegree                GLfloat         180.0
        endl

        mov     esi, [turn]
        fldpi
        fdiv    [PIDegree]
        fld     [esi + Vector3.x]
        fmul    st0, st1
        fstp    [a]

        fld     [esi + Vector3.y]
        fmulp
        fstp    [b]

        mov     esi, [direction]
        fld     [a]
        fcos
        fld     [b]
        fsin
        fmul    st0, st1
        fstp    dword [esi + Vector3.z]

        fld     [a]
        fsin
        fstp    dword [esi + Vector3.y]

        fld     [b]
        fcos
        fmulp
        fstp    dword [esi + Vector3.x]

        stdcall Vector3.Normalize, esi
        ret
endp


proc Camera.ChangeAngles uses edi,\
        turn

        locals
                __90            GLfloat         89.9
        endl

        mov     edi, [turn]
        invoke  GetCursorPos, cursorPos
        mov     eax, [windowWidthH]
        sub     eax, [cursorPos + POINT.x]
        push    eax
        fild    dword [esp]
        add     esp, 4
        fmul    [mouseSpeed]
        fchs
        fadd    [edi + Vector3.y]
        fstp    [edi + Vector3.y]

        mov     eax, [windowHeightH]
        sub     eax, [cursorPos + POINT.y]
        push    eax
        fild    dword [esp]
        add     esp, 4
        fmul    [mouseSpeed]
        fadd    [edi + Vector3.x]
        ; border
        fld     [__90]
        fcomi   st1
        ja      .skip90
        fxch    st1
        jmp     .skipm90
.skip90:
        fchs
        fcomi   st1
        jb      .skipm90
        fxch    st1
.skipm90:
        fstp    st0
        fstp    [edi + Vector3.x]

        invoke  SetCursorPos, [windowWidthH], [windowHeightH]
        ret
endp

proc Camera.Init uses ebx

        xor     ebx, ebx
        invoke  ShowCursor, ebx
        mov     eax, [clientRect.right]
        sar     eax, 1
        mov     [windowWidthH], eax
        mov     eax, [clientRect.bottom]
        sar     eax, 1
        mov     [windowHeightH], eax
        xor     eax, eax
        invoke  SetCursorPos, [windowWidthH], [windowHeightH]
        ret
endp