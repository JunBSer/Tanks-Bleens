        include "Main.inc"

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
        invoke  SwapBuffers, [hdc]
        jmp     .cycle
endp

proc WindowProc,\
        hWnd, uMsg, wParam, lParam
        invoke  DefWindowProc, [hWnd], [uMsg], [wParam], [lParam]
        ret
endp

