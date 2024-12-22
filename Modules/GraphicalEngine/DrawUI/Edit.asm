        ipAddr          dd      ?
        inputPointer    dd      0

proc    ProcessInput uses esi,\
        char
        mov     esi, [ipAddr]

        cmp     dword [char], 08h
        je      .ProcessBackspace
        cmp     dword [inputPointer], 15
        je      .Skip
        cmp     dword [char], -1
        je      .Skip

        mov     eax, [inputPointer]
        mov     cl, byte [char]
        mov     [esi + eax], cl
        mov     byte [esi + eax + 1], 0
        add     dword [inputPointer], 1
        jmp     .OuputText

.ProcessBackspace:
        cmp     dword [inputPointer], 0
        je      .Skip
        sub     dword [inputPointer], 1
        mov     eax, [inputPointer]
        mov     byte [esi + eax], 0


.OuputText:
        mov     esi, [edit]
        stdcall ChangeText, [esi + Button.pTextObj], emptyEditText
        cmp     dword [inputPointer], 0
        je      .Skip
        stdcall ChangeText, [esi + Button.pTextObj], [ipAddr]
.Skip:

        ret
endp