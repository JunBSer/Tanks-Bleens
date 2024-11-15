include                 "./FileProc/FileGenerateMesh.asm"
include                 "./FileProc/FileMemory.asm"
include                 "./FileProc/FileParse.asm"

FilePath                db      '.\', 0

LF                      =       10

struct FileMesh
        vertices        dd      ?
        normals         dd      ?
        textures        dd      ?
        vInd            dd      ?
        vnInd           dd      ?
        vtInd           dd      ?
        verticesCount   dd      ?
        normalsCount    dd      ?
        texturesCount   dd      ?
        trianglesCount  dd      ?
ends

struct TempFileMesh
        vertices        dd      ?
        normals         dd      ?
        textures        dd      ?
        verticesCount   dd      ?
ends

