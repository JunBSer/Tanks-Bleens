format  PE GUI 5.0
entry   WinMain

        include         "win32a.inc"

        include         "api\kernel32.inc"
        include         "api\user32.inc"
        include         "api\gdi32.inc"
        include         "api\opengl.inc"

        include         "Mesh.inc"
        include         "Vector.inc"
        include         "Matrix.inc"
        include         "File\File.inc"

macro JumpIf value, label
{
        cmp     eax, value
        je      label
}

        include         "Cube.inc"

        VK_W            =       0x57
        VK_S            =       0x53
        VK_A            =       0x41
        VK_D            =       0x44
        VK_E            =       0x45
        VK_Q            =       0x51


        true            =       1
        false           =       0

        COLOR_DEPTH     =       24
        PFD_FLAGS       =       PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or PFD_DRAW_TO_WINDOW
        WINDOW_STYLE    =       WS_VISIBLE or WS_MAXIMIZE or WS_POPUP
        FOV             =       60.0
        Z_NEAR          =       0.0001
        Z_FAR           =       10000.0

        wndClass        WNDCLASS                0, WindowProc, 0, 0, 0, 0, 0, 0, 0, className
        pfd             PIXELFORMATDESCRIPTOR   sizeof.PIXELFORMATDESCRIPTOR, 1, PFD_FLAGS, PFD_TYPE_RGBA, COLOR_DEPTH,\
                                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
                                                COLOR_DEPTH, 0, 0, PFD_MAIN_PLANE, 0, PFD_MAIN_PLANE


        mesh           Mesh                    ;planeVertices,planeColors,planeIndices,PLANE_TRIANGLES_COUNT
        plane          Mesh

data import

        library kernel32,       "KERNEL32.DLL",\
                user32,         "USER32.DLL",\
                gdi32,          "GDI32.DLL",\
                opengl32,       "OPENGL32.DLL"

end data