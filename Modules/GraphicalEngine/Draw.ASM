        include                  "./Textures.asm"
        include                  "./UniformLocations.inc"
        include                  "./MapInit.asm"
        include                  "./DrawTank.asm"
        include                  "../Data/CamMovementData.inc"
        include                  "../Data/TankMovementData.inc"
        include                  "./ShaderPrograms.inc"
        include                  "./TestData.asm"
        include                  "../LogicalEngine/Crosshair.asm"
        include                  "./StaticObjects.asm"


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

        StatObjects              dd              ?
        StatObjCnt               dd              ?
        StatObjCap               dd              ?

proc InitDraw  uses edi

     locals
          aspect          dd              ?
     endl
     ;GetUniforms for std shader program
     ;stdcall    InitStatProgUniforms, [stat_program]
     stdcall    InitStdProgUniforms, [std_program]


     ;Init textures
     stdcall    InitTexture, mainTxtFilePath
     mov        [mainTextID], eax

     stdcall    InitTexture, tankTxtFilePath
     mov        [tankTextID], eax

     stdcall    InitTexture, crosshairFilePath
     mov        [crossTextID],eax

     ;Init objArr
     mov         eax, 4
     mov         [DinObjCap],eax
     shl         eax,2
     malloc      eax
     mov         [DinObjects],eax
     mov         [DinObjCnt],0


     ;Init camera
     malloc  sizeof.Camera
     mov     [mainCamera], eax

     lea     eax, [aspect]
     stdcall InitGameDrawParams, eax
     stdcall Camera.Init, rotations, positionModel, stdOffset, [mainCamera]

     ;Init matrices
     stdcall     MapInit


     invoke  glMatrixMode, GL_PROJECTION
     invoke  glLoadIdentity

     stdcall Matrix.Projection, [aspect], [fovY], [zNear], [zFar]




     stdcall CreateTank
     mov     [tank], eax

     stdcall SpawnTank, eax, positionModel, turnModel, scaleModel, [speed]


     stdcall CreateStaticObject, vert, text, normals, [crossTextID], [vertCnt]
     mov     [crosshair], eax
     stdcall InitCrosshair, [crosshair], [tank], shootPointOffs, crosshairOffs, crosshairSize

        ret
endp



proc DrawObject uses edi,\
     obj
     mov        edi, [obj]
     mov        edi, [edi+Object.pMesh]



     invoke     glBindVertexArray, [edi+Mesh.VAO]


     ;invoke     glActiveTexture, GL_TEXTURE0
     invoke     glBindTexture, GL_TEXTURE_2D, [edi+Mesh.textureID]
     invoke     glUniform1i, [samplerLocation], 0

     invoke     glDrawArrays, GL_TRIANGLES, 0, [edi+Mesh.vertexCnt]

     invoke     glBindVertexArray, 0
     ret
endp


proc DrawGame uses esi ebx
;Limit frame freq

        invoke  glClearColor, 0.3, 0.3, 0.3, 1.0
        invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT


        invoke  GetTickCount
        mov     edx, eax
        sub     edx, [LastTime]
        cmp     edx, 13
        jb      .AfterLimitation
        mov     [LastTime], eax

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

        mov     ecx,[DinObjCnt]

.DrawLoop:
        mov        esi, [DinObjCnt]
        sub        esi, ecx
        shl        esi,2

        mov        eax, [DinObjects]
        push       ecx

        stdcall    DrawObject,  dword[eax+esi]

        pop     ecx
        loop    .DrawLoop

     @@:

        stdcall    DrawTank, [tank]
        stdcall    DrawStaticObject, [crosshair]


.Return:
        invoke     glUseProgram, ebx
        invoke     SwapBuffers, [hdc]
        ret
endp



proc    ReleaseGraphicsResources uses esi edi


        invoke     glBindVertexArray, 0
        invoke     glBindBuffer, GL_ARRAY_BUFFER,0
        invoke     glUseProgram, ebx


        mov     ecx, [DinObjCnt]
        mov     esi, [DinObjects]

.LoopFree:
        push    ecx
        mov     edx, [DinObjCnt]
        sub     edx, ecx

        push    edx

        mov     edi, [esi+edx*4]

        free    [edi+Object.pAABB]
        free    [edi+Object.pOBB]

        mov     edi, [edi+Object.pMesh]

        lea     eax, [edi+Mesh.VAO]
        invoke  glDeleteVertexArrays, 1, eax

        lea     eax, [edi+Mesh.VBOvert]
        invoke  glDeleteBuffers, 1, eax

        lea     eax, [edi+Mesh.VBOnorm]
        invoke  glDeleteBuffers, 1, eax

        lea     eax, [edi+Mesh.VBOtex]
        invoke  glDeleteBuffers, 1, eax

        free    edi

        pop     edx

        pop     ecx
        loop    .LoopFree

        invoke  glDeleteTextures, 2, mainTextID
        free    [mainCamera]
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
     mov     eax, [clientRect.right]
     sar     eax, 1
     mov     [windowWidthH], eax
     mov     eax, [clientRect.bottom]
     sar     eax, 1
     mov     [windowHeightH], eax
     xor     eax, eax
     invoke  SetCursorPos, [windowWidthH], [windowHeightH]

    ret
endp

proc InitUIElemMtrx
     locals
         height         dd      ?
         width          dd      ?
     endl
     fild       dword[clientRect.right]
     fstp       dword[width]

     fild       dword[clientRect.bottom]
     fstp       dword[height]

     stdcall Matrix.Ortho, matrixPrStat, 0.0, [width], 0.0, [height], -1.0, 1.0

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

proc InitStatProgUniforms,\
     program

     invoke     glGetUniformLocation, [program],stModelMtrxName
     mov        [stModelMatrixLocation],eax

     invoke     glGetUniformLocation, [program],stViewMtrxName
     mov        [stViewMatrixLocation],eax

     invoke     glGetUniformLocation, [program],stProjMtrxName
     mov        [stProjMatrixLocation],eax

     invoke     glGetUniformLocation, [program],stTextName
     mov        [stSamplerLocation],eax

    ret
endp


