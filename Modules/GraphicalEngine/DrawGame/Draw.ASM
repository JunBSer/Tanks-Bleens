        include                  "./Textures.asm"
        include                  "./UniformLocations.inc"
        include                  "./MapInit.asm"
        include                  "./DrawTank.asm"
        include                  "../../Data/CamMovementData.inc"
        include                  "../../Data/TankMovementData.inc"
        include                  "./ShaderPrograms.inc"
        include                  "./TestData.asm"
        include                  "../../LogicalEngine/Crosshair.asm"
        include                  "./StaticObjects.asm"
        include                  "./HP.asm"


        lightColor               Vector3         0.6, 0.6, 0.6
        lightDir                 Vector3         0.0, 1.0, 0.5


        radian                   GLfloat         57.32
        fovY                     dd              60.0
        zNear                    dd              0.001
        zFar                     dd              1000.0


        DinObjects               dd              ?
        DinObjCnt                dd              ?
        DinObjCap                dd              ?

        tank                     dd              ?

        Targets                  dd              ?
        TargetCnt                dd              ?
        TargetCap                dd              ?

        hpBar                    dd              ?
        lastHp                   dd              ?

        map                      dd              ?

proc SingleP_InitDrawGame  uses edi

     locals
          aspect          dd              ?
     endl

;GetUniforms for std shader program
     stdcall    InitStdProgUniforms, [std_program]
;Init objArr
     mov         eax, 4
     mov         [DinObjCap],eax
     shl         eax,2
     malloc      eax
     mov         [DinObjects],eax
     mov         [DinObjCnt],0


;Init TargetArr
     mov         eax, 4
     mov         [TargetCap],eax
     shl         eax,2
     malloc      eax
     mov         [Targets],eax
     mov         [TargetCnt],0


;Init camera
     malloc  sizeof.Camera
     mov     [mainCamera], eax

     lea     eax, [aspect]
     stdcall InitGameDrawParams, eax
     stdcall Camera.Init, rotations1, positionModel1, stdOffset, [mainCamera]

;Init matrices
     stdcall     MapInit


     invoke  glMatrixMode, GL_PROJECTION
     invoke  glLoadIdentity

     stdcall Matrix.Projection, [aspect], [fovY], [zNear], [zFar]


;Add player's tank

     stdcall CreateTank
     mov     [tank], eax

     stdcall SpawnTank, eax, positionModel1, turnModel1, scaleModel, [speed]

;Add Targets
     stdcall CreateTank
     mov     edi, eax

     stdcall AddToObjects, eax, Targets, TargetCap, TargetCnt

     stdcall SpawnTank, edi, positionModel2, turnModel2, scaleTarget, [speed]

