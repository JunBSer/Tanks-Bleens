proc SetCrosshairPos uses esi edi ebx,\
     crosshairPos, tankPos, modelDirection, crosshairOffs

     locals
         temp   Vector3
     endl

     mov        edi, [crosshairPos]
     mov        esi, [tankPos]
     stdcall    Vector3.Copy, edi, esi

     mov        esi, [modelDirection]
     lea        edi, [temp]
     stdcall    Vector3.Copy, edi, esi

     mov        esi, [crosshairOffs]
     mov        ebx, [esi + Vector3.y]
     mov        eax, [esi + Vector3.z]

     stdcall    Vector3.Mul, edi,eax

     mov        esi, [crosshairPos]
     stdcall    Vector3.Sub, esi, edi

     fld        dword [esi + Vector3.y]
     push       ebx
     fld        dword [esp]
     faddp
     fstp       dword [esi + Vector3.y]
     add        esp, 4

    ret
endp

proc InitCrosshair uses edi esi ebx,\
     pCross, pTank, shootPointOffs, crosshairOffs, crossScale

     locals
         crosshairPos           Vector3
         modelDirection         Vector3
         temp                   Vector3
     endl

     mov        edi, [pCross]

     mov        esi, [edi + StaticObject.pModelMatrix]
     stdcall    Matrix.LoadIdentity, esi

     mov        esi, [pTank]
     lea        ecx, [esi + Tank.rotations]
     lea        ebx, [modelDirection]
     stdcall    Camera.CalcDirection, ebx, ecx

     stdcall    Vector3.Normalize, ebx


     lea        edx, [crosshairPos]
     lea        ecx, [esi + Tank.position]
     stdcall    SetCrosshairPos, edx, ecx, ebx, [crosshairOffs]


     stdcall    Matrix.Scale, matrixS, [crossScale]

     lea        eax, [crosshairPos]
     stdcall    Matrix.Translate, matrixT, eax

     stdcall    Matrix.Multiply, matrixS, matrixT, [edi + StaticObject.pModelMatrix]

    ret
endp



