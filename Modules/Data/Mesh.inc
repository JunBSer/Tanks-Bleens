struct Vertex
        x               GLfloat     ?
        y               GLfloat     ?
        z               GLfloat     ?
ends

;struct Vertex
    ;    x               GLfloat     ?
    ;    y               GLfloat     ?
    ;    z               GLfloat     ?

    ;    nx              GLfloat     ?
    ;    ny              GLfloat     ? 
    ;    nz              GLfloat     ?              

    ;    u               GLfloat     ?
    ;    v               GLfloat     ? 
;ends

struct Mesh     
        VAO             GLuint               ?
        VBOvert         GLuint               ?
        VBOnorm         GLuint               ?
        VBOtex          GLuint               ?
       
        vertexCnt       dd                   ? 
        textureID       GLuint               ? 
       
ends 
        ; indexCnt        dd          ? 
        ; indices         dd          ?