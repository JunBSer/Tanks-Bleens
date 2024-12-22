proc  MakeMapping uses esi edi ebx,\
      Targets, pMainTank, usrId

      locals
            map         dd      ?

            temp        dd      ?
      endl

            malloc      4*4
            mov         [map], eax

            mov         esi, [pMainTank]
            mov         edi, [map]
            mov         eax, [usrId]
            mov         [esi + Tank.id], eax
            shl         eax, 2
            mov         edx, [pMainTank]
            mov         dword [edi + eax], edx

            mov         ecx, [playerCnt]
            mov         ebx, [Targets]
            mov         edx, 0
.MappingLoop:
            push       ecx
            mov        esi, [playerCnt]
            sub        esi, ecx
            cmp        esi, [usrId]
            je         .Skip
            shl        esi,2

            mov        ecx, edx
            shl        ecx, 2
            mov        eax,  [ebx + ecx]
            push       esi
            shr        esi, 2
            mov        dword [eax + Tank.id],esi
            pop        esi
            mov        dword [edi + esi], eax

            add        edx, 1
.Skip:
            pop        ecx
            loop        .MappingLoop
            mov        eax, edi

      ret
endp