        include         "./MapID.asm"

proc    InitPlayers uses esi

        mov     ecx, [playerCnt]
        sub     ecx, 1

.PlayerInitLoop:
        push    ecx
        stdcall CreateTank


        stdcall AddToObjects, eax, Targets, TargetCap, TargetCnt


        pop     ecx
        loop    .PlayerInitLoop


        ret
endp


proc    SpownPlayers  uses esi edi ebx,\
        map, usrID
        locals
            temp        dd      ?
        endl


        lea        ebx, [positionModel1]
        mov        ecx, [playerCnt]
        mov        edi, [map]
.PlayerSpownLoop:
        push       ecx
        mov        esi, [playerCnt]
        sub        esi, ecx
        mov        edx, esi
        shl        esi,2

        mov        eax, 36
        imul       edx, eax
        mov        [temp], edx
        add        [temp], ebx
        mov        ecx, [temp]
        add        ecx, 12
        lea        edx, [scaleModel]

        push       ecx
        stdcall    SpawnTank, [esi + edi], [temp], ecx, edx, [speed]
        pop        ecx

        shr        esi,2
        cmp        esi, [usrID]
        jne        .Skip

        stdcall    Camera.Init, ecx, [temp], stdOffset, [mainCamera]

.Skip:

        pop     ecx
        loop    .PlayerSpownLoop



        ret
endp