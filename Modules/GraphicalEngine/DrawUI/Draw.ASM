        include         "./Text.asm"

        hui     db      'Sosal?',0
        trialText      dd      ?

proc    InitDrawUI
        stdcall    InitStatProgUniforms, [stat_program]

        stdcall    InitTexture, alphabetFilePath
        mov        [alphtTextID], eax

        stdcall    InitDrawStartMenu

        stdcall    Matrix.LoadIdentity, matrixPrStat

        stdcall Matrix.Ortho, matrixPrStat, -10.0, 10.0, -10.0, 10.0, 1.0, 10.0

    ret
endp

proc    InitDrawStartMenu
        locals
                scale           Vector3  1.0, 1.0, 1.0
                translate       Vector3  0.0, 0.0, 0.0
        endl

        stdcall CreateText, hui, [alphtTextID]
        mov     [trialText], eax

        lea     eax, [scale]
        lea     edx, [translate]
        stdcall SetTxtParams, [trialText], eax, edx

    ret
endp



proc    DrawStartMenu

       invoke  glClearColor, 1.0, 1.0, 1.0, 1.0
       invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

       cmp        dword [stat_program], ebx
       je         .Return
       invoke     glUseProgram, [stat_program]
       invoke     glUniformMatrix4fv,[stProjMatrixLocation],1,GL_FALSE, matrixPrStat
       stdcall    DrawStaticObject, [trialText], [stModelMatrixLocation], [stSamplerLocation]

.Return:
        invoke     glUseProgram, ebx
        invoke     SwapBuffers, [hdc]

    ret
endp

