     include    "./Text.inc"
proc CreateText uses edi esi ebx,\
     pString, textId
     locals
         vertices       dd      ?
         textCoords     dd      ?
         strLen         dd      ?

         tempX          dd      ?
         vertCnt        dd      ?
         textObj        dd      ?
     endl

     len        [pString]
     mov        [strLen], ecx

     mov        ebx, 6
     imul       ebx, ecx

     mov        [vertCnt], ebx

     shl        ebx, 3

     malloc     ebx
     mov        [vertices], eax

     malloc     ebx
     mov        [textCoords], eax


     mov        edi, [vertices]
     mov        ebx, [textCoords]

     mov        edx, -5.0
     mov        esi, 0
     mov        ecx, [strLen]
.FillCoordsLoop:
     push       ecx

     mov        dword [edi + esi], edx
     mov        dword [edi + esi + 4], 0.0

     mov        dword [edi + esi + 8],edx
     mov        dword [edi + esi + 12], startCharHeight

     mov        [tempX], edx
     fld        dword [tempX]
     mov        [tempX], startCharWidth
     fadd       dword [tempX]
     fstp       dword [tempX]

     mov        ecx, [tempX]

     mov        dword [edi + esi + 16], ecx
     mov        dword [edi + esi + 20], startCharHeight

     mov        dword [edi + esi + 24], ecx
     mov        dword [edi + esi + 28], startCharHeight

     mov        dword [edi + esi + 32], ecx
     mov        dword [edi + esi + 36], 0.0

     mov        dword [edi + esi + 40], edx
     mov        dword [edi + esi + 44], 0.0


     push       ecx
     xor        edx, edx
     mov        eax, esi
     mov        ecx, 48
     div        ecx

     mov        edx, [pString]
     movzx      edx, byte[edx + eax]

     mov        ecx, ebx
     add        ecx, esi

     stdcall    InitCharData, edx,  ecx

     pop        ecx

     fld        dword [tempX]
     mov        dword [tempX], characterGap
     fadd       dword [tempX]
     fstp       dword [tempX]

     xchg       edx, [tempX]

     add        esi, 48

     pop        ecx

     sub        ecx,1
     cmp        ecx,0
     jne        .FillCoordsLoop


     stdcall    CreateStaticObject, [vertices], [textCoords], 0, [textId], [vertCnt]
     mov        [textObj], eax

     mov        edi, eax
     stdcall    Matrix.LoadIdentity, [edi + StaticObject.pModelMatrix]

     mov        eax, edi
    ret
endp

proc    SetTxtParams uses edi,\
        pTextObj, scale, translation

        mov     edi, [pTextObj]

        stdcall Matrix.Scale, matrixS, [scale]
        stdcall Matrix.Translate, matrixT, [translation]

        stdcall Matrix.Copy, matrixM, [edi + StaticObject.pModelMatrix]

        stdcall Matrix.Multiply, matrixS, matrixT, matrixR
        stdcall Matrix.Multiply, matrixR, matrixM, [edi + StaticObject.pModelMatrix]

        ret
endp

proc InitCharData uses edi,\
     letter, pTextArr

     locals
         charSize       dd      ?

         rctLeft        dd      ?
         rctRight       dd      ?
         rctTop         dd      ?
         rctBottom      dd      ?

         x              dd      ?
         y              dd      ?
     endl

;Init x, y
     movzx      eax, byte [letter]

     mov        [x], eax
     and        dword [x], 15

     shr        eax, 4
     mov        [y], eax
     add        [y], 1


     mov        dword [charSize], letPerLine

;Find texture coords
     fld1
     fld        dword [charSize]
     fdivp
     fst        dword [charSize]

     fimul      dword [x]
     fst        dword [rctLeft]

     fadd       dword [charSize]
     fstp       dword [rctRight]

     fld        dword [charSize]
     fimul      dword [y]
     fld1
     fsubrp     st1, st
     fst        dword [rctTop]

     fadd       dword [charSize]
     fstp       dword [rctBottom]

;Fill coords
     mov        edi, [pTextArr]

     mov        eax, [rctRight]
     mov        [edi + 4*4], eax
     mov        [edi + 6*4], eax
     mov        [edi + 8*4], eax

     mov        eax, [rctLeft]
     mov        [edi], eax
     mov        [edi + 2*4], eax
     mov        [edi + 10*4], eax


     mov        eax, [rctTop]
     mov        [edi + 1*4], eax
     mov        [edi + 9*4], eax
     mov        [edi + 11*4], eax

     mov        eax, [rctBottom]
     mov        [edi + 3*4], eax
     mov        [edi + 5*4], eax
     mov        [edi + 7*4], eax

    ret
endp