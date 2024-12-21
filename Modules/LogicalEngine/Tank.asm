
        tankBModelPath   db      "Resources/Tank/tankBody.obj", 0
        tankTModelPath   db      "Resources/Tank/tankTurret.obj", 0

proc    CreateTank uses esi\

        locals
        pTank           dd      ?
        endl


        malloc          sizeof.Tank
        mov             [pTank], eax
        mov             esi, eax

;Create Body object
        stdcall    ReadObject, tankBModelPath, [tankTextID]
        mov        [esi + Tank.pBodyObj], eax
;Create Turret object
        stdcall    ReadObject, tankTModelPath, [tankTextID]
        mov        [esi + Tank.pTurretObj], eax

        malloc     sizeof.Matrix4x4
        mov        [esi + Tank.pModelMatrix],eax

        malloc     sizeof.Matrix4x4
        mov        [esi + Tank.turret + Turret.pTurretMatrix],eax

        mov        eax, esi

    ret
endp

proc    ReleaseTankRes uses esi,\
        pTank

        mov     esi, [pTank]
        stdcall ReleaseObjRes, [esi + Tank.pBodyObj]
        stdcall ReleaseObjRes, [esi + Tank.pTurretObj]
        free    [esi + Tank.pModelMatrix]

        free    esi
        ret
endp


proc ReleaseTanks uses esi edi ebx,\
     Targets, pTrgtCnt

       mov     ebx, [pTrgtCnt]
       mov     ecx, [ebx]
       mov     edi, [Targets]


.FreeTankLoop:
       mov        esi, [ebx]
       sub        esi, ecx
       shl        esi,2

       push       ecx


       stdcall    ReleaseTankRes, [edi + esi]

       pop     ecx

       loop    .FreeTankLoop

       mov      dword [ebx], 0

     ret
endp



proc    SpawnTank uses esi edi,\
        pTank, position, rotations, scale, speed

        ; Init const params
        mov     esi, [pTank]

        mov     eax, [speed]
        mov     [esi + Tank.speed], eax

        lea     eax, [esi + Tank.scale]
        stdcall Vector3.Copy, eax, [scale]

        stdcall Matrix.LoadIdentity, [esi + Tank.pModelMatrix]

        ;Init world position
        lea     eax, [esi + Tank.position]
        stdcall Vector3.Copy, eax, [position]

        lea     eax, [esi + Tank.rotations]
        stdcall Vector3.Copy, eax, [rotations]

        ;Init turret rotations
        lea     eax, [esi + Tank.turret]
        lea     eax, [eax + Turret.rotations]

        memset  eax, 0.0, sizeof.Vector3

        ; Init Model matrix
        stdcall Matrix.Scale, matrixS, [scale]

        stdcall Matrix.Rotate, matrixR, [esi+Tank.rotations+4], 0.0, 1.0, 0.0

        stdcall Matrix.Translate, matrixT, [position]

        stdcall Matrix.Multiply, matrixR, matrixT, matrixM

        stdcall Matrix.Multiply, matrixS, matrixM, [esi + Tank.pModelMatrix]

        stdcall Matrix.Copy, [esi + Tank.turret + Turret.pTurretMatrix], [esi + Tank.pModelMatrix]

        stdcall Collision.OBB.Setup, esi

       ; stdcall Camera.Init, [rotations], [position], stdOffset, [mainCamera]

        mov     [esi  + Tank.hp], 100
    ret
endp


proc    MoveTank uses esi edi ebx,\
        pTank, camera


        locals
                turnModel               Vector3         0.0, 0.0, 0.0
                displacement            Vector3         0.0, 0.0, 0.0
                modelDirection          Vector3         0.0, 0.0, 0.0
                tempTurn                Vector3         0.0, 0.0, 0.0
        endl


        stdcall Model.KeyState.Update, keyState

        lea     esi, [turnModel]
        stdcall Model.CalcTurn, esi, [rotationSpeedModel]
        mov     edi, [pTank]

        lea     ebx, [modelDirection]
        stdcall Camera.CalcDirection, ebx, esi

        lea     esi, [displacement]

        stdcall Model.CalcPosition, esi, ebx, [edi + Tank.speed]

        stdcall Matrix.Rotate, matrixR, [turnModel.y], 0.0, 1.0, 0.0


        stdcall Matrix.Translate, matrixT, esi

        stdcall Matrix.Multiply, matrixT, matrixR, matrixM
        ;
        stdcall Collision.SetupModelMatrix, edi, matrixM
        cmp     eax, 1
        je      .Return

        mov     esi, [edi + Tank.pModelMatrix]
        lea     esi, [esi + Matrix4x4.m41]
        lea     eax, [edi + Tank.position]
        stdcall Vector3.Copy, eax, esi

        ;mov     edi, [camera]
        ;lea     esi, [turnModel]
        ;lea     edi, [edi + Camera.rotations]
        ;stdcall Vector3.Sub, edi, esi

        mov     edi, [pTank]
        lea     eax, [edi + Tank.rotations]
        lea     esi, [turnModel]
        stdcall Vector3.Sub, eax, esi


.Return:
        mov     eax, [camera]
        mov     eax, [eax + Camera.rotations + Vector3.y]
        mov     dword [tempTurn + Vector3.y], eax
        lea     eax, [tempTurn]
        stdcall Turret.Rotate, [edi + Tank.turret + Turret.pTurretMatrix], [pTank], eax

        stdcall ChangeDependPos, [edi + Tank.turret + Turret.pTurretMatrix]

        ret
endp


proc    MoveCamera uses esi edi ebx,\
        camera, pTank

        locals
                direction               Vector3         0.0, 0.0, 0.0
                up                      Vector3         0.0, 0.0, 0.0
                right                   Vector3         0.0, 0.0, 0.0
                tempTarget              Vector3         0.0, 0.0, 0.0
                tempTurn                Vector3         0.0, 0.0, 0.0
        endl



        mov     edi, [camera]
        lea     ebx, [edi+Camera.rotations]
        stdcall Camera.CalcPosition, edi, [pTank]

        ;fld     [ebx + Vector3.x]
        ;fldz
       ; fcomip  st, st1
        ;je      .Return

        lea     esi, [direction]
        stdcall Camera.CalcDirection, esi, ebx
        lea     edi, [up]
        stdcall Camera.CalcUp, edi, esi

        lea     eax, [right]
        stdcall Camera.CalcRight, eax, esi, edi


        lea     edi, [tempTarget]
        mov     esi, [camera]
        lea     ebx, [esi + Camera.position]
        stdcall Vector3.Copy, edi, ebx

        lea     esi, [direction]
        stdcall Vector3.Add, edi, esi

        lea     esi, [up]

        stdcall Matrix.LookAtV, ebx, edi, esi

.Return:
       ; fstp    [direction.x]
        ret
endp