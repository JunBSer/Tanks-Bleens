proc GenerateMesh uses ebx esi edi,\
     sourceMesh, resultMesh, copyColors

        locals
                verticesCount   dd      ?
                resultIndex     dd      ?
                vertices        dd      ?
                resultVertices  dd      ?
                colors          dd      ?
                resultColors    dd      ?
                indices         dd      ?
        endl

        mov     [resultIndex], ebx

        mov     esi, [sourceMesh]
        mov     edi, [resultMesh]

        mov     eax, [esi + Mesh.trianglesCount]
        mov     [edi + Mesh.trianglesCount], eax
        xor     edx, edx
        mov     ecx, 3
        mul     ecx
        mov     [verticesCount], eax    ; verticesCount = trianglesCount * 3
        xor     edx, edx
        mov     ecx, sizeof.Vertex
        mul     ecx
        push    eax
        push    eax
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [resultVertices], eax
        mov     [edi + Mesh.vertices], eax
        invoke  HeapAlloc, [hHeap], 8   ; eax
        mov     [resultColors], eax
        mov     [edi + Mesh.colors], eax

        mov     eax, [esi + Mesh.vertices]
        mov     [vertices], eax
        mov     eax, [esi + Mesh.colors]
        mov     [colors], eax
        mov     eax, [esi + Mesh.indices]
        mov     [indices], eax

        mov     ecx, [verticesCount]
.CopyCycle:
        push    ecx

        xor     edx, edx
        mov     esi, [indices]
        movzx   eax, byte[esi + ebx]    ; index
        mov     edi, sizeof.Vertex
        mul     edi                     ; index * sizeof.Vertex

        mov     esi, [vertices]
        add     esi, eax                ; vertices + index * sizeof.Vertex = vertices[index]

        xor     edx, edx
        mov     eax, [resultIndex]      ; resultIndex
        mov     edi, sizeof.Vertex
        mul     edi                     ; resultIndex * sizeof.Vertex

        mov     edi, [resultVertices]
        add     edi, eax                ; resultVertices + resultIndex * sizeof.Vertex = resultVertices[resultIndex]

        mov     eax, [esi + Vertex.x]   ; x = vertices[index].x
        mov     ecx, [esi + Vertex.y]   ; y = vertices[index].y
        mov     edx, [esi + Vertex.z]   ; z = vertices[index].z
        mov     [edi + Vertex.x], eax   ; resultVertices[resultIndex].x = x
        mov     [edi + Vertex.y], ecx   ; resultVertices[resultIndex].y = y
        mov     [edi + Vertex.z], edx   ; resultVertices[resultIndex].z = z

        cmp     [copyColors], false
        je      .DoNotCopyColors

        xor     edx, edx
        mov     esi, [indices]
        movzx   eax, byte[esi + ebx]    ; index
        mov     edi, sizeof.Color
        mul     edi                     ; index * sizeof.Color

        mov     esi, [colors]
        add     esi, eax                ; colors + index * sizeof.Color = colors[index]

        xor     edx, edx
        mov     eax, [resultIndex]      ; resultIndex
        mov     edi, sizeof.Color
        mul     edi                     ; resultIndex * sizeof.Color

        mov     edi, [resultColors]
        add     edi, eax                ; resultColors + resultIndex * sizeof.Color = resultColors[resultIndex]

        mov     eax, [esi + Color.r]    ; r = colors[index].r
        mov     ecx, [esi + Color.g]    ; g = colors[index].g
        mov     edx, [esi + Color.b]    ; b = colors[index].b
        mov     [edi + Color.r], eax    ; resultColors[resultIndex].r = r
        mov     [edi + Color.g], ecx    ; resultColors[resultIndex].g = g
        mov     [edi + Color.b], edx    ; resultColors[resultIndex].b = b

.DoNotCopyColors:

        inc     ebx
        inc     [resultIndex]

        pop     ecx
        loop    .CopyCycle

        ret
endp