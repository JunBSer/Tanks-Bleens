        include         "../../Data/ButtonClass.inc"
        include         "./Text.asm"
        include         "./Button.asm"
        include         "./MenuText.inc"

        StatObjects              dd              ?
        StatObjCnt               dd              ?
        StatObjCap               dd              ?

        Buttons                  dd              ?
        ButtonsCnt               dd              ?
        ButtonsCap               dd              ?

        resolutScale   dd      ?

proc    InitDrawUI


        invoke     LoadCursor, 0, IDC_ARROW
        invoke     SetCursor, eax

        stdcall    InitStatProgUniforms, [stat_program]

        stdcall    InitTexture, alphabetFilePath
        mov        [alphtTextID], eax

        stdcall    SetProjMtrx

        mov         eax, 4
        mov         [ButtonsCap],eax
        shl         eax,2
        malloc      eax
        mov         [Buttons],eax
        mov         [ButtonsCnt],0

        stdcall    InitDrawStartMenu



    ret
endp

proc    InitDrawStartMenu
        locals
                scale           Vector3  1.0, 1.0, 1.0
                translate       Vector3  -768.0, 0.0, 0.0
        endl


        stdcall  CreateButton, playTxt, [tankTextID], [alphtTextID], PlayButtonHandler

        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt

        ;lea     eax, [scale]
        ;lea     edx, [translate]
        ;stdcall SetButtonParams, [StatObjects], eax, edx

       ; mov     eax, [StatObjects]
        ;stdcall IsCursorOverStObject, [eax], 100, 500


    ret
endp



proc    DrawStartMenu

       invoke  glClearColor, 1.0, 1.0, 1.0, 1.0
       invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

       cmp        dword [stat_program], ebx
       je         .Return

       invoke     glUseProgram, [stat_program]
       invoke     glUniformMatrix4fv,[stProjMatrixLocation],1, GL_FALSE, matrixPrStat

       mov     ecx, [ButtonsCnt]
       mov     edi, [Buttons]
.DrawButtonLoop:
       mov        esi, [ButtonsCnt]
       sub        esi, ecx
       shl        esi,2

       push       ecx

       mov        eax, [esi + edi]
       cmp        dword [eax + Button.visible], true
       jne        .Skip

       stdcall    DrawButton, [edi + esi]

.Skip:
       pop     ecx

       loop    .DrawButtonLoop


.Return:
       invoke     glUseProgram, ebx
       invoke     SwapBuffers, [hdc]

    ret
endp



proc    SetProjMtrx

        locals
            widthH      dd      ?
            heightH     dd      ?

            temp        dd      ?
        endl

        fild       [windowWidthH]
        fst        [widthH]
        fchs
        fstp       [temp]
        mov        eax, [temp]     ;- Width

        fild       [windowHeightH]
        fst        [heightH]
        fchs
        fstp       [temp]
        mov        ecx, [temp]     ;- Height

        stdcall    Matrix.Ortho, matrixPrStat, eax, [widthH], ecx, [heightH], -1.0, 1.0

        ret
endp


