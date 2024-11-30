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


proc CreateObject uses esi edi,\
     pMesh, pAABB, pOBB

     locals
        pObject         dd      ?
     endl

     xor     ebx,ebx

     malloc     sizeof.Object
     mov        [pObject],eax

     mov        esi, eax
     mov        eax, [pMesh]
     mov        [esi + Object.pMesh], eax


     ;Fill pAABB
     mov        eax, [pAABB]
     mov        [esi + Object.pAABB], eax

     ;Fill pOBB
     mov        eax, [pOBB]
     mov        [esi + Object.pOBB], eax

     mov        eax, esi
    ret
endp


proc AddToObjects uses esi edi ebx,\
           pObject

     locals
          tempObjects   dd      ?
     endl


     mov        eax,[objCap]
     cmp        [objCnt],eax
     jne        .Skip

     shl        [objCap],1

     shl        eax,3


     malloc     eax
     mov        [tempObjects],eax

     mov        eax,[objCnt]
     shl        eax,2

     memcpy     [tempObjects], [Objects], eax

     mov        edx, [Objects] ;save old obj

     xchg       eax, [tempObjects]
     mov        [Objects],eax                                            ; 0 1 2 3 4 5 6 7 8 9

     ;xor        ebx, ebx
     free       edx

.Skip:
     mov        edi, [Objects]
     mov        ebx, [objCnt]
     shl        ebx,2

     mov        eax, [pObject]

     mov        [edi+ebx],eax

     add        [objCnt],1
     ret
endp



proc    ReadObject uses edi ,\
        objFPath, textId

        locals
            tempFileMesh        dd      ?
            pAABB               dd      ?
            pOBB                dd      ?
        endl

        stdcall    File.ReadModel, [objFPath]

        mov        [tempFileMesh], eax

        mov        edi, [tempFileMesh]

        stdcall    FindAABBStatic, [edi+TempFileMesh.vertices], [edi+TempFileMesh.verticesCount]
        mov        [pAABB], eax

        stdcall    Collision.ConvertAABBtoOBB, [pAABB]
        mov        [pOBB], eax

        stdcall    CreateMesh, [edi+TempFileMesh.vertices], [edi+TempFileMesh.normals], [edi+TempFileMesh.textures], [textId], [edi+TempFileMesh.verticesCount]

        stdcall    CreateObject, eax, [pAABB], [pOBB]

        push       eax
        stdcall    TempFileMeshFree, [tempFileMesh]
        pop        eax
    ret
endp