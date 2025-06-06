proc   FindBorderCoords uses esi edi,\
       pObj, pMinCoords, pMaxCoords

       locals
              temp      Vector3
       endl

       mov      esi, [pObj]

       mov      edi, [esi]
       mov      edi, [edi + StaticObject.pModelMatrix]

       lea      eax, [edi + Matrix4x4.m41]
       push     esi
       push     edi
       memcpy   [pMinCoords], eax, 2*4
       pop      edi
       pop      esi

       mov      eax, [esi + 12 + Vector2.u]
       mov      ecx, [esi + 12 + Vector2.v]
       mov      [temp], eax
       mov      [temp + Vector3.y], ecx
       mov      [temp + Vector3.z], 0.0

       lea      eax, [temp]
       stdcall  Matrix.Translate, matrixT, eax
       stdcall  Matrix.Multiply, matrixT, edi, matrixS

       mov      edi, matrixS
       lea      eax, [edi + Matrix4x4.m41]
       push     esi
       push     edi
       memcpy   [pMaxCoords], eax, 2*4
       pop      edi
       pop      esi


       ;mov      esi, [pMaxCoords]
       ;fld      dword [esi]
       ;mov      dword [temp], defBorderWidth
       ;fsub    dword [temp]
       ;fstp     dword [esi]

       ;fld      dword  [esi + 4]
       ;mov      dword [temp], defBorderHeight
       ;fsub    dword [temp]
       ;fstp     dword [esi + 4]
       ret
endp


proc   ProcessClick uses esi edi,\
       pStObjects, stObjectsCnt, lParam

       locals
               posX     dd      ?
               posY     dd      ?
       endl


       movzx    eax, word [lParam]
       sub      eax, [windowWidthH]
       mov      dword [posX], eax


       movzx    eax, word [lParam + 2]
       sub      eax, [windowHeightH]
       neg      eax
       mov      dword [posY], eax

       mov      ecx, [stObjectsCnt]
       cmp      ecx, 0
       je       .Return
       mov      edi, [pStObjects]
.CheckClickLoop:
       push     ecx

       mov      esi, [stObjectsCnt]
       sub      esi, ecx
       shl      esi,2

       stdcall  IsCursorOverStObject, [esi + edi], [posX], [posY]

       cmp      eax, true
       jne      .Skip

       mov      eax, [esi + edi]
       cmp      dword [eax + 20], 0
       je       .Skip

      ; int      3
       stdcall  dword [eax + 20], [esi + edi]


       jmp      .Return
.Skip:
       pop      ecx

       loop     .CheckClickLoop

       mov      dword [isEditActive], false

.Return:
       ret
endp


proc  IsCursorOverStObject uses esi,\
      pObj, xPos, yPos

      locals
                minCoords       Vector2
                maxCoords       Vector2
      endl

      mov        esi, [pObj]
      lea        eax, [minCoords]
      lea        ecx, [maxCoords]
      stdcall    FindBorderCoords, esi, eax, ecx

      fild       dword [xPos]
      fld        dword [minCoords]
      fcomip     st, st1
      ja         .ReturnFalse

      fld        dword [maxCoords]
      fcomip     st, st1
      jb         .ReturnFalse
      fstp       dword [minCoords]

      fild       dword [yPos]
      fld        dword [minCoords + 4]
      fcomip     st, st1
      ja         .ReturnFalse

      fld        dword [maxCoords + 4]
      fcomip     st, st1
      jb         .ReturnFalse
      fstp       dword [maxCoords]

.ReturnTrue:
      mov       eax, true
      jmp       .Return
.ReturnFalse:
      mov       eax, false
      fstp      dword [maxCoords]
.Return:

      ret
endp


proc TranslateChar,\
     vKey

     switch  [vKey]
     case    .ProcessPoint,             0xBE
     case    .ProcessBackspace,         VK_BACK
     case    .ProcessZero,              0x30
     case    .ProcessOne,               0x31
     case    .ProcessTwo,               0x32
     case    .ProcessThree,             0x33
     case    .ProcessFour,              0x34
     case    .ProcessFive,              0x35
     case    .ProcessSix,               0x36
     case    .ProcessSeven,             0x37
     case    .ProcessEight,             0x38
     case    .ProcessNine,              0x39
     jmp     .ReturnZero

.ProcessPoint:
        mov     eax, 46
        jmp     .Return

.ProcessBackspace:
        mov     eax, 08h
        jmp     .Return

.ProcessZero:
        mov     eax, 48
        jmp     .Return

.ProcessOne:
        mov     eax, 49
        jmp     .Return

.ProcessTwo:
        mov     eax, 50
        jmp     .Return

.ProcessThree:
        mov     eax, 51
        jmp     .Return

.ProcessFour:
        mov     eax, 52
        jmp     .Return

.ProcessFive:
        mov     eax, 53
        jmp     .Return

.ProcessSix:
        mov     eax, 54
        jmp     .Return

.ProcessSeven:
        mov     eax, 55
        jmp     .Return

.ProcessEight:
        mov     eax, 56
        jmp     .Return

.ProcessNine:
        mov     eax, 57
        jmp     .Return
.ReturnZero:
        mov     eax, -1
.Return:
    ret
endp