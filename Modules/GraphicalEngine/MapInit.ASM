        srcPath   db      "Resources/map/*",0
        baseSrcPathLen    =   14


proc    MapInit uses esi edi

        locals
        ffd               dd              ?
        hFind             dd              ?
        tempFileMesh      dd              ?
        tempPath          dd              ?

        createdMesh       dd              ?
        minPoint          dd              ?
        maxPoint          dd              ?
        endl

        xor     ebx,ebx

        malloc  sizeof.WIN32_FIND_DATA
        mov     [ffd], eax

        invoke FindFirstFile,  srcPath, [ffd]
        mov    [hFind], eax

        cmp    eax, INVALID_HANDLE_VALUE
        je     .ReturnZero

        invoke     FindNextFile, [hFind], [ffd]            ;
        invoke     FindNextFile, [hFind], [ffd]


        mov        esi, [ffd]
.FindLoop:

        lea        edx, [esi+WIN32_FIND_DATA.cFileName]

.CreateFullPath:
        stdcall    BuildFullPath, edx
        mov        [tempPath], eax

        stdcall    File.ReadModel, eax

        mov        [tempFileMesh], eax

        free       [tempPath]

        mov        edi, [tempFileMesh]

        push       edx
        stdcall    FindAABBStatic, [edi+TempFileMesh.vertices], [edi+TempFileMesh.verticesCount]
        mov        [minPoint], eax
        mov        [maxPoint], edx
        pop        edx

        stdcall    CreateMesh, [edi+TempFileMesh.vertices], [edi+TempFileMesh.normals], [edi+TempFileMesh.textures], [textureID], [edi+TempFileMesh.verticesCount]

        stdcall    CreateObject , eax, [minPoint], [maxPoint]

        stdcall    AddToObjects, eax

        stdcall    TempFileMeshFree, [tempFileMesh]

        invoke     FindNextFile, [hFind], [ffd]

        cmp        eax, ebx
        jne        .FindLoop

.ReturnZero:
        free    [ffd]
        invoke  FindClose, [hFind]
    ret
endp


proc BuildFullPath uses esi edi,\
     fileName

     locals
        fileNameLen     dd      ?
        filePath        dd      ?
     endl

     len        [fileName]
     mov        [fileNameLen],ecx

     mov        eax, ecx
     add        eax, baseSrcPathLen+1
     malloc     eax
     mov        [filePath], eax

     mov        eax, [fileNameLen]
     add        eax, 1

     memcpy     [filePath], srcPath, baseSrcPathLen
     memcpy     edi, [fileName], eax

     mov        eax, [filePath]

    ret
endp

