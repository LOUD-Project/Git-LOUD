local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SAAShleoCannonWeapon = import('/lua/seraphimweapons.lua').SAAShleoCannonWeapon

BSL0106 = Class(SWalkingLandUnit) {
    Weapons = {
        LaserTurret = Class(SAAShleoCannonWeapon) {},
    },
}
TypeClass = BSL0106