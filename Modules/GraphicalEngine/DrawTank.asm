proc    DrawTank uses esi edi,\
        pTank

        mov        edi, [pTank]
        mov        esi, [edi + Tank.pBodyObj]

        invoke     glUniformMatrix4fv,[modelMatrixLocation],1,GL_FALSE, [edi + Tank.pModelMatrix]

        stdcall    DrawObject, esi

        mov        esi, [edi + Tank.pTurretObj]

        invoke     glUniformMatrix4fv,[modelMatrixLocation],1,GL_FALSE, [edi + Tank.turret + Turret.pTurretMatrix]
        stdcall    DrawObject, esi

    ret
endp

proc    UpdateTarget uses esi,\
        pTank

        mov     esi, [pTank]

        lea     eax, [scaleModel]
        stdcall Matrix.Scale, matrixS, eax

        stdcall Matrix.Rotate, matrixR, [esi+Tank.rotations+4], 0.0, 1.0, 0.0

        lea     eax, [esi + Tank.position]
        stdcall Matrix.Translate, matrixT, eax

        stdcall Matrix.Multiply, matrixR, matrixT, matrixM

        stdcall Matrix.Multiply, matrixS, matrixM, [esi + Tank.pModelMatrix]

        stdcall Matrix.Rotate, matrixR, [esi + Tank.turret + Turret.rotations + 4], 0.0, 1.0, 0.0

        stdcall Matrix.Multiply, matrixR, [esi + Tank.pModelMatrix], [esi + Tank.turret + Turret.pTurretMatrix]

        ret
endp