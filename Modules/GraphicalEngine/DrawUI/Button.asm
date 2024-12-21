proc CreateButton uses edi esi ebx,\
     pText, butTextId, txtTextId, eHandler
     locals
         vertices       dd      ?
         textCoords     dd      ?

         pButton        dd      ?
         temp           dd      ?

         vertices       dd      ?
         textCoords     dd      ?
     endl

     malloc     sizeof.Button
     mov        [pButton], eax


     len        [pText]
     mov        edi, [pButton]
     mov        [edi + Button.sizes + Vector2.u], ecx

     mov        [temp], startCharWidth
     fld        [temp]
     mov        [temp], characterGap
     fadd       [temp]


     fimul      [edi + Button.sizes + Vector2.u]
     mov        [temp], defBorderWidth
     fadd       [temp]
     fadd       [temp]
     fstp       [edi + Button.sizes + Vector2.u]

     mov        [temp], startCharHeight
     fld        [temp]
     mov        dword [temp], defBorderHeight
     fadd       [temp]
     fadd       [temp]
     fstp       [edi + Button.sizes + Vector2.v]

     fld        [temp]
     fchs
     fstp       [edi + Button.position + Vector2.v]

     mov        dword [temp], defBorderWidth
     fld        [temp]
     fchs
     fstp       [edi + Button.position + Vector2.u]

     mov        dword [edi + Button.visible], true
     mov        eax, [eHandler]
     mov        dword [edi + Button.eventHandler],eax

;Create button data
     mov        esi, 6*2*4
     malloc     esi
     mov        [vertices], eax

     malloc     esi
     mov        [textCoords], eax

;Fill vert pos
     mov        esi,  [vertices]

     mov        ecx, [edi + Button.position + Vector2.u] ;old X
     mov        edx, [edi + Button.position + Vector2.v] ;old Y

     fld        [edi + Button.position + Vector2.u]
     fadd       [edi + Button.sizes + Vector2.u]
     fstp       [temp]
     mov        eax, [temp]    ;new X

     fld        [edi + Button.position + Vector2.v]
     fadd       [edi + Button.sizes + Vector2.v]
     fstp       [temp]
     mov        ebx, [temp]    ;new Y


     mov        dword [esi], ecx
     mov        dword [esi + 4], edx

     mov        dword [esi + 8], ecx
     mov        dword [esi + 12], ebx

     mov        dword [esi + 16], eax
     mov        dword [esi + 20], ebx

     mov        dword [esi + 24], eax
     mov        dword [esi + 28], ebx

     mov        dword [esi + 32], eax
     mov        dword [esi + 36], edx

     mov        dword [esi + 40], ecx
     mov        dword [esi + 44], edx

;Fill   textCoords

     mov        esi, [textCoords]

     mov        dword [esi], 0.0
     mov        dword [esi + 4], 0.0

     mov        dword [esi + 8], 0.0
     mov        dword [esi + 12], 1.0

     mov        dword [esi + 16], 1.0
     mov        dword [esi + 20], 1.0

     mov        dword [esi + 24], 1.0
     mov        dword [esi + 28], 1.0

     mov        dword [esi + 32], 1.0
     mov        dword [esi + 36], 0.0

     mov        dword [esi + 40], 0.0
     mov        dword [esi + 44], 0.0


     stdcall    CreateStaticObject, [vertices], [textCoords], 0, [butTextId], 6
     mov        [edi + Button.pEntityObj], eax


     stdcall    CreateText, [pText], [txtTextId]
     mov        [edi + Button.pTextObj], eax

     mov        ebx,  [edi + Button.pEntityObj]
     stdcall    Matrix.LoadIdentity, matrixM

     stdcall    Matrix.Scale, matrixS, [resolutScale]
     stdcall    Matrix.Multiply, matrixS, matrixM, [ebx + StaticObject.pModelMatrix]

     mov        eax, edi
    ret
endp


proc SetButtonParams uses edi,\
     obj, scale, translation

      mov     edi, [obj]

      stdcall SetStObjParams, [edi + Button.pEntityObj], [scale], [translation]

      stdcall SetStObjParams, [edi + Button.pTextObj], [scale], [translation]

    ret
endp


proc DrawButton uses edi,\
     pButton


     mov        edi, [pButton]

     stdcall    DrawStaticObject, [edi + Button.pEntityObj], [stModelMatrixLocation], [stSamplerLocation]

     stdcall    DrawStaticObject, [edi + Button.pTextObj], [stModelMatrixLocation], [stSamplerLocation]

    ret
endp


proc ReleaseButtonRes uses esi,\
     pBtn

     mov        esi, [pBtn]

     stdcall ReleaseStObjRes, [esi + Button.pEntityObj]
     stdcall ReleaseStObjRes, [esi + Button.pTextObj]

     free    esi

     ret
endp


proc ReleaseButtons uses esi edi ebx,\
     Buttons, pButtonsCnt

       mov     ebx, [pButtonsCnt]
       mov     ecx, [ebx]
       mov     edi, [Buttons]


.FreeButtonLoop:
       mov        esi, [ebx]
       sub        esi, ecx
       shl        esi,2

       push       ecx


       stdcall    ReleaseButtonRes, [edi + esi]

       pop     ecx

       loop    .FreeButtonLoop

       mov      dword [ebx], 0
     ret
endp