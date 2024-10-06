proc ReadModel uses ebx,\
     resultMesh, FilePath

     locals
        hFile                dd      ?          ; Descriptor of file
        lDistanceToMove      dd      80         ; STL Header - 80 bytes
        TrianglesCount       dd      ?          ; is already clear
        TriangleInfo         dd      ?          ; foreach triangle - 50 bytes (Normal, V1, V2, V3, Attr)
        resultVertices       dd      ?          ; is already clear
        resultColors         dd      ?          ; is already clear
     endl

     xor        ebx, ebx
     invoke     CreateFile, [FilePath], GENERIC_READ, ebx, ebx, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, ebx
     mov        [hFile], eax

     invoke     SetFilePointer, [hFile], [lDistanceToMove], ebx, FILE_BEGIN

     invoke     HeapAlloc, [hHeap], 8, TriangleInfoSize
     mov        [TriangleInfo], eax

     mov        esi, [resultMesh]
     add        esi, Mesh.trianglesCount

     invoke     ReadFile, [hFile], esi, 4, ebx, ebx                     ; Read count of triangles
     mov        edx, [esi]
     mov        [TrianglesCount], edx

     xor        edx, edx                                                ; Calc size of mesh triangles
     mov        ecx, sizeof.Vertex
     mov        eax, 3
     mul        ecx
     xor        edx, edx
     mov        ecx, [TrianglesCount]
     mul        ecx

     mov        edi, [resultMesh]
     push       eax                                                     ; Allocate memory in mesh
     push       eax
     invoke  HeapAlloc, [hHeap], 8   ; eax
     mov     [resultVertices], eax
     mov     [edi + Mesh.vertices], eax
     invoke  HeapAlloc, [hHeap], 8   ; eax
     mov     [resultColors], eax
     mov     [edi + Mesh.colors], eax

     mov        ecx, [TrianglesCount]
.CopyCycle:
     push       ecx
     invoke     ReadFile, [hFile], [TriangleInfo], TriangleInfoSize, ebx, ebx
     add        [TriangleInfo], 12                                                ; Skip normal vector


     mov        ecx, 9
     mov        esi, [TriangleInfo]
     mov        edi, [resultVertices]
     rep movsd

     mov        ecx, 9
     mov        eax, 0.45
     mov        edi, [resultColors]
     rep stosd

     add        [resultVertices], 36
     add        [resultColors], 36
     sub        [TriangleInfo], 12
     pop        ecx
     loop       .CopyCycle

     invoke     CloseHandle, [hFile]

     invoke     HeapFree, [hHeap], [TriangleInfo]

     ret
endp