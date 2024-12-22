        include         "./MapID.asm"

proc    InitPlayers uses esi

        mov     esi, Targets

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