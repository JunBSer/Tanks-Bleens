proc InitHPBar,\
     hpBar
     locals
       hpBarScale       Vector3         500.0, 50.0, 0.0
       hpBarTranslate   Vector3         -750.0, -400.0, 0.0

     endl

      stdcall  InitStObjParams, [hpBar]
      lea      eax, [hpBarScale]
      lea      edx, [hpBarTranslate]
      stdcall  SetStObjParams, [hpBar], eax, edx

     ret
endp

proc UpdateHp uses esi,\
     pTank, hpBar

     locals
            scaleX      dd         ?
            scaleY      dd         1.0
            scaleZ      dd         1.0
     endl

     mov        esi, [pTank]
     mov        dword [scaleX], 100
     fild       [esi + Tank.hp]
     fidiv      [scaleX]
     ;int       3
     fldz
     fcomip     st,st1
     jb         .ChangeParams
     mov        dword [scaleX], 0.0
     fmul       dword [scaleX]
.ChangeParams:
     fstp       [scaleX]
     stdcall    InitHPBar, [hpBar]


     mov        esi, [hpBar]
     lea        eax, [scaleX]
     stdcall    Matrix.Scale, matrixS, eax
     stdcall    Matrix.Copy, matrixM, [esi + StaticObject.pModelMatrix]
     stdcall    Matrix.Multiply, matrixS, matrixM, [esi + StaticObject.pModelMatrix]

     ret
endp