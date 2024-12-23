        include         "../../Data/ButtonClass.inc"
        include         "./Text.asm"
        include         "./Button.asm"
        include         "./Edit.asm"
        include         "./MenuText.inc"

        StatObjects              dd              ?
        StatObjCnt               dd              ?
        StatObjCap               dd              ?

        Buttons                  dd              ?
        ButtonsCnt               dd              ?
        ButtonsCap               dd              ?

        resolutScale             dd              ?

        activeEditHandler        dd              0
        isEditActive             dd              false

        edit                     dd              ?



proc    InitDrawUI


        invoke     LoadCursor, 0, IDC_ARROW
        invoke     SetCursor, eax

        stdcall    InitStatProgUniforms, [stat_program]

        stdcall    InitTexture, alphabetFilePath
        mov        [alphtTextID], eax

        stdcall    InitTexture, mainMenuFilePath
        mov        [mMenuTextID], eax

        stdcall    InitTexture, subMenuFilePath
        mov        [sMenuTextID], eax

        stdcall    InitTexture, buttonFilePath
        mov        [btnTextID], eax

        stdcall    InitTexture, editFilePath
        mov        [editTextID], eax



        stdcall    SetProjMtrx
;Init Buttons arr
        mov         eax, 4
        mov         [ButtonsCap],eax
        shl         eax,2
        malloc      eax
        mov         [Buttons],eax
        mov         [ButtonsCnt],0

;Init static obj arr
        mov         eax, 4
        mov         [StatObjCap],eax
        shl         eax,2
        malloc      eax
        mov         [StatObjects],eax
        mov         [StatObjCnt],0

        stdcall    InitDrawStartMenu

        malloc   16
        mov      [ipAddr], eax

    ret
endp

proc    InitDrawStartMenu uses esi
        locals
                menuScale       Vector3  1536.0, 864.0, 1.0
                menuTranslate   Vector3  -768.0, -432.0, 0.0
        endl

