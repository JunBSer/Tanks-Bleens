        include         "../Data/LoadTextures.asm"

        mainTxtFilePath             db     "Resources/mainTextTry.bmp",0
        tankTxtFilePath             db     "Resources/textureTry.bmp", 0
        crosshairFilePath           db     "Resources/crosshair.bmp", 0

        mainTextID               GLuint          0
        tankTextID               GLuint          0
        crossTextID              GLuint          0


proc    LinkTexture uses edi,\
        pTextureData, imgSizes

        locals
            textureID   dd      ?
        endl

        malloc  4
        mov     [textureID], eax

        invoke  glGenTextures, 1, [textureID]
        mov     edi, [textureID]
        invoke  glBindTexture, GL_TEXTURE_2D, [edi]

        invoke  glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
        invoke  glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
        invoke  glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT
        invoke  glTexParameteri, GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT

        mov     edi, [imgSizes]

        invoke  glTexImage2D, GL_TEXTURE_2D, 0, GL_RGBA, [edi+Vector2.u], [edi+Vector2.v], 0, GL_RGBA, GL_UNSIGNED_BYTE, [pTextureData]

        invoke  glGenerateMipmap, GL_TEXTURE_2D
        invoke  glBindTexture, GL_TEXTURE_2D, 0

        free    [pTextureData]

        mov     edi, [textureID]
        mov     eax, [edi]
        ret
endp


proc    InitTexture uses edi,\
        textureFileName
        locals
        imgSizes        dd      ?
        textureId       dd      ?
        endl
        malloc  sizeof.Vector2
        mov     [imgSizes],eax

        stdcall LoadTexture, [textureFileName], [imgSizes]

        stdcall LinkTexture, eax, [imgSizes]
        mov     [textureId], eax

        free    [imgSizes]

        mov     eax, [textureId]
        ret
endp