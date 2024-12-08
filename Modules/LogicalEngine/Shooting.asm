proc GetCrosshairPosition uses esi edi,\
     crosshairPos, tankPos, tankDirection, shootPosOffs,

     mov        edi, [crosshairPos]
     stdcall    Vector3.Copy


    ret
endp