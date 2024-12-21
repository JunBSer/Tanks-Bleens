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
        include         "../GraphicalEngine/DrawUI/ElementHandlers.asm"
        include         "../GraphicalEngine/DrawUI/Button.inc"
        include         "../GraphicalEngine/DrawUI/UIActions.asm"



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


        invoke  glEnable, GL_BLEND
        invoke  glBlendFunc, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA

        invoke  glShadeModel, GL_SMOOTH
        invoke  glHint, GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST

;Init Game params

        stdcall Glext.LoadFunctions

        stdcall Glext.InitShaders, stat_program, stat_fragmentShader, stat_frShaderFilePath, stat_vertexShader, stat_vrtxShaderFilePath

        stdcall InitResolutionParams
        mov     [resolutScale], eax

        stdcall InitDrawParams
        stdcall InitTextures


        stdcall InitDrawUI

        ret
endp

proc    InitDrawParams

          mov     eax, [clientRect.right]
          sar     eax, 1
          mov     [windowWidthH], eax
          mov     eax, [clientRect.bottom]
          sar     eax, 1
          mov     [windowHeightH], eax

         ret
endp



proc   InitTextures

     stdcall    InitTexture, mainTxtFilePath
     mov        [mainTextID], eax

     stdcall    InitTexture, tankTxtFilePath
     mov        [tankTextID], eax

     stdcall    InitTexture, crosshairFilePath
     mov        [crossTextID],eax

     stdcall    InitTexture, shootFilePath
     mov        [shootTextID],eax

       ret
endp

proc    InitResolutionParams uses esi

        locals
                tempX   dd      ?
                tempY   dd      ?
        endl

      ;  int     3
        malloc  sizeof.Vector3
        mov     esi, eax

        fild    [clientRect.right]
        mov     dword [tempX], stdResolutionX
        fdiv    [tempX]
        fstp    [tempX]

        fild    [clientRect.bottom]
        mov     dword [tempY], stdResolutionY
        fdiv    [tempY]
        fstp    [tempY]

        lea     eax, [esi + Vector3.y]
        minf    tempX, tempY, eax
        mov     eax, [esi + Vector3.y]
        mov     [esi + Vector3.x], eax
        mov     [esi + Vector3.z], 1.0

        mov     eax, esi

        ret
endp