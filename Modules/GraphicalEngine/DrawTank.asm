proc    DrawTank uses esi edi,\
        pTank

        locals
                tempTurn        Vector3         0.0, 0.0, 0.0
        endl

        mov        edi, [pTank]
        mov        esi, [edi + Tank.pBodyObj]

        invoke     glUniformMatrix4fv,[modelMatrixLocation],1,GL_FALSE, [edi + Tank.pModelMatrix]

        stdcall    DrawObject, esi

        mov        esi, [edi + Tank.pTurretObj]

        mov        eax, [mainCamera]
        mov        eax, [eax + Camera.rotations + Vector3.y]
        mov        dword [tempTurn + Vector3.y], eax
        lea        eax, [tempTurn]
        stdcall    Turret.Rotate, matrixTurret, [edi + Tank.pModelMatrix], eax
        invoke     glUniformMatrix4fv,[modelMatrixLocation],1,GL_FALSE, matrixTurret
        stdcall    DrawObject, esi

    ret
endp