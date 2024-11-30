        include         "./Textures.asm"
        include         "./UniformLocations.inc"
        include         "./MapInit.asm"
        include         "./DrawTank.asm"

        program             GLint           0
        fragmentShader      GLuint          0
        vertexShader        GLuint          0
        mainTextID          GLuint          0
        tankTextID          GLuint          0

        frShaderFilePath    db              "Resources/stdFragment.glsl", 0
        vrtxShaderFilePath  db              "Resources/stdVertex.glsl", 0


        cameraPosition  Vector3         0.0, 0.0, 15.0
        targetPosition  Vector3         0.0, 0.0, 0.0
        upVector        Vector3         0.0, 1.0, 0.0

        lightColor      Vector3         0.5, 0.5, 0.5
        lightDir        Vector3         0.0, 1.0, 0.5

        radian          GLfloat         57.32
        fovY            dd              60.0
        zNear           dd              0.001
        zFar            dd              1000.0

        Objects         dd              ?
        objCnt          dd              ?
        objCap          dd              ?

        tank            dd              ?

proc InitDraw  uses edi

     locals
          aspect          dd              ?
     endl
     ;GetUniforms
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


     ;Init textures
     stdcall    InitTexture, mainTxtFilePath
     mov        [mainTextID], eax

     stdcall    InitTexture, tankTxtFilePath
     mov        [tankTextID], eax


     ;Init objArr
     mov         eax, 4
     mov         [objCap],eax
     shl         eax,2
     malloc      eax
     mov         [Objects],eax
     mov         [objCnt],0


     ;Init camera
     malloc  sizeof.Camera
     mov     [mainCamera], eax

     lea     eax, [aspect]
     stdcall InitDrawParams, eax
     stdcall Camera.Init, rotations, positionModel, stdOffset, [mainCamera]

     ;Init matrices
     stdcall     MapInit


     invoke  glMatrixMode, GL_PROJECTION
     invoke  glLoadIdentity

     stdcall Matrix.Projection, [aspect], [fovY], [zNear], [zFar]


     stdcall CreateTank
     mov     [tank], eax

     stdcall SpawnTank, eax, positionModel, turnModel, scaleModel, [speed]

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


proc Draw uses esi ebx
;Limit frame freq

        invoke  glClearColor, 0.3, 0.3, 0.3, 1.0
        invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

        cmp        [program], ebx
        je         @F

        invoke  GetTickCount
        mov     edx, eax
        sub     edx, [LastTime]
        cmp     edx, 13
        jb      .AfterLimitation
        mov     [LastTime], eax

        stdcall    Player.Move

.AfterLimitation:

        invoke     glUseProgram, [program]
        invoke     glUniform3fv, [lightDirLocation], 1, lightDir
        invoke     glUniform3fv, [lightColorLocation], 1, lightColor
        invoke     glUniform3fv, [viewPosLocation], 1, position

        stdcall     Matrix.LoadIdentity, matrixM
        invoke     glUniformMatrix4fv,[modelMatrixLocation],1,GL_FALSE, matrixM
        invoke     glUniformMatrix4fv,[viewMatrixLocation],1,GL_FALSE, matrixV
        invoke     glUniformMatrix4fv,[projMatrixLocation],1,GL_FALSE, matrixPr

        mov     ecx,[objCnt]

.DrawLoop:
        mov        esi, [objCnt]
        sub        esi, ecx
        shl        esi,2

        mov        eax, [Objects]
        push       ecx

        stdcall    DrawObject,  dword[eax+esi]

        ;invoke     glBindVertexArray, 0

        pop     ecx
        loop    .DrawLoop





     @@:

        stdcall    DrawTank, [tank]

        invoke     glUseProgram, ebx
        invoke     SwapBuffers, [hdc]
        ret
endp



proc    ReleaseGraphicsResources uses esi edi


        invoke     glBindVertexArray, 0
        invoke     glBindBuffer, GL_ARRAY_BUFFER,0
        invoke     glUseProgram, ebx


        mov     ecx, [objCnt]
        mov     esi, [Objects]

.LoopFree:
        push    ecx
        mov     edx, [objCnt]
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


proc InitDrawParams uses ebx,\
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


