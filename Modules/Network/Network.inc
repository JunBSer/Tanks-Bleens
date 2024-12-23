        ; Network
        wsa                     WSADATA
        sock                    dd                      ?
        server                  sockaddr_in
        buf                     db                      1024 dup(?)
        bufSize                 dd                      0
        MAX_BUF_SIZE            =                       1024
        ip                      db                      16 dup(0)
        PORT                    =                       8080
        ipFilePath              db                      ".\Resources\Server\ip.tmp"
        TSP_VERSION             =                       0x202

        ; Process
        CommandLine             db                      ".\Resources\Server\server.exe 0", 0
        StartupInfo             STARTUPINFO
        ProcessInformation      PROCESS_INFORMATION

        ; Timer
        timer                   dd                      0

struct PlayerRequest
        position                Vector3
        bodyRot                 Vector3
        turretRot               Vector3
        hitID                   dd                      ?
        hp                      dd                      ?
ends

struct ServerAnswer
        hp                      dd                      ?
        timer                   dd                      ?
        countChanged            dd                      ?
        players                 dd                      ?
ends

struct PlayerData
        id                      dd                      ?
        position                Vector3
        bodyRot                 Vector3
        turretRot               Vector3
        hp                      dd                      ?
ends