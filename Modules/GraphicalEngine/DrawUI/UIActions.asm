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

       ret
endp


proc   ProcessClick uses esi edi,\
       pStObjects, stObjectsCnt, lParam

       locals
               posX     dd      ?
               posY     dd      ?
       endl

       movzx    eax, word [lParam]
       mov      dword [posX], eax

       movzx    eax, word [lParam + 2]
       mov      dword [posY], eax

       ;mov      dword [posX], 100
       ;mov      dword [posY], 500

       mov      ecx, [stObjectsCnt]
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

       stdcall  dword [eax + 20], [esi + edi]


.Skip:
       pop      ecx

       loop     .CheckClickLoop



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