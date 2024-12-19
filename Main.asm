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
        case    .KillFocus,             WM_KILLFOCUS
        case    .SetFocus,              WM_SETFOCUS



        jmp     .DefaultProcessing

.LeftMButtonDown:

        switch  [appState]
        case    .GameProcess,           1
        case    .MenuClickProcess,      0

.GameProcess:
        mov     dword [fShoot],       true
        jmp     .DefaultProcessing

.MenuClickProcess:
        stdcall    ProcessClick, [Buttons], [ButtonsCnt], 0
        jmp     .DefaultProcessing
.DefaultProcessing:
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        jmp     .Return


.KillFocus:
        mov     [fFocus], false
        jmp     .ReturnZero

.SetFocus:
        mov     [fFocus], true
        jmp     .ReturnZero

.Paint:
        ;stdcall DrawGame
        stdcall DrawStartMenu
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

