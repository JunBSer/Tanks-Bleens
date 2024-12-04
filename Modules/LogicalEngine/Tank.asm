
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
        mov        [esi+Tank.pBodyObj], eax
;Create Turret object
        stdcall    ReadObject, tankTModelPath, [tankTextID]
        mov        [esi+Tank.pTurretObj], eax

        malloc     sizeof.Matrix4x4
        mov        [esi+Tank.pModelMatrix],eax

        mov        eax, esi

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
        stdcall Vector3.Copy, eax, [rotations]

        ; Init Model matrix
        stdcall Matrix.Scale, matrixS, [scale]

        stdcall Matrix.Rotate, matrixR, [esi+Tank.rotations+4], 0.0, 1.0, 0.0

        stdcall Matrix.Translate, matrixT, [position]

        stdcall Matrix.Multiply, matrixR, matrixT, matrixM

        stdcall Matrix.Multiply, matrixS, matrixM, [esi + Tank.pModelMatrix]

        stdcall Collision.OBB.Setup, esi

       ; stdcall Camera.Init, [rotations], [position], stdOffset, [mainCamera]

    ret
endp


proc   MoveTank uses esi edi ebx,\
       pTank, camera

       locals
                tempTarget              Vector3         0.0, 0.0, 0.0
                turnModel               Vector3         0.0, 0.0, 0.0
                displacement            Vector3         0.0, 0.0, 0.0
                modelDirection          Vector3         0.0, 0.0, 0.0
       endl

       stdcall Model.KeyState.Update, KeyState

       lea     esi, [turnModel]
       stdcall Model.CalcTurn, esi, [rotationSpeedModel]
       mov      edi, [pTank]
       ;lea      eax, [edi + Tank.rotations]
       ;stdcall Vector3.Sub, eax, esi

       lea     ebx, [modelDirection]
       stdcall Camera.CalcDirection, ebx, esi


       ;mov      edi, [pTank]

       lea      esi, [displacement]

       stdcall  Model.CalcPosition, esi, ebx, [edi + Tank.speed]

       stdcall  Matrix.Rotate, matrixR, [turnModel.y], 0.0, 1.0, 0.0


       stdcall  Matrix.Translate, matrixT, esi

       stdcall Matrix.Multiply, matrixT, matrixR, matrixM
       ;
       stdcall Collision.SetupModelMatrix, edi, matrixM
       cmp     eax, 1
       je      .Return
       ;
       ;stdcall Matrix.Multiply, matrixM, [edi + Tank.pModelMatrix], matrixS

       stdcall Matrix.Copy, matrixS, [edi + Tank.pModelMatrix]


       lea     esi, [matrixS + Matrix4x4.m41]
       lea     eax, [edi + Tank.position]
       stdcall Vector3.Copy, eax, esi

       mov      edi, [camera]
       lea      edi, [edi + Camera.position]
       stdcall  Vector3.Copy, edi, eax

       mov      eax, [stdOffset.y]
       mov      [tempTarget.y], eax
       lea      eax, [tempTarget]

       stdcall  Vector3.Add, edi, eax

       push    edi
       mov      edi, [pTank]
       lea     eax, [edi + Tank.rotations]
       lea     esi, [turnModel]
       stdcall Vector3.Sub, eax, esi
       pop     edi

       ;lea      edx, [modelDirection]
       mov      esi, [pTank]
       lea      ebx, [esi + Tank.rotations]
       lea      esi, [tempTarget]
       stdcall  Vector3.Copy, esi, ebx

       lea     ebx, [modelDirection]
       stdcall Camera.CalcDirection, ebx, esi

       mov      eax, -2.0
       stdcall  Vector3.Mul, ebx, eax
       stdcall  Vector3.Add, edi, ebx

       mov      edi, [camera]
       lea      esi, [turnModel]
       lea      edi, [edi + Camera.rotations]

       stdcall  Vector3.Sub, edi,esi

.Return:
    ret
endp

proc    MoveCamera uses esi edi ebx,\
        camera

        locals
                direction               Vector3         0.0, 0.0, 0.0
                up                      Vector3         0.0, 0.0, 0.0
                right                   Vector3         0.0, 0.0, 0.0
                tempTarget              Vector3         0.0, 0.0, 0.0
                worldUp                 Vector3         0.0, 1.0, 0.0
        endl

        mov     edi, [camera]
        lea     ebx, [edi+Camera.rotations]
        stdcall Camera.ChangeAngles, ebx

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