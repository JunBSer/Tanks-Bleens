        include         "../../Data/LoadTextures.asm"

        mainTxtFilePath             db     "Resources/Textures/mainTextTry.bmp",0
        tankTxtFilePath             db     "Resources/Textures/textureTry.bmp", 0
        crosshairFilePath           db     "Resources/Textures/crosshair.bmp", 0
        shootFilePath               db     "Resources/Textures/shoot.bmp", 0
        alphabetFilePath            db     "Resources/Textures/alphabet.bmp", 0
        mainMenuFilePath            db     "Resources/Textures/MainMenu.bmp", 0
        subMenuFilePath             db     "Resources/Textures/SubMenu.bmp", 0
        buttonFilePath              db     "Resources/Textures/Button.bmp", 0
        editFilePath                db     "Resources/Textures/edit.bmp", 0
        hpBarFilePath               db     "Resources/Textures/hpBar.bmp", 0

        mainTextID               GLuint          0
        tankTextID               GLuint          0
        crossTextID              GLuint          0
        shootTextID              GLuint          0
        alphtTextID              GLuint          0
        mMenuTextID              GLuint          0
        sMenuTextID              GLuint          0
        btnTextID                GLuint          0
        editTextID               GLuint          0
        hpBarTextID              GLuint          0

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