        include         "./TestData.asm"
        include         "./Textures.asm"
        include         "./UniformLocations.inc"

        program         GLint           0
        fragmentShader  GLuint          0
        vertexShader    GLuint          0
        textureID       GLuint          0
        frShaderFile    db              "Modules/GraphicalEngine/Resources/stdFragment.glsl", 0
        vrtxShaderFile  db              "Modules/GraphicalEngine/Resources/stdVertex.glsl", 0

        cameraPosition  Vector3         -4.0, -4.0, 4.0
        targetPosition  Vector3         0.0, 0.0, 0.0
        upVector        Vector3         0.0, 0.0, 1.0

        lightColor      Vector3         1.0, 1.0, 1.0
        lightDir        Vector3         0.0, 0.0, -1.0

        radian          GLfloat         57.32
        fovY            dd              60.0
        zNear           dd              0.001
        zFar            dd              1000.0

        Objects         dd              ?
        objCnt          dd              ?
        objCap          dd              ?



proc InitDraw  uses edi

     invoke     glGetUniformLocation, [program],modelname
     mov        [modelViewMatrixLocation],eax

     invoke     glGetUniformLocation, [program],projname
     mov        [projMatrixLocation],eax

     invoke     glGetUniformLocation, [program],texname
     mov        [samplerLocation],eax

     invoke     glGetUniformLocation, [program],LDName
     mov        [lightDirLocation],eax

     invoke     glGetUniformLocation, [program],VPName
     mov        [viewPosLocation],eax

     invoke     glGetUniformLocation, [program],LCName
     mov        [lightColorLocation],eax



     mov         eax, 4
     mov         [objCap],eax
     shl         eax,2
     malloc      eax
     mov         [Objects],eax
     mov         [objCnt],0

     stdcall    InitTexture, textureFileName
     mov        [textureID], eax



     stdcall    CreateMesh, vert, norm, txt, [textureID], [vertCnt]
    ; mov        [objectTemp],eax
     stdcall    AddToMeshes,eax

     ;stdcall    CreateMesh, vert2,[vertCnt], clr2, [colorCnt]
     ;stdcall    AddToMeshes,eax







    ; stdcall Draw
        ret
endp



proc DrawObject uses edi,\
     obj
     mov        edi, [obj]




     invoke     glBindVertexArray, [edi+Mesh.VAO]



     ;invoke     glActiveTexture, GL_TEXTURE0
     invoke     glBindTexture, GL_TEXTURE_2D, [edi+Mesh.textureID]
     invoke     glUniform1i, [samplerLocation], 0

     invoke     glDrawArrays, GL_TRIANGLES, 0, [edi+Mesh.vertexCnt]

     invoke     glBindVertexArray, 0
     ret
endp


proc Draw uses esi ebx


        xor     ebx,ebx

        invoke  glClearColor, 0.3, 0.3, 0.3, 1.0
        invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT



        cmp     [program], ebx
        je      @F

        invoke     glUseProgram, [program]

        invoke     glUniform3fv, [lightDirLocation], 1, lightDir
        invoke     glUniform3fv, [lightColorLocation], 1, lightColor
        invoke     glUniform3fv, [viewPosLocation], 1, cameraPosition
        invoke     glUniformMatrix4fv,[modelViewMatrixLocation],1,GL_FALSE, matrixX
        invoke     glUniformMatrix4fv,[projMatrixLocation],1,GL_FALSE, matrixPr


        mov     ecx,[objCnt]

.DrawLoop:


        mov        esi, [objCnt]
        sub        esi, ecx
        shl        esi,2

        mov        eax, [Objects]
        push       ecx
        stdcall    DrawObject,  [eax+esi]
        ;dop


        invoke     glBindVertexArray, 0


        pop     ecx
        loop    .DrawLoop
     @@:
        invoke     glUseProgram, ebx
        invoke     SwapBuffers, [hdc]
        ret
endp