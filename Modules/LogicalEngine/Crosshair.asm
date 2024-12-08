proc SetCrosshairPos uses esi edi ebx,\
     crosshairPos, tankPos, modelDirection, crosshairOffs

     locals
         temp   Vector3
     endl

     mov        edi, [crosshairPos]
     mov        esi, [tankPos]
     stdcall    Vecto3.Copy, edi, esi

     mov        esi, [modelDirection]
     lea        edi, [temp]
     stdcall    Vector3.Copy, edi, esi

     mov        esi, [crosshairOffs]
     mov        ebx, [esi + Vector3.y]
     mov        eax, [esi + Vector3.z]

     stdcall    Vector3.Mul, edi,eax

     mov        esi, [crosshairPos]
     stdcall    Vector3.Add, esi, edi

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

     lea        eax, [temp]
     stdcall    Vector3.Copy, eax, [shootPointOffs]
     stdcall    Vector3.Add, eax, [crosshairOffs]
     lea        edx, [crosshairPos]
     lea        ecx, [esi + Tank.position]
     stdcall    SetCrosshairPos, edx, ecx, ebx, eax

     stdcall    Matrix.Scale, MatrixS, [crossScale]

     lea        eax, [crosshairPos]
     stdcall    Matrix.Translate, MatrixT, eax

     stdcall    Matrix.Multiply, MatrixS, MatrixT, [edi + StaticObject.pModelMatrix]

    ret
endp



