struct Camera
    rotations       Vector3
    position        Vector3
ends

struct Turret
    rotations       Vector3 
    pTurretMatrix   dd          ?
ends
struct Tank
    pBodyObj        dd          ?
    pTurretObj      dd          ?

    turret          Turret  

    pModelMatrix    dd          ?

    position        Vector3     ?   
    rotations       Vector3     ?

    scale           Vector3     ?

    speed           dd          ?


    hp              dd          ?

    id              dd          ?
ends