;Init static objects
     stdcall CreateStaticObject, vert, text, normals, [crossTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
     mov     [crosshair], eax

;Init shoot animation
     stdcall CreateStaticObject, vert, text, normals, [shootTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
     mov     [shootAnimObj], eax

     stdcall  CreateStaticObject, uiVert, text, 0, [hpBarTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
     mov      [hpBar], eax

     stdcall  InitHPBar, [hpBar]

        ret
endp



proc MultP_InitDrawGame  uses edi

     locals
          aspect          dd              ?
     endl

;GetUniforms for std shader program
     stdcall    InitStdProgUniforms, [std_program]
;Init objArr
     mov         eax, 4
     mov         [DinObjCap],eax
     shl         eax,2
     malloc      eax
     mov         [DinObjects], eax
     mov         [DinObjCnt], 0


;Init TargetArr
     mov         eax, 4
     mov         [TargetCap],eax
     shl         eax,2
     malloc      eax
     mov         [Targets],eax
     mov         [TargetCnt],0


;Init camera
     malloc  sizeof.Camera
     mov     [mainCamera], eax

     lea     eax, [aspect]
     stdcall InitGameDrawParams, eax
     stdcall Camera.Init, rotations1, positionModel1, stdOffset, [mainCamera]

;Init matrices
     stdcall     MapInit


     invoke  glMatrixMode, GL_PROJECTION
     invoke  glLoadIdentity

     stdcall Matrix.Projection, [aspect], [fovY], [zNear], [zFar]


;Add player's tank

     stdcall CreateTank
     mov     [tank], eax

;Init static objects
     stdcall CreateStaticObject, vert, text, normals, [crossTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
     mov     [crosshair], eax

;Init shoot animation
     stdcall CreateStaticObject, vert, text, normals, [shootTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
     mov     [shootAnimObj], eax

     stdcall  CreateStaticObject, uiVert, text, 0, [hpBarTextID], [vertCnt], GL_STATIC_DRAW, GL_STATIC_DRAW
     mov      [hpBar], eax

     stdcall  InitHPBar, [hpBar]

        ret
endp


proc DrawObject uses edi,\
     obj
     mov        edi, [obj]
     mov        edi, [edi+Object.pMesh]



     invoke     glBindVertexArray, [edi+Mesh.VAO]

     invoke     glBindTexture, GL_TEXTURE_2D, [edi+Mesh.textureID]
     invoke     glUniform1i, [samplerLocation], 0

     invoke     glDrawArrays, GL_TRIANGLES, 0, [edi+Mesh.vertexCnt]

     invoke     glBindVertexArray, 0
     ret
endp


proc DrawGame uses esi edi ebx
;Limit frame freq

        invoke  glClearColor, 0.3, 0.3, 0.3, 1.0
        invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


        invoke  GetTickCount
        mov     edx, eax
        sub     edx, [lastDrawTime]
        cmp     edx, 13
        jb      .AfterLimitation
        mov     [lastDrawTime], eax

        stdcall    Player.Move

.AfterLimitation:
;Draw dinamic objects
        invoke     glUseProgram, [std_program]
        invoke     glUniform3fv, [lightDirLocation], 1, lightDir
        invoke     glUniform3fv, [lightColorLocation], 1, lightColor
        lea        eax,[mainCamera + Camera.position]
        invoke     glUniform3fv, [viewPosLocation], 1,eax

        stdcall    Matrix.LoadIdentity, matrixM
        invoke     glUniformMatrix4fv,[modelMatrixLocation],1,GL_FALSE, matrixM
        invoke     glUniformMatrix4fv,[viewMatrixLocation],1,GL_FALSE, matrixV
        invoke     glUniformMatrix4fv,[projMatrixLocation],1,GL_FALSE, matrixPr

;Draw   map objects
        mov     ecx,[DinObjCnt]
        mov     edi, [DinObjects]
.DrawLoop:
        mov        esi, [DinObjCnt]
        sub        esi, ecx
        shl        esi,2

        push       ecx

        stdcall    DrawObject,  dword[edi+esi]

        pop     ecx

        loop    .DrawLoop

;Draw player's tank
        stdcall    DrawTank, [tank]


;Draw  Targets
        mov     ecx,[TargetCnt]
        cmp     ecx, 0
        je      .Return
        mov     edi, [Targets]
.DrawTargetLoop:
        mov        esi, [TargetCnt]
        sub        esi, ecx
        shl        esi,2

        push       ecx

        mov        eax, [esi + edi]

        fldz
        fld        dword [eax + Tank.hp]
        fcomip     st, st1
        jbe        .Skip
        stdcall    UpdateTarget, [esi + edi]
        stdcall    DrawTank, [esi + edi]
.Skip:
        faddp      st,st
        pop     ecx

        loop    .DrawTargetLoop


;Draw shoot animation
        cmp      [shootAnimTime],0
        je       .SkipAnimDraw
        stdcall  DrawStaticObject, [shootAnimObj], [modelMatrixLocation], [samplerLocation]
        sub      [shootAnimTime],1
.SkipAnimDraw:

;Draw static objects
        invoke  glDisable, GL_DEPTH_TEST
        stdcall DrawStaticObject, [crosshair], [modelMatrixLocation], [samplerLocation]


        invoke     glUseProgram, [stat_program]
        invoke     glUniformMatrix4fv,[stProjMatrixLocation],1, GL_FALSE, matrixPrStat

        stdcall    DrawStaticObject, [hpBar], [stModelMatrixLocation], [stSamplerLocation]

        invoke     glEnable, GL_DEPTH_TEST


.Return:
        invoke     glUseProgram, ebx
        invoke     SwapBuffers, [hdc]
        ret
endp



proc    ReleaseGraphicsResources uses esi edi


        invoke     glBindVertexArray, 0
        invoke     glBindBuffer, GL_ARRAY_BUFFER,0
        invoke     glUseProgram, ebx

        stdcall    ReleaseStObj, [StatObjects], StatObjCnt
        free       [StatObjects]

        stdcall    ReleaseButtons, [Buttons], ButtonsCnt
        free       [Buttons]

        invoke     glDeleteTextures, 8, mainTextID
        free       [mainCamera]

        invoke     glDeleteShader, [stat_fragmentShader]
        invoke     glDeleteShader, [stat_vertexShader]
        invoke     glDeleteProgram,[stat_program]
    ret
endp


proc InitGameDrawParams uses ebx,\
     aspect

     invoke  glViewport, ebx, ebx, [clientRect.right], [clientRect.bottom]

     fild    [clientRect.right]      ; width
     fidiv   [clientRect.bottom]     ; width / height
     mov     ebx, [aspect]
     fstp    dword[ebx]

     xor     ebx, ebx

     invoke  ShowCursor, ebx
     invoke  SetCursorPos, [windowWidthH], [windowHeightH]


     invoke  glEnable, GL_DEPTH_TEST
    ret
endp



proc InitStdProgUniforms,\
     program

     invoke     glGetUniformLocation, [program],modelMtrxName
     mov        [modelMatrixLocation],eax

     invoke     glGetUniformLocation, [program],viewMtrxName
     mov        [viewMatrixLocation],eax

     invoke     glGetUniformLocation, [program],projMtrxName
     mov        [projMatrixLocation],eax

     invoke     glGetUniformLocation, [program],textName
     mov        [samplerLocation],eax

     invoke     glGetUniformLocation, [program],LDName
     mov        [lightDirLocation],eax

     invoke     glGetUniformLocation, [program],VPName
     mov        [viewPosLocation],eax

     invoke     glGetUniformLocation, [program],LCName
     mov        [lightColorLocation],eax

    ret
endp




