        color   dd      ?

proc    CreateFloor uses esi edi ebx,\
        width,height,floor   ;width: count of cells Xaxis; height: YAxis

        locals
        size            dd      ?
        currOffs        dd      ?
        currInd         dd      ?
        temp            dd      ?
        currColor       dd      ?
        endl

        mov     [color],1.0

                               ;find map size
        mov     eax,[width]    ;count of vertexis: cells+1
        mov     ecx,[height]

        mul     ecx

        mov     [size],eax

        add     eax,[width]
        add     eax,[height]
        add     eax,1

        mov     esi,[floor]

        mov     ecx,sizeof.Vector3    ;12
        mul     ecx

        push    eax
        push    eax

        invoke  HeapAlloc, [hHeap], 8     ;Allocate vertex array
        mov     [esi+Mesh.vertices],eax

        invoke  HeapAlloc, [hHeap], 8           ;Allocate color arr
        mov     [esi+Mesh.colors],eax

        mov     [currColor],eax

        mov     eax,[size]
        mov     ecx,6
        mul     ecx

        mov     [esi+Mesh.indexCnt],eax

        mov     ecx,4           ; size of dword
        mul     ecx

        invoke  HeapAlloc, [hHeap], 8, eax      ; Allocate indices arr
        mov     [esi+Mesh.indices],eax

        mov     ecx,[height]
        inc     ecx


        mov     edi,[esi+Mesh.indices]
        mov     [currInd],edi
        mov     edi,[floor]
        mov     esi,[edi+Mesh.vertices]

.FillCoordsLoopH:                                ;start ebx - j; fin - i     ;edx - i
        push    ecx                              ;edi -- indices
                                    ;esi - points/colors

        ;find offst
        mov     edx,ecx
        sub     edx,[heigth]
        sub     edx,1
        neg     edx

        mov     eax,edx

        push    edx
        mov     ecx,[width]
        inc     ecx
        mul     ecx
        mov     [currOffs],eax
        pop     edx

.FillCoordsLoopW:
        mov     ebx,[width]
        sub     ebx,ecx ; j
        add     ebx,1
        ;fill   coords
        mov     [temp],ebx
        fild    [temp]

        fstp    [esi+Vector3.x]

        mov     [temp],edx
        fild    [temp]

        fstp    [esi+Vector3.y]

        mov     [esi+Vector3.z],0
        stdcall  ChangeColor
        stdcall  FillColors, [currColor]
        add     [currColor],12
      ; mov     [esi+Vector3.x],10
      ; mov     [esi+Vector3.y],10
      ; mov     [esi+Vector3.z],10

        ;fill   indices

        cmp     ebx,[width]
        jge     .Skip
        cmp     edx,[height]
        jge     .Skip

        stdcall  FillIndices, [width], [currOffs], [currInd]
        add      dword[currOffs],1
        add      [currInd],6*4

.Skip:


        add     esi,sizeof.Vector3

;fill colors

        loop    .FillCoordsLoopW

        pop     ecx
        loop    .FillCoordsLoopH


.Return:

    ret
endp

proc    FillIndices uses edi ebx,\
        width,currOffs,currInd


        mov     edi,[currInd]

        mov     ebx,[currOffs]
       ;mov      ebx,10

        mov     [edi],ebx
        mov     [edi+4],ebx
        mov     [edi+8],ebx
        mov     [edi+12],ebx
        mov     [edi+16],ebx
        mov     [edi+20],ebx

        mov     ebx,[width]

        add     dword[edi+4],1

        add     dword[edi+8],2
        add     [edi+8],ebx

        add     [edi+12],ebx
        add     dword[edi+12],2

        add     [edi+16],ebx
        add     dword[edi+16],1

    ret
endp

proc FillColors uses edi ebx,\
     currColor

     locals
     tempColor  dd      ?
     endl

     mov        edi,[currColor]

     mov        eax,[color]

     mov        dword[edi],eax
     mov        dword[edi+4],0.5
     mov        dword[edi+8],0.5

     ret
endp


proc ChangeColor
    locals
    temp        dd      ?
    endl
    mov [temp],1.0

    fld [color]
    fld [temp]
    fcomip    st,st1
    jne       .Skip
    je        .Skip2
.Skip:
    mov       [color],1.0
    jmp       .Ret
.Skip2:
    mov       [color],0.5
.Ret:
    fstp        [temp]
    ret
endp
