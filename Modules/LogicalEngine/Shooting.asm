proc rayOBBIntersection uses edi esi ebx,\
     pRayOrigin, pRayDirection, pOBB, pTIn


     locals
         delta          Vector3

         ;proections of delta on Axises
         eX             GLfloat              ?
         eY             GLfloat              ?
         eZ             GLfloat              ?

         ;projections of rayDir on Axises
         fX             GLfloat              ?
         fY             GLfloat              ?
         fZ             GLfloat              ?

         ; Min and max points (entry and exit points of ray)
         tMin           GLfloat              0.0
         tMax           GLfloat              7FFFFFFFh

     endl

         mov            edi, [pOBB]

         stdcall        Matrix.Rotate,  matrixR, 180.0, 0.0, 1.0, 0.0
         stdcall        Vector3.MulMat4, [pRayDirection], 1.0, matrixR, [pRayDirection]

         ;translate ray origin to the obb origin
         lea            esi, [delta]

         stdcall        Vector3.Copy, esi, [pRayOrigin]
         lea            eax, [edi + OBB.c]
         stdcall        Vector3.Sub,  esi, eax

         ;find projections of the delta on the obb axises
         lea            eax, [edi + OBB.u]
         stdcall        Vector3.Dot, esi, eax
         mov            [eX], eax

         lea            eax, [edi + OBB.v]
         stdcall        Vector3.Dot, esi, eax
         mov            [eY], eax

         lea            eax, [edi + OBB.w]
         stdcall        Vector3.Dot, esi, eax
         mov            [eZ], eax

         ;find projections of the ray dir on the obb axises
         mov            esi, [pRayDirection]

         lea            eax, [edi + OBB.u]
         stdcall        Vector3.Dot, esi, eax
         mov            [fX], eax

         lea            eax, [edi + OBB.v]
         stdcall        Vector3.Dot, esi, eax
         mov            [fY], eax

         lea            eax, [edi + OBB.w]
         stdcall        Vector3.Dot, esi, eax
         mov            [fZ], eax


         ;Main logic

         lea            esi, [tMin]
         lea            ebx, [tMax]

         stdcall        CheckAxis, [eX], [fX], [edi + OBB.h + Vector3.x], esi, ebx
         cmp            eax, false
         je             .ReturnFalse

         stdcall        CheckAxis, [eY], [fY], [edi + OBB.h + Vector3.y], esi, ebx
         cmp            eax, false
         je             .ReturnFalse

         stdcall        CheckAxis, [eZ], [fZ], [edi + OBB.h + Vector3.z], esi, ebx
         cmp            eax, false
         je             .ReturnFalse


         fld            dword [tMax]
         fld            dword [tMin]
         fcomip         st,st1
         ja             .ReturnFalse

         fldz
         fld            dword [tMin]
         fcomip         st, st1
         jb             .ReturnFalse
         fstp           dword [tMax]

         fstp           dword [tMax]

         mov            esi, [pTIn]
         mov            eax, [tMin]
         mov            [esi], eax

.ReturnTrue:
         mov            eax, true
         jmp            .Return
.ReturnFalse:
         mov            eax, false
.Return:
         ret
endp


proc    CheckAxis uses esi,\
        e, f, halfSize, pTMin, pTMax

        locals
                tempVal         dd              0.0001

                t1              dd              ?
                t2              dd              ?
        endl

        fld     dword[f]
        fabs

        fld     dword [tempVal]      ;st0

        fcomip  st, st1            ; 0.0001 abs(f)
        jae     .CheckIfIntersect
        fstp    dword [tempVal]
;Main part ----------------------------------

        fld     dword [e]
        fadd    dword [halfSize]
        fdiv    dword [f]
        fstp    dword [t1]

        fld     dword [e]
        fsub    dword [halfSize]
        fdiv    dword [f]
        fstp    dword [t2]

;Update TMin
        minf    t1, t2, tempVal
        mov     esi, [pTMin]
        maxf    esi, tempVal, esi
;Update TMax
        maxf    t1, t2, tempVal
        mov     esi, [pTMax]
        minf    esi, tempVal, esi


        fld     dword [esi]
        mov     esi, [pTMin]
        fld     dword [esi]
        fcomi   st,st1
        ja     .ReturnFalse
        jmp    .ReturnTrue
