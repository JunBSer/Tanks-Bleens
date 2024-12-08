proc CreateStaticObject uses esi edi,\
     vertecise, textCoords, textureID, vertexCnt

     locals
         pStaticObject          dd      ?
         pMesh                  dd      ?
         pModelMatrix           dd      ?
     endl

     stdcall    CreateMesh, [vertices], 0, [textCoords], [textureID], [vertexCnt]
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

proc DrawStaticObject uses edi esi,\
     pObj

     mov        esi, [pObj]
     mov        edi, [esi+StaticObject.pMesh]



     invoke     glBindVertexArray, [edi+Mesh.VAO]



     invoke     glBindTexture, GL_TEXTURE_2D, [edi+Mesh.textureID]
     invoke     glUniform1i, [stSamplerLocation], 0
     invoke

     invoke     glDrawArrays, GL_TRIANGLES, 0, [edi+Mesh.vertexCnt]

     invoke     glBindVertexArray, 0

     ret
endp