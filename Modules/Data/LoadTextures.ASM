proc    LoadTexture uses esi,\
                texturePath, imgSizes
        locals
        textureData           dd      ?
        textureBufSize        dd      ?
        endl

        stdcall File.LoadContent, [texturePath], 54, [imgSizes]
        mov     [textureData], eax
        ;sub     ecx,1
        mov     [textureBufSize], ecx
        sub     [textureBufSize], 1

        xor     ecx, ecx
        mov     esi, [textureData]

.TransformData:
        xchg    al, [esi+ecx]
        xchg    al, [esi+ecx+2]
        xchg    al, [esi+ecx]

        add     ecx,3
        cmp     ecx, [textureBufSize]
        jne     .TransformData

        mov     eax,[textureData]
    ret
endp