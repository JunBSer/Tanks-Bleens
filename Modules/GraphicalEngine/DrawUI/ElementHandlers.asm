proc    PlayButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt

        stdcall  InitSubMenuBtns
        ret
endp

proc    ExitButtonHandler uses esi,\
        pObj

        stdcall ReleaseGraphicsResources

        invoke  ExitProcess, ebx
        xor     eax,eax
        ret
endp


proc    OnePlButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt
        stdcall  ReleaseStObj, [StatObjects], StatObjCnt

        mov      dword [appState],1

        stdcall Glext.InitShaders, std_program, std_fragmentShader, std_frShaderFilePath, std_vertexShader, std_vrtxShaderFilePath

        stdcall InitDrawGame
        ret
endp



proc    ReturnGameButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt

        mov      dword [appState],1

        invoke   ShowCursor, false

        ret
endp



proc    ReturnMenuButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt

        stdcall  InitMMenuBtns
        ret
endp


proc    MenuButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt
        stdcall  ReleaseStObj, [StatObjects], StatObjCnt

        mov      dword [appState], 0

        invoke     glBindVertexArray, 0
        invoke     glBindBuffer, GL_ARRAY_BUFFER,0
        invoke     glUseProgram, ebx

        stdcall    ReleaseObjects, [DinObjects], DinObjCnt
        free       [DinObjects]

        invoke     glDeleteShader, [std_fragmentShader]
        invoke     glDeleteShader, [std_vertexShader]
        invoke     glDeleteProgram, [std_program]

        stdcall  InitDrawStartMenu
        ret
endp


