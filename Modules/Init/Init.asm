        include         "../Glext/GLext.inc"
        include         "../Glext/GLext.asm"
        include         "../Data/Matrix.inc"
        include         "../Data/Vector.inc"
        include         "../Data/Mesh.inc"
        include         "../Data/Tank.inc"
        include         "../LogicalEngine/BBoxes.asm"
        include         "../GraphicalEngine/DrawGame/Matrix.asm"
        include         "../GraphicalEngine/DrawGame/Mesh.asm"
        include         "../Data/Object.inc"
        include         "../Data/GameParams.inc"
        include         "../LogicalEngine/Tank.asm"
        include         "../Camera/Camera.asm"
        include         "../LogicalEngine/Shooting.asm"


proc Init uses esi

        locals
                hMainWindow     dd              ?
        endl

        invoke  GetProcessHeap
        mov     [hHeap], eax

        invoke  RegisterClass, wndClass
        invoke  CreateWindowEx, ebx, className, className, WINDOW_STYLE,\
                        ebx, ebx, ebx, ebx, ebx, ebx, ebx, ebx
        mov     [hMainWindow], eax

        invoke  GetClientRect, eax, clientRect

        invoke  GetDC, [hMainWindow]
        mov     [hdc], eax

        invoke  ChoosePixelFormat, [hdc], pfd
        invoke  SetPixelFormat, [hdc], eax, pfd

        invoke  wglCreateContext, [hdc]
        invoke  wglMakeCurrent, [hdc], eax

        invoke  glEnable, GL_DEPTH_TEST
        invoke  glEnable, GL_BLEND
        invoke  glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA

        invoke  glShadeModel, GL_SMOOTH
        invoke  glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST

        stdcall Glext.LoadFunctions

        stdcall Glext.InitShaders, std_program, std_fragmentShader, std_frShaderFilePath, std_vertexShader, std_vrtxShaderFilePath

        ;stdcall Glext.InitShaders, stat_program, stat_fragmentShader, stat_frShaderFilePath, stat_vertexShader, stat_vrtxShaderFilePath

        stdcall InitDrawGame

        ;stdcall InitDrawUI

        ret
endp