.CheckIfIntersect:
        fstp    dword [tempVal]
        fstp    dword [tempVal]

        fld     dword [halfSize]
        fld     dword [e]
        fabs
        fcomi   st, st1
        ja      .ReturnFalse

.ReturnTrue:
        mov     eax, true
        jmp     .ReturnWithZeroCl

.ReturnFalse:
        mov     eax, false

.ReturnWithZeroCl:
        fstp    dword [tempVal]
        fstp    dword [tempVal]

.Return:
        ret
endp


proc Player.Shoot uses esi edi ebx,\
     pTank, pfShoot, targets, targetCnt, objects, objCnt

     locals
        minInd           dd             -1
        rayDirection     Vector3        0.0, 0.0, -1.0
        rayOrigin        Vector3
        currMinT         dd             ?
        minT             dd             7FFFFFFFh
        tempOBB          OBB            ?
        hitObjType       dd             0
     endl

     mov        edi, [pfShoot]

     cmp        dword [edi], true
     jne        .Return

;Main part ---------------------------------------
     ;Find ray origin and ray dir

     mov        edi, [pTank]
     lea        esi, [rayOrigin]

     stdcall    Matrix.Rotate, matrixR, 90.0, 0.0, 1.0, 0.0
     stdcall    Matrix.Multiply, matrixR, [edi + Tank.turret + Turret.pTurretMatrix], matrixM

     stdcall    Vector3.MulMat4, shootPointOffs, 1.0, matrixM, esi

     lea        esi, [rayDirection]
     stdcall    Vector3.MulMat4, esi, 0.0, matrixM, esi
     stdcall    Vector3.Normalize, esi

     ;Check for ray collisions with targets
     mov        edi, [targets]
     mov        ecx, [targetCnt]
     lea        ebx, [tempOBB]
.CheckTargetsLoop:
     push       ecx

     mov        esi, [targetCnt]
     sub        esi, ecx
     shl        esi,2

     mov        eax, [edi + esi]
     mov        eax, [eax + Tank.pBodyObj]
     stdcall    Collision.OBB.Copy, ebx, [eax + Object.pOBB]

     mov        eax, [edi + esi]
     stdcall    Collision.OBB.Update, ebx, [eax + Tank.pModelMatrix]


     lea        eax, [rayOrigin]
     lea        ecx, [rayDirection]
     lea        edx, [currMinT]
     stdcall    rayOBBIntersection, eax, ecx, ebx, edx

     cmp        eax, false

     je         .SkipTargetInters

     minf       minT, currMinT, currMinT

     mov        eax, [currMinT]
     cmp        [minT], eax

     je         .SkipTargetInters


     mov        [minT], eax
     shr        esi, 2
     mov        [minInd], esi

.SkipTargetInters:

     pop        ecx
     loop       .CheckTargetsLoop

;Check for ray collisions with map objects
     mov        edi, [objects]
     mov        ecx, [objCnt]

.CheckObjLoop:
     push       ecx

     mov        esi, [objCnt]
     sub        esi, ecx
     shl        esi,2



     lea        edx, [currMinT]
     push       edx

     mov        edx, [edi + esi]

     lea        eax, [rayOrigin]
     lea        ecx, [rayDirection]

     stdcall    rayOBBIntersection, eax, ecx, [edx + Object.pOBB]

     cmp        eax, false

     je         .SkipObjInters

     minf       minT, currMinT, currMinT

     mov        eax, [currMinT]
     cmp        [minT], eax

     je         .SkipObjInters

     mov        [minT], eax
     shr        esi, 2
     mov        [minInd], esi
     mov        dword [hitObjType], 1

.SkipObjInters:

     pop        ecx
     loop       .CheckObjLoop

;-------------------------------------------------

     mov        eax, [minInd]
     cmp        eax, -1
     je         .EndProcessing

     cmp        dword [hitObjType], 0
     jne        .EndProcessing

     stdcall    ProcessHit, [targets], [minInd]

.EndProcessing:
     mov        edi, [pfShoot]
     mov        dword[edi], false
     mov        dword [shootAnimTime], 150
.Return:


        ret
endp


proc ProcessHit uses esi,\
     pTargets, ind
     locals
         temp   dd      ?
     endl

     mov        esi, [pTargets]
     mov        eax, [ind]
     shl        eax, 2

     mov        esi, [esi + eax]

     mov        edx, [lastDrawTime]
     and        edx, 15
     add        edx, stdDamage

     sub        [esi + Tank.hp], edx

     ret
endp