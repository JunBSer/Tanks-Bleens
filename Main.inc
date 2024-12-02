        format PE GUI 5.0
        entry  WinMain

; main params        
        true            =               1
        false           =               0

        className               db      "Tanks-Bleens",0h

        hdc                     dd      ?

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

        include         "Modules/PhysicalEngine/Collision.asm"
        include         "../PhysicalEngine/Collision.inc"
        
        include         "Modules/GraphicalEngine/Draw.asm"
        

        include         "Modules/Camera/Camera.asm"
        include         "Modules/Camera/Camera.inc"
data import

        library kernel32,       "KERNEL32.DLL",\
                user32,         "USER32.DLL",\
                gdi32,          "GDI32.DLL",\
                opengl32,       "OPENGL32.DLL"

end data

        wndClass                WNDCLASS                0, WindowProc, 0, 0, 0, 0, 0, 0, 0, className
        pfd                     PIXELFORMATDESCRIPTOR   sizeof.PIXELFORMATDESCRIPTOR, 1, PFD_FLAGS, PFD_TYPE_RGBA, COLOR_DEPTH,\
                                                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
                                                        COLOR_DEPTH, 0, 0, PFD_MAIN_PLANE, 0, PFD_MAIN_PLANE

        clientRect              RECT
        cursorPos               POINT