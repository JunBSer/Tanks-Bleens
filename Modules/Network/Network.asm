        include         "./Network.inc"

proc Network.Compile
        stdcall Server.Start
        stdcall Server.Free
        stdcall Client.ReadIP
        stdcall Network.Start
        stdcall Client.SendData
        stdcall Client.GetData
        ret
endp

proc Network.Start

        invoke  WSAStartup, TSP_VERSION, wsa
        ret
endp

proc Network.Close

        invoke  WSACleanup
        ret
endp

proc Socket.Create

        invoke  socket, AF_INET, SOCK_STREAM, 0
        mov     [sock], eax
        ret
endp

proc Socket.Close

        invoke  closesocket, [sock]
        ret
endp

proc Socket.Connect

        invoke  inet_addr, [ipAddr]
        mov     [server + sockaddr_in.sin_addr], eax
        mov     [server + sockaddr_in.sin_family], AF_INET
        invoke  htons, PORT
        mov     [server + sockaddr_in.sin_port], ax

        invoke  connect, [sock], server, sizeof.sockaddr_in
        ret
endp

proc Server.Start uses edi esi ebx,\
     countPlayers

        xor     ebx, ebx
        memset  StartupInfo, 0, sizeof.STARTUPINFO
        mov     dword [StartupInfo.cb], sizeof.STARTUPINFO
        memset  ProcessInformation, 0, sizeof.PROCESS_INFORMATION

        mov     eax, [playerCnt]
        add     eax, '0'
        mov     [CommandLine + 30], al

        invoke  CreateProcess, ebx, CommandLine, ebx, ebx, ebx, ebx, ebx, ebx, StartupInfo, ProcessInformation
        ret
endp

proc Server.Free

        invoke  WaitForSingleObject, dword [ProcessInformation.hProcess], 1000000
        invoke  CloseHandle, dword [ProcessInformation.hProcess]
        invoke  CloseHandle, dword [ProcessInformation.hThread]
        ret
endp

proc Client.ReadIP uses esi edi ebx

        locals
                hFile                   dd              ?
                fileData                dd              ?
                fileSize                dd              ?
        endl

        memset  ip, 0, 16
        xor     ebx, ebx
        invoke  CreateFile, ipFilePath, GENERIC_READ, ebx, ebx, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, ebx
        mov     [hFile], eax
        invoke  GetFileSize, [hFile], ebx
        mov     [fileSize], eax
        invoke  ReadFile, [hFile],[ipAddr], [fileSize], ebx, ebx
        invoke  CloseHandle, [hFile]
        invoke  DeleteFile, ipFilePath

        ret
endp

proc Client.GetNumber

        invoke  recv, [sock], buf, MAX_BUF_SIZE, 0
        mov     [bufSize], eax
        mov     eax, dword [buf]

        ret
endp

proc Client.SendData uses esi edi ebx,\
     pTank, hitID

        xor     ebx, ebx
        mov     esi, [pTank]
        lea     eax, [esi + Tank.position]
        lea     edi, [buf + PlayerRequest.position]
        stdcall Vector3.Copy, edi, eax

        lea     eax, [esi + Tank.rotations]
        lea     edi, [buf + PlayerRequest.bodyRot]
        stdcall Vector3.Copy, edi, eax

        lea     eax, [esi + Tank.turret + Turret.rotations]
        lea     edi, [buf + PlayerRequest.turretRot]
        stdcall Vector3.Copy, edi, eax

        mov     eax, dword [hitID]
        mov     dword [buf + PlayerRequest.hitID], eax

        mov     eax, dword [esi + Tank.hp]
        mov     dword [buf + PlayerRequest.hp], eax

        invoke  send, [sock], buf, sizeof.PlayerRequest, ebx
        ret
endp

proc Client.GetData uses esi edi ebx,\
     pTank

        invoke  recv, [sock], buf, MAX_BUF_SIZE, 0
        mov     [bufSize], eax

        mov     edi, [pTank]
        mov     eax, dword [buf + ServerAnswer.hp]
        mov     [edi + Tank.hp], eax

        mov     eax, dword [buf + ServerAnswer.timer]
        mov     [timer], eax

        mov     ecx, dword [buf + ServerAnswer.countChanged] ; ecx <- count of changed users

.Loop:
        cmp     ecx, 0
        jle     .ExitLoop
        push    ecx
        mov     eax, ecx
        dec     eax
        mov     ebx, sizeof.PlayerData
        imul    ebx, eax

        mov     eax, dword [buf + 12 + ebx + PlayerData.id]
        stdcall GetTankByID, eax
        mov     edi, eax        ; edi <- tank by id

        lea     eax, dword [buf + 12 + ebx + PlayerData.position]
        lea     edx, [edi + Tank.position]
        stdcall Vector3.Copy, edx, eax

        lea     eax, dword [buf + 12 + ebx + PlayerData.bodyRot]
        lea     edx, [edi + Tank.rotations]
        stdcall Vector3.Copy, edx, eax

        lea     eax, dword [buf + 12 + ebx + PlayerData.turretRot]
        lea     edx, [edi + Tank.turret + Turret.rotations]
        stdcall Vector3.Copy, edx, eax

        mov     eax, dword [buf + 12 + ebx + PlayerData.hp]
        mov     dword [edi + Tank.hp], eax

        pop     ecx
        dec     ecx
        jmp     .Loop
.ExitLoop:

        ret
endp