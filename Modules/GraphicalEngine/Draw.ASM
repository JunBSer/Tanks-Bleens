        include         "./Textures.asm"
        include         "./UniformLocations.inc"
        include         "./MapInit.asm"

        program             GLint           0
        fragmentShader      GLuint          0
        vertexShader        GLuint          0
        textureID           GLuint          0

        frShaderFilePath    db              "Resources/stdFragment.glsl", 0
        vrtxShaderFilePath  db              "Resources/stdVertex.glsl", 0


        cameraPosition  Vector3         0.0, 0.0, 15.0
        targetPosition  Vector3         0.0, 0.0, 0.0
        upVector        Vector3         0.0, 1.0, 0.0

        lightColor      Vector3         0.6, 0.6, 0.6
        lightDir        Vector3         0.0, 0.0, 1.0

        radian          GLfloat         57.32
        fovY            dd              60.0
        zNear           dd              0.001
        zFar            dd              1000.0

        Objects         dd              ?
        objCnt          dd              ?
        objCap          dd              ?



proc InitDraw  uses edi
     locals
         tempFileMesh      dd              ?
     endl


     ;GetUniforms
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


     ;Init textures
     stdcall    InitTexture, textureFileName
     mov        [textureID], eax


     ;Init objArr
     mov         eax, 4
     mov         [objCap],eax
     shl         eax,2
     malloc      eax
     mov         [Objects],eax
     mov         [objCnt],0

     stdcall     MapInit



        ret
endp



proc DrawObject uses edi,\
     obj
     mov        edi, [obj]
     mov        edi, [edi+Object.pMesh]



     invoke     glBindVertexArray, [edi+Mesh.VAO]


     invoke     glActiveTexture, GL_TEXTURE0
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
        invoke     glUniform3fv, [viewPosLocation], 1, position
        stdcall    Camera.Move
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



       ; invoke     glBindVertexArray, 0


        pop     ecx
        loop    .DrawLoop
     @@:
        invoke     glUseProgram, ebx
        invoke     SwapBuffers, [hdc]
        ret
endp