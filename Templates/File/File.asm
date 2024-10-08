proc ReadModel uses ebx,\
     resultMesh, verticesPath, indicesPath

     locals
        hFileVertices        dd      ?          ; Descriptor of file
        hFileIndices         dd      ?          ; Descriptor of file
        TrianglesCount       dd      ?          ; is already clear
        IndicesCount         dd      ?
        TriangleVertices     dd      ?          ; is already clear
        TriangleIndex        dd      ?
        resultVertices       dd      ?          ; is already clear
        resultIndices        dd      ?
        resultColors         dd      ?          ; is already clear
     endl

     xor        ebx, ebx
     invoke     CreateFile, [verticesPath], GENERIC_READ, ebx, ebx, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, ebx
     mov        [hFileVertices], eax

     invoke     HeapAlloc, [hHeap], 8, sizeof.Vertex
     mov        [TriangleVertices], eax

     mov        esi, [resultMesh]
     add        esi, Mesh.trianglesCount

     invoke     ReadFile, [hFileVertices], esi, 4, ebx, ebx                     ; Read count of triangles
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
     invoke     ReadFile, [hFileVertices], [TriangleVertices], 3 * sizeof.Vertex, ebx, ebx

     mov        ecx, 9
     mov        esi, [TriangleVertices]
     mov        edi, [resultVertices]
     rep movsd

     mov        ecx, 9
     mov        eax, 0.45
     mov        edi, [resultColors]
     rep stosd

     add        [resultVertices], 3 * sizeof.Vertex
     add        [resultColors], 3 * sizeof.Vertex
     pop        ecx
     loop       .CopyCycle
     invoke     CloseHandle, [hFileVertices]

     invoke     HeapFree, [hHeap], HEAP_NO_SERIALIZE, [TriangleVertices]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     invoke     CreateFile, [indicesPath], GENERIC_READ, ebx, ebx, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, ebx
     mov        [hFileIndices], eax

     invoke     HeapAlloc, [hHeap], 4
     mov        [TriangleIndex], eax

     invoke     ReadFile, [hFileIndices], [TriangleIndex], 4, ebx, ebx                     ; Read count of indices
     mov        esi, [TriangleIndex]
     mov        edx, [esi]
     mov        [IndicesCount], edx

     xor        edx, edx                                                ; Calc size of mesh triangles
     mov        ecx, [IndicesCount]
     mov        eax, 4
     mul        ecx

     mov        edi, [resultMesh]
     invoke  HeapAlloc, [hHeap], 8, eax
     mov     [resultIndices], eax
     mov     [edi + Mesh.indices], eax

     mov        ecx, [IndicesCount]
.CopyCycleIndices:
     push       ecx
     invoke     ReadFile, [hFileIndices], [TriangleIndex], 4, ebx, ebx

     mov        esi, [TriangleIndex]
     mov        edi, [resultIndices]
     movsd

     add        [resultIndices], 4
     pop        ecx
     loop       .CopyCycleIndices
     invoke     CloseHandle, [hFileIndices]

     invoke     HeapFree, [hHeap], HEAP_NO_SERIALIZE, [TriangleIndex]

     ret
endp

proc StrToFloat:
    fldz
    xor eax, eax
    xor edx, edx
    mov ecx, 0
    mov edi, 1
    mov ebx, 0

    cmp byte [esi], '-'
    jne .check_plus
    mov ecx, 1
    inc esi

.check_plus:
    cmp byte [esi], '+'
    jne .parse_number
    inc esi

.parse_number:

.next_digit:
    cmp byte [esi], 0
    je .end_conversion

    cmp byte [esi], '.'
    je .fraction_part

    sub byte [esi], '0'
    cmp byte [esi], 9
    ja .end_conversion

    imul eax, edi
    add eax, [esi]
    inc esi
    jmp .next_digit

.fraction_part:
    inc esi
    mov edx, 1
    mov ebx, 1

.parse_fraction:
    cmp byte [esi], 0
    je .end_conversion

    sub byte [esi], '0'
    cmp byte [esi], 9
    ja .end_conversion

    imul edx, edx, 10
    push eax
    mov eax, [esi]
    cdq
    idiv edx
    pop eax

    fld dword [esi]
    fdiv dword [edx]
    fadd dword [eax]
    ret
endp