proc CreateStaticObject uses esi edi,\
     vertices, textCoords, normals, textureID, vertexCnt, typeTextVBO, typeVertVBO

     locals
         pStaticObject          dd      ?
         pMesh                  dd      ?
         pModelMatrix           dd      ?
     endl

     stdcall    CreateMesh, [vertices], [normals], [textCoords], [textureID], [vertexCnt], [typeTextVBO], [typeVertVBO]
     mov        [pMesh], eax

     malloc     sizeof.Matrix4x4
     mov        [pModelMatrix], eax

     malloc     sizeof.StaticObject
     mov        [pStaticObject], eax

     mov        edi, [pStaticObject]

     mov        eax, [pMesh]
     mov        [edi + StaticObject.pMesh], eax

     mov        eax, [pModelMatrix]
     mov        [edi + StaticObject.pModelMatrix], eax

     mov        eax, edi

    ret
endp

proc    ReleaseStObjRes uses esi,\
        pStObj

        mov     esi, [pStObj]
        stdcall ReleaseMeshRes, [esi + StaticObject.pMesh]

        free    [esi + StaticObject.pModelMatrix]

        free    esi
        ret
endp


proc DrawStaticObject uses edi esi,\
     pObj, matrLoc, samplerLoc

     mov        esi, [pObj]
     mov        edi, [esi+StaticObject.pMesh]



     invoke     glBindVertexArray, [edi+Mesh.VAO]



     invoke     glBindTexture, GL_TEXTURE_2D, [edi+Mesh.textureID]
     invoke     glUniform1i, [samplerLoc], 0

     invoke     glUniformMatrix4fv, [matrLoc], 1, GL_FALSE, [esi+StaticObject.pModelMatrix]

     invoke     glDrawArrays, GL_TRIANGLES, 0, [edi+Mesh.vertexCnt]

    ; invoke     glBindVertexArray, 0

     ret
endp


proc InitStatProgUniforms,\
     program

     invoke     glGetUniformLocation, [program],stModelMtrxName
     mov        [stModelMatrixLocation],eax

     invoke     glGetUniformLocation, [program],stProjMtrxName
     mov        [stProjMatrixLocation],eax

     invoke     glGetUniformLocation, [program],stTextName
     mov        [stSamplerLocation],eax

    ret
endp

proc InitStObjParams uses esi,\
     pStObj

     mov        esi, [pStObj]

     stdcall    Matrix.LoadIdentity, matrixM

     stdcall    Matrix.Scale, matrixS, [resolutScale]
     stdcall    Matrix.Multiply, matrixS, matrixM, [esi + StaticObject.pModelMatrix]

     mov        eax, esi
     ret
endp


proc SetStObjParams uses esi,\
     pStObj, scale, translation

     mov     esi, [pStObj]

     stdcall Matrix.Scale, matrixS, [scale]
     stdcall Matrix.Translate, matrixT, [translation]

     stdcall Matrix.Copy, matrixM, [esi + StaticObject.pModelMatrix]

     stdcall Matrix.Multiply, matrixS, matrixT, matrixR
     stdcall Matrix.Multiply, matrixR, matrixM, [esi + StaticObject.pModelMatrix]

     ret
endp

proc ReleaseStObj uses esi edi ebx,\
     stObjects, pStObjCnt

      mov     ebx, [pStObjCnt]
      mov     ecx, [ebx]
      mov     edi, [stObjects]


.FreeStObjLoop:
      mov        esi, [ebx]
      sub        esi, ecx
      shl        esi,2

      push       ecx


      stdcall    ReleaseStObjRes, [edi + esi]

      pop     ecx

      loop    .FreeStObjLoop

      mov      dword [ebx], 0


      ret
endp