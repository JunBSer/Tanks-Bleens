        format PE GUI 5.0
        entry  WinMain

; main params        
        true            =               1
        false           =               0

        className               db      "Tanks-Bleens",0h

        hdc                     dd      ?

        appState                dd      ?

;display Params        

        windowWidthH            dd                      0
        windowHeightH           dd                      0

;includes
        include         "win32a.inc"

        include         "api\kernel32.inc"
        include         "api\user32.inc"
        include         "api\gdi32.inc"
        include         "api\opengl.inc"

        include         "Modules/Data/LaunchOptions.inc"
        include         "Macro/Macros.inc"

        include         "Modules/Data/FileOps/File.asm"
        include         "Modules/Data/FileOps/File.inc"
        
        include         "Modules/Init/Init.asm"

        include         "Modules/Network/Network.asm"

        include         "Modules/PhysicalEngine/Collision.asm"

        
        include         "Modules/GraphicalEngine/DrawGame/Draw.asm"
        include         "Modules/GraphicalEngine/DrawUI/Draw.asm"

        include         "Modules/Data/Spawns.inc"

data import

        library kernel32,       "KERNEL32.DLL",\
                user32,         "USER32.DLL",\
                gdi32,          "GDI32.DLL",\
                opengl32,       "OPENGL32.DLL",\
                ws2_32,         "WS2_32.DLL"

        import  ws2_32, WSAStartup, 'WSAStartup', \
                        WSACleanup, 'WSACleanup', \
                        socket, 'socket', \
                        connect, 'connect', \
                        send, 'send', \
                        recv, 'recv', \
                        closesocket, 'closesocket', \
                        inet_addr, 'inet_addr', \
                        htons, 'htons'

end data


        wndClass                WNDCLASS                0, WindowProc, 0, 0, 0, 0, 0, 0, 0, className
        pfd                     PIXELFORMATDESCRIPTOR   sizeof.PIXELFORMATDESCRIPTOR, 1, PFD_FLAGS, PFD_TYPE_RGBA, COLOR_DEPTH,\
                                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
                                                        COLOR_DEPTH, 0, 0, PFD_MAIN_PLANE, 0, PFD_MAIN_PLANE

        clientRect              RECT
        cursorPos               POINT