        include "OPENGL_DEMO.inc"

        className       db      "OpenGLDemo", 0
        clientRect      RECT
        hHeap           dd      ?
        hdcBack         dd      ?
        time            dd      ?
        hdc             dd      ?
        xAngle          dd      -20.0
        zAngle          dd      0.0
        radian          dd      57.32


        fovY            dd      60.0
        zNear           dd      0.001
        zFar            dd      1000.0

        cameraPosition  Vector3 0.0, 0.0, 0.0
        targetPosition  Vector3 0.0, 0.0, 0.0
        upVector        Vector3 0.0, 1.0, 0.0

        position        Vector3 0.0, 0.0, -3.0
        speed           dd      0.1
        cursorPos       POINT
        CursorPos_x     dd      ?
        CursorPos_y     dd      ?

        _0              dd      0.0
        _180            dd      180.0
        _5              dd      10.0

        include         "Init.asm"
        include         "Mesh.asm"
        include         "Vector.asm"
        include         "Matrix.asm"
        include         ".\File\File.asm"
proc WinMain

        locals
                msg     MSG
        endl

        xor     ebx, ebx

        stdcall Init





        lea     esi, [msg]

.cycle:
        invoke  GetMessage, esi, ebx, ebx, ebx
        invoke  DispatchMessage, esi

        jmp     .cycle

endp

proc WindowProc uses ebx,\
     hWnd, uMsg, wParam, lParam

        xor     ebx, ebx

        mov     eax, [uMsg]

        JumpIf  WM_PAINT,       .Paint
        JumpIf  WM_DESTROY,     .Destroy
        JumpIf  WM_KEYDOWN,     .KeyDown
        JumpIf  WM_MOUSEMOVE,   .MouseMove

        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

.Paint:

        stdcall Draw, plane

        jmp     .ReturnZero
.KeyDown:
        cmp     [wParam], VK_ESCAPE
        je      .Destroy
        stdcall MoveCamera, [wParam]

        jmp     .ReturnZero
.MouseMove:
         stdcall         MoveHead
         jmp     .ReturnZero
.Destroy:
        invoke  ExitProcess, ebx

.ReturnZero:
        xor     eax, eax

.Return:
        ret
endp



proc MoveCamera, key
        mov  eax,[key]
        stdcall         ChangeCoords,  [zAngle],position,[key]
        jmp  .Return


.Return:

     ret

endp


proc MoveHead

     invoke     GetCursorPos, cursorPos
     mov        eax, [CursorPos_x]
     sub        eax,[cursorPos + POINT.x]

     mov        [cursorPos + POINT.x],eax


     mov        eax, [CursorPos_y]
     sub        eax,[cursorPos + POINT.y]

     mov        [cursorPos + POINT.y],eax


     fld        [zAngle]
     fild       [cursorPos + POINT.x]
     fld        [_5]
     fdivp
     fsubp
     fstp       [zAngle]

     fld        [xAngle]
     fild       [cursorPos + POINT.y]
     fld        [_5]
     fdivp
     fsubp
      fstp       [xAngle]
     invoke     SetCursorPos, [CursorPos_x], [CursorPos_y]

ret
endp


proc ChangeCoords uses esi,\
     angle,pos,key

        locals
        dcos              dd      ?
        dsin              dd      ?
        polcruzhochka     dd      180.0
        endl

        fld     [angle]
        fdiv    [polcruzhochka]
        fldpi
        fmulp

        fsincos

        fmul    [speed]
        fstp    [dcos]
        fmul    [speed]
        fstp    [dsin]

        mov     esi,[pos]

        mov     eax,[key]

        JumpIf VK_W,      .PositionFRONT
        JumpIf VK_S,      .PositionBACK
        JumpIf VK_A,      .PositionLEFT
        JumpIf VK_D,      .PositionRIGHT
        JumpIf VK_E,      .PositionUP
        JumpIf VK_Q,      .PositionDOWN


.PositionFRONT:
        fld    [dsin]
        fsubr  [esi + Vector3.x]
        fstp   [esi + Vector3.x]

        fld     [dcos]
        fsubr  [esi + Vector3.y]
        fstp   [esi + Vector3.y]
        jmp  .Return
.PositionBACK:
        fld     [dsin]
        fadd  [esi + Vector3.x]
        fstp   [esi + Vector3.x]

        fld     [dcos]
        fadd  [esi + Vector3.y]
        fstp   [esi + Vector3.y]

        jmp  .Return

.PositionRIGHT:

        fld     [dcos]
        fsubr  [esi + Vector3.x]
        fstp   [esi + Vector3.x]

        fld     [dsin]
        fadd  [esi + Vector3.y]
        fstp   [esi + Vector3.y]
        jmp  .Return

.PositionLEFT:
        fld     [dcos]
        fadd  [esi + Vector3.x]
        fstp   [esi + Vector3.x]

        fld     [dsin]
        fsubr  [esi + Vector3.y]
        fstp   [esi + Vector3.y]

        jmp  .Return

.PositionUP:
        fld     [speed]
        fsubr   [esi + Vector3.z]
        fstp    [esi + Vector3.z]

        jmp  .Return

.PositionDOWN:
        fld     [speed]
        fadd   [esi + Vector3.z]
        fstp    [esi + Vector3.z]

.Return:

        ret
endp


proc Draw uses esi,\
     mesh



.Skip:
      ;  invoke glRotatef, -2.0, 1.0, 0.0, 0.0

        invoke  glPushMatrix
        invoke  glRotatef, [xAngle], 1.0, 0.0, 0.0
        invoke  glRotatef, [zAngle], 0.0, 0.0, 1.0
        invoke  glTranslatef, [position.x], 0.0, 0.0
        invoke  glTranslatef, 0.0,[position.y], 0.0
        invoke  glTranslatef, 0.0,0.0, [position.z]
        invoke  glClearColor, 0.1, 0.1, 0.6, 1.0
        invoke  glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT

        mov     esi,[mesh]



        invoke  glEnableClientState, GL_VERTEX_ARRAY
        invoke  glEnableClientState, GL_COLOR_ARRAY




        invoke  glVertexPointer, 3, GL_FLOAT, ebx, [esi+Mesh.vertices]
        invoke  glColorPointer, 3, GL_FLOAT, ebx, [esi+Mesh.colors]
        invoke  glDrawArrays, GL_TRIANGLES, ebx, PLANE_VERTICES_COUNT



        invoke  glDisableClientState, GL_VERTEX_ARRAY
        invoke  glDisableClientState, GL_COLOR_ARRAY

        ;invoke  Sleep,100





        invoke  glPopMatrix


        invoke  SwapBuffers, [hdc]


        ret
endp



