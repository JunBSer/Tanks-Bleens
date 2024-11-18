proc FileMeshAlloc uses esi,\
        fileMesh
        mov       esi, [fileMesh]

        xor        edx, edx
        mov        eax, sizeof.Vertex
        mov        ecx, [esi + FileMesh.verticesCount]
        mul        ecx
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
        mov        [esi + FileMesh.vertices], eax

        xor        edx, edx
        mov        eax, sizeof.Vertex
        mov        ecx, [esi + FileMesh.normalsCount]
        mul        ecx
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
        mov        [esi + FileMesh.normals], eax

        xor        edx, edx
        mov        eax, 2 * 4 ;GL_FLOAT
        mov        ecx, [esi + FileMesh.texturesCount]
        mul        ecx
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY, eax
        mov        [esi + FileMesh.textures], eax

        xor        edx, edx
        mov        eax, 3 * 4 ;3 * 3 * 4 ;GL_INT
        mov        ecx, [esi + FileMesh.trianglesCount]
        mul        ecx
        push       eax eax eax
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY ; eax
        mov        [esi + FileMesh.vInd], eax
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY ; eax
        mov        [esi + FileMesh.vnInd], eax
        invoke     HeapAlloc, [hHeap], HEAP_ZERO_MEMORY ; eax
        mov        [esi + FileMesh.vtInd], eax
        ret
endp

proc TempFileMeshAlloc uses esi,\
        tempFileMesh, trianglesCount

        mov     esi, [tempFileMesh]
        mov     eax, [trianglesCount]
        mov     ecx, 3
        mul     ecx
        mov     [esi + TempFileMesh.verticesCount], eax
        mov     ecx, 2 * 4 ;GL_FLOAT
        mul     ecx
        push    eax
        mov     eax, [esi + TempFileMesh.verticesCount]
        mov     ecx, 3 * 4 ;GL_FLOAT
        mul     ecx
        push    eax eax
        invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY ;eax
        mov     [esi + TempFileMesh.vertices], eax
        invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY ;eax
        mov     [esi + TempFileMesh.normals], eax
        invoke  HeapAlloc, [hHeap], HEAP_ZERO_MEMORY ;eax
        mov     [esi + TempFileMesh.textures], eax
        ret
endp

proc FileMeshFree uses ebx esi,\
       fileMesh
       mov      esi, [fileMesh]
       xor      ebx, ebx
       invoke     HeapFree, [hHeap], ebx, [esi + FileMesh.vertices]
       invoke     HeapFree, [hHeap], ebx, [esi + FileMesh.normals]
       invoke     HeapFree, [hHeap], ebx, [esi + FileMesh.textures]
       invoke     HeapFree, [hHeap], ebx, [esi + FileMesh.vInd]
       invoke     HeapFree, [hHeap], ebx, [esi + FileMesh.vnInd]
       invoke     HeapFree, [hHeap], ebx, [esi + FileMesh.vtInd]
       invoke     HeapFree, [hHeap], ebx, esi
       ret
endp

proc TempFileMeshFree uses esi,\
     tempFileMesh
     ;xor      ebx, ebx

     mov        esi, [tempFileMesh]
     free       [esi + TempFileMesh.vertices]
     free       [esi + TempFileMesh.normals]
     free       [esi + TempFileMesh.textures]
     free       [esi + TempFileMesh.verticesCount]

     free       esi

    ret
endp