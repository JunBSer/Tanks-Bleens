struct Object
    pMesh         dd      ?
    pAABB         dd      ?
    pOBB          dd      ?
ends

struct AABB
        maxPoint        Vector3
        minPoint        Vector3
ends

struct OBB
        c               Vector3
        h               Vector3
        u               Vector3
        v               Vector3
        w               Vector3
ends
