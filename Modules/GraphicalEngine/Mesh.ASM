proc CreateMesh uses esi edi ebx,\
     vertices, normals, textCoords, textureID, vertexCnt
                          ;colors
     locals
     pMesh      dd      ?
     byteCnt    dd      ?
     ;currVao    dd      ?
     ;currVbo    dd      ?
     endl

     ;invoke     glGetIntegerv, GL_VERTEX_ARRAY_BINDING, currVao              ;TODO return current context (in future)
     ;invoke     glGetIntegerv, GL_ARRAY_BUFFER_BINDING, currVbo

     malloc     sizeof.Mesh
     mov        [pMesh],eax
     mov        esi,[pMesh]

     mov        ecx,[vertexCnt]
     mov        [esi+Mesh.vertexCnt],ecx

     mov        ecx, [textureID]
     mov        [esi+Mesh.textureID],ecx

     lea        edi, [esi+Mesh.VAO]
     invoke     glGenVertexArrays, 1, edi
     invoke     glBindVertexArray, [edi]

     lea        edi, [esi+Mesh.VBOvert]
     invoke     glGenBuffers, 1, edi
     invoke     glBindBuffer, GL_ARRAY_BUFFER, [edi]

     mov        eax,[vertexCnt]
     mov        ecx,3*4
     mul        ecx
     mov        [byteCnt],eax

     invoke     glBufferData, GL_ARRAY_BUFFER,  eax, [vertices], GL_STATIC_DRAW
     invoke     glVertexAttribPointer, 0, 3, GL_FLOAT, GL_FALSE,0,0
     invoke     glEnableVertexAttribArray, 0

     lea        edi, [esi+Mesh.VBOnorm]
     invoke     glGenBuffers, 1, edi
     invoke     glBindBuffer, GL_ARRAY_BUFFER, [edi]
     invoke     glBufferData, GL_ARRAY_BUFFER,  [byteCnt], [normals], GL_STATIC_DRAW

     invoke     glVertexAttribPointer, 1, 3, GL_FLOAT, GL_FALSE,0,0
     invoke     glEnableVertexAttribArray, 1

     lea         edi, [esi+Mesh.VBOtex]
     invoke      glGenBuffers, 1, edi
     invoke      glBindBuffer, GL_ARRAY_BUFFER, [edi]

     mov         eax,[vertexCnt]
     mov         ecx, 2*4
     mul         ecx
     invoke      glBufferData, GL_ARRAY_BUFFER,  eax, [textCoords], GL_STATIC_DRAW



     invoke     glVertexAttribPointer, 2, 2, GL_FLOAT, GL_FALSE,0,0
     invoke     glEnableVertexAttribArray, 2

     invoke     glBindBuffer, GL_ARRAY_BUFFER,0    ;[currVbo]

     invoke     glBindVertexArray,0                ; [currVao]

     mov        eax, [pMesh]
     ret
endp





proc AddToMeshes uses edi ebx,\
           pMesh

     locals
          tempObjects   dd      ?
     endl


     mov        eax,[objCap]
     cmp        [objCnt],eax
     jne        .Skip

     shl        [objCap],1

     mov        eax,[objCnt]
     shl        eax,3


     malloc     eax
     mov        [tempObjects],eax

     mov        eax,[objCap]
     shl        eax,1

     memcpy     [tempObjects], [Objects], eax

     mov        edx, [Objects] ;save old obj

     mov        eax, [tempObjects]
     mov        [Objects],eax

     xor        ebx, ebx
     invoke     HeapFree, [hHeap], ebx, edx

.Skip:
     mov        edi, [Objects]
     mov        ebx, [objCnt]
     shl        ebx,2

     mov        eax, [pMesh]

     mov        [edi+ebx],eax

     add        [objCnt],1
     ret
endp