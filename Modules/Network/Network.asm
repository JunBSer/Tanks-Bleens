        include         "./Network.inc"

proc Network.Prototype uses esi edi ebx

        invoke  WSAStartup, 0x202, wsa
        invoke  socket, AF_INET, SOCK_STREAM, 0
        mov     [sock], eax

        invoke  inet_addr, ip
        mov     [server + sockaddr_in.sin_addr], eax
        mov     [server + sockaddr_in.sin_family], AF_INET
        invoke  htons, 8080
        mov     [server + sockaddr_in.sin_port], ax

        invoke  connect, [sock], server, sizeof.sockaddr_in
        invoke  recv, [sock], message, 1024, 0
        mov     [messageSize], eax

        invoke  closesocket, [sock]
        invoke  WSACleanup
        ret
endp   


