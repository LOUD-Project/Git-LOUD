local SWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local SAAShleoCannonWeapon = import('/lua/seraphimweapons.lua').SAAShleoCannonWeapon

BSL0206 = Class(SWalkingLandUnit) {
    Weapons = {
        LaserTurret = Class(SAAShleoCannonWeapon) {},
    },
}
TypeClass = BSL0206