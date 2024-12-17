        include "Main.inc"

        hHeap   dd      ?



proc    WinMain

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

proc WindowProc,\
        hWnd, uMsg, wParam, lParam

        xor     ebx,ebx

        switch  [uMsg]
        case    .Paint,                 WM_PAINT
        case    .Destroy,               WM_DESTROY
        case    .KeyDown,               WM_KEYDOWN
        case    .LeftMButtonDown,       WM_LBUTTONDOWN

        jmp     .DefaultProcessing

.LeftMButtonDown:

        switch  [appState]
        case    .GameProcess,           1

.GameProcess:

        mov     dword [fShoot],       true

.DefaultProcessing:
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return

.Paint:
        stdcall DrawGame
        ;stdcall DrawStartMenu
        jmp     .ReturnZero

.KeyDown:
        cmp     [wParam], VK_ESCAPE
        je      .Destroy
        jmp     .ReturnZero

.Destroy:
      ; stdcall  ReleaseGraphicsResources
       invoke  ExitProcess, ebx
.ReturnZero:

       xor     eax, eax
.Return:

        ret
endp

