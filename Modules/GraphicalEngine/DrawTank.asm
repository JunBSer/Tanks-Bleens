proc    DrawTank uses esi edi,\
        pTank

        mov        edi, [pTank]
        mov        esi, [edi + Tank.pBodyObj]

        invoke     glUniformMatrix4fv,[modelMatrixLocation],1,GL_FALSE, [edi + Tank.pModelMatrix]

        stdcall    DrawObject, esi

        mov        esi, [edi + Tank.pTurretObj]
        stdcall    DrawObject, esi

    ret
endp