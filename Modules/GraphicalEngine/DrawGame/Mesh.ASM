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
     xor        ebx,ebx

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
     cmp        dword [normals], 0
     jne        .TripleCoordVertVersion

     mov        ecx,2*4

     jmp        .FillByteCnt
.TripleCoordVertVersion:
     mov        ecx,3*4

.FillByteCnt:
     mul        ecx
     mov        [byteCnt],eax

     invoke     glBufferData, GL_ARRAY_BUFFER,  eax, [vertices], GL_STATIC_DRAW
     cmp        dword [normals],0
     jne        .TripleCoordVAOP

     invoke     glVertexAttribPointer, 0, 2, GL_FLOAT, GL_FALSE,0,0
     jmp        .ResetVAO
.TripleCoordVAOP:
     invoke     glVertexAttribPointer, 0, 3, GL_FLOAT, GL_FALSE,0,0

.ResetVAO:
     invoke     glEnableVertexAttribArray, 0

     lea         edi, [esi+Mesh.VBOtex]
     invoke      glGenBuffers, 1, edi
     invoke      glBindBuffer, GL_ARRAY_BUFFER, [edi]

     mov         eax,[vertexCnt]
     mov         ecx, 2*4
     mul         ecx
     invoke      glBufferData, GL_ARRAY_BUFFER,  eax, [textCoords], GL_STATIC_DRAW

     invoke     glVertexAttribPointer, 1, 2, GL_FLOAT, GL_FALSE,0,0
     invoke     glEnableVertexAttribArray, 1

     cmp        [normals], ebx
     jne         .FillNormals
     mov        [esi+Mesh.VBOnorm], 0
     jmp        .Skip

.FillNormals:
     lea        edi, [esi+Mesh.VBOnorm]
     invoke     glGenBuffers, 1, edi
     invoke     glBindBuffer, GL_ARRAY_BUFFER, [edi]
     invoke     glBufferData, GL_ARRAY_BUFFER,  [byteCnt], [normals], GL_STATIC_DRAW

     invoke     glVertexAttribPointer, 2, 3, GL_FLOAT, GL_FALSE,0,0
     invoke     glEnableVertexAttribArray, 2

.Skip:
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
           pObject, pObjectsArr, pObjCap, pObjCnt

     locals
          tempObjects   dd      ?
     endl

     mov        esi, [pObjCap]
     mov        eax,[esi]

     mov        edi, [pObjCnt]
     cmp        [edi],eax
     jne        .Skip

     shl        dword [esi],1

     shl        eax,3

     malloc     eax
     mov        [tempObjects],eax

     mov        eax,[edi]
     shl        eax,2

     mov        ebx, [pObjectsArr]
     memcpy     [tempObjects], [ebx], eax

     mov        edx, [ebx] ;save old obj

     xchg       eax, [tempObjects]
     mov        [ebx],eax                                            ; 0 1 2 3 4 5 6 7 8 9

     ;xor        ebx, ebx
     free       edx

.Skip:

     mov        edi, [pObjectsArr]
     mov        edi, [edi]

     mov        ebx, [pObjCnt]
     mov        esi, [ebx]
     shl        esi,2

     mov        eax, [pObject]

     mov        [edi+esi],eax

     add        dword[ebx],1
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