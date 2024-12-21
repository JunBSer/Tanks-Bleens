proc Player.Move uses ebx edi esi

        stdcall MoveCamera, [mainCamera], [tank]
        stdcall MoveTank,   [tank], [mainCamera]

        stdcall Player.Shoot, [tank], fShoot, [Targets], [TargetCnt], [DinObjects], [DinObjCnt]
.Return:
        ret
endp



proc Turret.Rotate uses edi esi ebx,\
     matrixTurret, pTank, turn

        locals
                yAngle          GLfloat         ?
        endl

        mov     eax, [turn]

        mov     edi, [pTank]
        fld     dword [eax + Vector3.y]
        fsub    dword [edi + Tank.rotations + Vector3.y]
        fchs
        fstp    dword [yAngle]
        stdcall Matrix.Rotate, matrixR, [yAngle], 0.0, 1.0, 0.0

        stdcall Matrix.Multiply, matrixR, [edi + Tank.pModelMatrix], [matrixTurret]
        ret
endp

proc Camera.InitLookAt uses esi edi,\
        rotations, position

        locals
                direction               Vector3         0.0, 0.0, 0.0
                up                      Vector3         0.0, 0.0, 0.0
                tempTarget              Vector3         0.0, 0.0, 0.0
        endl

        lea     esi, [direction]
        stdcall Camera.CalcDirection, esi, [rotations]
        lea     edi, [up]
        stdcall Camera.CalcUp, edi, esi


        lea     edi, [tempTarget]
        stdcall Vector3.Copy, edi, [position]
        lea     esi, [direction]
        stdcall Vector3.Add, edi, esi
        lea     esi, [up]

        stdcall Matrix.LookAtV, [position], edi, esi
        ret
endp

proc Model.KeyState.Update uses esi,\         ;+
        KeyState

        mov     esi, [KeyState]

        mov     dword [esi], VK_W
        invoke  GetAsyncKeyState, VK_S
        test    eax, 0x8000
        jz      .Skip
        mov     dword [esi], VK_S
.Skip:
        ret
endp

proc Model.CalcTurn uses edi,\
     turn, rotateSpeed

        mov     edi, [turn]
.PressA:
        invoke  GetAsyncKeyState, VK_A
        test    eax, 0x8000
        jz      .PressD
        fldz     ;[edi + Vector3.y]
        cmp     dword [keyState], VK_W
        jne     .BackwardA
.ForwardA:
        fadd    [rotateSpeed]
        jmp     .SkipA
.BackwardA:
        fsub    [rotateSpeed]
.SkipA:
        fstp    [edi + Vector3.y]
.PressD:
        invoke  GetAsyncKeyState, VK_D
        test    eax, 0x8000
        jz      .Skip
        fld     [edi + Vector3.y]
        cmp     dword [keyState], VK_W
        jne     .BackwardD
.ForwardD:
        fsub    [rotateSpeed]
        jmp     .SkipD
.BackwardD:
        fadd    [rotateSpeed]
.SkipD:
        fstp    [edi + Vector3.y]
.Skip:
        ret
endp

proc Model.CalcPosition uses esi edi,\             ;+
        position, direction, speed

        locals
                tempDirection   Vector3
        endl

        mov     edi, [position]
       ; mov     [edi + Vector3.x], 0.0
       ; mov     [edi + Vector3.y], 0.0
       ; mov     [edi + Vector3.z], 0.0

        mov     esi, [direction]
        lea     eax, [tempDirection]
        stdcall Vector3.Copy, eax, esi
        lea     esi, [tempDirection]
        stdcall Vector3.Mul, esi, [speed]

.PressW:
        invoke  GetAsyncKeyState, VK_W
        test    eax, 0x8000
        jz      .PressS
        stdcall Vector3.Sub, edi, esi
.PressS:
        invoke  GetAsyncKeyState, VK_S
        test    eax, 0x8000
        jz      .Skip
        stdcall Vector3.Add, edi, esi
.Skip:
        ret
endp

proc Camera.CalcPosition uses esi edi ebx,\
     camera, pTank
        locals
                tempDirection           Vector3         0.0, 0.0, 0.0
                tempTurn                Vector3         0.0, 0.0, 0.0
        endl

        mov     eax, [pTank]
        lea     eax, [eax + Tank.position]
        mov     edi, [camera]
        lea     edi, [edi + Camera.position]
        stdcall Vector3.Copy, edi, eax


        lea     eax, [stdOffset]
        stdcall Vector3.Add, edi, eax

        mov     esi, [camera]
        stdcall Camera.ChangeAngles, esi


        lea     ecx, [tempTurn]
        mov     esi, [esi + Camera.rotations + Vector3.y]
        mov     [ecx + Vector3.y], esi

        lea     ebx, [tempDirection]
        stdcall Camera.CalcDirection, ebx, ecx

        stdcall Vector3.Mul, ebx, -2.0
        stdcall Vector3.Add, edi, ebx
        ret
endp

proc Camera.CalcPositionOld uses esi edi,\          ; not useble
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

proc Camera.CalcUp uses esi,\                       ;+
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

proc Camera.CalcRight uses esi,\                  ;+
        right, direction, up

        stdcall Vector3.Cross, [direction], [up], [right]
        stdcall Vector3.Normalize, [right]

        ret
endp

proc Camera.CalcDirection uses esi,\       ;+
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


proc Camera.ChangeAngles uses edi,\                     ;+?
        turn

        locals
                __90            GLfloat         89.9
                __360           GLfloat         360.0
                yAngle          dd              ?
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

proc Camera.Init uses ebx esi edi, \                            ;+
        rotations, tankPos, camOffset, camera

        mov     esi, [camera]
        lea     edi, [esi + Camera.position]
        stdcall Vector3.Copy, edi, [tankPos]
        stdcall Vector3.Add, edi, [camOffset]

        stdcall Camera.InitLookAt, [rotations], edi

        lea     edi, [esi + Camera.rotations]
        stdcall Vector3.Copy, edi, [rotations]

        ;stdcall Matrix.LoadIdentity, matrixM
        ret
endp