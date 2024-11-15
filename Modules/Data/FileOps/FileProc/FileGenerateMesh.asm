proc GenerateMesh uses ebx esi edi,\
     sourceMesh, resultMesh

        locals
                verticesCount   dd      ?
                resultIndex     dd      ?
                vertices        dd      ?
                resultVertices  dd      ?
                indices         dd      ?

        endl

        xor     ebx, ebx

        mov     esi, [sourceMesh]
        mov     edi, [resultMesh]

        mov     [resultIndex], ebx
        mov     eax, [esi + FileMesh.vertices]
        mov     [vertices], eax
        mov     eax, [esi + FileMesh.vInd]
        mov     [indices], eax
        mov     eax, [edi + TempFileMesh.vertices]
        mov     [resultVertices], eax

        mov     ecx, [edi + TempFileMesh.verticesCount]
.CopyCycle0:
        push    ecx

        xor     edx, edx
        mov     esi, [indices]
        mov     eax, [esi + ebx]    ; index
        dec     eax
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

        add     ebx, 4
        add     [resultIndex], 1

        pop     ecx
        loop    .CopyCycle0

        xor     ebx, ebx
        mov     esi, [sourceMesh]
        mov     edi, [resultMesh]

        mov     [resultIndex], ebx
        mov     eax, [esi + FileMesh.normals]
        mov     [vertices], eax
        mov     eax, [esi + FileMesh.vnInd]
        mov     [indices], eax
        mov     eax, [edi + TempFileMesh.normals]
        mov     [resultVertices], eax

        mov     ecx, [edi + TempFileMesh.verticesCount]
.CopyCycle1:
        push    ecx

        xor     edx, edx
        mov     esi, [indices]
        mov     eax, [esi + ebx]    ; index
        dec     eax
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

        add     ebx, 4
        add     [resultIndex], 1

        pop     ecx
        loop    .CopyCycle1

        xor     ebx, ebx
        mov     esi, [sourceMesh]
        mov     edi, [resultMesh]

        mov     [resultIndex], ebx
        mov     eax, [esi + FileMesh.textures]
        mov     [vertices], eax
        mov     eax, [esi + FileMesh.vtInd]
        mov     [indices], eax
        mov     eax, [edi + TempFileMesh.textures]
        mov     [resultVertices], eax

        mov     ecx, [edi + TempFileMesh.verticesCount]
.CopyCycle2:
        push    ecx

        xor     edx, edx
        mov     esi, [indices]
        mov     eax, [esi + ebx]    ; index
        dec     eax
        mov     edi, 2 * 4 ;GL_FLOAT
        mul     edi                     ; index * sizeof.Vertex

        mov     esi, [vertices]
        add     esi, eax                ; vertices + index * sizeof.Vertex = vertices[index]

        xor     edx, edx
        mov     eax, [resultIndex]      ; resultIndex
        mov     edi, 2 * 4 ;GL_FLOAT
        mul     edi                     ; resultIndex * sizeof.Vertex

        mov     edi, [resultVertices]
        add     edi, eax                ; resultVertices + resultIndex * sizeof.Vertex = resultVertices[resultIndex]

        mov     eax, [esi + Vertex.x]   ; x = vertices[index].x
        mov     ecx, [esi + Vertex.y]   ; y = vertices[index].y
        mov     [edi + Vertex.x], eax   ; resultVertices[resultIndex].x = x
        mov     [edi + Vertex.y], ecx   ; resultVertices[resultIndex].y = y

        add     ebx, 4
        add     [resultIndex], 1

        pop     ecx
        loop    .CopyCycle2
        ret
endp