;Init main background
        stdcall  CreateStaticObject, uiVert, text, 0, [mMenuTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
        mov      esi, eax
        stdcall  InitStObjParams, esi
        stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
        lea      eax, [menuScale]
        lea      edx, [menuTranslate]
        stdcall  SetStObjParams, esi, eax, edx

        stdcall  InitMMenuBtns

    ret
endp


proc    InitDrawGameMenu uses esi
        locals
                menuScale       Vector3  1536.0, 864.0, 1.0
                menuTranslate   Vector3  -768.0, -432.0, 0.0
        endl

;Init main background
        mov      dword [appState],0

        stdcall  CreateStaticObject, uiVert, text, 0, [sMenuTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
        mov      esi, eax
        stdcall  InitStObjParams, esi
        stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
        lea      eax, [menuScale]
        lea      edx, [menuTranslate]
        stdcall  SetStObjParams, esi, eax, edx

        stdcall  InitGameMenuBtns

        invoke   ShowCursor, true
        invoke   glDisable, GL_DEPTH_TEST
    ret
endp


proc   DrawMenu uses esi edi ebx

       invoke  glClearColor, 1.0, 1.0, 1.0, 1.0
       invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

       cmp        dword [stat_program], ebx
       je         .Return

       invoke     glUseProgram, [stat_program]
       invoke     glUniformMatrix4fv,[stProjMatrixLocation],1, GL_FALSE, matrixPrStat


;Draw Static Objects
       mov     ecx, [StatObjCnt]
       mov     edi, [StatObjects]
.DrawStObjLoop:
       mov        esi, [StatObjCnt]
       sub        esi, ecx
       shl        esi,2

       push       ecx

       stdcall    DrawStaticObject, [edi + esi], [stModelMatrixLocation], [stSamplerLocation]

       pop     ecx

       loop    .DrawStObjLoop


;Draw buttons
       mov     ecx, [ButtonsCnt]
       cmp     ecx, 0
       je      .Return
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

proc InitMMenuBtns uses esi
     locals
            playBtnScale           Vector3  1.0, 1.0, 1.0
            playBtnTranslate       Vector3  -700.0, 100.0, 0.0

            exitBtnScale           Vector3  1.0, 1.0, 1.0
            exitBtnTranslate       Vector3  -700.0, -200.0, 0.0
     endl
        stdcall  CreateButton, playTxt, [btnTextID], [alphtTextID], PlayButtonHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea     eax, [playBtnScale]
        lea     edx, [playBtnTranslate]
        mov     esi, [Buttons]
        stdcall SetButtonParams, [esi], eax, edx


        stdcall  CreateButton, exitTxt, [btnTextID], [alphtTextID], ExitButtonHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea     eax, [exitBtnScale]
        lea     edx, [exitBtnTranslate]
        stdcall SetButtonParams, [esi+4], eax, edx

     ret
endp


proc InitGameMenuBtns  uses esi
      locals
            btnScale           Vector3  1.0, 1.0, 1.0
            menuBtnTranslate   Vector3  -250.0, 100.0, 0.0
            retBtnTranslate    Vector3  -350.0, -150.0, 0.0
      endl
        stdcall  CreateButton, menuTxt, [btnTextID], [alphtTextID], MenuButtonHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea     eax, [btnScale]
        lea     edx, [menuBtnTranslate]
        mov     esi, [Buttons]
        stdcall SetButtonParams, [esi], eax, edx


        stdcall  CreateButton, retTxt, [btnTextID], [alphtTextID], ReturnGameButtonHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea      eax, [btnScale]
        lea      edx, [retBtnTranslate]
        stdcall  SetButtonParams, [esi+4], eax, edx

     ret
endp

proc InitSubMenuBtns uses esi

      locals
            btnScale               Vector3   0.5, 0.5, 1.0
            menuBtnTranslate       Vector3  -700.0, 200.0, 0.0
            plOneBtnTranslate      Vector3  -700.0, 50.0, 0.0
            plTwoBtnTranslate      Vector3  -700.0, -100.0, 0.0
            retBtnTranslate        Vector3  -650.0, -300.0, 0.0
      endl
      stdcall  CreateButton, onePlayerTxt, [btnTextID], [alphtTextID], OnePlButtonHandler
      stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
      lea     eax, [btnScale]
      lea     edx, [menuBtnTranslate]
      mov     esi, [Buttons]
      stdcall SetButtonParams, [esi], eax, edx


      stdcall  CreateButton, twoPlayersTxt, [btnTextID], [alphtTextID], TwoPlButtonHandler
      stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
      lea     eax, [btnScale]
      lea     edx, [plOneBtnTranslate]
      stdcall SetButtonParams, [esi+4], eax, edx


      stdcall  CreateButton, fourPlayersTxt, [btnTextID], [alphtTextID], FourPlButtonHandler
      stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
      lea     eax, [btnScale]
      lea     edx, [plTwoBtnTranslate]
      stdcall SetButtonParams, [esi+8], eax, edx


      stdcall  CreateButton, retTxt, [btnTextID], [alphtTextID], ReturnMenuButtonHandler
      stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
      lea     eax, [btnScale]
      lea     edx, [retBtnTranslate]
      stdcall SetButtonParams, [esi+12], eax, edx



     ret
endp


proc InitMultiplMenuBtns  uses esi
      locals
            btnScale           Vector3  1.0, 1.0, 1.0
            menuBtnTranslate   Vector3  -250.0, 100.0, 0.0
            retBtnTranslate    Vector3  -350.0, -150.0, 0.0
      endl
        stdcall  CreateButton, menuTxt, [btnTextID], [alphtTextID], MenuButtonHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea     eax, [btnScale]
        lea     edx, [menuBtnTranslate]
        mov     esi, [Buttons]
        stdcall SetButtonParams, [esi], eax, edx


        stdcall  CreateButton, retTxt, [btnTextID], [alphtTextID], ReturnGameButtonHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea      eax, [btnScale]
        lea      edx, [retBtnTranslate]
        stdcall  SetButtonParams, [esi+4], eax, edx

     ret
endp


proc InitServerConBtns uses esi
     locals
            btnScale           Vector3  0.5, 0.5, 1.0
            hostBtnTranslate   Vector3  -650.0,  200.0, 0.0
            userBtnTranslate   Vector3  -650.0,  50.0, 0.0
            retBtnTranslate    Vector3  -700.0,  -100.0, 0.0
     endl
         mov     esi, [Buttons]
        stdcall  CreateButton, createGTxt, [btnTextID], [alphtTextID], HostBtnHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea     eax, [btnScale]
        lea     edx, [hostBtnTranslate]
        stdcall SetButtonParams, [esi], eax, edx


        stdcall  CreateButton, joinGTxt, [btnTextID], [alphtTextID], UsrBtnHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea      eax, [btnScale]
        lea      edx, [userBtnTranslate]
        stdcall  SetButtonParams, [esi+4], eax, edx

        stdcall  CreateButton, retTxt, [btnTextID], [alphtTextID], ReturnSelectMButtonHandler
        stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
        lea      eax, [btnScale]
        lea      edx, [retBtnTranslate]
        stdcall  SetButtonParams, [esi+8], eax, edx

     ret
endp

proc  InitInputPage uses esi
      locals
           btnScale        Vector3  0.5, 0.5, 1.0
           editScale       Vector3  0.4, 0.5, 1.0
           menuScale       Vector3  1536.0, 864.0, 1.0
           menuTranslate   Vector3  -768.0, -432.0, 0.0
           editTranslate   Vector3  -150.0, 100.0, 0.0
           retBtnTranslate Vector3  -700.0, -100.0, 0.0
           txtTranslate    Vector3  -25.0, 200.0, 0.0
           conBtnTranslate Vector3  0.0, -100.0, 0.0
      endl

      stdcall  CreateStaticObject, uiVert, text, 0, [sMenuTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
      mov      esi, eax
      stdcall  InitStObjParams, esi
      stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
      lea      eax, [menuScale]
      lea      edx, [menuTranslate]
      stdcall  SetStObjParams, esi, eax, edx


      stdcall  CreateButton, emptyEditText, [editTextID], [alphtTextID], EditHandler
      mov      [edit], eax
      stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
      lea      eax, [editScale]
      lea      edx, [editTranslate]
      mov      esi, [Buttons]
      stdcall  SetButtonParams, [esi], eax, edx


      stdcall  CreateButton, retTxt, [btnTextID], [alphtTextID], ReturnToChooseCon
      stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
      lea      eax, [btnScale]
      lea      edx, [retBtnTranslate]
      stdcall  SetButtonParams, [esi+4], eax, edx

        stdcall  CreateButton, connectTxt, [btnTextID], [alphtTextID], ConnectHandler
      stdcall  AddToObjects, eax, Buttons, ButtonsCap, ButtonsCnt
      lea      eax, [btnScale]
      lea      edx, [conBtnTranslate]
      stdcall  SetButtonParams, [esi+8], eax, edx

      stdcall  CreateText, stdEditText, [alphtTextID], GL_STATIC_DRAW, GL_STATIC_DRAW
      mov      esi, eax
      stdcall  InitStObjParams, esi
      stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
      lea      eax, [btnScale]
      lea      edx, [txtTranslate]
      stdcall  SetStObjParams, esi, eax, edx

      ret
endp


proc  InitChooseConTypeMenu uses esi
      locals
           menuScale       Vector3  1536.0, 864.0, 1.0
           menuTranslate   Vector3  -768.0, -432.0, 0.0
      endl

      stdcall  CreateStaticObject, uiVert, text, 0, [mMenuTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
      mov      esi, eax
      stdcall  InitStObjParams, esi
      stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
      lea      eax, [menuScale]
      lea      edx, [menuTranslate]
      stdcall  SetStObjParams, esi, eax, edx

      stdcall  InitServerConBtns

      ret
endp


proc InitDeathDisplay uses esi
     locals
           menuScale       Vector3  1536.0, 864.0, 1.0
           menuTranslate   Vector3  -768.0, -432.0, 0.0

           txtDTranslate   Vector3  -250.0, 200.0, 0.0
           txtWTranslate   Vector3  -500.0, -100.0, 0.0
           txtScale        Vector3  0.5, 0.5, 1.0

      endl

      stdcall  CreateStaticObject, uiVert, text, 0, [sMenuTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
      mov      esi, eax
      stdcall  InitStObjParams, esi
      stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
      lea      eax, [menuScale]
      lea      edx, [menuTranslate]
      stdcall  SetStObjParams, esi, eax, edx

      stdcall  CreateText, deathTxt, [alphtTextID], GL_STATIC_DRAW, GL_STATIC_DRAW
      mov      esi, eax
      stdcall  InitStObjParams, esi
      stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
      lea      eax, [txtScale]
      lea      edx, [txtDTranslate]
      stdcall  SetStObjParams, esi, eax, edx


      stdcall  CreateText, waitTxt, [alphtTextID], GL_STATIC_DRAW, GL_STATIC_DRAW
      mov      esi, eax
      stdcall  InitStObjParams, esi
      stdcall  AddToObjects, esi, StatObjects, StatObjCap, StatObjCnt
      lea      eax, [txtScale]
      lea      edx, [txtWTranslate]
      stdcall  SetStObjParams, esi, eax, edx


     ret
endp
