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
        case    .MenuClickProcess,      0
        case    .GameProcess,           1


.GameProcess:
        mov     dword [fShoot],       true
        jmp     .DefaultProcessing

.MenuClickProcess:
        stdcall   ProcessClick, [Buttons], [ButtonsCnt], [lParam]
        jmp      .DefaultProcessing
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
        switch  [appState]
        case    .DrawGame,      1
        case    .DrawMenu,      0

.DrawMenu:
        stdcall DrawMenu
        jmp     .ReturnZero
.DrawGame:
        stdcall DrawGame
        jmp     .ReturnZero

.KeyDown:
        cmp     [wParam], VK_ESCAPE
        jne     .ReturnZero

        switch  [appState]
        case    .RetToGameMenu,      1

        jmp     .ReturnZero

.RetToGameMenu:
        stdcall  InitDrawGameMenu
        jmp     .ReturnZero
.Destroy:
         invoke  ExitProcess, ebx

.ReturnZero:
         xor     eax, eax
.Return:

        ret
endp

