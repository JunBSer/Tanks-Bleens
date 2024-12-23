
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
        mov      dword [playerCnt], 1

        stdcall Glext.InitShaders, std_program, std_fragmentShader, std_frShaderFilePath, std_vertexShader, std_vrtxShaderFilePath

        stdcall SingleP_InitDrawGame
        ret
endp

proc    TwoPlButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt

        mov      dword [playerCnt], 2

        stdcall  InitServerConBtns

        ret
endp


proc    FourPlButtonHandler uses esi,\
        pObj
        stdcall  ReleaseButtons, [Buttons], ButtonsCnt

        mov      dword [playerCnt], 4

        stdcall  InitServerConBtns
        ret
endp


proc    ReturnGameButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt
        stdcall  ReleaseStObj, [StatObjects], StatObjCnt

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

proc    ReturnSelectMButtonHandler uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt

        stdcall  InitSubMenuBtns
        ret
endp


proc    MenuButtonHandler uses esi,\
        pObj

        stdcall    ReleaseButtons, [Buttons], ButtonsCnt
        stdcall    ReleaseStObj, [StatObjects], StatObjCnt

        mov        dword [appState], 0

        invoke     glBindVertexArray, 0
        invoke     glBindBuffer, GL_ARRAY_BUFFER,0
        invoke     glUseProgram, ebx

        stdcall    ReleaseObjects, [DinObjects], DinObjCnt
        free       dword [DinObjects]
;-----------------------------------------------------
        stdcall    ReleaseTankRes, [tank]
        stdcall    ReleaseStObjRes, [crosshair]
        stdcall    ReleaseStObjRes, [hpBar]
        free       dword [mainCamera]


;If what just delete this
        stdcall    ReleaseTanks, [Targets], TargetCnt
        free       dword [Targets]
;______________________________________________________

        invoke     glDeleteShader, [std_fragmentShader]
        invoke     glDeleteShader, [std_vertexShader]
        invoke     glDeleteProgram, [std_program]

        stdcall    InitDrawStartMenu
        ret
endp


proc    HostBtnHandler uses esi,\
        pObj

        ;int 3
        stdcall Server.Start, [playerCnt]
        stdcall Client.ReadIP

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt

        stdcall  InitCreateBtns

        ret
endp


proc    UsrBtnHandler uses esi,\
        pObj

        stdcall  ReleaseStObj, [StatObjects], StatObjCnt
        stdcall  ReleaseButtons, [Buttons], ButtonsCnt
        stdcall  InitInputPage


        ret
endp


proc    EditHandler uses esi,\
        pObj

        mov     dword [isEditActive], true
        mov     dword [activeEditHandler], ProcessInput

        mov     esi, [edit]

        ret
endp

proc    ReturnToChooseCon uses esi,\
        pObj

        stdcall  ReleaseButtons, [Buttons], ButtonsCnt
        stdcall  ReleaseStObj, [StatObjects], StatObjCnt
        stdcall  InitChooseConTypeMenu
        mov      dword [isEditActive], false

        ret
endp


proc    ConnectHandler uses esi,\
        pObj

        stdcall Network.Start
        stdcall Socket.Create
        stdcall Socket.Connect
        stdcall Client.GetNumber
        mov     esi, eax

        stdcall Glext.InitShaders, std_program, std_fragmentShader, std_frShaderFilePath, std_vertexShader, std_vrtxShaderFilePath

        mov     dword [appState],1

        stdcall MultP_InitDrawGame

        stdcall InitPlayers

        stdcall MakeMapping, [Targets], [tank], esi
        mov     [map], eax

        stdcall SpownPlayers, [map], esi


        ret
endp