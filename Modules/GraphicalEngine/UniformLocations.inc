;Dinamic uniforms
        modelMatrixLocation               GLint   ?
        modelMtrxName                     db      "u_ModelMatrix",0

        viewMatrixLocation                GLint   ?
        viewMtrxName                      db      "u_ViewMatrix",0

        projMatrixLocation                GLint   ?
        projMtrxName                      db      "u_ProjectionMatrix",0

        samplerLocation                   GLint   ?
        textName                          db      "texture1",0

        lightDirLocation                  GLint   ?
        LDName                            db      "lightDir",0
  
        viewPosLocation                   GLint   ?
        VPName                            db      "viewPos",0

        lightColorLocation                GLint   ?
        LCName                            db      "lightColor",0

;Static uniforms
        stModelMatrixLocation             GLint   ?
        stModelMtrxName                   db      "model",0   

        stViewMatrixLocation              GLint   ?
        stViewMtrxName                    db      "view",0

        stProjMatrixLocation              GLint   ?
        stProjMtrxName                    db      "projection",0      

        stSamplerLocation                 GLint   ?
        stTextName                        db      "textureStatic",0 