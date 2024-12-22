wsa             WSADATA
sock            dd                      ?
server          sockaddr_in
message         db                      1024 dup(?)
messageSize     dd                      0
ip              db                      "192.168.1.105", 0       