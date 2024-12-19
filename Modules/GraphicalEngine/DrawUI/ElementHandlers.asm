proc    PlayButtonHandler uses esi,\
        pObj

        mov     esi, [pObj]
        mov     dword [esi + Button.visible], 0


        ret
endp